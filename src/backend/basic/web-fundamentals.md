# Frontend Basics for Backend Developers

A concise reference covering the core frontend technologies and how they
interact with a backend like FastAPI.

## Q37. What are the roles of HTML, CSS, and JavaScript?

- **HTML (structure)**: Semantic tags (`<header>`, `<main>`, `<article>`) define
  page structure, forms for input, and accessibility attributes (`aria-label`,
  `alt`). It is the skeleton of every web page.
- **CSS (styling)**: Controls layout and visual presentation. Flexbox and Grid
  handle alignment and two-dimensional layouts. Media queries enable responsive
  design that adapts to screen sizes.
- **JavaScript (interactivity)**: Manipulates the DOM, handles events (clicks,
  input), and makes API calls via `fetch()` or Axios. It is the brain that makes
  pages dynamic.
- **Together**: HTML defines *what* is on the page, CSS defines *how it looks*,
  and JavaScript defines *how it behaves*.

## Q38. What is CORS and why does it occur?

**Cross-Origin Resource Sharing (CORS)** is a browser security policy that
restricts scripts on one origin from reading responses from another origin.

**Why it occurs**: When a frontend at `localhost:3000` calls an API at
`localhost:8000`, the browser treats them as different origins and blocks the
response unless the server explicitly allows it.

**How the server fixes it**: Sets the `Access-Control-Allow-Origin` header
listing permitted origins.

**Preflight**: For non-simple requests (methods like `PUT`, `DELETE` or custom
headers like `Authorization`), the browser sends an `OPTIONS` request first to
check whether the real request is allowed.

**FastAPI example**:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_methods=["*"],
    allow_credentials=True,
    allow_headers=["*"],
)
```

## Q39. How does React communicate with a FastAPI backend?

React uses standard HTTP calls to talk to a backend:

- **Data fetching**: `fetch()` or Axios `get`/`post` for GET, POST, PUT, DELETE.
- **Lifecycle**: `useEffect` triggers fetching when a component mounts.
- **State**: `useState` stores the response data for rendering.
- **Error handling**: `try/catch` around async calls; display error states in UI.
- **Authentication**: Attach a JWT token in the `Authorization: Bearer <token>`
  header.

```javascript
useEffect(() => {
  fetch("/api/users")
    .then((r) => r.json())
    .then(setUsers)
    .catch(console.error);
}, []);
```

In production, Axios interceptors or a base URL config centralize the token and
base path so components stay clean.

---

## Interview Questions and Answers

### 1. Why is CORS not a problem for same-origin requests?

**Answer:** Same-origin means protocol, host, and port all match. The browser's
same-origin policy only restricts cross-origin reads, so a frontend calling its
own server (same origin) goes through without CORS headers.

### 2. How would you handle authentication in a React + FastAPI SPA?

**Answer:** After login, the backend returns a short-lived access JWT and a
long-lived refresh token stored in an httpOnly cookie. The React app sends the
access token in the `Authorization` header. An Axios interceptor refreshes the
token on 401 responses so the user stays logged in without manual token
management.

### 3. What is the difference between server-side rendering and client-side
rendering, and when does each matter?

**Answer:** Client-side rendering (React SPA) loads a minimal HTML shell, then
JavaScript builds the page — good for interactive dashboards where SEO is
unimportant. Server-side rendering (Next.js, Remix) sends fully rendered HTML
on first load — better for SEO, slower connections, and content-heavy pages. The
choice depends on whether search indexing and initial load speed outweigh client
interactivity.
