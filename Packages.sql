--Të mos lejohet shitja nëse sasia e artikujt gjendje është 0 duke përdorur trigger-at.
CREATE OR REPLACE TRIGGER kontroll_shitje
BEFORE INSERT OR UPDATE ON billed_items
FOR EACH ROW
DECLARE 
    sasia_mbetur NUMBER;
BEGIN
    SELECT quantity INTO sasia_mbetur FROM products
    WHERE product_id = :new.product_id;
    
    IF sasia_mbetur < 1 THEN 
        RAISE_APPLICATION_ERROR(-20000, 'Nuk lejohet shitja');
    END IF;
END;
/

-----------------------------------------------------------------------------------------------------------------------------
--	Mbyllje aktiviteti ditor (gjendja e arkës për secilin shitës)
   CREATE OR REPLACE PROCEDURE gjendja_arkes_per_shites AS
BEGIN
    FOR staff_rec IN (SELECT DISTINCT staff_id FROM client_bills) LOOP
        FOR date_rec IN (SELECT DISTINCT TRUNC(date_time) AS bill_date FROM client_bills) LOOP
            DECLARE
                v_total_amount NUMBER := 0;
            BEGIN
                SELECT SUM(payment_amount) INTO v_total_amount
                FROM client_bills
                WHERE staff_id = staff_rec.staff_id
                AND TRUNC(date_time) = date_rec.bill_date;
                
                -- Print or store the result as needed
                DBMS_OUTPUT.PUT_LINE('Staff ' || staff_rec.staff_id || ' on ' || TO_CHAR(date_rec.bill_date, 'YYYY-MM-DD') || ' made ' || v_total_amount || ' in sales.');
            END;
        END LOOP;
    END LOOP;
END gjendja_arkes_per_shites;
/

----------------------------------------------------------------------------------------------------------------------------
-- Procedurave të furnizimit dhe shitjes do ti ofrohet mundësia që të bëhet 
-- edhe anulim i tyre duke gjeneruar te njëjtën flete hyrje/flete dalje me vlere negative. 

CREATE OR REPLACE PROCEDURE anulo_transaction (
    p_transaction_type IN VARCHAR2,
    p_transaction_id IN NUMBER)
    AS
    v_invoice_number NUMBER;
BEGIN
    IF p_transaction_type = 'furnizim' THEN
        -- Gjenerojme supplier invoice negative
        INSERT INTO supplier_invoices (invoice_number, nipt, date_received)
        VALUES (invoice_number_seq.nextval, 
                (SELECT nipt FROM supplier_invoices WHERE invoice_number = p_transaction_id),
                SYSDATE);
        v_invoice_number := invoice_number_seq.CURRVAL;

        INSERT INTO supplier_invoice_line (sup_inv_line_id, invoice_number, product_id, quantity, price_rate)
        SELECT sup_inv_line_id_seq.nextval, v_invoice_number, product_id, quantity * -1, price_rate
        FROM supplier_invoice_line
        WHERE invoice_number = p_transaction_id;

        COMMIT;
        
    ELSIF p_transaction_type = 'shitje' THEN
        -- GGjenerojme client bill negative
        INSERT INTO client_bills (bill_id, client_id, date_time, staff_id, payment_amount)
        VALUES (bill_id_seq.nextval, 
                (SELECT client_id FROM client_bills WHERE bill_id = p_transaction_id),
                SYSDATE,
                (SELECT staff_id FROM client_bills WHERE bill_id = p_transaction_id),
                (SELECT payment_amount * -1 FROM client_bills WHERE bill_id = p_transaction_id));
        
        v_invoice_number := bill_id_seq.CURRVAL;

        INSERT INTO billed_items (bill_line_id, bill_id, product_id, quantity, price_rate)
        SELECT bill_line_id_seq.nextval, v_invoice_number, product_id, quantity * -1, price_rate
        FROM billed_items
        WHERE bill_id = p_transaction_id;

        COMMIT;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Vendos llojin e transaksionit');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END anulo_transaction;
/

------------------------------------------------------------------------------------------------------------------
-- Kalkulojme piket per ne kredits ne card
CREATE OR REPLACE PROCEDURE kalkulojme_piket (
    p_client_id IN clients.client_id%TYPE,
    p_payment_amount IN NUMBER
)
IS
    v_points_earned NUMBER;
