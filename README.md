# LendingClub Loan Portfolio Risk Analysis

End-to-end credit risk analysis of the LendingClub consumer loan portfolio (2007–2018), covering data auditing, cleaning, exploratory analysis, SQL-based risk segmentation, and an interactive Power BI dashboard.

**Tools used:** Excel · Python (pandas, matplotlib/seaborn) · SQL (MySQL) · Power BI

---

## 📁 Project Structure

```
├── excel/
│   └── Phase1_Data_Audit_LendingClub.xlsx     # Initial data audit & quality checks
├── notebooks/
│   └── Phase2_Python_EDA_Risk_Analysis.ipynb  # Cleaning, feature engineering, EDA
├── sql/
│   ├── 01_data_validation.sql                 # Row counts, dupes, missing values, tie-outs
│   ├── 02_risk_analysis.sql                   # Default rate by grade, purpose, DTI, state, etc.
│   └── 03_advanced_analytics.sql              # Window functions, ranking, trend analysis
├── data/
│   ├── loans_cleaned_sample.csv               # 2,000-row sample of the cleaned dataset
│   └── high_risk_segment_table.csv            # Output table: highest-risk segments
├── powerbi/
│   └── LendingClub_Dashboard.pbix             # Interactive risk dashboard
└── images/
    └── dashboard_screenshot.png               # Dashboard preview
```

> **Note on data:** The full cleaned dataset (2.26M rows) and the raw Kaggle source file exceed GitHub's file size limits, so only a representative sample is included here. The full dataset can be sourced from [Kaggle: LendingClub Loan Data (2007–2018Q4)](https://www.kaggle.com/datasets/wordsforthewise/lending-club).

---

## 🔍 Project Overview

**Phase 1 — Data Audit (Excel):** Initial inspection of the raw LendingClub dataset — column inventory, missing value counts, and data quality flags before any cleaning.

**Phase 2 — Cleaning & EDA (Python):** Feature engineering (DTI bands, income bands, risk category, resolved/default flags) and exploratory analysis of default drivers across grade, purpose, income, and geography.

**Phase 3 — Risk Analysis (SQL):** 20 queries against the cleaned dataset in SQLite, validating the Python output and answering business questions:
- Data validation & cross-tool tie-out (Excel ↔ Python ↔ SQL)
- Default rate by grade, sub-grade, purpose, DTI band, income band, term, home ownership, verification status, state, and employment length
- Window functions: `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()`, running totals, `LAG()`/`LEAD()` trend analysis, and risk concentration flags

**Phase 4 — Dashboard (Power BI):** Interactive dashboard for exploring portfolio exposure and default risk by segment.

---

## 📊 Key Findings

- **Total portfolio:** 2,260,668 loans · $34.0B funded · 19.98% default rate among resolved loans
- Default risk increases sharply with loan grade (A → G) and DTI band
- Certain purposes (e.g. small business) and states show above-average exposure **and** above-average default rate — flagged as priority monitoring segments
- *(See `sql/02_risk_analysis.sql` and `data/high_risk_segment_table.csv` for the full segment breakdown)*

---

## 🖥️ Dashboard Preview

*(Add a screenshot of your Power BI dashboard to `images/dashboard_screenshot.png` and it will display here)*

![Dashboard Preview](images/dashboard_screenshot.png)

---

## 🛠️ How to Reproduce

1. Download the full dataset from [Kaggle](https://www.kaggle.com/datasets/wordsforthewise/lending-club)
2. Run `notebooks/Phase2_Python_EDA_Risk_Analysis.ipynb` to clean and feature-engineer the data
3. Load the cleaned CSV into SQLite as a table named `loans`
4. Run the SQL scripts in order: `01_data_validation.sql` → `02_risk_analysis.sql` → `03_advanced_analytics.sql`
5. Open `powerbi/LendingClub_Dashboard.pbix` in Power BI Desktop to explore the dashboard

---
