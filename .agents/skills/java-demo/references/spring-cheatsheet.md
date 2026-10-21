# Spring Boot Cheat Sheet

## Stereotype annotations
| Annotation | Scope | Notes |
|---|---|---|
| `@SpringBootApplication` | main class | `= @Configuration + @EnableAutoConfiguration + @ComponentScan` |
| `@Component` | generic bean | base stereotype |
| `@Service` | business logic | semantic `@Component` |
| `@Repository` | data access | translates persistence exceptions |
| `@Controller` / `@RestController` | web | `@RestController` = `@Controller` + `@ResponseBody` |
| `@Configuration` | config class | defines `@Bean`s |
| `@ConfigurationProperties("app")` | typed props | bind a config subtree to a class |

## Injection & lifecycle
| Annotation | Use |
|---|---|
| `@RequiredArgsConstructor` (Lombok) | constructor injection (preferred) |
| `@Autowired` | avoid; only for constructor (or setter if mandatory=false) |
| `@PostConstruct` / `@PreDestroy` | init / cleanup (or `InitializingBean`) |
| `@Primary` / `@Qualifier` | resolve multiple beans of one type |
| `@Profile("dev")` | bean active only in a profile |
| `@ConditionalOnProperty` | auto-config gated by a property |

## Web / REST
| Annotation | Use |
|---|---|
| `@RequestMapping` | base path/method on controller |
| `@GetMapping @PostMapping @PutMapping @DeleteMapping @PatchMapping` | HTTP verbs |
| `@PathVariable` `@RequestParam` `@RequestBody` | param binding |
| `@Valid` | trigger jakarta validation on a body/param |
| `@ResponseStatus` | set response status |
| `@RestControllerAdvice` + `@ExceptionHandler` | global error handling |

## Data (JPA)
| Annotation | Use |
|---|---|
| `@Entity` `@Table` | map a class to a table |
| `@Id` `@GeneratedValue` | primary key |
| `@Column` `@Transient` | column mapping / exclude |
| `@OneToMany @ManyToOne @ManyToMany` | relationships (prefer `LAZY`) |
| `@EntityGraph` | fetch graph to avoid N+1 |
| `JpaRepository<T, ID>` | CRUD + paging + derived queries |

## Validation (`jakarta.validation`)
`@NotNull @NotEmpty @NotBlank @Size(min,max) @Min @Max @Email @Pattern`
`@Positive @PositiveOrZero @Past @Future` — apply on DTOs, enforce with `@Valid`.

## Common dependencies (Initializr tokens)
`web` `webflux` `data-jpa` `data-mongodb` `jdbc` `mybatis` `validation` `security`
`oauth2-client` `postgresql` `mysql` `h2` `lombok` `actuator` `test`
Add-on: `springdoc-openapi-starter-webmvc-ui` (Swagger UI), `spring-boot-starter-data-redis`.

## test slices
`@SpringBootTest` (full) · `@WebMvcTest` (web) · `@DataJpaTest` (JPA) ·
`@JsonTest` (JSON ser/de) · `@Testcontainers` (real deps in Docker).

## Default property keys (frequent)
`server.port` · `server.servlet.context-path` · `spring.profiles.active` ·
`spring.datasource.url/username/password` · `spring.jpa.hibernate.ddl-auto` ·
`spring.jpa.show-sql` · `logging.level.com.acme=DEBUG` ·
`spring.jpa.properties.hibernate.format_sql=true`.

## MyBatis-Plus (Baomidou, Boot 3 → `mybatis-plus-spring-boot3-starter` 3.5.x)
| Element | Use |
|---|---|
| `@TableName("t_order")` | map entity to table |
| `@TableId(type = IdType.AUTO)` | PK; `ASSIGN_ID` = snowflake |
| `@TableField("col")` / `fill = FieldFill.INSERT` | column mapping / auto-fill |
| `@TableLogic` | logical (soft) delete |
| `BaseMapper<T>` | zero-XML CRUD; scan via `@MapperScan` |
| `IService<T>` + `ServiceImpl<M,T>` | service layer + `page(...)` |
| `LambdaQueryWrapper<T>` | type-safe queries (prefer over string cols) |
| `MybatisPlusInterceptor` + `PaginationInnerInterceptor(DbType.MYSQL)` | enable pagination |
| `MetaObjectHandler` | auto-fill create/update time |

## Spring Cloud (align release train to Boot version!)
| Capability | Starter / token |
|---|---|
| BOM (import in dependencyManagement) | `spring-cloud-dependencies` (e.g. 2024.0.0) |
| Service discovery | `spring-cloud-starter-netflix-eureka-client` (+ `@EnableDiscoveryClient`) |
| Discovery (CN, Nacos) | `spring-cloud-starter-alibaba-nacos-discovery` |
| Declarative HTTP | `spring-cloud-starter-openfeign` (+ `@EnableFeignClients`, `@FeignClient`) |
| Client load balancing | `spring-cloud-starter-loadbalancer` (Ribbon removed) |
| API Gateway | `spring-cloud-starter-gateway` (WebFlux — no `spring-boot-starter-web`) |
| Circuit breaker | `spring-cloud-starter-circuitbreaker-resilience4j` (+ `@CircuitBreaker`) |
| Config server | `spring-cloud-config-client` or `spring-cloud-starter-alibaba-nacos-config` |
| Tracing | Micrometer Tracing (Sleuth deprecated) |

Boot↔Cloud: Boot 3.4 → Cloud 2024.0.x; Boot 3.5 → Cloud 2025.0.x. Mismatched trains → `NoSuchMethodError` at startup.
