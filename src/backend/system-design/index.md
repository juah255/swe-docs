# System Design

System design interviews test how you reason about **trade-offs** under
ambiguity. There is rarely one correct answer. The goal is to show a structured
approach: clarify the problem, estimate scale, sketch a high-level design, then
go deep where it matters.

This overview covers the approach. The details live in focused subtopics:

- [Requirements](requirements.md): functional vs non-functional, clarifying
  questions, capacity estimation.
- [Scalability](scalability.md): scaling, load balancing, caching, replication,
  sharding, CAP, and rate limiting.
- [Microservices](microservices.md): monolith vs microservices, service
  communication, data ownership, sagas, gateways, and serverless.
- [System Design Questions](questions.md): a quick Q&A reference for common
  interview topics.

## Steps for Answering System Design Questions

1. Requirements: functional and non-functional
2. Capacity estimation
3. API design / high-level design
4. Data model
5. High-level architecture
6. Detailed design: component deep-dive
7. Bottlenecks and trade-offs

Drive the interview. State assumptions out loud, confirm them, and keep
narrating your reasoning so the interviewer can follow and steer you.

## Critical Path

The **critical path** is the sequence of dependent operations that determines
the minimum latency of a request. Any delay on this path directly increases
end-to-end response time.

### Example: e-commerce checkout

```text
Place order -> Check inventory -> Reserve item -> Authorize payment -> Write order DB record -> Return confirmation
```

### When do we need to identify the critical path?

- When optimizing latency
- When deciding what to scale first under load
- When checking whether an SLA is achievable
- When planning redundancy for failure-prone components
- When deciding what can move off the synchronous request path

Interview rule:

> If removing a component from the flow does not change user-facing latency, it
> is not on the critical path.

## SLA

SLA stands for **Service Level Agreement**.

In simple terms, it is a **promise the system makes about behavior**, usually to
users or business clients. It is backed by measurable targets and often carries
penalties when missed.

Three related terms are worth separating:

| Term | Meaning |
| --- | --- |
| **SLA** | External, contractual promise (e.g. `99.9%` uptime, with penalties) |
| **SLO** | Internal target the team aims for (usually stricter than the SLA) |
| **SLI** | The actual measured metric (e.g. request success rate, p99 latency) |

A useful framing: SLIs are what you measure, SLOs are what you aim for, and SLAs
are what you owe the customer if you miss.

## Mid/Senior Interview Questions and Answers

### 1. How should you start a system design interview?

**Answer:** Start by clarifying functional requirements, non-functional
requirements, scale, data model, core APIs, and constraints. Do not jump into
databases or diagrams before understanding the problem.

The first few minutes should reduce ambiguity: users, actions, data, traffic,
latency, availability, consistency, and failure expectations.

### 2. How do you keep a system design discussion structured?

**Answer:** Follow a repeatable flow: requirements, estimates, API, data model,
high-level architecture, then a deep dive on one or two hard components. Write
the steps down and check them off so you do not skip backwards under pressure.

State assumptions explicitly and confirm them. The interviewer is grading your
reasoning and prioritization, not whether you recall a specific product design.

### 3. What belongs on the critical path?

**Answer:** Only operations that must complete before the user receives the
response belong on the critical path. Everything else is a candidate for async
processing.

For checkout, inventory reservation and payment authorization may be critical.
Sending marketing email should not be.

### 4. How do you handle a question that is too broad?

**Answer:** Narrow the scope explicitly. Pick the most important use case, state
that you will design it first, and defer secondary features. Confirm the chosen
scope with the interviewer before designing.

This shows prioritization, which is exactly the senior skill being tested.
Designing one path well beats sketching ten paths shallowly.
