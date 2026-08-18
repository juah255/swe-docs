# Pydantic & Data Validation

This is one of the most important parts of FastAPI. Pydantic models define the shape of request and response data, validate it, and power the OpenAPI schema.

## Pydantic BaseModel

A Pydantic model is a class that defines and validates data fields.

```python
from pydantic import BaseModel

class Item(BaseModel):
    name: str
    price: float
    is_available: bool = True
```

FastAPI uses Pydantic models to validate input, serialize output, and generate the OpenAPI schema. Separate models are commonly used for input (`ItemCreate`), output (`ItemRead`), and internal representations to keep boundaries clean.

## Field types

Pydantic supports rich scalar types:

- `str`, `int`, `float`, `bool`
- `datetime`, `date`, `time`, `timedelta`
- `UUID`, `EmailStr` (requires `email-validator`), `Url`, `IPvAnyAddress`
- `Decimal`, `bytes`

```python
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, EmailStr

class User(BaseModel):
    id: UUID
    email: EmailStr
    created_at: datetime
```

## Optional/default values

```python
class Item(BaseModel):
    name: str
    description: str | None = None    # optional
    price: float
    tags: list[str] = []              # default - beware of mutable defaults
    qty: int = 1
```

Use `Field(default=None)` for richer metadata:

```python
from pydantic import Field

class Item(BaseModel):
    qty: int = Field(default=1, ge=0)
```

!!! warning
    Do not use mutable defaults (`tags: list = []` directly). Pydantic handles
    this safely, but prefer `Field(default_factory=list)` for explicit clarity.

## Nested models

Models can contain other models, lists, and dictionaries.

```python
class Address(BaseModel):
    street: str
    city: str

class User(BaseModel):
    name: str
    address: Address
    orders: list[Order] = []
```

Nested validation happens automatically: a bad `orders[0]` fails the whole model.

## Lists and dictionaries

```python
class ShoppingCart(BaseModel):
    items: list[str]
    quantities: dict[str, int]

cart = ShoppingCart(items=["apple"], quantities={"apple": 3})
```

Dict values are validated against the declared value type.

## Validation

Validation happens at model instantiation. Invalid data raises `ValidationError`:

```python
from pydantic import ValidationError

try:
    Item(name="x", price="not-a-number")
except ValidationError as e:
    print(e.errors())
```

In FastAPI, validation failures automatically produce a `422 Unprocessable Entity` response with the error details.

## Field()

`Field()` adds constraints and metadata that FastAPI also uses for OpenAPI docs.

```python
from pydantic import BaseModel, Field

class CreateUser(BaseModel):
    username: str = Field(min_length=3, max_length=32, pattern=r"^[a-z0-9_]+$")
    age: int = Field(ge=0, le=150)
    email: str = Field(examples=["user@example.com"])
```

Common constraints:

- Strings: `min_length`, `max_length`, `pattern`
- Numbers: `gt`, `ge`, `lt`, `le`, `multiple_of`
- Lists: `min_length`, `max_length`
- Docs: `description`, `examples`, `title`

## Custom validators

`field_validator` validates and optionally transforms a single field:

```python
from pydantic import BaseModel, field_validator

class CreateUser(BaseModel):
    username: str

    @field_validator("username")
    @classmethod
    def username_alphanumeric(cls, v: str) -> str:
        if not v.isalnum():
            raise ValueError("must be alphanumeric")
        return v.lower()
```

`model_validator` runs across the whole model (e.g. field interactions):

```python
from pydantic import BaseModel, model_validator

class Booking(BaseModel):
    start: datetime
    end: datetime

    @model_validator(mode="after")
    def end_after_start(self):
        if self.end <= self.start:
            raise ValueError("end must be after start")
        return self
```

In Pydantic v2, `@field_validator` replaces v1's `@validator`, and `mode="after"` / `mode="before"` controls whether the validator runs after coercion or on the raw input.

## Serialization/deserialization

- `.model_dump()` → dict (v2; v1 was `.dict()`)
- `.model_dump_json()` → JSON string (v1 was `.json()`)
- `.model_validate(data)` → model from dict/object (v1 was `.parse_obj()`)
- `Model.model_validate_json(json_str)` → model from JSON (v1 was `.parse_raw()`)

```python
item = Item(name="x", price=1.5)
data = item.model_dump()          # {"name": "x", "price": 1.5}
json_str = item.model_dump_json() # '{"name":"x","price":1.5}'
back = Item.model_validate(data)
```

## Pydantic settings

`pydantic-settings` loads configuration from environment variables with validation.

```bash
pip install pydantic-settings
```

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="APP_")

    database_url: str
    jwt_secret: str
    debug: bool = False

settings = Settings()
```

- Env vars map to fields automatically (`APP_DATABASE_URL` → `database_url`).
- Secrets can use `SecretStr` so they never print by accident.
- Cache the `Settings()` instance or use it inside a dependency.

## Pydantic v2 concepts

Pydantic v2 is a Rust-core rewrite with faster validation and a cleaner API:

- `model_validate` / `model_dump` replace `parse_obj` / `dict`
- `field_validator` / `model_validator` replace `@validator` / `@root_validator`
- `ConfigDict` replaces the old `Config` inner class
- `Field` constraints unchanged in spirit; `constr` / `conint` aliases removed
- Validation is significantly faster; serialization is customizable via `serde`
  or `field_serializer`

```python
class User(BaseModel):
    model_config = ConfigDict(extra="forbid", frozen=True)

    id: int
    name: str
```

Useful `ConfigDict` options: `extra` (`ignore`/`forbid`/`allow`), `frozen` (immutability), `str_strip_whitespace`, `validate_assignment`.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between `Field` and `field_validator`?

**Answer:** `Field` declares declarative constraints and metadata (min/max
length, regex, examples) used by Pydantic for validation and by FastAPI for
OpenAPI documentation. `field_validator` runs custom Python logic on a field to
enforce rules that cannot be expressed declaratively or to transform the value.

Prefer `Field` when possible; use validators for cross-field or complex rules.

### 2. What changed between Pydantic v1 and v2?

**Answer:** Pydantic v2 rewrote validation in Rust, making it several times
faster. The API changed: `parse_obj` → `model_validate`, `dict()` → `model_dump()`,
`@validator` → `@field_validator`, `Config` → `ConfigDict`. The `mode` parameter
on validators controls before/after coercion behavior.

### 3. How does FastAPI use Pydantic for both input and output?

**Answer:** For input, the request body is validated against the Pydantic model
before the endpoint runs; invalid data returns `422`. For output, `response_model`
validates and filters the endpoint's return value, stripping fields not declared
in the response model and catching schema violations early.

### 4. How do you prevent extra fields from being accepted?

**Answer:** Set `model_config = ConfigDict(extra="forbid")` on the model so
unknown keys raise a validation error. `extra="ignore"` silently drops them,
which can hide client mistakes and enable mass-assignment bugs.

### 5. When should you use a `model_validator`?

**Answer:** Use a `model_validator(mode="after")` when a rule spans multiple
fields - "end after start", "total equals sum of items", "either email or phone".
Use `mode="before"` when you must normalize raw input (strings, JSON) before
field-level parsing.