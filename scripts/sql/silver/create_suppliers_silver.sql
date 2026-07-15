--product_id,product_name,category_id,unit_price

CREATE TABLE silver.suppliers (
	supplier_id varchar(10) NOT NULL,
	supplier_name varchar(200),
    city varchar(200),
	modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE silver.suppliers ADD CONSTRAINT suppliers_pk PRIMARY KEY (supplier_id);

CREATE OR REPLACE FUNCTION silver.insert_supp_to_silver_func() RETURNS trigger as $insert_supp_to_silver_trig$
	DECLARE e silver.suppliers%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.suppliers WHERE supplier_id = NEW.supplier_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF (e.supplier_name <> NEW.supplier_name OR e.city <> NEW.city) AND e.modified < NEW.modified THEN
				UPDATE silver.suppliers SET
					supplier_name = NEW.supplier_name,
                    city = NEW.city,
					modified = NEW.modified
				WHERE product_id = NEW.product_id;
			END IF;
			RETURN NULL;
		END IF;
	END;
$insert_supp_to_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_supp_to_silver_trig BEFORE INSERT ON silver.suppliers
    FOR EACH ROW EXECUTE FUNCTION silver.insert_supp_to_silver_func();