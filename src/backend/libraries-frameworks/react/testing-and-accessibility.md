# Testing and Accessibility

Accessible React is built from correct HTML semantics, keyboard behavior,
readable content, and thoughtful focus management. Tests should exercise those
same user-visible behaviors instead of component internals.

## Start With Semantic HTML

Native elements provide behavior, keyboard support, and accessibility semantics:

- use `<button>` for actions;
- use `<a href>` for navigation;
- associate `<label>` with form controls;
- use headings in a logical hierarchy;
- use lists, tables, landmarks, and dialogs for their intended purpose.

A clickable `<div>` is not automatically a button after adding `onClick`. It
still lacks keyboard activation, focus behavior, and button semantics.

Use ARIA to fill a semantic gap, not to replace a suitable native element.

## Keyboard and Focus

Every interactive workflow should work without a pointer. Test:

- logical tab order;
- visible focus indicators;
- Enter and Space behavior where appropriate;
- Escape and arrow-key behavior for composite widgets;
- focus containment and restoration for modal dialogs;
- focus movement after route changes and critical errors.

Avoid positive `tabIndex` values, which create a separate and fragile tab order.
Use `tabIndex={-1}` for programmatic focus on normally non-tabbable elements.

## Accessible Names and Descriptions

Controls need names that communicate purpose. Prefer visible text and labels.
Use `aria-label` only when no visible label is practical, and use
`aria-labelledby` or `aria-describedby` to connect existing content.

Icon-only buttons need an accessible name. Alternative text for images should
convey the image's purpose; decorative images should be ignored by assistive
technology.

## Dynamic Updates

Visual changes are not always announced. Use status or alert semantics for
important asynchronous feedback, but avoid overly chatty live regions.

Loading indicators should have meaningful text or accessible status. When a
submission fails, keep the entered values, show a summary, associate field
errors, and move focus only when it helps recovery.

## Test User Behavior

Query rendered UI by role, name, label, and visible text:

```tsx
render(<LoginForm onSubmit={submit} />);

await user.type(screen.getByLabelText(/email/i), "reader@example.com");
await user.type(screen.getByLabelText(/password/i), "secret");
await user.click(screen.getByRole("button", { name: /sign in/i }));

expect(submit).toHaveBeenCalledWith({
  email: "reader@example.com",
  password: "secret",
});
```

These queries encourage accessible markup and survive DOM refactoring better
than CSS classes or test IDs. Use a test ID only when no user-facing query fits.

## Test Layers

| Layer | Best use |
| --- | --- |
| Pure unit test | Reducers, formatters, validators, and domain calculations |
| Component test | Rendering, interactions, forms, loading, and error states |
| Integration test | Router, cache, providers, and network adapters together |
| End-to-end test | Critical journeys in a real browser and deployed architecture |
| Visual test | Layout and style regressions across controlled states |

Do not unit-test JSX structure merely to increase coverage. Test the behavior a
user or consuming component can observe.

## Network Tests

Intercept requests at the network boundary rather than mocking the component's
internal hook. Exercise success, validation failure, server error, slow response,
cancellation, and stale response behavior.

A mock should match the real API contract closely. Contract and end-to-end tests
are still needed because a mock cannot reveal schema drift or server behavior.

## Async Assertions

Wait for visible outcomes, not implementation timing. Avoid arbitrary sleeps
and manual wrapping that hides unresolved work.

Close subscriptions and reset external stores between tests. Leaked timers,
listeners, cache entries, or mock handlers create order-dependent failures.

## Strict Mode in Tests

Rendering test applications under Strict Mode can expose impure components and
missing cleanup. Assertions should not depend on an Effect running exactly once
in development.

Test cleanup and idempotency rather than disabling checks to preserve fragile
call counts.

## Automated Accessibility Checks

Automated scanners catch missing labels, invalid ARIA, contrast problems, and
some structural issues. They cannot determine whether focus movement is useful,
alternative text is meaningful, or a workflow makes sense with a screen reader.

Combine automated checks with keyboard testing, browser accessibility-tree
inspection, and manual assistive-technology testing for critical workflows.

## Testing Checklist

- Query UI the way users perceive it.
- Cover loading, empty, error, success, and permission states.
- Verify keyboard and focus behavior.
- Test network cancellation and late responses.
- Keep mocks at real boundaries.
- Run critical flows in the actual rendering architecture.
- Include automated and manual accessibility review.
