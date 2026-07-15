CREATE TABLE silver.employees (
    employee_id VARCHAR(50) NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    store_id VARCHAR(50) NOT NULL,
    role VARCHAR(100) NOT NULL,
    hire_date DATE,
    modified TIMESTAMP
);


CREATE OR REPLACE FUNCTION silver.check_data_emp_silver_func() RETURNS trigger as $check_data_emp_silver_trig$
	DECLARE e silver.employees%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.employees WHERE employee_id = NEW.employee_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF (e.name <> NEW.name OR e.store_id <> NEW.store_id OR
            e.role <> NEW.role OR e.hire_date <> NEW.hire_date
            ) AND e.modified < NEW.modified THEN
				UPDATE silver.employees SET
					name = NEW.name,
                    store_id = NEW.store_id,
                    role = NEW.role,
                    hire_date = NEW.hire_date,
					modified = NEW.modified
				WHERE employee_id = NEW.employee_id;
			END IF;
			RETURN NULL;
		END IF;
	END;
$check_data_emp_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_emp_silver_trig BEFORE INSERT ON silver.employees
    FOR EACH ROW EXECUTE FUNCTION silver.check_data_emp_silver_func();