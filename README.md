# HR-Analytics-Pipeline
End-to-end HR data pipeline using SQL Server, SSIS, SSRS, and Tableau. Demonstrates ETL, data modeling, reporting, and analytics for workforce attrition insights.

# HR Analytics Pipeline – Workforce Attrition & Performance

## Overview
This project builds an end-to-end data pipeline for HR analytics. It extracts employee data, transforms it using SSIS, loads into SQL Server (star schema), and produces interactive dashboards (Tableau) and paginated reports (SSRS).

## Business Problem
HR needs to understand:
- Which departments have the highest attrition?
- Does performance rating correlate with leaving?
- What profiles (age, distance from home, salary) are more likely to leave?

This pipeline delivers a reusable, automated solution to answer these questions.

## Tools & Technologies
- **SQL Server** (database, T-SQL, indexing, stored procedures)
- **SSIS** (ETL from CSV to SQL)
- **SSRS** (paginated reports for operations)
- **Tableau** (interactive dashboards)
- **GitHub** (version control, portfolio)

## Dataset
Source: [IBM HR Analytics Attrition Dataset](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset)  
- 1,470 employees, 35 features
- Includes: Attrition (Yes/No), Department, JobRole, MonthlyIncome, YearsAtCompany, PerformanceRating, Age, DistanceFromHome.

## Architecture
datasets/*.csv → SSIS (Data Flow) → SQL Server (Staging → Dim/Fact) → SSRS / Tableau


## Repository Structure
HR-Analytics-Pipeline/
├── datasets/ # Raw CSV (IBM HR data)
├── sql_scripts/ # Table creation, indexes, stored procs
├── ssis_packages/ # .dtsx ETL package
├── ssrs_reports/ # .rdl report
├── tableau_dashboards/ # .twb workbook
├── docs/ # Screenshots, architecture diagram
└── README.md


## Setup Instructions 
1. Install SQL Server Developer Edition + SSMS.
2. Install Visual Studio Community with SSDT (includes SSIS/SSRS).
3. Clone this repo.
4. Run `sql_scripts/01_Create_Tables.sql` to create database and schema.
5. Open the SSIS project (`.dtproj`) – load data from `datasets/` to SQL.
6. Deploy SSRS report or open Tableau workbook.

## Key SQL Techniques Demonstrated
- Window functions (`ROW_NUMBER()`, `LAG()` for trend)
- CTE for department-wise aggregation
- Indexed views for performance
- Stored procedure with transaction handling

## Sample Outputs (to be added)
- 📊 Tableau dashboard: Attrition by department & performance rating.
- 📄 SSRS report: Employee-level attrition list with parameters.

## What This Shows
- **SQL Server**: Advanced queries, optimization, data modeling.
- **SSIS/ETL**: Automated pipeline from CSV to warehouse.
- **SSRS/Tableau**: Actionable insights for HR stakeholders.
- **Coordination**: Project structured as if leading a small team (documentation, versioning, reusable components).

## Author
Jesús Fernando Gómez Brito  
[LinkedIn](https://www.linkedin.com/in/jes%C3%BAs-fernando-g%C3%B3mez-brito-02a895279/)  


## Progress
- [x] Repository setup
- [x] Folder structure
- [x] README
- [x] Dataset downloaded
- [x] SQL tables created
- [x] SSIS ETL built
- [ ] Tableau dashboard
- [ ] SSRS report
- [ ] Final documentation & screenshots
