/*
=============================================================================
Script: 05_create_reporting_views.sql
Description: Creates the core.customer_report view. 
             This view serves as a "Customer 360" dashboard, consolidating:
             - Aggregate transaction history (LTV, AOV, Qty)
             - Demographic profiling (Age, Age Groups)
             - Behavioral Segmentation (VIP, Regular, New)
             - Engagement metrics (Recency, Lifespan)
=============================================================================
*/

USE sql_server_dwh;
GO

-- 1. Ensure idempotency by dropping the view if it already exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'customer_report' AND schema_id = SCHEMA_ID('core'))
    DROP VIEW core.customer_report;
GO

CREATE VIEW core.customer_report AS
WITH customer_stats AS (
    /* STEP 1: Performance Optimization
       Aggregate Fact data first to minimize the number of rows joined.
    */
    SELECT 
        sk_customer,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sale_amount)             AS total_sales,
        SUM(product_quantity)        AS total_quantity,
        COUNT(DISTINCT sk_product)   AS total_unique_products,
        MIN(order_date)              AS first_order_date,
        MAX(order_date)              AS last_order_date,
        -- Calculate tenure/lifespan using months for business consistency
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan_months
    FROM core.fct_sales
    GROUP BY sk_customer
)
SELECT 
    c.sk_customer,
    c.customer_number,
    c.first_name + ' ' + c.last_name AS customer_name,
    -- Precise Age Calculation using 365.25 for leap year adjustment
    FLOOR(DATEDIFF(DAY, c.birth_date, GETDATE()) / 365.25) AS customer_age,
    s.total_orders,
    s.total_sales,
    s.total_quantity,
    s.total_unique_products,
    s.last_order_date,
    s.lifespan_months,
    
    -- STEP 2: KPI Calculations with financial precision (DECIMAL 10,2)
    CAST(CASE 
        WHEN s.total_orders = 0 THEN 0 
        ELSE s.total_sales / s.total_orders 
    END AS DECIMAL(10,2)) AS average_order_value,
    
    CAST(CASE 
        WHEN s.lifespan_months <= 1 THEN s.total_sales -- Capture full value for new customers
        ELSE s.total_sales / s.lifespan_months 
    END AS DECIMAL(10,2)) AS average_monthly_spend,
    
    -- Recency: Months since the last transaction
    DATEDIFF(MONTH, s.last_order_date, GETDATE()) AS recency_months,

    -- STEP 3: Business Segmentation Logic
    CASE 
        WHEN s.total_sales > 5000 AND s.lifespan_months >= 12 THEN 'VIP'
        WHEN s.lifespan_months >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    -- STEP 4: Demographic Grouping
    CASE 
        WHEN FLOOR(DATEDIFF(DAY, c.birth_date, GETDATE()) / 365.25) < 25 THEN 'Below 25'
        WHEN FLOOR(DATEDIFF(DAY, c.birth_date, GETDATE()) / 365.25) BETWEEN 25 AND 49 THEN '25-49'
        WHEN FLOOR(DATEDIFF(DAY, c.birth_date, GETDATE()) / 365.25) BETWEEN 50 AND 74 THEN '50-74'
        ELSE '75+'
    END AS age_group

FROM core.dim_customers c
LEFT JOIN customer_stats s ON c.sk_customer = s.sk_customer;
GO
