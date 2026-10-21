---
name: java-demo
description: Unified backend engineering guidance for Java and Spring Boot, REST APIs, SQL and data modeling, TypeScript backend support, Docker/Kubernetes, security, testing, observability, and Git workflows. Use when building, debugging, refactoring, reviewing, testing, deploying, or operating a backend service; do not use for frontend-only work.
metadata:
  short-description: Unified Java backend engineering
---

# Backend Engineering

Use this as the backend entrypoint. Inspect first, then load one primary reference only when needed and at most one secondary for a clear cross-boundary concern. Never load every reference by default.

## Route by signal

| Task signals | Primary reference | Optional secondary |
|---|---|---|
| endpoint, DTO, error, pagination, OpenAPI, contract | [api-checklist.md](references/api-checklist.md) | production review for auth/config |
| JPA, Hibernate, repository, N+1, query, index, Flyway, migration | [jpa-and-migration-review.md](references/jpa-and-migration-review.md) | API checklist for public impact |
| config, profile, secret, security, Actuator, health, performance | [spring-production-review.md](references/spring-production-review.md) | API checklist for contract impact |
| test, MockMvc, Testcontainers, slice, integration | [testing-recipes.md](references/testing-recipes.md) | affected domain reference |
| JVM, GC, OOM, heap, native memory, thread dump, deadlock, high CPU | [jvm-incident-triage.md](references/jvm-incident-triage.md) | production review for probes/metrics |
| Maven, BOM, CVE, dependency, Spring Boot/Cloud/AI upgrade | [dependency-upgrades.md](references/dependency-upgrades.md) | affected framework reference |
| Spring AI, `@Tool`, `ToolCallback`, agent action | [spring-ai-tools.md](references/spring-ai-tools.md) | production review for auth/secrets |
| SQL syntax, schema, indexes, query plan | [sql-cheatsheet.md](references/sql-cheatsheet.md) | JPA review for ORM/migration risk |
| Docker, Compose, Kubernetes, probes, rollout | [k8s-manifests.yaml](references/k8s-manifests.yaml) | production review for health/security |
| TypeScript backend types or narrowing | [ts-utilities.md](references/ts-utilities.md) | none unless the API contract changes |
| Git branch, commit, rebase, merge, recovery | [git-cheatsheet.md](references/git-cheatsheet.md) | none |
| ordinary Spring annotations/project structure | [spring-cheatsheet.md](references/spring-cheatsheet.md) | none; do not also load production review |

Simple CRUD or local edits use repository context without an unrelated reference.

## Working rules

1. Inspect runtime/build, modules, profiles, persistence/migrations, tests, CI, and deployment files before editing.
2. Preserve repository architecture, versions, persistence, and dependency ownership; verify version-sensitive claims against build files and official docs.
3. Keep adapters thin, validate boundaries, return DTOs, parameterize queries, define transactions, and authorize sensitive actions server-side.
4. Never commit/log secrets, tokens, passwords, unnecessary PII, stack traces, or sensitive actuator details. Verify proportionally with repository checks and real boundaries where they matter.

## Token contract

- Read only the selected primary; add the secondary only when its condition is present.
- Do not read `references/provenance.md` during ordinary work. Do not combine `spring-cheatsheet.md` and `spring-production-review.md` unless version/config risk is explicit.

For new Java/Spring scaffolding, inspect first and use [scaffold.sh](scripts/scaffold.sh) only when its project shape matches; never overwrite an existing project without explicit approval.

## Boundary

Do not activate for frontend-only UI, CSS, browser layout, or visual design. For cross-stack work, apply this skill only to backend API, data, service, deployment, security, and operations concerns.
