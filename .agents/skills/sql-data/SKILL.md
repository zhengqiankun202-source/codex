---
name: sql-data
description: Practical SQL and data-modeling assistant for backend developers. Use when writing queries, designing tables, adding indexes, planning schema migrations (Flyway/Liquibase), or debugging slow/incorrect queries. Covers query patterns, indexing rules, normalization, and pitfalls like NULL handling and N+1.
metadata:
  short-description: SQL queries, indexing & schema design
---

# SQL & Data

Practical SQL and modeling for application developers. Assume standard SQL (PostgreSQL/MySQL
dialect notes where they matter). A query/index cheat sheet is in `references/sql-cheatsheet.md`.

## When to use

- Writing a non-trivial `SELECT` (joins, aggregation, window functions, CTEs).
- Designing or changing a table; deciding types, keys, indexes.
- Planning a schema migration that must be safe in production.
- Debugging slow queries or wrong result sets.

## Query patterns

- **Joins**: `INNER` for required relations, `LEFT` to keep the left row when the right may be absent.
- **Aggregation + window**: use window functions instead of self-joins for ranks/running totals:
  ```sql
  SELECT user_id, order_id,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at DESC) AS rn
  FROM orders;
  ```
- **CTEs** for readable multi-step queries: `WITH recent AS (...) SELECT ... FROM recent`.
- **Keyset (seek) pagination** instead of `OFFSET` for deep pages (avoids full scan):
  ```sql
  SELECT * FROM orders WHERE created_at < :last_seen ORDER BY created_at DESC LIMIT 20;
  ```

## Indexing rules

- Index columns in `WHERE`, `JOIN ... ON`, and `ORDER BY` that are high-cardinality.
- **Composite index order matters**: most selective / equality columns first, then range.
- Don't put a function on an indexed column (`WHERE DATE(created_at)=...` kills the index); rewrite
  to a range.
- **Covering indexes** (include the selected columns) let queries return without hitting the table.
- Too many indexes slow `INSERT`/`UPDATE` — index for the queries you actually run.

## Schema design

- Normalize to ~3NF, then denormalize only read hotspots that justify it.
- Always have a primary key; add `created_at`, `updated_at` (and a soft-delete flag when needed).
- Pick the right type: integer/enum for status flags (not `VARCHAR`); `DECIMAL` for money (never
  `FLOAT`); `UUID`/`BIGINT` for IDs per scale needs.
- Constraints over code: `NOT NULL`, `UNIQUE`, `FK` enforce integrity at the DB, not just the app.

## Migrations (Flyway / Liquibase)

- Never alter prod via ad-hoc SQL in the app — use versioned migrations.
- Prefer **additive, backward-compatible** changes (add column nullable, backfill, then enforce).
- One logical change per migration; name `V1_2__add_orders_index.sql`.
- Repeatable migrations (`R__`) for views/functions that should always match current definition.

## With app data layers (JPA / MyBatis / MyBatis-Plus)

- **Parameterize everything** — never concatenate user input into SQL (injection risk).
- The "N+1 problem" often starts in SQL: a loop issuing one query per row. Fix with a single join
  or `IN (...)` batch, or server-side `JOIN FETCH` / `@EntityGraph`.
- Let the ORM generate keys/identifiers; don't mix app-generated and DB-generated PKs.

## Gotchas

- `NULL` is not equal to anything, not even itself — use `IS NULL` / `IS NOT NULL`, `COALESCE`.
- Implicit type conversion (`string` vs `int` compare) silently disables an index.
- `COUNT(*)` counts rows; `COUNT(col)` ignores NULLs — know which you need.
- `SELECT *` in production code is fragile and can break on column renames / ordering.
