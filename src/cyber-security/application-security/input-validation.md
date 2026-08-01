# Input Validation

Validate input before it is used, and assume everything reaching the boundary is
untrusted.

## Validation Strategy

- Validate input at system boundaries.
- Prefer allowlists over denylists.
- Enforce type, length, range, enum, and format constraints.
- Validate again before sensitive operations if data has crossed trust
  boundaries.

## Validation Types

- Type: confirm the value is the expected data type, such as string, integer,
  or boolean.
- Length: cap minimum and maximum lengths to match the field's contract.
- Range: enforce numeric bounds and date ranges.
- Enum: restrict values to a known set of allowed options.
- Format: match a pattern such as email, UUID, or file extension.
- Allowlist: accept only values that match the permitted set; reject everything
  else.

## Validation vs Sanitization

- Validation rejects bad input; sanitization modifies it to be safer.
- Prefer validation with allowlists at the boundary.
- Sanitization is riskier because it is easy to miss an edge case, such as
  encoded or nested payloads.
- Sanitize rich content with a trusted sanitizer when users must supply HTML or
  markup.

Cross-links:

- [Injection attacks](injection-attacks.md)
- [SQL injection](sql-injection.md)
- [Cross-Site Scripting](xss.md)
- [Path traversal](path-traversal.md)
