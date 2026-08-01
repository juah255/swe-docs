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
