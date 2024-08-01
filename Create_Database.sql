CREATE SEQUENCE category_id_seq START WITH 10 INCREMENT BY 10 NOCACHE;
CREATE TABLE product_category (
  category_id NUMBER,
  category_name VARCHAR2(20) CONSTRAINT category_cat_name_nn NOT NULL,
  CONSTRAINT product_category_pk PRIMARY KEY (category_id),
  CONSTRAINT category_name_uk UNIQUE (category_name)
);

CREATE SEQUENCE product_id_seq START WITH 1 INCREMENT BY 1 CACHE 10;
CREATE TABLE products (
	product_id NUMBER,
	category_id NUMBER CONSTRAINT prod_cat_id_nn NOT NULL,
	product_name VARCHAR2(50) CONSTRAINT prod_name_nn NOT NULL,
	price_rate NUMBER(10,2) CONSTRAINT prod_price_nn NOT NULL,
	stock_level NUMBER,
    quantity NUMBER,
    CONSTRAINT prod_id_pk PRIMARY KEY (product_id),
    CONSTRAINT misc_products_ck CHECK (stock_level >= 0)
);
--FURNITORET
CREATE SEQUENCE nipt_seq START WITH 10 INCREMENT BY 1 NOCACHE;
CREATE TABLE suppliers (
  nipt NUMBER,
  supplier_name VARCHAR2(50) CONSTRAINT supplier_name_nn NOT NULL,
  address VARCHAR2(150) CONSTRAINT supplier_address_nn NOT NULL,
  phone NUMBER(15),
  CONSTRAINT suppliers_pk PRIMARY KEY (nipt),
  CONSTRAINT suppliers_name_uk UNIQUE (supplier_name)
);
--PER NJE PRODUKT
CREATE SEQUENCE sup_inv_line_id_seq START WITH 1 INCREMENT BY 1 CACHE 100;
CREATE TABLE supplier_invoice_line (
  sup_inv_line_id NUMBER,
  invoice_number NUMBER CONSTRAINT sup_inv_num_nn NOT NULL,
  product_id NUMBER CONSTRAINT sup_inv_prod_nn NOT NULL,
  quantity NUMBER CONSTRAINT sup_inv_quantity_nn NOT NULL,
  price_rate NUMBER(10,2) CONSTRAINT sup_inv_rate_nn NOT NULL,
  CONSTRAINT supplier_invoice_line_pk PRIMARY KEY (sup_inv_line_id),
  CONSTRAINT sup_inv_numeric_ck CHECK (quantity > 0 AND price_rate >= 0)
); 

--FLETEHYRJE
CREATE SEQUENCE invoice_number_seq START WITH 1 INCREMENT BY 1 CACHE 100;
CREATE TABLE supplier_invoices (
  invoice_number NUMBER,
  nipt NUMBER CONSTRAINT sup_invoice_sup_id_nn NOT NULL,
  date_received date CONSTRAINT sup_invoice_date_nn NOT NULL,
  CONSTRAINT supplier_invoices_pk PRIMARY KEY (invoice_number)
);

--MAGAZINA
CREATE TABLE stock_items (
    product_id NUMBER CONSTRAINT stk_prod_id_nn NOT NULL,
    stock_level NUMBER CONSTRAINT stk_stock_nn NOT NULL,
    CONSTRAINT stock_items_pk PRIMARY KEY (product_id),
    CONSTRAINT stock_items_fk_product_id FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT stock_items_chk CHECK (stock_level >= 0)
);

CREATE SEQUENCE client_id_seq START WITH 10 INCREMENT BY 1 NOCACHE;
CREATE TABLE clients (
  client_id NUMBER,
  name VARCHAR2(50) CONSTRAINT client_name_nn NOT NULL,
  surname VARCHAR2(50) CONSTRAINT client_surname_nn NOT NULL,
  phone NUMBER(15) CONSTRAINT client_phone_nn NOT NULL,
  address VARCHAR2(150),
  CONSTRAINT client_pk PRIMARY KEY (client_id)
);

CREATE SEQUENCE card_id_seq START WITH 10 INCREMENT BY 1 NOCACHE;
CREATE TABLE card (
  card_id NUMBER,
  client_id NUMBER, 
  credit NUMBER DEFAULT 0,
  data DATE,
  CONSTRAINT card_pk PRIMARY KEY (card_id),
  CONSTRAINT card_fk FOREIGN KEY (client_id) REFERENCES clients(client_id) 
);

