CREATE TABLE bronze.products (
	product_id varchar(10) NOT NULL,
	product_name varchar(200),
    category_id varchar(6),
    unit_price varchar(100),
	modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE OR REPLACE FUNCTION bronze.insert_prod_silver_func() RETURNS trigger as $insert_prod_silver_trig$
	BEGIN
		INSERT INTO silver.products (product_id, product_name, category_id, unit_price, modified)
        VALUES (TRIM(NEW.product_id), TRIM(NEW.product_name), TRIM(NEW.category_id), 
        CAST(TRIM(NEW.unit_price) AS INT8), NEW.modified);
        RETURN NULL;
	END;
$insert_prod_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_prod_silver_trig AFTER INSERT ON bronze.products
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_prod_silver_func();