/*
=============================================================================
Validation Script: Master Staging Layer Quality Check
Description: This script combines quality checks for all 6 staging tables.
             It verifies:
             - Key Integrity (Duplicates/Nulls)
             - Data Formatting (Whitespace/Cleaning)
             - Business Logic (Date ranges/Financials)
             - Audit Traceability (Metadata)
=============================================================================
*/

USE sql_server_dwh;
GO

PRINT '=====================================================================';
PRINT 'STARTING DATA QUALITY VALIDATION FOR STAGING LAYER';
PRINT '=====================================================================';

/*
-----------------------------------------------------------------------------
SECTION 1: CRM SYSTEM TABLES
-----------------------------------------------------------------------------
*/

-- 1.1 CRM CUSTOMER INFO
PRINT '------------------------------------------------';
PRINT '>> Validating: stg.stg_crm_cust_info';
PRINT '------------------------------------------------';

PRINT '>> Checking for Duplicates and Nulls in cst_id...';
SELECT cst_id, COUNT(*) as duplicate_count FROM stg.stg_crm_cust_info GROUP BY cst_id HAVING COUNT(*) > 1 OR cst_id IS NULL;

PRINT '>> Checking for Nulls and Whitespace issues...';
SELECT 
    SUM(CASE WHEN cst_key IS NULL THEN 1 ELSE 0 END) AS null_cst_key,
    SUM(CASE WHEN cst_key != TRIM(cst_key) THEN 1 ELSE 0 END) AS whitespace_cst_key,
    SUM(CASE WHEN cst_firstname IS NULL THEN 1 ELSE 0 END) AS null_firstname,
    SUM(CASE WHEN cst_lastname IS NULL THEN 1 ELSE 0 END) AS null_lastname
FROM stg.stg_crm_cust_info;

PRINT '>> Checking distribution of Gender and Marital Status...';
SELECT DISTINCT cst_gndr FROM stg.stg_crm_cust_info;
SELECT DISTINCT cst_marital_status FROM stg.stg_crm_cust_info;

-- 1.2 CRM PRODUCT INFO
PRINT '------------------------------------------------';
PRINT '>> Validating: stg.stg_crm_prd_info';
PRINT '------------------------------------------------';

PRINT '>> Checking for Duplicates and Nulls in prd_id...';
SELECT prd_id, COUNT(*) as duplicate_count FROM stg.stg_crm_prd_info GROUP BY prd_id HAVING COUNT(*) > 1 OR prd_id IS NULL;

PRINT '>> Checking for Nulls, Whitespace, and invalid Costs...';
SELECT 
    SUM(CASE WHEN prd_nm IS NULL THEN 1 ELSE 0 END) AS null_prd_nm,
    SUM(CASE WHEN prd_nm != TRIM(prd_nm) THEN 1 ELSE 0 END) AS whitespace_prd_nm,
    SUM(CASE WHEN prd_cost < 0 THEN 1 ELSE 0 END) AS negative_prd_cost
FROM stg.stg_crm_prd_info;

PRINT '>> Checking for invalid date logic (End < Start)...';
SELECT * FROM stg.stg_crm_prd_info WHERE prd_end_dt < prd_start_dt;

-- 1.3 CRM SALES DETAILS
PRINT '------------------------------------------------';
PRINT '>> Validating: stg.stg_crm_sales_details';
PRINT '------------------------------------------------';

PRINT '>> Checking for NULLs in sls_ord_num...';
SELECT COUNT(*) as NULL_count FROM stg.stg_crm_sales_details WHERE sls_ord_num IS NULL;

PRINT '>> Checking for invalid date logic (Ship/Due < Order)...';
SELECT * FROM stg.stg_crm_sales_details WHERE sls_ship_dt < sls_order_dt OR sls_due_dt < sls_order_dt;

