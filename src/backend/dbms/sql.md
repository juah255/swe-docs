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
