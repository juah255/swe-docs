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
