# Data Structures and Algorithms

Data Structures and Algorithms (`DSA`) are the foundation for writing efficient
programs. In backend engineering, DSA helps with query processing, caching,
scheduling, search, routing, memory usage, and system design trade-offs.

## Core Ideas

- **Data structure**: a way to organize and store data.
- **Algorithm**: a step-by-step process for solving a problem.
- **Time complexity**: how runtime grows as input size grows.
- **Space complexity**: how memory usage grows as input size grows.

## Big O Complexity

Big O describes the growth rate of an algorithm.

| Complexity | Meaning              | Example                         |
|------------|----------------------|---------------------------------|
| `O(1)`     | Constant time        | Accessing an array by index     |
| `O(log n)` | Logarithmic time     | Binary search                   |
| `O(n)`     | Linear time          | Scanning a list                 |
| `O(n log n)` | Linearithmic time  | Efficient sorting               |
| `O(n^2)`   | Quadratic time       | Nested loop over the same list  |

## Common Data Structures

### Array

Stores elements in contiguous positions.

Good for:

- index-based access;
- iteration;
- fixed or ordered collections.

Trade-off:

- inserting or deleting in the middle can be expensive.

### Linked List

Stores elements as nodes connected by pointers.

Good for:

- frequent insertion or deletion when the node is known;
- implementing queues or stacks.

Trade-off:

- random access is slow because nodes must be traversed.

### Stack

Uses **last in, first out** (`LIFO`) ordering.

Common uses:

- function call stack;
- browser back button history;
- undo and redo operations;
- parsing;
- depth-first search.

### Queue

Uses **first in, first out** (`FIFO`) ordering.

Common uses:

- support ticket handling;
- background job processing;
- request processing;
- breadth-first search;
- message handling.

### Hash Table

Stores key-value pairs with fast lookup by key.

Common uses:

- maps and dictionaries;
- caching;
- counting frequency;
- checking duplicates.

Average lookup, insert, and delete are usually `O(1)`, but poor hashing or many
collisions can degrade performance.

### Tree

A hierarchical structure with parent-child relationships.

Common types:

- binary tree;
- binary search tree;
- balanced tree;
- heap;
- trie.

Backend examples:

- indexes;
- file systems;
- routing trees;
- priority queues.

### Graph

A set of nodes connected by edges.

Common uses:

- social networks;
- dependency resolution;
- recommendation systems;
- shortest path problems;
- service topology.

## Common Algorithms

- **Searching**: linear search, binary search.
- **Sorting**: merge sort, quicksort, heapsort.
- **Two pointers**: useful for arrays and strings.
- **Sliding window**: useful for subarray and substring problems.
- **Recursion**: solves problems by breaking them into smaller versions.
- **Backtracking**: explores possible solutions and rejects invalid paths.
- **Breadth-first search** (`BFS`): explores level by level.
- **Depth-first search** (`DFS`): explores as deep as possible first.
- **Dynamic programming** (`DP`): stores results of overlapping subproblems.
- **Greedy algorithms**: make the best local choice at each step.

## Backend Relevance

DSA appears in backend systems more often than it may seem.

Examples:

- Hash maps are used in caches and lookup tables.
- Queues are used in background jobs and message brokers.
- Heaps are used in priority queues and schedulers.
- Trees are used in database indexes and routing.
- Graphs model dependencies, recommendations, and networks.
- Sliding windows are used in rate limiters.
- Sorting and pagination affect API performance.

## Problem-Solving Pattern

When solving a DSA problem:

1. Understand the input and output.
2. Check constraints and edge cases.
3. Start with a simple correct solution.
4. Analyze time and space complexity.
5. Improve the bottleneck if needed.
6. Test with small, large, and edge-case inputs.

## Common Pitfalls

- Optimizing before understanding the problem.
- Ignoring input constraints.
- Forgetting empty input or single-element cases.
- Using nested loops where a hash map would work better.
- Choosing recursion without considering stack depth.
- Knowing the data structure but not its trade-offs.

## Summary

DSA is not only for interviews. It helps backend engineers choose efficient
storage, caching, indexing, queueing, search, and scheduling strategies. The
goal is not to memorize every algorithm, but to understand the trade-offs well
enough to choose the right tool for the problem.

## Mid/Senior Interview Questions and Answers

### 1. How do you explain Big O in backend terms?

**Answer:** Big O describes how runtime or memory grows as input size grows. In
backend systems, this affects endpoint latency, batch job duration, memory
usage, database query cost, and cache behavior.

An `O(n^2)` operation may pass tests with 100 records and fail badly with
100,000 records.

### 2. When would you use a hash map?

**Answer:** Use a hash map for fast key-based lookup, deduplication, grouping,
frequency counting, and cache-like access.

The average case is usually `O(1)`, but memory usage, hash quality, and key
design still matter.

### 3. Why are queues important in backend systems?

**Answer:** Queues decouple producers from consumers, smooth traffic spikes, and
move slow work off the synchronous request path.

Senior design must handle retries, dead-letter queues, idempotency, ordering,
visibility timeouts, and backpressure.

### 4. Where do trees and graphs appear in real systems?

**Answer:** Trees appear in indexes, filesystems, routing, DOM structures, and
priority queues. Graphs appear in social networks, recommendations, dependency
resolution, fraud detection, and service topology.

Knowing traversal trade-offs helps with search, authorization inheritance, and
dependency analysis.

### 5. How do you approach an algorithm problem in an interview?

**Answer:** Clarify inputs and constraints, start with a correct simple
solution, analyze complexity, identify the bottleneck, improve the data
structure or algorithm, and test edge cases.

Explain trade-offs as you go. Senior interviews care about reasoning, not only
the final code.
