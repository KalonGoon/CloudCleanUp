-- ============================================================
--  CloudCleanUp — Bain Capital IT Procurement Analytics
--  01_schema.sql — Table Definitions
-- ============================================================

CREATE TABLE employees (
    employee_id     VARCHAR(10) PRIMARY KEY,
    name            VARCHAR(100),
    department      VARCHAR(100),
    role            VARCHAR(50),
    hire_date       DATE
);

CREATE TABLE software (
    software_id     VARCHAR(10) PRIMARY KEY,
    name            VARCHAR(100),
    vendor          VARCHAR(100),
    monthly_cost    DECIMAL(10,2),
    category        VARCHAR(50)
);

CREATE TABLE licenses_assigned (
    license_id          VARCHAR(15) PRIMARY KEY,
    employee_id         VARCHAR(10) REFERENCES employees(employee_id),
    software_id         VARCHAR(10) REFERENCES software(software_id),
    software_name       VARCHAR(100),
    assigned_date       DATE,
    monthly_cost_usd    DECIMAL(10,2)
);

CREATE TABLE login_activity (
    login_id        VARCHAR(15) PRIMARY KEY,
    employee_id     VARCHAR(10) REFERENCES employees(employee_id),
    software_id     VARCHAR(10) REFERENCES software(software_id),
    software_name   VARCHAR(100),
    login_date      DATE,
    session_minutes INT
);

CREATE TABLE aws_billing (
    date            DATE,
    provider        VARCHAR(10),
    service         VARCHAR(100),
    usage_type      VARCHAR(50),
    region          VARCHAR(20),
    cost_usd        DECIMAL(12,4),
    currency        VARCHAR(5)
);

CREATE TABLE azure_billing (
    date            DATE,
    provider        VARCHAR(10),
    service         VARCHAR(100),
    usage_type      VARCHAR(50),
    region          VARCHAR(20),
    cost_usd        DECIMAL(12,4),
    currency        VARCHAR(5)
);

-- Index to speed up license/login join queries significantly
CREATE INDEX idx_login_emp_sw
ON login_activity(employee_id, software_id);
