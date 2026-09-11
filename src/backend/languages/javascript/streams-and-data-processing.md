# Streams and Data Processing

Streams process data in chunks. They reduce peak memory and can begin producing
output before an entire file, request, or query result has been loaded.

## Stream Types

Node.js provides four fundamental stream forms:

| Type | Role | Example |
| --- | --- | --- |
| `Readable` | Produces chunks | File or HTTP request body |
| `Writable` | Consumes chunks | File or HTTP response body |
| `Duplex` | Reads and writes independently | TCP socket |
| `Transform` | Converts input chunks to output chunks | Compression or parsing |

Streams can operate on bytes and strings or in **object mode**, where chunks
are ordinary JavaScript values. Object mode changes buffering units but does
not make an unbounded data source safe automatically.

## Backpressure

Backpressure is the mechanism that prevents a fast producer from overwhelming
a slower consumer. When `writable.write(chunk)` returns `false`, the producer
should wait for the `drain` event before writing more.

Using `pipe()` or `pipeline()` coordinates this flow automatically. Ignoring
the signal lets queued chunks grow until the process has severe memory pressure.

## Safe Pipelines

Prefer the promise-based `pipeline()` helper because it propagates errors and
coordinates teardown:

```js
import { createReadStream, createWriteStream } from "node:fs";
import { pipeline } from "node:stream/promises";
import { createGzip } from "node:zlib";

await pipeline(
  createReadStream("events.ndjson"),
  createGzip(),
  createWriteStream("events.ndjson.gz"),
);
```

Manually wiring `data`, `end`, and `error` listeners is easy to get wrong. One
stage can fail while another continues holding a file descriptor or socket.

## Async Iteration

Readable streams support async iteration:

```js
let bytes = 0;

for await (const chunk of request) {
  bytes += chunk.length;
  if (bytes > maximumUploadBytes) {
    throw new PayloadTooLargeError();
  }
  await processChunk(chunk);
}
```

The loop naturally waits between chunks, which makes sequential processing
clear. If chunk processing is made concurrent, add an explicit bound and
preserve ordering when the protocol requires it.

## Buffering and Chunk Boundaries

A chunk boundary is not a message boundary. One JSON object, line, UTF-8
character, or protocol frame may be split across chunks, and one chunk may
contain several records.

Use an incremental parser or retain incomplete data between chunks. Converting
each arbitrary byte chunk to text independently can corrupt a multi-byte
character; use a decoder that preserves incomplete sequences.

## HTTP Bodies and Large Payloads

Request and response bodies are streams, but application frameworks may buffer
them before a handler runs. Configure body-size limits and understand whether
middleware parses the complete payload.

For downloads and proxies:

- stream from the source to the response when possible;
- handle client disconnects and abort upstream work;
- set appropriate content type and length when known;
- avoid buffering only to log or calculate a value;
- never trust a filename or path supplied by a client.

## Streaming Database Results

A database cursor can reduce memory for large result sets, but it may hold a
connection and transaction open for the entire stream. Apply a query timeout,
close the cursor on cancellation, and ensure a slow client cannot occupy scarce
database resources indefinitely.

Pagination or asynchronous export jobs are often safer for very large data
downloads.

## Common Mistakes

- collecting every chunk before processing, which defeats streaming;
- ignoring backpressure from the destination;
- assuming chunks align with lines or application messages;
- missing an error handler or cleanup path;
- leaving a source open after the client disconnects;
- using object mode with an unbounded number of large objects;
- holding a database connection while a slow client downloads data.

Streaming is a resource-lifetime design, not merely a memory optimization.
