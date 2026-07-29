/*
================================================================================
 File        : create_tables.sql
 Project     : Laundry Management System
 Folder      : 28873_2025_Uriah_SQL_Scripts_DB
 Student     : G. Uriah Summerville, Jr
 Reg. Number : 28873/2025
 Course      : Database Programming - UNILAK
 Purpose     : Creates the 5 core tables of the Laundry Management System
               (customers, employees, services, orders, order_items) with
               primary keys, foreign keys, NOT NULL, UNIQUE and CHECK
               constraints.
 Tested on   : Oracle SQL*Plus and Oracle SQL Developer (Oracle 12c+)
 Run order   : 1) create_tables.sql   2) insert_data.sql
================================================================================
*/

SET SERVEROUTPUT ON;
SET DEFINE OFF;
WHENEVER SQLERROR CONTINUE;

--------------------------------------------------------------------------------
-- 0. Clean slate: drop tables if they already exist (safe / re-runnable)
--    Child tables are dropped before parent tables to avoid FK errors.
--------------------------------------------------------------------------------
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE order_items CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE; END IF; -- -942 = table does not exist
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE orders CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE services CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE employees CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE customers CASCADE CONSTRAINTS PURGE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

--------------------------------------------------------------------------------
-- 1. CUSTOMERS
--------------------------------------------------------------------------------
CREATE TABLE customers (
   customer_id   NUMBER         GENERATED ALWAYS AS IDENTITY
                                 (START WITH 1 INCREMENT BY 1),
   full_name     VARCHAR2(80)   NOT NULL,
   phone         VARCHAR2(15)   NOT NULL,
   email         VARCHAR2(100),
   address       VARCHAR2(150),
   CONSTRAINT pk_customers        PRIMARY KEY (customer_id),
   CONSTRAINT uq_customers_phone  UNIQUE (phone)
);

--------------------------------------------------------------------------------
-- 2. EMPLOYEES
--------------------------------------------------------------------------------
CREATE TABLE employees (
   employee_id   NUMBER         GENERATED ALWAYS AS IDENTITY
                                 (START WITH 1 INCREMENT BY 1),
   full_name     VARCHAR2(80)   NOT NULL,
   role          VARCHAR2(20)   NOT NULL,
   phone         VARCHAR2(15),
   hire_date     DATE           DEFAULT SYSDATE NOT NULL,
   CONSTRAINT pk_employees        PRIMARY KEY (employee_id),
   CONSTRAINT uq_employees_phone  UNIQUE (phone),
   CONSTRAINT ck_employees_role   CHECK (role IN
                                   ('MANAGER','ATTENDANT','WASHER','CASHIER'))
);

--------------------------------------------------------------------------------
-- 3. SERVICES
--------------------------------------------------------------------------------
CREATE TABLE services (
   service_id    NUMBER         GENERATED ALWAYS AS IDENTITY
                                 (START WITH 1 INCREMENT BY 1),
   service_name  VARCHAR2(50)   NOT NULL,
   price         NUMBER(8,2)    NOT NULL,
   description   VARCHAR2(200),
   CONSTRAINT pk_services         PRIMARY KEY (service_id),
   CONSTRAINT uq_services_name    UNIQUE (service_name),
   CONSTRAINT ck_services_price   CHECK (price > 0)
);

--------------------------------------------------------------------------------
-- 4. ORDERS  (references customers, employees)
--------------------------------------------------------------------------------
CREATE TABLE orders (
   order_id      NUMBER         GENERATED ALWAYS AS IDENTITY
                                 (START WITH 1 INCREMENT BY 1),
   customer_id   NUMBER         NOT NULL,
   employee_id   NUMBER         NOT NULL,
   order_date    DATE           DEFAULT SYSDATE NOT NULL,
   status        VARCHAR2(20)   DEFAULT 'PENDING' NOT NULL,
   total_amount  NUMBER(10,2)   DEFAULT 0 NOT NULL,
   CONSTRAINT pk_orders            PRIMARY KEY (order_id),
   CONSTRAINT fk_orders_customers  FOREIGN KEY (customer_id)
                                    REFERENCES customers (customer_id),
   CONSTRAINT fk_orders_employees  FOREIGN KEY (employee_id)
                                    REFERENCES employees (employee_id),
   CONSTRAINT ck_orders_status     CHECK (status IN
                                    ('PENDING','WASHING','READY',
                                     'COMPLETED','CANCELLED')),
   CONSTRAINT ck_orders_total      CHECK (total_amount >= 0)
);

--------------------------------------------------------------------------------
-- 5. ORDER_ITEMS  (references orders, services)
--------------------------------------------------------------------------------
CREATE TABLE order_items (
   order_item_id NUMBER         GENERATED ALWAYS AS IDENTITY
                                 (START WITH 1 INCREMENT BY 1),
   order_id      NUMBER         NOT NULL,
   service_id    NUMBER         NOT NULL,
   quantity      NUMBER(4)      NOT NULL,
   subtotal      NUMBER(10,2)   NOT NULL,
   CONSTRAINT pk_order_items       PRIMARY KEY (order_item_id),
   CONSTRAINT fk_items_orders      FOREIGN KEY (order_id)
                                    REFERENCES orders (order_id)
                                    ON DELETE CASCADE,
   CONSTRAINT fk_items_services    FOREIGN KEY (service_id)
                                    REFERENCES services (service_id),
   CONSTRAINT ck_items_quantity    CHECK (quantity > 0),
   CONSTRAINT ck_items_subtotal    CHECK (subtotal >= 0)
);

--------------------------------------------------------------------------------
-- Confirmation
--------------------------------------------------------------------------------
COLUMN table_name FORMAT A20
SELECT table_name FROM user_tables
 WHERE table_name IN ('CUSTOMERS','EMPLOYEES','SERVICES','ORDERS','ORDER_ITEMS')
 ORDER BY table_name;

PROMPT All 5 tables created successfully: CUSTOMERS, EMPLOYEES, SERVICES, ORDERS, ORDER_ITEMS.
