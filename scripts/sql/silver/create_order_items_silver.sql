CREATE TABLE silver.order_items (    
    order_item_id VARCHAR(10),
    order_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity NUMERIC(15, 2) NOT NULL,
    unit_price NUMERIC(15, 2) NOT NULL,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE silver.order_items ADD CONSTRAINT order_items_pk PRIMARY KEY (order_item_id);
ALTER TABLE silver.order_items ADD CONSTRAINT order_items_unique UNIQUE (order_id, product_id);

CREATE OR REPLACE FUNCTION silver.check_data_order_items_silver_func() 
RETURNS trigger as $check_data_order_items_silver_trig$
    DECLARE e silver.order_items%ROWTYPE;
    BEGIN
        SELECT * INTO e FROM silver.order_items 
        WHERE order_item_id = NEW.order_item_id 
           OR (order_id = NEW.order_id AND product_id = NEW.product_id);
        
        IF NOT FOUND THEN 
            RETURN NEW;
        ELSE 
            IF e.modified < NEW.modified THEN
                UPDATE silver.order_items SET
                    order_item_id = NEW.order_item_id,
                    order_id = NEW.order_id,
                    product_id = NEW.product_id,
                    quantity = NEW.quantity,
                    unit_price = NEW.unit_price,
                    modified = NEW.modified
                WHERE order_item_id = e.order_item_id;
            END IF;
            
            RETURN NULL;
        END IF;
    END;
$check_data_order_items_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_order_items_silver_trig 
    BEFORE INSERT ON silver.order_items
    FOR EACH ROW 
    EXECUTE FUNCTION silver.check_data_order_items_silver_func();