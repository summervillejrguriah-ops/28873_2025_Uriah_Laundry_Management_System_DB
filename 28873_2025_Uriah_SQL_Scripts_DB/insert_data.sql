/*
================================================================================
 File        : insert_data.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Inserts realistic sample data (10+ rows per table) into the
               5 core tables: customers, employees, services, orders,
               order_items.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
 Run order   : 1) create_tables.sql   2) insert_data.sql   (run once)
================================================================================
*/

SET DEFINE OFF;

--------------------------------------------------------------------------------
-- 1. CUSTOMERS  (10 rows)
--------------------------------------------------------------------------------
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Aline Uwase',       '0788123456', 'aline.uwase@mail.com',   'Kicukiro, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Eric Niyonzima',    '0788234567', 'eric.n@mail.com',        'Nyarugenge, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Claudine Mukamana', '0788345678', 'claudine.m@mail.com',    'Gasabo, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Jean Bosco Habimana','0788456789','jbosco.h@mail.com',      'Remera, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Divine Iradukunda', '0788567890', 'divine.i@mail.com',      'Kimironko, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Patrick Mugisha',   '0788678901', 'patrick.m@mail.com',     'Kacyiru, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Grace Umutoni',     '0788789012', 'grace.u@mail.com',       'Nyamirambo, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Samuel Bizimana',   '0788890123', 'samuel.b@mail.com',      'Gikondo, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Nadia Ingabire',    '0788901234', 'nadia.i@mail.com',       'Kabeza, Kigali');
INSERT INTO customers (full_name, phone, email, address) VALUES
   ('Emmanuel Twagirayezu','0789012345','emmanuel.t@mail.com',   'Kanombe, Kigali');

--------------------------------------------------------------------------------
-- 2. EMPLOYEES  (10 rows)
--------------------------------------------------------------------------------
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Alice Keza',        'MANAGER',   '0722100001', DATE '2023-01-10');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Robert Ndayisenga', 'CASHIER',   '0722100002', DATE '2023-02-15');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Diane Uwimana',     'ATTENDANT', '0722100003', DATE '2023-03-01');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Felix Rugamba',     'WASHER',    '0722100004', DATE '2023-03-20');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Josiane Nyirahabimana','ATTENDANT','0722100005', DATE '2023-04-05');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Moses Kalisa',      'WASHER',    '0722100006', DATE '2023-05-12');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Sandrine Umuhoza',  'CASHIER',   '0722100007', DATE '2023-06-18');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Vincent Havugimana','ATTENDANT', '0722100008', DATE '2023-07-22');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Olive Mutesi',      'WASHER',    '0722100009', DATE '2023-08-30');
INSERT INTO employees (full_name, role, phone, hire_date) VALUES
   ('Kevin Rwigamba',    'ATTENDANT', '0722100010', DATE '2023-09-14');

--------------------------------------------------------------------------------
-- 3. SERVICES  (10 rows)
--------------------------------------------------------------------------------
INSERT INTO services (service_name, price, description) VALUES
   ('Wash & Fold',        1500, 'Standard machine wash, dry and fold');
INSERT INTO services (service_name, price, description) VALUES
   ('Dry Cleaning',       3500, 'Chemical dry cleaning for delicate fabrics');
INSERT INTO services (service_name, price, description) VALUES
   ('Ironing Only',       1000, 'Pressing and ironing of clean garments');
INSERT INTO services (service_name, price, description) VALUES
   ('Wash & Iron',        2200, 'Wash, dry and iron combined service');
INSERT INTO services (service_name, price, description) VALUES
   ('Bedding & Linens',   4000, 'Washing of bedsheets, duvets and linens');
INSERT INTO services (service_name, price, description) VALUES
   ('Curtain Cleaning',   5000, 'Removal, washing and re-hanging of curtains');
INSERT INTO services (service_name, price, description) VALUES
   ('Shoe Cleaning',      2500, 'Deep cleaning of shoes and sneakers');
INSERT INTO services (service_name, price, description) VALUES
   ('Express Same-Day',   3000, 'Priority same-day wash and fold service');
INSERT INTO services (service_name, price, description) VALUES
   ('Suit Cleaning',      4500, 'Dry cleaning and pressing for suits');
INSERT INTO services (service_name, price, description) VALUES
   ('Carpet Cleaning',    6000, 'Deep shampoo cleaning for carpets and rugs');

