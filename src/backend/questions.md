# Backend Interview Questions

Comprehensive index of all mid/senior interview questions across backend topics.
Answers are in the referenced source files.

## Software Architecture

*Source:* `software-architecture/`

- How do you tell architecture from design?
- What does "good architecture" actually mean?
- How do you evaluate an existing architecture?
- When is it worth investing in architecture up front?
- How do cohesion and coupling actually guide your work?
- Why does dependency direction matter?
- What does "fail fast" mean at an architectural level?
- How do you decide which decisions to reverse-proof?
- When is it right to break these principles?
- How do you choose an architectural style?
- When is hexagonal architecture worth its cost?
- What are the real costs of microservices?
- What problems does event-driven architecture actually solve?
- When would you use CQRS and event sourcing?
- What is the difference between a controller and a service?
- Why is the repository pattern useful?
- What is an anemic domain model and how do you fix it?
- When would you use DTOs versus returning entities directly?
- How thin should a controller be?
- What is the purpose of an architecture diagram?
- When should you use a sequence diagram?
- What is a class diagram good for?
- How do you choose between database-per-tenant, schema-per-tenant, and shared-schema?
- How do you prevent one tenant from reading another tenant's data in a shared-schema system?
- How do you handle the noisy-neighbor problem?
- How do you run schema migrations across thousands of tenants?
- When is single-tenant the right choice?
- How do you decide between monolith and microservices?
- How do you maintain data consistency across services?
- When would you choose gRPC over REST?
- How do you evolve a monolith toward microservices?
- When is serverless a good fit?
- How do circuit breakers prevent cascading failures?
- When would you use a circuit breaker vs just timeouts and retries?
- How do you test circuit breakers?
- What is a bounded context and why does it matter?
- What is an aggregate and how do you choose its boundary?
- What is an anemic domain model and why avoid it?
- When would you not use DDD?
- How does DDD relate to microservices?
- How do you approach a "design this system" question at the architecture level?
- What is architectural debt and how do you address it?
- When would you rewrite versus refactor?
- How do you document architecture without it going stale?
- What is the biggest mistake engineers make when choosing an architecture?

## System Design

*Source:* `system-design/`

- How should you start a system design interview?
- How do you keep a system design discussion structured?
- What belongs on the critical path?
- How do you handle a question that is too broad?
- Why are non-functional requirements more important than feature lists?
- How do you do capacity estimation without exact numbers?
- How do you decide between strong and eventual consistency?
- What clarifying questions matter most for a read-heavy system?
- How do availability tiers affect your design?
- How do you approach an unfamiliar system design question?
- How do you identify the bottleneck in a design?
- How do you make a system resilient to failures?
- How do you handle a sudden 10x traffic spike?
- How do you evolve a monolith toward microservices?
- An API suddenly becomes slow after reaching 5,000 requests/minute. How would you investigate?
- When do you choose L4 over L7 load balancing?
- How does consistent hashing help with load balancing?
- What happens when a load balancer itself fails?
- What is the difference between a reverse proxy and an API gateway?
- Why terminate TLS at the reverse proxy instead of each backend?
- What is the role of an API gateway, and what is its risk?
- When would you use the BFF pattern?
- Should business logic live in the API gateway?
- When do you need a dedicated service registry vs DNS-based discovery?
- What happens when the service registry itself fails?
- How does service discovery work in Kubernetes?
- Which rate limiting algorithm would you pick and why?
- How do you design rate limiting for a distributed API?
- What are the trade-offs of fail-open vs fail-closed?
- When should you use a CDN vs application-level caching?
- How do you handle cache invalidation on a CDN?
- How does a CDN affect your system design in an interview?
- What makes cache invalidation hard?
- When do you choose Redis over Memcached?
- How do you prevent cache stampedes?
- When do you choose horizontal over vertical scaling?
- Why does replication not solve write scaling?
- How do you choose a good shard key?
- When would you choose a message queue over synchronous communication?
- What is the difference between at-least-once and exactly-once delivery?
- What is the outbox pattern and why does it matter?
- How does CAP guide a real design?
- When would you choose Cassandra over PostgreSQL?
- What is quorum and why does it matter?
- Why are NFRs more important than feature lists in system design?
- How do you trade off consistency and availability?
- How do you prioritize NFRs when they conflict?
- How do you handle NFRs in a microservices architecture?
- How do availability tiers affect your design?
- What are the most common causes of downtime?
- How do you handle graceful degradation?
- How do you make a system resilient to failures?
- What is the difference between availability and reliability?
- How do circuit breakers prevent cascading failures?
- How do you determine if a latency target is achievable?
- Why is p99 more important than average latency?
- How do you optimize for both latency and throughput?
- What does "defense in depth" mean in backend security?
- Why should you never build your own cryptographic algorithms?
- How do you approach security in a microservices architecture?
- What is the difference between fault tolerance and high availability?
- How do you design for fault tolerance in a distributed system?
- When is fault tolerance not worth the cost?
- Why does maintainability matter in system design interviews?
- How do you design for maintainability in a distributed system?
- What is technical debt and how do you manage it?