BEGIN
    -- Kalkulojme piket ne baze te payment amount (pagesave ne fature)
    v_points_earned := TRUNC(p_payment_amount / 10); -- 1 point per cdo $10 te shpenzuar
    
    -- Kerkon nese ID e klientit eshte ne tabelen card 
    DECLARE
        v_record_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_record_count
        FROM card
        WHERE client_id = p_client_id;

        -- Nese ID e klientit nuk ekziston, shto nje rekord te ri
        IF v_record_count = 0 THEN
            INSERT INTO card (client_id, credit)
            VALUES (p_client_id, v_points_earned);
        ELSE
            -- Nese ID e klientit ekziston, updatojme rekordin
            UPDATE card
            SET credit = credit + v_points_earned
            WHERE client_id = p_client_id;
        END IF;
        
        COMMIT;
    END;
EXCEPTION
    WHEN OTHERS THEN 
        ROLLBACK;
        raise_application_error(-20001, 'An error occurred: ' || SQLERRM);
END calculate_points;
/


-- Trigger per te updatuar piket ne card automatikisht pas cdo blerjeje
--CREATE OR REPLACE TRIGGER calculate_points_trigger
--AFTER INSERT ON client_bills
--FOR EACH ROW
--BEGIN
    -- Call the procedure to calculate points for the client
  --  calculate_points(:NEW.client_id, :NEW.payment_amount);
--END;
/-------------------------------------------------------------------------------------------------------------
-- Updatojme tabelen stock_items nga quantity e products
CREATE OR REPLACE TRIGGER update_stock_trigger
AFTER INSERT OR UPDATE OF quantity ON products
FOR EACH ROW
BEGIN
    -- Llogaritni nivelin e ri të stokut si 50% të sasisë të rrumbullakosur në numrin e plotë më të afërt
    DECLARE
        v_new_stock NUMBER;
    BEGIN
        
        v_new_stock := ROUND(:NEW.quantity * 0.5);
        
        -- Updatojme stock_level ne tabelen stock_items
        UPDATE stock_items
        SET stock_level = v_new_stock
        WHERE product_id = :NEW.product_id;
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback ne rast errori
            ROLLBACK;
            
            RAISE_APPLICATION_ERROR(-20001, 'An error occurred: ' || SQLERRM);
    END;
END;
/

------------------------------------------------------------------------------------------
-- Updatojme tabelen products te stock_level
UPDATE products p
SET stock_level = (
    SELECT s.stock_level
    FROM stock_items s
    WHERE s.product_id = p.product_id
);
-- Krijojme triggers per te updatuar tabelen products bazuar ne ndryshimet e stock_items
CREATE OR REPLACE TRIGGER trg_update_quantity
AFTER INSERT OR UPDATE ON stock_items
FOR EACH ROW
BEGIN
    UPDATE products inv
    SET inv.stock_level = :new.stock_level
    WHERE inv.product_id = :new.product_id;
END;
/
---------------------------------------------------------------------------------
-- Updatojme quantity te tabeles product nga cdo furnizim
CREATE OR REPLACE TRIGGER update_quantity_supplier_trigger
AFTER INSERT ON supplier_invoice_line
FOR EACH ROW
BEGIN
    -- Shtojme quantityn nga supplier_invoice_line te quantityi tabeles product
    UPDATE products
    SET quantity = quantity + :NEW.quantity
    WHERE product_id = :NEW.product_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback ne rast errori 
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'An error occurred: ' || SQLERRM);
END;
/
----------------------------------------------------------------------------------------
-- Updatojme quantityn e tabeles product nga cdo shitje (fature) 
CREATE OR REPLACE TRIGGER update_quantity_billed_trigger
AFTER INSERT ON billed_items
FOR EACH ROW
BEGIN
    -- Zbresim quantity e billed_items nga quantity
    UPDATE products
    SET quantity = quantity - :NEW.quantity
    WHERE product_id = :NEW.product_id;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Rollback tne rast errori
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'An error occurred: ' || SQLERRM);
END;
/
DECLARE
  -- Deklarojme variabla qe te ruajme kredencialet
  
  member_username VARCHAR2(20);
  member_password VARCHAR2(20);
  
  -- Cursor per te bere fetch datat nga tabela
  CURSOR staff_cursor IS
    SELECT staff_id, first_name, last_name, username, password
    FROM staff;
  
BEGIN
  -- LKrijojme nje loop qe iteron neper anetaret e stafit
  FOR staff_rec IN staff_cursor LOOP
    
    member_username := staff_rec.username;
    member_password := staff_rec.password;
    
    EXECUTE IMMEDIATE 'CREATE USER ' || member_username || ' IDENTIFIED BY ' || member_password;
    
    EXECUTE IMMEDIATE 'GRANT SELECT ON DetyraDone TO ' || member_username;
   
     EXECUTE IMMEDIATE 'GRANT role_name TO ' || member_username;
    
    COMMIT;
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/

SELECT username FROM all_users;
-----------------------------------------------------------------------------------------------------------------------
