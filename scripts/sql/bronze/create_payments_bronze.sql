CREATE TABLE bronze.payments (
    payment_id VARCHAR(255),
    order_id VARCHAR(255),
    method VARCHAR(255),
    amount VARCHAR(255),
    status VARCHAR(255),
    paid_at VARCHAR(255),
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION bronze.insert_payments_silver_func() 
RETURNS trigger as $insert_payments_silver_trig$
    BEGIN
        BEGIN
            INSERT INTO silver.payments (
                payment_id, 
                order_id, 
                method, 
                amount, 
                status, 
                paid_at, 
                modified
            )
            VALUES (
                TRIM(NEW.payment_id), 
                TRIM(NEW.order_id), 
                TRIM(NEW.method), 
                CAST(bronze.clean_numeric(TRIM(NEW.amount)) AS NUMERIC(15, 2)), 
                TRIM(NEW.status), 
                CAST(TRIM(NEW.paid_at) AS TIMESTAMP), 
                NEW.modified
            );
        EXCEPTION 
            WHEN OTHERS THEN
                INSERT INTO bronze.rejected_data (table_name, raw_data, error_message)
                VALUES (
                    'bronze.payments',
                    CAST(ROW_TO_JSON(NEW) AS TEXT), 
                    SQLERRM
                );
        END;
        
        RETURN NULL;
    END;
$insert_payments_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_payments_silver_trig 
    AFTER INSERT ON bronze.payments
    FOR EACH ROW 
    EXECUTE FUNCTION bronze.insert_payments_silver_func();