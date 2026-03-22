-- ==========================================
-- createTables.sql
-- Billing & Finance Division
-- ==========================================


CREATE TABLE BILLING_STAFF (
    billing_staff_id INT PRIMARY KEY,
    staff_id INT NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL,

    CONSTRAINT chk_billing_staff_role
        CHECK (role IN ('Billing Clerk', 'Billing Manager', 'Insurance Coordinator', 'Cashier'))
);

COMMENT ON TABLE BILLING_STAFF IS 'Stores staff assigned to billing and finance roles.';


CREATE TABLE INVOICE (
    invoice_id INT PRIMARY KEY,
    patient_id INT NOT NULL,
    admission_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,

    CONSTRAINT chk_invoice_total_amount
        CHECK (total_amount >= 0)
);

COMMENT ON TABLE INVOICE IS 'Stores billing invoices issued to patients.';


CREATE TABLE INVOICE_ITEM (
    item_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    service_name VARCHAR(100) NOT NULL,
    cost NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_invoice_item_invoice
        FOREIGN KEY (invoice_id) REFERENCES INVOICE(invoice_id) ON DELETE CASCADE,

    CONSTRAINT chk_invoice_item_cost
        CHECK (cost >= 0)
);

COMMENT ON TABLE INVOICE_ITEM IS 'Stores billed service items for each invoice.';


CREATE TABLE PAYMENT (
    payment_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,

    CONSTRAINT fk_payment_invoice
        FOREIGN KEY (invoice_id) REFERENCES INVOICE(invoice_id) ON DELETE RESTRICT,

    CONSTRAINT chk_payment_amount
        CHECK (amount > 0),

    CONSTRAINT chk_payment_method
        CHECK (payment_method IN ('Cash', 'Credit Card', 'Bank Transfer', 'Insurance', 'Other'))
);

COMMENT ON TABLE PAYMENT IS 'Stores payments for invoices.';


CREATE TABLE REFUND (
    refund_id INT PRIMARY KEY,
    payment_id INT NOT NULL,
    refund_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_refund_payment
        FOREIGN KEY (payment_id) REFERENCES PAYMENT(payment_id) ON DELETE RESTRICT,

    CONSTRAINT chk_refund_amount
        CHECK (amount > 0)
);

COMMENT ON TABLE REFUND IS 'Stores refunds made for payments.';


CREATE TABLE INSURANCE_CLAIM (
    claim_id INT PRIMARY KEY,
    invoice_id INT NOT NULL,
    insurance_id INT NOT NULL,
    claim_status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_claim_invoice
        FOREIGN KEY (invoice_id) REFERENCES INVOICE(invoice_id) ON DELETE RESTRICT,

    CONSTRAINT chk_claim_status
        CHECK (claim_status IN ('Pending', 'Approved', 'Rejected', 'Partially Approved'))
);

COMMENT ON TABLE INSURANCE_CLAIM IS 'Stores insurance claims related to invoices.';