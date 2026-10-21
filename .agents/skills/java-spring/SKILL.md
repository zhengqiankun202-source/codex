---
name: java-spring
description: Practical Spring Boot / Spring framework development assistant. Use when building, debugging, or extending a Java project with Spring Boot — web apps, REST APIs, data access (JPA / MyBatis / MyBatis-Plus), Spring Cloud microservices (service discovery, OpenFeign, Gateway, config, circuit breaking), configuration, dependency injection, or testing. Provides scaffolding commands, project-structure conventions, annotation quick references, build/run/test commands, and a debugging checklist.
metadata:
  short-description: Spring Boot / Java development helper
---

# Java Spring Helper

Practical guidance for Spring Boot (3.x) projects on Java 17/21. Assume the reader knows Java
syntax; focus on Spring-specific conventions, commands, and pitfalls. A compact annotation and
dependency cheat sheet lives in `references/spring-cheatsheet.md`.

## When to use

- Scaffolding a new Spring Boot service or module.
- Designing REST controllers, services, repositories, or DTOs.
- Wiring configuration, profiles, or externalized properties.
- Choosing between Spring Data JPA and MyBatis, or writing queries.
- Writing or fixing tests (`@SpringBootTest`, `@WebMvcTest`, Testcontainers).
- Diagnosing startup failures, bean wiring errors, or N+1 queries.

## 1. Scaffold a project

Prefer Spring Initializr. The repo includes `scripts/scaffold.sh` (run from Git Bash / WSL):

```bash
# Maven, Java 21, Spring Boot 3.4, web + data-jpa + validation + test
bash ~/.codex/skills/java-spring/scripts/scaffold.sh \
  --name order-service --package com.acme.order --java 21 \
  --deps web,data-jpa,validation,postgresql,lombok,test
```

Equivalent raw call (no script):

```bash
curl https://start.spring.io/starter.zip \
  -d type=maven-project -d javaVersion=21 -d bootVersion=3.4.4 \
  -d groupId=com.acme -d artifactId=order-service \
  -d dependencies=web,data-jpa,validation,postgresql,lombok,test \
  -o order-service.zip && unzip order-service.zip -d order-service
```

Common dependency tokens: `web`, `webflux`, `data-jpa`, `data-mongodb`, `jdbc`, `mybatis`,
`validation`, `security`, `oauth2-client`, `postgresql`, `mysql`, `h2`, `lombok`, `actuator`,
`test` (JUnit 5 + MockMvc + AssertJ).

## 2. Standard Maven layout

```
src/main/java/com/acme/order/
  OrderApplication.java          # @SpringBootApplication, main()
  controller/  OrderController.java
  service/     OrderService.java
  repository/  OrderRepository.java
  model/       Order.java (entity) / OrderDto.java (record/DTO)
  config/      SecurityConfig.java / OpenApiConfig.java
src/main/resources/
  application.yml  application-dev.yml  application-prod.yml
  db/migration/    # Flyway/Liquibase if used
src/test/java/com/acme/order/  ...mirror of main
```

Package by feature when the app grows (`order/`, `customer/`), not strictly by layer.

## 3. Core conventions

- **Constructor injection only** — never field `@Autowired`. Final fields, immutable, testable.
- **Controllers are thin**: map HTTP, validate, delegate to a service, return DTOs. No business logic.
- **Entities vs DTOs**: never expose JPA entities directly as API responses.
- **Use `record` for DTOs** when immutable: `public record OrderDto(Long id, String code) {}`.
- **Validation**: annotate DTOs with `jakarta.validation` constraints; trigger with `@Valid` on the
  controller parameter; return `400` automatically.
- **Transactions**: put `@Transactional` on the service method that needs atomicity, not the repo.
- **Logging**: inject `private static final Logger log = LoggerFactory.getLogger(X.class);`.

## 4. Configuration & profiles

```yaml
# application.yml
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:dev}
  datasource:
    url: ${DB_URL}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
---
spring:
  config:
    activate:
      on-profile: prod
  jpa:
    hibernate:
      ddl-auto: validate   # never 'update' in prod
```

