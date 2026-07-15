CREATE TABLE silver.loyalty_points (
    loyalty_id VARCHAR(10),
    customer_id VARCHAR(6),
    order_id VARCHAR(10),
    points_earned NUMBER,
    points_redeemed NUMBER,
    modified TIMESTAMP
);

ALTER TABLE silver.loyalty_points ADD CONSTRAINT loyalty_points_pk PRIMARY KEY (loyalty_id,customer_id);
ALTER TABLE silver.loyalty_points ADD CONSTRAINT loyalty_points_customers_fk FOREIGN KEY (customer_id) REFERENCES silver.customers(customer_id);


CREATE OR REPLACE FUNCTION silver.check_data_lylt_silver_func() RETURNS trigger as $check_data_lylt_silver_trig$
	DECLARE e silver.loyalty_points%ROWTYPE;
	BEGIN
		SELECT * INTO e FROM silver.loyalty_points WHERE loyalty_id = NEW.loyalty_id 
        AND customer_id = NEW.customer_id;
		IF NOT FOUND THEN 
			RETURN NEW;
		ELSE 
			IF (e.points_earned <> NEW.points_earned OR e.points_redeemed <> NEW.points_redeemed
            ) AND e.modified < NEW.modified THEN
				UPDATE silver.loyalty_points SET
                    points_earned = NEW.points_earned,
                    points_redeemed = NEW.points_redeemed,
					modified = NEW.modified
				WHERE loyalty_id = NEW.loyalty_id AND customer_id = NEW.customer_id;
			END IF;
			RETURN NULL;
		END IF;
	END;
$check_data_lylt_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_lylt_silver_trig BEFORE INSERT ON silver.loyalty_points
    FOR EACH ROW EXECUTE FUNCTION silver.check_data_lylt_silver_func();