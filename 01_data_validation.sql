-- ============================================================================
-- 01_DATA_VALIDATION.SQL
-- LendingClub Loan Portfolio — Data Validation Queries
-- Run against: loans.db (SQLite) — loaded from cleaned/feature-engineered data
-- produced in Phase 2 (Python). Table: loans (2,260,668 rows, 44 columns)
-- ============================================================================

-- Q1. Row count sanity check
-- Business Question: Does the SQL table match the cleaned Python dataset row count?
SELECT COUNT(*) AS total_rows
FROM loans;
-- Expected: 2,260,668 (matches Phase 2 notebook output exactly)

-- Q2. Duplicate loan ID check
-- Business Question: Are there any duplicate loan records that would double-count exposure?
SELECT COUNT(*) AS duplicate_ids
FROM (
    SELECT id, COUNT(*) AS cnt
    FROM loans
    GROUP BY id
    HAVING COUNT(*) > 1
) AS dup_check;

-- Q3. Missing-value check on key risk fields
-- Business Question: Which key fields have data quality gaps that could bias risk analysis?
SELECT
    SUM(CASE WHEN dti IS NULL THEN 1 ELSE 0 END)              AS missing_dti,
    SUM(CASE WHEN annual_inc IS NULL THEN 1 ELSE 0 END)       AS missing_income,
    SUM(CASE WHEN emp_length_years IS NULL THEN 1 ELSE 0 END) AS missing_emp_length,
    SUM(CASE WHEN grade IS NULL THEN 1 ELSE 0 END)            AS missing_grade,
    SUM(CASE WHEN dti_valid = 0 THEN 1 ELSE 0 END)            AS invalid_dti_flagged
FROM loans;

-- Q4. Loan status distribution
-- Business Question: What does the full population look like by status (resolved vs active)?
SELECT loan_status, COUNT(*) AS loan_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM loans), 2) AS pct_of_portfolio
FROM loans
GROUP BY loan_status
ORDER BY loan_count DESC;

-- Q5. Resolved-population cross-check against Phase 1 (Excel) / Phase 2 (Python) figures
-- Business Question: Do total loans, resolved loans, defaults, and total funded amount tie out
-- across all three tools (Excel, Python, SQL)? This is the validation checklist requirement.
SELECT
    COUNT(*)                                   AS total_loans,
    SUM(is_resolved)                           AS resolved_loans,
    SUM(is_default)                            AS defaults,
    ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct,
    ROUND(SUM(funded_amnt), 0)                 AS total_funded
FROM loans;
-- Expected: 2,260,668 / 1,348,099 / 269,360 / 19.98% / 34,004,208,600 — matches Phase 1 & 2 exactly

-- Q6. Grade value validity check
-- Business Question: Are grade values clean and limited to the expected A-G scale?
SELECT DISTINCT grade FROM loans ORDER BY grade;

-- Q7. Funded amount vs loan amount consistency check
-- Business Question: Are there loans where funded_amnt exceeds loan_amnt (a logical impossibility)?
SELECT COUNT(*) AS inconsistent_funding_rows
FROM loans
WHERE funded_amnt > loan_amnt;
