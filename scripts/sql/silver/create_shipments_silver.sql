CREATE TABLE silver.shipments (
    shipment_id VARCHAR(10) PRIMARY KEY,
    order_id VARCHAR(10),
    courier VARCHAR(255),
    shipped_date DATE,
    delivered_date DATE,
    status VARCHAR(50),
    modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION silver.check_data_shipments_silver_func() 
RETURNS trigger as $check_data_shipments_silver_trig$
    DECLARE e silver.shipments%ROWTYPE;
    BEGIN
        -- Mencegah duplikasi: Cari data lama berdasarkan PK (shipment_id)
        SELECT * INTO e FROM silver.shipments 
        WHERE shipment_id = NEW.shipment_id;
        
        IF NOT FOUND THEN 
            -- Jika tidak ada data lama yang konflik, izinkan INSERT berlanjut
            RETURN NEW;
        ELSE 
            -- Jika data lama ditemukan dan data baru memiliki versi lebih segar (modified lebih baru)
            IF e.modified < NEW.modified THEN
                UPDATE silver.shipments SET
                    order_id = NEW.order_id,
                    courier = NEW.courier,
                    shipped_date = NEW.shipped_date,
                    delivered_date = NEW.delivered_date,
                    status = NEW.status,
                    modified = NEW.modified
                WHERE shipment_id = e.shipment_id;
            END IF;
            
            -- Gagalkan proses INSERT asli agar tidak memicu error duplicate key
            RETURN NULL;
        END IF;
    END;
$check_data_shipments_silver_trig$ language plpgsql;

CREATE OR REPLACE FUNCTION silver.check_data_shipments_silver_func() 
RETURNS trigger as $check_data_shipments_silver_trig$
    DECLARE e silver.shipments%ROWTYPE;
    BEGIN
        SELECT * INTO e FROM silver.shipments 
        WHERE shipment_id = NEW.shipment_id;
        
        IF NOT FOUND THEN 
            RETURN NEW;
        ELSE 
            IF e.modified < NEW.modified THEN
                UPDATE silver.shipments SET
                    order_id = NEW.order_id,
                    courier = NEW.courier,
                    shipped_date = NEW.shipped_date,
                    delivered_date = NEW.delivered_date,
                    status = NEW.status,
                    modified = NEW.modified
                WHERE shipment_id = e.shipment_id;
            END IF;
            RETURN NULL;
        END IF;
    END;
$check_data_shipments_silver_trig$ language plpgsql;

CREATE OR REPLACE TRIGGER check_data_shipments_silver_trig 
    BEFORE INSERT ON silver.shipments
    FOR EACH ROW 
    EXECUTE FUNCTION silver.check_data_shipments_silver_func();