# CORS

Cross-origin resource sharing (`CORS`) controls whether browser JavaScript from
one origin can read responses from another origin.

CORS is not authentication or authorization. It is enforced by browsers, not by
tools such as backend services, `curl`, or Postman.

Common mistakes:

- Reflecting arbitrary origins.
- Combining wildcard origins with credentials.
- Assuming CORS blocks server-to-server requests.
- Allowing sensitive APIs without proper authentication and authorization.

Cross-links:

- [Cross-Site Request Forgery](csrf.md)
- [Security headers](security-headers.md)
- [API Authentication](../api-security/api-authentication.md) for how CORS
  interacts with cookies and credentials.
