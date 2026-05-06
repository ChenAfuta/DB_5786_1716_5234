-- Add refund reason if missing
ALTER TABLE refund
ADD COLUMN IF NOT EXISTS refund_reason VARCHAR(255);

-- Add claim date if missing
ALTER TABLE insurance_claim
ADD COLUMN IF NOT EXISTS claim_date DATE;

-- Add payment method if missing
ALTER TABLE payment
ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50);
