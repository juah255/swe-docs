# WordPress

WordPress is a PHP-based content management system used for websites, blogs,
e-commerce, and custom content applications. Backend work usually focuses on
themes, plugins, custom post types, hooks, REST APIs, security, performance,
and deployment.

## Core Concepts

- **Themes:** control templates, layout, assets, and presentation.
- **Plugins:** add reusable behavior without modifying WordPress core.
- **Hooks:** use actions and filters to extend or change runtime behavior.
- **Custom post types:** model structured content beyond posts and pages.
- **Taxonomies:** group content with categories, tags, or custom groupings.
- **REST API:** expose or consume WordPress data through HTTP endpoints.

## Backend Practices

- keep business logic in plugins instead of themes when it should survive theme
  changes;
- use child themes when customizing an existing theme;
- validate, sanitize, and escape all external data;
- use nonces and capability checks for admin actions;
- avoid editing WordPress core files;
- use prepared queries through `$wpdb->prepare()` when custom SQL is required;
- keep plugins, themes, and WordPress core updated.

## Common Interview Topics

- WordPress request lifecycle and template hierarchy;
- actions vs filters;
- plugin architecture;
- custom post types and custom fields;
- database schema and the `wp_posts` / `wp_postmeta` model;
- security concerns such as XSS, CSRF, SQL injection, and file uploads;
- performance tuning with caching, object cache, CDN, and query optimization.

## Questions and Answers

### 1. How do you decide whether code belongs in a theme or a plugin?

**Answer:** Put presentation concerns in a theme and durable application
behavior in a plugin.

A theme should own templates, layout, styles, assets, and view-specific helper
logic. A plugin should own features that must survive a theme change, such as
custom post types, shortcodes, blocks, integrations, business rules, background
jobs, REST endpoints, and admin workflows.

At a senior level, this boundary matters because theme changes are common during
redesigns. If core business behavior lives in the theme, a visual redesign can
accidentally break data models, admin behavior, or integrations.

### 2. What is the WordPress template hierarchy?

**Answer:** The template hierarchy is the order WordPress uses to choose a theme
template for the current request.

For example, a single blog post may use `single-{post_type}.php`, then
`single.php`, then `singular.php`, then `index.php` depending on what exists in
the theme. Archives, pages, search results, taxonomy pages, and custom post
types each have their own hierarchy.

A strong answer should mention that template selection is based on the main
query and conditional context. Debugging template issues usually means checking
the request type, the queried object, rewrite rules, and which template file the
theme actually provides.

### 3. When should you use a child theme?

**Answer:** Use a child theme when you need to customize an existing theme while
still keeping the parent theme updateable.

A child theme can override templates, add styles, enqueue scripts, and customize
theme behavior through hooks. The parent theme remains intact, so security and
bug-fix updates can still be applied.

Do not use a child theme as a dumping ground for application logic. If the logic
represents a reusable feature or business rule, it should usually live in a
plugin.

### 4. How would you structure a maintainable WordPress plugin?

**Answer:** A maintainable plugin should have a small bootstrap file and move
real behavior into organized classes or modules.

Good structure usually includes:

- a main plugin file with metadata and bootstrap code;
- namespaced classes or prefixed functions to avoid collisions;
- activation, deactivation, and uninstall handlers;
- separate modules for admin UI, frontend behavior, REST routes, integrations,
  and data access;
- clear capability checks before privileged actions;
- tests or at least isolated service classes for critical behavior.

Senior-level concern: avoid doing expensive work when the plugin file is loaded.
Register hooks early, but run expensive behavior only when the relevant hook or
request path requires it.

### 5. What is the difference between activation, deactivation, and uninstall?

**Answer:** Activation runs when the plugin is enabled, deactivation runs when it
is disabled, and uninstall runs when it is removed.

Activation is appropriate for setup tasks such as registering rewrite rules,
creating custom tables, setting default options, or scheduling cron events.
Deactivation should undo runtime state such as clearing scheduled events or
flushing rewrite rules. Uninstall is for deleting plugin-owned data when the user
has chosen to remove the plugin.

Avoid deleting user data on deactivation. Deactivation is often temporary.

### 6. What is the difference between actions and filters?

**Answer:** Actions let code run at a specific point in the WordPress lifecycle.
Filters receive a value, modify it, and return the result.

