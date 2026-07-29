/*
================================================================================
 File        : functions.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_PL_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Reusable stored functions operating on the 5 core tables.
 Prerequisite: Run 28873_2025_Uriah_SQL_Scripts_DB/create_tables.sql first.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
================================================================================
*/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- 1. get_order_total : sums the subtotal of every item on an order
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_order_total (
   p_order_id IN order_items.order_id%TYPE
) RETURN NUMBER
IS
   v_total NUMBER := 0;
BEGIN
   SELECT NVL(SUM(subtotal), 0) INTO v_total
     FROM order_items
    WHERE order_id = p_order_id;

   RETURN v_total;
END get_order_total;
/

--------------------------------------------------------------------------------
-- 2. get_customer_total_spent : lifetime spend of a customer (completed orders)
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_customer_total_spent (
   p_customer_id IN customers.customer_id%TYPE
) RETURN NUMBER
IS
   v_total NUMBER := 0;
BEGIN
   SELECT NVL(SUM(total_amount), 0) INTO v_total
     FROM orders
    WHERE customer_id = p_customer_id
      AND status = 'COMPLETED';

   RETURN v_total;
END get_customer_total_spent;
/

--------------------------------------------------------------------------------
-- 3. count_orders_by_status : how many orders are currently in a given status
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION count_orders_by_status (
   p_status IN orders.status%TYPE
) RETURN NUMBER
IS
   v_count NUMBER;
BEGIN
   SELECT COUNT(*) INTO v_count FROM orders WHERE status = p_status;
   RETURN v_count;
END count_orders_by_status;
/

--------------------------------------------------------------------------------
-- 4. get_service_price : looks up the current price of a service
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_service_price (
   p_service_id IN services.service_id%TYPE
) RETURN NUMBER
IS
   v_price services.price%TYPE;
BEGIN
   SELECT price INTO v_price FROM services WHERE service_id = p_service_id;
   RETURN v_price;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN NULL;
END get_service_price;
/

--------------------------------------------------------------------------------
-- 5. is_valid_customer : returns 'Y'/'N' — used inside other PL/SQL blocks
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION is_valid_customer (
   p_customer_id IN customers.customer_id%TYPE
) RETURN VARCHAR2
IS
   v_count NUMBER;
BEGIN
   SELECT COUNT(*) INTO v_count FROM customers WHERE customer_id = p_customer_id;
   RETURN CASE WHEN v_count > 0 THEN 'Y' ELSE 'N' END;
END is_valid_customer;
/

--------------------------------------------------------------------------------
-- Demo (comment out if not needed)
--------------------------------------------------------------------------------
BEGIN
   DBMS_OUTPUT.PUT_LINE('Order #1 total       : '||get_order_total(1));
   DBMS_OUTPUT.PUT_LINE('Customer #1 spent     : '||get_customer_total_spent(1));
   DBMS_OUTPUT.PUT_LINE('Pending orders count  : '||count_orders_by_status('PENDING'));
   DBMS_OUTPUT.PUT_LINE('Service #1 price      : '||get_service_price(1));
   DBMS_OUTPUT.PUT_LINE('Is customer #1 valid? : '||is_valid_customer(1));
END;
/
