# Data Structures

A **data structure** is a way to organize and store data so that the operations
you need are efficient. Choosing the right one is one of the highest-leverage
decisions in backend code: it determines lookup speed, memory usage, and how
well a service scales. This page covers the core structures, their operation
costs, when to use them, and where they show up in backend systems.

## Arrays

An **array** stores elements in contiguous memory, indexed by position.

| Operation        | Complexity |
|------------------|------------|
| Access by index  | `O(1)`     |
| Search (unsorted)| `O(n)`     |
| Insert/delete end| `O(1)`*    |
| Insert/delete mid| `O(n)`     |

(*Amortized for dynamic arrays that resize.)

**When to use**: index-based access, iteration, fixed or ordered collections,
cache-friendly scans.

**Backend examples**: result rows from a query, batch payloads, fixed lookup
tables, ring buffers for recent events.

## Strings

A **string** is an ordered sequence of characters, often backed by an array of
bytes or code units.

| Operation          | Complexity |
|--------------------|------------|
| Access by index    | `O(1)`     |
| Concatenation      | `O(n + m)` |
| Substring search   | `O(n*m)` naive, `O(n + m)` with KMP |

Strings are usually **immutable**, so building one in a loop with `+` is
`O(n^2)`. Use a string builder or buffer instead.

**When to use**: text, identifiers, serialized payloads, keys.

**Backend examples**: request paths, JSON bodies, tokens, log lines, cache keys.

## Linked Lists

A **linked list** stores elements as nodes, each pointing to the next (and, in a
doubly linked list, the previous).

| Operation              | Complexity |
|------------------------|------------|
| Access by index        | `O(n)`     |
| Insert/delete at known node | `O(1)` |
| Search                 | `O(n)`     |

**When to use**: frequent insertion or deletion when you already hold the node,
or as the backbone of queues, stacks, and LRU caches.

**Backend examples**: the eviction list inside an LRU cache, free lists in
memory allocators, adjacency lists in graphs.

**Trade-off**: poor cache locality and `O(n)` random access make arrays faster
in most real workloads.

## Stacks

A **stack** uses **last in, first out** (`LIFO`) ordering.

| Operation | Complexity |
|-----------|------------|
| Push      | `O(1)`     |
| Pop       | `O(1)`     |
| Peek      | `O(1)`     |

**When to use**: reversing order, tracking nested context, depth-first
traversal.

**Backend examples**: the function call stack, expression and syntax parsing,
undo/redo, DFS over a dependency graph.

## Queues

A **queue** uses **first in, first out** (`FIFO`) ordering.

| Operation | Complexity |
|-----------|------------|
| Enqueue   | `O(1)`     |
| Dequeue   | `O(1)`     |
| Peek      | `O(1)`     |

**When to use**: processing items in arrival order, decoupling producers from
consumers, level-order traversal.

**Backend examples**: background job processing, message brokers, request
buffering, BFS.

### Deque

A **deque** (double-ended queue) allows `O(1)` insertion and removal at both
ends. It can act as a stack or a queue and is the standard structure for the
sliding-window technique.

### Priority Queue

A **priority queue** returns the highest- (or lowest-) priority element first
rather than the oldest. It is usually backed by a **heap**.

| Operation     | Complexity |
|---------------|------------|
| Insert        | `O(log n)` |
| Pop top       | `O(log n)` |
| Peek top      | `O(1)`     |

**Backend examples**: task schedulers, rate limiters, Dijkstra's algorithm,
timeout and retry wheels, merging sorted streams.

## Hash Tables

A **hash table** stores key-value pairs and uses a hash function to map keys to
buckets for fast access.

| Operation | Average | Worst  |
|-----------|---------|--------|
| Insert    | `O(1)`  | `O(n)` |
| Lookup    | `O(1)`  | `O(n)` |
| Delete    | `O(1)`  | `O(n)` |

The worst case occurs when many keys collide into the same bucket. Good hash
functions, load-factor-based resizing, and treeified buckets keep this rare.

**When to use**: fast key lookup, deduplication, grouping, frequency counting,
caching.

**Backend examples**: in-memory caches, session stores, request deduplication,
counting and grouping in aggregation logic.

## Sets

A **set** stores unique elements with no duplicates. It is usually backed by a
hash table (unordered) or a balanced tree (ordered).

| Operation        | Hash set avg | Tree set    |
|------------------|--------------|-------------|
| Add/contains/remove | `O(1)`    | `O(log n)`  |

**When to use**: membership tests, deduplication, set operations (union,
intersection, difference).

**Backend examples**: tracking seen IDs, permission/role checks, feature flags,
allow/deny lists.

## Trees

A **tree** is a hierarchical structure of nodes with parent-child relationships.

### Binary Search Tree (BST)

