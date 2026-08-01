# Logging

Logging captures the events needed to detect incidents and investigate them
later.

## Security Logs

Log security-relevant events:

- Login success and failure.
- MFA changes.
- Password reset requests.
- Permission changes.
- Admin actions.
- Data exports.
- Token creation and revocation.
- Payment, billing, or account ownership changes.

Logs should include actor, target, action, timestamp, source IP or request
context, and result.

## Sensitive Data in Logs

Do not log:

- Passwords.
- Session tokens.
- API keys.
- Private keys.
- Full payment details.
- Unnecessary personal data.

Use redaction and retention policies.

See [Security Monitoring](security-monitoring.md) and [SIEM](siem.md) for how
these logs are collected and analyzed.
