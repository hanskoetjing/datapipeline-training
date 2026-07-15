CREATE TABLE silver.stores (
    store_id VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(200) NOT NULL,
    city VARCHAR(200) NOT NULL,
    opened_date DATE NOT NULL,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION silver.check_data_stores_silver_func() 
RETURNS trigger as $check_data_stores_silver_trig$
    DECLARE e silver.stores%ROWTYPE;
    BEGIN
        SELECT * INTO e FROM silver.stores 
        WHERE store_id = NEW.store_id;
        IF NOT FOUND THEN 
            RETURN NEW;
        ELSE 
            IF e.modified < NEW.modified THEN
                UPDATE silver.stores SET
                    store_name = NEW.store_name,
                    city = NEW.city,
                    opened_date = NEW.opened_date,
                    modified = NEW.modified
                WHERE store_id = e.store_id;
            END IF;
            RETURN NULL;
        END IF;
    END;
$check_data_stores_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_stores_silver_trig 
BEFORE INSERT ON silver.stores
FOR EACH ROW 
EXECUTE FUNCTION silver.check_data_stores_silver_func();