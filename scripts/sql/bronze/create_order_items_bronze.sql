CREATE TABLE bronze.order_items (    
    order_item_id VARCHAR(255),
    order_id VARCHAR(255),
    product_id VARCHAR(255),
    quantity VARCHAR(255),
    unit_price VARCHAR(255),
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
);

CREATE OR REPLACE FUNCTION bronze.insert_order_items_silver_func() 
RETURNS trigger as $insert_order_items_silver_trig$
    BEGIN
        BEGIN
            INSERT INTO silver.order_items (
                order_item_id, 
                order_id, 
                product_id, 
                quantity, 
                unit_price, 
                modified
            )
            VALUES (
                TRIM(NEW.order_item_id), 
                TRIM(NEW.order_id), 
                TRIM(NEW.product_id), 
                CAST(TRIM(NEW.quantity) AS NUMERIC(15,2)), 
                CAST(TRIM(NEW.unit_price) AS NUMERIC(15, 2)), 
                NEW.modified
            );
        EXCEPTION 
            WHEN OTHERS THEN
                INSERT INTO bronze.rejected_data (table_name, raw_data, error_message)
                VALUES (
                    'bronze.order_items',
                    CAST(ROW_TO_JSON(NEW) AS TEXT), 
                    SQLERRM
                );
        END;
        
        RETURN NULL;
    END;
$insert_order_items_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_order_items_silver_trig 
    AFTER INSERT ON bronze.order_items
    FOR EACH ROW 
    EXECUTE FUNCTION bronze.insert_order_items_silver_func();