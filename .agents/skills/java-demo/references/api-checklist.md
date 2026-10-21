# API Design Checklist & Status Codes

## Status code quick reference
| Code | Meaning | When |
|---|---|---|
| 200 | OK | successful GET / PUT / PATCH |
| 201 | Created | resource created (include `Location`) |
| 202 | Accepted | async / queued work started |
| 204 | No Content | successful DELETE |
| 400 | Bad Request | malformed syntax |
| 401 | Unauthorized | missing/invalid auth |
| 403 | Forbidden | authed but not allowed |
| 404 | Not Found | resource missing |
| 409 | Conflict | state conflict (e.g. duplicate) |
| 422 | Unprocessable | valid syntax, semantic errors |
| 429 | Too Many Requests | rate limited |
| 500 | Internal Error | unexpected server fault |

## Design review checklist
- [ ] Resource-oriented URLs (nouns, plural, no verbs)
- [ ] Correct HTTP method per action (GET safe/idempotent, POST create)
- [ ] Appropriate status codes (201 + Location on create)
- [ ] Consistent error envelope with machine-readable `code` + `traceId`
- [ ] List endpoints bounded (pagination, no unbounded returns)
- [ ] Filtering/sorting params validated server-side
- [ ] Authz enforced on every sensitive action
- [ ] No internal entities leaked (DTOs only)
- [ ] Idempotency for retries (`Idempotency-Key` / `ETag`)
- [ ] Versioning plan for breaking changes (`/v1`)
- [ ] OpenAPI documented & generated from code

## Naming conventions
- Resources: plural, lowercase, hyphenated (`/order-items`)
- JSON fields: `camelCase`
- Query params: `page`, `size`, `sort=-createdAt`, `filter=...`
- Error `code`: `UPPER_SNAKE_CASE` (`ORDER_NOT_FOUND`)
