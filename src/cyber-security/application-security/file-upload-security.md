# File Upload Security

File uploads are risky because uploaded files can be executed, contain malware,
or store unexpected content.

Defenses:

- Validate file type by content, not by extension or client-supplied MIME type.
- Enforce size limits at the server, including during upload streaming.
- Store files outside the web root, or use object storage with generated IDs.
- Serve files with a safe content type and no inline execution, such as a
  `Content-Disposition: attachment` header.
- Scan uploaded files for malware and quarantine suspicious content.
- Randomize stored filenames; never trust the client-supplied name.
- Sanitize filenames to prevent path traversal and encoded traversal sequences.
- Store metadata such as the original name separately from the file.
- Block execution in upload directories and disable dangerous formats for
  web-facing content.

Cross-links:

- [Path traversal](path-traversal.md)
- [Injection attacks](injection-attacks.md)
