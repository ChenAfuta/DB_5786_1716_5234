/* =========================================================
   MedBill Pro - Stage 2 - Queries.sql
   ========================================================= */


/* =========================================================
   SELECT QUERIES
   ========================================================= */


/* ---------------------------------------------------------
   Query 1A
   Screen: Payments & Refunds
   Purpose: Show payments with invoice details
   --------------------------------------------------------- */
SELECT 
    p.payment_id,
    p.payment_date,
    p.amount AS payment_amount,
    p.payment_method,
    i.invoice_id,
    i.invoice_date,
    i.total_amount AS invoice_total
FROM payment p
JOIN invoice i
    ON p.invoice_id = i.invoice_id
ORDER BY p.payment_date DESC;


/* ---------------------------------------------------------
   Query 1B
   Same purpose using subquery
   --------------------------------------------------------- */
SELECT
    p.payment_id,
    p.payment_date,
    p.amount AS payment_amount,
    p.payment_method,
    p.invoice_id,
    (
        SELECT i.invoice_date
        FROM invoice i
        WHERE i.invoice_id = p.invoice_id
    ) AS invoice_date,
    (
        SELECT i.total_amount
        FROM invoice i
        WHERE i.invoice_id = p.invoice_id
    ) AS invoice_total
FROM payment p
ORDER BY p.payment_date DESC;


/* ---------------------------------------------------------
   Query 2A
   Screen: Payments & Refunds
   Purpose: Show refunds with original payment details
   --------------------------------------------------------- */
SELECT
    r.refund_id,
    r.refund_date,
    r.amount AS refund_amount,
    r.refund_reason,
    p.payment_id,
    p.payment_date,
    p.amount AS original_payment_amount,
    p.payment_method
FROM refund r
JOIN payment p
    ON r.payment_id = p.payment_id
ORDER BY r.refund_date DESC;


/* ---------------------------------------------------------
   Query 2B
   Same purpose using subquery
   --------------------------------------------------------- */
SELECT
    r.refund_id,
    r.refund_date,
    r.amount AS refund_amount,
    r.refund_reason,
    r.payment_id,
    (
        SELECT p.payment_date
        FROM payment p
        WHERE p.payment_id = r.payment_id
    ) AS payment_date,
    (
        SELECT p.amount
        FROM payment p
        WHERE p.payment_id = r.payment_id
    ) AS original_payment_amount,
    (
        SELECT p.payment_method
        FROM payment p
        WHERE p.payment_id = r.payment_id
    ) AS payment_method
FROM refund r
ORDER BY r.refund_date DESC;


/* ---------------------------------------------------------
   Query 3A
   Screen: Financial Dashboard
   Purpose: Monthly revenue from payments
   --------------------------------------------------------- */
SELECT
    EXTRACT(YEAR FROM p.payment_date) AS payment_year,
    EXTRACT(MONTH FROM p.payment_date) AS payment_month,
    COUNT(p.payment_id) AS num_payments,
    SUM(p.amount) AS total_revenue
FROM payment p
GROUP BY
    EXTRACT(YEAR FROM p.payment_date),
    EXTRACT(MONTH FROM p.payment_date)
ORDER BY payment_year, payment_month;


/* ---------------------------------------------------------
   Query 3B
   Same purpose using DATE_TRUNC
   --------------------------------------------------------- */
SELECT
    DATE_TRUNC('month', p.payment_date) AS revenue_month,
    COUNT(p.payment_id) AS num_payments,
    SUM(p.amount) AS total_revenue
FROM payment p
GROUP BY DATE_TRUNC('month', p.payment_date)
ORDER BY revenue_month;


/* ---------------------------------------------------------
   Query 4A
   Screen: Financial Dashboard
   Purpose: Payment method distribution
   --------------------------------------------------------- */
SELECT
    p.payment_method,
    COUNT(*) AS method_count,
    SUM(p.amount) AS total_amount
FROM payment p
GROUP BY p.payment_method
ORDER BY total_amount DESC;


/* ---------------------------------------------------------
   Query 4B
   Same purpose using derived table
   --------------------------------------------------------- */
SELECT *
FROM (
    SELECT
        p.payment_method,
        COUNT(*) AS method_count,
        SUM(p.amount) AS total_amount
    FROM payment p
    GROUP BY p.payment_method
) AS payment_summary
ORDER BY total_amount DESC;


