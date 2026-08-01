# SQL Injection

SQL injection occurs when untrusted input changes the meaning of a SQL query.

Defenses:

- Use parameterized queries or prepared statements.
- Use query builders or ORM APIs that bind values safely.
- Avoid concatenating untrusted input into SQL.
- Use least-privilege database accounts.
- Validate sort fields, column names, and table names with allowlists.

## Attack Variants

- UNION-based SQLi: an attacker appends a `UNION SELECT` to combine the query
  result with attacker-controlled rows.
- Blind SQLi: the query result is not returned directly, so the attacker infers
  information from differences in timing, error messages, or boolean outcomes.

## ORMs Are Not Automatic

- ORMs and query builders bind values safely only when used correctly.
- Raw queries, `LIKE` patterns, dynamic table or column names, and raw string
  fragments can still introduce injection.
- Always route untrusted values through the ORM's binding API.

Cross-links:

- [NoSQL injection](nosql-injection.md)
- [Injection attacks](injection-attacks.md)
- [Secure coding principles](secure-coding-principles.md)
