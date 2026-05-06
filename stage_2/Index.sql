/* =========================================================
   Index.sql
   Stage B - Indexes and performance testing
   ========================================================= */

-- Enable timing in psql
\timing on


/* =========================================================
   Index 1 - payment(payment_date)
   ========================================================= */

-- Before index
EXPLAIN ANALYZE
SELECT *
FROM payment
WHERE payment_date >= DATE '2025-01-01'
  AND payment_date < DATE '2025-02-01';

-- Create index
CREATE INDEX idx_payment_payment_date
ON payment(payment_date);

-- After index
EXPLAIN ANALYZE
SELECT *
FROM payment
WHERE payment_date >= DATE '2025-01-01'
  AND payment_date < DATE '2025-02-01';


/* =========================================================
   Index 2 - payment(invoice_id)
   ========================================================= */

-- Before index
EXPLAIN ANALYZE
SELECT p.payment_id, p.amount, i.total_amount
FROM payment p
JOIN invoice i
    ON p.invoice_id = i.invoice_id
WHERE p.invoice_id BETWEEN 100 AND 300;

-- Create index
CREATE INDEX idx_payment_invoice_id
ON payment(invoice_id);

-- After index
EXPLAIN ANALYZE
SELECT p.payment_id, p.amount, i.total_amount
FROM payment p
JOIN invoice i
    ON p.invoice_id = i.invoice_id
WHERE p.invoice_id BETWEEN 100 AND 300;


/* =========================================================
   Index 3 - refund(payment_id)
   ========================================================= */

-- Before index
EXPLAIN ANALYZE
SELECT r.refund_id, r.amount, p.amount AS payment_amount
FROM refund r
JOIN payment p
    ON r.payment_id = p.payment_id
WHERE r.payment_id IS NOT NULL;

-- Create index
CREATE INDEX idx_refund_payment_id
ON refund(payment_id);

-- After index
EXPLAIN ANALYZE
SELECT r.refund_id, r.amount, p.amount AS payment_amount
FROM refund r
JOIN payment p
    ON r.payment_id = p.payment_id
WHERE r.payment_id IS NOT NULL;