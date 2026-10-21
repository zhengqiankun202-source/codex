---
name: api-design
description: REST API design assistant. Use when designing, documenting, versioning, or reviewing HTTP APIs — resource/URL modeling, request/response shapes, error envelopes, pagination, filtering, idempotency, and OpenAPI/Swagger docs. Complements the java-spring skill's controller patterns with design-level guidance.
metadata:
  short-description: REST API design & docs
---

# API Design

Design-level guidance for HTTP APIs. Pair with `java-spring` for Spring controller implementation.
A status-code / review checklist is in `references/api-checklist.md`.

## When to use

- Designing a new endpoint or a service's whole HTTP surface.
- Choosing URLs, HTTP methods, status codes, or request/response shapes.
- Defining consistent errors, pagination, filtering, sorting.
- Picking a versioning strategy; generating OpenAPI/Swagger; reviewing API consistency.

## Resource modeling

- Nouns, not verbs: `/orders` not `/getOrders`. Non-CRUD actions → sub-resource or named operation
  (e.g. `POST /orders/{id}/cancel`).
- Nest for ownership: `/customers/{id}/orders`; avoid deep nesting (≤ 2 levels).
- Use plural, lowercase, hyphenated resource names: `/order-items`.

## Methods & status

- `GET` (safe, idempotent), `POST` (create), `PUT` (full replace, idempotent), `PATCH` (partial),
  `DELETE` (idempotent).
- `200` OK · `201` Created (+ `Location`) · `202` Accepted (async) · `204` No Content (delete) ·
  `400` bad input · `401` unauthenticated · `403` forbidden · `404` missing · `409` conflict ·
  `422` validation · `429` rate limited · `500` unexpected.

## Request / response shape

- Exchange JSON (`Content-Type: application/json`); use `camelCase` in JSON.
- Paginated collections carry metadata:
  ```json
  { "data": [ ... ], "page": { "number": 1, "size": 20, "total": 137 } }
  ```
- Map to **DTOs** — never expose internal JPA entities as responses.
- Document nullability; keep responses stable (additive changes only).

## Errors: consistent envelope

```json
{
  "error": {
    "code": "ORDER_NOT_FOUND",
    "message": "Order 12345 does not exist",
    "traceId": "a1b2c3",
    "details": [ { "field": "id", "issue": "not found" } ]
  }
}
```

- Use a machine-readable `code` (not the HTTP number) so clients can branch.
- Include `traceId` for support correlation; never leak stack traces.

## Pagination / filtering / sorting

- Cursor (keyset) for large/append-heavy data; offset for small/admin views.
- `?page=2&size=20&sort=-createdAt,status` (leading `-` = descending).
- Filtering: `?status=PAID&customerId=9`; validate enum/range params server-side.

## Idempotency & concurrency

- Keep `PUT`/`DELETE` idempotent. For retryable `POST`, accept an `Idempotency-Key` header and dedupe.
- Use `ETag` / `If-Match` for optimistic concurrency on updates.

## Versioning

- Prefer URL prefix `/v1/...` for breaking changes (easier to debug than header versioning).
- Additive, non-breaking changes (new optional field) need no version bump.

## Documentation (OpenAPI)

- Generate from code with `springdoc-openapi-starter-webmvc-ui` → `/v3/api-docs`, `/swagger-ui.html`.
- Annotate DTOs with `@Schema`; document every error `code`.
- Keep the published OpenAPI spec in CI as a contract; consider consumer-driven contract tests.

## Review checklist (see references/api-checklist.md)

Resource-oriented URLs · correct methods/status · consistent error envelope · bounded list responses ·
authz enforced · no entity leak · versioning plan · OpenAPI documented.
