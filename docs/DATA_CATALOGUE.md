# Data Catalogue: Sales Data Mart

## High-Level Architecture
This data mart follows a **Star Schema** design. It integrates data from a CRM (Sales, Customers, Products) and an ERP (Demographics, Categories, Locations) into a unified Analytics Layer.

---

## 👥 Dimension: `core.dim_customers`
**Grain:** One row per unique customer.

| Column | Key | Description |
| :--- | :--- | :--- |
| `sk_customer` | PK | Primary Surrogate Key (Internal). |
| `customer_id` | BK | Original CRM ID. |
| `customer_number` | BK | Cross-system integration key. |
| `first_name` | - | Standardized first name. |
| `last_name` | - | Standardized last name. |
| `gender` | - | Unified Gender (CRM prioritized over ERP). |
| `birth_date` | - | Customer DOB from ERP. |
| `marital_status`| - | Standardized Marital Status. |
| `country` | - | Normalized Country name from ERP Location. |

---

## 📦 Dimension: `core.dim_products`
**Grain:** One row per current active product.

| Column | Key | Description |
| :--- | :--- | :--- |
| `sk_product` | PK | Primary Surrogate Key (Internal). |
| `product_id` | BK | Original CRM ID. |
| `product_number` | BK | Cleaned product identifier. |
| `product_name` | - | Full product description. |
| `category` | - | High-level product category (e.g., Bikes). |
| `subcategory` | - | Detailed product subcategory. |
| `product_cost` | - | Standard unit cost. |
| `product_line` | - | Product classification line. |

---

## 💰 Fact: `core.fct_sales`
**Grain:** One row per transaction line item.

| Column | Key | Description |
| :--- | :--- | :--- |
| `order_number` | BK | Unique transaction ID. |
| `sk_product` | FK | Link to `core.dim_products`. |
| `sk_customer` | FK | Link to `core.dim_customers`. |
| `order_date` | - | Date of purchase. |
| `product_price` | - | Unit price at time of sale. |
| `product_quantity`| - | Number of units sold. |
| `sale_amount` | - | Total revenue (`Price * Quantity`). |
