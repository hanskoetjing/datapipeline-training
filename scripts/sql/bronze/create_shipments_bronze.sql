CREATE TABLE bronze.shipments (
    shipment_id VARCHAR(255),
    order_id VARCHAR(255),
    courier VARCHAR(255),
    shipped_date VARCHAR(255),
    delivered_date VARCHAR(255),
    status VARCHAR(255),
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION bronze.insert_shipments_silver_func() 
RETURNS trigger as $insert_shipments_silver_trig$
    BEGIN
        BEGIN
            INSERT INTO silver.shipments (
                shipment_id, 
                order_id, 
                courier, 
                shipped_date, 
                delivered_date, 
                status, 
                modified
            )
            VALUES (
                TRIM(NEW.shipment_id), 
                TRIM(NEW.order_id), 
                TRIM(NEW.courier), 
                CAST(NULLIF(TRANSLATE(TRIM(NEW.shipped_date), '/\-', '-'), '') AS DATE), 
                CAST(NULLIF(TRANSLATE(TRIM(NEW.delivered_date),'/\-', '-'), '') AS DATE), 
                TRIM(NEW.status), 
                NEW.modified
            );
        EXCEPTION 
            WHEN OTHERS THEN
                INSERT INTO bronze.rejected_data (table_name, raw_data, error_message)
                VALUES (
                    'bronze.shipments',
                    CAST(ROW_TO_JSON(NEW) AS TEXT), 
                    SQLERRM
                );
        END;
        
        RETURN NULL;
    END;
$insert_shipments_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_shipments_silver_trig 
    AFTER INSERT ON bronze.shipments
    FOR EACH ROW 
    EXECUTE FUNCTION bronze.insert_shipments_silver_func();