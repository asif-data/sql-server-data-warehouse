# Data Catalogue: Sales Data Mart

## High-Level Architecture
This data mart follows a **Star Schema** design. It integrates data from a CRM (Sales, Customers, Products) and an ERP (Demographics, Categories, Locations) into a unified Analytics Layer.

---

## 👥 Dimension: `core.dim_customers`
**Grain:** One row per unique customer.

| Column | Data Type | Key | Description |
| :--- | :--- | :--- | :--- |
| `sk_customer` | INT | PK | Primary Surrogate Key (Internal). |
| `customer_id` | INT | BK | Original CRM ID. |
| `customer_number` | VARCHAR(50) | BK | Unique business key for cross-system mapping. |
| `first_name` | VARCHAR(50) | - | Standardized first name. |
| `last_name` | VARCHAR(50) | - | Standardized last name. |
| `gender` | VARCHAR(20) | - | Unified Gender (CRM prioritized over ERP). |
| `birth_date` | DATE | - | Birth date from ERP AZ12. |
| `marital_status`| VARCHAR(10) | - | Standardized Marital Status. |
| `country` | VARCHAR(50) | - | Normalized Country name from ERP Location. |
| `create_date` | DATE | - | CRM record creation date. |

---

## 📦 Dimension: `core.dim_products`
**Grain:** One row per current active product version.

| Column | Data Type | Key | Description |
| :--- | :--- | :--- | :--- |
| `sk_product` | INT | PK | Primary Surrogate Key (Internal). |
| `product_id` | INT | BK | Original CRM ID. |
| `product_number` | VARCHAR(50) | BK | Cleaned product identifier. |
| `product_name` | VARCHAR(100) | - | Full product description. |
| `category_id` | VARCHAR(50) | FK | Link to ERP Category system. |
| `category` | VARCHAR(50) | - | High-level product category (e.g., Bikes). |
| `subcategory` | VARCHAR(50) | - | Detailed product subcategory. |
| `maintenance` | VARCHAR(10) | - | ERP Maintenance flag. |
| `product_cost` | DECIMAL(18, 4)| - | Standard unit cost. |
| `product_line` | VARCHAR(10) | - | Product classification line. |
| `start_date` | DATE | - | Validity start date for this product version. |

---

## 💰 Fact: `core.fct_sales`
**Grain:** One row per transaction line item.

| Column | Data Type | Key | Description |
| :--- | :--- | :--- | :--- |
| `order_number` | VARCHAR(50) | BK | Unique transaction ID. |
| `sk_product` | INT | FK | Link to `core.dim_products`. |
| `sk_customer` | INT | FK | Link to `core.dim_customers`. |
| `order_date` | DATE | - | Date of purchase. |
| `shipping_date` | DATE | - | Date goods were shipped. |
| `due_date` | DATE | - | Date payment/delivery was expected. |
| `product_price` | DECIMAL(18, 2)| - | Net unit price at time of sale. |
| `product_quantity`| INT | - | Number of units sold. |
| `sale_amount` | DECIMAL(18, 2)| - | Total calculated revenue (`Price * Quantity`). |
