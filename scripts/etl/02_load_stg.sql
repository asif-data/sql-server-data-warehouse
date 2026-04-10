/*
=============================================================================
Script: 02_load_stg.sql
Description: Executes the unified staging stored procedure to cleanse 
             and load data from the 'src' schema to the 'stg' schema.
=============================================================================
*/

EXEC stg.usp_load_stg;
