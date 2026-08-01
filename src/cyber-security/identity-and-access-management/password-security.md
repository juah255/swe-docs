# Password Security

- Store passwords with a password-hashing algorithm and a unique salt.
- Never store plaintext passwords.
- Never encrypt passwords for later recovery.
- Rate-limit login attempts.
- Support password reset through short-lived, single-use tokens.
- Invalidate reset tokens after use.

Password rules should block known compromised passwords and allow long
passphrases.

See [password hashing guidance](../cryptography/hashing.md) for how to
choose and apply a password hashing algorithm.

Related: [MFA](mfa.md), [Authentication](authentication.md).
