# Server-Side Request Forgery

Server-side request forgery (`SSRF`) occurs when an attacker controls a server's
outbound request target.

Defenses:

- Allowlist destinations.
- Block private and metadata IP ranges where appropriate.
- Resolve and validate hostnames carefully.
- Disable redirects or revalidate redirected targets.
- Use network egress controls.

Cross-links:

- [Injection attacks](injection-attacks.md)
- [XML external entity](xxe.md)
