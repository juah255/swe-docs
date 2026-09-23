# Requests, URLs, Views, and Middleware

## URL Configuration

Django resolves each request against `urlpatterns`, from top to bottom. Keep the
root URL configuration small and delegate to app-level modules.

```python
# config/urls.py
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("orders/", include("orders.urls")),
]
```

Name routes and use `reverse()` or the `{% url %}` template tag rather than
hard-coding paths.

```python
# orders/urls.py
from django.urls import path

from . import views

app_name = "orders"

urlpatterns = [
    path("<uuid:order_id>/", views.detail, name="detail"),
]
```

Converters reject malformed path segments before the view runs. They do not
replace authorization or domain validation.

## Function-Based Views

Function-based views make control flow direct:

```python
from django.contrib.auth.decorators import login_required
from django.shortcuts import get_object_or_404, render

from .models import Order


@login_required
def detail(request, order_id):
    order = get_object_or_404(
        Order.objects.select_related("customer"),
        id=order_id,
        customer=request.user,
    )
    return render(request, "orders/detail.html", {"order": order})
```

Filter the object query by what the user is allowed to access. Fetching an
object first and checking access later can leak its existence and is easier to
get wrong.

## Class-Based Views

Class-based views provide reusable dispatch and mixins. Use them when the shared
behavior is clearer than the inheritance chain.

```python
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic import DetailView

from .models import Order


class OrderDetailView(LoginRequiredMixin, DetailView):
    model = Order
    template_name = "orders/detail.html"
    context_object_name = "order"

    def get_queryset(self):
        return super().get_queryset().filter(customer=self.request.user)
```

Mixin order matters because Python's method resolution order determines which
implementation runs. Prefer a function view when understanding the behavior
requires tracing several parent classes.

## Request and Response Objects

`HttpRequest` exposes the method, headers, cookies, uploaded files, authenticated
user, and parsed form/query data. `request.GET` and `request.POST` are
`QueryDict` objects and may contain multiple values per key.

Return an `HttpResponse` subclass such as `JsonResponse`, a redirect, a rendered
template response, a file response, or a streaming response. Set the status and
headers deliberately. Do not return internal exception details to clients.

## Middleware

Middleware is an ordered stack around the request handler:

```python
def request_id_middleware(get_response):
    def middleware(request):
        request.request_id = request.headers.get("X-Request-ID")
        response = get_response(request)
        response.headers["X-Request-ID"] = request.request_id
        return response

    return middleware
```

Request processing moves from the first configured middleware toward the view;
the response unwinds in reverse. A middleware can short-circuit by returning a
response without calling the next layer. Django also supports view, exception,
and template-response hooks.

Modern Django middleware can be synchronous, asynchronous, or capable of both.
Under ASGI, a synchronous middleware may force adaptation and reduce the benefit
of an async view. Keep middleware cheap, avoid database work unless necessary,
and declare its capabilities correctly.

Middleware is suitable for cross-cutting concerns such as security headers,
correlation IDs, and coarse request metrics. Object authorization and domain
rules belong closer to the operation that needs them.

## Error Handling

Raise `Http404` for a missing web resource and return an appropriate 4xx response
for invalid input. Configure custom handlers for 400, 403, 404, and 500 pages.
Log an internal error once, with request context but without secrets.

Streaming responses require extra care: their iterator may execute after the
view and outside a per-request database transaction. Avoid performing writes
while streaming the body.

