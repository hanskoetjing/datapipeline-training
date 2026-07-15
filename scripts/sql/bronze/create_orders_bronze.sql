CREATE TABLE bronze.orders (
    order_id VARCHAR(100),
    customer_id VARCHAR(100),
    store_id VARCHAR(100),
    order_date VARCHAR(100),
    payment_method VARCHAR(100),
    status VARCHAR(100),
    
    -- Field modified tanpa timezone
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION bronze.insert_orders_silver() RETURNS trigger as $insert_orders_silver_trig$
    BEGIN
        BEGIN
            INSERT INTO silver.orders (
                order_id, 
                customer_id, 
                store_id, 
                order_date, 
                payment_method, 
                status, 
                modified
                )
            VALUES (
                TRIM(NEW.order_id), 
                TRIM(NEW.customer_id), 
                TRIM(NEW.store_id), 
                CAST(TO_TIMESTAMP(TRIM(NEW.order_date), 'YYYY-MM-DD HH24:MI:SS') AS TIMESTAMP), 
                TRIM(NEW.payment_method), 
                TRIM(NEW.status),
                NEW.modified
                );
            EXCEPTION
                WHEN OTHERS THEN
                    INSERT INTO bronze.rejected_data (
                        table_name, 
                        raw_data, 
                        error_message
                    )
                    VALUES (
                        'silver.orders',
                        CAST(ROW_TO_JSON(NEW) AS TEXT), 
                        SQLERRM 
                    );
                END;
        RETURN NULL;
	END;
$insert_orders_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_orders_silver_trig AFTER INSERT ON bronze.orders
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_orders_silver();
