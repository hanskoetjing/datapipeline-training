CREATE TABLE silver.categories (
	category_id varchar(6) NOT NULL,
	category_name varchar(100) NULL,
	modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE silver.categories ADD CONSTRAINT categories_pk PRIMARY KEY (category_id);

CREATE OR REPLACE FUNCTION silver.insert_cat_to_silver_func() RETURNS trigger as $insert_cat_to_silver_trig$
	DECLARE e silver.categories%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.categories WHERE category_id = NEW.category_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF e.category_name <> NEW.category_name AND e.modified < NEW.modified THEN
				UPDATE silver.categories SET
					category_name = NEW.category_name,
					modified = NEW.modified
				WHERE category_id = NEW.category_id;
			END IF;
			RETURN NULL;
		END IF;
	END;
$insert_cat_to_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_cat_to_silver_trig BEFORE INSERT ON silver.categories
    FOR EACH ROW EXECUTE FUNCTION silver.insert_cat_to_silver_func();