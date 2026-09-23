# Project Structure and Settings

## Projects and Apps

A **project** is the deployed application: its settings, root URL configuration,
and WSGI or ASGI entry point. An **app** is a Python package that owns a focused
capability such as accounts, billing, or inventory. One project usually contains
several apps.

An app boundary should represent behavior and ownership, not merely a database
table. Avoid creating an app for every model or putting an entire product in one
generic `core` app.

```text
config/
  settings/
    base.py
    local.py
    production.py
  urls.py
  asgi.py
  wsgi.py
catalog/
  migrations/
  admin.py
  apps.py
  models.py
  urls.py
  views.py
  tests/
manage.py
```

## Settings

Settings are ordinary Python, but they are also deployment configuration. Keep
shared defaults in one place and read environment-specific values at the
boundary.

```python
import os

DEBUG = os.environ.get("DJANGO_DEBUG", "false").lower() == "true"
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]
ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "").split(",")
```

Do not commit production secrets. Fail clearly when a required value is absent,
and validate configuration during startup or deployment. A settings package,
environment-based settings module, or a typed configuration library can all
work; consistency matters more than the specific pattern.

Important settings include:

- `INSTALLED_APPS`, which activates Django and project applications;
- `MIDDLEWARE`, whose order affects request and response behavior;
- `DATABASES`, `CACHES`, `TEMPLATES`, and storage configuration;
- `AUTH_USER_MODEL`, which should be chosen before the first migration;
- security settings such as hosts, cookies, HTTPS, and proxy handling.

Never import a production settings module from application code. Read values
through `django.conf.settings` when code genuinely needs configuration.

## Application Configuration

`AppConfig` supplies application metadata and startup hooks:

```python
from django.apps import AppConfig


class OrdersConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "orders"

    def ready(self):
        from . import signals  # noqa: F401
```

`ready()` may run more than once in some test or tooling scenarios. Do not query
the database, call remote services, or start worker threads there. If signals
are necessary, make their registration idempotent.

## Admin

The admin is an internal, model-oriented interface. Register models with a
purposeful `ModelAdmin` rather than exposing every field by default:

```python
from django.contrib import admin

from .models import Order


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ["id", "status", "created_at"]
    list_filter = ["status"]
    search_fields = ["id", "customer__email"]
    readonly_fields = ["created_at"]
```

Treat admin actions as production code: enforce authorization, avoid unbounded
queries, validate transitions, and record important changes. The admin is not a
replacement for a customer-facing workflow.

## Management Commands

Management commands are good entry points for maintenance and operational jobs:

```python
from django.core.management.base import BaseCommand

from orders.services import expire_stale_orders


class Command(BaseCommand):
    help = "Expire unpaid orders past their deadline"

    def handle(self, *args, **options):
        count = expire_stale_orders()
        self.stdout.write(self.style.SUCCESS(f"Expired {count} orders"))
```

Make commands safe to retry, add batching for large datasets, and expose a dry
run option when an operation has broad effects.

## Explicit Application Logic

Models can own small invariants and behavior closely tied to one entity. Complex
workflows often read more clearly in explicit service functions. Reusable read
queries can live in custom querysets, managers, or selector functions.

Signals are useful for framework integration and truly decoupled notifications,
but they make control flow implicit. Avoid relying on a `post_save` handler for
critical business behavior. Explicit calls also make transaction boundaries and
tests easier to understand.