Use an action for side effects, such as registering a post type on `init`, adding
admin menu pages, sending email, or enqueueing assets. Use a filter when the goal
is to transform data, such as changing content output, modifying query
arguments, or adjusting allowed MIME types.

The key interview signal is return behavior. A filter must return a value.
Forgetting to return from a filter can break downstream behavior.

### 7. How do hook priority and accepted arguments affect behavior?

**Answer:** Hook priority controls execution order. Lower priority numbers run
earlier, and higher numbers run later. Accepted arguments control how many values
WordPress passes into the callback.

Priority matters when multiple plugins or theme code touch the same behavior.
For example, one filter may need to run after another plugin has added data. In
that case, increasing the priority can be the correct fix.

Senior developers should avoid relying on fragile priority chains unless the
dependency is clear. When possible, design hooks to be explicit, documented, and
idempotent.

### 8. How do custom post types change WordPress content modeling?

**Answer:** Custom post types let WordPress model content that is not simply a
blog post or page.

Examples include products, events, case studies, jobs, courses, and portfolio
items. They allow separate admin menus, URLs, archives, capabilities, REST API
exposure, and templates.

The important design decision is whether the data fits the WordPress post model.
If the data is content-like, editorial, searchable, and benefits from revisions
or admin workflows, a custom post type is often appropriate. If the data is
high-volume, relational, transactional, or reporting-heavy, custom database
tables may be a better fit.

### 9. When should you use custom fields or post meta?

**Answer:** Use post meta for extra attributes attached to a post, such as event
dates, product metadata, SEO fields, or external IDs.

Post meta is flexible, but it has performance tradeoffs. Heavy filtering,
sorting, and reporting across many meta keys can create slow queries because
`wp_postmeta` is an entity-attribute-value style table.

For senior-level design, post meta is fine for moderate content metadata. For
large datasets with strong query requirements, use custom tables or an external
data store with explicit indexes.

### 10. How do taxonomies differ from custom fields?

**Answer:** Taxonomies classify content into reusable groups. Custom fields store
attributes about one item.

Use a taxonomy for categories, tags, genres, brands, departments, locations, or
other groupings that users may browse, filter, or archive. Use custom fields for
item-specific values such as price, start date, rating, or source URL.

A practical rule: if many posts share the same value and users need to navigate
by it, consider a taxonomy. If the value describes one post and is not a
browsable grouping, use metadata.

### 11. How would you expose custom data through the WordPress REST API?

**Answer:** Register REST routes with explicit namespaces, methods, permission
callbacks, request validation, and response shaping.

For custom post types, WordPress can expose standard CRUD behavior when
`show_in_rest` is enabled. For custom application behavior, use
`register_rest_route()` and define callbacks for reads or writes.

Senior-level concerns include authentication, authorization, schema validation,
response size, caching, pagination, and backward-compatible API changes. Never
trust request data just because it arrives through the REST API.

### 12. How do you secure a custom REST endpoint?

**Answer:** A secure endpoint needs authentication, authorization, validation,
sanitization, and safe output handling.

The `permission_callback` should check whether the current user can perform the
requested action. Read-only public endpoints can allow anonymous access, but
write operations should require appropriate capabilities.

Validate request shape, sanitize values before storage or querying, and escape
data when rendering it into HTML. For cookie-authenticated browser requests,
also account for nonce handling where appropriate.

### 13. What happens during the WordPress request lifecycle?

**Answer:** WordPress loads configuration, plugins, the theme, parses the
request, builds the query, runs hooks, selects a template, and sends the
response.

Important lifecycle moments include plugin loading, `init`, rewrite parsing,
query construction, `wp`, template resolution, and rendering. Admin requests,
AJAX requests, REST API requests, and cron requests have related but different
paths.

Senior engineers use lifecycle knowledge to place code correctly. For example,
custom post types should be registered on `init`, query changes often belong in
`pre_get_posts`, and frontend assets should be enqueued on
`wp_enqueue_scripts`.

### 14. How do you change the main query safely?

**Answer:** Use the `pre_get_posts` action and check that you are changing the
intended query.

Common checks include `! is_admin()`, `$query->is_main_query()`, and the
specific condition being targeted, such as an archive, search page, or custom
post type archive.

