# SQL

SQL (Structured Query Language) is used to define, query, and modify data in relational databases.

## Core Topics

- Data definition: `CREATE`, `ALTER`, and `DROP`
- Data manipulation: `SELECT`, `INSERT`, `UPDATE`, and `DELETE`
- Filtering, sorting, and grouping
- Joins and subqueries
- Aggregate and window functions
- Constraints and data integrity
- Common table expressions

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between `WHERE` and `HAVING`?

**Answer:** `WHERE` filters rows before grouping. `HAVING` filters groups after
aggregation.

Use `WHERE` for row-level conditions and `HAVING` for aggregate conditions such
as `COUNT(*) > 5`.

### 2. What is the difference between `UNION` and `UNION ALL`?

**Answer:** `UNION` combines results and removes duplicates. `UNION ALL`
combines results without deduplication.

`UNION ALL` is usually faster because the database does not need to sort or hash
to remove duplicates.

### 3. When should you use a window function?

**Answer:** Use a window function when you need calculations across related rows
without collapsing rows into groups.

Examples include ranking, running totals, moving averages, percentiles, and
finding the latest row per group.

### 4. How do joins differ from subqueries?

**Answer:** A join combines rows from multiple tables in the result. A subquery
is a query nested inside another query and may return a scalar, list, table, or
existence check depending on context.

Modern optimizers can often rewrite one form into another. Choose the form that
is clear, then verify performance with the query plan.

### 5. How do constraints support application correctness?

**Answer:** Constraints enforce rules at the database layer: primary keys,
foreign keys, unique constraints, check constraints, and not-null constraints.

They protect data even when bugs, concurrent requests, scripts, or multiple
services write to the database.

### 6. Design a database for an online bookstore.

**Answer:** Tables:

- **books** (`book_id` PK, title, author, `isbn` UNIQUE, price, stock, genre, `created_at`)
- **authors** (`author_id` PK, name, bio)
- **customers** (`customer_id` PK, name, email UNIQUE, `password_hash`, `created_at`)
- **orders** (`order_id` PK, `customer_id` FK→customers, total, status, `created_at`)
- **order_items** (`order_item_id` PK, `order_id` FK→orders, `book_id` FK→books, quantity, `price_at_purchase`)
- **reviews** (`review_id` PK, `book_id` FK→books, `customer_id` FK→customers, rating 1–5, comment, `created_at`)

Relationships:

- books ↔ authors: many-to-many (`book_authors` junction table)
- customers → orders: one-to-many
- orders → order_items: one-to-many
- books → order_items: one-to-many
- books → reviews: one-to-many
- customers → reviews: one-to-many

Key decisions:

- `price_at_purchase` in order_items captures price at time of order (price may
  change).
- ISBN as unique constraint prevents duplicate book entries.
- Soft delete for books (`is_active` flag) to preserve order history.

### 7. What is the difference between `INNER JOIN`, `LEFT JOIN`, and `RIGHT JOIN`?

**Answer:**

- **`INNER JOIN`**: returns only rows that match in both tables. If a customer
  has no orders, they don't appear.
- **`LEFT JOIN`**: returns all rows from the left table and matching rows from the
  right. Non-matching right rows are `NULL`. Good for "all customers, with their
  orders if any."
- **`RIGHT JOIN`**: returns all rows from the right table and matching from the
  left. Rarely used; can be rewritten as `LEFT JOIN` by swapping table order.

In practice, `LEFT JOIN` is used much more often than `RIGHT JOIN`.

### 8. When can an index hurt performance?

**Answer:** An index is a data structure (usually B-tree) that speeds up lookups.
It hurts performance when:

- too many indexes slow writes (`INSERT`/`UPDATE`/`DELETE` must update every
  index);
- low-selectivity columns are indexed (e.g., a boolean `gender` column);
- the table is small enough that a full scan is faster; or
- unused indexes waste storage and maintenance time.

Rule: index columns used in `WHERE`, `JOIN`, and `ORDER BY`. Don't index
everything.
