use role accountadmin;

create warehouse bookstore_wh 
    with warehouse_size='x-small'
    auto_suspend=120
    auto_resume=true
    initially_suspended=true;
create database if not exists bookstore_db;
create role if not exists bookstore_role;

show grants on warehouse bookstore_wh;

grant usage on warehouse bookstore_wh to role bookstore_role;
grant role bookstore_role to user yourusername;
grant all on database bookstore_db to role bookstore_role;

use role bookstore_role;
create schema bookstore_db.stage_schema;
create schema bookstore_db.bookstore_schema;

use role accountadmin;
drop warehouse if exists bookstore_wh;
drop database if exists bookstore_db;
drop role if exists bookstore_role;
