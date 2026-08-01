# Least Privilege

Least privilege means granting only the access needed to do the job, and no
more. It limits the damage any single account, service, or compromise can do.

Apply it everywhere:

- **Humans**: role-based access that matches the actual job.
- **Services**: scoped service accounts with the minimum permissions.
- **Containers**: run as non-root, drop capabilities, restrict what the image
  can do.
- **Cloud roles**: scoped IAM roles instead of broad administrative grants.
- **Database accounts**: least privilege at the schema and table level.

Use short-lived credentials so a stolen credential expires quickly, and review
and revoke access on a regular cadence, especially when roles change or people
leave.

See [Defense in Depth](defense-in-depth.md) and
[Secure Design Principles](secure-design-principles.md) for related design
principles, and the fundamentals view in
[../fundamentals/security-principles.md](../fundamentals/security-principles.md).
