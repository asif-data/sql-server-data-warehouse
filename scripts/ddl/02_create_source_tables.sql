/*
=============================================================================
Script: 02_create_source_tables.sql
Description: Creates ingestion tables for CRM and ERP systems in 'src' schema.
=============================================================================
*/

USE sql_server_dwh;
GO

-- 1. CRM: Customer Info
IF OBJECT_ID('src.src_crm_cust_info', 'U') IS NOT NULL DROP TABLE src.src_crm_cust_info;
CREATE TABLE src.src_crm_cust_info (
    cst_id             INT,
    cst_key            VARCHAR(50),
    cst_firstname      VARCHAR(50),
    cst_lastname       VARCHAR(50),
    cst_marital_status VARCHAR(10),
    cst_gndr           VARCHAR(10),
    cst_create_date    DATE
);

-- 2. CRM: Product Info
IF OBJECT_ID('src.src_crm_prd_info', 'U') IS NOT NULL DROP TABLE src.src_crm_prd_info;
CREATE TABLE src.src_crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(100),
    prd_cost     DECIMAL(18, 4),
    prd_line     VARCHAR(10),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);

-- 3. CRM: Sales Details
IF OBJECT_ID('src.src_crm_sales_details', 'U') IS NOT NULL DROP TABLE src.src_crm_sales_details;
CREATE TABLE src.src_crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,  -- Stored as INT to match YYYYMMDD format
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    DECIMAL(18, 4),
    sls_quantity INT,
    sls_price    DECIMAL(18, 4)
);

-- 4. ERP: Customer Data (AZ12)
IF OBJECT_ID('src.src_erp_cust_az12', 'U') IS NOT NULL DROP TABLE src.src_erp_cust_az12;
CREATE TABLE src.src_erp_cust_az12 (
    CID   VARCHAR(50),
    BDATE DATE,
    GEN   VARCHAR(20)
);

-- 5. ERP: Location Data (A101)
IF OBJECT_ID('src.src_erp_loc_a101', 'U') IS NOT NULL DROP TABLE src.src_erp_loc_a101;
CREATE TABLE src.src_erp_loc_a101 (
    CID    VARCHAR(50),
    CNTRY  VARCHAR(50)
);

-- 6. ERP: Product Category (G1V2)
IF OBJECT_ID('src.src_erp_px_cat_g1v2', 'U') IS NOT NULL DROP TABLE src.src_erp_px_cat_g1v2;
CREATE TABLE src.src_erp_px_cat_g1v2 (
    ID           VARCHAR(50),
    CAT          VARCHAR(50),
    SUBCAT       VARCHAR(50),
    MAINTENANCE  VARCHAR(10)
);
GO