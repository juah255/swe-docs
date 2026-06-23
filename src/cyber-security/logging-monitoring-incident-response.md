# Logging, Monitoring, and Incident Response

Security monitoring helps detect suspicious behavior and investigate incidents.

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

## Incident Response

Typical response flow:

1. Detect suspicious behavior.
2. Triage severity and scope.
3. Contain the issue.
4. Preserve evidence.
5. Eradicate the root cause.
6. Recover service safely.
7. Rotate exposed secrets if needed.
8. Review the incident and improve controls.

## Alerts

Good alerts are actionable. Alert on behavior that suggests account takeover,
credential misuse, data exfiltration, privilege escalation, or service abuse.
