/*
=============================================================================
Stored Procedure: src.usp_load_raw
Description: Truncates and Bulk Loads data from CSV files into the 'src' schema.
             Includes logging for load times, row counts, and error handling.

Execution:
    EXEC src.usp_load_raw;
=============================================================================
*/

CREATE OR ALTER PROCEDURE src.usp_load_raw
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_time DATETIME, @end_time DATETIME, @total_start_time DATETIME, @total_end_time DATETIME;
    DECLARE @rows_loaded INT;
    
    SET @total_start_time = GETDATE();
    PRINT '================================================';
    PRINT 'Starting Bulk Load Process at ' + CAST(@total_start_time AS VARCHAR);
    PRINT '================================================';

    BEGIN TRY
        -- 1. CRM Customer Info
        SET @start_time = GETDATE();
        TRUNCATE TABLE src.src_crm_cust_info;
        BULK INSERT src.src_crm_cust_info
        FROM 'C:\Users\Asif Khan\Desktop\Asif\sql-server-data-warehouse\datasets\source_crm\cust_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Loaded [src.src_crm_cust_info]: ' + CAST(@rows_loaded AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 2. CRM Product Info
        SET @start_time = GETDATE();
        TRUNCATE TABLE src.src_crm_prd_info;
        BULK INSERT src.src_crm_prd_info
        FROM 'C:\Users\Asif Khan\Desktop\Asif\sql-server-data-warehouse\datasets\source_crm\prd_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Loaded [src.src_crm_prd_info]: ' + CAST(@rows_loaded AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 3. CRM Sales Details
        SET @start_time = GETDATE();
        TRUNCATE TABLE src.src_crm_sales_details;
        BULK INSERT src.src_crm_sales_details
        FROM 'C:\Users\Asif Khan\Desktop\Asif\sql-server-data-warehouse\datasets\source_crm\sales_details.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Loaded [src.src_crm_sales_details]: ' + CAST(@rows_loaded AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 4. ERP Customer Data (AZ12)
        SET @start_time = GETDATE();
        TRUNCATE TABLE src.src_erp_cust_az12;
        BULK INSERT src.src_erp_cust_az12
        FROM 'C:\Users\Asif Khan\Desktop\Asif\sql-server-data-warehouse\datasets\source_erp\CUST_AZ12.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Loaded [src.src_erp_cust_az12]: ' + CAST(@rows_loaded AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 5. ERP Location Data (A101)
        SET @start_time = GETDATE();
        TRUNCATE TABLE src.src_erp_loc_a101;
        BULK INSERT src.src_erp_loc_a101
        FROM 'C:\Users\Asif Khan\Desktop\Asif\sql-server-data-warehouse\datasets\source_erp\LOC_A101.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Loaded [src.src_erp_loc_a101]: ' + CAST(@rows_loaded AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- 6. ERP Product Category (G1V2)
        SET @start_time = GETDATE();
        TRUNCATE TABLE src.src_erp_px_cat_g1v2;
        BULK INSERT src.src_erp_px_cat_g1v2
        FROM 'C:\Users\Asif Khan\Desktop\Asif\sql-server-data-warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = GETDATE();
        PRINT '>> Loaded [src.src_erp_px_cat_g1v2]: ' + CAST(@rows_loaded AS VARCHAR) + ' rows in ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds.';

        -- Final Summary
        SET @total_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'SUCCESS: Bulk Load Completed Successfully.';
        PRINT 'Total Time Taken: ' + CAST(DATEDIFF(SECOND, @total_start_time, @total_end_time) AS VARCHAR) + ' seconds.';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING BULK LOAD:';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '================================================';
    END CATCH
END
GO

