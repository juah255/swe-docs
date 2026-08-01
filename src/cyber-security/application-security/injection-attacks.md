# Injection Attacks

Injection happens when untrusted input is interpreted as code, commands, query
syntax, file paths, or internal instructions. The attacker provides input that
the interpreter executes as if it were part of the program.

General defense: parameterize or encode input, and never concatenate untrusted
input into an interpreter. Treat input as data, not as instructions.

Specific injection types:

- [SQL Injection](sql-injection.md): input changes the meaning of a SQL query.
- [NoSQL Injection](nosql-injection.md): input changes query operators in NoSQL
  databases.
- [Command Injection](command-injection.md): input reaches an operating system
  command.
- [Server-Side Request Forgery](ssrf.md): input controls an outbound request
  target.
- [XML External Entity](xxe.md): input causes the XML parser to process external
  entities.
- [Path Traversal](path-traversal.md): input changes a filesystem path outside
  the intended directory.
- Template injection: input is rendered as template code rather than plain text.

Related:

- [Input validation](input-validation.md)
- [Secure coding principles](secure-coding-principles.md)
