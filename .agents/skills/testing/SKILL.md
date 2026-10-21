---
name: testing
description: Testing assistant for backend code. Use when writing unit tests, integration tests, mocks/stubs/fakes, test fixtures, or setting up test strategy (test pyramid, TDD, contract tests, Testcontainers). Covers JUnit 5, Mockito, AssertJ, Spring Boot test slices, and flaky-test fixes.
metadata:
  short-description: Unit, integration & strategy testing
---

# Testing

Practical testing for backend code. A recipe sheet is in `references/testing-recipes.md`.

## When to use

- Writing a test for a method, service, controller, or repository.
- Deciding what/how much to test; choosing mock vs real dependencies.
- Fixing flaky tests; setting up Testcontainers or contract tests.

## Test pyramid (most → least)

- **Many unit tests** (fast, isolated) — pure logic; services with mocks.
- **Some integration tests** — Spring Boot slices (`@WebMvcTest`, `@DataJpaTest`) or full
  `@SpringBootTest` with Testcontainers.
- **Few end-to-end** — only the critical user journeys.

## JUnit 5 + Mockito + AssertJ

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    @Mock OrderRepository repo;
    @InjectMocks OrderService service;

    @Test
    void createsOrderAndPersists() {
        when(repo.save(any())).thenAnswer(inv -> inv.getArgument(0));
        OrderDto dto = service.create(new CreateOrder("A1", 2));
        assertThat(dto.code()).isEqualTo("A1");
        verify(repo).save(any(Order.class));
    }
}
```

- Prefer `@InjectMocks` + `@Mock` over manual `new`; use `MockitoExtension`.
- Assert with **AssertJ** (`assertThat(...).isEqualTo(...)`) — readable.
- `verify(repo).save(...)` checks interaction; only verify behavior that matters.

## Mock vs stub vs fake

- **Stub**: returns canned data (`when(...).thenReturn(...)`).
- **Mock**: also verifies calls happened (`verify(...)`).
- **Fake**: a lightweight real implementation (e.g. in-memory repo) — often better than mocks for
  behavior.
- Don't over-mock what you don't own; prefer testing real boundaries with Testcontainers.

## Spring Boot test slices (fast, focused context)

- `@WebMvcTest(Controller.class)` — web layer only; `@MockBean` the service.
- `@DataJpaTest` — JPA/repo only, embedded or Testcontainers DB.
- `@SpringBootTest` — full context (use for wiring/smoke, not every test; slow).
- `@Testcontainers` + `@Container` Postgres for realistic integration tests.

## Edge cases worth testing

- Null / empty / boundary inputs; invalid IDs (404); concurrency; inject a `Clock` for time;
  exceptions & rollback; idempotency of retries.

## Flaky-test fixes

- No shared mutable state between tests; reset with `@BeforeEach`.
- Don't depend on real time/network/order; use deterministic inputs.
- Use `awaitility` for async instead of fixed `Thread.sleep`.
- Quarantine (don't delete) flaky tests while fixing.

## Gotchas

- 100% coverage ≠ good tests; test **behavior**, not implementation lines.
- Over-mocking → tests that pass but miss real bugs; let integration tests cover the seams.
- `Thread.sleep` in tests = flakiness; prefer `Awaitility` or virtual time.