## APIs & Communication

*Source:* `apis-and-communication/`

- How do you choose between REST, GraphQL, and gRPC?
- What makes an API contract maintainable?
- How should APIs protect themselves under load?
- What should be considered when designing API authorization?
- What does stateless mean in REST?
- What is the difference between PUT and PATCH?
- Which HTTP methods should be idempotent?
- When should an API return 401, 403, or 404?
- How should pagination be designed for large datasets?
- How should API errors be structured?
- What makes an API RESTful?
- When should you return 200, 201, 204, 400, 401, 403, 404, 409, 500?
- Design REST APIs for an e-commerce product service.
- Users report duplicate orders when clicking "Pay" multiple times. How would you prevent duplicate order creation?
- What should middleware handle, and what should it avoid?
- What is the responsibility of a controller?
- How do services and repositories differ?
- Why are DTOs useful in API design?
- Where should business logic live in a layered backend?
- When would you choose WebSockets instead of REST?
- Why are WebSockets harder to scale than stateless HTTP?
- How should authentication work with WebSockets?
- What failures should a WebSocket client handle?
- Why should access tokens be short-lived?
- Where should a browser application store tokens?
- Why should sensitive data not be stored in a JWT payload?
- What is the difference between authentication and authorization?
- How should refresh token rotation work?
- What is the difference between OAuth and OpenID Connect?
- How do you design role-based access control safely?
- What are common JWT validation mistakes?
- What is a REST API?
- What does stateless mean in HTTP?
- What is the difference between GET, POST, PUT, and PATCH?
- What is the difference between 401 Unauthorized and 403 Forbidden?
- Why can an API request work in Postman but fail in the browser?
- What is CORS?
- What is the difference between cookies, local storage, and session storage?
- What is JWT, and why is it URL-safe?
- What is RBAC?
- What is the difference between a service and a repository?
- What is a WebSocket?
- How is WebSocket different from normal HTTP?
- When should you use WebSocket instead of polling or SSE?
- What should be considered when scaling WebSockets?

## Concurrency

*Source:* `concurrency/`

- What is the difference between concurrency and parallelism?
- Why does concurrency create bugs in backend systems?
- How do you choose between threads, async, and processes?
- How can databases help with concurrency?
- Why does async not automatically make code faster?
- When are threads a better choice than async?
- How can async servers still fail under high traffic?
- What is backpressure?
- What is the difference between blocking and non-blocking I/O?
- Explain the difference between Threading, Multiprocessing, and Asyncio.
- Your API processes uploaded images. Would you choose threads, processes, or async?
- How can two HTTP requests create a race condition?
- How do optimistic and pessimistic concurrency differ?
- How do unique constraints prevent race conditions?
- How do you test for race conditions?
- What conditions are usually required for a deadlock?
- How do you reduce deadlocks in application code?
- How do you handle database deadlocks?
- How would you debug a deadlock in production?
- When should you use a mutex?
- When should you use a semaphore?
- What makes critical sections risky?
- What is the difference between local locks and distributed locks?
- Can a mutex protect multiple processes?
- What is concurrency?
- What is thread safety?
- What is a critical section?
- What is the difference between a mutex and a semaphore?
- What is the difference between a thread and a process?
- What is blocking versus non-blocking I/O?
- How can two requests create a race condition in a backend application?
- How would you protect shared in-memory data from concurrent writes?
- How can database transactions help with concurrency issues?
- How would you debug a deadlock in production?

## Databases (DBMS)

*Source:* `dbms/`

