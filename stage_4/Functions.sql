CREATE OR REPLACE FUNCTION fn_calculate_invoice_balance(p_invoice_id INT)
RETURNS NUMERIC(10,2) AS $$
DECLARE
    v_invoice_total NUMERIC(10,2);
    v_total_payments NUMERIC(10,2) := 0;
    v_total_refunds NUMERIC(10,2) := 0;
    v_payment_rec RECORD;
    v_refund_rec RECORD;
    v_payment_cursor CURSOR FOR
        SELECT payment_id, amount
        FROM PAYMENT
        WHERE invoice_id = p_invoice_id;
    v_refund_cursor CURSOR FOR
        SELECT r.refund_id, r.amount
        FROM REFUND r
        JOIN PAYMENT p ON r.payment_id = p.payment_id
        WHERE p.invoice_id = p_invoice_id;
BEGIN
    SELECT total_amount
    INTO v_invoice_total
    FROM INVOICE
    WHERE invoice_id = p_invoice_id;

    IF NOT FOUND THEN
        RETURN 0;
    END IF;

    OPEN v_payment_cursor;
    LOOP
        FETCH v_payment_cursor INTO v_payment_rec;
        EXIT WHEN NOT FOUND;
        v_total_payments := v_total_payments + COALESCE(v_payment_rec.amount, 0);
    END LOOP;
    CLOSE v_payment_cursor;

    OPEN v_refund_cursor;
    LOOP
        FETCH v_refund_cursor INTO v_refund_rec;
        EXIT WHEN NOT FOUND;
        v_total_refunds := v_total_refunds + COALESCE(v_refund_rec.amount, 0);
    END LOOP;
    CLOSE v_refund_cursor;

    RETURN v_invoice_total - (v_total_payments - v_total_refunds);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error calculating invoice balance: %', SQLERRM;
        RETURN -1;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fn_validate_payment_amount(
    p_invoice_id INT,
    p_payment_amount NUMERIC(10,2)
)
RETURNS TABLE (
    is_valid BOOLEAN,
    validation_message VARCHAR(255),
    invoice_total NUMERIC(10,2),
    remaining_balance NUMERIC(10,2)
) AS $$
DECLARE
    v_invoice_record RECORD;
    v_balance NUMERIC(10,2);
BEGIN
    SELECT invoice_id, total_amount, processing_status
    INTO v_invoice_record
    FROM INVOICE
    WHERE invoice_id = p_invoice_id;

    IF NOT FOUND THEN
        RETURN QUERY
        SELECT FALSE, 'Invoice not found'::VARCHAR(255), 0::NUMERIC(10,2), 0::NUMERIC(10,2);
        RETURN;
    END IF;

    v_balance := fn_calculate_invoice_balance(p_invoice_id);

    IF p_payment_amount <= 0 THEN
        RETURN QUERY
        SELECT FALSE, 'Payment amount must be greater than zero'::VARCHAR(255),
               v_invoice_record.total_amount, v_balance;
        RETURN;
    END IF;

    IF p_payment_amount > v_balance THEN
        RETURN QUERY
        SELECT FALSE, 'Payment amount exceeds remaining balance'::VARCHAR(255),
               v_invoice_record.total_amount, v_balance;
        RETURN;
    END IF;

    IF v_invoice_record.processing_status = 'Failed' THEN
        RETURN QUERY
        SELECT FALSE, 'Cannot process payment for failed invoice'::VARCHAR(255),
               v_invoice_record.total_amount, v_balance;
        RETURN;
    END IF;

    RETURN QUERY
    SELECT TRUE, 'Valid payment'::VARCHAR(255),
           v_invoice_record.total_amount, v_balance;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error validating payment amount: %', SQLERRM;
        RETURN QUERY
        SELECT FALSE, ('Error: ' || SQLERRM)::VARCHAR(255),
               0::NUMERIC(10,2), 0::NUMERIC(10,2);
END;
$$ LANGUAGE plpgsql;