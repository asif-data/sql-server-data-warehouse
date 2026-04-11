/*
=============================================================================
Script: eda_core_layer.sql
Description: Comprehensive Exploratory Data Analysis (EDA) for the Core Layer.
             - Metadata Discovery
             - Demographic & Date Profiling
             - Key Metric Aggregation (Big Numbers)
             - Segment & Magnitude Analysis
             - Performance Ranking (Ties handled via DENSE_RANK)
=============================================================================
*/

USE sql_server_dwh;
GO

-- =============================================================================
-- 1. Metadata & Schema Exploration
-- =============================================================================
PRINT '>> Exploring Schema and Column Metadata...';
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'core' 
ORDER BY TABLE_NAME;


-- =============================================================================
-- 2. Dimension Value Exploration
-- =============================================================================
PRINT '>> Identifying unique dimension categories...';
SELECT DISTINCT country FROM core.dim_customers;

SELECT DISTINCT category, subcategory 
FROM core.dim_products 
ORDER BY category, subcategory;


-- =============================================================================
-- 3. Date & Demographic Profiling
-- =============================================================================
PRINT '>> Analyzing Date Ranges and Customer Age Demographics...';

-- Fact Sales Date Range
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS total_span_years
FROM core.fct_sales;

-- Customer Age Profiling (Precise Calculation)
SELECT
    MIN(birth_date) AS oldest_birth_date,
    MAX(birth_date) AS youngest_birth_date,
    AVG(FLOOR(DATEDIFF(DAY, birth_date, GETDATE()) / 365.25)) AS average_age,
    MIN(FLOOR(DATEDIFF(DAY, birth_date, GETDATE()) / 365.25)) AS youngest_age,
    MAX(FLOOR(DATEDIFF(DAY, birth_date, GETDATE()) / 365.25)) AS oldest_age
FROM core.dim_customers;


-- =============================================================================
-- 4. Key Metric Aggregation (Optimized Single Scan)
-- =============================================================================
PRINT '>> Calculating High-Level "Big Number" Metrics...';
SELECT 
    'Summary Metrics' AS report_line,
    SUM(sale_amount)              AS total_revenue,
    SUM(product_quantity)         AS total_units_sold,
    AVG(product_price)            AS avg_selling_price,
    COUNT(order_number)           AS total_order_lines,
    COUNT(DISTINCT order_number)  AS total_unique_orders,
    (SELECT COUNT(DISTINCT product_id) FROM core.dim_products) AS total_products_catalogued,
    COUNT(DISTINCT sk_product)    AS total_products_with_sales,
    COUNT(DISTINCT sk_customer)   AS total_active_customers
FROM core.fct_sales;


-- =============================================================================
-- 5. Magnitude & Segment Analysis
-- =============================================================================
PRINT '>> Analyzing Revenue and Customer Distribution...';

-- Customers by Country
SELECT country, COUNT(sk_customer) AS total_customers
FROM core.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Product Cost Distribution by Category
SELECT category, AVG(product_cost) AS avg_cost
FROM core.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Revenue by Product Category
SELECT 
    p.category, 
    SUM(s.sale_amount) AS total_revenue,
    SUM(s.product_quantity) AS units_sold
FROM core.fct_sales s
LEFT JOIN core.dim_products p ON s.sk_product = p.sk_product
GROUP BY p.category
ORDER BY total_revenue DESC;


-- =============================================================================
-- 6. Ranking Analysis (Handling Ties via DENSE_RANK)
-- =============================================================================
PRINT '>> Identifying Top and Bottom Performance...';

-- Top 5 Products by Revenue
SELECT TOP 5
    p.product_name,
    SUM(s.sale_amount) AS total_revenue,
    DENSE_RANK() OVER(ORDER BY SUM(s.sale_amount) DESC) AS rank_by_revenue
FROM core.fct_sales s
JOIN core.dim_products p ON s.sk_product = p.sk_product
GROUP BY p.product_name;

-- Bottom 5 Products by Revenue
SELECT TOP 5
    p.product_name,
    SUM(s.sale_amount) AS total_revenue,
    DENSE_RANK() OVER(ORDER BY SUM(s.sale_amount) ASC) AS rank_by_revenue
FROM core.fct_sales s
JOIN core.dim_products p ON s.sk_product = p.sk_product
GROUP BY p.product_name;

-- Top 5 Customers by Lifetime Value (LTV)
SELECT TOP 5
    c.first_name + ' ' + c.last_name AS full_name,
    SUM(s.sale_amount) AS lifetime_value
FROM core.fct_sales s
JOIN core.dim_customers c ON s.sk_customer = c.sk_customer
GROUP BY s.sk_customer, c.first_name, c.last_name
ORDER BY lifetime_value DESC;
GO
