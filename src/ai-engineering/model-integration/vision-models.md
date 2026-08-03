# Vision Models

Vision models are multimodal models that accept images as input alongside text.
They combine image understanding with language generation.

## Use Cases

- OCR and text extraction from scanned documents.
- Structured data extraction from invoices, forms, and receipts.
- Reading charts, diagrams, and screenshots.
- Image captioning and alt-text generation.
- Verifying or extracting information from product photos.

## Image Inputs

- Images are converted to tokens, so resolution and file size directly drive
  cost and latency.
- Higher resolution preserves detail for small text but costs more tokens.
- PDFs are often converted to images before being passed to the model rather
  than read directly.
- Send only the pages or crops that matter instead of the whole document.

## Validation

- Validate extracted data against business rules before using it.
- Cross-check critical fields like totals, IDs, and dates against the source
  image when possible.
- Low confidence results should route to human review or a deterministic
  fallback.

See [AI APIs](ai-apis.md) for request design, retries, and rate limits.

## Mid/Senior Interview Questions and Answers

### 1. When would you use a vision model instead of a text-only model?

**Answer:** Reach for a vision model when the information is only available in
pixels — OCR, charts, diagrams, screenshots, product photos — and text-only
models cannot see it. Evaluate first whether the task is really visual or
whether a cheaper text pipeline on OCR-extracted text is sufficient. Reserve
vision calls for cases where the image itself carries meaning that text loses.

### 2. How do you budget for image token costs and resolution?

**Answer:** Image tokens scale with resolution and detail, so a high-res
document can cost far more than a thumbnail. Pick the lowest resolution that
preserves the detail you need, crop to the region of interest, and estimate
token cost per image before committing to a pipeline. Cache repeated or
catalog images so the same pixels are not re-tokenized on every request.

### 3. How do you handle PDFs and scanned documents?

**Answer:** Convert PDFs page by page to images rather than dumping the whole
document, and send only the pages that contain relevant content. Rasterize at a
resolution that keeps small text legible, and where possible run OCR or layout
detection first to filter pages. Treat conversion as a separate, testable stage
so it can be cached or swapped independently.

### 4. How do you validate extracted data from documents?

**Answer:** Validate extracted fields against business rules and, for
high-stakes fields like totals, IDs, and dates, cross-check against the source
image. Use confidence scores to route low-confidence results to human review or
a deterministic fallback, and spot-check samples in production rather than
trusting a fixed eval set. Never let unvalidated model output directly mutate
a system of record.

### 5. How do you scale document processing throughput?

**Answer:** Structure the pipeline as queue-based batches with retries,
concurrency limits, and per-document backpressure so a slow model cannot
overwhelm the provider quota. Measure throughput in documents per hour and cost
per document, and store per-page results so a failed page can be retried
without re-processing the whole job. Add end-to-end accuracy monitoring on a
sample of production documents.
