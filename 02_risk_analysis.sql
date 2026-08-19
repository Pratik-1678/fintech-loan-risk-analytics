-- ============================================================================
-- 02_RISK_ANALYSIS.SQL
-- LendingClub Loan Portfolio — Default Rate by Segment
-- All default rates use: defaults / resolved_loans (is_resolved = 1)
-- ============================================================================

-- Q8. Default rate by loan grade
SELECT grade,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct,
       ROUND(SUM(funded_amnt), 0) AS total_funded
FROM loans
GROUP BY grade
ORDER BY grade;

-- Q9. Default rate by sub_grade — top 10 riskiest with meaningful volume
SELECT sub_grade,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
GROUP BY sub_grade
HAVING SUM(is_resolved) >= 1000
ORDER BY default_rate_pct DESC
LIMIT 10;

-- Q10. Default rate by loan purpose
SELECT purpose,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct,
       ROUND(SUM(funded_amnt), 0) AS total_funded
FROM loans
GROUP BY purpose
ORDER BY total_loans DESC;

-- Q11. Default rate by DTI band
SELECT dti_band,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
WHERE dti_band <> 'Invalid/Unknown'
GROUP BY dti_band
ORDER BY
    CASE dti_band WHEN '<10' THEN 1 WHEN '10-20' THEN 2 WHEN '20-30' THEN 3
                   WHEN '30-40' THEN 4 WHEN '40+' THEN 5 END;

-- Q12. Default rate by annual income band
SELECT income_band,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
WHERE income_band <> 'Unknown'
GROUP BY income_band
ORDER BY
    CASE income_band WHEN '<$30k' THEN 1 WHEN '$30k-60k' THEN 2 WHEN '$60k-90k' THEN 3
                       WHEN '$90k-120k' THEN 4 WHEN '$120k+' THEN 5 END;

-- Q13. Default rate by loan term
SELECT term_months,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
GROUP BY term_months;

-- Q14. Default rate by home ownership
SELECT home_ownership,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
GROUP BY home_ownership
ORDER BY total_loans DESC;

-- Q15. Default rate by verification status
SELECT verification_status,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
GROUP BY verification_status
ORDER BY total_loans DESC;

-- Q16. Default rate by state — top 10 highest-risk states with meaningful volume
SELECT addr_state,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
GROUP BY addr_state
HAVING SUM(is_resolved) >= 5000
ORDER BY default_rate_pct DESC
LIMIT 10;

-- Q17. Employment length vs default rate
SELECT emp_length_years,
       COUNT(*) AS total_loans,
       SUM(is_resolved) AS resolved_loans,
       SUM(is_default) AS defaults,
       ROUND(100.0 * SUM(is_default) / SUM(is_resolved), 2) AS default_rate_pct
FROM loans
WHERE emp_length_years IS NOT NULL
GROUP BY emp_length_years
ORDER BY emp_length_years;
