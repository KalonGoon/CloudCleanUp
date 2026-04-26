import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import os

random.seed(42)
np.random.seed(42)

# ── Config ──────────────────────────────────────────────────────────────────
START_DATE = datetime(2022, 1, 1)
END_DATE   = datetime(2024, 12, 31)

DEPARTMENTS = ["Deal Advisory", "Private Equity", "Technology & Digital",
               "Corporate Finance", "Operations", "HR", "Legal", "Research & Analytics"]

# Software licenses
SOFTWARE = [
    {"name": "Microsoft 365",   "vendor": "Microsoft",  "monthly_cost": 22,   "category": "Productivity"},
    {"name": "Salesforce",      "vendor": "Salesforce", "monthly_cost": 150,  "category": "CRM"},
    {"name": "Tableau",         "vendor": "Tableau",    "monthly_cost": 70,   "category": "Analytics"},
    {"name": "Slack",           "vendor": "Slack",      "monthly_cost": 12,   "category": "Collaboration"},
    {"name": "Zoom",            "vendor": "Zoom",       "monthly_cost": 20,   "category": "Collaboration"},
    {"name": "DocuSign",        "vendor": "DocuSign",   "monthly_cost": 45,   "category": "Legal"},
    {"name": "Bloomberg Terminal","vendor":"Bloomberg",  "monthly_cost": 2000, "category": "Finance Data"},
    {"name": "PitchBook",       "vendor": "PitchBook",  "monthly_cost": 833,  "category": "Finance Data"},
    {"name": "Refinitiv Eikon", "vendor": "Refinitiv",  "monthly_cost": 700,  "category": "Finance Data"},
    {"name": "GitHub Enterprise","vendor":"GitHub",      "monthly_cost": 21,   "category": "Dev Tools"},
    {"name": "Jira",            "vendor": "Atlassian",  "monthly_cost": 8,    "category": "Dev Tools"},
    {"name": "Workday",         "vendor": "Workday",    "monthly_cost": 100,  "category": "HR"},
]

# AWS services (heavier usage)
AWS_SERVICES = [
    {"service": "Amazon EC2",         "base_daily": 1800, "std": 300},
    {"service": "Amazon S3",          "base_daily": 420,  "std": 60},
    {"service": "Amazon RDS",         "base_daily": 650,  "std": 100},
    {"service": "AWS Lambda",         "base_daily": 180,  "std": 50},
    {"service": "Amazon CloudFront",  "base_daily": 95,   "std": 20},
    {"service": "Amazon Redshift",    "base_daily": 320,  "std": 80},
    {"service": "AWS Glue",           "base_daily": 140,  "std": 40},
    {"service": "Amazon SageMaker",   "base_daily": 260,  "std": 90},
]

# Azure services (lighter usage — Bain skews AWS)
AZURE_SERVICES = [
    {"service": "Azure Virtual Machines", "base_daily": 950,  "std": 150},
    {"service": "Azure Blob Storage",     "base_daily": 210,  "std": 40},
    {"service": "Azure SQL Database",     "base_daily": 380,  "std": 70},
    {"service": "Azure Active Directory", "base_daily": 85,   "std": 15},
    {"service": "Azure DevOps",           "base_daily": 120,  "std": 30},
    {"service": "Azure Synapse Analytics","base_daily": 190,  "std": 60},
]

EMPLOYEES = []
emp_id = 1000
for dept in DEPARTMENTS:
    n = random.randint(18, 45)
    for _ in range(n):
        EMPLOYEES.append({
            "employee_id": f"EMP{emp_id}",
            "name": f"Employee_{emp_id}",
            "department": dept,
            "role": random.choice(["Analyst", "Associate", "Manager", "Senior Manager", "VP", "Director"]),
            "hire_date": START_DATE - timedelta(days=random.randint(0, 1800))
        })
        emp_id += 1

# ── Helpers ──────────────────────────────────────────────────────────────────
def date_range(start, end):
    d = start
    while d <= end:
        yield d
        d += timedelta(days=1)

def add_anomaly(base, date):
    """Occasional spend spikes — realistic for PE/consulting firms"""
    month = date.month
    # End-of-quarter deal activity spikes (Mar, Jun, Sep, Dec)
    if month in [3, 6, 9, 12] and date.day >= 20:
        base *= random.uniform(1.15, 1.45)
    # Random infra incidents (rare)
    if random.random() < 0.008:
        base *= random.uniform(1.8, 3.2)
    return base

# ── 1. employees.csv ─────────────────────────────────────────────────────────
emp_df = pd.DataFrame(EMPLOYEES)
emp_df.to_csv("/home/claude/employees.csv", index=False)
print(f"employees.csv: {len(emp_df)} rows")

# ── 2. software.csv ──────────────────────────────────────────────────────────
sw_df = pd.DataFrame(SOFTWARE)
sw_df["software_id"] = [f"SW{100+i}" for i in range(len(sw_df))]
sw_df.to_csv("/home/claude/software.csv", index=False)
print(f"software.csv: {len(sw_df)} rows")

