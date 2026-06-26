# CPU Scheduling

The **scheduler** decides which runnable thread gets a CPU core next. On a busy
backend host there are always more threads ready than cores available, so the
scheduler's choices directly shape tail latency and throughput under load.

## The Scheduler's Job

Given a set of **ready** threads and a limited number of cores, the scheduler
picks who runs, for how long, and when to switch. It balances competing goals:

- **Throughput**: total work completed per unit time.
- **Latency / response time**: how quickly a thread starts running.
- **Fairness**: every thread makes reasonable progress.
- **Priority**: important work runs ahead of background work.

These goals conflict — favoring throughput can starve latency-sensitive work, and
strict fairness can hurt high-priority requests.

## Preemptive vs Non-Preemptive

- **Non-preemptive**: a thread runs until it blocks or voluntarily yields. Simple
  but one greedy thread can hog the CPU.
- **Preemptive**: the kernel can interrupt a running thread (typically on a timer
  tick) and switch to another. Modern OSes are preemptive, which keeps one task
  from monopolizing a core and bounds response time.

## Common Algorithms

| Algorithm        | Preemptive | Idea                                  | Strength                | Weakness                          |
| ---------------- | ---------- | ------------------------------------- | ----------------------- | --------------------------------- |
| FCFS             | No         | Run in arrival order                  | Simple, fair by arrival | Convoy effect; long jobs block    |
| SJF              | No         | Run shortest job next                 | Optimal avg wait time   | Needs job length; starves long    |
| SRTF             | Yes        | Preemptive SJF by remaining time      | Great avg wait          | Starvation; needs estimates       |
| Round Robin      | Yes        | Fixed time slice, rotate              | Fair, good response     | Slice tuning; overhead if too small |
| Priority         | Either     | Highest priority first                | Honors importance       | Starvation of low priority        |
| Multilevel Queue | Yes        | Multiple queues by class, each tuned  | Mixes classes well      | Complex; needs tuning             |

- **FCFS** suffers the **convoy effect**: one long job stuck at the front delays
  everyone behind it.
- **Round robin** with time slice `q` gives each thread a turn; small `q`
  improves responsiveness but adds context-switch overhead.
- **Priority** schemes risk **starvation**, fixed with **aging** (slowly raising
  a waiting thread's priority).
- **Multilevel feedback queues** generalize this: threads move between queues
  based on behavior, favoring interactive work over CPU hogs. Linux's CFS is a
  modern fairness-based scheduler in the same spirit.

## Context-Switch Cost

Every scheduling decision that swaps threads incurs a **context switch**: saving
and restoring register state plus indirect cache and TLB penalties. A tiny time
slice maximizes fairness but wastes CPU on switching. The slice is a trade-off
between responsiveness and overhead.

## How This Affects Latency Under Load

- When **runnable threads exceed cores**, requests sit in the run queue before
  executing — visible as rising **run-queue length** and CPU **scheduling
  latency**, even if CPU utilization is not 100%.
- **Oversubscription** (far more threads than cores) inflates tail latency
  because each request waits through more switching.
- **Priority inversion**: a high-priority thread waits on a lock held by a
  low-priority thread that cannot get scheduled. Mitigated by priority
  inheritance.
- In containers, **CPU quotas/throttling** can pause a workload mid-burst,
  producing latency spikes that look like the app stalling.

The practical takeaway: size your worker concurrency to the available cores.
Throwing more threads at a CPU-bound service usually raises latency, not
throughput.

## Mid/Senior Interview Questions and Answers

### 1. Why can CPU utilization look low while latency is high?

**Answer:** Utilization measures time spent executing, not time spent waiting to
be scheduled. If many threads are runnable but cores are busy, requests queue in
the run queue and accrue scheduling latency before they ever run.

Look at run-queue length, load average relative to core count, and scheduler
latency metrics. In containers, also check CPU throttling, which pauses work even
when the host has spare capacity.

### 2. What is the convoy effect and how do you avoid it?

**Answer:** The convoy effect happens under FCFS when a long-running task holds
the CPU and forces many short tasks to wait behind it, inflating their latency.

Preemptive, time-sliced scheduling like round robin or fairness-based schedulers
avoids it by interrupting long tasks. At the application level, separating slow
work into its own pool prevents it from blocking fast requests.

### 3. How do you prevent starvation in a priority scheduler?

**Answer:** Use aging: gradually raise the priority of threads that have waited a
long time so they eventually run regardless of newer high-priority arrivals.
Multilevel feedback queues do this implicitly by promoting waiting threads.

At the system level, reserve capacity for lower-priority classes or cap how much
high-priority work can flood the scheduler.

### 4. How should worker thread count relate to CPU cores?

**Answer:** For CPU-bound work, keep concurrency close to the core count; extra
threads only add context-switch overhead and contention without more parallelism.
For I/O-bound work, more threads (or async I/O) help because threads spend most
time blocked.

The right answer comes from measuring: increase concurrency until throughput
plateaus and latency starts climbing, then back off.

### 5. What is priority inversion and how is it handled?

**Answer:** Priority inversion occurs when a high-priority thread blocks on a
resource held by a low-priority thread that the scheduler keeps preempting, so
the important work stalls indefinitely.

The standard fix is priority inheritance: the lock holder temporarily inherits
the waiter's higher priority so it can finish and release the resource quickly.
