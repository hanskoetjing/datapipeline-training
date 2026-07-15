CREATE TABLE silver.orders (
    order_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(6) NOT NULL,
    store_id VARCHAR(10) NOT NULL,
    order_date TIMESTAMP NOT NULL,
    payment_method VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION silver.check_data_orders_silver_func() RETURNS trigger as $check_data_orders_silver_trig$
	DECLARE e silver.orders%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.orders WHERE order_id = NEW.order_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF e.modified < NEW.modified THEN
                UPDATE silver.orders SET
                    customer_id = NEW.customer_id,
                    store_id = NEW.store_id,
                    order_date = NEW.order_date,
                    payment_method = NEW.payment_method,
                    status = NEW.status,
                    modified = NEW.modified
                WHERE order_id = NEW.order_id;
            END IF;
			RETURN NULL;
		END IF;
	END;
$check_data_orders_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_orders_silver_trig BEFORE INSERT ON silver.orders
    FOR EACH ROW EXECUTE FUNCTION silver.check_data_orders_silver_func();