# ── 3. licenses_assigned.csv ─────────────────────────────────────────────────
licenses = []
lic_id = 1
for _, emp in emp_df.iterrows():
    dept = emp["department"]
    role = emp["role"]
    for _, sw in sw_df.iterrows():
        # Everyone gets M365 and Slack/Zoom
        if sw["name"] in ["Microsoft 365", "Slack", "Zoom"]:
            assign = True
        # Bloomberg/PitchBook only for finance roles
        elif sw["category"] == "Finance Data":
            assign = dept in ["Deal Advisory", "Private Equity", "Corporate Finance", "Research & Analytics"]
        # Dev tools only for Tech dept
        elif sw["category"] == "Dev Tools":
            assign = dept == "Technology & Digital"
        # Workday only for HR
        elif sw["name"] == "Workday":
            assign = dept == "HR"
        # Salesforce for select depts
        elif sw["name"] == "Salesforce":
            assign = dept in ["Deal Advisory", "Corporate Finance"] and role in ["Manager","Senior Manager","VP","Director"]
        else:
            assign = random.random() < 0.4

        if assign:
            assigned_date = emp["hire_date"] + timedelta(days=random.randint(0, 30))
            licenses.append({
                "license_id": f"LIC{lic_id:05d}",
                "employee_id": emp["employee_id"],
                "software_id": sw["software_id"],
                "software_name": sw["name"],
                "assigned_date": assigned_date.date(),
                "monthly_cost_usd": sw["monthly_cost"]
            })
            lic_id += 1

lic_df = pd.DataFrame(licenses)
lic_df.to_csv("/home/claude/licenses_assigned.csv", index=False)
print(f"licenses_assigned.csv: {len(lic_df)} rows")

# ── 4. login_activity.csv ────────────────────────────────────────────────────
# Simulate realistic usage — some licenses go dark (waste!)
logins = []
login_id = 1
dates = list(date_range(START_DATE, END_DATE))

for _, lic in lic_df.iterrows():
    sw = lic["software_name"]
    # Assign a "usage pattern" per license
    roll = random.random()
    if roll < 0.12:
        pattern = "ghost"       # never logs in — pure waste
    elif roll < 0.28:
        pattern = "occasional"  # logs in rarely
    elif roll < 0.65:
        pattern = "regular"
    else:
        pattern = "heavy"

    if pattern == "ghost":
        continue  # no logins generated

    for d in dates:
        if d < pd.Timestamp(lic["assigned_date"]):
            continue
        is_weekday = d.weekday() < 5
        if not is_weekday and sw not in ["Bloomberg Terminal", "PitchBook"]:
            continue  # most tools unused on weekends

        freq = {"occasional": 0.15, "regular": 0.70, "heavy": 0.92}[pattern]
        if random.random() < freq:
            logins.append({
                "login_id": f"LOG{login_id:07d}",
                "employee_id": lic["employee_id"],
                "software_id": lic["software_id"],
                "software_name": sw,
                "login_date": d.date(),
                "session_minutes": random.randint(5, 480)
            })
            login_id += 1

login_df = pd.DataFrame(logins)
login_df.to_csv("/home/claude/login_activity.csv", index=False)
print(f"login_activity.csv: {len(login_df)} rows")

# ── 5. aws_billing.csv ───────────────────────────────────────────────────────
aws_rows = []
for d in date_range(START_DATE, END_DATE):
    for svc in AWS_SERVICES:
        cost = np.random.normal(svc["base_daily"], svc["std"])
        cost = max(cost, svc["base_daily"] * 0.3)
        cost = add_anomaly(cost, d)
        aws_rows.append({
            "date": d.date(),
            "provider": "AWS",
            "service": svc["service"],
            "usage_type": random.choice(["BoxUsage", "DataTransfer", "Requests", "Storage"]),
            "region": random.choice(["us-east-1", "us-west-2", "eu-west-1"]),
            "cost_usd": round(cost, 4),
            "currency": "USD"
        })

aws_df = pd.DataFrame(aws_rows)
aws_df.to_csv("/home/claude/aws_billing.csv", index=False)
print(f"aws_billing.csv: {len(aws_df)} rows")

# ── 6. azure_billing.csv ─────────────────────────────────────────────────────
azure_rows = []
for d in date_range(START_DATE, END_DATE):
    for svc in AZURE_SERVICES:
        cost = np.random.normal(svc["base_daily"], svc["std"])
        cost = max(cost, svc["base_daily"] * 0.3)
        cost = add_anomaly(cost, d)
        azure_rows.append({
            "date": d.date(),
            "provider": "Azure",
            "service": svc["service"],
            "usage_type": random.choice(["Compute Hours", "Storage GB", "Data Transfer", "Transactions"]),
            "region": random.choice(["eastus", "westus2", "westeurope"]),
            "cost_usd": round(cost, 4),
            "currency": "USD"
        })

azure_df = pd.DataFrame(azure_rows)
azure_df.to_csv("/home/claude/azure_billing.csv", index=False)
print(f"azure_billing.csv: {len(azure_df)} rows")

# ── Summary ──────────────────────────────────────────────────────────────────
total_aws   = aws_df["cost_usd"].sum()
total_azure = azure_df["cost_usd"].sum()
ghost_waste = lic_df[~lic_df["license_id"].isin(login_df["employee_id"] if False else
              lic_df[lic_df["license_id"].isin(
                  set(f"LIC{i:05d}" for i in range(1, lic_id))
              )]["license_id"])]["monthly_cost_usd"].sum()

print(f"\n📊 Dataset Summary")
print(f"  Employees       : {len(emp_df)}")
print(f"  Licenses issued : {len(lic_df)}")
print(f"  Login events    : {len(login_df):,}")
print(f"  AWS total spend : ${total_aws:,.0f}")
print(f"  Azure total spend: ${total_azure:,.0f}")
print(f"  AWS/Azure ratio : {total_aws/total_azure:.2f}x")
