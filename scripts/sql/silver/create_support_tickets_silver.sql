CREATE TABLE silver.support_tickets (
    ticket_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(6),
    order_id VARCHAR(10),
    issue_type VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION silver.check_data_support_tickets_silver_func() 
RETURNS trigger as $check_data_support_tickets_silver_trig$
    DECLARE e silver.support_tickets%ROWTYPE;
    BEGIN
        SELECT * INTO e FROM silver.support_tickets WHERE ticket_id = NEW.ticket_id;
        
        IF NOT FOUND THEN 
            RETURN NEW;
        ELSE 
            -- Jika data baru lebih segar, lakukan update
            IF e.modified < NEW.modified THEN
                UPDATE silver.support_tickets SET
                    customer_id = NEW.customer_id,
                    order_id = NEW.order_id,
                    issue_type = NEW.issue_type,
                    status = NEW.status,
                    created_at = NEW.created_at,
                    modified = NEW.modified
                WHERE ticket_id = e.ticket_id;
            END IF;
            RETURN NULL;
        END IF;
    END;
$check_data_support_tickets_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_support_tickets_silver_trig 
    BEFORE INSERT ON silver.support_tickets
    FOR EACH ROW EXECUTE FUNCTION silver.check_data_support_tickets_silver_func();