CREATE SEQUENCE staff_id_seq START WITH 10 INCREMENT BY 1 NOCACHE;
CREATE TABLE staff (
  staff_id NUMBER,
  first_name VARCHAR2(20) CONSTRAINT staff_fname_nn NOT NULL,
  last_name VARCHAR2(20) CONSTRAINT staff_lname_nn NOT NULL,
  home_phone VARCHAR2(14) CONSTRAINT staff_hphone_nn NOT NULL,
  username VARCHAR(20),
  password VARCHAR(20),
  address VARCHAR2(150) CONSTRAINT staff_addr_nn NOT NULL,
  CONSTRAINT username_uk UNIQUE (username),
  CONSTRAINT staff_id_pk PRIMARY KEY (staff_id)
);
-- PER NJE PRODUKT
CREATE SEQUENCE bill_line_id_seq START WITH 1 INCREMENT BY 1 CACHE 500;
CREATE TABLE billed_items (
  bill_line_id NUMBER,
  bill_id NUMBER CONSTRAINT billed_bill_id_nn NOT NULL,
  product_id NUMBER CONSTRAINT billed_product_nn NOT NULL,
  quantity NUMBER CONSTRAINT billed_quantity_nn NOT NULL,
  price_rate NUMBER(10,2) CONSTRAINT billed_pricerate_nn NOT NULL,
  CONSTRAINT billed_items_pk PRIMARY KEY (bill_line_id)
);
-- FATURA
CREATE SEQUENCE bill_id_seq START WITH 1 INCREMENT BY 1 CACHE 500;
CREATE TABLE client_bills (
  bill_id NUMBER,
  client_id NUMBER,
  date_time DATE CONSTRAINT bills_date_nn NOT NULL,
  staff_id NUMBER,
  payment_amount NUMBER(10,2),
  CONSTRAINT client_bills_pk PRIMARY KEY (bill_id)
);

CREATE SEQUENCE station_id_seq START WITH 10 INCREMENT BY 1 NOCACHE;
CREATE TABLE cashier_stations (
  station_id NUMBER,
  staff_id NUMBER,
  desk NUMBER(3),
  CONSTRAINT cashier_stations_pk PRIMARY KEY (station_id)
);
---------------------------------------------------------------------------------------------------------------------------------

-- Foreign Key Constraints 

ALTER TABLE products ADD 
(
CONSTRAINT products_category_id_fk FOREIGN KEY (category_id) REFERENCES product_category(category_id)
);

ALTER TABLE supplier_invoice_line ADD 
(
CONSTRAINT sup_inv_ln_product_fk FOREIGN KEY (product_id) REFERENCES products(product_id),
CONSTRAINT sup_inv_ln_invoice_no_fk FOREIGN KEY (invoice_number) REFERENCES supplier_invoices(invoice_number)
);

ALTER TABLE supplier_invoices ADD 
(
CONSTRAINT sup_inv_supplier_fk FOREIGN KEY (nipt) REFERENCES suppliers(nipt)
);

ALTER TABLE billed_items ADD 
(
CONSTRAINT billed_items_bill_fk FOREIGN KEY (bill_id) REFERENCES client_bills(bill_id),
CONSTRAINT billed_items_product_fk FOREIGN KEY (product_id) REFERENCES products(product_id)
);

ALTER TABLE client_bills ADD
CONSTRAINT bill_staff_fk FOREIGN KEY (staff_id) REFERENCES staff(staff_id);

ALTER TABLE client_bills ADD
CONSTRAINT bill_client_fk FOREIGN KEY (client_id) REFERENCES clients(client_id);

ALTER TABLE cashier_stations ADD 
CONSTRAINTS staff_station_fk FOREIGN KEY (staff_id) REFERENCES staff(staff_id);

------------------------------------------------------------------------------------------------------
-- Insert product categories
INSERT INTO product_category (category_id, category_name)
VALUES (category_id_seq.nextval, 'Laptops');

INSERT INTO product_category (category_id, category_name)
VALUES (category_id_seq.nextval, 'Smartphones');

INSERT INTO product_category (category_id, category_name)
VALUES (category_id_seq.nextval, 'Tablets');

INSERT INTO product_category (category_id, category_name)
VALUES (category_id_seq.nextval, 'Desktops');

