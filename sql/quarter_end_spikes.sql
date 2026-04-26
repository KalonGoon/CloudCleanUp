-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  08_quarter_end_spikes.sql
--  Month-over-month AWS spend change with quarter-end flagging
--
--  Finding: Mar/Jun/Sep/Dec consistently spike higher
--  tied to deal activity at a PE firm
-- ============================================================

WITH monthly AS (
    SELECT
        strftime('%Y-%m', date)     AS month,
        CAST(strftime('%m', date) AS INTEGER) AS month_num,
        ROUND(SUM(cost_usd), 2)     AS total_cost
    FROM aws_billing
    GROUP BY month, month_num
)
SELECT
    month,
    total_cost,
    LAG(total_cost) OVER (ORDER BY month)   AS prev_month_cost,
    ROUND(
        (total_cost - LAG(total_cost) OVER (ORDER BY month)) * 100.0 /
        LAG(total_cost) OVER (ORDER BY month)
    , 2)                                    AS mom_change_pct,
    CASE
        WHEN month_num IN (3, 6, 9, 12) THEN 'Quarter-End'
        ELSE 'Regular'
    END                                     AS period_type
FROM monthly
ORDER BY month;
