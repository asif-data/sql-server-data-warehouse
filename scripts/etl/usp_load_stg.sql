/*
=============================================================================
Stored Procedure: stg.usp_load_stg
Description: Cleanses and loads data from 'src' schema into 'stg' schema.
             Orchestrates the entire Staging layer ETL process.
             - Deduplication
             - Data Type Conversion
             - Business Logic Enforcement
             - Audit Metadata Generation

Execution:
    EXEC stg.usp_load_stg;
=============================================================================
*/

CREATE OR ALTER PROCEDURE stg.usp_load_stg
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    DECLARE @rows_affected INT; 
    
    SET @batch_start_time = GETDATE();
    PRINT '================================================';
    PRINT 'Starting Staging Load Process at ' + CAST(@batch_start_time AS VARCHAR);
    PRINT '================================================';

    BEGIN TRY
        
        -- ====================================================================
        -- SECTION 1: CRM DATA LOAD
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT '>> Loading CRM Tables';
        PRINT '------------------------------------------------';

        -- 1.1 Load stg.stg_crm_cust_info
        SET @start_time = GETDATE();
        TRUNCATE TABLE stg.stg_crm_cust_info;

        ;WITH deduplicated_data AS (
            SELECT cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS record_rank
            FROM src.src_crm_cust_info WHERE cst_id IS NOT NULL
        )
        INSERT INTO stg.stg_crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
        SELECT cst_id, cst_key, TRIM(cst_firstname), TRIM(cst_lastname),
               CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' ELSE 'n/a' END,
               CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' ELSE 'n/a' END,
               cst_create_date
        FROM deduplicated_data WHERE record_rank = 1;
        
        SET @rows_affected = @@ROWCOUNT; 
        SET @end_time = GETDATE();
        PRINT '>> [stg.stg_crm_cust_info] loaded ' + CAST(@rows_affected AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 1.2 Load stg.stg_crm_prd_info
        SET @start_time = GETDATE();
        TRUNCATE TABLE stg.stg_crm_prd_info;

        ;WITH transformed_prd AS (
            SELECT prd_id, REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, prd_nm,
                   ISNULL(prd_cost, 0) AS prd_cost,
                   CASE UPPER(TRIM(prd_line)) WHEN 'M' THEN 'Mountain' WHEN 'R' THEN 'Road' WHEN 'S' THEN 'Other Sales' WHEN 'T' THEN 'Touring' ELSE 'n/a' END AS prd_line,
                   CAST(prd_start_dt AS DATE) AS prd_start_dt,
                   CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
            FROM src.src_crm_prd_info
        )
        INSERT INTO stg.stg_crm_prd_info (prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
        SELECT prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt FROM transformed_prd;
        
        SET @rows_affected = @@ROWCOUNT; -- CAPTURE IMMEDIATELY
        SET @end_time = GETDATE();
        PRINT '>> [stg.stg_crm_prd_info] loaded ' + CAST(@rows_affected AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 1.3 Load stg.stg_crm_sales_details
        SET @start_time = GETDATE();
        TRUNCATE TABLE stg.stg_crm_sales_details;

        ;WITH cleansed_sales AS (
            SELECT sls_ord_num, sls_prd_key, sls_cust_id,
                   CASE WHEN sls_order_dt <= 0 OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
                   CASE WHEN sls_ship_dt <= 0 OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 THEN NULL ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
                   CASE WHEN sls_due_dt <= 0 OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8 THEN NULL ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
                   CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END AS sls_sales,
                   sls_quantity,
                   CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0) ELSE sls_price END AS sls_price
            FROM src.src_crm_sales_details
        )
        INSERT INTO stg.stg_crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
        SELECT * FROM cleansed_sales;
        
        SET @rows_affected = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> [stg.stg_crm_sales_details] loaded ' + CAST(@rows_affected AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- ====================================================================
        -- SECTION 2: ERP DATA LOAD
        -- ====================================================================
        PRINT '------------------------------------------------';
        PRINT '>> Loading ERP Tables';
        PRINT '------------------------------------------------';

        -- 2.1 Load stg.stg_erp_cust_az12
        SET @start_time = GETDATE();
        TRUNCATE TABLE stg.stg_erp_cust_az12;

        ;WITH cleansed_erp_cust AS (
            SELECT CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID)) ELSE CID END AS CID,
                   CASE WHEN BDATE > GETDATE() THEN NULL ELSE BDATE END AS BDATE,
                   CASE UPPER(TRIM(GEN)) WHEN 'FEMALE' THEN 'Female' WHEN 'F' THEN 'Female' WHEN 'MALE' THEN 'Male' WHEN 'M' THEN 'Male' ELSE 'n/a' END AS GEN
            FROM src.src_erp_cust_az12
        )
        INSERT INTO stg.stg_erp_cust_az12 (CID, BDATE, GEN)
        SELECT CID, BDATE, GEN FROM cleansed_erp_cust;
        
        SET @rows_affected = @@ROWCOUNT; 
        SET @end_time = GETDATE();
        PRINT '>> [stg.stg_erp_cust_az12] loaded ' + CAST(@rows_affected AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 2.2 Load stg.stg_erp_loc_a101
        SET @start_time = GETDATE();
        TRUNCATE TABLE stg.stg_erp_loc_a101;

        ;WITH cleansed_erp_loc AS (
            SELECT REPLACE(CID, '-', '') AS CID,
                   CASE WHEN UPPER(TRIM(CNTRY)) IN ('US', 'USA') THEN 'United States' WHEN UPPER(TRIM(CNTRY)) = 'DE' THEN 'Germany' 
                        WHEN UPPER(TRIM(CNTRY)) = '' OR CNTRY IS NULL THEN 'n/a' ELSE TRIM(CNTRY) END AS CNTRY
            FROM src.src_erp_loc_a101
        )
        INSERT INTO stg.stg_erp_loc_a101 (CID, CNTRY)
        SELECT CID, CNTRY FROM cleansed_erp_loc;
        
        SET @rows_affected = @@ROWCOUNT; 
        SET @end_time = GETDATE();
        PRINT '>> [stg.stg_erp_loc_a101] loaded ' + CAST(@rows_affected AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 2.3 Load stg.stg_erp_px_cat_g1v2
        SET @start_time = GETDATE();
        TRUNCATE TABLE stg.stg_erp_px_cat_g1v2;

        INSERT INTO stg.stg_erp_px_cat_g1v2 (ID, CAT, SUBCAT, MAINTENANCE)
        SELECT TRIM(ID), TRIM(CAT), TRIM(SUBCAT), TRIM(MAINTENANCE) FROM src.src_erp_px_cat_g1v2;
        
        SET @rows_affected = @@ROWCOUNT; 
        SET @end_time = GETDATE();
        PRINT '>> [stg.stg_erp_px_cat_g1v2] loaded ' + CAST(@rows_affected AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- Final Summary
        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'SUCCESS: Staging Load Completed Successfully.';
        PRINT 'Total Batch Time Taken: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds.';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING STAGING LOAD:';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END
GO