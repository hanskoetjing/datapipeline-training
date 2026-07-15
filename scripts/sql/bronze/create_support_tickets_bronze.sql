CREATE TABLE bronze.support_tickets (
    ticket_id VARCHAR(255),
    customer_id VARCHAR(255),
    order_id VARCHAR(255),
    issue_type VARCHAR(255),
    status VARCHAR(255),
    created_at VARCHAR(255),
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION bronze.insert_support_tickets_silver_func() 
RETURNS trigger as $insert_support_tickets_silver_trig$
    BEGIN
        BEGIN
            INSERT INTO silver.support_tickets (
                ticket_id, 
                customer_id, 
                order_id, 
                issue_type, 
                status, 
                created_at, 
                modified
            )
            VALUES (
                TRIM(NEW.ticket_id), 
                TRIM(NEW.customer_id), 
                TRIM(NEW.order_id), 
                TRIM(NEW.issue_type), 
                TRIM(NEW.status), 
                CAST(NULLIF(TRANSLATE(TRIM(NEW.created_at), '/\', '-'), '') AS TIMESTAMP), 
                NEW.modified
            );
        EXCEPTION 
            WHEN OTHERS THEN
                INSERT INTO bronze.rejected_data (table_name, raw_data, error_message)
                VALUES (
                    'bronze.support_tickets',
                    CAST(ROW_TO_JSON(NEW) AS TEXT), 
                    SQLERRM
                );
        END;
        
        RETURN NULL;
    END;
$insert_support_tickets_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_support_tickets_silver_trig 
    AFTER INSERT ON bronze.support_tickets
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_support_tickets_silver_func();