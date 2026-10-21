---
name: docker-k8s
description: Containerization and Kubernetes assistant. Use when writing Dockerfiles, docker-compose, or K8s manifests (Deployment, Service, Ingress, ConfigMap, Secret, HPA), or debugging builds, images, pods, and rollouts. Covers image-size/security best practices, multi-stage builds, and common K8s pitfalls.
metadata:
  short-description: Docker & Kubernetes practical guide
---

# Docker & Kubernetes

Practical containerization for backend services. A copy-paste K8s manifest set is in
`references/k8s-manifests.yaml`.

## When to use

- Containerizing a Java/Spring service (multi-stage Dockerfile).
- Writing `docker-compose.yml` for a local multi-service stack.
- Authoring K8s manifests / Helm charts; configuring probes, resources, ingress.
- Debugging image bloat, failed pods, CrashLoopBackOff, or bad rollouts.

## Dockerfile (multi-stage, Java)

```dockerfile
# build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q dependency:go-offline
COPY src ./src
RUN mvn -q clean package -DskipTests

# runtime stage
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
RUN useradd -m app && chown -R app /app
USER app
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
```

- **Multi-stage** keeps the runtime image free of build tooling.
- Use a **slim JRE** (`eclipse-temurin:21-jre`) or `jlink` image, not a full JDK, at runtime.
- Pin base image by **digest** for reproducibility; scan with `trivy`/`grype` in CI.
- Run as **non-root**; set `-XX:MaxRAMPercentage=75` so the JVM respects container memory limits.

## docker-compose (local only)

```yaml
services:
  app:
    build: .
    ports: ["8080:8080"]
    environment:
      SPRING_PROFILES_ACTIVE: dev
      DB_URL: jdbc:postgresql://db:5432/app
    depends_on: [db]
  db:
    image: postgres:16
    environment: { POSTGRES_PASSWORD: dev, POSTGRES_DB: app }
    volumes: ["pgdata:/var/lib/postgresql/data"]
volumes: { pgdata: }
```

- Keep dev compose separate from prod manifests; never ship compose to production.

## Kubernetes core objects

- **Deployment**: replicas, pod template, `image: tag` (never `:latest` in prod),
  `resources.requests/limits`, `rollingUpdate` strategy.
- **Probes**: `readinessProbe` (only route traffic when ready), `livenessProbe` (restart if stuck),
  `startupProbe` for slow Java boot. Point at `/actuator/health`-style endpoints.
- **Service**: stable in-cluster DNS; `ClusterIP` default, `LoadBalancer`/`NodePort` to expose.
- **Ingress**: external routing + TLS; needs an installed ingress controller.
- **ConfigMap / Secret**: externalize config & secrets; mount as env or volume. Never bake secrets
  into images.
- **HPA** (`autoscaling/v2`): autoscale on CPU or custom metrics.

## Rollouts & debugging

- `kubectl apply -f ./manifests/` ; `kubectl rollout status deploy/app`.
- `kubectl logs deploy/app --tail=100` ; `kubectl exec -it <pod> -- sh`.
- `kubectl describe pod <x>` → Events reveal `ImagePullBackOff`, `OOMKilled`, `CrashLoopBackOff`.
- Rollback: `kubectl rollout undo deploy/app`.

## Gotchas

- **OOMKilled** → JVM heap + metaspace exceeds `limits.memory`; set `-XX:MaxRAMPercentage` and
  right-size limits.
- **Readiness vs liveness**: a failing liveness during slow startup kills the pod — use
  `startupProbe`.
- `:latest` tag → unpredictable rollouts; always pin versions.
- Secrets in env are visible via `describe`; prefer sealed-secrets / external-secret operators.
- Don't run stateful DBs on ephemeral pods without `PersistentVolumeClaim`s.
