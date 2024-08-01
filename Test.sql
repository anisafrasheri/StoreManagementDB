-- TESTING
-----------------------------------------------------------------------------------------------------------------------------

-- DBMS_OUTPUT per te shfaqur rezultatet
SET SERVEROUTPUT ON;

BEGIN
    gjendja_arkes_per_shites;
END;
/

SET SERVEROUTPUT OFF;
-------------------------------------------------------------------------------------------------------------------------------
BEGIN
    calculate_points(p_client_id => 12, p_payment_amount => 500.75);
END;
/
SELECT * FROM clients
SELECT * FROM card
------------------------------------------------------------------------------------------------------------------------------
-- Provojme te bejme insert ne billed_items nje produkt me quantity 0
INSERT INTO billed_items (bill_line_id, bill_id, product_id, quantity, price_rate)
VALUES (2, 10, (SELECT product_id FROM products WHERE product_name = 'iPhone 13'), 5, 100);

------------------------------------------------------------------------------------------------------------------------------
DECLARE
    v_bill_id NUMBER;
BEGIN
    SELECT bill_id INTO v_bill_id
    FROM client_bills
    WHERE date_time = TO_DATE('2024-05-07 10:30:00', 'YYYY-MM-DD HH24:MI:SS');

    anulo_transaction('shitje', v_bill_id);
END;
/

-- Shikojme rezultatet ne tabele
SELECT * FROM supplier_invoices;
SELECT * FROM supplier_invoice_line; 
-- shikojme qe te jete shtuar billi me vlere negative
SELECT * FROM client_bills; 
SELECT * FROM billed_items;
------------------------------------------------------------------------------------------------------------------

INSERT INTO clients (client_id, name, surname, phone, address)
VALUES (client_id_seq.nextval, 'Anisa', 'Frasheri', 1234567890, '123 Main Street');

-- Insert client bills
INSERT INTO client_bills (bill_id, client_id, date_time, staff_id, payment_amount)
VALUES (bill_id_seq.nextval, (SELECT client_id FROM clients WHERE name = 'Anisa' AND surname = 'Frasheri'), TO_DATE('2024-01-07 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), (SELECT staff_id FROM staff WHERE first_name = 'John'), 500.75);

INSERT INTO billed_items (bill_line_id, bill_id, product_id, quantity, price_rate)
VALUES (bill_line_id_seq.nextval, (SELECT bill_id FROM client_bills WHERE date_time = TO_DATE('2024-01-07 09:00:00', 'YYYY-MM-DD HH24:MI:SS')), (SELECT product_id FROM products WHERE product_name = 'Dell Inspiron 15'), ROUND(DBMS_RANDOM.VALUE(1, 5), 0), (SELECT price_rate FROM products WHERE product_name = 'Dell Inspiron 15'));


SELECT * FROM client_bills
