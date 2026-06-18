# Normalization

Normalization is the process of organizing data in a relational database to
reduce redundancy and unwanted dependencies. It usually involves dividing a
large table into smaller, related tables.

The main goals of normalization are to:

- prevent inconsistent or duplicated data;
- improve data integrity;
- make inserts, updates, and deletions safer; and
- make relationships between data easier to understand.

## Data Anomalies

Poorly designed tables often store the same fact in multiple rows. This can
cause three common anomalies.

### Insertion Anomaly

An insertion anomaly occurs when one fact cannot be added without adding an
unrelated fact.

For example, if course information is stored only alongside student
enrollments, a new course cannot be added until at least one student enrolls in
it.

### Update Anomaly

An update anomaly occurs when the same fact appears in multiple rows and must
be updated everywhere.

For example, if the name of course `C-10` is stored in every enrollment row,
renaming the course requires updating every occurrence. Missing one row leaves
the database inconsistent.

### Deletion Anomaly

A deletion anomaly occurs when deleting one fact accidentally removes another
useful fact.

For example, deleting the only student enrolled in course `C-20` may also
remove the only stored record of that course.

## First Normal Form (1NF)

A table is in **First Normal Form (`1NF`)** when:

- every column contains atomic, or indivisible, values;
- a cell does not contain a list or repeating group; and
- each row can be uniquely identified.

The following table violates `1NF` because `BooksBorrowed` contains multiple
values in a single cell:

| StudentID | StudentName | BooksBorrowed        |
|-----------|-------------|----------------------|
| 101       | Ann Smith   | Dune, 1984           |
| 102       | John Doe    | The Hobbit           |
| 103       | Lisa Ray    | Dune, Foundation     |

To satisfy `1NF`, store one borrowed book per row:

| StudentID | StudentName | Book       |
|-----------|-------------|------------|
| 101       | Ann Smith   | Dune       |
| 101       | Ann Smith   | 1984       |
| 102       | John Doe    | The Hobbit |
| 103       | Lisa Ray    | Dune       |
| 103       | Lisa Ray    | Foundation |

The combination of `StudentID` and `Book` can identify each borrowing record.

## Second Normal Form (2NF)

A table is in **Second Normal Form (`2NF`)** when:

- it is already in `1NF`; and
- every non-key attribute depends on the entire primary key, not only part of a
  composite key.

The following enrollment table may use (`StudentID`, `CourseID`) as its
composite primary key:

| StudentID | CourseID | StudentName | CourseName       |
|-----------|----------|-------------|------------------|
| 101       | C-10     | Ann Smith   | Intro to SQL     |
| 101       | C-20     | Ann Smith   | Data Structures  |
| 102       | C-10     | John Doe    | Intro to SQL     |

It violates `2NF` because:

- `StudentName` depends only on `StudentID`; and
- `CourseName` depends only on `CourseID`.

These are **partial dependencies**. The table can be decomposed into:

**Students**

| StudentID | StudentName |
|-----------|-------------|
| 101       | Ann Smith   |
| 102       | John Doe    |

**Courses**

| CourseID | CourseName       |
|----------|------------------|
| C-10     | Intro to SQL     |
| C-20     | Data Structures  |

**Enrollments**

| StudentID | CourseID |
|-----------|----------|
| 101       | C-10     |
| 101       | C-20     |
| 102       | C-10     |

Now each non-key attribute depends on the complete key of its table.

## Third Normal Form (3NF)

A table is in **Third Normal Form (`3NF`)** when:

- it is already in `2NF`; and
- no non-key attribute depends on another non-key attribute.

The following table violates `3NF`:

| StudentID | StudentName | MajorID | MajorName         |
|-----------|-------------|---------|-------------------|
| 101       | Ann Smith   | M-1     | Computer Science  |
| 102       | John Doe    | M-2     | Physics           |
| 103       | Lisa Ray    | M-1     | Computer Science  |

Here, `StudentID` determines `MajorID`, and `MajorID` determines `MajorName`.
Therefore, `MajorName` depends on `StudentID` through `MajorID`. This is a
**transitive dependency**.

The table can be decomposed into:

**Students**

| StudentID | StudentName | MajorID |
|-----------|-------------|---------|
| 101       | Ann Smith   | M-1     |
| 102       | John Doe    | M-2     |
| 103       | Lisa Ray    | M-1     |

**Majors**

| MajorID | MajorName         |
|---------|-------------------|
| M-1     | Computer Science  |
| M-2     | Physics           |

Now `MajorName` is stored once and depends directly on the key of the `Majors`
table.

## Summary

| Normal Form | Main Requirement                                  |
|-------------|---------------------------------------------------|
| `1NF`       | Store one atomic value in each field.              |
| `2NF`       | Remove dependencies on part of a composite key.    |
| `3NF`       | Remove dependencies between non-key attributes.    |

A common memory aid is:

> Every non-key attribute should depend on **the key, the whole key, and
> nothing but the key**.

Normalization improves data integrity, but highly normalized databases may
require more joins. In read-heavy systems, selective **denormalization** may be
used when measured performance needs justify the additional redundancy.

## Mid/Senior Interview Questions and Answers

### 1. Why is normalization important?

**Answer:** Normalization reduces duplicated facts and prevents insertion,
update, and deletion anomalies. It helps keep data consistent by storing each
fact in the right place.

In production systems, normalization also makes constraints and ownership easier
to reason about.

### 2. When is denormalization a good idea?

**Answer:** Denormalization is useful when measured read performance,
simplified queries, or reporting needs justify storing duplicate or derived
data.

It should come with a consistency strategy: transactions, background rebuilds,
event processing, materialized views, or clear tolerance for stale data.

### 3. How do you explain 1NF, 2NF, and 3NF in an interview?

**Answer:** `1NF` means columns contain atomic values and rows are identifiable.
`2NF` means non-key attributes depend on the whole composite key. `3NF` means
non-key attributes do not depend on other non-key attributes.

The practical summary is: each fact should be stored once and depend on the
right key.

### 4. How does normalization interact with application performance?

**Answer:** Normalization can increase joins, which may affect read-heavy
queries. However, poor schema design can create much worse problems through
inconsistent data and expensive cleanup.

Start normalized for correctness, measure real query patterns, then denormalize
specific hot paths when needed.

### 5. What mistakes do teams make with normalization?

**Answer:** Common mistakes include over-normalizing simple read models,
under-normalizing core transactional data, ignoring constraints, and
denormalizing without a plan to keep duplicated data correct.

Senior design separates transactional schemas from read-optimized projections
when the workload needs both.
