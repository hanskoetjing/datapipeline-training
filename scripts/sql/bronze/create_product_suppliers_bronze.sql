CREATE TABLE bronze.product_suppliers (
	product_id varchar(10) NOT NULL,
	supplier_id varchar(10),
	cost_price varchar(20),
	modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION bronze.insert_prodsupp_silver_func() RETURNS trigger as $insert_prodsupp_silver_trig$
	BEGIN
		INSERT INTO silver.product_suppliers (product_id, supplier_id, cost_price, modified)
        VALUES (TRIM(NEW.product_id), TRIM(NEW.supplier_id), CAST(TRIM(NEW.cost_price) AS int8), NEW.modified);
        RETURN NULL;
	END;
$insert_prodsupp_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_prodsupp_silver_trig AFTER INSERT ON bronze.product_suppliers
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_prodsupp_silver_func();