# Django

Django is a batteries-included Python web framework for building server-rendered
sites, internal tools, and APIs. Its core includes URL routing, an ORM,
migrations, forms, templates, authentication, sessions, an admin site, caching,
and security protections. Django REST Framework (DRF) is a separate, widely used
package for building web APIs.

## Why Django?

Django is a strong choice when a product benefits from a coherent set of
conventions instead of assembling every layer independently. Common examples
include content platforms, marketplaces, SaaS applications, and data-heavy
internal systems.

Its main advantages are:

- a mature ORM and migration system;
- built-in authentication, forms, sessions, and administration;
- secure defaults for common web risks;
- support for both WSGI and ASGI deployments;
- a large ecosystem of reusable applications.

The trade-off is that Django has opinions and a substantial request stack. A
small service may not need all of it, while a large codebase still needs clear
application boundaries beyond Django's default project layout.

## The Main Building Blocks

| Building block | Responsibility |
| --- | --- |
| Project | Deployment-wide configuration and root URL routing |
| App | A focused, reusable unit of domain behavior |
| Model | Database schema and persistence behavior |
| View | Request handling and response construction |
| URL configuration | Mapping URLs to views |
| Template | Rendering server-side text, usually HTML |
| Form | Parsing, validating, and cleaning user input |
| Middleware | Cross-cutting request and response behavior |
| Admin | Internal, model-oriented data management |

## A Typical Request

```text
client
  -> web server / reverse proxy
  -> WSGI or ASGI application
  -> request middleware
  -> URL resolver
  -> view
  -> application services and ORM
  -> response middleware
  -> client
```

Middleware wraps the request handler. URL resolution selects a view, the view
coordinates validation and application work, and the returned response travels
back through middleware in reverse order. A view should be an entry point, not
the home of every business rule.

## A Maintainable Shape

Small projects can work well with Django's generated layout. As the application
grows, keep responsibilities explicit:

```text
config/             # settings, root URLs, WSGI and ASGI entry points
accounts/           # one domain-focused Django app
orders/             # another domain-focused Django app
  migrations/
  admin.py
  models.py
  urls.py
  views.py
  services.py       # application workflows and writes
  selectors.py      # reusable read queries, if the project uses this pattern
  tests/
manage.py
```

This is a convention, not a Django requirement. Prefer names and boundaries that
make the project's control flow easy to find.

## Version Awareness

The core concepts in this section apply across supported Django versions. Some
features are newer: Django's Tasks framework and built-in Content Security
Policy support arrived in Django 6.0. Always read the documentation for the
version deployed by the project. The Tasks framework defines and queues work;
it does not itself run production workers.

## Learning Path

1. Learn projects, apps, settings, URLs, views, and middleware.
2. Model data and understand lazy querysets and relationship loading.
3. Practice safe migrations and transaction boundaries.
4. Add forms or DRF serializers at input boundaries.
5. Understand authentication, permissions, sessions, and CSRF.
6. Learn testing, caching, async behavior, and background work.
7. Finish with security and production deployment.

Use the pages in this section as a practical reference rather than a substitute
for the versioned Django documentation.

