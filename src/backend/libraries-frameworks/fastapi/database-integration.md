# Database Integration

This should be a major section of your study. SQL databases with SQLAlchemy, async drivers, PostgreSQL, sessions, migrations, and the service/repository layering.

## The layering

Keep the data access behind services:

```
FastAPI
   ↓
Service
   ↓
Repository / ORM
   ↓
Database
```

Endpoints validate and delegate to services. Services orchestrate repositories
and transactions. The repository/ORM layer maps objects to SQL.

## SQLAlchemy

```bash
pip install sqlalchemy
```

SQLAlchemy is the most common ORM for FastAPI. SQLAlchemy 2.x uses a modern
style with `Mapped` annotations and `select()`:

```python
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str] = mapped_column(unique=True)
    name: Mapped[str]
```

## Sessions

A session is a transactional unit of work. The `get_db` dependency provides one
per request:

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

engine = create_engine(settings.database_url, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

`autoflush=False` and `autocommit=False` are the recommended settings. The
`yield` dependency guarantees the session closes after the request.

## Models

Models map Python classes to tables:

```python
from sqlalchemy import ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

class Post(Base):
    __tablename__ = "posts"

    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str] = mapped_column(String(200))
    author_id: Mapped[int] = mapped_column(ForeignKey("users.id"))

    author: Mapped["User"] = relationship(back_populates="posts")

class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    email: Mapped[str]
    posts: Mapped[list["Post"]] = relationship(back_populates="author")
```

## Relationships

- `ForeignKey` on the column, `relationship()` on the Python side.
- `relationship` for `one-to-many` / `many-to-many` with `secondary=` for
  association tables.
- Load related objects eagerly with `selectinload` / `joinedload`, or lazily by
  default (watch for the N+1 problem).

```python
from sqlalchemy import select
from sqlalchemy.orm import selectinload

stmt = select(User).options(selectinload(User.posts))
```

## CRUD

SQLAlchemy 2.x style:

```python
# create
db.add(User(email="a@b.com", name="A"))
db.commit()
db.refresh(user)

# read
user = db.get(User, user_id)                     # by primary key
users = db.scalars(select(User)).all()           # list
user = db.scalars(select(User).where(User.email == email)).first()

# update
user.name = "New name"
db.commit()

# delete
db.delete(user)
db.commit()
```

## Transactions

A session wraps work in a transaction that you commit or roll back:

```python
def transfer(db: Session, from_id: int, to_id: int, amount: int):
    try:
        sender = db.get(Account, from_id)
        receiver = db.get(Account, to_id)
        sender.balance -= amount
        receiver.balance += amount
        db.commit()
    except Exception:
        db.rollback()
        raise
```

For multiple sessions or async transactions, use the engine/connection level
transactions or `AsyncSession` `begin()`.

## Connection pooling

SQLAlchemy manages a connection pool automatically:

```python
engine = create_engine(
    settings.database_url,
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_pre_ping=True,
)
```

- `pool_pre_ping=True` checks stale connections before use.
- Right-size the pool to your database limits (`max_connections`).
- For high concurrency, put PgBouncer in front of PostgreSQL to share
  connections across workers.

## Alembic migrations

```bash
pip install alembic
alembic init migrations
```

Configure `migrations/env.py` to read the app's `DATABASE_URL` and `Base.metadata`:

```python
from app.core.config import settings
from app.models import Base  # import all models

config.set_main_option("sqlalchemy.url", settings.database_url)
target_metadata = Base.metadata
```

Commands:

```bash
alembic revision --autogenerate -m "create users table"  # generate
alembic upgrade head                                       # apply
alembic downgrade -1                                       # revert
```

Migrations are versioned SQL scripts. Never use `create_all` for schema changes
in production; always use Alembic.

## PostgreSQL

```bash
pip install psycopg[binary]    # sync driver
# or
pip install asyncpg            # async driver
```

```python
from sqlalchemy import create_engine

engine = create_engine(
    "postgresql+psycopg://user:pass@localhost:5432/mydb",
    pool_size=10,
    pool_pre_ping=True,
)
```

PostgreSQL features that matter for FastAPI apps: JSONB columns, full-text
search, array types, `ON CONFLICT` upserts, `RETURNING`, and partial indexes.

## Async database drivers

For async endpoints use `asyncpg` and `AsyncSession`:

```bash
pip install sqlalchemy[asyncio] asyncpg
```

```python
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

engine = create_async_engine(settings.database_url)  # postgresql+asyncpg://...
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
```

Async session queries:

```python
from sqlalchemy import select

async def get_user(user_id: int, db: AsyncSession):
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()
```

Async code requires async endpoints (`async def`) and `await` on every query -
see [Async Programming](async-programming.md).

## asyncpg

`asyncpg` is a fast async PostgreSQL driver that SQLAlchemy uses as its
`asyncpg://` dialect:

```python
engine = create_async_engine(
    "postgresql+asyncpg://user:pass@localhost:5432/mydb",
    pool_size=10,
    max_overflow=20,
)
```

Combined with FastAPI's event loop, it gives very high throughput under
concurrent I/O because no thread blocks on database calls.

## PostgreSQL-specific features

- **JSONB** - store and query semi-structured data.
- **Full-text search** - `to_tsvector` / `to_tsquery` for search.
- **`ON CONFLICT`** - atomic upserts without a race.
- **`RETURNING`** - get inserted/updated rows in one round trip.
- **Partial/expression indexes** - index only the rows you query.
- **`pg_trgm`** - trigram search for fuzzy matching.

## Mid/Senior Interview Questions and Answers

### 1. Why do you use a `yield` dependency for the database session?

**Answer:** The `get_db` dependency opens a session before the endpoint runs and
closes it in `finally` after the response. This guarantees cleanup even when the
endpoint raises, keeps sessions request-scoped, and reuses the same session for
nested dependencies in one request.

### 2. What is the difference between `sync` and `async` SQLAlchemy?

**Answer:** Sync SQLAlchemy uses blocking drivers (`psycopg2`) and must run in a
threadpool. Async SQLAlchemy uses `AsyncSession` with async drivers (`asyncpg`)
and is awaited on the event loop. Async is faster under high concurrency because
no thread blocks on database I/O, but every query must be `await`ed.

### 3. What is the N+1 query problem and how do you fix it?

**Answer:** N+1 happens when you load a list, then execute one query per row to
fetch related data - N extra queries. Fix with eager loading: `selectinload` or
`joinedload` to fetch relations in the same query, or batch with `WHERE id IN
(...)`. Check `echo=True` or use SQLAlchemy logging to spot query counts.

### 4. How do you handle database migrations?

**Answer:** Use Alembic, which generates versioned migration scripts by diffing
models against the current schema. Apply them with `alembic upgrade head` in
deployments. Never use `create_all` in production because it cannot alter
existing tables safely or track schema versions.

### 5. How do you size connection pools and when do you use PgBouncer?

**Answer:** Set `pool_size` and `max_overflow` based on the database's
`max_connections` and the number of workers. Each worker holds up to
pool_size + max_overflow connections. With many workers, use PgBouncer in
transaction mode to share a small pool of database connections across them,
avoiding connection exhaustion.