-- Insert products
INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Laptops'), 'Dell Inspiron 15', ROUND(DBMS_RANDOM.VALUE(500, 1500), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), ROUND(DBMS_RANDOM.VALUE(50, 100), 0));

INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Laptops'), 'HP Spectre x360', ROUND(DBMS_RANDOM.VALUE(800, 2000), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), ROUND(DBMS_RANDOM.VALUE(50, 100), 0));

INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Smartphones'), 'iPhone 13', ROUND(DBMS_RANDOM.VALUE(700, 1300), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), 0);

INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Smartphones'), 'Samsung Galaxy S21', ROUND(DBMS_RANDOM.VALUE(600, 1200), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), ROUND(DBMS_RANDOM.VALUE(50, 100), 0));

INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Tablets'), 'iPad Pro', ROUND(DBMS_RANDOM.VALUE(600, 1500), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), ROUND(DBMS_RANDOM.VALUE(50, 100), 0));

INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Tablets'), 'Samsung Galaxy Tab S7', ROUND(DBMS_RANDOM.VALUE(500, 1200), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), ROUND(DBMS_RANDOM.VALUE(50, 100), 0));

INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Desktops'), 'Dell OptiPlex', ROUND(DBMS_RANDOM.VALUE(600, 1500), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), ROUND(DBMS_RANDOM.VALUE(50, 100), 0));

INSERT INTO products (product_id, category_id, product_name, price_rate, stock_level, quantity)
VALUES (product_id_seq.nextval, (SELECT category_id FROM product_category WHERE category_name = 'Desktops'), 'Lenovo ThinkCentre', ROUND(DBMS_RANDOM.VALUE(500, 1200), 2), ROUND(DBMS_RANDOM.VALUE(100, 500), 0), ROUND(DBMS_RANDOM.VALUE(50, 100), 0));

-- Insert suppliers
INSERT INTO suppliers (nipt, supplier_name, address, phone)
VALUES (nipt_seq.nextval, 'TechMarti', '123 Main Street, Tech City', 1234567);

INSERT INTO suppliers (nipt, supplier_name, address, phone)
VALUES (nipt_seq.nextval, 'Global Electronics', '456 Broadway Avenue, Digital Town', 2345678);

-- Insert supplier_invoices
INSERT INTO supplier_invoices (invoice_number, nipt, date_received)
VALUES (1, (SELECT nipt FROM suppliers WHERE supplier_name = 'TechMart'), TO_DATE('2024-05-15', 'YYYY-MM-DD'));

INSERT INTO supplier_invoices (invoice_number, nipt, date_received)
VALUES (3, (SELECT nipt FROM suppliers WHERE supplier_name = 'Global Electronics'), TO_DATE('2024-05-16', 'YYYY-MM-DD'));

-- Insert supplier_invoice_line
INSERT INTO supplier_invoice_line (sup_inv_line_id, invoice_number, product_id, quantity, price_rate)
VALUES (sup_inv_line_id_seq.nextval, 1, (SELECT product_id FROM products WHERE product_name = 'Dell Inspiron 15'), 10, 1200.00);

INSERT INTO supplier_invoice_line (sup_inv_line_id, invoice_number, product_id, quantity, price_rate)
VALUES (sup_inv_line_id_seq.nextval, 1, (SELECT product_id FROM products WHERE product_name = 'HP Spectre x360'), 8, 1500.00);

INSERT INTO supplier_invoice_line (sup_inv_line_id, invoice_number, product_id, quantity, price_rate)
VALUES (sup_inv_line_id_seq.nextval, 3, (SELECT product_id FROM products WHERE product_name = 'iPhone 13'), 15, 1000.00);

INSERT INTO supplier_invoice_line (sup_inv_line_id, invoice_number, product_id, quantity, price_rate)
VALUES(sup_inv_line_id_seq.nextval, 3, (SELECT product_id FROM products WHERE product_name = 'Samsung Galaxy S21'), 20, 800.00);

-- Insert stock_items
INSERT INTO stock_items (stock_level, product_id)
VALUES (10, (SELECT product_id FROM products WHERE product_name = 'Dell Inspiron 15'));

INSERT INTO stock_items (stock_level, product_id)
VALUES (20, (SELECT product_id FROM products WHERE product_name = 'HP Spectre x360'));

INSERT INTO stock_items (stock_level, product_id)
VALUES (15, (SELECT product_id FROM products WHERE product_name = 'iPhone 13'));

