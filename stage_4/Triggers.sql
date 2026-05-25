-- ==========================================
-- Stage 4: PostgreSQL Triggers
-- Trigger definitions for automated actions
-- ==========================================

-- ==========================================
-- Trigger 1: Audit Trigger on PAYMENT INSERT
-- 
-- Purpose: Log all payments when inserted
-- Demonstrates: trigger on INSERT, RECORD variable, DML (INSERT)
-- ==========================================

-- Create audit table for logging payments
CREATE TABLE IF NOT EXISTS PAYMENT_AUDIT (
    audit_id SERIAL PRIMARY KEY,
    payment_id INT NOT NULL,
    invoice_id INT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30),
    action VARCHAR(20) NOT NULL,
    action_timestamp TIMESTAMP NOT NULL,
    action_user VARCHAR(100)
);

COMMENT ON TABLE PAYMENT_AUDIT IS 'Audit log for payment transactions';

-- Create trigger function for payment insert
CREATE OR REPLACE FUNCTION fn_audit_payment_insert()
RETURNS TRIGGER AS $$
DECLARE
    v_current_user VARCHAR(100);
BEGIN
    -- Get current user name
    v_current_user := COALESCE(current_user, 'system');
    
    -- DML: Insert audit record
    INSERT INTO PAYMENT_AUDIT (
        payment_id,
        invoice_id,
        amount,
        payment_date,
        payment_method,
        action,
        action_timestamp,
        action_user
    )
    VALUES (
        NEW.payment_id,
        NEW.invoice_id,
        NEW.amount,
        NEW.payment_date,
        NEW.payment_method,
        'INSERT',
        NOW(),
        v_current_user
    );
    
    -- Return the new record
    RETURN NEW;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Print error message
        RAISE NOTICE 'Error in payment audit trigger: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger on INSERT
CREATE TRIGGER tr_audit_payment_insert
AFTER INSERT ON PAYMENT
FOR EACH ROW
EXECUTE FUNCTION fn_audit_payment_insert();

-- ==========================================
-- Trigger 2: Update Trigger on INVOICE
-- 
-- Purpose: Update payment status when invoice is updated
-- Demonstrates: trigger on UPDATE, explicit cursor, loop, IF conditions, DML (UPDATE)
-- ==========================================

-- Create trigger function for invoice update
CREATE OR REPLACE FUNCTION fn_update_invoice_payment_status()
RETURNS TRIGGER AS $$
DECLARE
    v_invoice_balance NUMERIC(10,2);
    v_payment_cursor CURSOR FOR
        SELECT payment_id FROM PAYMENT
        WHERE invoice_id = NEW.invoice_id;
    v_payment_id INT;
BEGIN
    -- Check if processing status changed to 'Completed'
    IF OLD.processing_status IS DISTINCT FROM NEW.processing_status 
       AND NEW.processing_status = 'Completed' THEN
        
        -- Calculate invoice balance
        v_invoice_balance := fn_calculate_invoice_balance(NEW.invoice_id);
        
        -- Check if balance is zero
        IF v_invoice_balance <= 0 THEN
            -- Loop through payments and update status to completed
            OPEN v_payment_cursor;
            LOOP
                FETCH v_payment_cursor INTO v_payment_id;
                EXIT WHEN NOT FOUND;
                
                -- DML: Update payment status
                UPDATE PAYMENT
                SET payment_status = 'Completed'
                WHERE payment_id = v_payment_id;
            END LOOP;
            CLOSE v_payment_cursor;
            
        END IF;
    END IF;
    
    -- Check if status changed to 'Failed'
    IF OLD.processing_status IS DISTINCT FROM NEW.processing_status 
       AND NEW.processing_status = 'Failed' THEN
        
        -- DML: Update related payments to reflect failure
        UPDATE PAYMENT
        SET payment_status = 'Failed'
        WHERE invoice_id = NEW.invoice_id
          AND payment_status = 'Pending';
    END IF;
    
    -- Return the updated record
    RETURN NEW;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Print error message
        RAISE NOTICE 'Error in invoice update trigger: %', SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger on UPDATE
CREATE TRIGGER tr_update_invoice_status
AFTER UPDATE ON INVOICE
FOR EACH ROW
EXECUTE FUNCTION fn_update_invoice_payment_status();

COMMIT;
