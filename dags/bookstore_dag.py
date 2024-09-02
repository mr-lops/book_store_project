from airflow.decorators import dag, task, task_group
from datetime import datetime, timedelta
import os

from include.dbt.cosmos_config import DBT_PROJECT_CONFIG, DBT_CONFIG

from cosmos.airflow.task_group import DbtTaskGroup
from cosmos.constants import LoadMode
from cosmos.config import RenderConfig, ExecutionConfig

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
}


@dag(
    dag_id="bookstore_project",
    default_args=default_args,
    schedule=None,
    catchup=False,
    tags=["bookstore", "snowflake", "dbt"],
)
def bookstore_pipeline():

    @task_group(group_id="mysql_to_snowflake")
    def mysql_to_snowflake():

        SOURCE_ID = "mysql://myuser:mypassword@mysql:3306/bookstoredb"

        DESTINATION_ID = (
            f"{os.environ['SNOWFLAKE_USER']}:"
            f"{os.environ['SNOWFLAKE_PASSWORD']}@"
            f"{os.environ['SNOWFLAKE_ACCOUNT']}.snowflakecomputing.com:443/"
            f"{os.environ['SNOWFLAKE_DB']}/{os.environ['SNOWFLAKE_SCHEMA']}?"
            f"warehouse={os.environ['SNOWFLAKE_WH']}&role={os.environ['SNOWFLAKE_ROLE']}")

        @task.external_python(python='/usr/local/airflow/polars_venv/bin/python')
        def get_tables_from_source(source) -> list:
            import polars as pl
            query = ("select TABLE_NAME "
                     "from information_schema.tables "
                     "where table_schema = 'bookstoredb'")
            df = pl.read_database_uri(query, source, engine="connectorx")
            tables = df.to_series().to_list()
            return tables

        @task.external_python(python='/usr/local/airflow/polars_venv/bin/python')
        def create_tables_into_destination(tables: list, source, destination):
            import polars as pl
            import adbc_driver_snowflake.dbapi

            for table in tables:
                query = ("select column_name, column_type "
                         "from information_schema.columns "
                         "where table_schema = 'bookstoredb' "
                         f"and table_name = '{table}'")
                df = pl.read_database_uri(query, source, engine="connectorx")
                columns_def = ", ".join([f"{row['COLUMN_NAME']} {row['COLUMN_TYPE'].decode('utf-8')}" for row in df.to_dicts()])
                create_table_query = f"create or replace table {table} ({columns_def})"
                with adbc_driver_snowflake.dbapi.connect(destination) as sn_conn:
                    with sn_conn.cursor() as sn_cursor:
                        sn_cursor.execute(create_table_query)

            return tables

        @task.external_python(python='/usr/local/airflow/polars_venv/bin/python')
        def copy_data_to_destination(tables: list, source, destination):
            import polars as pl
            for table in tables:
                query_table_content = f"select * from {table}"
                df = pl.read_database_uri(query_table_content, source, engine="connectorx")
                df.write_database(table_name=table.upper(), connection=destination,
                                  if_table_exists="append", engine='adbc')

        source_tables = get_tables_from_source(SOURCE_ID)
        source_tables = create_tables_into_destination(source_tables, SOURCE_ID, DESTINATION_ID)
        copy_data_to_destination(source_tables, SOURCE_ID, ("snowflake://"+DESTINATION_ID))

    @task.external_python(python='/usr/local/airflow/soda_venv/bin/python')
    def check_stage(scan_name='check_stage', checks_subpath='stage', data_source='stage'):
        from include.soda.check_function import check

        return check(scan_name, checks_subpath, data_source)
    
    staging_area = DbtTaskGroup(
        group_id='staging_area',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        execution_config=ExecutionConfig(
            dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"),
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/staging']
        )
    )
    
    data_warehouse = DbtTaskGroup(
        group_id='data_warehouse',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        execution_config=ExecutionConfig(
            dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"),
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/intermediate']
        )
    )
    
    @task.external_python(python='/usr/local/airflow/soda_venv/bin/python')
    def check_data_warehouse(scan_name='check_data_warehouse', checks_subpath='intermediate', data_source='book_store'):
        from include.soda.check_function import check

        return check(scan_name, checks_subpath, data_source)
    
    report = DbtTaskGroup(
        group_id='report',
        project_config=DBT_PROJECT_CONFIG,
        profile_config=DBT_CONFIG,
        execution_config=ExecutionConfig(
            dbt_executable_path=f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"),
        render_config=RenderConfig(
            load_method=LoadMode.DBT_LS,
            select=['path:models/report']
        )
    )
    
    @task.external_python(python='/usr/local/airflow/soda_venv/bin/python')
    def check_report(scan_name='check_report', checks_subpath='report', data_source='book_store'):
        from include.soda.check_function import check

        return check(scan_name, checks_subpath, data_source)
    
    mysql_to_snowflake() >> check_stage() >> staging_area
    staging_area >> data_warehouse >> check_data_warehouse() >> report
    report >> check_report()


bookstore_dag = bookstore_pipeline()