-- Insert clients
INSERT INTO clients (client_id, name, surname, phone, address)
VALUES (client_id_seq.nextval, 'John', 'Doe', 1234567890, '123 Main Street');

INSERT INTO clients (client_id, name, surname, phone, address)
VALUES (client_id_seq.nextval, 'Jane', 'Smith', 9876543210, '456 Oak Avenue');

-- Insert cards
INSERT INTO card (card_id, client_id, credit, data)
VALUES (card_id_seq.nextval, (SELECT client_id FROM clients WHERE name = 'John' AND surname = 'Doe'), 100, TO_DATE('2024-05-10', 'yyyy-mm-dd'));

INSERT INTO card (card_id, client_id, credit, data)
VALUES (card_id_seq.nextval, (SELECT client_id FROM clients WHERE name = 'Jane' AND surname = 'Smith'), 50, TO_DATE('2024-05-09', 'yyyy-mm-dd'));

-- Insert anetare staffi
INSERT INTO staff (staff_id, first_name, last_name, home_phone, address, username, password)
VALUES (staff_id_seq.nextval, 'John', 'Smith', '555-1234', '789 Elm Street', 'john.smith', 'password');

INSERT INTO staff (staff_id, first_name, last_name, home_phone, address, username, password)
VALUES (staff_id_seq.nextval, 'Emma', 'Johnson', '555-5678', '456 Oak Avenue', 'emma.johnson', 'password123');

INSERT INTO staff (staff_id, first_name, last_name, home_phone, address, username, password)
VALUES (staff_id_seq.nextval, 'Michael', 'Williams', '555-9876', '321 Pine Road', 'michael.williams', 'password456');

-- Insert client bills (fatura)
INSERT INTO client_bills (bill_id, client_id, date_time, staff_id, payment_amount)
VALUES (bill_id_seq.nextval, (SELECT client_id FROM clients WHERE name = 'John' AND surname = 'Doe'), TO_DATE('2024-05-07 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), (SELECT staff_id FROM staff WHERE first_name = 'John'), 500.75);

INSERT INTO client_bills (bill_id, client_id, date_time, staff_id, payment_amount)
VALUES (bill_id_seq.nextval, (SELECT client_id FROM clients WHERE name = 'Jane' AND surname = 'Smith'), TO_DATE('2024-05-07 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), (SELECT staff_id FROM staff WHERE first_name = 'Emma'), 300.00);

INSERT INTO client_bills (bill_id, client_id, date_time, staff_id, payment_amount)
VALUES (bill_id_seq.nextval, (SELECT client_id FROM clients WHERE name = 'John' AND surname = 'Doe'), TO_DATE('2024-05-07 11:45:00', 'YYYY-MM-DD HH24:MI:SS'), (SELECT staff_id FROM staff WHERE first_name = 'John'), 200.50);

-- Insert billed items
INSERT INTO billed_items (bill_line_id, bill_id, product_id, quantity, price_rate)
VALUES (bill_line_id_seq.nextval, (SELECT bill_id FROM client_bills WHERE date_time = TO_DATE('2024-05-07 10:30:00', 'YYYY-MM-DD HH24:MI:SS')), (SELECT product_id FROM products WHERE product_name = 'Dell Inspiron 15'), ROUND(DBMS_RANDOM.VALUE(1, 5), 0), (SELECT price_rate FROM products WHERE product_name = 'Dell Inspiron 15'));

INSERT INTO billed_items (bill_line_id, bill_id, product_id, quantity, price_rate)
VALUES (bill_line_id_seq.nextval, (SELECT bill_id FROM client_bills WHERE date_time = TO_DATE('2024-05-07 09:00:00', 'YYYY-MM-DD HH24:MI:SS')), (SELECT product_id FROM products WHERE product_name = 'Samsung Galaxy Tab S7'), ROUND(DBMS_RANDOM.VALUE(1, 5), 0), (SELECT price_rate FROM products WHERE product_name = 'Samsung Galaxy Tab S7'));

-- Insert cashier stations
INSERT INTO cashier_stations (station_id, staff_id, desk)
VALUES (station_id_seq.nextval,  (SELECT staff_id FROM staff WHERE first_name = 'John'), 1);

INSERT INTO cashier_stations (station_id, staff_id, desk)
VALUES (station_id_seq.nextval, (SELECT staff_id FROM staff WHERE first_name = 'Emma'), 2);
