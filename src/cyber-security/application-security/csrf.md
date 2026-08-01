# Cross-Site Request Forgery

Cross-site request forgery (`CSRF`) tricks a logged-in browser into sending a
state-changing request to another site.

Defenses:

- Use `SameSite` cookies.
- Use CSRF tokens for state-changing form requests.
- Check `Origin` or `Referer` for sensitive requests.
- Avoid unsafe state changes through `GET`.
- Require re-authentication or confirmation for high-risk actions.

Cross-links:

- [Clickjacking](clickjacking.md)
- [Sessions and Cookies](../identity-and-access-management/sessions-and-cookies.md)
  for `SameSite` cookie behavior.
