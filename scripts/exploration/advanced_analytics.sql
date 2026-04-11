/*
=============================================================================
Script: advanced_analytics.sql
Description: Advanced Business Intelligence (BI) Analytics.
             - Time Series & Seasonality Analysis
             - Cumulative Revenue (Running Totals)
             - Product Performance (YoY & vs. Average)
             - Part-to-Whole (Market Share) Analysis
             - Advanced Customer/Product Segmentation
=============================================================================
*/

USE sql_server_dwh;
GO

-- =============================================================================
-- 1. Time Series & Seasonality Analysis
-- =============================================================================
PRINT '>> Analyzing Monthly Seasonality...';

SELECT
    DATETRUNC(month, order_date) AS order_month,
    FORMAT(order_date, 'MMM')      AS month_name, 
    SUM(sale_amount)               AS total_sales,
    COUNT(DISTINCT sk_customer)    AS total_customers,
    SUM(product_quantity)          AS total_quantity
FROM core.fct_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date), FORMAT(order_date, 'MMM')
ORDER BY order_month;


-- =============================================================================
-- 2. Cumulative Analysis 
-- =============================================================================
PRINT '>> Calculating Running Totals and Moving Averages...';

WITH monthly_sales AS (
    SELECT
        DATETRUNC(month, order_date) AS order_month,
        SUM(sale_amount) AS total_sales,
        AVG(sale_amount) AS avg_sale
    FROM core.fct_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(month, order_date)
)
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales,
    AVG(avg_sale)    OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3mo
FROM monthly_sales;


-- =============================================================================
-- 3. Performance Analysis (YoY & vs. Average)
-- =============================================================================
PRINT '>> Analyzing Product Year-over-Year (YoY) Performance...';

WITH yearly_product_sales AS (
    SELECT
        YEAR(s.order_date)  AS order_year,
        p.product_name,
        SUM(s.sale_amount)  AS current_sale
    FROM core.fct_sales AS s
    JOIN core.dim_products AS p ON s.sk_product = p.sk_product
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.product_name
),
performance_metrics AS (
    SELECT *,
        AVG(current_sale) OVER(PARTITION BY product_name) AS product_avg_sale,
        LAG(current_sale) OVER(PARTITION BY product_name ORDER BY order_year) AS previous_yr_sale
    FROM yearly_product_sales
)
SELECT *,
    (current_sale - product_avg_sale) AS diff_from_avg,
    (current_sale - previous_yr_sale) AS yoy_diff,
    CASE 
        WHEN current_sale > product_avg_sale THEN 'Above Avg'
        WHEN current_sale < product_avg_sale THEN 'Below Avg'
        ELSE 'Average'
    END AS performance_status
FROM performance_metrics
ORDER BY product_name, order_year;


-- =============================================================================
-- 4. Part-to-Whole Analysis (Category Market Share)
-- =============================================================================
PRINT '>> Calculating Category Contribution Percentage...';

WITH category_sales AS (
    SELECT 
        p.category,
        SUM(s.sale_amount) AS category_total_sale
    FROM core.fct_sales AS s
    JOIN core.dim_products AS p ON s.sk_product = p.sk_product
    GROUP BY p.category
)
SELECT
    category,
    category_total_sale,
    SUM(category_total_sale) OVER() AS grand_total,
    CAST(category_total_sale * 100.0 / SUM(category_total_sale) OVER() AS DECIMAL(10,2)) AS pct_contribution
FROM category_sales
ORDER BY category_total_sale DESC;


-- =============================================================================
-- 5. Advanced Data Segmentation
-- =============================================================================
PRINT '>> Segmenting Products and Customers...';

-- A. Product Cost Segmentation 
SELECT
    cost_range,
    COUNT(sk_product) AS product_count
FROM (
    SELECT sk_product,
        CASE
            WHEN product_cost < 100 THEN 'Budget (<100)'
            WHEN product_cost < 500 THEN 'Mid-Range (100-500)'
            WHEN product_cost < 1000 THEN 'Premium (500-1000)'
            ELSE 'Luxury (>1000)'
        END AS cost_range
    FROM core.dim_products
) t
GROUP BY cost_range
ORDER BY product_count DESC;

-- B. Customer Tiering (VIP vs. Regular vs. New)
WITH customer_metrics AS (
    SELECT
        c.sk_customer,
        SUM(s.sale_amount) AS total_spending,
        DATEDIFF(MONTH, MIN(s.order_date), MAX(s.order_date)) AS tenure_months
    FROM core.fct_sales s
    JOIN core.dim_customers c ON s.sk_customer = c.sk_customer
    GROUP BY c.sk_customer
)
SELECT 
    cust_segment,
    COUNT(sk_customer) AS customer_count,
    CAST(AVG(total_spending) AS DECIMAL(10,2)) AS avg_spending_per_segment
FROM (
    SELECT sk_customer, total_spending,
        CASE
            WHEN total_spending > 5000 AND tenure_months >= 12 THEN 'VIP'
            WHEN tenure_months >= 12 THEN 'Regular'
            ELSE 'New'
        END AS cust_segment
    FROM customer_metrics
) t
GROUP BY cust_segment
ORDER BY customer_count DESC;
GO
