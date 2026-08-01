# Clickjacking

Clickjacking tricks users into clicking hidden UI by framing a page and
overlaying transparent or misleading elements.

How it works:

- The attacker embeds a target page in an invisible iframe.
- The user believes they are interacting with the attacker's page.
- A click lands on the target page's buttons, such as a submit or delete
  action.

Defenses:

- Send `X-Frame-Options: DENY` or `X-Frame-Options: SAMEORIGIN`.
- Use the CSP `frame-ancestors` directive to restrict which origins may frame
  the page.
- Do not combine `SAMEORIGIN` with `allow-from` in a way that widens framing.
- For sensitive actions, require an explicit user interaction such as a
  confirmation dialog or CAPTCHA.
- Use `SameSite` cookies so cross-site requests carry fewer credentials.

Cross-links:

- [Security headers](security-headers.md)
- [Cross-Site Request Forgery](csrf.md)
- [Content security policy](csp.md)
