# NestJS

NestJS architecture notes, module conventions, and examples.

## Mid/Senior Interview Questions and Answers

### 1. What problem does NestJS solve in Node.js backend projects?

**Answer:** NestJS provides a structured application architecture with modules,
controllers, providers, dependency injection, guards, pipes, interceptors, and
filters.

It is useful when a Node.js codebase needs clear boundaries and conventions
similar to enterprise backend frameworks.

### 2. What is the difference between a controller and a provider?

**Answer:** A controller handles incoming transport requests and returns
responses. A provider is an injectable class that implements reusable behavior,
such as services, repositories, clients, or configuration helpers.

Controllers should stay thin. Business logic belongs in services or domain
classes.

### 3. How do guards, pipes, interceptors, and filters differ?

**Answer:** Guards decide whether a request is allowed. Pipes transform or
validate input. Interceptors wrap execution for concerns such as logging,
mapping responses, or timing. Filters handle exceptions and convert them into
responses.

Order and responsibility matter because putting validation, authorization, and
error handling in the wrong layer makes behavior inconsistent.

### 4. How should modules be designed in NestJS?

**Answer:** Modules should group cohesive features and expose only the providers
that other modules need. Avoid a single global module that imports everything.

Feature modules, shared infrastructure modules, and explicit exports keep
dependency direction understandable.
