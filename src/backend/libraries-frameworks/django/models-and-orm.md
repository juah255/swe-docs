# Models and the ORM

## Model Design

A model describes stored data and database-level guarantees. Use constraints
and indexes to preserve invariants even when data is written outside a form or
view.

```python
from django.conf import settings
from django.db import models


class Order(models.Model):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        PAID = "paid", "Paid"
        CANCELLED = "cancelled", "Cancelled"

    customer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="orders",
    )
    reference = models.CharField(max_length=32, unique=True)
    status = models.CharField(
        max_length=16,
        choices=Status.choices,
        default=Status.PENDING,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [models.Index(fields=["customer", "-created_at"])]
        constraints = [
            models.CheckConstraint(
                condition=~models.Q(reference=""),
                name="order_reference_not_empty",
            )
        ]
```

Choose `on_delete` behavior from domain semantics. `CASCADE` is not a harmless
default; `PROTECT`, `RESTRICT`, or `SET_NULL` may better preserve data.

## QuerySets Are Lazy

Creating, filtering, and ordering a queryset usually builds a query without
executing it:

```python
orders = Order.objects.filter(status=Order.Status.PENDING)
recent = orders.order_by("-created_at")[:20]
```

Iteration, `list()`, `len()`, `bool()`, serialization, and several other
operations evaluate it. Reusing an evaluated queryset may reuse its result
cache, while constructing a new queryset issues another query. Know where the
evaluation boundary is, especially in templates and loops.

Use `exists()` for an existence check and `count()` for a database count when
the rows are not otherwise needed. If the queryset will immediately be consumed,
an extra existence or count query may be wasteful.

## Loading Relationships

N+1 problems occur when code loads a collection, then performs another query for
each row.

- `select_related()` uses SQL joins for single-valued `ForeignKey` and
  `OneToOneField` relationships.
- `prefetch_related()` runs additional queries and joins results in Python. It
  supports many-to-many and reverse relationships.

```python
from django.db.models import Prefetch

orders = (
    Order.objects.select_related("customer")
    .prefetch_related(
        Prefetch(
            "items",
            queryset=OrderItem.objects.select_related("product"),
        )
    )
)
```

Prefetching fills result caches and can use substantial memory. A later filtered
related query does not automatically use the prefetched collection. Optimize
from measured query counts, not by prefetching everything.

## Database Expressions

`Q` objects compose boolean conditions. `F` expressions refer to values in the
database and avoid read-modify-write races for simple updates.

```python
from django.db.models import F, Q

visible = Order.objects.filter(
    Q(status=Order.Status.PAID) | Q(customer=request.user)
)

Product.objects.filter(pk=product_id, stock__gt=0).update(
    stock=F("stock") - 1
)
```

Annotations, aggregations, `Subquery`, and `Exists` can move appropriate work to
the database. Inspect the generated plan with `QuerySet.explain()` and keep the
query understandable.

## Managers and Custom QuerySets

Put reusable, composable query behavior on a custom queryset:

```python
class OrderQuerySet(models.QuerySet):
    def payable(self):
        return self.filter(status=Order.Status.PENDING)


class Order(models.Model):
    # fields omitted
    objects = OrderQuerySet.as_manager()
```

Avoid silently hiding rows in the default manager when migrations, admin code,
or related-object access needs the full set.

## Writes and Bulk Operations

`update()` performs a direct SQL update and does not call each model's `save()`.
Bulk create/update operations likewise bypass parts of normal instance behavior
and some signals. Use them deliberately and preserve invariants in the database
or explicit application logic.

For a state transition, lock or conditionally update the relevant rows inside a
transaction. Calling `save()` after a stale read does not prevent another
request from changing the row in between.

Raw SQL is appropriate when it is clearer or exposes database features the ORM
cannot express. Always bind parameters rather than interpolating user input, and
isolate database-specific code behind a small interface.

