/*
=============================================================================
Script: 04_create_core_views.sql
Description: Creates the Dimensional Model (Core Layer) using Views.
             This layer represents the 'Gold' standard for the Sales 
             Data Mart, utilizing a Star Schema architecture.
=============================================================================
*/

USE sql_server_dwh;
GO

-- =============================================================================
-- 1. Create Customer Dimension: core.dim_customers
-- =============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'dim_customers' AND schema_id = SCHEMA_ID('core'))
    DROP VIEW core.dim_customers;
GO

CREATE VIEW core.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS sk_customer, -- Surrogate Key
    ci.cst_id          AS customer_id,
    ci.cst_key         AS customer_number,
    ci.cst_firstname   AS first_name,
    ci.cst_lastname    AS last_name,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM priority
        ELSE COALESCE(ca.gen, 'n/a')               -- ERP fallback
    END                AS gender,
    ca.BDATE           AS birth_date,
    ci.cst_marital_status AS marital_status,
    cl.CNTRY           AS country,
    ci.cst_create_date AS create_date
FROM stg.stg_crm_cust_info ci
LEFT JOIN stg.stg_erp_cust_az12 ca ON ci.cst_key = ca.CID
LEFT JOIN stg.stg_erp_loc_a101  cl ON ci.cst_key = cl.CID;
GO

-- =============================================================================
-- 2. Create Product Dimension: core.dim_products
-- =============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'dim_products' AND schema_id = SCHEMA_ID('core'))
    DROP VIEW core.dim_products;
GO

CREATE VIEW core.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS sk_product, -- Surrogate Key
    pi.prd_id          AS product_id,
    pi.prd_key         AS product_number,
    pi.prd_nm          AS product_name,
    pi.cat_id          AS category_id,
    pc.cat             AS category,
    pc.SUBCAT          AS subcategory,
    pc.MAINTENANCE     AS maintenance,
    pi.prd_cost        AS product_cost,
    pi.prd_line        AS product_line,
    pi.prd_start_dt    AS start_date
FROM stg.stg_crm_prd_info pi
LEFT JOIN stg.stg_erp_px_cat_g1v2 pc ON pi.cat_id = pc.ID
WHERE pi.prd_end_dt IS NULL; -- Filters for current active products only
GO

-- =============================================================================
-- 3. Create Sales Fact: core.fct_sales
-- =============================================================================
IF EXISTS (SELECT * FROM sys.views WHERE name = 'fct_sales' AND schema_id = SCHEMA_ID('core'))
    DROP VIEW core.fct_sales;
GO

CREATE VIEW core.fct_sales AS
SELECT 
    sd.sls_ord_num     AS order_number,
    p.sk_product       AS sk_product,  -- Join to SK
    c.sk_customer      AS sk_customer, -- Join to SK
    sd.sls_order_dt    AS order_date,
    sd.sls_ship_dt     AS shipping_date,
    sd.sls_due_dt      AS due_date,
    sd.sls_price       AS product_price,
    sd.sls_quantity    AS product_quantity,
    sd.sls_sales       AS sale_amount
FROM stg.stg_crm_sales_details sd
LEFT JOIN core.dim_customers c ON sd.sls_cust_id = c.customer_id
LEFT JOIN core.dim_products  p ON sd.sls_prd_key  = p.product_number;
GO