A **BST** keeps left children smaller and right children larger than the parent,
giving ordered traversal and `O(log n)` operations when balanced.

| Operation | Balanced  | Degenerate |
|-----------|-----------|------------|
| Search    | `O(log n)`| `O(n)`     |
| Insert    | `O(log n)`| `O(n)`     |
| Delete    | `O(log n)`| `O(n)`     |

An unbalanced BST degrades to a linked list, which is why production systems use
self-balancing variants.

### Balanced Trees

**Balanced trees** (AVL, red-black) rebalance on insert and delete to guarantee
`O(log n)`. **B-trees** and **B+ trees** are the wide, disk-friendly variant
used by databases.

**Backend examples**: database and filesystem **indexes** (B-trees), ordered
maps and sets, range queries.

### Heap

A **heap** is a complete binary tree where each parent is ordered relative to its
children (min-heap or max-heap). It is the standard backing for a priority
queue.

| Operation | Complexity |
|-----------|------------|
| Peek top  | `O(1)`     |
| Insert    | `O(log n)` |
| Pop top   | `O(log n)` |

**Backend examples**: schedulers, top-K queries, timeout management.

### Trie

A **trie** (prefix tree) stores strings by shared character prefixes, giving
lookup proportional to key length rather than the number of keys.

| Operation         | Complexity   |
|-------------------|--------------|
| Insert/search key | `O(k)` (k = key length) |

**Backend examples**: autocomplete, prefix-based routing, IP routing tables,
spell checking.

## Graphs

A **graph** is a set of nodes (vertices) connected by edges. Edges can be
directed or undirected, weighted or unweighted.

### Representations

| Representation    | Space      | Edge check | Best for          |
|-------------------|------------|------------|-------------------|
| Adjacency list    | `O(V + E)` | `O(degree)`| Sparse graphs     |
| Adjacency matrix  | `O(V^2)`   | `O(1)`     | Dense graphs      |
| Edge list         | `O(E)`     | `O(E)`     | Simple iteration  |

Most backend graphs are sparse, so **adjacency lists** are the common choice.

**When to use**: anything with relationships and connectivity.

**Backend examples**: social graphs, dependency resolution, recommendation
systems, shortest-path routing, service topology, permission inheritance.

## Choosing a Structure

| Need                          | Use                  |
|-------------------------------|----------------------|
| Fast key lookup               | Hash table           |
| Ordered keys / range queries  | Balanced tree / B-tree |
| Membership / uniqueness       | Set                  |
| Process in arrival order      | Queue                |
| Process by priority           | Priority queue (heap)|
| Prefix matching               | Trie                 |
| Relationships / connectivity  | Graph                |

## Mid/Senior Interview Questions and Answers

### 1. When would you choose a hash table over a balanced tree?

**Answer:** A hash table gives `O(1)` average lookup and is ideal when I only
need key equality: caching, deduplication, and frequency counting. A balanced
tree gives `O(log n)` lookup but keeps keys ordered, which I need for range
queries, ordered iteration, or finding the nearest key. Databases use B-trees
for indexes precisely because they support range scans, which a hash index
cannot.

### 2. Why do databases use B-trees instead of binary search trees for indexes?

**Answer:** A binary search tree has a small branching factor, so it is tall and
each level can be a separate disk read. A B-tree (or B+ tree) is wide, packing
many keys per node, which keeps the tree shallow and minimizes expensive disk
I/O. B+ trees also link leaf nodes for efficient range scans. The structure is
optimized for block-based storage, not just in-memory comparisons.

### 3. How does a hash table stay O(1) as it grows, and when does it fail?

**Answer:** A hash table tracks its load factor (entries per bucket) and resizes,
rehashing into a larger table, when it gets too full. This keeps buckets short so
operations stay amortized `O(1)`. It fails when keys collide heavily, either from
a poor hash function or adversarial input, degrading to `O(n)` per bucket.
Modern implementations randomize the hash seed and treeify large buckets to
limit this.

### 4. When is a linked list actually the right choice in backend code?

**Answer:** Rarely as a primary collection, because arrays have far better cache
locality. It shines when I need `O(1)` insertion and removal at a known node,
such as the recency list inside an LRU cache, free lists in allocators, or
adjacency lists in graphs. If I find myself indexing into a linked list, I have
chosen the wrong structure.

### 5. How would you implement a top-K most frequent items endpoint?

**Answer:** I would count frequencies in a hash map in `O(n)`, then maintain a
min-heap of size K while scanning the counts, which is `O(n log K)` and far
cheaper than fully sorting at `O(n log n)`. The heap holds the K largest seen so
far; anything smaller than its top is discarded. For very large datasets I would
push the counting into the database or a streaming aggregation instead of loading
everything into memory.
