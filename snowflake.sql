USE ROLE accountadmin;

CREATE WAREHOUSE bookstore_wh 
    with warehouse_size='x-small'
    auto_suspend=120
    auto_resume=true
    initially_suspended=true;
CREATE DATABASE IF NOT EXISTS bookstore_db;
CREATE ROLE IF NOT EXISTS bookstore_role;

GRANT USAGE ON WAREHOUSE bookstore_wh TO ROLE bookstore_role;
GRANT ROLE bookstore_role TO USER YOUR-USERNAME;
GRANT ALL ON DATABASE bookstore_db TO ROLE bookstore_role;

USE ROLE bookstore_role;
CREATE SCHEMA bookstore_db.stage_schema;
CREATE SCHEMA bookstore_db.bookstore_schema;

-- END


-- DELETE RESOURCES
-- USE ROLE accountadmin;
-- DROP WAREHOUSE IF EXISTS bookstore_wh;
-- DROP DATABASE IF EXISTS bookstore_db;
-- DROP ROLE IF EXISTS bookstore_role;


-- CREATE CONSUMER USER
-- USE ROLE accountadmin;
-- CREATE ROLE IF NOT EXISTS consumer_role;
-- CREATE USER consumer_user
-- PASSWORD = 'StrongPassword123!'
-- DEFAULT_ROLE = 'PUBLIC'
-- MUST_CHANGE_PASSWORD = FALSE
-- COMMENT = 'User created for data consumption purposes';
-- GRANT USAGE ON WAREHOUSE bookstore_wh TO ROLE consumer_role;
-- GRANT ROLE consumer_role TO USER consumer_user;
-- GRANT USAGE ON DATABASE bookstore_db TO ROLE consumer_role;
-- GRANT USAGE ON SCHEMA bookstore_db.bookstore_schema TO ROLE consumer_role;
-- GRANT SELECT ON ALL TABLES IN SCHEMA bookstore_db.bookstore_schema TO ROLE consumer_role;
-- ALTER USER consumer_user
-- SET DEFAULT_ROLE = consumer_role,
--     DEFAULT_WAREHOUSE = bookstore_wh;
