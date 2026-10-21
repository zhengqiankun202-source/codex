---
name: secure-coding
description: Secure-coding checklist for backend applications, especially Spring Boot / Java services. Use when writing or reviewing code that handles user input, authentication/authorization, secrets, data persistence, or external dependencies. Covers OWASP-style risks, input validation, authn/authz, secrets handling, and dependency hygiene.
metadata:
  short-description: Backend security checklist (Spring/Java)
---

# Secure Coding

A practical checklist for writing and reviewing backend code. Pair with `java-spring` for Spring
specifics. Goal: catch the common, high-impact flaws before they ship.

## When to use

- Building an endpoint that accepts user input or uploads.
- Implementing or changing authn / authz logic.
- Storing config, credentials, or PII.
- Adding a third-party / open-source dependency.
- Reviewing a PR for security regressions.

## Top risks to check (OWASP-flavored)

1. **Broken access control** — every request re-checks authorization server-side. Don't trust a
   client-sent `role`/`userId`; enforce via `@PreAuthorize` or filter, not just the UI hiding a button.
2. **Injection** — SQL/OS/command injection from untrusted input. Always parameterize queries
   (`?` / named params), never string-concatenate. Use the ORM's typed APIs.
3. **Auth failures** — weak password hashing (`BCrypt`/`Argon2`, never MD5/SHA/plain), no rate
   limiting on login, sessions without expiry, JWT without signature/audience checks.
4. **Sensitive data exposure** — PII in logs, plaintext at rest, missing TLS, verbose error pages
   leaking stack traces.
5. **Security misconfiguration** — default Spring Security permissiveness, `CORS: *` with credentials,
   exposed actuator endpoints (`/health` ok, `/env`/`/heapdump` not).
6. **XSS** — encode output; with templating use the framework's auto-escaping; avoid `th:utext`/
   `innerHTML` on user data.
7. **Insecure deserialization** — don't `readObject` untrusted streams; validate message types.
8. **Logging of secrets** — never log passwords, tokens, full cards; mask before logging.

## Input validation

- Validate at the boundary: DTOs with `jakarta.validation` (`@NotNull`, `@Size`, `@Pattern`).
- Whitelist, not blacklist; reject unknown fields (`spring.jackson.deserialization.fail-on-unknown-properties`).
- Canonicalize / trim before checks; be careful with Unicode/encoding bypasses.

## Authn / Authz

- Use the framework's security (Spring Security), not hand-rolled filters.
- Check authorization per request; method-level guards (`@PreAuthorize("hasRole('ADMIN')")`).
- Hash passwords with `BCryptPasswordEncoder` (or Argon2); constant-time compare.
- Rate-limit login and token endpoints; lock/backoff after failures.
- Set cookie flags: `HttpOnly`, `Secure`, `SameSite=Lax/Strict`; short-lived access + refresh tokens.

## Secrets & config

- No secrets in source or VCS. Use env vars / a secret manager (`SPRING_PROFILES_ACTIVE`, Vault).
- `.gitignore` credential files; scan repos (gitleaks) in CI.
- Rotate compromised secrets; prefer scoped, least-privilege credentials per service.

## Data protection

- TLS in transit (terminate + verify at the edge; mTLS between services when possible).
- Encrypt PII at rest; minimize what you store (don't keep what you don't need).
- Mask PII in logs and responses; honor deletion/retention requirements.

## Dependencies

- Run `mvn dependency-check:check` / `snyk test` in CI; fail on high/critical.
- Keep frameworks patched; watch transitive deps, not just direct ones.
- Pin versions; avoid abandoned libraries.

## Review checklist (paste into a PR template)

- [ ] All untrusted input validated/parameterized
- [ ] Authz enforced server-side on every sensitive action
- [ ] No secrets logged or committed
- [ ] Errors don't leak internals to clients
- [ ] CORS / cookie flags correct
- [ ] New dependencies scanned
