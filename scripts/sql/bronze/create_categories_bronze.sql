CREATE TABLE bronze.categories (
	category_id varchar(6) NULL,
	category_name varchar(100) NULL
);

CREATE OR REPLACE FUNCTION bronze.insert_cat_to_silver_func() RETURNS trigger as $insert_cat_to_silver_trig$
	BEGIN
		INSERT INTO silver.categories (category_id, category_name) VALUES (trim(new.category_id), trim(new.category_name));
		RETURN NEW;
	END;
$insert_cat_to_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_cat_to_silver_trig AFTER INSERT ON bronze.categories
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_cat_to_silver_func();
