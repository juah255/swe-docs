# Complexity Analysis

**Complexity analysis** describes how an algorithm's resource usage grows as the
input size grows. It lets you compare solutions independently of hardware,
language, or load, and it predicts how code will behave when data scales from a
few rows to millions.

## Asymptotic Notation

Asymptotic notation describes growth rate as input size `n` approaches infinity,
ignoring constant factors and lower-order terms.

- **Big O** (`O`): upper bound. The worst-case growth rate. Most commonly used.
- **Big Omega** (`Ω`): lower bound. The best-case growth rate.
- **Big Theta** (`Θ`): tight bound. Used when upper and lower bounds match.

Example:

```text
Linear search:
  Best case  -> Ω(1)      element found first
  Worst case -> O(n)      element found last or missing
  Tight      -> Θ(n)      describes the dominant behavior
```

In practice, engineers say "Big O" but usually mean the dominant term, the same
idea Big Theta captures.

## Time vs. Space Complexity

- **Time complexity**: how the number of operations grows with input size.
- **Space complexity**: how much extra memory grows with input size.

These often trade off against each other. A hash map can turn an `O(n^2)` scan
into `O(n)` time, but it costs `O(n)` extra memory.

```text
Two-sum with nested loops -> O(n^2) time, O(1) space
Two-sum with a hash map   -> O(n)   time, O(n) space
```

Space complexity counts **auxiliary space** (extra memory the algorithm
allocates), not the input itself. Recursion adds call-stack space equal to its
depth.

## Best, Average, and Worst Case

| Case    | Meaning                          | Example                       |
|---------|----------------------------------|-------------------------------|
| Best    | Most favorable input             | Quicksort with balanced pivots|
| Average | Expected over typical inputs     | Hash lookup with good hashing |
| Worst   | Most expensive input             | Quicksort on sorted data      |

Backend systems should usually be designed around the **worst case** or a
realistic **average case**. Adversarial inputs (for example, crafted keys that
all collide in a hash table) can push average-case structures into their worst
case, which is a real denial-of-service concern.

## Amortized Analysis

**Amortized analysis** averages the cost of an operation over a sequence of
operations. A single operation may be expensive, but the cost spread across many
operations is small.

Classic example: appending to a **dynamic array**.

```text
Most appends      -> O(1)
Occasional resize -> O(n)  (copy all elements to a larger buffer)
Amortized cost    -> O(1)  per append over many appends
```

Amortized `O(1)` is not the same as worst-case `O(1)`. A latency-sensitive
endpoint can still see an occasional spike when the expensive operation fires,
which matters for tail latency (p99).

## Big O Reference Table

| Complexity   | Name         | Example                              |
|--------------|--------------|--------------------------------------|
| `O(1)`       | Constant     | Hash lookup, array index access      |
| `O(log n)`   | Logarithmic  | Binary search, balanced tree lookup  |
| `O(n)`       | Linear       | Scanning a list, single loop         |
| `O(n log n)` | Linearithmic | Merge sort, heapsort, quicksort avg  |
| `O(n^2)`     | Quadratic    | Nested loops over the same input     |
| `O(2^n)`     | Exponential  | Naive recursive subset generation    |

Growth comparison for `n = 1,000,000`:

```text
O(1)        -> 1
O(log n)    -> ~20
O(n)        -> 1,000,000
O(n log n)  -> ~20,000,000
O(n^2)      -> 1,000,000,000,000   (a trillion)
O(2^n)      -> effectively never finishes
```

## How Complexity Affects Backend Systems

Complexity is not academic. It directly drives **latency** and **throughput**.

- **Latency**: a per-request `O(n^2)` loop over a growing collection slowly
  raises response time until the endpoint times out under real data.
- **Throughput**: cheaper per-request work means each server handles more
  requests per second before saturating CPU.
- **Database cost**: an unindexed query is `O(n)` per lookup; a B-tree index
  makes it `O(log n)`. At scale this is the difference between a full table scan
  and a fast seek.
- **Memory pressure**: an `O(n)` in-memory cache of unbounded input can exhaust
  heap and trigger garbage-collection pauses or out-of-memory kills.
- **Tail latency**: amortized and average-case structures can produce
  occasional `O(n)` spikes that show up as bad p99 latency even when the mean
  looks fine.

A common backend trap: code passes tests with 100 rows (`O(n^2)` is invisible)
and collapses in production at 100,000 rows.

## Mid/Senior Interview Questions and Answers

### 1. What is the difference between Big O, Big Theta, and Big Omega?

**Answer:** Big O is an upper bound (worst-case growth), Big Omega is a lower
bound (best-case growth), and Big Theta is a tight bound used when the upper and
lower bounds match. Engineers usually say Big O but mean the dominant term,
which is really Big Theta. The distinction matters when an algorithm has very
different best and worst cases, such as quicksort.

### 2. What does amortized O(1) mean, and why might it still hurt latency?

**Answer:** Amortized `O(1)` means the average cost per operation over a long
sequence is constant, even though individual operations can be expensive. A
dynamic array append is amortized `O(1)` because occasional `O(n)` resizes are
rare. It can still hurt tail latency because a single request can hit the
expensive resize, producing a p99 spike even when the mean stays low.

### 3. How do you reason about space versus time trade-offs in backend code?

**Answer:** Most optimizations trade memory for speed. Adding a hash index or
cache turns repeated `O(n)` scans into `O(1)` lookups at the cost of `O(n)`
memory. The decision depends on data size, request rate, and memory budget.
Unbounded caches risk out-of-memory failures and GC pauses, so I bound them with
eviction policies and measure both latency and memory under realistic load.

### 4. Why can an algorithm with good average-case complexity be a security risk?

**Answer:** Structures like hash tables are `O(1)` on average but `O(n)` in the
worst case. An attacker who knows the hash function can craft keys that all
collide, degrading lookups to linear time and causing a hash-flooding denial of
service. Mitigations include randomized hash seeds, treeified buckets for
collisions, and input limits at the boundary.

### 5. How do you estimate whether an algorithm will scale before deploying?

**Answer:** I identify the dominant operation and how it grows with the realistic
input size, then project from that. If an endpoint is `O(n^2)` over a collection
that grows with users, I extrapolate from current data volume to the expected
peak. I also load-test with production-scale data, because test fixtures are
usually too small to reveal quadratic behavior.
