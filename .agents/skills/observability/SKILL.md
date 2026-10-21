---
name: observability
description: Observability assistant for backend services — logging, metrics, and tracing. Use when setting up structured logging, Micrometer metrics, Prometheus/Grafana, distributed tracing (Micrometer Tracing / OpenTelemetry), alerts, or debugging "it's slow / it's failing" with telemetry. Complements secure-coding and java-spring.
metadata:
  short-description: Logging, metrics & tracing
---

# Observability

Make a service observable in production: logs, metrics, traces — and how to use them to debug.
Assume Spring Boot Actuator basics; focus on what to emit and how to reason with it.

## When to use

- Setting up or improving how a service is observed.
- Choosing what to log / metric / trace; defining SLOs and alerts.
- Debugging latency, error spikes, or "works locally, fails in prod".

## The three pillars

1. **Logs** — discrete events. Use **structured (JSON) logging**, not string concat.
2. **Metrics** — numeric time series (counters, gauges, histograms) for rates/percentiles/SLOs.
3. **Traces** — a request's path across services; essential in microservices (Spring Cloud).

## Structured logging

- Log JSON (Logback + `logstash-encoder`, or Spring Boot 3 default). Include `traceId`, `spanId`.
- Levels: `ERROR` (user-impacting) · `WARN` (recoverable) · `INFO` (lifecycle) · `DEBUG` (dev).
- **Never log secrets/PII** (see `secure-coding`); mask before logging.
- Propagate a **correlation ID** per request via MDC; return it in responses for support.

## Metrics (Micrometer + Prometheus)

- Actuator exposes `/actuator/prometheus` with `micrometer-registry-prometheus` on classpath.
- Track: request rate, error rate, latency (p95/p99 histograms), JVM/mem, DB pool, queue depth.
- Custom business metrics: `meterRegistry.counter("orders.created")` / `Timer`.
- Scrape with Prometheus; dashboards in Grafana; alert on SLO burn (e.g. error rate > 1%).

## Tracing (distributed)

- Spring Cloud → **Micrometer Tracing** (Sleuth is deprecated) with Brave/OTel + a collector
  (Tempo / Jaeger / OTel Collector).
- Propagate `traceId` across HTTP (headers) and messaging; sample a percentage in prod (e.g. 10%).
- Use traces to locate the slow span in a multi-service call.

## Alerting & SLOs

- Alert on symptoms users feel: error rate, p99 latency, saturation — not just "pod restarted".
- Define SLOs (e.g. 99.9% success) and error budgets; page only on budget burn.

## Debugging with telemetry

- **Slow?** → trace the request, find the slow span (DB query? downstream call? lock?).
- **Failing?** → error-rate metric → correlated logs by `traceId` → the exception + context.
- **Intermittent?** → check saturation (CPU/mem/DB pool), retries, and timeouts.

## Gotchas

- High-cardinality labels (e.g. per-user ID as a metric tag) explode storage — keep labels
  low-cardinality.
- Trace sampling too low hides rare issues; too high costs money. Tune per environment.
- Logs without `traceId` are nearly useless in microservices.
