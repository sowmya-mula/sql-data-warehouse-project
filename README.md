
# SQL Data Warehouse Project

## 📖 Introduction

This project demonstrates the end-to-end development of a modern SQL Data Warehouse using SQL Server. The solution integrates data from multiple business source systems, applies ETL processes to ensure data quality, and transforms raw operational data into analytics-ready datasets.

The project follows the Medallion Architecture (Bronze, Silver, and Gold layers), a widely adopted data engineering pattern that improves data reliability, maintainability, and scalability. The final output consists of well-structured fact and dimension tables designed to support business intelligence, reporting, and analytical workloads.

---

## 🎯 Project Overview

Organizations generate large volumes of data from different operational systems. However, raw data is often inconsistent, duplicated, and difficult to analyze directly.

This project addresses these challenges by building a centralized data warehouse that:

* Consolidates data from CRM and ERP systems
* Cleans and standardizes raw data
* Applies business transformation rules
* Implements dimensional modeling techniques
* Produces trusted datasets for reporting and analytics

### Business Goals

* Create a single source of truth for business data
* Improve data quality and consistency
* Enable faster analytical queries
* Support data-driven decision making
* Establish a scalable foundation for future BI solutions

---

## 🚀 Project Implementation Steps

### 1️⃣ Data Ingestion (Bronze Layer)

Raw data is extracted from source systems and loaded into the Bronze layer without modification.

**Activities:**

* Import CRM datasets
* Import ERP datasets
* Preserve source-system structure
* Maintain historical traceability

---

### 2️⃣ Data Cleansing & Transformation (Silver Layer)

The Silver layer improves data quality by applying cleansing and transformation rules.

**Activities:**

* Remove duplicate records
* Handle missing values
* Standardize naming conventions
* Validate data integrity
* Apply business rules

---

### 3️⃣ Dimensional Modeling (Gold Layer)

The Gold layer contains business-ready datasets optimized for analytics.

**Activities:**

* Create Dimension Tables

  * Customers
  * Products
* Create Fact Tables

  * Sales
* Implement surrogate keys
* Establish relationships between facts and dimensions

---

### 4️⃣ Analytics & Reporting

The final warehouse structure supports analytical reporting and business intelligence solutions.

**Deliverables:**

* Reporting-ready datasets
* Business KPIs
* Trend analysis
* Customer insights
* Product performance analysis

---

## 📋 Project Requirements

### Functional Requirements

* Extract data from source systems
* Load raw data into Bronze Layer
* Clean and transform data in Silver Layer
* Create dimensional models in Gold Layer
* Implement automated ETL workflows
* Perform comprehensive data quality checks

### Technical Requirements

| Category         | Technology                          |
| ---------------- | ----------------------------------- |
| Database         | SQL Server                          |
| Language         | T-SQL                               |
| Development Tool | SQL Server Management Studio (SSMS) |
| Version Control  | Git & GitHub                        |
| Architecture     | Medallion Architecture              |

---

## 🏗️ Data Architecture

The project follows a Medallion Architecture consisting of Bronze, Silver, and Gold layers.

<img width="842" height="589" alt="DWH_architecture drawio" src="https://github.com/user-attachments/assets/41f369ef-041a-410e-84e6-2d5cb6e88445" />


### Architecture Layers

#### 🥉 Bronze Layer

Stores raw source data exactly as received from CRM and ERP systems.

#### 🥈 Silver Layer

Contains cleansed, validated, and standardized data ready for business processing.

#### 🥇 Gold Layer

Contains fact and dimension tables optimized for reporting, dashboarding, and analytics.

---

## 📂 Repository Structure

```text
sql-data-warehouse-project
│
├── datasets/
│   ├── crm/
│   └── erp/
│
├── docs/
│   └── data_architecture.png
│
├── scripts/
│   ├── bronze/
│   │   └── load_bronze.sql
│   │
│   ├── silver/
│   │   └── load_silver.sql
│   │
│   ├── gold/
│   │   ├── dim_customers.sql
│   │   ├── dim_products.sql
│   │   └── fact_sales.sql
│   │
│   └── quality_checks/
│       ├── bronze_checks.sql
│       ├── silver_checks.sql
│       └── gold_checks.sql
│
├── README.md
└── LICENSE
```

---

## 📜 License

This project is licensed under the MIT License.

You are free to use, modify, and distribute this project for educational and learning purposes.

---

## 👨‍💻 About Me

Hi, I'm **Sowmya**, an aspiring Data Analyst with a strong interest in Data Engineering, Data Warehousing, and Business Intelligence.

### Skills

* SQL & T-SQL
* SQL Server
* PostgreSQL
* Data Warehousing
* ETL Development
* Data Modeling
* Power BI
* Excel

### Connect With Me

* LinkedIn: *Add your LinkedIn profile*
* GitHub: *Add your GitHub profile*
* Email: *Add your email address*

---

## 🙏 Acknowledgements

A special thanks to **Baraa Khatib** for creating the SQL Data Warehouse tutorial that inspired and guided the development of this project.

---
