# Path Traversal

Path traversal occurs when input changes a filesystem path outside the intended
directory.

Defenses:

- Use object storage IDs instead of raw paths.
- Normalize and validate paths.
- Restrict access to an allowed base directory.
- Avoid serving files based directly on user-provided paths.

Cross-links:

- [File upload security](file-upload-security.md)
- [Injection attacks](injection-attacks.md)
- [Secure coding principles](secure-coding-principles.md)
