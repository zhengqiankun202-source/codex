# Maven and Spring Dependency Upgrades

Use when changing Maven dependencies, plugins, BOMs, Java, Spring Boot/Cloud/AI, Hibernate, Jackson, or security versions.

## Baseline and version ownership

1. Record Java/Maven/wrapper versions, profiles, mirrors, the exact command, and the current passing/failing result.
2. Read parent POMs, imported BOMs, dependency management, plugin management, and reactor structure before editing leaf versions.
3. Generate the effective POM and dependency tree for disputed artifacts. Distinguish declared, managed, and transitive versions.
4. Identify the version owner. Prefer one platform/BOM property over scattered overrides; every exclusion needs a reason and a final resolved-tree check.

## Plan the smallest coherent upgrade

- Keep framework families compatible when guidance requires it: Spring Boot, Spring Cloud, Spring AI, Hibernate, Jackson, Netty, Kotlin, and test/container libraries may need coordinated changes.
- Upgrade in reviewable batches: build prerequisites, platform/BOM, adapters, then application migrations. Separate unrelated library cleanups.
- Check Java baseline, removed APIs, renamed configuration, database-driver behavior, bytecode tools, test engine, and container support before changing code.
- For CVE remediation, verify the resolved artifact version; a direct dependency declaration does not prove the runtime graph is safe.
- Preserve tests, enforcer rules, exclusions, and warnings. A temporary compatibility shim must state why it exists and when it can be removed.

## Validate and report

Run the smallest affected module tests, then the full reactor, dependency convergence, integration tests, packaging, startup smoke tests, and native/container builds when applicable. Inspect the final dependency tree and record a rollback version. Do not call an upgrade complete based on compilation alone; compare runtime behavior and representative payloads.

Report baseline/target and version owner, compatibility evidence, ordered changes, exact commands/results, unresolved risks, rollback point, and cleanup follow-ups. Mark assumptions when repository context is missing.
