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
