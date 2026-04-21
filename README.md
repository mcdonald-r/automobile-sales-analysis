# automobile-sales-analysis
# Automobile Sales Pipeline Risk Analysis

## Overview
This project analyzes an automobile sales dataset to identify where revenue is being lost or delayed across the order pipeline. Using SQL for data exploration and Python (pandas, matplotlib, seaborn) for data analysis/visualization, the project examines cancelled, disputed, and on-hold orders to uncover patterns by geography, customer, product line, and time period.

## Tools & Methods
- **SQL (PostgreSQL)** — data exploration, quality checks, and analysis queries
- **Python** — pandas for data manipulation, matplotlib and seaborn for visualization
- **Jupyter Notebook** — end-to-end analysis narrative
- **Dataset** — [Automobile Sales Dataset]([https://www.kaggle.com](https://www.kaggle.com/datasets/ddosad/auto-sales-data)) from Kaggle

## Key Findings
- Problem orders (Cancelled, Disputed, and On Hold) represent `4.5%` of total pipeline revenue — approximately `$446,000` across 118      orders
- The **USA** accounts for the largest share of problem order revenue at roughly `$200,000`, nearly 2.5x the next highest countries       (Spain and Sweden)
- **Euro Shopping Channel** carries the highest problem order revenue at `$82,832` with 22 repeat problem orders across Cancelled and     Disputed categories, suggesting a systemic relationship issue rather than isolated incidents
- **Classic Cars** is the most affected product line at `30%` of problem order revenue (`$134,000`), with Medium sized deals driving      the majority of problem orders across all product lines
- Problem orders show a recurring seasonal pattern — **Q2 was the highest problem order quarter in both 2019 and 2020**, suggesting       potential logistics or demand challenges specific to this time of year

## Repository Structure
- `auto_sales_analysis.ipynb` — main analysis notebook
- `automobile_queries.sql` — full SQL query file covering exploration, quality checks, and analysis
- `data/` — place dataset here (download from Kaggle link above)
