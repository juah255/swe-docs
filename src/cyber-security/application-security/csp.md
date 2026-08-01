# Content Security Policy

Content security policy (`CSP`) restricts which resources a page can load,
including scripts, styles, frames, images, and connections.

How to use it:

- Start with a report-only policy (`Content-Security-Policy-Report-Only`) to
  observe violations before enforcing.
- Test in production traffic and tighten the policy incrementally.
- Enforce once the report shows the policy is safe.

Common directives:

- `default-src`: fallback policy for resource types not otherwise specified.
- `script-src`: allowed sources and restrictions for scripts.
- `style-src`: allowed sources for stylesheets.
- `frame-ancestors`: which origins may frame the page (see clickjacking).
- `object-src`: allowed sources for plugins and embeds.

Avoid `unsafe-inline` and `unsafe-eval` where possible; they weaken the policy
and are frequent CSP bypass vectors.

CSP is a defense-in-depth control. It does not replace output escaping or other
remediation for vulnerabilities such as XSS.

Cross-links:

- [Cross-Site Scripting](xss.md)
- [Clickjacking](clickjacking.md)
- [Security headers](security-headers.md)
