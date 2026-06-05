/*
===============================================================================
Create Database and Schemas
===============================================================================

Script Purpose:
    This script creates the DataWarehouse database and sets up the
    Bronze, Silver, and Gold schemas used in the data warehouse architecture.

    - Bronze : Stores raw data from source systems.
    - Silver : Stores cleaned and transformed data.
    - Gold   : Stores business-ready data for reporting and analytics.

Warning:
    This script will drop the existing 'DataWarehouse' database if it exists.
    All data within the database will be permanently deleted.
    Ensure that any required backups have been taken before execution.

===============================================================================
*/


use master;

--Drop and recreate the "DataWarehouse" database
if exists (select 1 from sys.databases where name = 'DataWarehouse')
begin
  alter database DataWarehouse set single_user with rollback immediate;
  drop database DataWarehouse;
end;
go

--create the "DataWarehouse" database
create database DataWarehouse;
go
  
use DataWarehouse;
go

--create schemas
create schema bronze;
go
  
create schema silver;
go
  
create schema gold;
go
