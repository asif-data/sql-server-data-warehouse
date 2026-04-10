/*
=============================================================================
Validation Script: Master Core Layer Quality Check
Description: This script validates the integrity of the Dimensional Model.
             It focuses on Surrogate Key uniqueness, Referential Integrity 
             (FK to PK links), and Business Logic consistency.
=============================================================================
*/

USE sql_server_dwh;
GO

PRINT '=====================================================================';
PRINT 'STARTING DATA QUALITY VALIDATION FOR CORE LAYER (STAR SCHEMA)';
PRINT '=====================================================================';

/*
-----------------------------------------------------------------------------
SECTION 1: DIMENSION VALIDATION
-----------------------------------------------------------------------------
*/

-- 1.1 core.dim_customers
PRINT '------------------------------------------------';
PRINT '>> Validating: core.dim_customers';
PRINT '------------------------------------------------';

PRINT '>> Checking Surrogate Key (sk_customer) uniqueness...';
SELECT sk_customer, COUNT(*) as duplicate_count 
FROM core.dim_customers 
GROUP BY sk_customer 
HAVING COUNT(*) > 1 OR sk_customer IS NULL;

PRINT '>> Checking for orphaned records or invalid categorical mapping...';
SELECT 
    SUM(CASE WHEN customer_number IS NULL THEN 1 ELSE 0 END) AS null_customer_numbers,
    SUM(CASE WHEN gender = 'n/a' THEN 1 ELSE 0 END) AS unknown_gender_count,
    SUM(CASE WHEN country IS NULL OR country = 'n/a' THEN 1 ELSE 0 END) AS unknown_country_count
FROM core.dim_customers;


-- 1.2 core.dim_products
PRINT '------------------------------------------------';
PRINT '>> Validating: core.dim_products';
PRINT '------------------------------------------------';

PRINT '>> Checking Surrogate Key (sk_product) uniqueness...';
SELECT sk_product, COUNT(*) as duplicate_count 
FROM core.dim_products 
GROUP BY sk_product 
HAVING COUNT(*) > 1 OR sk_product IS NULL;

PRINT '>> Checking for missing category links or invalid costs...';
SELECT 
    SUM(CASE WHEN product_number IS NULL THEN 1 ELSE 0 END) AS null_product_numbers,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS missing_categories,
    SUM(CASE WHEN product_cost <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_costs
FROM core.dim_products;

/*
-----------------------------------------------------------------------------
SECTION 2: FACT & REFERENTIAL INTEGRITY VALIDATION
-----------------------------------------------------------------------------
*/

-- 2.1 core.fct_sales
PRINT '------------------------------------------------';
PRINT '>> Validating: core.fct_sales';
PRINT '------------------------------------------------';

PRINT '>> Checking for Referential Integrity issues (Orphaned Facts)...';
-- This checks if any sale points to a customer or product that doesn't exist.
SELECT 
    SUM(CASE WHEN sk_customer IS NULL THEN 1 ELSE 0 END) AS orphaned_sales_no_customer,
    SUM(CASE WHEN sk_product IS NULL THEN 1 ELSE 0 END) AS orphaned_sales_no_product
FROM core.fct_sales;

PRINT '>> Checking for financial consistency in the Fact table...';
SELECT 
    SUM(CASE WHEN sale_amount <= 0 THEN 1 ELSE 0 END) AS zero_sale_records,
    SUM(CASE WHEN product_quantity <= 0 THEN 1 ELSE 0 END) AS zero_quantity_records,
    SUM(CASE WHEN sale_amount != (product_price * product_quantity) THEN 1 ELSE 0 END) AS math_errors
FROM core.fct_sales;

/*
-----------------------------------------------------------------------------
SECTION 3: ANALYTICAL SANITY CHECKS
-----------------------------------------------------------------------------
*/

PRINT '------------------------------------------------';
PRINT '>> STAR SCHEMA SANITY CHECK';
PRINT '------------------------------------------------';

PRINT '>> Measuring Sales Volume by Country (Top 3)...';
SELECT TOP 3 
    c.country, 
    SUM(s.sale_amount) AS total_revenue
FROM core.fct_sales s
JOIN core.dim_customers c ON s.sk_customer = c.sk_customer
GROUP BY c.country
ORDER BY total_revenue DESC;

PRINT '=====================================================================';
PRINT 'CORE LAYER VALIDATION COMPLETE';
PRINT '=====================================================================';
GO
