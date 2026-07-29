/*
================================================================================
 File        : triggers.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_PL_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Simple triggers, a compound trigger (audit system + user
               activity tracking), and a security-restriction trigger that
               enforces the business rule below, all operating on the 5 core
               tables.

 Business Rule (as specified):
   "Block INSERT, UPDATE, DELETE during weekdays (Mon-Fri) and public
    holidays." This script implements the rule exactly as written: writes to
    ORDERS are permitted only on Saturday and Sunday, and are blocked on
    Monday-Friday and on any date listed in PUBLIC_HOLIDAYS. If your intent
    was the opposite (block weekends/holidays, allow Mon-Fri), simply swap
    the day list in trg_orders_restrict from ('MON','TUE','WED','THU','FRI')
    to ('SAT','SUN').

 Prerequisite: Run 28873_2025_Uriah_SQL_Scripts_DB/create_tables.sql
               and insert_data.sql first.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
================================================================================
*/

SET SERVEROUTPUT ON;
SET DEFINE OFF;

--------------------------------------------------------------------------------
-- 0. Supporting tables: AUDIT_LOG and PUBLIC_HOLIDAYS (safe / re-runnable)
--------------------------------------------------------------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE audit_log CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE public_holidays CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

CREATE TABLE public_holidays (
   holiday_date DATE          NOT NULL,
   description  VARCHAR2(100),
   CONSTRAINT pk_public_holidays PRIMARY KEY (holiday_date)
);

CREATE TABLE audit_log (
   audit_id    NUMBER        GENERATED ALWAYS AS IDENTITY,
   table_name  VARCHAR2(30)  NOT NULL,
   action      VARCHAR2(10)  NOT NULL,
   record_id   NUMBER,
   changed_by  VARCHAR2(30)  DEFAULT USER NOT NULL,
   changed_on  DATE          DEFAULT SYSDATE NOT NULL,
   CONSTRAINT pk_audit_log PRIMARY KEY (audit_id)
);

-- Sample public holidays (Rwanda, illustrative)
INSERT INTO public_holidays (holiday_date, description)
VALUES (DATE '2026-01-01', 'New Year''s Day');
INSERT INTO public_holidays (holiday_date, description)
VALUES (DATE '2026-04-07', 'Genocide Memorial Day');
INSERT INTO public_holidays (holiday_date, description)
VALUES (DATE '2026-07-01', 'Independence Day');
INSERT INTO public_holidays (holiday_date, description)
VALUES (DATE '2026-12-25', 'Christmas Day');
COMMIT;

--------------------------------------------------------------------------------
-- 1. SIMPLE TRIGGER: auto-maintain orders.total_amount from order_items
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_items_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
BEGIN
   UPDATE orders
      SET total_amount = (SELECT NVL(SUM(subtotal),0) FROM order_items
                            WHERE order_id = NVL(:NEW.order_id,:OLD.order_id))
    WHERE order_id = NVL(:NEW.order_id,:OLD.order_id);
END trg_items_total;
/

--------------------------------------------------------------------------------
-- 2. SIMPLE TRIGGER: normalize employee data before insert
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_employees_bi
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
   :NEW.role := UPPER(:NEW.role);
   IF :NEW.hire_date IS NULL THEN
      :NEW.hire_date := SYSDATE;
   END IF;
END trg_employees_bi;
/

--------------------------------------------------------------------------------
-- 3. COMPOUND TRIGGER: audit system + user activity tracking on ORDERS
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_orders_audit
FOR INSERT OR UPDATE OR DELETE ON orders
COMPOUND TRIGGER

   TYPE t_ids IS TABLE OF NUMBER;
   g_ids   t_ids := t_ids();
   g_action VARCHAR2(10);

   AFTER EACH ROW IS
   BEGIN
      g_ids.EXTEND;
      g_ids(g_ids.COUNT) := NVL(:NEW.order_id, :OLD.order_id);
   END AFTER EACH ROW;

   AFTER STATEMENT IS
   BEGIN
      IF UPDATING THEN
         g_action := 'UPDATE';
      ELSIF DELETING THEN
         g_action := 'DELETE';
      ELSE
         g_action := 'INSERT';
      END IF;

      FOR i IN 1 .. g_ids.COUNT LOOP
         INSERT INTO audit_log (table_name, action, record_id, changed_by)
         VALUES ('ORDERS', g_action, g_ids(i),
                 SYS_CONTEXT('USERENV','SESSION_USER'));
      END LOOP;
   END AFTER STATEMENT;

END trg_orders_audit;
/

--------------------------------------------------------------------------------
-- 4. SECURITY TRIGGER: block INSERT/UPDATE/DELETE on weekdays & holidays
--    (business rule as specified — see header note above)
--------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_orders_restrict
BEFORE INSERT OR UPDATE OR DELETE ON orders
FOR EACH ROW
DECLARE
   v_day        VARCHAR2(3);
   v_is_holiday NUMBER;
BEGIN
   v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');

   SELECT COUNT(*) INTO v_is_holiday
     FROM public_holidays
    WHERE holiday_date = TRUNC(SYSDATE);

   IF v_day IN ('MON','TUE','WED','THU','FRI') THEN
      RAISE_APPLICATION_ERROR(-20001,
         'DML blocked: writes to ORDERS are restricted on weekdays (Mon-Fri).');
   ELSIF v_is_holiday > 0 THEN
      RAISE_APPLICATION_ERROR(-20002,
         'DML blocked: writes to ORDERS are restricted on public holidays.');
   END IF;
END trg_orders_restrict;
/

--------------------------------------------------------------------------------
-- 5. Demo / self-test (safe on any day — expected errors are caught and
--    reported instead of failing the script)
--------------------------------------------------------------------------------
DECLARE
   v_day VARCHAR2(3) := TO_CHAR(SYSDATE,'DY','NLS_DATE_LANGUAGE=ENGLISH');
BEGIN
   DBMS_OUTPUT.PUT_LINE('Today is '||v_day||
      ' - attempting a test UPDATE on orders...');

   UPDATE orders SET status = status WHERE order_id = 1;
   COMMIT;

   DBMS_OUTPUT.PUT_LINE('Update allowed: today is not a restricted day.');
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE IN (-20001, -20002) THEN
         ROLLBACK;
         DBMS_OUTPUT.PUT_LINE('Update correctly blocked: '||SQLERRM);
      ELSE
         RAISE;
      END IF;
END;
/

--------------------------------------------------------------------------------
-- Verification
--------------------------------------------------------------------------------
COLUMN table_name FORMAT A15
COLUMN trigger_name FORMAT A25
COLUMN status FORMAT A10
SELECT table_name, trigger_name, status
  FROM user_triggers
 WHERE table_name IN ('ORDERS','ORDER_ITEMS','EMPLOYEES')
 ORDER BY table_name, trigger_name;

SELECT * FROM audit_log ORDER BY changed_on DESC;

PROMPT All triggers created successfully: trg_items_total, trg_employees_bi, trg_orders_audit, trg_orders_restrict.
