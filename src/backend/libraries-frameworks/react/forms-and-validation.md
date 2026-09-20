# Forms and Validation

Forms combine browser behavior, local interaction, server validation, and
accessibility. Use native form semantics first, then add React state only where
the user experience requires it.

## Controlled Inputs

A controlled field receives its value from state and updates that state on
input:

```tsx
function SearchBox() {
  const [query, setQuery] = useState("");

  return (
    <label>
      Search
      <input
        name="query"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
      />
    </label>
  );
}
```

Controlled fields are useful for immediate formatting, dependent UI, character
counts, and validation. Keep their state local so typing does not rerender an
unrelated large page.

An input should not switch between controlled and uncontrolled behavior. For a
controlled text input, initialize with an empty string rather than `undefined`.

## Uncontrolled Inputs

An uncontrolled field lets the DOM hold the current value. Read it through
`FormData` on submission:

```tsx
function SearchForm() {
  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const query = String(data.get("query") ?? "");
    search(query);
  }

  return (
    <form onSubmit={handleSubmit}>
      <label htmlFor="query">Search</label>
      <input id="query" name="query" defaultValue="" />
      <button type="submit">Search</button>
    </form>
  );
}
```

Uncontrolled fields reduce render work in large forms and work naturally with
native and framework Action APIs.

## Labels and Instructions

Every control needs an accessible name, normally from a visible `<label>`.
Placeholder text is not a label and disappears during input.

Connect instructions and errors with `aria-describedby`. Mark invalid fields
with `aria-invalid`, but do not set it before validation has actually failed.

```tsx
<label htmlFor="email">Email address</label>
<input
  id="email"
  name="email"
  type="email"
  aria-invalid={Boolean(errors.email)}
  aria-describedby={errors.email ? "email-error" : "email-help"}
/>
<p id="email-help">We use this for account notifications.</p>
{errors.email && <p id="email-error">{errors.email}</p>}
```

## Validation Layers

- **Browser validation** provides fast, native constraints and mobile keyboard
  hints.
- **Client validation** improves feedback and handles rich cross-field rules.
- **Server validation** is authoritative because clients can bypass JavaScript.
- **Database constraints** protect invariants across every writer.

Keep client and server rules aligned through shared schemas or contract tests
where practical, but never skip server enforcement.

## Submission State

During submission:

- prevent accidental duplicates or make the operation idempotent;
- keep pending text and controls understandable;
- preserve user input after a validation failure;
- move focus to an error summary or the first invalid field when helpful;
- announce asynchronous errors through an appropriate live region;
- distinguish validation failures from service outages.

Do not disable every control if users need to review or copy their input.

## Form Actions

React-aware form Actions can manage pending state and reset uncontrolled fields
after successful submission. `useFormStatus` lets a descendant submit button
read the surrounding form's status without threading a prop through the tree.

Framework Server Functions can support progressive enhancement, but the server
must still validate identity, authorization, input, and CSRF protections
appropriate to its authentication model.

## File Inputs

File inputs are uncontrolled. Validate file count, type, and size on the client
for feedback and again on the server for security.

Do not read a large file fully into memory merely to preview or upload it. Use
object URLs carefully, revoke them after use, and use a streaming or direct
upload design for large assets.

## Complex Forms

A form library can help with nested fields, repeated sections, touched and dirty
tracking, schema integration, and render isolation. Evaluate whether it works
with native semantics, accessible errors, server responses, and the chosen
rendering framework.

Do not let a library's generic field abstraction hide the actual label, input,
error, and focus relationships.

## Form Checklist

- Every field has a stable name and accessible label.
- Validation errors explain how to fix the value.
- Server validation is authoritative.
- Pending and failure states are visible and announced.
- Keyboard order and focus behavior remain logical.
- Duplicate submissions are prevented or safe.
- Sensitive values are not persisted or logged unnecessarily.
