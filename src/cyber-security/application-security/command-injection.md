# Command Injection

Command injection occurs when input reaches an operating system command.

Defenses:

- Avoid shell execution for user-controlled input.
- Prefer library APIs over command-line calls.
- Pass arguments as structured arrays when execution is required.
- Validate inputs with allowlists.
- Run processes with least privilege.

Cross-links:

- [Injection attacks](injection-attacks.md)
- [Secure coding principles](secure-coding-principles.md)
