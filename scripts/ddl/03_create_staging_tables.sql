/*
=============================================================================
Script: 03_create_staging_tables.sql
Description: Creates staging tables in the 'stg' schema. 
             Metadata columns follow the 'audit_' naming convention.
=============================================================================
*/

USE sql_server_dwh;
GO

-- 1. CRM Customer Info
IF OBJECT_ID('stg.stg_crm_cust_info', 'U') IS NOT NULL DROP TABLE stg.stg_crm_cust_info;
CREATE TABLE stg.stg_crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(10),
    cst_gndr           VARCHAR(10),
    cst_create_date    DATE,
    audit_load_timestamp DATETIME DEFAULT GETDATE()
);

-- 2. CRM Product Info
IF OBJECT_ID('stg.stg_crm_prd_info', 'U') IS NOT NULL DROP TABLE stg.stg_crm_prd_info;
CREATE TABLE stg.stg_crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(100),
    prd_cost     DECIMAL(18, 4),
    prd_line     VARCHAR(10),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME,
    audit_load_timestamp DATETIME DEFAULT GETDATE()
);

-- 3. CRM Sales Details
IF OBJECT_ID('stg.stg_crm_sales_details', 'U') IS NOT NULL DROP TABLE stg.stg_crm_sales_details;
CREATE TABLE stg.stg_crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    DECIMAL(18, 4),
    sls_quantity INT,
    sls_price    DECIMAL(18, 4),
    audit_load_timestamp DATETIME DEFAULT GETDATE()
);

-- 4. ERP Customer Data (AZ12)
IF OBJECT_ID('stg.stg_erp_cust_az12', 'U') IS NOT NULL DROP TABLE stg.stg_erp_cust_az12;
CREATE TABLE stg.stg_erp_cust_az12 (
    CID   VARCHAR(50),
    BDATE DATE,
    GEN   VARCHAR(20),
    audit_load_timestamp DATETIME DEFAULT GETDATE()
);

-- 5. ERP Location Data (A101)
IF OBJECT_ID('stg.stg_erp_loc_a101', 'U') IS NOT NULL DROP TABLE stg.stg_erp_loc_a101;
CREATE TABLE stg.stg_erp_loc_a101 (
    CID    VARCHAR(50),
    CNTRY  VARCHAR(50),
    audit_load_timestamp DATETIME DEFAULT GETDATE()
);

-- 6. ERP Product Category (G1V2)
IF OBJECT_ID('stg.stg_erp_px_cat_g1v2', 'U') IS NOT NULL DROP TABLE stg.stg_erp_px_cat_g1v2;
CREATE TABLE stg.stg_erp_px_cat_g1v2 (
    ID           VARCHAR(50),
    CAT          VARCHAR(50),
    SUBCAT       VARCHAR(50),
    MAINTENANCE  VARCHAR(10),
    audit_load_timestamp DATETIME DEFAULT GETDATE()
);
GO