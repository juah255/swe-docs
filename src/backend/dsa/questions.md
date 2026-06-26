# DSA Questions

A quick-reference set of common data structures and algorithms questions, with
concise, backend-focused answers.

## What is Big O notation?

**Big O** describes how an algorithm's runtime or memory grows as input size
grows, ignoring constants and lower-order terms. It expresses the worst-case
upper bound and lets you compare approaches independently of hardware.

## What is the difference between time and space complexity?

- **Time complexity**: how the number of operations grows with input size.
- **Space complexity**: how much extra (auxiliary) memory grows with input size.

They often trade off: a hash map can cut time from `O(n^2)` to `O(n)` at the cost
of `O(n)` extra memory.

## What does amortized complexity mean?

**Amortized** complexity is the average cost per operation over a sequence of
operations. Appending to a dynamic array is amortized `O(1)` even though
occasional resizes cost `O(n)`.

## When should you use an array vs. a linked list?

- **Array**: fast index access (`O(1)`), cache-friendly iteration. Most backend
  collections.
- **Linked list**: `O(1)` insert/delete at a known node, but `O(n)` access and
  poor cache locality.

Prefer arrays unless you specifically need cheap node-level insertion, as in an
LRU eviction list.

## When should you use a hash table vs. a tree?

- **Hash table**: `O(1)` average lookup by key, no ordering. Best for caching,
  deduplication, and counting.
- **Balanced tree / B-tree**: `O(log n)` lookup with ordered keys and range
  queries. Best for indexes and ordered iteration.

## How does a hash map work internally?

A hash map applies a **hash function** to each key to pick a **bucket**.
Collisions (different keys landing in the same bucket) are handled by chaining
(a list or tree per bucket) or open addressing. As entries grow past a **load
factor**, the table **resizes** and rehashes to keep buckets short, preserving
amortized `O(1)` operations.

## Why can a hash map degrade to O(n)?

When many keys collide into the same bucket, lookups scan a long chain. This
happens with a poor hash function or adversarial keys (hash flooding). Mitigations
include randomized hash seeds and treeifying large buckets into balanced trees.

## What is a stable sort and when does it matter?

A **stable sort** preserves the relative order of elements that compare equal.
It matters for multi-key sorting (sort by date, keep original order for ties) and
for deterministic, repeatable paginated output. Merge sort is stable; quicksort
and heapsort are not.

## What is the difference between recursion and iteration?

Both repeat work, but **recursion** uses the call stack (one frame per call,
risking stack overflow on deep input) while **iteration** uses a loop with
constant stack space. Recursion is cleaner for tree and divide-and-conquer
problems; iteration is safer when depth is large or unbounded.

## When should you use BFS vs. DFS?

- **BFS**: shortest path in unweighted graphs, level-by-level processing. Uses a
  queue.
- **DFS**: reachability, cycle detection, topological sort. Uses recursion or a
  stack.

Both run in `O(V + E)`.

## What is the difference between dynamic programming and greedy?

- **Greedy** makes the locally optimal choice at each step; correct only when the
  problem has the greedy-choice property.
- **Dynamic programming** caches results of overlapping subproblems to consider
  combinations; needed when choices interact.

Try greedy first, but verify with a counterexample before trusting it.

## What is the difference between a stack and a queue?

- **Stack**: last in, first out (`LIFO`). Used for call stacks, parsing, DFS,
  undo.
- **Queue**: first in, first out (`FIFO`). Used for job processing, message
  brokers, BFS.

## What is a heap used for?

A **heap** is a tree that keeps the minimum or maximum at the root, giving
`O(log n)` insert and extract and `O(1)` peek. It backs **priority queues** used
in schedulers, top-K queries, and shortest-path algorithms.

## What is a trie and when is it useful?

A **trie** (prefix tree) stores strings by shared prefixes, giving lookup
proportional to key length rather than the number of keys. It powers
autocomplete, prefix routing, and IP routing tables.

## How are graphs represented?

- **Adjacency list**: `O(V + E)` space, best for sparse graphs (most common).
- **Adjacency matrix**: `O(V^2)` space, `O(1)` edge checks, best for dense
  graphs.
- **Edge list**: simple list of edges, good for iteration.

## Where does DSA show up in backend systems?

Hash maps power caches and lookup tables, queues power background jobs and
brokers, heaps power schedulers, trees (B-trees) power database indexes, graphs
model dependencies and recommendations, and sliding windows power rate limiters.

## Mid/Senior Interview Questions and Answers

### 1. How do you choose a data structure under real backend constraints?

**Answer:** I start from the operations that dominate the workload: lookup
pattern, insertion rate, ordering needs, and memory budget. Frequent key lookups
point to a hash map; range queries point to a B-tree; priority ordering points to
a heap. Then I weigh the worst case, not just the average, because production
sees adversarial and skewed inputs that test fixtures never do.

### 2. A query is slow at scale. How does DSA thinking help you diagnose it?

**Answer:** I look for accidental quadratic behavior and missing indexes. A nested
loop over a growing collection is `O(n^2)` and invisible in tests; an unindexed
database lookup is an `O(n)` table scan that a B-tree index turns into
`O(log n)`. I confirm with the query plan and profiling, then fix the dominant
term rather than micro-optimizing constants.

### 3. How would you design an in-memory LRU cache, and what structures back it?

**Answer:** I combine a hash map for `O(1)` key lookup with a doubly linked list
for `O(1)` recency updates. The map points to list nodes; on access I move the
node to the front, and on eviction I drop the tail. This gives `O(1)` get and put.
At scale I bound capacity and add metrics, and for shared state across instances
I move to Redis with an eviction policy.

### 4. When does recursion become a liability in production code?

**Answer:** Recursion is a liability when input depth is unbounded or
attacker-controlled, because each frame consumes stack and deep recursion crashes
the process. Parsing untrusted nested JSON or traversing deep trees are classic
cases. I convert to iteration with an explicit stack, or cap depth, so a deeply
nested payload cannot trigger a stack overflow.

### 5. How do you explain a complexity trade-off to a non-specialist stakeholder?

**Answer:** I frame it in concrete terms: this approach is instant at 100 records
but takes minutes at a million, while the alternative stays fast but uses more
memory and is harder to maintain. I tie the choice to product impact, latency,
cost, and reliability, rather than notation. The goal is a decision the team can
revisit with data, not a math lecture.
