# HTTP and REST

## What is a REST API?

A **REST API** is a **stateless**, HTTP-based interface through which clients access and manipulate server resources using HTTP methods on URL endpoints.

**Stateless** means the server does not remember previous requests. Each request must include all data needed to process it, such as authentication tokens or parameters.

## Difference Between `GET` and `POST`

- `GET` retrieves data from the server.
- `POST` sends data to create a new resource.

## Route Design

**Good route design uses nouns instead of actions**, because the HTTP method already describes the action.

Examples:

- `GET /users`
- `GET /users/42`
- `POST /users`
- `PATCH /users/42`
- `DELETE /users/42`

## Common HTTP Methods

- `GET`: read data
- `POST`: create a resource
- `PUT`: replace a resource
- `PATCH`: partially update a resource
- `DELETE`: remove a resource

## Status Code Categories

- `2xx`: success
- `3xx`: redirection
- `4xx`: client error
- `5xx`: server error

Common examples:

- `200 OK`
- `201 Created`
- `204 No Content`
- `400 Bad Request`
- `401 Unauthorized`
- `403 Forbidden`
- `404 Not Found`
- `409 Conflict`
- `500 Internal Server Error`
