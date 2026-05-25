-- ==========================================
-- Stage 4: Main Program Orchestration
-- Integration of functions, procedures, and triggers
-- ==========================================

-- ==========================================
-- Main Program 1: Process Refund with Balance Calculation
-- 
-- Purpose: Demonstrate integrated refund processing workflow
-- Calls: fn_calculate_invoice_balance() and sp_process_refund()
-- Demonstrates: loops, IF conditions, function calls, procedure calls
-- ==========================================
DO $$
DECLARE
    v_invoice_id INT;
    v_payment_id INT;
    v_refund_amount NUMERIC(10,2) := 50.00;
    v_refund_reason VARCHAR(255) := 'Product defect - customer complaint';
    v_remaining_balance NUMERIC(10,2);
    v_refund_success BOOLEAN;
    v_refund_message VARCHAR(500);
    v_counter INT := 0;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Main Program 1: Refund Processing Flow';
    RAISE NOTICE '========================================';
    
    -- Loop through invoices with payments using implicit cursor
    FOR v_invoice_id IN 
        SELECT DISTINCT i.invoice_id
        FROM INVOICE i
        INNER JOIN PAYMENT p ON i.invoice_id = p.invoice_id
        LIMIT 3
    LOOP
        v_counter := v_counter + 1;
        
        RAISE NOTICE '';
        RAISE NOTICE 'Processing Invoice: %', v_invoice_id;
        
        -- Call Function 1: Calculate invoice balance
        v_remaining_balance := fn_calculate_invoice_balance(v_invoice_id);
        RAISE NOTICE 'Remaining Balance: %.2f', v_remaining_balance;
        
        -- Get first payment for this invoice
        SELECT payment_id INTO v_payment_id
        FROM PAYMENT
        WHERE invoice_id = v_invoice_id
        LIMIT 1;
        
        -- Check if payment exists and balance is positive
        IF v_payment_id IS NOT NULL AND v_remaining_balance > 0 THEN
            -- Call Procedure 1: Process refund
            CALL sp_process_refund(
                v_payment_id,
                LEAST(v_refund_amount, v_remaining_balance),
                v_refund_reason,
                v_refund_success,
                v_refund_message
            );
            
            RAISE NOTICE 'Refund Result: %', v_refund_message;
            
            -- Check refund success
            IF v_refund_success THEN
                RAISE NOTICE 'Refund processed successfully';
            END IF;
        END IF;
        
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Main Program 1 Completed - Processed % invoices', v_counter;
    RAISE NOTICE '========================================';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in Main Program 1: %', SQLERRM;
END;
$$;

-- ==========================================
-- Main Program 2: Validate and Update Claims
-- 
-- Purpose: Demonstrate integrated payment validation and claim updates
-- Calls: fn_validate_payment_amount() and sp_update_insurance_claim_status()
-- Demonstrates: explicit cursor, loop, IF conditions, function and procedure calls
-- ==========================================
DO $$
DECLARE
    v_claim_id INT;
    v_invoice_id INT;
    v_payment_id INT;
    v_new_status VARCHAR(30) := 'Approved';
    v_staff_id INT := 1;
    v_validation_result RECORD;
    v_update_success BOOLEAN;
    v_update_message VARCHAR(500);
    v_updated_count INT;
    v_payment_amount NUMERIC(10,2) := 100.00;
    v_counter INT := 0;
    
    -- Explicit cursor for insurance claims
    v_claim_cursor CURSOR FOR
        SELECT ic.claim_id, ic.invoice_id, ic.claim_status
        FROM INSURANCE_CLAIM ic
        WHERE ic.claim_status = 'Pending'
        LIMIT 3;
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Main Program 2: Payment Validation & Claim Update';
    RAISE NOTICE '========================================';
    
    -- Loop through pending claims using explicit cursor
    OPEN v_claim_cursor;
    LOOP
        FETCH v_claim_cursor INTO v_claim_id, v_invoice_id, v_new_status;
        EXIT WHEN NOT FOUND;
        
        v_counter := v_counter + 1;
        
        RAISE NOTICE '';
        RAISE NOTICE 'Processing Claim: %', v_claim_id;
        
        -- Get first payment for this invoice
        SELECT payment_id INTO v_payment_id
        FROM PAYMENT
        WHERE invoice_id = v_invoice_id
        LIMIT 1;
        
        -- Check if payment exists
        IF v_payment_id IS NOT NULL THEN
            -- Call Function 2: Validate payment amount
            v_validation_result := (SELECT * FROM fn_validate_payment_amount(v_invoice_id, v_payment_amount));
            
            RAISE NOTICE 'Validation - Valid: %, Message: %', 
                v_validation_result.is_valid, 
                v_validation_result.validation_message;
            
            RAISE NOTICE 'Invoice Total: %.2f, Balance: %.2f', 
                v_validation_result.invoice_total,
                v_validation_result.remaining_balance;
            
            -- Determine claim status based on validation
            IF v_validation_result.is_valid THEN
                v_new_status := 'Approved';
            ELSE
                v_new_status := 'Rejected';
            END IF;
        ELSE
            v_new_status := 'Pending';
        END IF;
        
        -- Call Procedure 2: Update claim status
        CALL sp_update_insurance_claim_status(
            v_claim_id,
            v_new_status,
            v_staff_id,
            v_update_success,
            v_update_message,
            v_updated_count
        );
        
        RAISE NOTICE 'Claim Update Result: %', v_update_message;
        RAISE NOTICE 'Updated Invoices: %', v_updated_count;
        
    END LOOP;
    CLOSE v_claim_cursor;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Main Program 2 Completed - Processed % claims', v_counter;
    RAISE NOTICE '========================================';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error in Main Program 2: %', SQLERRM;
