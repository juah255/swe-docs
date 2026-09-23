# Django REST Framework

Django REST Framework (DRF) is a third-party toolkit built on Django. It adds
serializers, API views, authentication and permission policies, throttling,
pagination, content negotiation, and interactive API tooling.

## Serializers

Serializers validate input and transform model instances or Python values into
response data.

```python
from rest_framework import serializers

from .models import Order


class OrderSerializer(serializers.ModelSerializer):
    customer_email = serializers.EmailField(
        source="customer.email",
        read_only=True,
    )

    class Meta:
        model = Order
        fields = ["id", "reference", "status", "customer_email", "created_at"]
        read_only_fields = ["id", "status", "created_at"]
```

Declare writable fields deliberately. Serializer validation does not replace
database constraints, transaction handling, or authorization. Pass
server-controlled values explicitly to `save()`:

```python
serializer.is_valid(raise_exception=True)
order = serializer.save(customer=request.user)
```

## Views, ViewSets, and Routers

Choose the least abstract entry point that stays clear:

- `APIView` for explicit request methods and unusual workflows;
- generic views for standard list, create, retrieve, update, and delete flows;
- viewsets and routers for a consistent resource-oriented API.

```python
from rest_framework import permissions, viewsets


class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return (
            Order.objects.filter(customer=self.request.user)
            .select_related("customer")
        )
```

Scoping `get_queryset()` prevents callers from retrieving another user's object
through detail routes. Add object permissions when policy is more complex.

## API Policy

Configure the following explicitly, globally or per view:

- authentication mechanisms;
- request and object permissions;
- throttling for abuse control, not as the only denial-of-service defense;
- pagination and maximum page size;
- accepted parsers and rendered formats;
- versioning and deprecation policy;
- consistent exceptions and error envelopes.

Cookie-authenticated APIs need CSRF protection. Token-based APIs need secure
issuance, rotation, revocation, storage, and transport.

## Preventing Query Problems

DRF does not automatically optimize ORM queries based on serializer fields. A
nested serializer can create an N+1 query pattern. Shape the queryset with
`select_related()`, `prefetch_related()`, annotations, and bounded pagination,
then assert query counts for important endpoints.

Avoid serializing an unbounded queryset or accepting an arbitrary ordering field.
Whitelist filter and ordering fields and cap expensive searches.

## Writes and Workflows

`ModelViewSet` is useful for straightforward CRUD. A domain action such as
paying, approving, or cancelling an order is often clearer as an explicit
endpoint calling a transactional service. Do not encode a state machine as
unrestricted `PATCH` access to a status field.

For long-running work, return an accepted response with a job identifier and run
the operation in a durable worker. Do not keep a request open or start an
untracked thread.

## Schemas and Testing

Generate an OpenAPI schema and treat it as a contract, but review it for accurate
authentication, nullability, errors, and examples. Test validation, permissions,
pagination, content types, status codes, and query behavior. A schema alone does
not prove that authorization or business invariants are correct.

