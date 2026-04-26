-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  05_aws_vs_azure.sql
--  Monthly AWS vs Azure spend comparison
--
--  Finding: AWS consistently ~2x Azure (~$60,000/month premium)
--  Jan 2022: AWS $119,263 vs Azure $59,300 = $59,962 premium
-- ============================================================

SELECT
    strftime('%Y-%m', aws.date)         AS month,
    ROUND(SUM(aws.cost_usd), 2)         AS aws_spend,
    ROUND(SUM(az.cost_usd), 2)          AS azure_spend,
    ROUND(SUM(aws.cost_usd) - SUM(az.cost_usd), 2) AS aws_premium,
    ROUND(SUM(aws.cost_usd) / SUM(az.cost_usd), 2) AS aws_azure_ratio
FROM
    (SELECT date, SUM(cost_usd) AS cost_usd
     FROM aws_billing GROUP BY date) aws
JOIN
    (SELECT date, SUM(cost_usd) AS cost_usd
     FROM azure_billing GROUP BY date) az
ON aws.date = az.date
GROUP BY month
ORDER BY month;
