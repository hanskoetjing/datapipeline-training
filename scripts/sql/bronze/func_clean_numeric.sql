CREATE OR REPLACE FUNCTION bronze.clean_numeric(input_val VARCHAR)
RETURNS NUMERIC(15,2) AS $$
DECLARE
    cleaned VARCHAR;
BEGIN
    cleaned := TRIM(input_val);
    
    IF cleaned IS NULL OR cleaned = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned ~ '\..*,' OR cleaned ~ ',\d{1,2}$' THEN
        cleaned := REPLACE(cleaned, '.', '');
        cleaned := REPLACE(cleaned, ',', '.');
    ELSIF cleaned ~ ',.*\.' THEN
        cleaned := REPLACE(cleaned, ',', '');
    END IF;
    RETURN CAST(cleaned AS NUMERIC(15,2));
EXCEPTION 
    WHEN OTHERS THEN
		INSERT INTO bronze.rejected_data (table_name, raw_data, error_message)
            VALUES (
                'bronze.func.clean_numeric',
                CAST(input_val AS TEXT), 
                SQLERRM
            );
        RETURN NULL; 
END;
$$ LANGUAGE plpgsql;