CREATE TABLE bronze.suppliers (
	supplier_id varchar(10) NOT NULL,
	supplier_name varchar(200),
    city varchar(200),
	modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION bronze.insert_supp_silver_func() RETURNS trigger as $insert_supp_silver_trig$
	BEGIN
		INSERT INTO silver.suppliers (supplier_id, supplier_name, city, modified)
        VALUES (TRIM(NEW.supplier_id), TRIM(NEW.supplier_name), TRIM(NEW.city), NEW.modified);
        RETURN NULL;
	END;
$insert_supp_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_supp_silver_trig AFTER INSERT ON bronze.suppliers
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_supp_silver_func();