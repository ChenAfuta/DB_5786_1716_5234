-- ==========================================
-- Stage 4: Alter Table Modifications
-- Safe to run multiple times
-- ==========================================

-- Add processing_status column to INVOICE table
ALTER TABLE INVOICE
ADD COLUMN IF NOT EXISTS processing_status VARCHAR(30) DEFAULT 'Pending';

-- Add processed_date column to INVOICE table
ALTER TABLE INVOICE
ADD COLUMN IF NOT EXISTS processed_date DATE;

-- Add processing_staff_id to INVOICE table
ALTER TABLE INVOICE
ADD COLUMN IF NOT EXISTS processing_staff_id INT;

-- Add refund_reason column to REFUND table
ALTER TABLE REFUND
ADD COLUMN IF NOT EXISTS refund_reason VARCHAR(255);

-- Add claim_date column to INSURANCE_CLAIM table
ALTER TABLE INSURANCE_CLAIM
ADD COLUMN IF NOT EXISTS claim_date DATE;

-- Add claim_processed_date column to INSURANCE_CLAIM table
ALTER TABLE INSURANCE_CLAIM
ADD COLUMN IF NOT EXISTS claim_processed_date DATE;

-- Add payment_status column to PAYMENT table
ALTER TABLE PAYMENT
ADD COLUMN IF NOT EXISTS payment_status VARCHAR(30) DEFAULT 'Completed';

-- Add chk_processing_status only if it does not already exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_processing_status'
    ) THEN
        ALTER TABLE INVOICE
        ADD CONSTRAINT chk_processing_status
        CHECK (processing_status IN ('Pending', 'Processing', 'Completed', 'Failed'));
    END IF;
END;
$$;

-- Add chk_payment_status only if it does not already exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_payment_status'
    ) THEN
        ALTER TABLE PAYMENT
        ADD CONSTRAINT chk_payment_status
        CHECK (payment_status IN ('Pending', 'Completed', 'Refunded', 'Failed'));
    END IF;
END;
$$;

-- Add chk_processed_date_not_future only if it does not already exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'chk_processed_date_not_future'
    ) THEN
        ALTER TABLE INVOICE
        ADD CONSTRAINT chk_processed_date_not_future
        CHECK (processed_date IS NULL OR processed_date <= CURRENT_DATE);
    END IF;
END;
$$;