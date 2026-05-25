-- ==========================================
-- Stage 4: PostgreSQL Functions
-- Functions for business logic and data operations
-- ==========================================

-- ==========================================
-- Function 1: Calculate Invoice Balance
-- 
-- Purpose: Calculate remaining balance for an invoice
-- using explicit cursor to loop through all payments and refunds
-- Demonstrates: explicit cursor, loop, RECORD variable, exception handling
-- ==========================================
CREATE OR REPLACE FUNCTION fn_calculate_invoice_balance(
    p_invoice_id INT
)
RETURNS NUMERIC(10,2) AS $$
DECLARE
    v_invoice_total NUMERIC(10,2);
    v_total_payments NUMERIC(10,2) := 0;
    v_total_refunds NUMERIC(10,2) := 0;
    v_payment_rec RECORD;
    v_refund_rec RECORD;
    v_payment_cursor CURSOR FOR 
        SELECT payment_id, amount FROM PAYMENT WHERE invoice_id = p_invoice_id;
    v_refund_cursor CURSOR FOR 
        SELECT r.refund_id, r.amount 
        FROM REFUND r
        INNER JOIN PAYMENT p ON r.payment_id = p.payment_id
        WHERE p.invoice_id = p_invoice_id;
BEGIN
    -- Select the total invoice amount
    SELECT total_amount INTO v_invoice_total
    FROM INVOICE
    WHERE invoice_id = p_invoice_id;
    
    -- Handle invoice not found
    IF v_invoice_total IS NULL THEN
        RAISE NOTICE 'Invoice % not found', p_invoice_id;
        RETURN 0;
    END IF;
    
    -- Loop through all payments using explicit cursor
    OPEN v_payment_cursor;
    LOOP
        FETCH v_payment_cursor INTO v_payment_rec;
        EXIT WHEN NOT FOUND;
        
        -- Add to total payments
        v_total_payments := v_total_payments + v_payment_rec.amount;
    END LOOP;
    CLOSE v_payment_cursor;
    
    -- Loop through all refunds using explicit cursor
    OPEN v_refund_cursor;
    LOOP
        FETCH v_refund_cursor INTO v_refund_rec;
        EXIT WHEN NOT FOUND;
        
        -- Add to total refunds
        v_total_refunds := v_total_refunds + v_refund_rec.amount;
    END LOOP;
    CLOSE v_refund_cursor;
    
    -- Calculate remaining balance
    RETURN v_invoice_total - (v_total_payments - v_total_refunds);
    
EXCEPTION
    WHEN OTHERS THEN
        -- Exception handling
        RAISE NOTICE 'Error calculating balance for invoice %: %', p_invoice_id, SQLERRM;
        RETURN -1;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- Function 2: Validate Payment Amount
-- 
-- Purpose: Validate if payment amount is within acceptable range for invoice
-- Demonstrates: RECORD variable, IF conditions, implicit cursor (SELECT INTO)
-- ==========================================
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
    v_is_valid BOOLEAN := TRUE;
    v_message VARCHAR(255) := 'Valid payment';
BEGIN
    -- Select invoice record using implicit cursor (SELECT INTO)
    SELECT invoice_id, total_amount, processing_status
    INTO v_invoice_record
    FROM INVOICE
    WHERE invoice_id = p_invoice_id;
    
    -- Check if invoice exists
    IF v_invoice_record IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Invoice not found', 0::NUMERIC(10,2), 0::NUMERIC(10,2);
        RETURN;
    END IF;
    
    -- Calculate remaining balance by calling Function 1
    v_balance := fn_calculate_invoice_balance(p_invoice_id);
    
    -- Check if amount is positive
    IF p_payment_amount <= 0 THEN
        v_is_valid := FALSE;
        v_message := 'Payment amount must be greater than zero';
    END IF;
    
    -- Check if amount exceeds remaining balance
    IF v_is_valid AND p_payment_amount > v_balance THEN
        v_is_valid := FALSE;
        v_message := 'Payment amount exceeds remaining balance';
    END IF;
    
    -- Check if invoice status allows payment processing
    IF v_is_valid AND v_invoice_record.processing_status = 'Failed' THEN
        v_is_valid := FALSE;
        v_message := 'Cannot process payment for failed invoice';
    END IF;
    
    -- Return validation result
    RETURN QUERY SELECT v_is_valid, v_message, v_invoice_record.total_amount, v_balance;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Exception handling
        RAISE NOTICE 'Error validating payment for invoice %: %', p_invoice_id, SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0::NUMERIC(10,2), 0::NUMERIC(10,2);
END;
$$ LANGUAGE plpgsql;

COMMIT;
        -- English: Exception handling
        RAISE NOTICE 'Error validating payment for invoice %: %', p_invoice_id, SQLERRM;
        RETURN QUERY SELECT FALSE, 'Error: ' || SQLERRM, 0::NUMERIC(10,2), 0::NUMERIC(10,2);
END;
$$ LANGUAGE plpgsql;

COMMIT;
