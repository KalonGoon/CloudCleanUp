-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  07_top_aws_services.sql
--  AWS spend breakdown by service
--
--  Finding: EC2 = 36%, RDS = 16.72%, S3 = 10.82% of total spend
--  EC2 Reserved Instances could save 30-40% on compute
-- ============================================================

SELECT
    service,
    ROUND(SUM(cost_usd), 2)             AS total_spend,
    ROUND(AVG(cost_usd), 2)             AS avg_daily_spend,
    ROUND(SUM(cost_usd) * 100.0 /
        (SELECT SUM(cost_usd) FROM aws_billing), 2) AS pct_of_total,
    RANK() OVER (ORDER BY SUM(cost_usd) DESC) AS spend_rank
FROM aws_billing
GROUP BY service
ORDER BY total_spend DESC;
