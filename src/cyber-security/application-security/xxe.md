# XML External Entity

XML external entity (`XXE`) injection occurs when an XML parser processes
external entities from untrusted input.

How it works:

- XML documents can declare entities that reference external files or URLs.
- A parser configured to resolve these entities will fetch and expand them.
- Attackers can reference local files, internal services, or network resources.

Impact:

- File disclosure: reading arbitrary files from the server.
- SSRF: making the parser request internal or cloud-metadata endpoints.
- Denial of service: entity expansion such as the "billion laughs" attack
  consumes memory and CPU.

Defenses:

- Disable DTDs and external entity processing in the XML parser.
- Reject or strip DOCTYPE declarations.
- Prefer JSON or other non-XML formats where possible.
- Configure the parser explicitly; never rely on insecure defaults.
- Apply the same network egress controls used for SSRF.

Cross-links:

- [Server-Side Request Forgery](ssrf.md)
- [Injection attacks](injection-attacks.md)
