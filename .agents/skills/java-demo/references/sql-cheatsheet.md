# SQL Cheat Sheet

## SELECT building blocks
```sql
SELECT  c.id, c.name, COUNT(o.id) AS orders
FROM    customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE   c.created_at >= '2026-01-01'
GROUP BY c.id, c.name
HAVING  COUNT(o.id) > 3
ORDER BY orders DESC
LIMIT  20;
```

## Window functions
| Function | Use |
|---|---|
| `ROW_NUMBER() OVER (PARTITION BY x ORDER BY y)` | rank within group, no ties |
| `RANK() / DENSE_RANK()` | ranked with/without gaps |
| `LAG(col) OVER (...)` / `LEAD(col)` | previous / next row value |
| `SUM(x) OVER (PARTITION BY ..)` | running / grouped total |

## CTE
```sql
WITH recent AS (
  SELECT * FROM orders WHERE created_at >= NOW() - INTERVAL '30 days'
)
SELECT customer_id, COUNT(*) FROM recent GROUP BY customer_id;
```

## Index DDL
```sql
CREATE INDEX idx_orders_cust_status
  ON orders (customer_id, status);          -- equality cols first
CREATE UNIQUE INDEX uq_email ON users (email);
```

## Pagination
```sql
-- keyset (preferred for deep pages)
SELECT * FROM orders WHERE id < :last_id ORDER BY id DESC LIMIT 20;
-- offset (simple, slow when deep)
SELECT * FROM orders ORDER BY id DESC LIMIT 20 OFFSET 100;
```

## MySQL vs PostgreSQL notes
| Topic | MySQL | PostgreSQL |
|---|---|---|
| Limit | `LIMIT n OFFSET m` | same |
| String concat | `CONCAT(a,b)` | `a || b` |
| Upsert | `INSERT ... ON DUPLICATE KEY UPDATE` | `INSERT ... ON CONFLICT DO UPDATE` |
| Bool | `TINYINT(1)` | `BOOLEAN` |
| UUID | `CHAR(36)` / `BINARY(16)` | `UUID` type |

## NULL traps
- `NULL = NULL` is **unknown** (not true) → use `IS NULL`.
- `COALESCE(col, 0)` to substitute a default.
- `COUNT(col)` skips NULL rows; `COUNT(*)` counts all.