PRINT '>> Checking for mathematical inconsistencies in financials...';
SELECT sls_ord_num, sls_sales, sls_quantity, sls_price, (sls_quantity * sls_price) AS expected_sales
FROM stg.stg_crm_sales_details
WHERE sls_sales != sls_quantity * sls_price OR sls_sales <= 0;

/*
-----------------------------------------------------------------------------
SECTION 2: ERP SYSTEM TABLES
-----------------------------------------------------------------------------
*/

-- 2.1 ERP CUSTOMER (AZ12)
PRINT '------------------------------------------------';
PRINT '>> Validating: stg.stg_erp_cust_az12';
PRINT '------------------------------------------------';

PRINT '>> Checking for Nulls, Duplicates, or remaining "NAS" prefixes...';
SELECT CID, COUNT(*) as duplicate_count FROM stg.stg_erp_cust_az12 WHERE CID IS NULL OR CID LIKE 'NAS%' GROUP BY CID HAVING COUNT(*) > 1 OR CID IS NULL;

PRINT '>> Checking for future birth dates...';
SELECT * FROM stg.stg_erp_cust_az12 WHERE BDATE > GETDATE();

-- 2.2 ERP LOCATION (A101)
PRINT '------------------------------------------------';
PRINT '>> Validating: stg.stg_erp_loc_a101';
PRINT '------------------------------------------------';

PRINT '>> Checking for Nulls, Duplicates, or remaining hyphens in CID...';
SELECT CID, COUNT(*) as duplicate_count FROM stg.stg_erp_loc_a101 WHERE CID IS NULL OR CID LIKE '%-%' GROUP BY CID HAVING COUNT(*) > 1;

PRINT '>> Checking Country distribution and unexpected abbreviations...';
SELECT CNTRY, COUNT(*) as record_count FROM stg.stg_erp_loc_a101 GROUP BY CNTRY ORDER BY record_count DESC;

-- 2.3 ERP PRODUCT CATEGORY (G1V2)
PRINT '------------------------------------------------';
PRINT '>> Validating: stg.stg_erp_px_cat_g1v2';
PRINT '------------------------------------------------';

PRINT '>> Checking for Duplicates in ID...';
SELECT ID, COUNT(*) as duplicate_count FROM stg.stg_erp_px_cat_g1v2 GROUP BY ID HAVING COUNT(*) > 1 OR ID IS NULL;

PRINT '>> Checking CAT and SUBCAT distribution...';
SELECT CAT, COUNT(SUBCAT) as subcat_count FROM stg.stg_erp_px_cat_g1v2 GROUP BY CAT;

/*
-----------------------------------------------------------------------------
FINAL GLOBAL CHECKS
-----------------------------------------------------------------------------
*/

PRINT '------------------------------------------------';
PRINT '>> GLOBAL AUDIT CHECK';
PRINT '------------------------------------------------';

PRINT '>> Verifying audit metadata coverage across all staging tables...';
SELECT 'stg_crm_cust_info' AS tbl, COUNT(*) FROM stg.stg_crm_cust_info WHERE audit_load_timestamp IS NULL
UNION ALL
SELECT 'stg_crm_prd_info', COUNT(*) FROM stg.stg_crm_prd_info WHERE audit_load_timestamp IS NULL
UNION ALL
SELECT 'stg_crm_sales_details', COUNT(*) FROM stg.stg_crm_sales_details WHERE audit_load_timestamp IS NULL
UNION ALL
SELECT 'stg_erp_cust_az12', COUNT(*) FROM stg.stg_erp_cust_az12 WHERE audit_load_timestamp IS NULL
UNION ALL
SELECT 'stg_erp_loc_a101', COUNT(*) FROM stg.stg_erp_loc_a101 WHERE audit_load_timestamp IS NULL
UNION ALL
SELECT 'stg_erp_px_cat_g1v2', COUNT(*) FROM stg.stg_erp_px_cat_g1v2 WHERE audit_load_timestamp IS NULL;

PRINT '=====================================================================';
PRINT 'VALIDATION COMPLETE';
PRINT '=====================================================================';
GO
