CREATE TABLE customers (
    customer_id VARCHAR(6),
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(100),
    join_date VARCHAR(50),
    segment VARCHAR(10),
    modified TIMESTAMP
);

CREATE OR REPLACE FUNCTION bronze.insert_cust_to_silver_func() RETURNS trigger as $insert_cust_silver_trig$
	BEGIN
		INSERT INTO silver.customers (customer_id, name, email, phone, city, join_date, segment, modified)
        VALUES (TRIM(NEW.customer_id), TRIM(NEW.name), TRIM(NEW.email), 
        REGEXP_REPLACE(TRANSLATE(NEW.phone, '() -', ''), '^(\+0|0)', '+62', ''), TRIM(NEW.city), TO_DATE(TRIM(NEW.join_date), 'YYYY-MM-DD'),
         TRIM(NEW.segment), NEW.modified);
        RETURN NULL;
	END;
$insert_cust_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_cust_silver_trig AFTER INSERT ON bronze.customers
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_cust_to_silver_func();