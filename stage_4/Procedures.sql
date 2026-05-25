-- ==========================================
-- Stage 4: PostgreSQL Procedures
-- Stored procedures for complex operations
-- ==========================================

-- ==========================================
-- Procedure 1: Process Refund Request
-- 
-- Purpose: Process a refund for a payment with full validation,
-- exception handling, and DML operations (INSERT, UPDATE)
-- Demonstrates: RECORD variable, IF conditions, exception handling, DML
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_process_refund(
    p_payment_id INT,
    p_refund_amount NUMERIC(10,2),
    p_refund_reason VARCHAR(255),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_payment_record RECORD;
    v_payment_status VARCHAR(30);
    v_invoice_id INT;
    v_new_refund_id INT;
    v_existing_refund_amount NUMERIC(10,2) := 0;
BEGIN
    -- Initialize variables
    p_success := FALSE;
    p_message := 'Refund processing started';
    
    -- Select payment details using implicit cursor (SELECT INTO)
    SELECT payment_id, invoice_id, amount, payment_status
    INTO v_payment_record.payment_id, v_payment_record.invoice_id, 
         v_payment_record.amount, v_payment_status
    FROM PAYMENT
    WHERE payment_id = p_payment_id;
    
    -- Check if payment exists
    IF v_payment_record.payment_id IS NULL THEN
        p_message := 'Error: Payment not found';
        RETURN;
    END IF;
    
    -- Validate refund amount
    IF p_refund_amount <= 0 THEN
        p_message := 'Error: Refund amount must be greater than zero';
        RETURN;
    END IF;
    
    -- Check if refund does not exceed payment amount
    IF p_refund_amount > v_payment_record.amount THEN
        p_message := 'Error: Refund amount exceeds payment amount of ' || v_payment_record.amount;
        RETURN;
    END IF;
    
    -- Calculate existing refund amounts
    SELECT COALESCE(SUM(amount), 0)
    INTO v_existing_refund_amount
    FROM REFUND
    WHERE payment_id = p_payment_id;
    
    -- Check if total refunds do not exceed payment
    IF (v_existing_refund_amount + p_refund_amount) > v_payment_record.amount THEN
        p_message := 'Error: Total refunds cannot exceed payment amount';
        RETURN;
    END IF;
    
    BEGIN
        -- Generate new refund ID
        SELECT COALESCE(MAX(refund_id), 0) + 1
        INTO v_new_refund_id
        FROM REFUND;
        
        -- DML: Insert new refund record
        INSERT INTO REFUND (
            refund_id, 
            payment_id, 
            refund_date, 
            amount, 
            refund_reason
        )
        VALUES (
            v_new_refund_id,
            p_payment_id,
            CURRENT_DATE,
            p_refund_amount,
            p_refund_reason
        );
        
        -- DML: Update payment status to refunded
        UPDATE PAYMENT
        SET payment_status = 'Refunded'
        WHERE payment_id = p_payment_id;
        
        -- DML: Update invoice processing status
        UPDATE INVOICE
        SET processing_status = 'Completed'
        WHERE invoice_id = v_payment_record.invoice_id
          AND processing_status = 'Pending';
        
        p_success := TRUE;
        p_message := 'Refund processed successfully. Refund ID: ' || v_new_refund_id;
        
    EXCEPTION
        WHEN unique_violation THEN
            -- Handle unique constraint violation
            p_message := 'Error: Refund ID already exists';
        WHEN foreign_key_violation THEN
            -- Handle foreign key violation
            p_message := 'Error: Payment or invoice reference invalid';
        WHEN check_violation THEN
            -- Handle check constraint violation
            p_message := 'Error: Data violates check constraints';
        WHEN OTHERS THEN
            -- Handle other exceptions
            p_message := 'Unexpected error: ' || SQLERRM;
    END;

END;
$$;

-- ==========================================
-- Procedure 2: Update Insurance Claim Status
-- 
-- Purpose: Update insurance claim status with loop through related invoices
-- Demonstrates: explicit cursor, loop, IF conditions, exception handling, DML
-- ==========================================
CREATE OR REPLACE PROCEDURE sp_update_insurance_claim_status(
    p_claim_id INT,
    p_new_status VARCHAR(30),
    p_processing_staff_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(500),
    OUT p_updated_invoices INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_claim_record RECORD;
    v_invoice_cursor CURSOR FOR
        SELECT DISTINCT ic.invoice_id, i.total_amount, i.processing_status
        FROM INSURANCE_CLAIM ic
        INNER JOIN INVOICE i ON ic.invoice_id = i.invoice_id
        WHERE ic.claim_id = p_claim_id;
    v_invoice_rec RECORD;
    v_invoice_count INT := 0;
BEGIN
    -- Initialize variables
    p_success := FALSE;
    p_message := 'Claim status update started';
    p_updated_invoices := 0;
    
    -- Validate claim status
    IF p_new_status NOT IN ('Pending', 'Approved', 'Rejected', 'Partially Approved') THEN
        p_message := 'Error: Invalid claim status. Must be: Pending, Approved, Rejected, or Partially Approved';
        RETURN;
    END IF;
    
    -- Select claim details using implicit cursor (SELECT INTO)
    SELECT claim_id, invoice_id, claim_status
    INTO v_claim_record
    FROM INSURANCE_CLAIM
    WHERE claim_id = p_claim_id;
    
    -- Check if claim exists
    IF v_claim_record.claim_id IS NULL THEN
        p_message := 'Error: Claim not found';
        RETURN;
    END IF;
    
    BEGIN
        -- DML: Update claim status
        UPDATE INSURANCE_CLAIM
        SET claim_status = p_new_status,
            claim_processed_date = CURRENT_DATE
        WHERE claim_id = p_claim_id;
        
        -- Loop through all related invoices using explicit cursor
        OPEN v_invoice_cursor;
        LOOP
            FETCH v_invoice_cursor INTO v_invoice_rec;
            EXIT WHEN NOT FOUND;
            
            -- Update invoice status based on claim status
            IF p_new_status = 'Approved' THEN
                UPDATE INVOICE
                SET processing_status = 'Completed',
                    processed_date = CURRENT_DATE,
                    processing_staff_id = p_processing_staff_id
                WHERE invoice_id = v_invoice_rec.invoice_id;
                
            ELSIF p_new_status = 'Rejected' THEN
                UPDATE INVOICE
                SET processing_status = 'Failed',
                    processed_date = CURRENT_DATE,
                    processing_staff_id = p_processing_staff_id
                WHERE invoice_id = v_invoice_rec.invoice_id;
                
            ELSIF p_new_status = 'Partially Approved' THEN
                UPDATE INVOICE
                SET processing_status = 'Processing',
                    processing_staff_id = p_processing_staff_id
                WHERE invoice_id = v_invoice_rec.invoice_id;
            END IF;
            
            -- Increment updated invoices counter
            p_updated_invoices := p_updated_invoices + 1;
            
        END LOOP;
        CLOSE v_invoice_cursor;
        
        p_success := TRUE;
        p_message := 'Claim status updated successfully. Processed ' || p_updated_invoices || ' invoice(s)';
        
    EXCEPTION
        WHEN check_violation THEN
            -- Handle check constraint violation
            p_message := 'Error: Invalid status value';
        WHEN foreign_key_violation THEN
            -- Handle foreign key violation
            p_message := 'Error: Invalid staff ID or other reference';
        WHEN OTHERS THEN
            -- Handle other exceptions
            p_message := 'Unexpected error: ' || SQLERRM;
    END;

END;
$$;

COMMIT;
