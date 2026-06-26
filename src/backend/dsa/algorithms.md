# Algorithms

An **algorithm** is a step-by-step process for solving a problem. The goal in
backend engineering is rarely to invent new algorithms, but to recognize which
known approach fits a problem and to understand its cost. This page covers
searching, sorting, and the common problem-solving techniques, with notes on
where each shows up in backend systems.

## Searching

### Linear Search

**Linear search** scans every element until it finds the target.

| Case  | Complexity |
|-------|------------|
| Best  | `O(1)`     |
| Worst | `O(n)`     |

Works on any collection, sorted or not. It is the fallback when data is small or
unsorted.

### Binary Search

**Binary search** repeatedly halves a **sorted** range, comparing against the
middle element.

| Case  | Complexity |
|-------|------------|
| All   | `O(log n)` |

```text
Find 7 in [1, 3, 5, 7, 9, 11]
  mid = 5 -> 7 > 5, search right half
  mid = 9 -> 7 < 9, search left half
  mid = 7 -> found
```

Binary search requires sorted, randomly accessible data. The same halving idea
powers database index lookups and `O(log n)` operations on balanced trees.

## Sorting

Efficient general-purpose sorts run in `O(n log n)`. Knowing their trade-offs,
especially stability and memory, is more important than memorizing the code.

### Merge Sort

Divides the array in half, sorts each half recursively, then merges. Always
`O(n log n)`, **stable**, but needs `O(n)` extra space. The merge step is the
basis of external sorting for data too large to fit in memory.

### Quicksort

Partitions around a pivot, then sorts each side. Average `O(n log n)`, in-place,
and usually the fastest in practice due to cache locality. Worst case is `O(n^2)`
on bad pivots, mitigated by randomized or median-of-three pivot selection. It is
**not stable**.

### Heapsort

Builds a heap, then repeatedly extracts the max. Guaranteed `O(n log n)` and
in-place, but poor cache behavior makes it slower than quicksort in practice. It
is **not stable**.

### Comparison Table

| Algorithm  | Best        | Average     | Worst       | Space     | Stable |
|------------|-------------|-------------|-------------|-----------|--------|
| Merge sort | `O(n log n)`| `O(n log n)`| `O(n log n)`| `O(n)`    | Yes    |
| Quicksort  | `O(n log n)`| `O(n log n)`| `O(n^2)`    | `O(log n)`| No     |
| Heapsort   | `O(n log n)`| `O(n log n)`| `O(n log n)`| `O(1)`    | No     |

**Stability** matters in backend code: when sorting records by one field while
preserving an existing order on another (for example, sort by date, keeping the
original ID order for ties), a stable sort is required.

## Problem-Solving Techniques

### Two Pointers

Use two indices moving through a structure, often from both ends or at different
speeds. Turns many `O(n^2)` scans into `O(n)`.

```text
Pair summing to a target in a sorted array:
  move left/right inward based on the current sum
```

**Backend relevance**: merging sorted result sets, deduplication, comparing two
ordered streams.

### Sliding Window

Maintain a moving range over a sequence, expanding and shrinking to satisfy a
constraint. Avoids recomputing overlapping work.

```text
Longest substring without repeats:
  grow the window; shrink from the left when a duplicate appears
```

**Backend relevance**: rate limiters (requests per time window), moving averages,
log and metrics aggregation.

### Recursion

A function solves a problem by calling itself on smaller inputs until a base
case. Clean for tree and divide-and-conquer problems, but each call adds
stack-frame space, so deep recursion risks stack overflow. Convert to iteration
or an explicit stack when depth is unbounded.

**Backend relevance**: traversing nested JSON, directory trees, comment threads.

### Backtracking

Explore candidate solutions incrementally and abandon a path as soon as it
cannot lead to a valid result. Often exponential in the worst case, so prune
aggressively.

**Backend relevance**: constraint solving, permission/rule combinations,
configuration generation.

### Breadth-First Search (BFS)

Explore a graph level by level using a queue. Finds the **shortest path** in
unweighted graphs. Time `O(V + E)`, space `O(V)`.

**Backend relevance**: shortest social connection, dependency level ordering,
crawling by distance.

### Depth-First Search (DFS)

Explore as deep as possible before backtracking, using recursion or a stack.
Time `O(V + E)`.

**Backend relevance**: cycle detection, topological sort, reachability,
dependency resolution.

### Dynamic Programming (DP)

Break a problem into overlapping subproblems and cache their results
(memoization, or bottom-up tabulation). Turns exponential brute force into
polynomial time.

```text
Fibonacci:
  naive recursion -> O(2^n)
  with memoization -> O(n)
```

**Backend relevance**: cost/pricing optimization, diff algorithms, edit
distance, sequence alignment, resource allocation.

### Greedy

Make the locally optimal choice at each step, hoping it leads to a global
optimum. Fast and simple, but only correct when the problem has the
greedy-choice property; otherwise it gives a wrong answer.

**Backend relevance**: scheduling, interval selection, Huffman coding, caching
eviction heuristics.

## Backend Relevance Summary

| Technique        | Shows up in                          |
|------------------|--------------------------------------|
| Binary search    | Index lookups, balanced trees        |
| Sorting          | Pagination, ranking, report output   |
| Two pointers     | Merging streams, deduplication       |
| Sliding window   | Rate limiting, moving aggregates     |
| BFS              | Shortest path, level ordering        |
| DFS              | Cycle detection, topological sort    |
| DP               | Optimization, diffing, alignment     |
| Greedy           | Scheduling, eviction, interval logic |

## Mid/Senior Interview Questions and Answers

### 1. When does quicksort lose to merge sort, and how do you handle it?

**Answer:** Quicksort is usually faster due to in-place partitioning and good
cache locality, but it degrades to `O(n^2)` when pivots are consistently poor,
such as on already-sorted input with a naive first-element pivot. I mitigate this
with randomized or median-of-three pivots. I prefer merge sort when I need
guaranteed `O(n log n)`, stability, or external sorting of data that does not fit
in memory, since merge sort streams naturally.

### 2. Why does sort stability matter in backend systems?

**Answer:** Stability preserves the relative order of records that compare equal.
This matters for multi-key sorting: if I sort orders by amount and want ties
broken by their existing chronological order, a stable sort keeps that order
without an extra comparison. It also makes paginated and cached results
deterministic, avoiding rows jumping around between requests when sort keys tie.

### 3. How do you decide between dynamic programming and a greedy approach?

**Answer:** Greedy works only when locally optimal choices lead to a global
optimum, the greedy-choice property, and it is faster and simpler when it
applies, like interval scheduling. Dynamic programming is needed when choices
interact and you must consider combinations, like the knapsack problem. My rule:
try greedy, but verify with a counterexample; if I can construct one, I fall back
to DP over the overlapping subproblems.

### 4. When would you reach for BFS versus DFS?

**Answer:** I use BFS when I need the shortest path in an unweighted graph or to
process nodes by distance, since it explores level by level. I use DFS for
reachability, cycle detection, and topological sorting, where exploring a full
path before backtracking is natural. DFS is also lighter on memory for deep,
narrow graphs, while BFS can hold an entire wide level in its queue.

### 5. How do you apply the sliding-window technique to a rate limiter?

**Answer:** A sliding-window rate limiter counts requests within a moving time
window rather than fixed buckets, which avoids the burst problem at bucket
boundaries. I keep timestamps (or a windowed counter) per client and drop
entries older than the window as new requests arrive, giving amortized `O(1)`
per request. For scale I approximate with a sliding-window-counter algorithm in
Redis to bound memory while keeping the smoothing behavior.
