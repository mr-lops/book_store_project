USE ROLE accountadmin;

CREATE WAREHOUSE bookstore_wh 
    with warehouse_size='x-small'
    auto_suspend=120
    auto_resume=true
    initially_suspended=true;
CREATE DATABASE IF NOT EXISTS bookstore_db;
CREATE ROLE IF NOT EXISTS bookstore_role;

GRANT USAGE ON warehouse bookstore_wh TO ROLE bookstore_role;
GRANT ROLE bookstore_role TO USER yourusername;
GRANT ALL ON DATABASE bookstore_db TO ROLE bookstore_role;

USE ROLE bookstore_role;
CREATE SCHEMA bookstore_db.stage_schema;

USE ROLE accountadmin;
DROP WAREHOUSE IF EXISTS bookstore_wh;
DROP DATABASE IF EXISTS bookstore_db;
DROP ROLE IF EXISTS bookstore_role;
