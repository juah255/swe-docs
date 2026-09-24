# Spring Security

Spring Security provides authentication, authorization, exploit protection, and
integration with session, OAuth 2.0, and OpenID Connect workflows. Spring Boot
configures secure defaults when Security is present, but application policy must
still be explicit.

## Security Filter Chain

Modern applications define one or more `SecurityFilterChain` beans:

```java
@Bean
SecurityFilterChain apiSecurity(HttpSecurity http) throws Exception {
    return http
        .authorizeHttpRequests(authorize -> authorize
            .requestMatchers("/actuator/health").permitAll()
            .requestMatchers(HttpMethod.POST, "/api/orders/**")
                .hasAuthority("SCOPE_orders.write")
            .anyRequest().authenticated())
        .oauth2ResourceServer(oauth -> oauth.jwt(Customizer.withDefaults()))
        .build();
}
```

When several chains exist, their matcher and order decide which chain secures a
request. Defining a custom chain causes relevant Boot defaults to back off, so
ensure unmatched application and management routes are still protected.

## Authentication and Authorization

Authentication establishes a principal. Authorization evaluates whether that
principal may perform an action. Request rules are useful at the HTTP boundary;
method security such as `@PreAuthorize` can protect application services called
from HTTP, messaging, scheduling, or other entry points.

Neither layer automatically supplies object-level or tenant authorization.
Filter data by the caller's allowed scope and enforce policy again on writes.
Never trust a user-provided owner, tenant, price, or role.

## Resource Servers

Spring Security can validate JWT or opaque bearer tokens for an OAuth 2.0
resource server. For JWTs, validate at least the signature, issuer, lifetime, and
intended audience according to the authorization server contract. Map claims to
authorities deliberately; token presence alone grants nothing.

Do not implement token verification by manually decoding a JWT payload. Plan key
rotation, clock skew, revocation or short lifetimes, and behavior when identity
infrastructure is unavailable.

## Browser Sessions and CSRF

CSRF protection is enabled by default for servlet applications. Keep it for
browser requests authenticated with cookies or other automatically attached
credentials. Disabling it can be reasonable for a stateless bearer-token API
used only by non-browser clients, but that decision follows the authentication
model, not the response format.

Set secure, HTTP-only, appropriately scoped session cookies. Rotate the session
identifier on authentication and invalidate sessions correctly on logout or
credential compromise.

CORS controls which cross-origin browser scripts may read or issue eligible
requests. It is not authentication and should use precise origins, methods, and
headers rather than a wildcard with credentials.

## Passwords and Secrets

Use a supported adaptive `PasswordEncoder` and allow stored hashes to identify
their encoding. Tune the work factor for the environment and plan gradual
rehashing. Never log passwords, access tokens, session IDs, authorization
headers, or client secrets.

Load keys and credentials from protected runtime configuration. Separate signing
and verification roles when possible, rotate secrets, and restrict management
access.

## Method Security

Enable method authorization where service-level policy is valuable:

```java
@PreAuthorize("hasAuthority('orders:refund') and @orderPolicy.canAccess(#id)")
public Refund refund(UUID id) {
    // Execute an independently validated, transactional operation.
}
```

Method security is proxy-based, so self-invocation and unmanaged objects can
bypass interception. Keep expressions understandable; complex policy belongs in
named components with direct unit tests.

## Security Baseline

- Patch the JDK, Spring Boot, Spring Security, and transitive dependencies.
- Validate all input and encode output for its actual context.
- Parameterize database queries and whitelist dynamic identifiers.
- Restrict request body, upload, header, and decompression sizes at the edge.
- Configure TLS and trusted proxy headers correctly.
- Apply rate limits and abuse controls outside and inside the application.
- Secure Actuator and avoid exposing sensitive diagnostic endpoints.
- Return safe errors and scrub sensitive log fields.
- Test anonymous, ordinary, privileged, and cross-tenant access.

