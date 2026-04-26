-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  04_dept_overspend.sql
--  Department waste ranking — unused licenses by department
--
--  Finding: Corporate Finance worst at $556,920/year (78 licenses)
-- ============================================================

SELECT
    e.department,
    COUNT(l.license_id)                         AS unused_licenses,
    ROUND(SUM(l.monthly_cost_usd) * 12, 2)      AS annual_waste_usd,
    RANK() OVER (ORDER BY SUM(l.monthly_cost_usd) DESC) AS waste_rank
FROM licenses_assigned l
JOIN employees e ON l.employee_id = e.employee_id
WHERE NOT EXISTS (
    SELECT 1 FROM login_activity la
    WHERE la.employee_id = l.employee_id
    AND la.software_id = l.software_id
)
GROUP BY e.department
ORDER BY annual_waste_usd DESC;
