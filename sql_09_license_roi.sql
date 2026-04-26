-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  09_license_roi.sql
--  License utilization rate vs monthly spend per software
--
--  Shows which tools are worth the cost and which aren't
-- ============================================================

SELECT
    s.name                                              AS software,
    s.category,
    s.monthly_cost,
    COUNT(DISTINCT l.employee_id)                       AS licenses_issued,
    COUNT(DISTINCT la.employee_id)                      AS active_users_90d,
    ROUND(
        COUNT(DISTINCT la.employee_id) * 100.0 /
        NULLIF(COUNT(DISTINCT l.employee_id), 0)
    , 1)                                                AS utilization_pct,
    ROUND(AVG(la.session_minutes), 0)                   AS avg_session_mins,
    ROUND(COUNT(DISTINCT l.employee_id) * s.monthly_cost, 2) AS monthly_spend
FROM software s
LEFT JOIN licenses_assigned l   ON s.software_id = l.software_id
LEFT JOIN login_activity la     ON l.employee_id = la.employee_id
                                AND l.software_id = la.software_id
                                AND la.login_date >= DATE('now', '-90 days')
GROUP BY s.name, s.category, s.monthly_cost
ORDER BY monthly_spend DESC;
