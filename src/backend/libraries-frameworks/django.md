# Django

## Core Concepts

### What is Django?

Django is a full-stack Python web framework. It ships with an ORM, admin panel,
authentication, form handling, templating, migrations, and CSRF protection out of
the box. It follows the "batteries included" philosophy.

### What is Django REST Framework?

DRF is the standard library for building REST APIs with Django. It provides
serializers for validation and serialization, viewsets for CRUD, routers for URL
generation, and authentication/permission classes.

### What is an ORM and how does Django's work?

Django's ORM maps Python classes to database tables. Each model class becomes a
table, each attribute becomes a column, and `Meta` defines table-level options
(indexes, ordering, constraints). Queries use a lazy chainable API that compiles
to SQL only when evaluated.

```python
class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(Author, on_delete=models.CASCADE)
    published = models.DateField()

    class Meta:
        indexes = [models.Index(fields=["published"])]
```

### What are Django migrations?

Migrations are Django's way of propagating model changes to the database schema.
`makemigrations` diffs the current models against the last migration and
generates a new migration file. `migrate` applies pending migrations in order.

Migrations are version-controlled and collaborative. Conflicts arise when two
branches modify the same model and are resolved with `makemigrations --merge`.

### What is the Django admin?

The admin is an auto-generated CRUD interface for managing data. Register a model
with `admin.site.register(Model)` and Django generates list views, detail forms,
filters, and search. It is useful for internal tools and content management but
is not a substitute for a purpose-built API or dashboard.

### What are Django signals?

Signals are publish-subscribe notifications that fire when specific events occur
(e.g. `post_save`, `pre_delete`). They let decoupled apps react to model
changes. Use signals for side effects (send email, update search index) rather
than core business logic, because signals are hard to trace and test.

### What is the Django request cycle?

```
Client request
│
▼
WSGI/ASGI server (Gunicorn / Uvicorn)
│
▼
Django URL resolver
│  Match URL pattern → select view function
│  No match → 404
▼
Middleware (outermost first)
│  SessionMiddleware → AuthenticationMiddleware → custom middleware...
│  Each can modify request, short-circuit, or wrap the response
▼
View function / class-based view
│  Request object populated (GET, POST, headers, session)
│  Form / Serializer validation
│  Business logic (ORM queries, service calls)
│  Return HttpResponse / JsonResponse / TemplateResponse
▼
Template rendering (if template response)
│  Context populated → template engine renders HTML
▼
Response middleware (reverse order)
│  Security headers, CSRF cookie, cache headers set
▼
WSGI/ASGI server sends response bytes to client
```

### What is the difference between `select_related` and `prefetch_related`?

- **`select_related`** does a SQL `JOIN` and fetches related objects in the same
  query. Use for `ForeignKey` and `OneToOneField` (single row).
- **`prefetch_related`** does a separate query for related objects and joins them
  in Python. Use for `ManyToManyField` and reverse `ForeignKey` (multiple rows).

Using the wrong one causes N+1 queries.

### What is the difference between `Q` objects and `F` expressions?

- **`Q` objects** build complex boolean queries (`Q(author="X") | Q(published=True)`).
- **`F` expressions** reference column values in the database, enabling atomic
  updates (`F("views") + 1`) without loading data into Python.

## Mid/Senior Interview Questions and Answers

### 1. Why choose Django over FastAPI for a new project?

**Answer:** Choose Django when the project benefits from an ORM, admin, auth,
migrations, and templating without assembling separate libraries. Choose FastAPI
when raw async performance, OpenAPI schema generation, and minimal overhead
matter more than built-in full-stack features.

Django's ecosystem (DRF, Django Celery, django-allauth) reduces integration
work for CRUD-heavy products. FastAPI's ecosystem (Pydantic, async SQLAlchemy)
reduces overhead for high-throughput microservices.

### 2. How do you prevent N+1 queries in Django?

**Answer:** Use `select_related` for single-valued relations and
`prefetch_related` for multi-valued relations. Debug with `django-debug-toolbar`
or `connection.queries` to inspect the actual SQL.

For complex cases, annotate with `Subquery` and `OuterRef` to push aggregation
into the database rather than pulling rows into Python.

### 3. What are the trade-offs of Django signals?

**Answer:** Signals decouple apps but make control flow implicit. They are hard
to debug, hard to test (signal handlers must be connected), and can cause
unexpected side effects. For critical business logic, prefer explicit service
functions called from the view. Use signals only for non-essential side effects.

### 4. How does Django's middleware differ from FastAPI's middleware?

**Answer:** Django middleware wraps the request/response in a fixed order
configured in `MIDDLEWARE`. Each middleware class has `__call__` that can modify
the request, call the next middleware, and modify the response. Django middleware
is class-based and synchronous.

FastAPI middleware is function-based or class-based, runs on ASGI, and supports
both sync and async. FastAPI middleware wraps every request without the
`process_view` / `process_exception` lifecycle hooks that Django provides.

### 5. How do you scale a Django application?

**Answer:**

- Horizontal scaling: run multiple Gunicorn/Uvicorn workers behind a load
  balancer.
- Database: read replicas, connection pooling (PgBouncer), query optimization.
- Caching: Django cache framework with Redis or Memcached for views, templates,
  and querysets.
- Static/media: offload to S3 + CloudFront.
- Background tasks: Celery + Redis/RabbitMQ for async work.
- Session storage: move from database to Redis.

### 6. When would you use Django over a micro-framework for a backend?

**Answer:** Django is a strong fit when the team values convention over
configuration, the project needs admin, auth, forms, and ORM from day one, and
the domain is CRUD-heavy (content management, e-commerce, SaaS admin panels).

Micro-frameworks are a better fit when the team wants full control over
architecture, the workload is API-only with high throughput, or the project
already has established libraries for ORM, auth, and validation.
