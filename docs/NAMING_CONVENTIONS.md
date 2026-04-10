# Naming Conventions: Sales Data Mart

## 1. Schema Layers
To maintain a clear separation of concerns, the following schemas are utilized:
- `src`: Raw data ingested directly from source systems (CRM, ERP).
- `stg`: Cleansed and standardized data; no business logic or joins.
- `core`: The final Dimensional Model (Star Schema) ready for consumption.

## 2. Object Prefixes
| Object Type | Prefix | Example |
| :--- | :--- | :--- |
| **Dimension Table** | `dim_` | `core.dim_customers` |
| **Fact Table** | `fct_` | `core.fct_sales` |
| **Staging Table** | `stg_` | `stg.stg_crm_sales_details` |
| **Stored Procedure** | `usp_` | `stg.usp_load_stg` |

## 3. Column Naming Rules
- **Surrogate Keys (SK):** Always prefixed with `sk_` (e.g., `sk_customer`). These are internal, auto-generated integers.
- **Business Keys (BK):** Original identifiers from source systems (e.g., `customer_id` or `customer_number`).
- **Audit Metadata:** All technical columns must use the `audit_` prefix.
  - `audit_load_timestamp`: The datetime the record entered the layer.
- **Casing:** All identifiers use `snake_case` for maximum compatibility across SQL environments.

## 4. Date Formatting
- All date columns in the `core` layer must be of the `DATE` type.
- Column names should clearly indicate the event (e.g., `order_date`, `shipping_date`).
