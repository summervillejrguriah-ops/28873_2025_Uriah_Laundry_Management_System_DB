/*
================================================================================
 File        : dml_ddl_transaction_control.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_PL_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Demonstrates DDL operations, DML operations, and transaction
               control (COMMIT / ROLLBACK / SAVEPOINT) on the 5 core tables.
 Prerequisite: Run 28873_2025_Uriah_SQL_Scripts_DB/create_tables.sql
               and insert_data.sql first.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
================================================================================
*/

SET SERVEROUTPUT ON;

--------------------------------------------------------------------------------
-- SECTION A: DDL OPERATIONS
--------------------------------------------------------------------------------

-- A1. ALTER TABLE: add a loyalty_points column to customers
BEGIN
   EXECUTE IMMEDIATE 'ALTER TABLE customers ADD loyalty_points NUMBER DEFAULT 0';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -1430 THEN -- column already exists
         DBMS_OUTPUT.PUT_LINE('loyalty_points column already exists, skipping.');
      ELSE
         RAISE;
      END IF;
END;
/

-- A2. CREATE INDEX: speed up lookups of orders by customer
BEGIN
   EXECUTE IMMEDIATE 'CREATE INDEX idx_orders_customer ON orders(customer_id)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -955 THEN -- index already exists
         DBMS_OUTPUT.PUT_LINE('idx_orders_customer already exists, skipping.');
      ELSE
         RAISE;
      END IF;
END;
/

-- A3. CREATE OR REPLACE VIEW: a reporting view joining all 5 tables
CREATE OR REPLACE VIEW vw_order_summary AS
   SELECT o.order_id, c.full_name AS customer_name, e.full_name AS employee_name,
          o.order_date, o.status, o.total_amount,
          s.service_name, oi.quantity, oi.subtotal
     FROM orders o
     JOIN customers c    ON c.customer_id  = o.customer_id
     JOIN employees e    ON e.employee_id  = o.employee_id
     JOIN order_items oi ON oi.order_id    = o.order_id
     JOIN services s     ON s.service_id   = oi.service_id;

--------------------------------------------------------------------------------
-- SECTION B: DML OPERATIONS
--------------------------------------------------------------------------------

-- B1. INSERT a new service
INSERT INTO services (service_name, price, description)
VALUES ('Blanket Cleaning', 3200, 'Deep wash for heavy blankets');

-- B2. UPDATE a service price
UPDATE services SET price = 1600 WHERE service_name = 'Wash & Fold';

-- B3. DELETE a cancelled order (order_items cascade via FK)
DELETE FROM orders WHERE status = 'CANCELLED' AND order_id = 7;

COMMIT;

--------------------------------------------------------------------------------
-- SECTION C: TRANSACTION CONTROL (COMMIT / ROLLBACK / SAVEPOINT)
--------------------------------------------------------------------------------
DECLARE
   v_new_order_id orders.order_id%TYPE;
BEGIN
   -- Start of transaction
   INSERT INTO orders (customer_id, employee_id, order_date, status, total_amount)
   VALUES (2, 3, SYSDATE, 'PENDING', 0)
   RETURNING order_id INTO v_new_order_id;

   SAVEPOINT after_order_created;

   INSERT INTO order_items (order_id, service_id, quantity, subtotal)
   VALUES (v_new_order_id, 1, 2, 3000);

   SAVEPOINT after_first_item;

   -- Simulate a problem with a second item (invalid service_id) and recover
   BEGIN
      INSERT INTO order_items (order_id, service_id, quantity, subtotal)
      VALUES (v_new_order_id, 9999, 1, 9999);
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Second item failed, rolling back to savepoint.');
         ROLLBACK TO after_first_item;
   END;

   UPDATE orders
      SET total_amount = (SELECT NVL(SUM(subtotal),0) FROM order_items
                            WHERE order_id = v_new_order_id)
    WHERE order_id = v_new_order_id;

   COMMIT;  -- commit order + first item only; second item was rolled back
   DBMS_OUTPUT.PUT_LINE('Transaction committed for order #'||v_new_order_id);
EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;  -- undo everything on any unexpected error
      DBMS_OUTPUT.PUT_LINE('Transaction rolled back entirely: '||SQLERRM);
END;
/

--------------------------------------------------------------------------------
-- Verification
--------------------------------------------------------------------------------
SELECT * FROM vw_order_summary WHERE ROWNUM <= 5;
