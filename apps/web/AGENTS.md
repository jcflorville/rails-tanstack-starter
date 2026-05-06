# Web — Vite + React

> Frontend app for the `{{PROJECT_NAME}}` monorepo. This file documents web-specific patterns. For monorepo-wide context (architecture principles, Docker, CI, deploy, git workflow, auth strategy), see the root [`AGENTS.md`](../../AGENTS.md). `CLAUDE.md` in this directory is a symlink to this file.

## Overview

Single-page React app built with Vite. Routing via TanStack Router (file-based), data layer via TanStack Query. Tailwind CSS v4 + shadcn/ui (Radix primitives) for UI. TypeScript strict mode. Talks to the Rails API at `/api/v1/` over fetch with `credentials: 'include'`.

## Tech Stack

| Concern    | Tool                                |
| ---------- | ----------------------------------- |
| Build      | Vite                                |
| Framework  | React 19 + TypeScript (strict)      |
| Router     | TanStack Router (file-based)        |
| Data Layer | TanStack Query                      |
| UI         | Tailwind CSS + shadcn/ui (Radix UI) |
| Testing    | Vitest + Testing Library            |
| Linting    | ESLint + Prettier                   |

## Directory Layout

```
apps/web/
├── src/
│   ├── components/        # Shared/global components (shadcn/ui customizations)
│   ├── features/          # Feature modules — group by feature, not by type
│   │   └── <feature>/
│   │       ├── components/
│   │       ├── hooks/
│   │       └── api.ts     # TanStack Query hooks for this feature
│   ├── hooks/             # Shared hooks
│   ├── lib/
│   │   ├── api-client.ts  # Fetch wrapper for /api/v1/ with credentials: 'include'
│   │   └── utils.ts
│   ├── routes/            # TanStack Router file-based routes
│   └── styles/            # Global styles
├── Dockerfile
├── nginx.conf             # Nginx config for production container
├── vite.config.ts
├── tailwind.config.ts
└── tsconfig.json
```

## Frontend Patterns

### Feature-Based Organization

Group code by feature, not by type. Shared code lives at the top level (`components/`, `hooks/`, `lib/`). A feature folder is self-contained: components, hooks, and `api.ts` for that domain.

```
src/features/users/
├── components/
│   ├── user-list.tsx
│   └── user-form.tsx
├── hooks/
│   └── use-current-user.ts
└── api.ts
```

### API Layer (TanStack Query)

Each feature has an `api.ts` file with query/mutation hooks. Components consume hooks, never call `apiClient` directly.

```typescript
// src/features/users/api.ts
import { useMutation, useQuery } from "@tanstack/react-query"
import { apiClient } from "@/lib/api-client"

export function useUsers() {
  return useQuery({
    queryKey: ["users"],
    queryFn: () => apiClient.get<User[]>("/users"),
  })
}

export function useCreateUser() {
  return useMutation({
    mutationFn: (data: CreateUserInput) => apiClient.post<User>("/users", data),
  })
}
```

### Components

- Functional components only.
- shadcn/ui as base components, customized as needed (don't fork unless necessary).
- Co-locate component-specific logic (hooks, types) with the component.
- Props interfaces defined in the same file as the component.
- Keep components small. If a component does loading + error + empty + data states, split when it gets unwieldy.

### TypeScript

- Strict mode enabled.
- No `any` — use `unknown` if the type is truly unknown, then narrow.
- Prefer type inference where the type is obvious.
- Define API response types that match the Blueprinter serializer output on the backend.

### Responsive Design

Mobile-first is mandatory. See the Responsive Design section in the root `AGENTS.md` for the full rules. Quick checklist:

- Design at 375px first, then add `sm:` / `md:` / `lg:` overrides.
- Touch targets ≥ 44×44px (`min-h-11` or `p-3`).
- No horizontal scroll except intentional carousels.
- Use `max-w-*` + `w-full` instead of fixed pixel widths.

## Testing (Vitest + Testing Library)

Test behavior, not implementation. Select elements the way a user would (by role, label, text) — never by class or internal state.

**What to test:**

- Custom hooks with real logic (auth, data fetching).
- Components with conditional behavior (loading/error states, form validation).
- Critical user flows (login, signup, data submission).

**What NOT to test:**

- Purely visual/static components.
- shadcn/ui internals.
- CSS or layout details.

**Test file location:** co-locate with the file under test. `login-form.test.tsx` next to `login-form.tsx`. `api.test.tsx` next to `api.ts`.

### Required patterns

Every test that uses TanStack Query needs a `QueryClientProvider` wrapper. Always disable retries in tests to avoid timeouts:

```typescript
function renderWithQuery(ui: React.ReactElement) {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false }, mutations: { retry: false } },
  })
  return render(<QueryClientProvider client={queryClient}>{ui}</QueryClientProvider>)
}
```

Mock `apiClient` using `importOriginal` to preserve `ApiError`:

```typescript
vi.mock("@/lib/api-client", async (importOriginal) => {
  const actual = await importOriginal<typeof import("@/lib/api-client")>()
  return { ...actual, apiClient: { post: vi.fn(), get: vi.fn() } }
})
```

Mock `@tanstack/react-router` when a component calls `useRouter()`:

```typescript
const mockNavigate = vi.fn()
vi.mock("@tanstack/react-router", () => ({
  useRouter: () => ({ navigate: mockNavigate }),
  Link: ({ children, to }: { children: React.ReactNode; to: string }) => (
    <a href={to}>{children}</a>
  ),
}))
```

## Authentication (client-side details)

Session-based auth via HttpOnly cookies. See the root `AGENTS.md` for the cross-cutting strategy.

**Client-side specifics:**

- `apiClient` is configured with `credentials: 'include'` — cookies flow automatically on every request.
- No token storage, no auth headers, no refresh logic. Don't add any.
- To check auth state, call `GET /api/v1/me` (typically wrapped in a `useCurrentUser()` hook).
- On `401`, redirect to login. Don't try to "refresh" — there's nothing to refresh.

## Common Commands

All commands run inside the Docker container — never on the host.

```bash
# Dev server (already running if `docker compose up` is up)
docker compose up web

# Tests
docker compose exec web pnpm test
docker compose exec web pnpm test -- src/features/auth

# Lint + type check (run before pushing)
docker compose exec web pnpm lint
docker compose exec web pnpm type-check

# Install / update dependencies
docker compose run --rm web pnpm install
docker compose run --rm web pnpm add <package>

# Build (sanity-check the production bundle)
docker compose exec web pnpm build
```

## Deploy

Deploy is managed via Kamal. From the project root:

```bash
kamal deploy -c apps/web/config/deploy.yml
```

See the Deploy section in the root `AGENTS.md` for full details.
