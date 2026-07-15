CREATE TABLE bronze.employees (
    employee_id VARCHAR(50),
    name VARCHAR(255),
    store_id VARCHAR(50),
    role VARCHAR(100),
    hire_date VARCHAR(50),
    modified TIMESTAMP
);


CREATE OR REPLACE FUNCTION bronze.insert_emp_silver() 
RETURNS trigger as $insert_emp_silver_trig$
    BEGIN
        BEGIN
            INSERT INTO silver.employees (
                employee_id, 
                name, 
                store_id, 
                role, 
                hire_date, 
                modified
            )
            VALUES (
                TRIM(NEW.employee_id), 
                TRIM(NEW.name), 
                TRIM(NEW.store_id), 
                TRIM(NEW.role), 
                TO_DATE(TRIM(NEW.hire_date), 'YYYY-MM-DD'), 
                NEW.modified
            );
        EXCEPTION 
            WHEN OTHERS THEN
                INSERT INTO bronze.rejected_data (table_name, raw_data, error_message)
                VALUES (
                    'bronze.employees',
                    CAST(ROW_TO_JSON(NEW) AS TEXT), 
                    SQLERRM
                );
        END;
        
        RETURN NULL;
    END;
$insert_emp_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER insert_emp_silver_trig AFTER INSERT ON bronze.employees
    FOR EACH ROW EXECUTE FUNCTION bronze.insert_emp_silver();