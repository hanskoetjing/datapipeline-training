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
        BEGIN
            INSERT INTO silver.customers (
                customer_id, 
                name, 
                email, 
                phone, 
                city, 
                join_date, 
                segment,
                modified
            )
            VALUES (
                TRIM(NEW.customer_id), 
                TRIM(NEW.name), 
                TRIM(NEW.email), 
                REGEXP_REPLACE(TRANSLATE(NEW.phone, '() -', ''), '^(\+0|0)', '+62', ''), 
                TRIM(NEW.city), 
                TO_DATE(TRIM(NEW.join_date), 'YYYY-MM-DD'),
                TRIM(NEW.segment), 
                NEW.modified
            );
            EXCEPTION
                WHEN OTHERS THEN
                    INSERT INTO bronze.rejected_data (
                        table_name, 
                        raw_data, 
                        error_message
                    )
                    VALUES (
                        'silver.customers',
                        CAST(ROW_TO_JSON(NEW) AS TEXT), 
                        SQLERRM 
                    );
        END;
        RETURN NULL;
	END;
$insert_cust_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_cust_silver_trig AFTER INSERT ON bronze.customers
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_cust_to_silver_func();