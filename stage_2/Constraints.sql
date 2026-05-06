/* =========================================================
   Constraints.sql
   Stage B - Adding constraints and testing invalid data
   ========================================================= */

-- Constraint 1: refund reason must not be empty
ALTER TABLE refund
ADD CONSTRAINT chk_refund_reason_not_empty
CHECK (TRIM(refund_reason) <> '');

-- Test Constraint 1: should fail
INSERT INTO refund (refund_id, payment_id, refund_date, amount, refund_reason)
VALUES (
    999999,
    (SELECT MIN(payment_id) FROM payment),
    CURRENT_DATE,
    100.00,
    ''
);


-- Constraint 2: invoice date cannot be in the future
ALTER TABLE invoice
ADD CONSTRAINT chk_invoice_date_not_future
CHECK (invoice_date <= CURRENT_DATE);

-- Test Constraint 2: should fail
INSERT INTO invoice (invoice_id, patient_id, admission_id, invoice_date, total_amount)
VALUES (
    999999,
    1,
    1,
    CURRENT_DATE + INTERVAL '10 days',
    500.00
);


-- Constraint 3: claim date cannot be in the future
ALTER TABLE insurance_claim
ADD CONSTRAINT chk_claim_date_not_future
CHECK (claim_date IS NULL OR claim_date <= CURRENT_DATE);

-- Test Constraint 3: should fail
INSERT INTO insurance_claim (claim_id, invoice_id, insurance_id, claim_status, claim_date)
VALUES (
    999999,
    (SELECT MIN(invoice_id) FROM invoice),
    1,
    'Pending',
    CURRENT_DATE + INTERVAL '10 days'
);