- What is ACID?
- What isolation levels exist and when would you use each?
- What is the difference between a clustered and non-clustered index?
- When would you choose a NoSQL database over a relational database?
- What is a database index and how does it work?
- What is the N+1 query problem?
- What is a deadlock in a database?
- What is connection pooling and why does it matter?
- What is a database transaction?
- What is sharding and when is it necessary?
- What is the difference between vertical and horizontal partitioning?
- How do you handle database migrations safely?
- What is the difference between SQL and NoSQL databases?
- What is a CTE and when would you use it?
- How do window functions work?
- What is a covering index?
- When would you use a view versus a materialized view?
- What is a UNION vs JOIN?
- How does the query planner use statistics?
- What is a partial index?
- What is an index and how does it work internally?
- What is the difference between a clustered and non-clustered index?
- When would you create a composite index?
- What is index cardinality and why does it matter?
- How do you detect and fix unused indexes?
- What is the difference between 1NF, 2NF, 3NF, and BCNF?
- When would you denormalize?
- How do you identify normalization violations in a legacy schema?
- What is a junction table and when do you need one?
- What is a surrogate key vs natural key?
- What is the difference between a primary key and a unique key?
- What is a foreign key and why does it matter for data integrity?
- How do you choose between storing a value and computing it from related data?
- What is the difference between MongoDB and Cassandra?
- When would you choose DynamoDB over PostgreSQL?
- What is the difference between a document store and a wide-column store?
- When would you use a graph database?
- What is the CAP theorem in practice?
- How do you handle schema changes in a NoSQL database?
- What is the difference between Redis cache and a Redis database?
- What is an ORM and what problems does it solve?
- What is the N+1 query problem and how do you prevent it?
- When would you avoid the ORM and write raw SQL?
- How do you manage database migrations with an ORM?
- How does an ORM handle transactions?
- What is lazy loading vs eager loading?
- How do you test code that uses an ORM?
- What is a unit of work pattern in ORMs?
- What are the trade-offs of storing sessions in Redis vs a database?
- How would you implement rate limiting with Redis?
- What happens when Redis runs out of memory?
- What is the difference between SQL and NoSQL?
- What is indexing and how does it improve query performance?
- What is a LEFT JOIN and when do you use it?
- What is the difference between DELETE and TRUNCATE?
- What is a stored procedure?
- What is the difference between CHAR and VARCHAR?
- What is normalization?

## Design Patterns

*Source:* `design-patterns/`

- How do you decide whether to introduce a design pattern?
- What is the main risk of overusing patterns?
- How are the three pattern categories different?
- Are patterns still relevant with modern frameworks?
- When is a singleton acceptable in a backend service?
- How do factory method and abstract factory differ?
- When would you choose a builder over a constructor?
- What is the most common bug with the prototype pattern?
- How do dependency injection containers relate to creational patterns?
- How do adapter and facade differ?
- When would you use a decorator instead of inheritance?
- What problems can a proxy hide from callers?
- When does a facade become an anti-pattern?
- What problem does the bridge pattern solve that simple inheritance cannot?
- How do you choose between strategy and template method?
- What are the failure-handling risks of the observer pattern?
- Why is the command pattern useful for job processing?
- When should you reach for the state pattern instead of a status field?
- What is a common bug in chain of responsibility implementations?
- How do you decide which pattern, if any, to apply?
- How would you refactor a large conditional that selects behavior?
- When is the singleton pattern actually appropriate?
- How do patterns relate to SOLID principles?
- Which patterns are already provided by modern frameworks?

## OOP

*Source:* `oop/`

- What is inheritance and when would you use it?
- What is polymorphism and how does it work in practice?
- What is encapsulation and why does it matter?
- What is composition over inheritance?
- What is the difference between an abstract class and an interface?
- What is method overloading vs overriding?
- What is a constructor?
- What is the diamond problem?
- How do the SOLID principles apply to backend design?
- What is the Single Responsibility Principle?
- What is the Open/Closed Principle?
- What is the Liskov Substitution Principle?
- What is the Interface Segregation Principle?
- What is the Dependency Inversion Principle?
- What is a strategy pattern?
- What is a singleton and its problems?
- What is a factory pattern?
- What is an observer pattern?
- What is a repository pattern?
- What is a dependency injection?
- What is a decorator pattern?
- What is the difference between composition and inheritance?
- What is the difference between an abstract class and an interface?
- What is a mixin?
- What is the difference between aggregation and composition?
- What is the difference between overloading and overriding?
- What is the difference between an object and a class?
- What is the difference between a class and a struct?
- What is the difference between shallow copy and deep copy?

