CREATE TABLE bronze.rejected_data (
    rejected_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    raw_data TEXT NOT NULL,                     
    error_message TEXT NOT NULL,                
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);