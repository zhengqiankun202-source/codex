# Spring Production Review

Use this reference when a backend change crosses architecture, configuration, security, actuator, or performance boundaries. Existing repository conventions and measured behavior take precedence over these defaults.

## Architecture and dependency flow

- Choose layer-based packages for a small, stable monolith; choose feature-based packages when domains, ownership, or extraction boundaries dominate. Do not reorganize a working codebase just to match a template.
- Keep the dependency direction explicit: web and messaging adapters call application services; domain code does not depend on transport or persistence; infrastructure adapters implement ports at the edge.
- Keep controllers thin. Validate and normalize input at the boundary, pass DTOs or commands inward, and map domain results back to response DTOs. Do not serialize persistence entities as the public contract.
- Put cross-cutting behavior in focused boundaries: exception advice, request/tracing filters, authorization checks, and configuration modules. Avoid a generic utility package becoming an undocumented dependency sink.

## Configuration and errors

- Bind related settings with `@ConfigurationProperties`; use typed `Duration`, `DataSize`, enums, and validation instead of scattered untyped `@Value` strings.
- Layer shared, profile-specific, and externally imported configuration deliberately. Inject secrets from the environment, a secret manager, or a platform secret; never print `.env` or commit credentials. If a secret was committed, rotate it rather than merely deleting the line.
- Use one error contract, preferably `ProblemDetail`/RFC 9457 on supported Spring versions. Map expected domain failures to stable status and machine-readable codes; keep a last-resort handler for unexpected failures that returns no stack trace, SQL, token, or internal path.
- Include a correlation/trace identifier in logs and error responses only when the project already has a trusted propagation mechanism. Do not accept a caller-supplied identifier as proof of identity.

## Security boundary

- Separate authentication from authorization. Deny by default and enforce object/tenant authorization at the service or resource boundary, not only on URL patterns.
- Validate DTO shape, size, ranges, URLs, file metadata, and identifiers. Parameterize all SQL and constrain dynamic sort/filter fields to an allow-list.
- Keep CSRF enabled for browser sessions; a stateless bearer-token API may disable it only with an explicit threat model. Restrict CORS origins and credentials in production, and configure security headers for the deployed client model.
- Hash passwords with a framework `PasswordEncoder`; externalize signing keys and credentials; never log tokens, passwords, full payment data, or unnecessary PII. Rate-limit expensive and authentication endpoints where abuse is plausible.

## Actuator, health, and performance

- Expose only the management endpoints required by the environment. Treat `/env`, heap dumps, thread dumps, shutdown, and unrestricted config details as sensitive; protect or keep them off the network.
- Keep liveness a cheap process-health signal. Readiness may include essential dependencies, but every check must be bounded and cheap enough for frequent probes; a slow dependency check should not stall the probe path.
- Use metrics and traces to form a baseline before tuning. Investigate pool saturation, downstream latency, allocation rate, post-GC live-set growth, query count, and payload size rather than guessing.
- Consider virtual threads only for compatible, I/O-bound workloads after checking blocking libraries, thread-local assumptions, pinning risk, and connection-pool limits. Do not treat them as a substitute for bounded concurrency or query optimization.