Avoid replacing the main query with a new `WP_Query` in templates when the goal
is to modify the page's primary result set. Creating extra queries can break
pagination, canonical behavior, and performance.

### 15. How should WordPress code handle validation, sanitization, and escaping?

**Answer:** Validate input, sanitize data before storage or querying, and escape
output at the point of rendering.

Validation decides whether data is acceptable. Sanitization normalizes or cleans
data. Escaping makes data safe for a specific output context, such as HTML,
attributes, URLs, JavaScript, or SQL.

A senior answer should emphasize context. Escaping for HTML is not the same as
escaping for an attribute or URL. WordPress provides functions such as
`sanitize_text_field()`, `esc_html()`, `esc_attr()`, `esc_url()`, and prepared
SQL helpers for different contexts.

### 16. What are nonces in WordPress, and what do they not protect against?

**Answer:** WordPress nonces are tokens used to verify that a request came from
an expected user flow. They are commonly used to reduce CSRF risk for forms,
admin actions, AJAX calls, and some REST requests.

Nonces are not authentication or authorization. A valid nonce does not prove the
user is allowed to perform an action. Code must still check capabilities with
functions such as `current_user_can()`.

A good implementation checks the nonce, checks the user's capability, validates
the input, performs the action, and returns a controlled response.

### 17. Why should you avoid editing WordPress core files?

**Answer:** Core edits are overwritten by updates and make the installation hard
to maintain, secure, and debug.

WordPress is designed to be extended through plugins, themes, child themes,
hooks, filters, REST routes, blocks, and configuration. If a change appears to
require editing core, it usually means the extension point has not been found
yet or the requirement should be handled outside WordPress.

Editing core also creates operational risk because teams may avoid applying
security updates for fear of losing custom changes.

### 18. How should custom SQL be written in WordPress?

**Answer:** Use `$wpdb` with prepared statements when custom SQL is required.

`$wpdb->prepare()` binds values safely into a SQL query and helps prevent SQL
injection. Use the correct placeholders for strings, integers, and floats, and
never concatenate untrusted input directly into SQL.

Also consider whether custom SQL is actually needed. `WP_Query`, taxonomy
queries, metadata queries, and custom tables with well-defined access layers may
be clearer depending on the use case.

### 19. What are the tradeoffs of the `wp_posts` and `wp_postmeta` schema?

**Answer:** The schema is flexible and works well for content management, but it
can become inefficient for complex relational or analytical queries.

`wp_posts` stores many content types in one table. `wp_postmeta` stores flexible
key-value metadata. This makes WordPress adaptable, but meta queries across
large datasets can become expensive, especially with multiple joins, sorting by
meta values, or filtering on poorly indexed values.

Senior-level solutions include better indexes where appropriate, caching,
denormalized lookup tables, purpose-built custom tables, or moving heavy search
and reporting workloads to external systems.

### 20. How do you improve WordPress performance?

**Answer:** Start with measurement, then optimize the slowest layer.

Common improvements include page caching, object caching with Redis or Memcached,
OPcache, CDN usage, image optimization, fewer plugin loads on critical paths,
database query optimization, proper indexes, and reducing external HTTP calls.

Senior engineers distinguish anonymous traffic from authenticated traffic.
Full-page caching helps public pages, but logged-in dashboards, carts, and
personalized pages often need object caching, query tuning, and application-level
optimization.

### 21. How do you keep WordPress updates safe in production?

**Answer:** Use version control, staging environments, backups, dependency
review, and a repeatable deployment process.

Core, plugin, and theme updates should be tested before production when the site
has business-critical behavior. Check PHP compatibility, plugin compatibility,
database migrations, custom templates, forms, checkout flows, cron jobs, and
REST integrations.

For senior teams, updates are not just an admin-button workflow. They are part
of operational security and release management.

### 22. How would you handle file uploads securely?

**Answer:** Restrict allowed file types, validate MIME type and extension, limit
file size, store uploads in controlled locations, and avoid executing uploaded
files.

Use WordPress media APIs where possible instead of manually handling upload
paths. Check user capabilities before accepting uploads and sanitize filenames.

A senior answer should mention that upload security is both application-level
and infrastructure-level. The web server should not execute scripts from the
uploads directory, and private files should not be exposed through predictable
public URLs unless intended.
