# Migrations and Transactions

## Schema Migrations

Migration files are version-controlled descriptions of schema state and the
operations that transform it. `makemigrations` creates files from model changes;
`migrate` applies the dependency graph to a database.

Review generated migrations before committing them. A model change that looks
small in Python can lock a large table, rewrite data, or fail on existing rows.
Do not routinely edit or delete migrations that have already run in shared
environments.

Useful commands include:

```bash
python manage.py makemigrations
python manage.py migrate
python manage.py showmigrations
python manage.py sqlmigrate orders 0008
```

## Data Migrations

Use `RunPython` for data changes that must move with the schema history. Retrieve
historical models from the migration app registry instead of importing today's
model class.

```python
from django.db import migrations


def populate_normalized_status(apps, schema_editor):
    Order = apps.get_model("orders", "Order")
    Order.objects.filter(status="P").update(status="pending")


class Migration(migrations.Migration):
    dependencies = [("orders", "0007_add_status")]
    operations = [migrations.RunPython(populate_normalized_status)]
```

Provide a reverse operation when rollback is meaningful. For large tables,
consider batching or a separate resumable backfill rather than one enormous
transaction.

## Backward-Compatible Rollouts

Code and schema versions overlap during a rolling deployment. Use an
expand-and-contract sequence for risky changes:

1. Add a nullable column or new table that old code can ignore.
2. Deploy code that writes both representations when necessary.
3. Backfill existing data in bounded batches.
4. Switch reads to the new representation.
5. Enforce constraints and remove the old representation later.

Renaming or dropping a busy column in one release can break still-running
workers. Coordinate migrations with deploy order, queues, replicas, and rollback
plans.

## Autocommit and `atomic()`

Django uses autocommit by default: each statement commits unless a transaction
is active. Use `transaction.atomic()` around a business operation that must
succeed or fail as one unit.

```python
from django.db import transaction


@transaction.atomic
def place_order(*, customer, lines):
    order = Order.objects.create(customer=customer)
    reserve_inventory(lines)
    create_order_lines(order, lines)
    return order
```

Nested `atomic()` blocks normally use savepoints. Catch database exceptions
outside the atomic block whose rollback you expect; catching them inside can
leave the transaction marked as broken until it exits.

Keep transactions short. Do not perform slow network requests while holding
locks.

## Concurrency and Locks

`atomic()` provides a boundary, but it does not automatically prevent every race.
Lock rows when a workflow depends on their current state:

```python
from django.db import transaction


@transaction.atomic
def cancel_order(order_id):
    order = Order.objects.select_for_update().get(pk=order_id)
    if order.status != Order.Status.PENDING:
        raise ValueError("Only pending orders can be cancelled")
    order.status = Order.Status.CANCELLED
    order.save(update_fields=["status"])
```

Conditional updates, unique constraints, and database isolation can sometimes
solve the problem with less locking. Design for deadlocks and retry safe
operations when the database reports a transient conflict.

## Side Effects After Commit

An email or queued task must not announce data that later rolls back. Register
the side effect with `transaction.on_commit()`:

```python
from functools import partial

from django.db import transaction


transaction.on_commit(partial(send_order_confirmation, order.id))
```

This improves consistency but is not a durable message handoff by itself. For
critical integration events, consider a transactional outbox processed by a
worker.

## Per-Request Transactions

`ATOMIC_REQUESTS` wraps each view in a transaction. It is convenient but can
increase lock duration and database overhead. Middleware and template response
rendering run outside that transaction, and streaming content is produced after
the view returns. Explicit transaction boundaries are usually easier to reason
about for non-trivial applications.

