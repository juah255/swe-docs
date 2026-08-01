# Insecure Deserialization

Deserializing untrusted data can execute code, create malformed objects, or
trigger unexpected behavior in the application.

How it works:

- Serialized formats such as Java object streams, Python `pickle`, and PHP
  serialization can carry code or class references.
- The deserializer constructs objects (and sometimes calls methods or loads
  classes) based on the attacker's payload.
- Gadget chains combine accessible classes to reach dangerous sinks such as
  command execution.
- Even without code execution, an attacker can craft objects that corrupt
  application state or bypass logic.

Defenses:

- Do not deserialize untrusted input.
- Prefer safe, plain-data formats such as JSON with schema validation.
- Allowlist acceptable classes and types when deserialization is required.
- Use signing or integrity checks so only trusted producers can create input.
- Run deserialization in an isolated process with least privilege.
- Enforce strict input validation before the object is deserialized.

Cross-links:

- [Secure coding principles](secure-coding-principles.md)
- [Injection attacks](injection-attacks.md)
