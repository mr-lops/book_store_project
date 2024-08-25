from cosmos.config import ProfileConfig, ProjectConfig
from pathlib import Path

DBT_PROJECT_CONFIG = ProjectConfig(
    dbt_project_path="/usr/local/airflow/include/dbt/",
)

DBT_CONFIG_DEV = ProfileConfig(
    profile_name='book_store',
    target_name='dev',
    profiles_yml_filepath=Path(
        "/usr/local/airflow/include/dbt/profiles.yml")
)

# Configuração do profile com o target prod
DBT_CONFIG_STAGE = ProfileConfig(
    profile_name='book_store',
    target_name='staging',
    profiles_yml_filepath=Path(
        "/usr/local/airflow/include/dbt/profiles.yml")
)
