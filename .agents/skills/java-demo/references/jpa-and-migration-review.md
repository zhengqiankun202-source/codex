# JPA Query and Migration Review

Read this reference for query tuning, repository review, schema changes, or rolling deployments that overlap old and new application versions.

## JPA/query checklist

Measure before changing: capture the generated SQL, execution plan, row counts, latency, and query count under representative data. Then check:

- N+1 access: use a bounded DTO projection, an entity graph, a targeted fetch join, or batch fetching according to the response shape. Do not make every association eager.
- Pagination: collection fetch joins can duplicate roots and invalidate count queries. For large or changing datasets, consider a stable keyset cursor or a two-step ID page followed by a bounded fetch.
- Repository semantics: inspect unintended inner joins, predicates that turn a left join into an inner join, nullable parameter behavior, duplicate roots, unbounded `findAll`, and native-query/count-query drift.
- Bulk DML: remember that update/delete queries can bypass the persistence context; define clear flush/clear behavior and test stale-entity consequences.
- Authorization and tenancy: every custom query path must preserve the required tenant/resource predicate; do not assume a controller guard covers a repository method used elsewhere.
- Index evidence: align indexes with actual predicates, joins, sort order, and cardinality; verify with `EXPLAIN`/`EXPLAIN ANALYZE` against production-like data.

Keep transaction boundaries around a business operation, and keep entities separate from API DTOs. Treat lazy-loading failures as a boundary/design signal, not a reason to expose the session globally.

## Safe schema-change review

Collect the database engine and major version, Flyway/versioned migration configuration, table size and write rate, rolling-deploy overlap, lock/statement timeouts, replication constraints, and the recovery procedure before calling a migration safe.

1. Read migrations in order and classify each statement as metadata-only, validation scan, rewrite/copy, blocking index build, backfill, or destructive change.
2. Analyze lock acquisition and queue amplification, not just the expected execution time.
3. Separate large backfills from DDL. Batch by an indexed key, record progress, throttle, and make the operation restartable and observable.
4. Use expand-contract for renames, type transitions, and removals: add the compatible shape, deploy dual-read/dual-write code as needed, backfill, switch reads, then remove the old shape after all older binaries are gone.
5. For PostgreSQL, evaluate `CREATE INDEX CONCURRENTLY`, `NOT VALID` constraints, validation scans, and transaction restrictions. For MySQL, evaluate metadata locks, implicit commits, engine/version support for `ALGORITHM`/`LOCK`, and copy behavior.
6. Never edit an already-applied versioned migration in a shared environment merely to fix validation; add a forward migration under the team's repair policy.

## Review output

Start with `block`, `change required`, `safe with conditions`, or `low risk`. For each finding state the exact statement, engine/version assumption, lock/rewrite/data-loss mechanism, safer phased SQL or rollout, pre/in-flight/post checks, abort signal, and roll-forward or recovery action. If scale or overlap is unknown, state that the unknown changes the decision.
