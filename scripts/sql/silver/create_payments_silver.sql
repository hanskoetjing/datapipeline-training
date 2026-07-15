CREATE TABLE silver.payments (
    payment_id VARCHAR(10) PRIMARY KEY,
    order_id VARCHAR(10) NOT NULL,
    method VARCHAR(10) NOT NULL,
    amount NUMERIC(15,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    paid_at TIMESTAMP NOT NULL,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE silver.payments ADD CONSTRAINT payments_unique UNIQUE (order_id, payment_id);

CREATE OR REPLACE FUNCTION silver.check_data_payments_silver_func() 
RETURNS trigger as $check_data_payments_silver_trig$
    DECLARE e silver.payments%ROWTYPE;
    BEGIN
        SELECT * INTO e FROM silver.payments 
        WHERE payment_id = NEW.payment_id 
           OR (order_id = NEW.order_id AND payment_id = NEW.payment_id);
        
        IF NOT FOUND THEN 
            RETURN NEW;
        ELSE 
            IF e.modified < NEW.modified THEN
                UPDATE silver.payments SET
                    payment_id = NEW.payment_id,
                    order_id = NEW.order_id,
                    method = NEW.method,
                    amount = NEW.amount,
                    status = NEW.status,
                    paid_at = NEW.paid_at,
                    modified = NEW.modified
                WHERE payment_id = e.payment_id;
            END IF;
            RETURN NULL;
        END IF;
    END;
$check_data_payments_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_payments_silver_trig 
    BEFORE INSERT ON silver.payments
    FOR EACH ROW 
    EXECUTE FUNCTION silver.check_data_payments_silver_func();