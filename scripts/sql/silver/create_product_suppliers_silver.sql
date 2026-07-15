CREATE TABLE silver.product_suppliers (
	product_id varchar(10) NOT NULL,
	supplier_id varchar(10),
	cost_price int8,
	modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE silver.product_suppliers ADD CONSTRAINT prodsupp_pk PRIMARY KEY (product_id, supplier_id);

CREATE OR REPLACE FUNCTION silver.insert_prodsupp_to_silver_func() RETURNS trigger as $insert_prodsupp_to_silver_trig$
	DECLARE e silver.product_suppliers%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.product_suppliers WHERE product_id = NEW.product_id 
		AND supplier_id = NEW.supplier_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF e.cost_price <> NEW.cost_price AND e.modified < NEW.modified THEN
				UPDATE silver.product_suppliers SET
					cost_price = NEW.cost_price,
					modified = NEW.modified
				WHERE product_id = NEW.product_id AND supplier_id = NEW.supplier_id;
			END IF;
			RETURN NULL;
		END IF;
	END;
$insert_prodsupp_to_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_prodsupp_to_silver_trig BEFORE INSERT ON silver.product_suppliers
    FOR EACH ROW EXECUTE FUNCTION silver.insert_prodsupp_to_silver_func();