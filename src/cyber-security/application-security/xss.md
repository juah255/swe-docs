# Cross-Site Scripting

Cross-site scripting (`XSS`) happens when untrusted content runs as JavaScript in
a user's browser.

Defenses:

- Escape output by context: HTML, attribute, URL, JavaScript, or CSS.
- Use framework-safe rendering defaults.
- Sanitize rich HTML with a trusted sanitizer.
- Avoid unsafe DOM APIs such as direct HTML insertion with untrusted strings.
- Use a restrictive content security policy where practical.
- Validate input, but do not rely on input validation alone.

Stored input must still be safely encoded when it is rendered.

## Types

- Stored XSS: attacker-supplied content is saved and later rendered to other
  users.
- Reflected XSS: attacker-controlled input is reflected immediately in a
  response without being saved.
- DOM-based XSS: unsafe client-side code reads attacker-controlled values from
  the DOM or URL and inserts them into the page.

Cross-links:

- [Content security policy](csp.md)
- [Input validation](input-validation.md)
- [Injection attacks](injection-attacks.md)
