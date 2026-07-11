# Architecture Diagrams

Diagrams are communication tools. The goal is not to draw everything, but to
make a specific part of the system easier to reason about.

## Architecture Diagram

An **architecture diagram** shows the major components of a system, their
boundaries, and how data or requests move between them.

Use it to explain:

- Service or module boundaries
- Ownership of data and responsibilities
- External systems and integrations
- Sync vs async communication
- Deployment shape at a high level

Good architecture diagrams are:

- Simple enough to read in under a minute
- Focused on boundaries and relationships
- Labeled with only the technologies or protocols that matter

Avoid turning an architecture diagram into a detailed implementation map. If it
has every class, table, and method, it is no longer an architecture diagram.

## Sequence Diagram

A **sequence diagram** shows how a specific flow unfolds over time between
participants.

Use it when you need to explain:

- Login or checkout flows
- Request/response steps across services
- Retry, timeout, or fallback behavior
- Asynchronous workflows with events or jobs

Sequence diagrams are strongest when the order of operations matters. They make
latency, dependency chains, and failure points visible.

Keep them focused on one flow. If a single diagram covers too many branches, it
becomes hard to read and loses its value.

## Class Diagram

A **class diagram** shows the static structure of a design: classes, interfaces,
relationships, and dependencies.

Use it to explain:

- Entity and service relationships
- Inheritance and interface implementation
- Composition and aggregation
- Responsibilities inside a module

Class diagrams belong in design discussions more than architecture discussions.
They are useful when the object model is complex enough that the relationships
need to be explicit.

## Choosing the Right Diagram

| Diagram | Best for | Not for |
| --- | --- | --- |
| Architecture diagram | System boundaries, ownership, communication | Internal class-level detail |
| Sequence diagram | Step-by-step behavior over time | Whole-system structure |
| Class diagram | Object structure and relationships | Runtime request flow |

## Common Mistakes

- Mixing too many levels of detail in one diagram
- Using diagrams to hide missing decisions
- Drawing boxes without explaining boundaries or ownership
- Letting diagrams become stale after the code changes
- Using class diagrams when a simpler flow description would do

## Mid/Senior Interview Questions and Answers

### 1. What is the purpose of an architecture diagram?

**Answer:** An architecture diagram communicates the system's major
components, their boundaries, and how they interact. It should help another
engineer understand ownership, dependencies, and communication style without
digging through code.

The best diagrams are intentionally incomplete. They show the important shape
of the system, not every technical detail.

### 2. When should you use a sequence diagram?

**Answer:** Use a sequence diagram when the order of calls matters, such as
request flows, distributed transactions, retries, or event-driven workflows.
They are especially useful for debugging hidden dependencies and explaining
latency.

If you are trying to explain static structure instead of time order, a sequence
diagram is the wrong tool.

### 3. What is a class diagram good for?

**Answer:** A class diagram is useful for showing the static relationships
between classes, interfaces, and objects inside a design. It helps when the
object model is complex enough that the dependencies are hard to keep in your
head.

It is not the right choice for system-level architecture. At that level, it adds
noise instead of clarity.