- Externalize secrets via env vars / `application-prod.yml` outside the repo.
- Read custom props with `@ConfigurationProperties("app")` on a typed bean, not scattered `@Value`.
- `ddl-auto`: `create-drop` (dev/test only), `validate` or `none` (prod with migrations).

## 5. Data access

**Spring Data JPA** — derive queries from method names; add `@Query` for complex cases.

```java
public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByCustomerIdAndStatus(Long customerId, OrderStatus status);
    @Query("select o from Order o join fetch o.items where o.id = :id")
    Optional<Order> findWithItems(@Param("id") Long id);
}
```

- Avoid N+1: use `join fetch` or `@EntityGraph` for collections.
- Prefer `JpaRepository` over `CrudRepository` (paging/sorting built in).

**MyBatis-Plus** (Baomidou; Spring Boot 3 → `mybatis-plus-spring-boot3-starter`, v3.5.x) — enhances
MyBatis with zero-XML CRUD. Add the dependency manually (not an Initializr token):

```xml
<dependency>
  <groupId>com.baomidou</groupId>
  <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
  <version>3.5.9</version>
</dependency>
```

- **Entity**: `@TableName("t_order")`, `@TableId(type = IdType.AUTO)` (or `ASSIGN_ID` for snowflake),
  `@TableField("col_name")`, `@TableLogic` for logical delete.
- **Mapper**: extend `BaseMapper<Order>` to get `insert / deleteById / selectById / selectList /
  updateById` for free; enable scanning with `@MapperScan("com.acme.mapper")` on the app class.
- **Service layer**: `extends IService<Order>` + `ServiceImpl<OrderMapper, Order>` for paginated
  `page(new Page<>(1, 10), wrapper)` and batch ops.
- **Wrappers**: prefer `LambdaQueryWrapper<Order>` to avoid hard-coded column names:
  `wrapper.eq(Order::getStatus, PAID).ge(Order::getAmount, 100);`
- **Pagination**: register `MybatisPlusInterceptor` with `PaginationInnerInterceptor(DbType.MYSQL)`;
  without it `page()` returns `total = 0`.
- **Auto-fill** (create/update time): implement `MetaObjectHandler` + `@TableField(fill = FieldFill.INSERT)`.
- **Code generator** (`mybatis-plus-generator`) scaffolds entity/mapper/service from a DB schema.

**MyBatis** (plain) — use when SQL must be hand-tuned: `@Mapper` interface + XML/annotations.

## 6. REST controllers

```java
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor          // Lombok -> constructor injection
public class OrderController {
    private final OrderService service;

    @GetMapping("/{id}")
    public ResponseEntity<OrderDto> get(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PostMapping
    public ResponseEntity<OrderDto> create(@Valid @RequestBody CreateOrderRequest req) {
        OrderDto created = service.create(req);
        return ResponseEntity.created(URI.create("/api/orders/" + created.id())).body(created);
    }
}
```

- Return proper status codes (`201` + `Location` on create, `204` on delete).
- Global error handling via `@RestControllerAdvice` + `@ExceptionHandler` -> consistent error body.
- Document with Springdoc OpenAPI (`springdoc-openapi-starter-webmvc-ui`) -> `/swagger-ui.html`.

## 7. Testing

```java
@SpringBootTest
class OrderServiceTest {
    @Autowired OrderRepository repo;
    @Autowired OrderService service;

    @Test
    void createsOrder() {
        OrderDto dto = service.create(new CreateOrderRequest("A1", 2));
        assertThat(repo.findById(dto.id())).isPresent();
    }
}

@WebMvcTest(OrderController.class)            // slice test, no full context
class OrderControllerTest {
    @Autowired MockMvc mvc;
    @MockBean OrderService service;

    @Test void returns404WhenMissing() throws Exception {
        when(service.getById(99L)).thenThrow(new OrderNotFound(99L));
        mvc.perform(get("/api/orders/99")).andExpect(status().isNotFound());
    }
}
```

