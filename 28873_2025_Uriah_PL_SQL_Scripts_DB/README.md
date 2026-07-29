# 28873_2025_Uriah_PL_SQL_Scripts_DB

PL/SQL scripts for the **Laundry Management System** database (Database Programming — UNILAK).

**Student:** G. Uriah Summerville, Jr &nbsp;|&nbsp; **Reg. Number:** 28873/2025

## Contents

| File | Description |
|---|---|
| `procedure.sql` | Standalone procedures: `add_customer`, `add_order`, `add_order_item`, `update_order_status`, `delete_order`. |
| `functions.sql` | Standalone functions: `get_order_total`, `get_customer_total_spent`, `count_orders_by_status`, `get_service_price`, `is_valid_customer`. |
| `packages.sql` | `PKG_LAUNDRY` package bundling order registration, item entry, order totals, a `SYS_REFCURSOR`-returning function, and a receipt printer. |
| `cursors.sql` | Explicit cursors, cursor `FOR` loops, a parameterized cursor, a `REF CURSOR`, and a `%ROWTYPE` cursor. |
| `exception_handling.sql` | Predefined exceptions (`NO_DATA_FOUND`, `TOO_MANY_ROWS`, `DUP_VAL_ON_INDEX`, `ZERO_DIVIDE`), `PRAGMA EXCEPTION_INIT`, user-defined exceptions, and nested exception blocks. |
| `dml_ddl_transaction_control.sql` | DDL (`ALTER TABLE`, `CREATE INDEX`, `CREATE VIEW`), DML (`INSERT`/`UPDATE`/`DELETE`), and transaction control (`COMMIT`, `ROLLBACK`, `SAVEPOINT`). |
| `triggers.sql` | Simple triggers, a **compound trigger** implementing an audit system and user-activity tracking, and a **security-restriction trigger** enforcing the weekday/public-holiday business rule below. Creates the supporting `AUDIT_LOG` and `PUBLIC_HOLIDAYS` tables. |

## Business rule enforced by `trg_orders_restrict`

> Block INSERT, UPDATE, DELETE on `ORDERS` during weekdays (Mon–Fri) and on any date stored in `PUBLIC_HOLIDAYS`. Writes are permitted on Saturday and Sunday only.

If your grading rubric intends the opposite (block weekends/holidays, allow Mon–Fri), change the day list inside `trg_orders_restrict` from `('MON','TUE','WED','THU','FRI')` to `('SAT','SUN')` — the rest of the logic (holiday check, error codes, audit trail) stays the same.

## How to run

Run in Oracle **SQL\*Plus** or **SQL Developer**, connected to the same schema used for `28873_2025_Uriah_SQL_Scripts_DB` (tables `customers`, `employees`, `services`, `orders`, `order_items` must already exist), in this order:

```sql
@procedure.sql
@functions.sql
@packages.sql
@cursors.sql
@exception_handling.sql
@dml_ddl_transaction_control.sql
@triggers.sql
```

Each script prints `DBMS_OUTPUT` messages confirming success — make sure `SET SERVEROUTPUT ON` is enabled (each script sets it automatically).
