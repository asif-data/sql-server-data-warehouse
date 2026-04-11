# 📊 Sales Data Mart: End-to-End SQL Server Data Warehouse

This repository represents my first major step into Data Engineering and Analytics. Using **SQL Server**, I built a professional-grade Data Warehouse that integrates fragmented data from disparate **CRM** and **ERP** systems. This project was a journey in learning how to transform "dirty," disconnected data into a high-performance **Star Schema** ready for real-world business insights.

---

## 🏗️ Architecture & Data Flow

The data pipeline follows a robust three-tier architecture, which helped me understand the importance of data lineage and quality at every stage:
1. **Raw Layer (`src`)**: Ingesting source files "as-is" to maintain a permanent audit trail.
2. **Staging Layer (`stg`)**: The "cleansing" zone where I applied logic to fix duplicates, cast data types, and handle nulls.
3. **Analytics Layer (`core`)**: The final Star Schema, utilizing Surrogate Keys (SK) to ensure the warehouse remains stable even if source systems change.

![High Level Architecture](docs/images/high_level_architecture.png)

*Figure 1: End-to-end data pipeline from raw flat files to the consumption layer.*

### The Star Schema (Analytics Layer)
I designed the Core layer as a dimensional model to optimize for analytical queries and ease of use in BI tools.

![Star Schema Data Model](docs/images/data_model.png)

*Figure 2: Dimensional model optimized for reporting.*

---

## 📁 Repository Structure

```text
sql-server-data-warehouse/
├── data/                        # Local raw data directory
│   ├── source_crm/              # Customer, Product, and Sales CSV extracts
│   └── source_erp/              # Demographic, Category, and Location CSV extracts
├── docs/                        # Technical documentation
│   ├── images/                  # Architecture and schema diagrams
│   ├── DATA_CATALOGUE.md        # Table granularity, metadata, and column definitions
│   └── NAMING_CONVENTIONS.md    # Standardized rules for schemas, tables, and keys
├── scripts/                     # SQL codebase
│   ├── ddl/                     # Data Definition Language (Schema generation)
│   │   ├── 01_setup_database.sql       # Initializes database and schemas
│   │   ├── 02_create_source_tables.sql # Defines Raw (`src`) layer tables
│   │   ├── 03_create_staging_tables.sql# Defines Staging (`stg`) layer tables
│   │   ├── 04_create_core_views.sql    # Defines Analytics (`core`) Star Schema views
│   │   ├── 05_create_customer_report.sql  # Customer 360 View
│   │   └── 06_create_product_report.sql   # Product Intelligence View
│   ├── etl/                     # Extract, Transform, Load processes
│   │   ├── usp_load_raw.sql            # Stored proc to BULK INSERT raw files
│   │   ├── 01_bulk_load_src.sql        # Execution script for raw ingestion
│   │   ├── usp_load_stg.sql            # Unified stored proc for data cleansing
│   │   └── 02_load_stg.sql             # Execution script for staging transformations
│   └── exploration/             # Data Discovery & Advanced Insights
│       ├── eda_core_layer.sql             # Exploratory Data Analysis
│       └── advanced_analytics.sql         # Time-series & Segmentation logic
│   └── quality_checks/          # Data validation and integrity testing
│       ├── val_stg_layer.sql           # Scans staging for nulls, duplicates, & math errors
│       └── val_core_layer.sql          # Validates referential integrity & surrogate keys
├── LICENSE                      # MIT License
└── README.md                    # Project overview (this file)
```
---

## 🔎 Data Discovery & Business Insights

As I progressed through the project, I moved beyond just building the "pipes" and focused on uncovering actual business value through SQL. This phase allowed me to apply theoretical knowledge to solve practical business questions.

### 1. Exploratory Data Analysis (EDA)
Located in the `scripts/exploration/` folder, this phase involved a deep dive into core metrics to understand the "health" of the business.
* **Key Discovery:** Identified "Dead Stock" (products catalogued but never sold) and analyzed revenue distribution by country and gender.
* **Techniques:** Utilized **Window Functions** for ranking and aggregated "Big Numbers" (Total Sales, AOV) to provide a high-level executive summary.

### 2. Advanced Analytics
I challenged myself with more complex SQL techniques to answer deeper business questions:
* **Cumulative Analysis:** Created running totals and 3-month moving averages to smooth out seasonal sales spikes and track growth.
* **Performance Benchmarking:** Used `LAG()` and `PARTITION BY` to calculate **Year-over-Year (YoY)** growth and compared individual product performance against category averages.
* **Segmentation:** Categorized products into cost tiers (Budget to Luxury) and segmented customers into **VIP**, **Regular**, and **New** groups based on spending behavior and tenure.

---

## 📊 Automated Reporting Views

To make the data accessible for decision-making, I created two specialized "Dashboard Views" in the Core layer, ready for consumption by BI tools:

1.  **Customer 360 (`customer_report`):** Consolidates essential customer metrics—from total lifetime value (LTV) and average order value (AOV) to specific age groups and behavioral segments.
2.  **Product Intelligence (`product_report`):** Focuses on inventory health, calculating **Sales Velocity** (units sold per day) and identifying "Top Sellers" versus products that haven't moved in months.

---

## 🚀 Setup & Execution

To recreate this Data Warehouse locally, follow these steps in order:

> [!IMPORTANT]
> **Local File Path Configuration:**
> The script `scripts/etl/usp_load_raw.sql` contains hardcoded absolute paths from my local system. **Before running the ETL**, you must open this file and update the `@base_path` variable to match the location of the `/data` folder on your system.

1.  **Deploy Schemas:** Execute scripts `01` to `06` in `scripts/ddl/` to build the database structure and reporting views.
2.  **Ingest Raw Data:** Execute `scripts/etl/01_bulk_load_src.sql` to load the CSVs into the `src` layer.
3.  **Run Transformations:** Execute `scripts/etl/02_load_stg.sql` to trigger the cleansing and integration procedures.
4.  **Explore & Validate:** Run scripts in `scripts/quality_checks/` and `scripts/exploration/` to see the insights and validations in action.

---

## 👨‍💻 About Me

I am an **aspiring Data Analyst/Engineer** based in Uttar Pradesh, India. Coming from a multidisciplinary academic background in **Biotechnology (B.Tech)** and **Agronomy (M.Sc.)**, I am passionate about the intersection of data and business growth. This project represents my commitment to mastering the modern data stack and transitioning into a role where I can help organizations turn raw data into strategic assets. I am focused on helping startups understand:

- Revenue trends
- Customer behavior
- Marketing performance

Skilled in:
- SQL for data analysis
- Power BI for dashboarding
- Excel for business analysis
- Python for data analysis

* **LinkedIn:** [View Profile](https://www.linkedin.com/in/asif-khan-data/)
* **Email:** [khan.asif@outlook.in](mailto:khan.asif@outlook.in)

---

* **Optimization Note:** AI tooling was utilized during the development of this project to refine T-SQL readability, enforce enterprise naming conventions, and structure documentation while I focused on the core logic and architecture.
* **License:** This project is licensed under the MIT License - see the `LICENSE` file for details.
