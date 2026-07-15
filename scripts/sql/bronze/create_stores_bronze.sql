CREATE TABLE bronze.stores (
    store_id VARCHAR(255),
    store_name VARCHAR(255),
    city VARCHAR(255),
    opened_date VARCHAR(255),
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION bronze.insert_stores_silver_func() 
RETURNS trigger as $insert_stores_silver_trig$
    BEGIN
        BEGIN
            INSERT INTO silver.stores (
                store_id, 
                store_name, 
                city, 
                opened_date, 
                modified
            )
            VALUES (
                TRIM(NEW.store_id), 
                TRIM(NEW.store_name), 
                TRIM(NEW.city), 
                CAST(TRIM(NEW.opened_date) AS DATE), 
                NEW.modified
            );
        EXCEPTION 
            WHEN OTHERS THEN
                INSERT INTO bronze.rejected_data (table_name, raw_data, error_message)
                VALUES (
                    'bronze.stores',
                    CAST(ROW_TO_JSON(NEW) AS TEXT), 
                    SQLERRM
                );
        END;
        
        RETURN NULL;
    END;
$insert_stores_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_stores_silver_trig 
    AFTER INSERT ON bronze.stores
    FOR EACH ROW 
    EXECUTE FUNCTION bronze.insert_stores_silver_func();