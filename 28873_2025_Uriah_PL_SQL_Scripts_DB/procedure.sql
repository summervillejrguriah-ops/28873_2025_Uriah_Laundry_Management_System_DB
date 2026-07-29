/*
================================================================================
 File        : procedure.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_PL_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Standalone stored procedures operating on the 5 core tables
               (customers, employees, services, orders, order_items).
 Prerequisite: Run 28873_2025_Uriah_SQL_Scripts_DB/create_tables.sql first.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
================================================================================
*/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- 1. add_customer : registers a new customer
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_customer (
   p_full_name IN customers.full_name%TYPE,
   p_phone     IN customers.phone%TYPE,
   p_email     IN customers.email%TYPE DEFAULT NULL,
   p_address   IN customers.address%TYPE DEFAULT NULL
) IS
BEGIN
   INSERT INTO customers (full_name, phone, email, address)
   VALUES (p_full_name, p_phone, p_email, p_address);

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Customer "'||p_full_name||'" added successfully.');
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Error: phone number already exists.');
   WHEN OTHERS THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Unexpected error: '||SQLERRM);
END add_customer;
/

--------------------------------------------------------------------------------
-- 2. add_order : creates a new order for a customer, handled by an employee
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_order (
   p_customer_id IN orders.customer_id%TYPE,
   p_employee_id IN orders.employee_id%TYPE,
   p_order_id    OUT orders.order_id%TYPE
) IS
BEGIN
   INSERT INTO orders (customer_id, employee_id, order_date, status, total_amount)
   VALUES (p_customer_id, p_employee_id, SYSDATE, 'PENDING', 0)
   RETURNING order_id INTO p_order_id;

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Order #'||p_order_id||' created (PENDING).');
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20020, 'Failed to create order: '||SQLERRM);
END add_order;
/

--------------------------------------------------------------------------------
-- 3. add_order_item : adds a service line to an order and refreshes the total
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_order_item (
   p_order_id   IN order_items.order_id%TYPE,
   p_service_id IN order_items.service_id%TYPE,
   p_qty        IN order_items.quantity%TYPE
) IS
   v_price  services.price%TYPE;
   e_bad_qty EXCEPTION;
BEGIN
   IF p_qty <= 0 THEN
      RAISE e_bad_qty;
   END IF;

   SELECT price INTO v_price FROM services WHERE service_id = p_service_id;

   INSERT INTO order_items (order_id, service_id, quantity, subtotal)
   VALUES (p_order_id, p_service_id, p_qty, v_price * p_qty);

   UPDATE orders
      SET total_amount = (SELECT NVL(SUM(subtotal),0) FROM order_items
                            WHERE order_id = p_order_id)
    WHERE order_id = p_order_id;

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Item added to order #'||p_order_id||
                         ' (qty '||p_qty||').');
EXCEPTION
   WHEN e_bad_qty THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20010, 'Quantity must be greater than 0.');
   WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20011, 'Invalid service_id: '||p_service_id);
END add_order_item;
/

--------------------------------------------------------------------------------
-- 4. update_order_status : moves an order through its lifecycle
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE update_order_status (
   p_order_id IN orders.order_id%TYPE,
   p_status   IN orders.status%TYPE
) IS
BEGIN
   UPDATE orders SET status = p_status WHERE order_id = p_order_id;

   IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20012, 'Order #'||p_order_id||' not found.');
   END IF;

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Order #'||p_order_id||' status -> '||p_status);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END update_order_status;
/

--------------------------------------------------------------------------------
-- 5. delete_order : removes an order (order_items cascade automatically)
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE delete_order (
   p_order_id IN orders.order_id%TYPE
) IS
BEGIN
   DELETE FROM orders WHERE order_id = p_order_id;

   IF SQL%ROWCOUNT = 0 THEN
      RAISE_APPLICATION_ERROR(-20013, 'Order #'||p_order_id||' not found.');
   END IF;

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Order #'||p_order_id||' deleted (items cascaded).');
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END delete_order;
/

--------------------------------------------------------------------------------
-- Demo (comment out if not needed)
--------------------------------------------------------------------------------
DECLARE
   v_new_order_id orders.order_id%TYPE;
BEGIN
   add_customer('Test Customer','0799000000','test.customer@mail.com','Kigali');
   add_order(1, 3, v_new_order_id);
   add_order_item(v_new_order_id, 1, 2);
   update_order_status(v_new_order_id, 'WASHING');
END;
/
