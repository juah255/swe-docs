# Libraries & Frameworks

Framework-specific guides and implementation notes.

## Mid/Senior Interview Questions and Answers

### 1. How do you evaluate whether a framework is a good fit?

**Answer:** Evaluate ecosystem maturity, team familiarity, performance profile,
security posture, deployment model, observability, testing support, and long-term
maintenance cost.

The best framework is not always the newest one. It is the one that fits the
system constraints and team operating model.

### 2. What framework knowledge matters at senior level?

**Answer:** Senior engineers need to understand lifecycle, dependency injection,
configuration, validation, error handling, data access, security hooks,
performance bottlenecks, and deployment behavior.

Knowing only route syntax is not enough for production ownership.

### 3. When should you avoid framework-specific code?

**Answer:** Avoid framework coupling in core business logic when that logic
should be testable and reusable outside HTTP handlers, jobs, or framework
lifecycle hooks.

Keep framework code near boundaries and keep domain logic in ordinary modules or
classes.
