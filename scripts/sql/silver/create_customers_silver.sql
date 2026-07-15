CREATE TABLE silver.customers (
    customer_id VARCHAR(6) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(100),
    join_date DATE,
    segment VARCHAR(10),
    modified TIMESTAMP
);

CREATE OR REPLACE FUNCTION silver.check_data_cust_silver_func() RETURNS trigger as $check_data_cust_silver_trig$
	DECLARE e silver.customers%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.customers WHERE customer_id = NEW.customer_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF (e.name <> NEW.name OR e.email <> NEW.email OR
            e.phone <> NEW.phone OR e.city <> NEW.city OR
            e.join_date <> e.join_date OR e.segment <> e.segment
            ) AND e.modified < NEW.modified THEN
				UPDATE silver.customers SET
					name = NEW.name,
                    email = NEW.email,
                    phone = NEW.phone,
                    city = NEW.city,
                    join_date = NEW.join_date,
                    segment = NEW.segment,
					modified = NEW.modified
				WHERE customer_id = NEW.customer_id;
			END IF;
			RETURN NULL;
		END IF;
	END;
$check_data_cust_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_cust_silver_trig BEFORE INSERT ON silver.customers
    FOR EACH ROW EXECUTE FUNCTION silver.check_data_cust_silver_func();