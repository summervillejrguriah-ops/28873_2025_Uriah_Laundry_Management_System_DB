/*
================================================================================
 File        : exception_handling.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_PL_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Demonstrates predefined exceptions, PRAGMA EXCEPTION_INIT,
               user-defined exceptions, and nested exception blocks against
               the 5 core tables.
 Prerequisite: Run 28873_2025_Uriah_SQL_Scripts_DB/create_tables.sql
               and insert_data.sql first.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
================================================================================
*/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- 1. NO_DATA_FOUND : looking up a service that does not exist
--------------------------------------------------------------------------------
DECLARE
   v_price services.price%TYPE;
BEGIN
   SELECT price INTO v_price FROM services WHERE service_id = 9999;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('[NO_DATA_FOUND] Service 9999 does not exist.');
END;
/

--------------------------------------------------------------------------------
-- 2. TOO_MANY_ROWS : a SELECT ... INTO that matches more than one row
--------------------------------------------------------------------------------
DECLARE
   v_id customers.customer_id%TYPE;
BEGIN
   SELECT customer_id INTO v_id FROM customers WHERE customer_id > 0;
EXCEPTION
   WHEN TOO_MANY_ROWS THEN
      DBMS_OUTPUT.PUT_LINE('[TOO_MANY_ROWS] Query returned more than one row.');
END;
/

--------------------------------------------------------------------------------
-- 3. DUP_VAL_ON_INDEX : inserting a duplicate unique/primary-key value
--------------------------------------------------------------------------------
DECLARE
   v_dummy customers.phone%TYPE;
BEGIN
   SELECT phone INTO v_dummy FROM customers WHERE ROWNUM = 1;

   INSERT INTO customers (full_name, phone) VALUES ('Duplicate Test', v_dummy);
   COMMIT;
EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('[DUP_VAL_ON_INDEX] Phone number already in use.');
END;
/

--------------------------------------------------------------------------------
-- 4. ZERO_DIVIDE : average order value when there happen to be zero orders
--------------------------------------------------------------------------------
DECLARE
   v_order_count NUMBER;
   v_total       NUMBER;
   v_average     NUMBER;
BEGIN
   SELECT COUNT(*), NVL(SUM(total_amount),0)
     INTO v_order_count, v_total
     FROM orders
    WHERE customer_id = -1;                  -- guaranteed no matches

   v_average := v_total / v_order_count;      -- division by zero
EXCEPTION
   WHEN ZERO_DIVIDE THEN
      DBMS_OUTPUT.PUT_LINE('[ZERO_DIVIDE] No orders found for that customer.');
END;
/

--------------------------------------------------------------------------------
-- 5. PRAGMA EXCEPTION_INIT : name an Oracle error explicitly
--    ORA-02291: integrity constraint violated - parent key not found
--------------------------------------------------------------------------------
DECLARE
   e_fk_violation EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_fk_violation, -2291);
BEGIN
   INSERT INTO orders (customer_id, employee_id, order_date, status, total_amount)
   VALUES (99999, 99999, SYSDATE, 'PENDING', 0);   -- non-existent parent rows
   COMMIT;
EXCEPTION
   WHEN e_fk_violation THEN
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('[EXCEPTION_INIT -2291] Customer or employee '||
                            'does not exist.');
END;
/

--------------------------------------------------------------------------------
-- 6. User-defined exception + RAISE_APPLICATION_ERROR (custom business rule)
--------------------------------------------------------------------------------
DECLARE
   e_invalid_quantity EXCEPTION;
   v_qty NUMBER := -3;
BEGIN
   IF v_qty <= 0 THEN
      RAISE e_invalid_quantity;
   END IF;
EXCEPTION
   WHEN e_invalid_quantity THEN
      DBMS_OUTPUT.PUT_LINE('[USER-DEFINED] Quantity must be positive.');
      -- Re-signal as an application error visible to the calling client:
      -- RAISE_APPLICATION_ERROR(-20030, 'Invalid order quantity.');
END;
/

--------------------------------------------------------------------------------
-- 7. Nested exception blocks with WHEN OTHERS + SQLCODE/SQLERRM
--------------------------------------------------------------------------------
DECLARE
   v_price services.price%TYPE;
BEGIN
   BEGIN
      SELECT price INTO v_price FROM services WHERE service_id = -1;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         DBMS_OUTPUT.PUT_LINE('[NESTED] Inner block: service not found, '||
                               'defaulting price to 0.');
         v_price := 0;
   END;

   DBMS_OUTPUT.PUT_LINE('Continuing outer block with price = '||v_price);
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('[OUTER] Unexpected error '||SQLCODE||': '||SQLERRM);
END;
/
