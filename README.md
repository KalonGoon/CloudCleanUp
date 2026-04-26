CloudCleanUp

Analyzed 3 years of IT procurement data for a private equity firm — uncovering license waste, cloud overspend, and anomalous AWS billing events across a 300-person organization.

Summary
Most large firms have no visibility into whether their software licenses are actually being used, or why their cloud bill spikes unexpectedly. This project simulates that problem for a PE/consulting firm environment and answers it with SQL.

Key findings:
💸 $864,000 in annual license waste from Bloomberg Terminal ghost licenses never activated
📉 ~12% of assigned licenses went unused in the last 30 days
☁️ AWS spend ran ~2x Azure consistently across all 3 years (~$60,000/month premium)
🚨 8+ billing anomalies flagged using z-score detection — worst spike hit $8,198 in a single day (z-score: 6.89) on 2024-03-01
📆 Quarter-end months (Mar/Jun/Sep/Dec) showed higher AWS spend tied to deal activity
🏢 Corporate Finance was the most wasteful department — $556,920 in annual unused license spend
💰 Total identifiable annual savings: $1.2M+

⚠️ All data is simulated. No real Bain Capital data was used. Dataset was generated using Python to reflect realistic PE firm procurement patterns.
