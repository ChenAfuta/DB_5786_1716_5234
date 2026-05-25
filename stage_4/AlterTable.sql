-- ==========================================
-- Stage 4: Alter Table Modifications
-- Schema modifications and new columns for Stage 4 processing
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

-- Add refund_reason column to REFUND table (if not exists from stage_2)
ALTER TABLE REFUND
ADD COLUMN IF NOT EXISTS refund_reason VARCHAR(255);

-- Add claim_date column to INSURANCE_CLAIM table (if not exists from stage_2)
ALTER TABLE INSURANCE_CLAIM
ADD COLUMN IF NOT EXISTS claim_date DATE;

-- Add claim_processed_date column to INSURANCE_CLAIM table
ALTER TABLE INSURANCE_CLAIM
ADD COLUMN IF NOT EXISTS claim_processed_date DATE;

-- Add payment_status column to PAYMENT table
ALTER TABLE PAYMENT
ADD COLUMN IF NOT EXISTS payment_status VARCHAR(30) DEFAULT 'Completed';

-- Constraint: processing_status must be valid
ALTER TABLE INVOICE
ADD CONSTRAINT IF NOT EXISTS chk_processing_status
CHECK (processing_status IN ('Pending', 'Processing', 'Completed', 'Failed'));

-- Constraint: payment_status must be valid
ALTER TABLE PAYMENT
ADD CONSTRAINT IF NOT EXISTS chk_payment_status
CHECK (payment_status IN ('Pending', 'Completed', 'Refunded', 'Failed'));

-- Constraint: processed_date cannot be in the future
ALTER TABLE INVOICE
ADD CONSTRAINT IF NOT EXISTS chk_processed_date_not_future
CHECK (processed_date IS NULL OR processed_date <= CURRENT_DATE);

COMMIT;
