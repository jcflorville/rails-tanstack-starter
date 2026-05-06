# {{PROJECT_NAME}}

A production-ready monorepo template for building SaaS products with a Rails 8 API backend and a Vite + React + TypeScript frontend. Fully dockerized for local development and deployed to a single VPS via Kamal 2.

## Stack

| Layer     | Technology                                           |
| --------- | ---------------------------------------------------- |
| Frontend  | Vite + React 19 + TypeScript + TanStack Router/Query |
| UI        | Tailwind CSS v4 + shadcn/ui (Radix UI)               |
| Backend   | Ruby on Rails 8 (API mode)                           |
| Auth      | Session cookies (Rails 8 built-in)                   |
| Database  | PostgreSQL                                           |
| Jobs      | Solid Queue                                          |
| Deploy    | Kamal 2 → single VPS (SSL via Let's Encrypt)         |
| Testing   | RSpec + Vitest                                       |
| CI        | GitHub Actions                                       |

## What's included

**Authentication (ready to use)**
- Sign up, sign in, sign out
- Password reset via email token
- Session-based auth with HttpOnly cookies — no JWT, no token storage
- `Current.user` pattern throughout the API

**API conventions**
- Versioned REST endpoints (`/api/v1/`)
- Blueprinter serializers — controllers never render raw models
- Service objects for business logic — controllers stay thin
- Centralized error handling: `RecordNotFound` → 404, `ParameterMissing` → 400, `RecordInvalid` → 422

**Developer experience**
- Docker Compose for local dev with hot reload on both frontend and backend
- Pre-push git hook — lints only changed files (~10–30s feedback loop)
- GitHub Actions CI — RuboCop, Brakeman, bundler-audit, RSpec, ESLint, Prettier, Vitest
- CLAUDE.md — machine-readable spec for AI-assisted development

## Layout

```
apps/
├── web/   # Vite + React + TypeScript frontend
└── api/   # Rails 8 API
```

See [`CLAUDE.md`](./CLAUDE.md) for full architecture, conventions, and commands.

## Quick start

**1. Replace placeholders** across the repo (search and replace):

| Placeholder        | Example value          |
| ------------------ | ---------------------- |
| `{{PROJECT_NAME}}` | `my-app`               |
| `{{WEB_DOMAIN}}`   | `app.example.com`      |
| `{{API_DOMAIN}}`   | `api.example.com`      |
| `{{VPS_IP}}`       | `123.45.67.89`         |
| `{{REGISTRY}}`     | `ghcr.io`              |
| `{{REGISTRY_USER}}`| `your-github-username` |

**2. Set up git hooks** (once, after cloning):

```bash
git config core.hooksPath .githooks
```

**3. Copy environment files:**

```bash
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env
```

**4. Start the stack:**

```bash
docker compose up
```

- Frontend: [http://localhost:5173](http://localhost:5173)
- API: [http://localhost:3000](http://localhost:3000)

**5. Seed the database** (creates a test user):

```bash
docker compose exec api rails db:seed
# test@example.com / password
```

## Running tests

```bash
# Backend
docker compose exec api bundle exec rspec

# Frontend
docker compose exec web pnpm test
```

## Deploy

See the [Kamal deploy section in CLAUDE.md](./CLAUDE.md#deploy-kamal) for first-time server setup and deploy commands.