## Data Structures & Algorithms

*Source:* `dsa/`

- What is Big-O notation and why does it matter?
- What is the difference between time complexity and space complexity?
- What is the complexity of binary search?
- What is amortized analysis?
- How do you compare two algorithms with the same Big-O?
- What is the difference between an array and a linked list?
- When would you use a hash map over a tree-based map?
- What is a stack and when do you use it?
- What is a queue and when do you use it?
- What is a priority queue?
- What is the difference between a set and a map?
- What is a trie and when is it useful?
- What is a bloom filter?
- What is LRU cache and how would you implement it?
- What is a binary search tree and its complexity?
- What is a heap and when do you use it?
- What is a graph and how do you represent it?
- What is the difference between DFS and BFS?
- What is Dijkstra's algorithm?
- What is dynamic programming?
- What is the difference between mergesort and quicksort?
- When would you use counting sort?
- What is the sliding window technique?
- What is recursion and its trade-offs?
- What is the two-pointer technique?
- What is the difference between top-down and bottom-up DP?
- What is the difference between divide and conquer and DP?
- How would you find the shortest path in an unweighted graph?
- How would you detect a cycle in a linked list?
- How would you reverse a linked list in place?
- How would you determine whether two strings are anagrams?
- How would you find the kth largest element in an array?
- How would you merge two sorted arrays?
- How would you check if a binary tree is balanced?
- How would you serialize and deserialize a binary tree?
- How would you find the longest substring without repeating characters?
- How would you implement a rate limiter using a token bucket?
- How would you validate a binary search tree?
- How would you design an LRU cache?
- How would you find all anagrams in a string?
- How would you group anagrams from a list of strings?
- How would you find the median of two sorted arrays?
- How would you find the maximum subarray sum?
- How would you implement a trie for autocomplete?

## Languages

*Source:* `languages/`

- What is a type system and why does it matter?
- How does type safety differ across languages?
- How do you decide what language is right for a project?
- What is the GIL in Python and how does it affect concurrency?
- How does Python's memory management work?
- What is the difference between `__init__` and `__new__`?
- What is monkey patching and when is it acceptable?
- What is a decorator in Python?
- What is a context manager?
- What is the difference between a list and a tuple?
- What is the difference between `is` and `==`?
- What is the difference between a generator and an iterator?

## Libraries & Frameworks

*Source:* `libraries-frameworks/`

- How do you evaluate whether a framework is a good fit?
- What framework knowledge matters at senior level?
- When should you avoid framework-specific code?
- Why choose Django over FastAPI for a new project?
- How do you prevent N+1 queries in Django?
- What are the trade-offs of Django signals?
- How does Django's middleware differ from FastAPI's middleware?
- How do you scale a Django application?
- When would you use Django over a micro-framework for a backend?
- What makes FastAPI different from many older Python web frameworks?
- When should a FastAPI endpoint be `async`?
- How should dependencies be used in FastAPI?
- How do you structure a production FastAPI app?
- Explain the request lifecycle in FastAPI.
- What is dependency injection in FastAPI?
- What is the difference between Middleware, Dependency, and Background Tasks?
- How do you validate request data in FastAPI?
- How do you handle exceptions globally in FastAPI?
- How does the request cycle work in FastAPI's ASGI server?
- How are middleware and dependencies ordered in the FastAPI request lifecycle?
- What is the NestJS request lifecycle?
- When would you use a guard vs an interceptor in NestJS?
- How does dependency injection work in NestJS?
- What is the difference between NestJS and Express?
- When would you use Next.js over a plain React SPA?
- What is server-side rendering and how does Next.js implement it?
- What is the difference between getStaticProps and getServerSideProps?
- How does Next.js handle image optimization?
- What is middleware in Next.js?
- What is the React component lifecycle?
- What is the difference between state and props?
- What is the virtual DOM and how does it work?
- What is the difference between controlled and uncontrolled components?
- When would you use useMemo vs useCallback?
- What is the Context API and when would you use it?
- How do you handle forms in React?
- How do you handle authentication in React?
- What is the difference between React class components and functional components?
- How does React handle routing?
- What are custom hooks and when would you create one?
- What is the difference between useEffect and useLayoutEffect?
- How do you test React components?
- What is the difference between React.memo and useMemo?
- How does React handle state management?
- What is the difference between state managers?
- How does Spring Boot auto-configuration work?
- What is the difference between @Component, @Service, @Repository, and @Controller?
- How does dependency injection work in Spring?
- What is AOP in Spring and when would you use it?
- What is Spring Security and how does it integrate?
- What is the difference between @RestController and @Controller?
- How does Spring Boot handle database transactions?
- What is the difference between @RequestMapping and @GetMapping?
- How does Spring Boot handle externalized configuration?
- What is the difference between Spring Boot and Spring MVC?
- When would you use an interface for Spring Data JPA repositories?

