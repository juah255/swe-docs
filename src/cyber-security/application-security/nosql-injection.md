# NoSQL Injection

NoSQL databases such as MongoDB and Elasticsearch parse query operators from
input, so injection is possible even without SQL syntax.

How it works:

- Queries are built from objects rather than SQL strings.
- Operators such as `$gt`, `$ne`, `$where`, and `$or` change query behavior.
- When untrusted input is placed directly into a query object, an attacker can
  inject these operators.
- For example, a login check can be bypassed by supplying `$ne` in a password
  field so the comparison matches any non-null value.

Defenses:

- Use driver parameterization or sanitization so input is treated as data.
- Validate input types; reject objects and arrays where strings are expected.
- Avoid `$where` clauses and other string-based JavaScript evaluation.
- Use least-privilege database accounts.
- Apply the same allowlist and boundary validation used for SQL.

Cross-links:

- [SQL injection](sql-injection.md)
- [Injection attacks](injection-attacks.md)
- [Input validation](input-validation.md)
