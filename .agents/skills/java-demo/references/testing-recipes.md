# Testing Recipes

## Web layer slice (`@WebMvcTest`)
```java
@WebMvcTest(OrderController.class)
class OrderControllerTest {
    @Autowired MockMvc mvc;
    @MockBean OrderService service;

    @Test void returns404WhenMissing() throws Exception {
        when(service.getById(99L)).thenThrow(new OrderNotFound(99L));
        mvc.perform(get("/api/orders/99")).andExpect(status().isNotFound());
    }
}
```

## JPA slice (`@DataJpaTest` + Testcontainers)
```java
@DataJpaTest
@Testcontainers
class OrderRepositoryTest {
    @Container static PostgreSQLContainer<?> db =
        new PostgreSQLContainer<>("postgres:16").withReuse(true);
    @Autowired OrderRepository repo;

    @Test void savesAndReads() {
        Order o = repo.save(new Order("A1"));
        assertThat(repo.findById(o.getId())).contains(o);
    }
}
```

## Full context (`@SpringBootTest`)
```java
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
class OrderApiIT {
    @Autowired TestRestTemplate rest;
    @Test void health() { assertThat(rest.getForEntity("/actuator/health", String.class)
        .getStatusCode()).isEqualTo(HttpStatus.OK); }
}
```

## Mockito patterns
```java
when(repo.findById(1L)).thenReturn(Optional.of(order));   // stub
when(repo.save(any())).thenThrow(new RuntimeException()); // exception path
doNothing().when(mailer).send(any());                     // void method
verify(service, times(1)).notify(any());                  // verify call count
verify(mailer, never()).send(any());                      // negative
```

## Time & async
```java
// inject Clock instead of LocalDateTime.now() for determinism
when(clock.instant()).thenReturn(Instant.parse("2026-01-01T00:00:00Z"));

// async without flaky sleep
await().atMost(Duration.ofSeconds(5)).until(() -> fut.isDone());
```

## AssertJ essentials
```java
assertThat(list).hasSize(3).containsExactlyInAnyOrder(a, b, c);
assertThat(opt).isPresent().get().extracting(Order::code).isEqualTo("A1");
assertThatThrownBy(() -> service.create(null)).isInstanceOf(IllegalArg.class);
```

## Layering and suite boundaries

Match the test layer to the question. Keep many fast plain-JUnit unit tests, focused Spring slices, fewer real-boundary integration tests, and only a small number of full HTTP end-to-end tests. Never mock the class under test; prefer mocking an application-owned adapter over mocking third-party clients directly.

- Unit: pure business logic and branching, with dependencies mocked or stubbed.
- Slice: `@WebMvcTest` for binding/validation/mapping, `@DataJpaTest` for repository behavior, and `@JsonTest` for serialization.
- Integration: `@SpringBootTest` with the real database or external boundary, commonly Testcontainers; keep it out of the fast unit command.
- End-to-end: critical user journeys that verify security, serialization, and the real HTTP path.

Use deterministic `Clock`/time and bounded polling instead of sleeps. Name container-backed tests distinctly (for example `*IT`) when the build separates unit and integration phases. For framework migrations, verify the project's actual Spring Boot line before choosing version-specific annotations such as `@MockitoBean`.
