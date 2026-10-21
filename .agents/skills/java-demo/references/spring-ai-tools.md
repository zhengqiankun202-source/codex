# Spring AI Tool Safety Review

Use when creating or reviewing `@Tool` methods, `ToolCallback` implementations, model-facing schemas, or agent actions that read or mutate application state.

## Establish the tool contract

Inventory each tool's name, description, parameters, output, side effects, downstream calls, caller, tenant, authenticated principal, and authorization boundary. Separate read-only tools from tools that mutate data, spend money, send messages, disclose data, or invoke infrastructure.

## Review rules

- Make descriptions narrow and include important exclusions; avoid vague verbs such as “manage” or “process”.
- Describe every model-controlled parameter and validate type, canonical form, size/range, collection count, URL/path, and enum values in application code.
- Supply principal and tenant context from trusted runtime state rather than accepting model-provided identity fields.
- Enforce object-level authorization at the resolved resource. Prompt wording is never authorization.
- Require an explicit approval gate for high-impact or irreversible actions; bind approval to the exact normalized tool, principal, target, arguments, and expiry.
- Give retryable mutations an idempotency key or durable operation identity. Define one retry owner, deadlines, cancellation, and rate limits for remote calls.
- Return small structured results with stable failure categories. Do not expose stack traces, credentials, tokens, prompts, unrestricted records, or raw downstream payloads.
- Emit redacted audit events for accepted, rejected, completed, and failed calls with tool, outcome, duration, principal, resource, and correlation ID.

## Minimum negative tests

Test malformed/oversized input, unauthorized resources, duplicate delivery, expired or altered approval, timeout, partial downstream failure, and sensitive-error redaction wherever those paths exist. Start a review with `block`, `change required`, `safe with conditions`, or `low risk`, and identify every missing runtime assumption.
