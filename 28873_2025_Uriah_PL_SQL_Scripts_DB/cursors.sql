/*
================================================================================
 File        : cursors.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_PL_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Demonstrates explicit cursors, cursor FOR loops, parameterized
               cursors, and REF CURSORs against the 5 core tables.
 Prerequisite: Run 28873_2025_Uriah_SQL_Scripts_DB/create_tables.sql
               and insert_data.sql first.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
================================================================================
*/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- 1. Explicit cursor: list all PENDING orders (open / fetch / close)
--------------------------------------------------------------------------------
DECLARE
   CURSOR c_pending IS
      SELECT o.order_id, c.full_name, o.order_date, o.total_amount
        FROM orders o
        JOIN customers c ON c.customer_id = o.customer_id
       WHERE o.status = 'PENDING'
       ORDER BY o.order_date;

   v_order_id  orders.order_id%TYPE;
   v_name      customers.full_name%TYPE;
   v_date      orders.order_date%TYPE;
   v_total     orders.total_amount%TYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('--- Pending Orders ---');
   OPEN c_pending;
   LOOP
      FETCH c_pending INTO v_order_id, v_name, v_date, v_total;
      EXIT WHEN c_pending%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Order #'||v_order_id||' | '||v_name||
                            ' | '||TO_CHAR(v_date,'DD-MON-YYYY')||
                            ' | '||v_total);
   END LOOP;
   CLOSE c_pending;
END;
/

--------------------------------------------------------------------------------
-- 2. Cursor FOR loop: total spend per customer (no explicit OPEN/FETCH/CLOSE)
--------------------------------------------------------------------------------
BEGIN
   DBMS_OUTPUT.PUT_LINE('--- Customer Spend Report ---');
   FOR rec IN (
      SELECT c.customer_id, c.full_name,
             NVL(SUM(o.total_amount),0) AS spend
        FROM customers c
        LEFT JOIN orders o ON o.customer_id = c.customer_id
       GROUP BY c.customer_id, c.full_name
       ORDER BY spend DESC
   ) LOOP
      DBMS_OUTPUT.PUT_LINE(rec.full_name||' -> '||rec.spend);
   END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 3. Parameterized cursor: fetch orders for a given status
--------------------------------------------------------------------------------
DECLARE
   CURSOR c_by_status (p_status VARCHAR2) IS
      SELECT order_id, customer_id, total_amount
        FROM orders
       WHERE status = p_status;
BEGIN
   DBMS_OUTPUT.PUT_LINE('--- Completed Orders ---');
   FOR rec IN c_by_status('COMPLETED') LOOP
      DBMS_OUTPUT.PUT_LINE('Order #'||rec.order_id||
                            ' (customer '||rec.customer_id||') = '||
                            rec.total_amount);
   END LOOP;
END;
/

--------------------------------------------------------------------------------
-- 4. REF CURSOR: dynamically report order_items for a given order
--------------------------------------------------------------------------------
DECLARE
   TYPE t_ref_cursor IS REF CURSOR;
   v_cursor        t_ref_cursor;
   v_service_name  services.service_name%TYPE;
   v_qty           order_items.quantity%TYPE;
   v_subtotal      order_items.subtotal%TYPE;
   v_order_id      orders.order_id%TYPE := 1;
BEGIN
   OPEN v_cursor FOR
      SELECT s.service_name, oi.quantity, oi.subtotal
        FROM order_items oi
        JOIN services s ON s.service_id = oi.service_id
       WHERE oi.order_id = v_order_id;

   DBMS_OUTPUT.PUT_LINE('--- Items for Order #'||v_order_id||' (REF CURSOR) ---');
   LOOP
      FETCH v_cursor INTO v_service_name, v_qty, v_subtotal;
      EXIT WHEN v_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(v_service_name||' x'||v_qty||' = '||v_subtotal);
   END LOOP;
   CLOSE v_cursor;
END;
/

--------------------------------------------------------------------------------
-- 5. Cursor with %ROWTYPE: bulk-style single-row processing of employees
--------------------------------------------------------------------------------
DECLARE
   CURSOR c_employees IS SELECT * FROM employees ORDER BY employee_id;
   v_emp c_employees%ROWTYPE;
BEGIN
   DBMS_OUTPUT.PUT_LINE('--- Employee Roster ---');
   OPEN c_employees;
   LOOP
      FETCH c_employees INTO v_emp;
      EXIT WHEN c_employees%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(v_emp.employee_id||' - '||v_emp.full_name||
                            ' ('||v_emp.role||')');
   END LOOP;
   CLOSE c_employees;
END;
/
