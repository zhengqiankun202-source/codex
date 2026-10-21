# JVM Incident Triage

Use for high CPU, hangs, deadlocks, latency, GC pauses, heap/native OOM, memory leaks, or repeated restarts. Preserve evidence and stabilize impact before invasive collection.

## Establish the timeline

Record the incident window, Java/JVM and container limits, deployment/workload changes, restart history, affected instances, user impact, and correlated latency, throughput, error, host CPU, memory, disk, and network signals.

## Collect bounded evidence

- Capture three thread dumps several seconds apart. A single dump is a snapshot, not proof of a deadlock or root cause.
- When permitted, record `jcmd <pid> VM.version`, `VM.flags`, `GC.heap_info`, and `Thread.print -l`. Preserve recent GC logs and fatal-error files.
- Compare RSS with committed heap, direct buffers, metaspace, code cache, native libraries, mapped files, thread count, file descriptors, and container limits.
- Use an existing JFR recording or a bounded profile only after checking overhead, disk capacity, sensitive-data handling, and policy. Do not start a heap dump on an almost-full host.
- Redact credentials, customer data, SQL literals, and sensitive arguments before sharing artifacts; retain timestamps and instance identity.

## Analyze by symptom

- High CPU: map hot OS thread IDs to JVM thread IDs, compare repeated stacks, and separate application loops, contention, JIT, and GC CPU.
- Hangs/latency: inspect lock cycles, blocked owners, pool starvation, parked threads, downstream waits, and synchronized bottlenecks across repeated dumps.
- Heap pressure: compare allocation rate with post-collection live-set trend, promotion failures, humongous allocations, and collection frequency. High allocation alone is not a leak.
- Native memory: explain RSS above committed heap with direct buffers, stacks, metaspace, code cache, JNI/native libraries, allocator fragmentation, or mapped files; Native Memory Tracking is unavailable unless enabled at startup.
- Restarts: distinguish Java heap OOM, native allocation failure, external container OOM kill, termination, and health-check eviction using runtime/kernel evidence.

## Report contract

Separate facts, inferences, and unknowns. Provide impact/timeline, ranked hypotheses with supporting and contradicting evidence, containment with rollback risk, the next collection command and expected discriminator, confidence, and longer-term remediation. Keep containment separate from root-cause fixes.
