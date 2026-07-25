# Security Questions

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between authentication and authorization?

**Answer:** Authentication proves who the user or client is. Authorization
decides what that identity is allowed to do.

An authenticated user may still be forbidden from an action. Systems must check
both identity and permissions independently.

### 2. What is the difference between session-based and token-based authentication?

**Answer:** Session-based authentication stores user state on the server and
uses a session ID (usually in a cookie) to identify the user. Token-based
authentication (JWT) stores claims in the token itself, making it stateless.

Sessions are easier to revoke but harder to scale. Tokens scale better but
require short lifetimes and refresh mechanisms for security.

### 3. Why should access tokens be short-lived?

**Answer:** Short-lived access tokens reduce the impact of token theft. If a
token leaks, the attacker has a small window to use it. Refresh tokens or
re-authentication extend the session without exposing long-lived credentials.

For high-security systems, combine short-lived tokens with token revocation
and refresh token rotation.

### 4. How do you prevent SQL injection?

**Answer:** Use parameterized queries (prepared statements) as the primary
defense. Never concatenate user input into SQL strings. Use ORMs that handle
query construction safely. Validate input on the server side. Apply least
privilege to database accounts.

### 5. What is CORS and why does it exist?

**Answer:** CORS is a browser mechanism that controls which origins can access
a server's resources. It exists to prevent malicious websites from making
unauthorized requests to other domains using the user's browser and cookies.

CORS is enforced by browsers, not servers. It does not protect against
server-side attacks.

### 6. How do you securely store passwords?

**Answer:** Never store passwords in plaintext. Use a dedicated password
hashing algorithm (Argon2 preferred, bcrypt acceptable). Each password should
be hashed with a unique salt. Tune the algorithm's work factor to be slow
enough to resist brute-force but fast enough for user experience.

Check passwords against known breach databases. Follow NIST SP 800-63B
guidelines for password policies.

### 7. What is the OWASP Top 10?

**Answer:** The OWASP Top 10 is a list of the most critical web application
security risks, updated periodically by the Open Web Application Security
Project. It includes broken access control, injection, cryptographic failures,
insecure design, security misconfiguration, and others.

It serves as a baseline for security reviews, compliance, and development
training.

### 8. How does TLS protect data in transit?

**Answer:** TLS encrypts all data between client and server, preventing
eavesdropping and tampering. It uses asymmetric cryptography for key exchange
and certificate verification, then symmetric encryption for data transfer.

TLS also provides integrity (data cannot be modified) and authentication
(server identity verified via certificates). Always use TLS 1.2+ with strong
cipher suites.

### 9. What is CSRF and how do you prevent it?

**Answer:** CSRF tricks an authenticated user's browser into making unintended
requests to a site where they are authenticated. Prevention includes using
SameSite cookies (Lax or Strict), CSRF tokens in forms, checking Origin and
Referer headers, and requiring re-authentication for sensitive operations.

### 10. What is the principle of least privilege?

**Answer:** Grant only the minimum access needed for a task. Users, services,
and tokens should not have more permissions than required. This limits the
blast radius of compromised accounts, reduces the impact of misconfigurations,
and makes security audits easier.

Apply least privilege to database accounts, API keys, service accounts, and
user roles.
