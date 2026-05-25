-- ============================================================
-- Stage C - Views and queries on views
-- Integrated system: Billing & Finance + Staff Management
-- ============================================================

-- ============================================================
-- View 1: Billing & Finance department view
-- Purpose: shows invoices together with payments and refunds.
-- This represents the original Billing & Finance point of view.
-- ============================================================

CREATE OR REPLACE VIEW v_billing_invoice_payments AS
SELECT
    i.invoice_id,
    i.patient_id,
    i.admission_id,
    i.invoice_date,
    i.total_amount AS invoice_total,
    p.payment_id,
    p.payment_date,
    p.amount AS payment_amount,
    p.payment_method,
    r.refund_id,
    r.refund_date,
    r.amount AS refund_amount
FROM invoice i
LEFT JOIN payment p
    ON i.invoice_id = p.invoice_id
LEFT JOIN refund r
    ON p.payment_id = r.payment_id;

-- Required output for the report:
SELECT *
FROM v_billing_invoice_payments
LIMIT 10;

-- Query 1 on View 1: total paid per invoice
SELECT
    invoice_id,
    invoice_total,
    COALESCE(SUM(payment_amount), 0) AS total_paid
FROM v_billing_invoice_payments
GROUP BY invoice_id, invoice_total
ORDER BY invoice_id;

-- Query 2 on View 1: invoices that have refunds
SELECT
    invoice_id,
    payment_id,
    refund_id,
    refund_date,
    refund_amount
FROM v_billing_invoice_payments
WHERE refund_id IS NOT NULL
ORDER BY refund_date DESC;


-- ============================================================
-- View 2: Staff Management department view
-- Purpose: shows staff members with their departments and roles.
-- This represents the new department point of view.
-- ============================================================

CREATE OR REPLACE VIEW v_staff_department_roles AS
SELECT
    s.staffid,
    s.firstname,
    s.lastname,
    s.email,
    s.status,
    s.hiredate,
    d.deptid,
    d.deptname,
    d.building,
    d.floor,
    ro.roleid,
    ro.rolename,
    ro.basehourlysalary
FROM staff s
JOIN departments d
    ON s.deptid = d.deptid
JOIN roles ro
    ON s.roleid = ro.roleid;

-- Required output for the report:
SELECT *
FROM v_staff_department_roles
LIMIT 10;

-- Query 1 on View 2: number of staff members in each department
SELECT
    deptname,
    COUNT(*) AS staff_count
FROM v_staff_department_roles
GROUP BY deptname
ORDER BY staff_count DESC;

-- Query 2 on View 2: active staff and their hourly salary
SELECT
    staffid,
    firstname,
    lastname,
    deptname,
    rolename,
    basehourlysalary
FROM v_staff_department_roles
WHERE status = 'Active'
ORDER BY basehourlysalary DESC;




