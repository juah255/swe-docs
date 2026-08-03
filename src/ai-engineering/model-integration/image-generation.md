# Image Generation

Image generation models produce images from a text prompt. The API surface
differs from chat: outputs are files or URLs, and generation is often slow and
expensive.

## Prompts for Images

- Describe subject, composition, style, and mood explicitly.
- State what to exclude as well as what to include.
- Negative prompts or excluded terms help when the model supports them.
- Seed parameters give reproducibility for testing and iteration.

## Outputs

- Specify output size, format, and quality up front.
- Some providers return a URL that expires; download and store what you need.
- Async generation or streaming works better than synchronous calls for long
  generations.
- Verify the generated image before use where the content is load-bearing.

## Operational Concerns

- Safety and moderation filters can reject or alter output; handle refusals as
  a first-class result.
- Content ownership and licensing vary by provider and plan. Confirm what you
  may do with generated images, especially for commercial use.
- Rate limits and cost are per image, so batch and cache aggressively.

See [AI APIs](ai-apis.md) for request design, retries, and rate limits.

## Mid/Senior Interview Questions and Answers

### 1. How do you write image prompts that produce predictable results?

**Answer:** Make prompts explicit about subject, composition, style, and mood,
and state exclusions as clearly as inclusions, since the model fills any
ambiguity on its own. Use seed parameters for reproducibility, iterate on a
small prompt-to-result eval set, and lock prompt versions like code. Measure
prompt quality by the distribution of outputs, not one lucky image.

### 2. How do you handle slow or asynchronous generation?

**Answer:** Treat generation as async work: submit the request, poll or stream
the status, and surface progress to the user rather than blocking a request
thread for the whole generation. Add idempotency keys so a retry cannot spawn
duplicate generations, and cache completed results keyed by prompt plus
parameters so identical requests are free.

### 3. How do you manage output formats and storage?

**Answer:** Decide the output contract up front — format, size, quality —
because re-generating later is expensive. Download provider URLs immediately
since they can expire, store images in your own object store, and keep a record
of prompt, model, and parameters alongside the artifact so you can debug and
reproduce. Generate at the smallest acceptable size and upscale separately.

### 4. How do you handle moderation and safety refusals?

**Answer:** Treat moderation and safety refusals as first-class outcomes, not
failures: surface a clear message to the user and route flagged prompts to
review instead of silently substituting output. Apply your own input filter as
a first gate but do not rely on it alone — check the result for policy
adherence, and log flags so thresholds can be tuned against real traffic.

### 5. How do you reason about ownership and licensing of generated images?

**Answer:** Read the provider's terms for training rights, usage, and
commercial redistribution before building a feature on generated images —
ownership varies by plan and by provider. Assume you have rights only to what
the contract grants, and document provenance for anything derivative. Keep the
prompt and model version with each image so you can prove or defend
provenance later.