- Slice tests (`@WebMvcTest`, `@DataJpaTest`, `@JsonTest`) boot only the needed layer -> fast.
- Integration tests against real DB -> **Testcontainers** (`@Container` Postgres) in `@Testcontainers`.
- Use AssertJ (`assertThat`) over JUnit `assertEquals` for readable assertions.

## 8. Build & run

```bash
# Maven
./mvnw clean package          # build jar
./mvnw spring-boot:run        # run dev
java -jar target/order-service.jar

# Gradle
./gradlew build
./gradlew bootRun

# Run only a slice of tests
./mvnw test -Dtest=OrderControllerTest
```

## 9. Debugging checklist

- **`APPLICATION FAILED TO START` / unsatisfied dependency**: a bean is missing or two beans match
  a type — use `@Qualifier` or `@Primary`; check `@ComponentScan` base package covers the class.
- **Port already in use**: `server.port` conflict; set `server.port=0` for tests or free the port.
- **`404` on a valid mapping**: wrong `@RequestMapping` base, context path
  (`server.servlet.context-path`), or the controller isn't a Spring bean (missing `@RestController`).
- **LazyInitializationException**: accessing lazy collection outside a transaction -> fetch eagerly
  in the query or use `spring.jpa.open-in-view=false` + explicit fetching.
- **N+1 queries**: enable `spring.jpa.properties.hibernate.format_sql=true` and watch the logs;
  add `join fetch` / `@EntityGraph`.
- **Properties not picked up**: profile not active, typo in key, or YAML indentation error. Run with
  `--debug` to see the resolved config and active AutoConfigurations.

## 10. Version notes (2026)

- Spring Boot 3.x requires **Java 17+**; Java 21 is the recommended baseline.
- Namespace is **`jakarta.*`** (e.g. `jakarta.persistence.*`, `jakarta.validation.*`), not `javax.*`.
- Avoid the deprecated `spring.factories`; use `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`.

## 11. Spring Cloud microservices

- **Version alignment is mandatory.** The Spring Cloud release train must match the Spring Boot
  version (Spring Boot 3.4 ↔ Spring Cloud 2024.0.x "Murray"; Boot 3.5 ↔ 2025.0.x). Import the BOM via
  `spring-cloud-dependencies` in `<dependencyManagement>` rather than pinning each artifact:

  ```xml
  <dependencyManagement>
    <dependencies>
      <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-dependencies</artifactId>
        <version>2024.0.0</version>
        <type>pom</type>
        <scope>import</scope>
      </dependency>
    </dependencies>
  </dependencyManagement>
  ```

- **Service discovery**: `spring-cloud-starter-netflix-eureka-client` + `@EnableDiscoveryClient`
  (registers with Eureka). In China, **Nacos** is common: `spring-cloud-starter-alibaba-nacos-discovery`
  + `spring.cloud.nacos.discovery.server-addr`.
- **Declarative HTTP (OpenFeign)**: `spring-cloud-starter-openfeign` + `@EnableFeignClients`; define
  `@FeignClient(name = "order-service")`. Pair with `spring-cloud-starter-loadbalancer` for client-side
  load balancing (Ribbon was removed — don't use it).
- **API Gateway**: `spring-cloud-starter-gateway` is WebFlux-based — **do NOT add
  `spring-boot-starter-web`** in the gateway module (port/servlet conflict). Define routes in
  `application.yml` or via a `RouteLocator` bean; use filters for auth / rate limiting.
- **Circuit breaker**: `spring-cloud-starter-circuitbreaker-resilience4j` + `@CircuitBreaker(name="...")`,
  or wire it into Feign via `resilience4j` config; always define timeouts and fallbacks to avoid
  cascading failure.
- **Config**: `spring-cloud-config-client` (Git-backed) or Nacos config
  (`spring-cloud-starter-alibaba-nacos-config`); externalize per-service config, never hard-code env.
- **Observability**: prefer **Micrometer Tracing** (replaces the deprecated Sleuth) for distributed
  tracing across services.

**Top gotcha**: mixing a Cloud train with an incompatible Boot version causes cryptic
`NoSuchMethodError` / `ClassNotFoundException` at startup — always align the release train first.
