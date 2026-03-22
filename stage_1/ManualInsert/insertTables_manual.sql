-- ==========================================
-- insertTables_manual.sql
-- Manual logical inserts for the Billing & Finance Division
-- ==========================================

-- 1. BILLING_STAFF
-- 'role' must be one of: 'Billing Clerk', 'Billing Manager', 'Insurance Coordinator', 'Cashier'
INSERT INTO BILLING_STAFF (billing_staff_id, staff_id, role) VALUES 
(9001, 9101, 'Billing Manager'),
(9002, 9102, 'Cashier'),
(9003, 9103, 'Insurance Coordinator'),
(9004, 9104, 'Billing Clerk');

-- 2. INVOICE
-- 'total_amount' logically matches the sum of INVOICE_ITEM costs for each invoice.
-- invoice 1: 1500.00
-- invoice 2: 800.50
-- invoice 3: 4500.00
INSERT INTO INVOICE (invoice_id, patient_id, admission_id, invoice_date, total_amount) VALUES 
(9001, 9201, 9301, '2025-01-15', 1500.00),
(9002, 9202, 9302, '2025-02-10', 800.50),
(9003, 9203, 9303, '2025-03-05', 4500.00);

-- 3. INVOICE_ITEM
-- The sum of 'cost' for each invoice matches the 'total_amount' of the INVOICE.
INSERT INTO INVOICE_ITEM (item_id, invoice_id, service_name, cost) VALUES 
(9001, 9001, 'MRI Scan', 1000.00),
(9002, 9001, 'Blood Test', 500.00),
(9003, 9002, 'Consultation', 300.00),
(9004, 9002, 'X-Ray', 500.50),
(9005, 9003, 'Hospital Stay', 4500.00);

-- 4. PAYMENT
-- 'payment_method' must be: 'Cash', 'Credit Card', 'Bank Transfer', 'Insurance', 'Other'
-- Invoice 1: Paid fully with Credit Card
-- Invoice 2: Paid partially (500 Cash, 300.50 Insurance)
-- Invoice 3: Paid fully with Bank Transfer
INSERT INTO PAYMENT (payment_id, invoice_id, payment_date, amount, payment_method) VALUES 
(9001, 9001, '2025-01-16', 1500.00, 'Credit Card'),
(9002, 9002, '2025-02-10', 500.00, 'Cash'),
(9003, 9002, '2025-02-15', 300.50, 'Insurance'),
(9004, 9003, '2025-03-06', 4500.00, 'Bank Transfer');

-- 5. REFUND
-- Refunding 500.00 back to the patient's Credit Card for Invoice 1.
INSERT INTO REFUND (refund_id, payment_id, refund_date, amount) VALUES 
(9001, 9001, '2025-01-20', 500.00);

-- 6. INSURANCE_CLAIM
-- 'claim_status' must be: 'Pending', 'Approved', 'Rejected', 'Partially Approved'
-- Invoice 1 claim: Approved
-- Invoice 3 claim: Rejected (which is why they paid by Bank Transfer instead)
INSERT INTO INSURANCE_CLAIM (claim_id, invoice_id, insurance_id, claim_status) VALUES 
(9001, 9002, 9401, 'Approved'),
(9002, 9003, 9402, 'Rejected');
