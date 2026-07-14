CREATE TABLE silver.categories (
	category_id varchar(6) NULL,
	category_name varchar(100) NULL
);

ALTER TABLE silver.categories ADD CONSTRAINT categories_pk PRIMARY KEY (category_id);
