-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  06_anomaly_detection.sql
--  Z-score based AWS spend anomaly detection
--
--  Finding: 8+ anomaly days flagged
--  Worst: 2024-03-01 — $8,198 vs $4,045 baseline (z-score: 6.89)
--  Pattern: anomalies cluster around quarter-end deal activity
-- ============================================================

WITH daily_totals AS (
    SELECT
        date,
        SUM(cost_usd) AS daily_cost
    FROM aws_billing
    GROUP BY date
),
stats AS (
    SELECT
        AVG(daily_cost) AS avg_cost,
        AVG(daily_cost * daily_cost) -
        AVG(daily_cost) * AVG(daily_cost) AS variance
    FROM daily_totals
)
SELECT
    d.date,
    ROUND(d.daily_cost, 2)              AS daily_cost,
    ROUND(s.avg_cost, 2)                AS avg_baseline,
    ROUND(d.daily_cost - s.avg_cost, 2) AS overspend_usd,
    ROUND((d.daily_cost - s.avg_cost) / SQRT(s.variance), 2) AS z_score,
    CASE
        WHEN (d.daily_cost - s.avg_cost) / SQRT(s.variance) > 2.5 THEN 'ANOMALY'
        WHEN (d.daily_cost - s.avg_cost) / SQRT(s.variance) > 1.5 THEN 'WARNING'
        ELSE 'Normal'
    END AS status
FROM daily_totals d, stats s
WHERE (d.daily_cost - s.avg_cost) / SQRT(s.variance) > 1.5
ORDER BY z_score DESC;
