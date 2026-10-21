# Front-end Testing Recipes

## Vitest config (both frameworks)
```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
export default defineConfig({
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./src/test/setup.ts'],
    css: true,
  },
});
```
`src/test/setup.ts`: `import '@testing-library/jest-dom'` (React) + `vi.mock` globals + MSW `server.listen()`.

## Mock Service Worker (MSW) — network in tests
```ts
// src/test/server.ts
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';
export const server = setupServer(
  http.get('/api/user', () => HttpResponse.json({ id: 1, name: 'Ada' })),
  http.post('/api/follow/:id', ({ params }) => HttpResponse.json({ ok: true })),
);
```
setup: `beforeAll(() => server.listen()); afterEach(() => server.resetHandlers()); afterAll(() => server.close());`

## Pinia test setup (Vue)
```ts
import { setActivePinia, createPinia } from 'pinia';
import { createTestingPinia } from '@pinia/testing';
beforeEach(() => setActivePinia(createPinia()));
// or: const pinia = createTestingPinia({ stubActions: false, initialState: { cart: { items: [] } } });
```

## React Query test setup
```ts
const qc = new QueryClient({ defaultOptions: { queries: { retry: false }, mutations: { retry: false } } });
render(<App />, { wrapper: ({ children }) => <QueryClientProvider client={qc}>{children}</QueryClientProvider> });
```

## Flaky-test quick fixes
- Async UI → `await screen.findByRole(...)` / `await waitFor(...)`.
- Timers → `vi.useFakeTimers(); await vi.advanceTimersByTimeAsync(1000); await vi.restoreAllTimers();`
- Shared state → `vi.clearAllMocks()` + `setActivePinia(createPinia())` + `server.resetHandlers()` in `afterEach`.
- Stale resolve → `await waitFor(() => expect(...).toBeTruthy())` instead of fixed sleeps.

## a11y assertion (vitest-axe)
```ts
import { axe } from 'vitest-axe';
test('no violations', async () => {
  const { container } = render(<Form />);
  expect(await axe(container)).toHaveNoViolations();
});
```

## Playwright critical path (lean)
```ts
test('sign in and save', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('a@b.co');
  await page.getByLabel('Password').fill('pw');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
});
```
Run against `vite preview` (built bundle), not dev server.
