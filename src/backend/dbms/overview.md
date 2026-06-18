# DBMS

## Questions and Topics

### When do we need a database trigger?

**Answer:** Use a trigger when a rule must run inside the database whenever a
table changes, regardless of which application or script made the change.

Real examples include maintaining audit tables, updating summary counters,
enforcing cross-table invariants, or writing change records for replication.
Avoid triggers for complex business workflows that are easier to understand and
test in application code.

### Stored Procedure vs. Function

**Answer:** A function usually returns a value and can often be used inside SQL
expressions. A stored procedure usually represents an operation and may perform
multiple statements, transaction control, or side effects depending on the
database.

Use them when logic needs to run close to the data for consistency or
performance. Avoid hiding too much application behavior in the database unless
the team can version, test, deploy, and observe it properly.

### What does a subquery return?

**Answer:** A subquery can return a scalar value, one column with many rows,
multiple columns and rows, or only existence information depending on where it
is used.

For example, `salary > (SELECT AVG(salary) FROM employees)` expects one scalar
value. `WHERE id IN (SELECT user_id FROM orders)` expects a one-column set.
`EXISTS` only checks whether the subquery returns at least one row.

### Can I find employees whose salary is greater than the average without a subquery?

**Answer:** Yes. A window function can compute the average across the result set
and then filter from an outer query. Some databases also allow joining against a
derived aggregate result.

Example pattern:

```sql
SELECT *
FROM (
  SELECT employees.*, AVG(salary) OVER () AS avg_salary
  FROM employees
) ranked
WHERE salary > avg_salary;
```

### Why do we need a composite key?

**Answer:** A composite key is useful when a row is uniquely identified by more
than one column. Junction tables often use composite keys such as
`(student_id, course_id)`.

The trade-off is that foreign keys and joins become wider. Many systems still
add a surrogate `id` for convenience while keeping a unique constraint on the
natural composite key.

### Explain the N+1 problem

**Answer:** The N+1 problem happens when code runs one query to load parent rows
and then one additional query for each parent row. Loading 100 users and then
loading posts user by user causes 101 queries.

Avoid it with eager loading, joins, batch queries, dataloaders, or explicit
query design. Always inspect generated SQL when using an ORM.

## Managed Databases

- **Supabase PostgreSQL**
- **Amazon RDS**
- **Google Cloud SQL**
- **PlanetScale**
- **Neon**

## Mid/Senior Interview Questions and Answers

### 1. When should database logic live in triggers or stored procedures?

**Answer:** Put logic in the database when it must be enforced for all writers,
needs strong consistency near the data, or reduces heavy data transfer. Keep it
in application code when it is complex business workflow that needs ordinary
testing, versioning, and observability.

The senior answer is not "never use triggers." It is to use them deliberately
for integrity and audit-style concerns.

### 2. How do you choose between managed and self-managed databases?

**Answer:** Managed databases reduce operational burden for backups, patching,
replication, failover, and monitoring. Self-managed databases offer more control
but require stronger operational expertise.

For most product teams, managed databases are the safer default unless cost,
compliance, custom extensions, or unusual performance needs justify
self-management.

### 3. What is the N+1 problem in an ORM-backed API?

**Answer:** An endpoint loads a list of records, then lazy-loads related records
one by one. The result is many small queries instead of a small number of
intentional queries.

Fix it with eager loading, preloading, joins, batching, or query-specific DTOs.
