# HTTPS and TLS

**HTTPS** (HTTP Secure) is HTTP encrypted with **TLS** (Transport Layer Security). It protects data in transit between the client and server from eavesdropping, tampering, and impersonation.

## Why HTTPS Matters

Without HTTPS, all HTTP traffic is sent in plaintext. Anyone on the network path (ISP, Wi-Fi operator, attacker) can:

- Read request and response data
- Steal credentials and session tokens
- Modify responses (inject scripts, redirect to malicious sites)
- Perform man-in-the-middle (MITM) attacks

HTTPS prevents all of these by encrypting and authenticating the connection.

## How TLS Works

TLS handshake (simplified):

1. **Client Hello** -- client sends supported TLS versions, cipher suites, and a random value
2. **Server Hello** -- server selects TLS version and cipher suite, sends its certificate and a random value
3. **Certificate Verification** -- client verifies the server's certificate against trusted Certificate Authorities (CAs)
4. **Key Exchange** -- client and server derive shared session keys using asymmetric cryptography
5. **Encrypted Communication** -- all subsequent data is encrypted with symmetric keys

Modern TLS (1.2, 1.3) uses:

- **Asymmetric cryptography** (RSA, ECDSA, Ed25519) for key exchange and certificates
- **Symmetric encryption** (AES-GCM, ChaCha20) for bulk data transfer
- **HMAC / AEAD** for data integrity

## TLS 1.2 vs TLS 1.3

| Feature | TLS 1.2 | TLS 1.3 |
|---|---|---|
| Handshake round trips | 2 | 1 (or 0 with 0-RTT) |
| Cipher suites | Many (including weak) | Only secure ones |
| Key exchange | RSA, DHE, ECDHE | ECDHE, DHE only |
| Forward secrecy | Optional | Mandatory |
| 0-RTT resumption | No | Yes (with replay risk) |
| Recommended | Yes | Preferred |

TLS 1.3 removed vulnerable features (RSA key exchange, CBC mode, SHA-1, RC4, DES, 3DES) and simplified the handshake.

## Certificates

A **TLS certificate** binds a domain name to a public key, signed by a Certificate Authority (CA).

Certificate types:

- **Domain Validated (DV)** -- proves control of the domain, fastest to obtain
- **Organization Validated (OV)** -- verifies the organization's identity
- **Extended Validation (EV)** -- rigorous verification, shows organization name in some browsers

Certificate formats:

- **PEM** -- Base64-encoded, used by most servers (`.pem`, `.crt`, `.key`)
- **DER** -- Binary format
- **PFX/PKCS#12** -- Bundled certificate + private key (`.pfx`, `.p12`)

### Let's Encrypt

**Let's Encrypt** is a free, automated Certificate Authority:

- Issues free DV certificates
- Uses ACME protocol for automation
- Certificates expire after 90 days (automated renewal recommended)
- Widely adopted, trusted by all major browsers

## HSTS (HTTP Strict Transport Security)

**HSTS** instructs browsers to only connect to a domain over HTTPS.

```http
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

- `max-age` -- how long (seconds) the browser should enforce HTTPS
- `includeSubDomains` -- applies to all subdomains
- `preload` -- include in browser HSTS preload lists (applied before first visit)

HSTS prevents downgrade attacks where an attacker forces HTTP connections.

## Forward Secrecy

**Forward secrecy** (also called Perfect Forward Secrecy, PFS) ensures that session keys cannot be derived from the server's long-term private key.

- Uses ephemeral key exchange (DHE, ECDHE)
- Each session has unique keys
- If the server's private key is later compromised, past sessions remain encrypted
- TLS 1.3 mandates forward secrecy

## Common TLS Misconfigurations

- Supporting TLS 1.0 or 1.1 (deprecated)
- Using weak cipher suites (RC4, DES, 3DES, export ciphers)
- Not enforcing forward secrecy
- Using self-signed certificates in production
- Not rotating certificates before expiry
- Missing HSTS headers
- Not redirecting HTTP to HTTPS
- Serving mixed content (HTTPS page loading HTTP resources)

Tools for testing:

- **SSL Labs** (ssllabs.com/ssltest)
- **testssl.sh** -- command-line TLS testing
- **Mozilla SSL Configuration Generator** -- recommended configurations

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between TLS 1.2 and TLS 1.3?

**Answer:** TLS 1.3 is faster (1-RTT handshake vs 2-RTT), more secure (only
secure cipher suites, mandatory forward secrecy), and simpler (removed
vulnerable features like RSA key exchange and CBC mode).

TLS 1.3 also supports 0-RTT resumption for faster reconnections, though this
has replay attack risks for non-idempotent requests.

### 2. What is forward secrecy and why is it important?

**Answer:** Forward secrecy ensures that each session uses unique, ephemeral
keys. If the server's long-term private key is later compromised, past session
cannot be decrypted.

It uses ephemeral Diffie-Hellman (DHE or ECDHE) key exchange. TLS 1.3
mandates forward secrecy. Without it, recording encrypted traffic today and
stealing the server key later would expose all past communications.

### 3. How does HSTS protect against downgrade attacks?

**Answer:** HSTS tells the browser to only connect to the domain over HTTPS
for a specified period. Once the browser receives the HSTS header, it
automatically converts HTTP requests to HTTPS and refuses connections that
cannot be verified.

The `preload` directive ensures the browser never makes an HTTP request to the
domain, even on the first visit, preventing the initial downgrade.

### 4. What should you check when auditing TLS configuration?

**Answer:** Check supported TLS versions (1.2+ only), cipher suites (no weak
ones), forward secrecy support, certificate validity and chain, HSTS
configuration, HTTP-to-HTTPS redirect, mixed content, and OCSP stapling.

Use SSL Labs or testssl.sh for automated checks. Compare results against
Mozilla's recommended server configuration guidelines.

### 5. How do you handle certificate renewal in production?

**Answer:** Automate renewal using ACME clients (Certbot, acme.sh) with
cron jobs or container orchestration. Let's Encrypt certificates expire every
90 days.

Set up monitoring for certificate expiry, test the renewal process in staging,
and ensure the web server reloads the new certificate without downtime. Many
platforms (AWS, Cloudflare) handle renewal automatically.