## Operating Systems

*Source:* `os/`

- What is the difference between a process and a thread?
- What are file descriptors?
- How do signals affect server processes?
- What is virtual memory?
- When would you choose multiple processes over multiple threads?
- Why can too many threads make a server slower?
- What is a zombie process and why does it matter?
- How do concurrency and parallelism differ in practice?
- What happens during a context switch and why care?
- Why can CPU utilization look low while latency is high?
- What is the difference between preemptive and non-preemptive scheduling?
- What is the difference between a page fault and a segmentation fault?
- What is thrashing and how do you detect it?
- How does memory allocation work in a backend service?
- What is the difference between stack and heap memory?
- How does garbage collection work in Python and Java?
- What is a memory leak and how do you detect it?
- What is the difference between a regular file and a socket?
- How do file descriptors behave with `fork()`?
- What is `mmap` and when would you use it?
- What is the difference between buffered and unbuffered I/O?
- How do disk I/O operations affect backend performance?

## Security

*Source:* `security/`

- What is the difference between a vulnerability, a threat, and a risk?
- What is defense in depth?
- What is the principle of least privilege?
- What is the difference between security by obscurity and real security?
- What is the CIA triad and how does it apply to backend security?
- What is the difference between authentication and authorization?
- How does a password-based authentication flow work?
- What is multi-factor authentication and when should you enforce it?
- What is single sign-on and how does it work?
- How does OAuth 2.0 work for delegated authorization?
- What is OpenID Connect?
- What are the failure modes of role-based access control?
- How does attribute-based access control differ from RBAC?
- When would you use an ACL instead of roles?
- What is the principle of least privilege in authorization?
- What is a session and how does session-based auth work?
- What is a CSRF attack and how do you prevent it?
- What are the security differences between cookie sessions and token auth?
- How do you handle session expiration and renewal?
- What is session fixation and how to prevent it?
- What is a JWT and how does it work?
- What happens if a JWT signing key is leaked?
- How do you handle JWT revocation?
- What is the difference between JWT and opaque tokens?
- What is the difference between encoding, encryption, and hashing?
- How should passwords be stored?
- What is bcrypt and how does it work?
- How do you handle password reset securely?
- What is a pepper and how is it different from a salt?
- What is rate limiting in password authentication?
- What is the difference between authentication and authorization?
- What is the difference between TLS and SSL?
- What is a TLS handshake?
- How do you configure HTTPS on a backend service?
- What is a certificate authority?
- What is mutual TLS?
- What is the difference between symmetric and asymmetric encryption?
- How does a certificate chain work?
- What are the most critical OWASP Top 10 vulnerabilities for backend services?
- What is SQL injection and how do you prevent it?
- What is XSS and how do you prevent it?
- What is CSRF and how do you prevent it?
- What is SSRF and how do you prevent it?
- How do you secure an API from injection attacks?

## Basic / Web Fundamentals

*Source:* `basic/`

- What happens when a backend receives an HTTP request?
- What is the difference between validation and sanitization?
- Why are environment variables used in backend services?
- What makes a backend endpoint production-safe?
- What are the roles of HTML, CSS, and JavaScript?
- What is CORS and why does it occur?
- How does React communicate with a FastAPI backend?
- Why is CORS not a problem for same-origin requests?
- How would you handle authentication in a React + FastAPI SPA?
- What is the difference between server-side rendering and client-side rendering, and when does each matter?
