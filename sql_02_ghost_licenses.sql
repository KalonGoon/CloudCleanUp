-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  02_ghost_licenses.sql
--  Licenses assigned but never used once (pure waste)
--
--  Finding: Bloomberg Terminal had 36 ghost licenses
--  = $864,000 in annual waste
-- ============================================================

SELECT
    l.software_name,
    l.monthly_cost_usd,
    COUNT(l.license_id)                             AS ghost_licenses,
    COUNT(l.license_id) * l.monthly_cost_usd        AS monthly_waste_usd,
    ROUND(COUNT(l.license_id) * l.monthly_cost_usd * 12, 2) AS annual_waste_usd
FROM licenses_assigned l
WHERE NOT EXISTS (
    SELECT 1 FROM login_activity la
    WHERE la.employee_id = l.employee_id
    AND la.software_id = l.software_id
)
GROUP BY l.software_name, l.monthly_cost_usd
ORDER BY annual_waste_usd DESC;
