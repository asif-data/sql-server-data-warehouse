# 📊 Sales Data Mart: End-to-End SQL Server Data Warehouse

This repository showcases the development of a professional-grade Data Warehouse using **SQL Server**. The project transforms fragmented, "dirty" data from two distinct source systems (**CRM** and **ERP**) into a unified, high-performance **Star Schema** optimized for business intelligence and reporting.

> **Note on Optimization:** This project’s T-SQL scripts and documentation were developed and refined with AI assistance to ensure "Gold Standard" readability, performance optimization, and adherence to enterprise naming conventions.

---

## 🏗️ High-Level Architecture
The warehouse utilizes a three-tier architecture to ensure data integrity, lineage, and scalability.

![High Level Architecture](docs/images/high_level_architecture.png)

### Key Technical Achievements:
* **Data Integration:** Successfully unified CRM sales data with ERP demographic and location records using Master Data Management (MDM) principles.
* **Data Cleansing:** Implemented robust T-SQL logic to handle duplicates, null values, inconsistent date formats, and string whitespace.
* **Dimensional Modelling:** Designed a Star Schema featuring Surrogate Keys (SK) to isolate the analytics layer from source system changes.
* **SCD Type 2 Logic:** Implemented Slowly Changing Dimension logic in the product dimension to track historical attribute changes over time.

---

## 📁 Repository Structure

```text
sql-server-data-warehouse/
├── data/                        # Raw Source Files (CSV)
│   ├── source_crm/              # Customer, Product, and Sales datasets
│   └── source_erp/              # Demographic, Category, and Location datasets
├── docs/                        # Project Documentation
│   ├── images/                  # Architecture & Data Model Diagrams
│   ├── DATA_CATALOGUE.md        # Technical metadata and column definitions
│   └── NAMING_CONVENTIONS.md    # Established rules for warehouse governance
├── scripts/                     # SQL Development Scripts
│   ├── ddl/                     # Data Definition (Schema Structure)
│   │   ├── 01_setup_database.sql       # Database and Schema creation
│   │   ├── 02_create_source_tables.sql # Raw Layer (src) definition
│   │   ├── 03_create_staging_tables.sql# Cleansing Layer (stg) definition
│   │   └── 04_create_core_views.sql    # Analytics Layer (core) Star Schema
│   ├── etl/                     # Data Manipulation & Orchestration
│   │   ├── usp_load_raw.sql     # Logic for initial raw data ingestion
│   │   ├── 01_bulk_load_src.sql # Trigger script for Raw layer load
│   │   ├── usp_load_stg.sql     # Unified Procedure for data cleansing
│   │   └── 02_load_stg.sql      # Trigger script for Staging layer load
│   └── quality_checks/          # Data Validation Scripts
│       ├── val_stg_layer.sql    # Master validation for Staging integrity
│       └── val_core_layer.sql   # Referential integrity & Star Schema checks
├── LICENSE                      # MIT License
└── README.md                    # Project Documentation

md
🔄 Data Flow & Integration
Source to Staging Integration
Mapped CRM and ERP datasets using standardized keys
Applied transformation logic such as:
Prefix removal (e.g., 'NAS')
Data normalization for join compatibility
Final Data Model

The warehouse exposes a clean Star Schema:

Dimensions
dim_customers
dim_products
Fact Table
fct_sales

This structure ensures efficient querying and seamless integration with BI tools.

🚀 Setup & Execution
⚠️ Important: Local File Paths

The script scripts/etl/usp_load_raw.sql contains hardcoded local file paths (e.g., C:\Users\Asif Khan\...).

Before execution:

Clone the repository
Open usp_load_raw.sql
Update the @base_path or file paths to match your local /data directory
Execution Workflow
Initialize Database
Run all scripts in scripts/ddl/ sequentially:
01_setup_database.sql
02_create_source_tables.sql
03_create_staging_tables.sql
04_create_core_views.sql
Load Raw Data

Execute:

scripts/etl/01_bulk_load_src.sql
Run ETL Pipeline

Execute:

scripts/etl/02_load_stg.sql
Validate Data

Run validation scripts:

scripts/quality_checks/val_stg_layer.sql
scripts/quality_checks/val_core_layer.sql
👨‍💻 About Me

I am a data professional based in Uttar Pradesh, India, with a multidisciplinary academic background in Biotechnology (B.Tech) and Agronomy (M.Sc.). I transitioned into the digital and data domain to build scalable, outcome-driven solutions.

Core Focus Areas
Data Engineering
SQL Server, T-SQL
Data Warehousing and ETL pipelines
Data Visualization
Power BI for business insights
Business Strategy
Asset-light models
AI-driven automation workflows
🔗 Contact
LinkedIn: [Your LinkedIn Profile Link]
Email: [Your Email Address]
📜 License

This project is licensed under the MIT License.
Refer to the LICENSE file for details.