--------------------------------------------------------------------------------
-- 4. ORDERS  (12 rows, referencing customers 1-10 and employees 1-10)
--------------------------------------------------------------------------------
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (1, 3, DATE '2026-07-01', 'COMPLETED');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (2, 5, DATE '2026-07-02', 'COMPLETED');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (3, 3, DATE '2026-07-05', 'READY');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (4, 8, DATE '2026-07-08', 'WASHING');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (5, 5, DATE '2026-07-10', 'PENDING');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (6, 10, DATE '2026-07-12', 'COMPLETED');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (7, 3, DATE '2026-07-14', 'CANCELLED');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (8, 8, DATE '2026-07-16', 'READY');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (9, 5, DATE '2026-07-19', 'WASHING');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (10, 10, DATE '2026-07-21', 'PENDING');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (1, 8, DATE '2026-07-24', 'COMPLETED');
INSERT INTO orders (customer_id, employee_id, order_date, status) VALUES
   (3, 3, DATE '2026-07-27', 'PENDING');

--------------------------------------------------------------------------------
-- 5. ORDER_ITEMS  (20 rows, referencing orders 1-12 and services 1-10)
--    subtotal = services.price * quantity (computed manually here; a trigger
--    in the PL/SQL package also keeps orders.total_amount in sync)
--------------------------------------------------------------------------------
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (1, 1, 3, 4500);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (1, 3, 2, 2000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (2, 2, 1, 3500);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (2, 8, 1, 3000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (3, 4, 2, 4400);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (4, 5, 1, 4000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (4, 7, 2, 5000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (5, 1, 5, 7500);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (6, 9, 1, 4500);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (6, 3, 3, 3000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (7, 6, 1, 5000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (8, 1, 4, 6000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (8, 4, 1, 2200);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (9, 10, 1, 6000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (9, 2, 1, 3500);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (10, 1, 2, 3000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (11, 8, 2, 6000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (11, 3, 1, 1000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (12, 5, 1, 4000);
INSERT INTO order_items (order_id, service_id, quantity, subtotal) VALUES
   (12, 7, 1, 2500);

--------------------------------------------------------------------------------
-- 6. A_branches  
--------------------------------------------------------------------------------
INSERT INTO A_branches (branch_name, location, phone) VALUES ('Downtown Branch', 'KN 4 Ave, Kigali', '0788111222');
INSERT INTO A_branches (branch_name, location, phone) VALUES ('Kimironko Branch', 'Kimironko, Kigali', '0788333444');
INSERT INTO A_branches (branch_name, location, phone) VALUES ('Remera Branch', 'Remera, Kigali', '0788555666');
INSERT INTO A_branches (branch_name, location, phone) VALUES ('Nyamirambo Branch', 'Nyamirambo, Kigali', '0788777888');
INSERT INTO A_branches (branch_name, location, phone) VALUES ('Kacyiru Branch', 'Kacyiru, Kigali', '0788999000');

--------------------------------------------------------------------------------
-- 7. A_Payments 
--------------------------------------------------------------------------------
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (1, 'CASH', 6500, 'PAID');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (2, 'MOBILE_MONEY', 6500, 'PAID');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (3, 'CARD', 4400, 'PAID');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (4, 'CASH', 9000, 'PAID');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (5, 'MOBILE_MONEY', 7500, 'PAID');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (6, 'CASH', 4500, 'PARTIAL');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (7, 'BANK_TRANSFER', 5000, 'PAID');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (8, 'CARD', 6000, 'PARTIAL');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (9, 'MOBILE_MONEY', 9500, 'PAID');
INSERT INTO A_payments (order_id, payment_method, amount_paid, payment_status) VALUES (10, 'CASH', 3000, 'PENDING');


--------------------------------------------------------------------------------
-- Sync order totals from order_items, then commit
--------------------------------------------------------------------------------
UPDATE orders o
   SET total_amount = (SELECT NVL(SUM(oi.subtotal),0)
                          FROM order_items oi
                         WHERE oi.order_id = o.order_id);

COMMIT;

--------------------------------------------------------------------------------
-- Verification
--------------------------------------------------------------------------------
SELECT 'CUSTOMERS'   AS table_name, COUNT(*) AS row_count FROM customers UNION ALL
SELECT 'EMPLOYEES',   COUNT(*) FROM employees               UNION ALL
SELECT 'SERVICES',    COUNT(*) FROM services                UNION ALL
SELECT 'ORDERS',      COUNT(*) FROM orders                  UNION ALL
SELECT 'ORDER_ITEMS', COUNT(*) FROM order_items;

PROMPT Sample data inserted and committed successfully.
