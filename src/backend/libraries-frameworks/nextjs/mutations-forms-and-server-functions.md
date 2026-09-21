# Mutations, Forms, and Server Functions

A Server Function is an async function marked for server execution. When used
for a mutation or form Action, it receives a framework-managed POST request and
can return updated UI and data in the same round trip.

## Define Server Functions Explicitly

```ts
// app/orders/actions.ts
"use server";

import { updateTag } from "next/cache";
import { redirect } from "next/navigation";

export async function createOrder(formData: FormData) {
  const session = await verifySession();
  const input = createOrderSchema.parse({
    productID: formData.get("productID"),
    quantity: formData.get("quantity"),
  });

  const order = await orderService.create(session.userID, input);
  updateTag("orders");
  redirect(`/orders/${order.id}`);
}
```

A file-level `"use server"` marks exported async functions in that module as
server callable. An inline directive can define a function inside a Server
Component.

Do not place the directive on arbitrary sensitive helpers. Keep those helpers
server-only and expose a narrow action that validates and authorizes its input.

## Actions Are Public Attack Surfaces

Treat every Server Function callable by the client like a public endpoint:

1. authenticate the current request;
2. authorize the specific resource and operation;
3. validate every argument at runtime;
4. enforce transaction and idempotency rules;
5. return a safe result;
6. invalidate the required cached data.

Hiding the invoking button does not protect the action. Bound arguments and
hidden form inputs are also controlled by the client.

## Form Actions

A Server Component form supports progressive enhancement:

```tsx
import { createOrder } from "./actions";

export function CreateOrderForm() {
  return (
    <form action={createOrder}>
      <label htmlFor="product">Product</label>
      <input id="product" name="productID" required />

      <label htmlFor="quantity">Quantity</label>
      <input id="quantity" name="quantity" type="number" min="1" required />

      <button type="submit">Create order</button>
    </form>
  );
}
```

The browser can submit before client JavaScript loads. Preserve native form
semantics, labels, and server validation.

## Returning Expected Errors

Use `useActionState` in a Client Component for validation or business outcomes:

```tsx
"use client";

const initialState = { message: "", fieldErrors: {} };

export function ProfileForm() {
  const [state, action, pending] = useActionState(updateProfile, initialState);

  return (
    <form action={action}>
      <label htmlFor="name">Display name</label>
      <input id="name" name="name" aria-describedby="name-error" />
      <p id="name-error">{state.fieldErrors.name}</p>
      <button disabled={pending}>Save</button>
      <p role="status">{state.message}</p>
    </form>
  );
}
```

Return known errors as serializable state. Throw unexpected failures so an
Error Boundary and server error reporting can handle them.

## Pending and Optimistic UI

`useFormStatus` lets a submit control read the surrounding form's pending state.
`useOptimistic` can show an expected result while the server confirms it.

Optimistic UI needs stable temporary IDs, reconciliation, rollback, and clear
failure feedback. Never show irreversible success for payments or security-
sensitive changes before server confirmation.

## Revalidation and Redirects

After a successful write:

- use `updateTag` when the user must immediately read their write;
- use `revalidateTag` for stale-while-revalidate shared content;
- use `revalidatePath` when a route is the correct invalidation boundary;
- redirect only after the transaction succeeds.

Invalidate every affected aggregate. Updating an order may also change customer
history, inventory, and dashboard summaries.

## Transactions and Side Effects

A Server Action invocation is not automatically a database transaction. Put
related state changes in an explicit transaction and define what happens if an
email, webhook, or event publish fails afterward.

Use an outbox or durable job for side effects that must survive process failure.
Serverless invocations may stop after the response and local in-memory work is
not durable.

## Do Not Use Actions for General Reads

Server Actions are designed for mutations and client dispatch may be queued.
Fetch data through Server Components, Route Handlers for public HTTP consumers,
or a client query layer when browser-owned timing is required.

## Mutation Checklist

- Authenticate and authorize inside the action.
- Parse `FormData` and arguments as untrusted values.
- Protect duplicate or retryable writes with idempotency.
- Use a database transaction for atomic changes.
- Return field errors without exposing internals.
- Update or invalidate all affected cache entries.
- Preserve accessible pending, success, and failure feedback.
- Move durable follow-up work to a queue or outbox.
