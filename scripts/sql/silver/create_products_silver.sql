--product_id,product_name,category_id,unit_price

CREATE TABLE silver.products (
	product_id varchar(10) NOT NULL,
	product_name varchar(200),
    category_id varchar(6),
    unit_price int8,
	modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE silver.products ADD CONSTRAINT products_pk PRIMARY KEY (product_id);

CREATE OR REPLACE FUNCTION silver.insert_prod_to_silver_func() RETURNS trigger as $insert_prod_to_silver_trig$
	DECLARE e silver.products%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.products WHERE product_id = NEW.product_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF e.product_name <> NEW.product_name AND e.category_id <> NEW.category_id AND
            e.unit_price <> NEW.unit_price AND e.modified < NEW.modified THEN
				UPDATE silver.products SET
					product_name = NEW.product_name,
                    category_id = NEW.category_id,
                    unit_price = NEW.unit_price,
					modified = NEW.modified
				WHERE product_id = NEW.product_id;
			END IF;
			RETURN NULL;
		END IF;
	END;
$insert_prod_to_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_prod_to_silver_trig BEFORE INSERT ON silver.products
    FOR EACH ROW EXECUTE FUNCTION silver.insert_prod_to_silver_func();