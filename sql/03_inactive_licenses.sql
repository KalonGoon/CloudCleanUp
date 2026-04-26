-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  03_inactive_licenses.sql
--  Licenses with no login activity in the last 30 days
--
--  Finding: ~12% of assigned licenses went inactive
-- ============================================================

WITH last_login AS (
    SELECT
        employee_id,
        software_id,
        MAX(login_date) AS last_seen
    FROM login_activity
    GROUP BY employee_id, software_id
)
SELECT
    e.department,
    l.software_name,
    l.monthly_cost_usd,
    COUNT(*)                                AS inactive_licenses,
    ROUND(COUNT(*) * l.monthly_cost_usd, 2) AS monthly_waste_usd,
    ROUND(COUNT(*) * l.monthly_cost_usd * 12, 2) AS annual_waste_usd
FROM licenses_assigned l
JOIN employees e ON l.employee_id = e.employee_id
LEFT JOIN last_login ll
    ON l.employee_id = ll.employee_id
    AND l.software_id = ll.software_id
WHERE ll.last_seen < DATE('now', '-30 days')
   OR ll.last_seen IS NULL
GROUP BY e.department, l.software_name, l.monthly_cost_usd
ORDER BY annual_waste_usd DESC;
