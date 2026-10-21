---
name: frontend-testing
description: Front-end testing specialist. Use when writing, reviewing, or fixing tests for React / Vue / TypeScript apps — unit (Vitest), component (React Testing Library / Vue Test Utils), and end-to-end (Playwright / Cypress). Covers the testing pyramid, what to test vs mock, flaky-test fixes, and accessibility assertions.
---

# Front-end Testing

Practical, framework-aware testing guidance for modern SPAs. Pair with the `testing` skill for general strategy and with `frontend-react` / `frontend-vue` for component patterns.

## 1. Pick the right tool for the layer

| Layer | React | Vue 3 | Notes |
|---|---|---|---|
| Unit (pure logic) | **Vitest** | **Vitest** | Fast, Vite-native, `expect` API like Jest |
| Component | **@testing-library/react** | **@vue/test-utils** + **@testing-library/vue** | Query by role/text, not by testid/class |
| E2E | **Playwright** / Cypress | **Playwright** / Cypress | Drive the real browser; few critical paths only |
| Visual | Playwright `--snapshot`, Chromatic | same | Regress UI diffs, not logic |

Default runner is **Vitest** for both unit and component tests (jsdom environment for DOM).

## 2. Testing-library first principles (React & Vue)

- **Query by what the user sees**: `getByRole`, `getByLabelText`, `getByText`, `getByPlaceholderText`. Treat `getByTestId` as a last resort.
- **Don't test implementation**: assert on rendered output and behavior, not on internal state or that a function was called (unless it's the contract).
- **Use `userEvent`** (not `fireEvent`) for realistic events — `userEvent.click`, `userEvent.type`, `userEvent.tab`.
- **`findBy*` for async** (returns a promise, retries). Use `await screen.findByRole('alert')` after a fetch.
- **`act()` / `waitFor`**: wrap state-updating operations; Testing Library does this for userEvent automatically, but manual promises need `await waitFor(...)`.

## 3. React component test template

```tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { UserCard } from './UserCard';

function wrapper({ children }: { children: React.ReactNode }) {
  const qc = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return <QueryClientProvider client={qc}>{children}</QueryClientProvider>;
}

test('shows name and handles follow click', async () => {
  const onFollow = vi.fn();
  render(<UserCard user={{ id: 1, name: 'Ada' }} onFollow={onFollow} />, { wrapper });

  expect(screen.getByRole('heading', { name: 'Ada' })).toBeInTheDocument();

  await userEvent.click(screen.getByRole('button', { name: /follow/i }));
  expect(onFollow).toHaveBeenCalledWith(1);
});
```

## 4. Vue component test template

```ts
import { render, screen } from '@testing-library/vue';
import userEvent from '@testing-library/user-event';
import UserCard from './UserCard.vue';

test('emits follow', async () => {
  const { emitted } = render(UserCard, {
    props: { user: { id: 1, name: 'Ada' } },
  });
  expect(screen.getByRole('heading', { name: 'Ada' })).toBeInTheDocument();
  await userEvent.click(screen.getByRole('button', { name: /follow/i }));
  expect(emitted()).toHaveProperty('follow');
});
```

For Pinia, use `createTestingPinia({ stubActions: false })` and set store state directly. For router, pass `global.plugins` with a memory router.

## 5. What to mock (and what NOT to)

- **Mock**: network layer (MSW — Mock Service Worker — is best, intercepts at fetch/XHR level so the app code is untouched), dates (`vi.useFakeTimers` / `vi.setSystemTime`), random IDs (`vi.mock('./id')`), heavy external SDKs.
- **Don't mock**: React/Vue itself, your store, small pure components, or the component under test's children unnecessarily (use `jest.mock`/`vi.mock` with `spy` only when a child is slow/flaky).
- Prefer **MSW** over mocking `fetch`/`axios` — it keeps the real request path and catches wrong URLs/methods.

## 6. E2E with Playwright — keep it lean

- Cover only **critical user journeys** (login → core action → success). E2E is slow and brittle; don't test every branch here.
- Use `data-testid` sparingly and stable selectors (`getByRole`/`getByLabel`) where possible.
- `await expect(page.getByRole('button', { name: 'Save' })).toBeEnabled()`.
- Run against a **preview build** (`vite build` + `vite preview`) in CI, not dev server.

## 7. Fixing flaky tests

- **Race conditions**: replace `setTimeout`/`Thread.sleep`-style waits with `findBy*` / `waitFor` / `Awaitility`-style polling.
- **Shared state**: reset mocks (`vi.clearAllMocks()`), reset stores (`setActivePinia(createPinia())` per test), reset MSW handlers per test.
- **Fake timers + real promises**: call `await vi.advanceTimersByTimeAsync(ms)` and `await flushMicrotasks()` so microtasks resolve.
- **Animation/portal timing**: in RTL, `await waitForElementToBeRemoved(...)`.
- See `references/testing-recipes.md` for a per-framework recipe list.

## 8. Coverage: behavior over %

- Aim for high coverage on **business logic and reducers/store actions**, moderate on components, low on pure layouts.
- Use coverage thresholds to catch regressions, but never game the number with meaningless assertions.
- Gate PRs on coverage delta, not absolute floor, to avoid noisy failures.

## 9. a11y in tests (cheap wins)

- Assert headings/labels/roles exist (`getByRole('heading')`), keyboard nav works (`userEvent.tab()`), and `aria-invalid` flips on bad input.
- Add `jest-axe` / `vitest-axe` `expect(await axe(container)).toHaveNoViolations()` in a smoke test.
