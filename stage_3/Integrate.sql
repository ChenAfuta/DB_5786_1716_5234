-- ============================================================
-- Stage C - Integration Script
-- Integrated system: Billing & Finance + Staff Management
-- ============================================================
-- Important:
-- This script does not recreate the original billing tables.
-- It keeps the existing tables and adds only the missing structures
-- and relationships needed for the integrated ERD.
-- ============================================================

BEGIN;

-- ============================================================
-- 1. Staff Management tables from the new department
-- ============================================================

CREATE TABLE IF NOT EXISTS departments (
    deptid INTEGER PRIMARY KEY,
    deptname VARCHAR(100) NOT NULL,
    building VARCHAR(50) NOT NULL,
    floor INTEGER NOT NULL,
    CONSTRAINT chk_floor CHECK (floor >= -5 AND floor <= 20)
);

CREATE TABLE IF NOT EXISTS roles (
    roleid INTEGER PRIMARY KEY,
    rolename VARCHAR(100) NOT NULL,
    basehourlysalary NUMERIC(10,2) NOT NULL,
    description TEXT,
    CONSTRAINT chk_salary_pos CHECK (basehourlysalary > 0)
);

CREATE TABLE IF NOT EXISTS staff (
    staffid INTEGER PRIMARY KEY,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100) NOT NULL,
    idnumber VARCHAR(20) NOT NULL UNIQUE,
    phone VARCHAR(20),
    status VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    hiredate DATE NOT NULL,
    deptid INTEGER NOT NULL,
    roleid INTEGER NOT NULL,
    CONSTRAINT staff_deptid_fkey FOREIGN KEY (deptid)
        REFERENCES departments(deptid),
    CONSTRAINT staff_roleid_fkey FOREIGN KEY (roleid)
        REFERENCES roles(roleid),
    CONSTRAINT chk_hospital_email CHECK (email LIKE '%@hospital.org.il'),
    CONSTRAINT chk_status_vals CHECK (status IN ('Active', 'Inactive', 'On Leave', 'Terminated'))
);

CREATE TABLE IF NOT EXISTS shifts (
    shiftid INTEGER PRIMARY KEY,
    shifttype VARCHAR(50) NOT NULL,
    startshift TIME NOT NULL,
    endshift TIME NOT NULL,
    shiftmultiplier NUMERIC(3,2) NOT NULL,
    CONSTRAINT chk_mult_min CHECK (shiftmultiplier >= 1.0)
);

CREATE TABLE IF NOT EXISTS shiftassignments (
    assignmentid INTEGER PRIMARY KEY,
    workdate DATE NOT NULL,
    starttime TIME NOT NULL,
    endtime TIME NOT NULL,
    staffid INTEGER NOT NULL,
    shiftid INTEGER NOT NULL,
    deptid INTEGER NOT NULL,
    CONSTRAINT shiftassignments_staffid_fkey FOREIGN KEY (staffid)
        REFERENCES staff(staffid),
    CONSTRAINT shiftassignments_shiftid_fkey FOREIGN KEY (shiftid)
        REFERENCES shifts(shiftid),
    CONSTRAINT shiftassignments_deptid_fkey FOREIGN KEY (deptid)
        REFERENCES departments(deptid),
    CONSTRAINT chk_work_times CHECK (endtime > starttime)
);

CREATE TABLE IF NOT EXISTS salaries (
    salaryid INTEGER PRIMARY KEY,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    paymentdate DATE NOT NULL,
    baseamount NUMERIC(10,2) NOT NULL,
    bonusamount NUMERIC(10,2) DEFAULT 0,
    overtimehours NUMERIC(5,2) DEFAULT 0,
    staffid INTEGER NOT NULL,
    CONSTRAINT salaries_staffid_fkey FOREIGN KEY (staffid)
        REFERENCES staff(staffid),
    CONSTRAINT chk_month_range CHECK (month >= 1 AND month <= 12),
    CONSTRAINT chk_positive_pay CHECK (baseamount >= 0 AND bonusamount >= 0),
    CONSTRAINT chk_year_min CHECK (year > 2020)
);

-- ============================================================
-- 2. Integrating Billing_Staff with Staff
-- ============================================================
-- In the integrated ERD, Billing_Staff is merged into Staff.
-- Instead of keeping Billing_Staff as a separate employee entity,
-- invoices can now reference the Staff member who handled them.
-- The column is nullable so existing invoice records remain valid.

ALTER TABLE invoice
ADD COLUMN IF NOT EXISTS handled_by_staffid INTEGER;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.table_constraints
        WHERE constraint_name = 'invoice_handled_by_staff_fkey'
          AND table_name = 'invoice'
    ) THEN
        ALTER TABLE invoice
        ADD CONSTRAINT invoice_handled_by_staff_fkey
        FOREIGN KEY (handled_by_staffid)
        REFERENCES staff(staffid);
    END IF;
END $$;

-- Optional: preserve old billing_staff table if it already exists.
-- We do not drop it, because the instructions say not to recreate the whole DB
-- and because it may contain existing project data.

-- ============================================================
-- 3. Helpful indexes for integrated queries and views
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_invoice_handled_by_staffid
ON invoice(handled_by_staffid);

CREATE INDEX IF NOT EXISTS idx_staff_deptid
ON staff(deptid);

CREATE INDEX IF NOT EXISTS idx_staff_roleid
ON staff(roleid);

CREATE INDEX IF NOT EXISTS idx_salaries_staffid
ON salaries(staffid);

CREATE INDEX IF NOT EXISTS idx_shiftassignments_staffid
ON shiftassignments(staffid);

CREATE INDEX IF NOT EXISTS idx_payment_invoiceid
ON payment(invoice_id);

CREATE INDEX IF NOT EXISTS idx_refund_paymentid
ON refund(payment_id);

COMMIT;

-- ============================================================
-- Validation queries to run after integration
-- ============================================================
-- SELECT COUNT(*) FROM departments;
-- SELECT COUNT(*) FROM roles;
-- SELECT COUNT(*) FROM staff;
-- SELECT COUNT(*) FROM shifts;
-- SELECT COUNT(*) FROM shiftassignments;
-- SELECT COUNT(*) FROM salaries;
-- SELECT COUNT(*) FROM invoice;
-- SELECT COUNT(*) FROM payment;
-- SELECT COUNT(*) FROM refund;