END;
$$;

-- ==========================================
-- Test 1: Show invoice balances using Function 1
-- ==========================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Test Results - Invoice Balances';
    RAISE NOTICE '========================================';
END;
$$;

SELECT 
    i.invoice_id,
    i.total_amount,
    fn_calculate_invoice_balance(i.invoice_id) AS remaining_balance,
    i.processing_status,
    COUNT(p.payment_id) AS payment_count
FROM INVOICE i
LEFT JOIN PAYMENT p ON i.invoice_id = p.invoice_id
GROUP BY i.invoice_id, i.total_amount, i.processing_status
ORDER BY i.invoice_id
LIMIT 10;

-- ==========================================
-- Test 2: Show payment audit logs
-- ==========================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Test Results - Payment Audit Logs';
    RAISE NOTICE '========================================';
END;
$$;

SELECT 
    pa.audit_id,
    pa.payment_id,
    pa.invoice_id,
    pa.amount,
    pa.action,
    pa.action_timestamp,
    pa.action_user
FROM PAYMENT_AUDIT pa
ORDER BY pa.action_timestamp DESC
LIMIT 10;

-- ==========================================
-- Test 3: Show refund history
-- ==========================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Test Results - Refund History';
    RAISE NOTICE '========================================';
END;
$$;

SELECT 
    r.refund_id,
    r.payment_id,
    p.invoice_id,
    r.amount,
    r.refund_date,
    r.refund_reason,
    p.payment_method
FROM REFUND r
INNER JOIN PAYMENT p ON r.payment_id = p.payment_id
ORDER BY r.refund_date DESC
LIMIT 10;

-- ==========================================
-- Test 4: Show insurance claims with processing status
-- ==========================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Test Results - Insurance Claims';
    RAISE NOTICE '========================================';
END;
$$;

SELECT 
    ic.claim_id,
    ic.invoice_id,
    ic.insurance_id,
    ic.claim_status,
    ic.claim_date,
    ic.claim_processed_date,
    i.processing_status,
    i.total_amount
FROM INSURANCE_CLAIM ic
INNER JOIN INVOICE i ON ic.invoice_id = i.invoice_id
ORDER BY ic.claim_id
LIMIT 10;

-- ==========================================
-- Test 5: Show invoice processing summary
-- ==========================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Test Results - Invoice Processing Summary';
    RAISE NOTICE '========================================';
END;
$$;

SELECT 
    i.processing_status,
    COUNT(*) AS invoice_count,
    SUM(i.total_amount) AS total_amount,
    COUNT(p.payment_id) AS payment_count,
    COALESCE(SUM(r.amount), 0) AS total_refunded
FROM INVOICE i
LEFT JOIN PAYMENT p ON i.invoice_id = p.invoice_id
LEFT JOIN REFUND r ON p.payment_id = r.payment_id
GROUP BY i.processing_status
ORDER BY i.processing_status;

COMMIT;
