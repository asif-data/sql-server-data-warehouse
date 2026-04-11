/*
=============================================================================
Script: 06_create_product_report.sql
Description: Creates the core.product_report view. 
             This view serves as a Product Intelligence dashboard, consolidating:
             - Sales Performance (Revenue, Quantity, Orders)
             - Market Reach (Unique Customers)
             - Operational Metrics (Inventory Age, Recency)
             - Performance Tiering (Top Seller, Regular, Low Seller)
=============================================================================
*/

USE sql_server_dwh;
GO

-- 1. Ensure idempotency by dropping the view if it already exists
IF EXISTS (SELECT * FROM sys.views WHERE name = 'product_report' AND schema_id = SCHEMA_ID('core'))
    DROP VIEW core.product_report;
GO

CREATE VIEW core.product_report AS
WITH product_stats AS (
    /* STEP 1: Aggregate Fact Data FIRST
       Calculating all measures at the product level before joining attributes.
    */
    SELECT 
        sk_product,
        COUNT(DISTINCT order_number)  AS total_orders,
        COUNT(DISTINCT sk_customer)   AS total_unique_customers,
        SUM(sale_amount)              AS total_sales,
        SUM(product_quantity)         AS total_quantity_sold,
        CAST(AVG(product_price) AS DECIMAL(10,2)) AS avg_selling_price,
        MIN(order_date)               AS first_sale_date,
        MAX(order_date)               AS last_sale_date,
        DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS product_lifespan_days
    FROM core.fct_sales
    GROUP BY sk_product
)
SELECT 
    p.sk_product,
    p.product_number,
    p.product_name,
    p.category,
    p.subcategory,
    p.product_cost,
    s.total_orders,
    s.total_sales,
    s.total_quantity_sold,
    s.total_unique_customers,
    s.first_sale_date,
    s.last_sale_date,

    -- STEP 2: Product Performance KPIs
    -- Average Revenue per Order
    CAST(CASE 
        WHEN s.total_orders = 0 THEN 0 
        ELSE s.total_sales / s.total_orders 
    END AS DECIMAL(10,2)) AS avg_order_revenue,

    -- Recency: Days since this product was last sold
    DATEDIFF(DAY, s.last_sale_date, GETDATE()) AS days_since_last_sale,

    -- STEP 3: Business Logic / Performance Tiering
    CASE 
        WHEN s.total_sales > 10000 THEN 'Top Seller'
        WHEN s.total_sales BETWEEN 5000 AND 10000 THEN 'Regular'
        WHEN s.total_sales > 0 THEN 'Low Seller'
        ELSE 'No Sales'
    END AS product_tier,

    -- STEP 4: Inventory/Sales Velocity 
    -- (How many units sold per day since the product first hit the market)
    CAST(CASE 
        WHEN s.product_lifespan_days <= 1 THEN s.total_quantity_sold
        ELSE CAST(s.total_quantity_sold AS FLOAT) / s.product_lifespan_days 
    END AS DECIMAL(10,2)) AS sales_velocity_per_day

FROM core.dim_products p
LEFT JOIN product_stats s ON p.sk_product = s.sk_product;
GO