/* ---------------------------------------------------------
   Query 5
   Screen: Financial Dashboard / Reports
   Purpose: Monthly refunds summary
   --------------------------------------------------------- */
SELECT
    EXTRACT(YEAR FROM r.refund_date) AS refund_year,
    EXTRACT(MONTH FROM r.refund_date) AS refund_month,
    COUNT(r.refund_id) AS num_refunds,
    SUM(r.amount) AS total_refund_amount
FROM refund r
GROUP BY
    EXTRACT(YEAR FROM r.refund_date),
    EXTRACT(MONTH FROM r.refund_date)
ORDER BY refund_year, refund_month;


/* ---------------------------------------------------------
   Query 6A
   Screen: Financial Dashboard / Reports
   Purpose: Invoices whose total amount is above average
   --------------------------------------------------------- */
SELECT
    i.invoice_id,
    i.invoice_date,
    i.total_amount
FROM invoice i
WHERE i.total_amount > (
    SELECT AVG(total_amount)
    FROM invoice
)
ORDER BY i.total_amount DESC;


/* ---------------------------------------------------------
   Query 6B
   Same purpose using CTE
   --------------------------------------------------------- */
WITH avg_invoice AS (
    SELECT AVG(total_amount) AS avg_total
    FROM invoice
)
SELECT
    i.invoice_id,
    i.invoice_date,
    i.total_amount
FROM invoice i
CROSS JOIN avg_invoice a
WHERE i.total_amount > a.avg_total
ORDER BY i.total_amount DESC;


/* ---------------------------------------------------------
   Query 7
   Screen: Payments & Refunds / Reports
   Purpose: Show invoice items with invoice details
   --------------------------------------------------------- */
SELECT
    ii.item_id,
    ii.invoice_id,
    ii.service_name,
    ii.cost,
    i.invoice_date,
    i.total_amount
FROM invoice_item ii
JOIN invoice i
    ON ii.invoice_id = i.invoice_id
ORDER BY ii.invoice_id, ii.item_id;


/* ---------------------------------------------------------
   Query 8
   Screen: Insurance & Staff
   Purpose: Show billing staff list and roles
   --------------------------------------------------------- */
SELECT
    billing_staff_id,
    staff_id,
    role
FROM billing_staff
ORDER BY role, billing_staff_id;



/* =========================================================
   UPDATE QUERIES
   ========================================================= */


/* ---------------------------------------------------------
   Update 1
   Screen: Payments & Refunds
   Purpose: Update payment method
   --------------------------------------------------------- */
UPDATE payment
SET payment_method = 'Cash'
WHERE payment_id = (
    SELECT MIN(payment_id)
    FROM payment
);


/* ---------------------------------------------------------
   Update 2
   Screen: Insurance & Staff
   Purpose: Update a billing staff role
   --------------------------------------------------------- */
UPDATE billing_staff
SET role = 'Cashier'
WHERE billing_staff_id = (
    SELECT MIN(billing_staff_id)
    FROM billing_staff
)
AND role <> 'Cashier';


/* ---------------------------------------------------------
   Update 3
   Screen: Payments & Refunds
   Purpose: Update another payment method
   --------------------------------------------------------- */
UPDATE payment
SET payment_method = 'Bank Transfer'
WHERE payment_id = (
    SELECT MAX(payment_id)
    FROM payment
)
AND payment_method <> 'Bank Transfer';



/* =========================================================
   DELETE QUERIES
   ========================================================= */


/* ---------------------------------------------------------
   Delete 1
   Screen: Payments & Refunds
   Purpose: Delete one refund record
   --------------------------------------------------------- */
DELETE FROM refund
WHERE refund_id = (
    SELECT MIN(refund_id)
    FROM refund
);


/* ---------------------------------------------------------
   Delete 2
   Screen: Payments & Refunds
   Purpose: Delete one payment that has no related refund
   --------------------------------------------------------- */
DELETE FROM payment
WHERE payment_id = (
    SELECT MIN(p.payment_id)
    FROM payment p
    WHERE NOT EXISTS (
        SELECT 1
        FROM refund r
        WHERE r.payment_id = p.payment_id
    )
);


/* ---------------------------------------------------------
   Delete 3
   Screen: Insurance & Staff
   Purpose: Delete one billing staff row with the highest id
   --------------------------------------------------------- */
DELETE FROM billing_staff
WHERE billing_staff_id = (
    SELECT MAX(billing_staff_id)
    FROM billing_staff
);