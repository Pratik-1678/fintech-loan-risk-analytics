-- ============================================================================
-- 03_ADVANCED_ANALYTICS.SQL
-- LendingClub Loan Portfolio — CTEs, Window Functions, Ranking, Trend Analysis
-- ============================================================================

-- Q18. RANK() — loan grades ranked by default rate (riskiest first)
WITH grade_risk AS (
    SELECT grade,
           SUM(is_resolved) AS resolved_loans,
           SUM(is_default) AS defaults,
           ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
    FROM loans
    GROUP BY grade
)
SELECT grade, resolved_loans, defaults, default_rate_pct,
       RANK() OVER (ORDER BY default_rate_pct DESC) AS risk_rank
FROM grade_risk
ORDER BY risk_rank;

-- Q19. DENSE_RANK() — loan purposes ranked by default rate, minimum volume filter
WITH purpose_risk AS (
    SELECT purpose,
           SUM(is_resolved) AS resolved_loans,
           SUM(is_default) AS defaults,
           ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
    FROM loans
    GROUP BY purpose
    HAVING SUM(is_resolved) >= 1000
)
SELECT purpose, resolved_loans, default_rate_pct,
       DENSE_RANK() OVER (ORDER BY default_rate_pct DESC) AS risk_rank
FROM purpose_risk
ORDER BY risk_rank;

-- Q20. ROW_NUMBER() — top 5 states by total dollar exposure
WITH state_exposure AS (
    SELECT addr_state,
           SUM(funded_amnt) AS total_funded,
           ROUND(100.0 * SUM(is_default) / NULLIF(SUM(is_resolved),0), 2) AS default_rate_pct
    FROM loans
    GROUP BY addr_state
)
SELECT addr_state, total_funded, default_rate_pct,
       ROW_NUMBER() OVER (ORDER BY total_funded DESC) AS exposure_rank
FROM state_exposure
ORDER BY exposure_rank
LIMIT 5;

-- Q21. SUM() OVER() — running cumulative funded amount by origination year
WITH yearly AS (
    SELECT issue_year, SUM(funded_amnt) AS yearly_funded
    FROM loans
    WHERE issue_year IS NOT NULL
    GROUP BY issue_year
)
SELECT issue_year, yearly_funded,
       SUM(yearly_funded) OVER (ORDER BY issue_year) AS running_cumulative_funded
FROM yearly
ORDER BY issue_year;

-- Q22. AVG() OVER() — each grade's default rate vs the overall portfolio average
WITH grade_risk AS (
    SELECT grade,
           SUM(is_resolved) AS resolved_loans,
           ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
    FROM loans
    GROUP BY grade
)
SELECT grade, default_rate_pct,
       ROUND(AVG(default_rate_pct) OVER (), 2) AS portfolio_avg_default_rate,
       ROUND(default_rate_pct - AVG(default_rate_pct) OVER (), 2) AS variance_from_avg
FROM grade_risk
ORDER BY grade;

-- Q23. LAG() — year-over-year change in default rate (resolved loans by issue year)
WITH yearly_risk AS (
    SELECT issue_year,
           SUM(is_resolved) AS resolved_loans,
           SUM(is_default) AS defaults,
           ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
    FROM loans
    WHERE issue_year IS NOT NULL
    GROUP BY issue_year
)
SELECT issue_year, resolved_loans, default_rate_pct,
       LAG(default_rate_pct) OVER (ORDER BY issue_year) AS prev_year_default_rate,
       ROUND(default_rate_pct - LAG(default_rate_pct) OVER (ORDER BY issue_year), 2) AS pp_change
FROM yearly_risk
ORDER BY issue_year;

-- Q24. LEAD() — same trend, looking forward instead of back (for comparison / narrative flexibility)
WITH yearly_risk AS (
    SELECT issue_year,
           ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
    FROM loans
    WHERE issue_year IS NOT NULL
    GROUP BY issue_year
)
SELECT issue_year, default_rate_pct,
       LEAD(default_rate_pct) OVER (ORDER BY issue_year) AS next_year_default_rate
FROM yearly_risk
ORDER BY issue_year;

-- Q25. CTE-based risk segmentation — Low/Medium/High tier default rate & exposure share
WITH risk_tiers AS (
    SELECT risk_category,
           COUNT(*) AS total_loans,
           SUM(is_resolved) AS resolved_loans,
           SUM(is_default) AS defaults,
           SUM(funded_amnt) AS total_funded
    FROM loans
    GROUP BY risk_category
),
portfolio_totals AS (
    SELECT SUM(total_loans) AS all_loans, SUM(total_funded) AS all_funded
    FROM risk_tiers
)
SELECT r.risk_category, r.total_loans,
       ROUND(100.0 * r.total_loans / p.all_loans, 1) AS pct_of_loans,
       ROUND(100.0 * r.total_funded / p.all_funded, 1) AS pct_of_exposure,
       ROUND(100.0 * r.defaults / r.resolved_loans, 2) AS default_rate_pct
FROM risk_tiers r CROSS JOIN portfolio_totals p
ORDER BY default_rate_pct;

-- Q26. Risk concentration flag — segments with above-average exposure AND above-average default rate
-- (CTE + self-referencing comparison to portfolio averages — priority monitoring list)
WITH purpose_stats AS (
    SELECT purpose,
           SUM(funded_amnt) AS total_funded,
           ROUND(100.0 * SUM(is_default) / NULLIF(SUM(is_resolved),0), 2) AS default_rate_pct
    FROM loans
    GROUP BY purpose
    HAVING SUM(is_resolved) >= 1000
),
averages AS (
    SELECT AVG(total_funded) AS avg_funded, AVG(default_rate_pct) AS avg_rate
    FROM purpose_stats
)
SELECT p.purpose, p.total_funded, p.default_rate_pct
FROM purpose_stats p CROSS JOIN averages a
WHERE p.total_funded > a.avg_funded AND p.default_rate_pct > a.avg_rate
ORDER BY p.default_rate_pct DESC;

-- Q27. Month-over-month origination volume trend (2015 as an illustrative year) with growth %
WITH monthly AS (
    SELECT issue_yyyymm, COUNT(*) AS loans_originated, SUM(funded_amnt) AS funded
    FROM loans
    WHERE issue_yyyymm LIKE '2015-%'
    GROUP BY issue_yyyymm
)
SELECT issue_yyyymm, loans_originated, funded,
       LAG(loans_originated) OVER (ORDER BY issue_yyyymm) AS prev_month_loans,
       ROUND(100.0 * (loans_originated - LAG(loans_originated) OVER (ORDER BY issue_yyyymm))
             / LAG(loans_originated) OVER (ORDER BY issue_yyyymm), 1) AS mom_growth_pct
FROM monthly
ORDER BY issue_yyyymm;

-- Q28. Purpose exposure contribution — each purpose's % share of total portfolio funding
-- Rewritten as a two-step CTE (rather than nesting SUM() OVER() directly around SUM()) so it
-- runs identically on MySQL, PostgreSQL, and SQLite without risk of an "invalid use of group
-- function" error some engines raise on doubly-nested aggregate/window expressions.
WITH purpose_totals AS (
    SELECT purpose, SUM(funded_amnt) AS purpose_funded
    FROM loans
    GROUP BY purpose
),
grand_total AS (
    SELECT SUM(purpose_funded) AS total_funded FROM purpose_totals
)
SELECT t.purpose, t.purpose_funded,
       ROUND(100.0 * t.purpose_funded / g.total_funded, 2) AS pct_of_total_exposure
FROM purpose_totals t CROSS JOIN grand_total g
ORDER BY t.purpose_funded DESC;
