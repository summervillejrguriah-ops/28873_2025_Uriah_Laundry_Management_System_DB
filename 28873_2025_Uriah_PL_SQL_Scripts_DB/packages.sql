/*
================================================================================
 File        : packages.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_PL_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Bundles related procedures/functions into a single package,
               PKG_LAUNDRY, operating on the 5 core tables.
 Prerequisite: Run 28873_2025_Uriah_SQL_Scripts_DB/create_tables.sql first.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
================================================================================
*/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- Package specification
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE pkg_laundry AS

   -- registers a new order for a customer/employee, returns the new order_id
   PROCEDURE register_order (
      p_customer_id IN  orders.customer_id%TYPE,
      p_employee_id IN  orders.employee_id%TYPE,
      p_order_id    OUT orders.order_id%TYPE
   );

   -- adds a service line item to an order and refreshes the order total
   PROCEDURE add_order_item (
      p_order_id   IN order_items.order_id%TYPE,
      p_service_id IN order_items.service_id%TYPE,
      p_qty        IN order_items.quantity%TYPE
   );

   -- returns the current total for an order
   FUNCTION get_order_total (
      p_order_id IN order_items.order_id%TYPE
   ) RETURN NUMBER;

   -- returns a cursor of all order items belonging to an order
   FUNCTION get_order_items (
      p_order_id IN order_items.order_id%TYPE
   ) RETURN SYS_REFCURSOR;

   -- prints a simple receipt to DBMS_OUTPUT
   PROCEDURE print_receipt (
      p_order_id IN orders.order_id%TYPE
   );

END pkg_laundry;
/

--------------------------------------------------------------------------------
-- Package body
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY pkg_laundry AS

   FUNCTION get_order_total (
      p_order_id IN order_items.order_id%TYPE
   ) RETURN NUMBER
   IS
      v_total NUMBER := 0;
   BEGIN
      SELECT NVL(SUM(subtotal), 0) INTO v_total
        FROM order_items WHERE order_id = p_order_id;
      RETURN v_total;
   END get_order_total;


   PROCEDURE register_order (
      p_customer_id IN  orders.customer_id%TYPE,
      p_employee_id IN  orders.employee_id%TYPE,
      p_order_id    OUT orders.order_id%TYPE
   ) IS
   BEGIN
      INSERT INTO orders (customer_id, employee_id, order_date, status, total_amount)
      VALUES (p_customer_id, p_employee_id, SYSDATE, 'PENDING', 0)
      RETURNING order_id INTO p_order_id;

      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20020,
            'pkg_laundry.register_order failed: '||SQLERRM);
   END register_order;


   PROCEDURE add_order_item (
      p_order_id   IN order_items.order_id%TYPE,
      p_service_id IN order_items.service_id%TYPE,
      p_qty        IN order_items.quantity%TYPE
   ) IS
      v_price   services.price%TYPE;
      e_bad_qty EXCEPTION;
   BEGIN
      IF p_qty <= 0 THEN
         RAISE e_bad_qty;
      END IF;

      SELECT price INTO v_price FROM services WHERE service_id = p_service_id;

      INSERT INTO order_items (order_id, service_id, quantity, subtotal)
      VALUES (p_order_id, p_service_id, p_qty, v_price * p_qty);

      UPDATE orders
         SET total_amount = get_order_total(p_order_id)
       WHERE order_id = p_order_id;

      COMMIT;
   EXCEPTION
      WHEN e_bad_qty THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20010, 'Quantity must be greater than 0.');
      WHEN NO_DATA_FOUND THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20011, 'Invalid service_id: '||p_service_id);
   END add_order_item;


   FUNCTION get_order_items (
      p_order_id IN order_items.order_id%TYPE
   ) RETURN SYS_REFCURSOR
   IS
      v_cursor SYS_REFCURSOR;
   BEGIN
      OPEN v_cursor FOR
         SELECT oi.order_item_id, s.service_name, oi.quantity, oi.subtotal
           FROM order_items oi
           JOIN services s ON s.service_id = oi.service_id
          WHERE oi.order_id = p_order_id;
      RETURN v_cursor;
   END get_order_items;


   PROCEDURE print_receipt (
      p_order_id IN orders.order_id%TYPE
   ) IS
      v_cursor       SYS_REFCURSOR;
      v_item_id      order_items.order_item_id%TYPE;
      v_service_name services.service_name%TYPE;
      v_qty          order_items.quantity%TYPE;
      v_subtotal     order_items.subtotal%TYPE;
   BEGIN
      DBMS_OUTPUT.PUT_LINE('--- Receipt for Order #'||p_order_id||' ---');
      v_cursor := get_order_items(p_order_id);

      LOOP
         FETCH v_cursor INTO v_item_id, v_service_name, v_qty, v_subtotal;
         EXIT WHEN v_cursor%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE(RPAD(v_service_name,20)||' x'||v_qty||
                               '  ->  '||v_subtotal);
      END LOOP;
      CLOSE v_cursor;

      DBMS_OUTPUT.PUT_LINE('TOTAL: '||get_order_total(p_order_id));
   END print_receipt;

END pkg_laundry;
/

--------------------------------------------------------------------------------
-- Demo (comment out if not needed)
--------------------------------------------------------------------------------
DECLARE
   v_order_id orders.order_id%TYPE;
BEGIN
   pkg_laundry.register_order(2, 5, v_order_id);
   pkg_laundry.add_order_item(v_order_id, 2, 1);
   pkg_laundry.add_order_item(v_order_id, 4, 2);
   pkg_laundry.print_receipt(v_order_id);
END;
/
