# Memory and Data Representation

Go passes values by value. Understanding what a value contains—inline data, a
pointer, or a small descriptor referencing shared storage—explains most
surprises involving mutation, allocation, and concurrency.

## Values and Pointers

Assignment copies a value:

```go
original := User{Name: "Ann"}
copyOfUser := original
copyOfUser.Name = "Lisa"

fmt.Println(original.Name) // Ann
```

A pointer copies an address, so dereferencing either pointer reaches the same
value. Use pointers when mutation, identity, optional presence, or avoiding a
large copy is part of the contract—not automatically for every struct.

Go does not support pointer arithmetic in ordinary safe code.

## Arrays and Slices

An array's length is part of its type and an array value contains its elements.
A slice is a descriptor with a pointer to an underlying array, a length, and a
capacity.

```go
base := []string{"a", "b", "c", "d"}
window := base[1:3]
window[0] = "changed"

fmt.Println(base[1]) // changed
```

Two slices can share storage. `append` reuses the existing array when capacity
allows and allocates a new array otherwise, so whether later writes are shared
can depend on capacity.

Use `copy` or an explicit append into fresh storage when independent ownership
is required:

```go
owned := append([]string(nil), source...)
```

## Slice Retention

A short slice can keep a large underlying array reachable. Copy the needed
segment when a small result will live much longer than the large source.

Preallocate capacity when the approximate final size is known:

```go
results := make([]Result, 0, len(inputs))
```

Preallocation reduces growth allocations but can waste memory if the estimate
is much larger than reality.

## Nil and Empty Slices

Both nil and empty slices have length zero and can be appended to:

```go
var nilItems []string
emptyItems := []string{}
```

They can encode differently in formats such as JSON. Decide whether an API
contract distinguishes `null` from `[]` and normalize at the boundary.

## Maps

A map value refers to runtime-managed map data. Reading from a nil map returns
the element zero value; writing to a nil map panics.

```go
counts := make(map[string]int)
counts["active"]++
```

Map iteration order is unspecified. Sort keys when deterministic output or tests
require ordering.

Ordinary maps are not safe for unsynchronized concurrent reads and writes. Use
a mutex, transfer ownership to one goroutine, or choose a specialized concurrent
structure when its access pattern fits.

## Strings, Bytes, and Runes

A string is an immutable sequence of bytes and may contain UTF-8 text. `len(s)`
returns bytes, not Unicode characters.

```go
for index, r := range text {
    fmt.Printf("byte offset=%d rune=%q\n", index, r)
}
```

`range` over a string decodes UTF-8 and yields byte offsets and runes. A rune is
a Unicode code point, which is not always the same as one user-perceived
character.

Conversions between `string` and `[]byte` generally copy data. Avoid repeated
conversion in measured hot paths, but prioritize clear boundary types first.

## Escape Analysis

The compiler decides whether storage can remain on a goroutine stack or must be
allocated where it can outlive the stack frame. A value may escape when its
address is returned, it is captured by a closure, or it is passed through code
the compiler cannot fully analyze.

Escape behavior is a compiler decision, not a language guarantee. Inspect build
diagnostics and profiles instead of guessing. Returning a pointer can still be
the correct and clearest API.

## Garbage Collection

The runtime reclaims heap objects that are no longer reachable. Garbage
collection consumes CPU and can affect latency, but reducing allocations is
useful only when measurements show meaningful pressure.

Common retention problems include:

- unbounded maps and caches;
- goroutines blocked forever while holding references;
- short slices retaining large arrays;
- queues whose producers outpace consumers;
- timers, callbacks, or global registries that retain state.

Forcing collection does not fix reachable data.

## `sync.Pool`

`sync.Pool` can reduce temporary allocation for frequently reused objects, but
items may disappear at any time and the pool is not a general cache. Pooling can
increase retained memory, complicate ownership, and preserve sensitive bytes.

Use it only after profiling, reset objects completely before reuse, and never
rely on it for correctness.

## Memory Rules

- Know when copied values still reference shared storage.
- Copy slices or maps at ownership boundaries when mutation must be isolated.
- Do not depend on map iteration order.
- Distinguish bytes, code points, and user-perceived characters.
- Profile allocation and retention before adding pools or low-level tricks.
