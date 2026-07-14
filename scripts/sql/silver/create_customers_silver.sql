CREATE TABLE customers (
    customer_id VARCHAR(6) PRIMARY KEY,
    cust_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(100),
    join_date DATE,
    segment VARCHAR(10)
);