# 28873_2025_Uriah_SQL_Scripts_DB

SQL scripts for the **Laundry Management System** database (Database Programming — UNILAK).

**Student:** G. Uriah Summerville, Jr &nbsp;|&nbsp; **Reg. Number:** 28873/2025

## Contents

| File | Description |
|---|---|
| `create_tables.sql` | Creates the 5 core tables — `customers`, `employees`, `services`, `orders`, `order_items` — with primary keys, foreign keys, `NOT NULL`, `UNIQUE`, and `CHECK` constraints. Script is re-runnable (drops tables first if they exist). |
| `insert_data.sql` | Inserts realistic sample data: 10 customers, 10 employees, 10 services, 12 orders, and 20 order items, then syncs `orders.total_amount` and commits. |

## How to run

Run in Oracle **SQL\*Plus** or **SQL Developer**, in this order, connected to your application schema (e.g. `laundry_admin`):

```sql
@create_tables.sql
@insert_data.sql
```

Both scripts have been tested to execute without errors on Oracle Database 12c and later.
