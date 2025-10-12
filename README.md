# NorthWind Analytics : From Data to Insights  

Northwind Analytics provides a comprehensive analysis of the Northwind company’s sales and operations data to uncover meaningful business insights. Using data from 11 interconnected areas — including customers, products, orders, suppliers, and employees — this project translates complex information into clear, actionable findings that support smarter decision-making.

The analysis focuses on identifying top-performing products, high-value customers, and key revenue regions, while also revealing opportunities to improve inventory efficiency, employee performance, and overall profitability.

By turning raw data into an easy-to-understand story about business performance, this project enables managers and stakeholders to make informed, evidence-based decisions that strengthen customer relationships, optimize operations, and drive sustainable growth.

## Table of Contents

+ [Project Objective](#project-objective)
+ [Project Files](#project-files)
+ [Tools and Technologies](#tools-and-technologies)
+ [Setup & Installation](#setup--installation)
+ [Project Workflow](#project-workflow)
+ [Analysis Summary & Key Insights](#analysis-summary--key-insights)
+ [Project Structure](#project-structure)
+ [Contributing](#contributing)
+ [License](#license)
+ [Author](#author)

## Project Objective

The primary objective of the Northwind SQL Analytics project is to transform business data into meaningful insights that help Northwind’s management make informed, data-driven decisions. The project aims to:

+ Identify key revenue drivers by analyzing top-performing products, customers, and regions.

+ Improve operational efficiency through insights on order patterns, supplier performance, and inventory management.

+ Evaluate employee sales performance to recognize high achievers and identify areas for growth.

+ Understand customer purchasing behavior to support targeted marketing and retention strategies.

+ Provide a data-backed foundation for optimizing profitability, resource allocation, and strategic planning.

By achieving these objectives, the project empowers stakeholders with a clear understanding of how business performance can be enhanced through the intelligent use of data.

## Project Files

### 1. Data Files

The **`data/raw/`** folder contains the original SQL files that form the foundation of this project.  

- **`data/raw/northwind_ddl.sql`** — Defines the complete **database schema** for the Northwind dataset, including table structures, relationships, primary and foreign keys, and constraints.  
- **`data/raw/northwind_data.sql`** — Contains the **raw data inserts** for all tables such as *Customers*, *Orders*, *Products*, *Suppliers*, *Employees*, and *Shippers*.  

Together, these files recreate the **Northwind relational database**, which represents a fictional trading company — *Northwind Traders*. The dataset captures various business processes like order management, sales transactions, and product distribution.  

Key entities include:
- **Customers** – client details and contact information  
- **Orders** – transactional records linking customers and employees  
- **Products & Categories** – product catalog and classification  
- **Suppliers** – vendor details and product sourcing data  
- **Employees** – sales representatives managing customer orders  
- **Shippers** – logistics partners responsible for delivery  

This dataset is widely used for **SQL analytics, data modeling, and business intelligence** projects.


### 2. SQL Scripts

The **`sql/`** folder contains all SQL-related files used for analysis.  

- **`sql/northwind_analysis.sql`** — This is the **main analytical script** of the project. It contains SQL queries that answer the key business questions, such as top-performing products, revenue trends, customer behavior, employee performance, and profitability insights.  

All queries in this script are executed on the **Northwind database**, built from the raw SQL files in `data/raw/`. The script is structured to be modular and reproducible, allowing any analyst to rerun the analysis from scratch.  

> **Folder path:** `sql/`

### 3. Reports

The **`reports/`** folder contains all outputs from the analysis, including dashboards, visualizations, and summary reports.  

- **`reports/dashboards/northwind_analysis.pbix`** — Power BI dashboard visualizing key metrics and business trends.  
- **`reports/figures/`** — Image exports of visuals such as revenue trends, ROI charts, and performance comparisons.  
- **`reports/summary_reports/northwind_analysis_report.pdf`** — Final report summarizing insights, analysis, and recommendations.  

These files provide a complete view of the analytical results and can be used for presentations, business meetings, or further exploration.  

> **Folder path:** `reports/`

## Tools and Technologies

| Category | Tool / Technology | Purpose |
|----------|-----------------|---------|
| Database | PostgreSQL | Host and manage the Northwind dataset; perform SQL queries for analytics |
| Query Language | SQL | Data extraction, aggregation, and analysis |
| Visualization | Power BI | Create dashboards and visualizations of key business metrics |
| Reporting & Documentation | Markdown | Project documentation and README formatting |
| Reporting & Documentation | Quarto | Generate PDF reports and structured summaries |
| Version Control | Git & GitHub | Track project changes, maintain versions, and collaboration |

## Setup & Installation

Follow these steps to set up and run the Northwind SQL Analytics project locally:

### 1. Clone the repository 
   ```bash
   git clone https://github.com/yourusername/northwind_sql_analytics.git

   cd northwind_sql_analytics
   ```
### 2. Install PostgreSQL

+ Ensure PostgreSQL is installed and running on your system.

+ You can download it from https://www.postgresql.org/download/

### 3. Create the Northwind database

+ Open the PostgreSQL client (psql, pgAdmin, or any SQL IDE).

+ Execute the schema file to create tables and load Data:

    - Excute the `data/raw/northwind_ddl.sql` to create tables in database.
    - After that excute `data/raw/northwind_data.sql` to insert the data in the tables.

### 4. Run the Analysis

+ Execute the main SQL script to generate analytical results:

    - Now execute the main sql script `sql/northwind_analysis.sql` to start the analysis.


### 5. View reports and dashboards

+ Open the Power BI dashboard: `reports/dashboards/northwind_analysis.pbix`

+ Review the summary PDF report: `reports/summary_reports/northwind_analysis_report.pdf`

Following these steps ensures a fully reproducible setup for exploring, analyzing, and visualizing the Northwind dataset.




## Project Workflow


## Analysis Summary & Key Insights


## Project Structure
```bash
data_analytics_project_template/
│
├─ data/                    # Data storage
│  ├─ final/                    # Final datasets (ready for reporting/ML models)
│  ├─ interim/                  # Intermediate processed files
│  └─ raw/                      # Raw untouched datasets
│
├─ logs/                    # Logging outputs (script runs, ETL jobs, errors)
│
├─ notebooks/               # Jupyter notebooks (exploration, EDA, visualization)
│  ├─ 01_data_cleaning.ipynb
│  ├─ 02_exploratory_data_analysis.ipynb
│  └─ 03_ml_models.ipynb
│
├─ reports/                 # Deliverables for stakeholders
│  ├─ dashboards/           # Power BI/Tableau/Looker dashboards
│  ├─ figures/              # Saved plots, charts, images
│  └─ summary_reports/      # Business-style reports (PDF/Word/Markdown)
│
├─ scripts/                 # Reusable Python scripts
│
├─ sql/                     # All reusable SQL queries
│
├─ .gitignore               # Ignore data, logs, venv, credentials
├─ LICENCE                  # Open-source license
├─ README.md                # Project overview + instructions
└─ requirements.txt         # Python dependencies
```

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.


## License

This project is licensed under the MIT License.


## Author

Hi, I'm Hemant, a data enthusiast passionate about turning raw data into meaningful business insights.

**Let’s connect:**
- LinkedIn : [LinkedIn Profile](https://www.linkedin.com/in/hemant1491/)  
- Email : hemant4dsci@gmail.com
