# Frontend Security

## Cross-Site Scripting

XSS occurs when untrusted input is rendered as HTML or JavaScript. Types: stored (persisted on server), reflected (in URL/query params), DOM-based (client-side source). Prevent by escaping output by context, using framework-safe rendering, and applying a Content Security Policy.

## Cross-Site Request Forgery

CSRF tricks an authenticated browser into sending a state-changing request to a target site. Defenses: SameSite cookies, CSRF tokens for cookie-based auth, and checking Origin/Referer headers.

## Content Security Policy

CSP restricts which resources (scripts, styles, images) can load on a page. Use `script-src`, `style-src`, `img-src`, `connect-src` directives. Report violations with `report-uri` or `report-to` before enforcing. Strict CSP blocks most XSS and data exfiltration.

## Token Storage

- **httpOnly, Secure, SameSite cookies:** Safest for tokens. Immune to XSS reads. Require CSRF protection.
- **localStorage:** Vulnerable to XSS. Any injected script can read tokens. Avoid for sensitive data.
- **Memory (variable):** Safe from XSS, but lost on refresh. Common in SPAs with refresh tokens in cookies.

## Dependency Security

Frontend apps depend on many npm packages. Use lockfiles (`package-lock.json`, `yarn.lock`), run `npm audit` or `pnpm audit` in CI, enable Dependabot or Renovate, and review transitive dependency changes.

## Mid/Senior Interview Questions and Answers

### 1. What are common frontend security risks?

**Answer:** Common risks include XSS, unsafe HTML rendering, token exposure in localStorage, CSRF in cookie-based flows, dependency vulnerabilities, leaking secrets into client bundles, and overly permissive CORS assumptions. Never put server secrets in frontend environment variables that are bundled into browser code.

### 2. How does a Content Security Policy protect against XSS?

**Answer:** CSP restricts which scripts can execute on a page. By setting `script-src` to trusted sources only, inline scripts and event handlers are blocked unless `unsafe-inline` is used (not recommended). Strict CSP with nonces or hashes allows only scripts explicitly marked by the server.

### 3. What is the safest way to store authentication tokens in a browser?

**Answer:** httpOnly, Secure, SameSite=Strict cookies are safest — they are inaccessible to JavaScript and automatically sent with requests. If tokens must be accessible to JavaScript (SPA with Bearer tokens), store them in memory and use short expiry. Avoid localStorage for tokens in applications that handle sensitive data.

### 4. How do you protect against supply chain attacks in frontend builds?

**Answer:** Use lockfiles, enable integrity checking (`subresourceIntegrity`), pin dependency versions, scan with `npm audit` and Snyk, review dependency changes in PRs, avoid unnecessary dependencies, and use package provenance (npm 9+).
