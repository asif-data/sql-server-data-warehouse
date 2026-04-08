/*
=============================================================================
Project: SQL Server Data Warehouse
Script: 01_setup_database.sql
Description: Initializes the Database and the Raw, Staging, and Core schemas.
=============================================================================
*/

-- 1. Create the Database
-- Check if the database exists; if not, create it.
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'sql_server_dwh')
BEGIN
    CREATE DATABASE sql_server_dwh;
    PRINT 'Database "sql_server_dwh" created successfully.';
END
ELSE
BEGIN
    PRINT 'Database "sql_server_dwh" already exists.';
END
GO

-- 2. Switch context to the new database
USE sql_server_dwh;
GO

-- 3. Create Schemas
-- These schemas align with the layers: Raw Ingestion, Staging, and Analytics.

-- Schema for Raw Data (Source)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'src')
BEGIN
    EXEC('CREATE SCHEMA src');
    PRINT 'Schema "src" created.';
END
ELSE
BEGIN
    PRINT 'Schema "src" already exists.';
END
GO

-- Schema for Staging/Cleansing
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg');
    PRINT 'Schema "stg" created.';
END
ELSE
BEGIN
    PRINT 'Schema "stg" already exists.';
END
GO

-- Schema for Final Analytics/Core
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'core')
BEGIN
    EXEC('CREATE SCHEMA core');
    PRINT 'Schema "core" created.';
END
ELSE
BEGIN
    PRINT 'Schema "core" already exists.';
END
GO