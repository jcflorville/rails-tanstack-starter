# {{PROJECT_NAME}} — Monorepo

> This file is the project's authoritative spec for collaborating with AI coding agents (Claude Code, Codex, Cursor, Aider, etc.) and humans. `CLAUDE.md` is a symlink to this file. Replace `{{PROJECT_NAME}}`, `{{WEB_DOMAIN}}`, `{{API_DOMAIN}}`, `{{VPS_IP}}`, and `{{REGISTRY}}` with real values when bootstrapping a new project from this template.

## Project Overview

A monorepo with a decoupled frontend and backend, fully dockerized for local development and deployed via Kamal 2 to a single VPS.

## Tech Stack

| Layer    | Technology                                          |
| -------- | --------------------------------------------------- |
| Frontend | Vite + React + TypeScript + TanStack Router & Query |
| UI       | Tailwind CSS + shadcn/ui (Radix UI)                 |
| Backend  | Ruby on Rails 8 (API mode)                          |
| Auth     | Rails 8 built-in authentication (session cookies)   |
| Database | PostgreSQL                                          |
| Jobs     | Solid Queue                                         |
| API      | Versioned REST (`/api/v1/`)                         |
| Monorepo | pnpm workspaces + Docker Compose (local)            |
| Deploy   | Kamal 2 → VPS                                       |
| Testing  | RSpec (backend) + Vitest (frontend)                 |
| CI       | GitHub Actions                                      |
| Linting  | RuboCop + Brakeman + bundler-audit + ESLint         |

## Monorepo Structure

```
{{PROJECT_NAME}}/
├── apps/
│   ├── web/                  # Frontend - Vite + React  (see apps/web/AGENTS.md)
│   └── api/                  # Backend  - Rails 8 API   (see apps/api/AGENTS.md)
├── .github/workflows/ci.yml  # GitHub Actions CI pipeline
├── docker-compose.yml        # Local dev orchestration
├── pnpm-workspace.yaml
├── package.json
└── AGENTS.md                 # ← you are here (CLAUDE.md is a symlink)
```

## Per-App Guidance

When working inside a specific app, read its local `AGENTS.md` for app-specific patterns:

- **`apps/api/AGENTS.md`** — Rails patterns: service objects, controllers, Blueprinter serializers, RSpec.
- **`apps/web/AGENTS.md`** — React patterns: feature-based organization, TanStack Query, components, Vitest.

This root file covers everything cross-cutting (architecture, auth strategy, Docker, CI, deploy, git workflow).

Per-app contexts are auto-loaded from this file so they are available regardless of which directory the agent session starts in:

@apps/api/AGENTS.md
@apps/web/AGENTS.md

## Language

All code, comments, variable names, commit messages, branch names, documentation, and API responses MUST be written in English — regardless of the language used in conversation. This is a strict standard with no exceptions.

## Architecture & Design Principles

### SOLID (as a guide, not rigid dogma)

Apply SOLID principles pragmatically. They should improve code clarity and maintainability, not add unnecessary abstraction.

- **S - Single Responsibility**: Each class/module/component does one thing well. A service handles one business operation. A component renders one UI concern.
- **O - Open/Closed**: Prefer extending behavior over modifying existing code. Use composition in React, and inheritance/modules in Ruby when it makes sense.
- **I - Interface Segregation**: Keep interfaces small and focused. In Rails, don't bloat models with unrelated concerns. In React, keep prop interfaces tight.
- **L - Liskov Substitution**: Subclasses should be interchangeable with their parent. In practice: don't override methods in ways that break expectations.
- **D - Dependency Inversion**: Depend on abstractions when beneficial. Services receive dependencies instead of hardcoding them — but don't over-engineer simple cases.

**Rule of thumb**: If applying a SOLID principle adds more complexity than it removes, skip it. Three simple lines beat one clever abstraction.

### Development Workflow: Test-Driven Development (TDD)

Every new feature must start with tests before writing implementation code. Follow the Red-Green-Refactor cycle:

1. **Red** — Write failing tests that define the expected behavior
2. **Green** — Write the minimum code to make the tests pass
3. **Refactor** — Clean up the code while keeping tests green

**In practice:**

For a backend feature (e.g., new endpoint):

1. Write request specs (`spec/requests/api/v1/`) defining the API contract
2. Write service specs (`spec/services/`) defining the business logic
3. Write model specs if new models/validations are needed
4. Implement the code to make all tests pass

For a frontend feature (e.g., new page/component):

1. Write component/integration tests with Vitest + Testing Library
2. Implement the component to make tests pass

**Never skip this order.** Tests are not an afterthought — they define the feature.

### General Coding Guidelines

- Write simple, readable code. Prefer clarity over cleverness.
- Don't add abstractions for hypothetical future needs. Solve today's problem.
- Don't add error handling for scenarios that can't happen.
- Only validate at system boundaries (user input, external APIs).
- No comments unless the logic is genuinely non-obvious.

### Responsive Design (Mobile-First)

Every UI component and page must be designed mobile-first. The app is intended to be used on mobile browsers and may evolve into a native mobile app — responsive quality directly impacts that future.

**Rules:**

- Always design for mobile first, then scale up with `sm:`, `md:`, `lg:` breakpoints
- No fixed widths that break on small screens — use `max-w-*` with `w-full`
- Touch targets must be at least 44×44px (use `min-h-11` or `p-3` on interactive elements)
- Navigation must be usable on mobile — use a hamburger/sheet pattern when items don't fit
- Horizontal scrolling is never acceptable (except intentional carousels)
- Test every new page at 375px (iPhone SE) and 390px (iPhone 14) widths
- Prefer `px-4` on mobile containers, `px-6` from `sm:` upward

## Authentication

### Strategy: Session-based with HttpOnly Cookies

The API uses Rails 8 built-in authentication with session cookies — not JWT.

**Why cookies over JWT:**

- HttpOnly + Secure + SameSite cookies are not accessible via JavaScript (XSS-proof)
- No token refresh logic needed — sessions renew automatically
- Real logout — destroying the server-side session invalidates access immediately
- Rails 8 auth generator works this way out of the box

**Frontend setup:**

- API client configured with `credentials: 'include'` so cookies are sent automatically
- No token storage, no auth headers to manage manually
- TanStack Query works normally — auth is transparent at the HTTP level

**Backend setup:**

- CORS configured with `credentials: true` and explicit origin (no wildcards)
- Session stored server-side (default Rails session store)
- `Current.user` pattern for accessing the authenticated user in controllers/services

**Auth flow:**

1. `POST /api/v1/session` — login (sets session cookie)
2. `DELETE /api/v1/session` — logout (destroys session)
3. `GET /api/v1/me` — returns current user (used by frontend to check auth state)

## CI/CD

### GitHub Actions

Two parallel jobs on every push/PR:

**Backend job (`apps/api/`):**

1. `bundle exec rubocop` — code style and lint
2. `bundle exec brakeman -q` — security static analysis
3. `bundler-audit check --update` — dependency vulnerability scan
4. `bundle exec rspec` — test suite

**Frontend job (`apps/web/`):**

1. `pnpm lint` — ESLint + Prettier check
2. `pnpm type-check` — TypeScript strict compilation
3. `pnpm test` — Vitest test suite

**Rules:**

- All checks must pass before merging to `main`
- CI runs on: push to `main`, all pull requests
- Backend job uses a PostgreSQL service container for RSpec
- Cache: bundle gems + pnpm store cached between runs

### Security Scanning

- **RuboCop**: Ruby style + lint (runs in CI and locally)
- **Brakeman**: Static analysis for Rails security vulnerabilities (SQL injection, XSS, mass assignment, etc.)
- **bundler-audit**: Checks Gemfile.lock for known vulnerable gem versions
- Run all three locally before pushing: `docker compose exec api bash -c "bundle exec rubocop && bundle exec brakeman -q && bundler-audit check"`

## Docker

### Local Development (docker-compose.yml)

- **api**: Rails 8 with hot reload (mounted volume)
- **web**: Vite dev server with HMR (mounted volume)
- **postgres**: PostgreSQL with persistent volume
- Frontend proxies API requests to the api container

### Production (Kamal)

- **api**: Rails 8 behind Kamal's built-in proxy (Thruster)
- **web**: Nginx serving Vite's static build output
- Kamal manages both as accessories/services on the VPS
- SSL via Let's Encrypt (Kamal handles this)

## Commands

**IMPORTANT:** All commands must run inside Docker containers. Do NOT run Rails, bundle, or pnpm commands directly on the host machine. The host may have different versions or missing dependencies. Docker is the single source of truth for the runtime environment.

### Local Development

```bash
# Start all services
docker compose up

# Start specific service
docker compose up web
docker compose up api

# Install frontend dependencies
docker compose run --rm web pnpm install

# Install backend dependencies
docker compose run --rm api bundle install

# Run backend tests
docker compose exec api bundle exec rspec

# Run frontend tests
docker compose exec web pnpm test

# Run backend linting/security
docker compose exec api bundle exec rubocop
docker compose exec api bundle exec brakeman -q
docker compose exec api bundler-audit check --update

# Run frontend linting/type check
docker compose exec web pnpm lint
docker compose exec web pnpm type-check

# Rails console
docker compose exec api rails console

# Rails generators
docker compose exec api rails generate model User name:string email:string
docker compose exec api rails generate migration AddFieldToTable

# Database operations
docker compose exec api rails db:create
docker compose exec api rails db:migrate
docker compose exec api rails db:seed
docker compose exec api rails db:rollback
```

### Deploy (Kamal)

**Production URLs (replace placeholders for the actual project):**

- Frontend: `https://{{WEB_DOMAIN}}`
- API: `https://{{API_DOMAIN}}`
- VPS IP: `{{VPS_IP}}`
- Registry: `{{REGISTRY}}` (e.g. `ghcr.io`)

**Architecture:** Two separate containers on the same VPS. The frontend (Nginx) serves the React static build. The API (Rails + Thruster) runs separately. Session cookies use `SameSite=None; Secure` for cross-origin auth.

**Secrets files (never committed, local only):**

- API: `apps/api/.kamal/secrets`
- Frontend: `.kamal/secrets` (project root)

**Migrations run automatically** on every deploy via `bin/docker-entrypoint` (`db:prepare`).

```bash
# First-time server setup
cd apps/api && kamal setup
kamal setup -c apps/web/config/deploy.yml  # run from project root

# Deploy API (run from apps/api/)
cd apps/api
kamal deploy

# Deploy frontend (run from project root)
kamal deploy -c apps/web/config/deploy.yml

# Force rebuild without cache
kamal build push --no-cache && kamal deploy

# Logs (real-time)
kamal logs -f

# Rails console in production
kamal console

# Postgres accessory
kamal accessory boot db      # start if stopped
kamal accessory details db   # status
```

## Git Workflow (GitHub Flow)

The `main` branch is always deployable. All work happens in feature branches via Pull Requests.

**Before writing any code or starting any implementation, always check the current branch with `git branch --show-current`. If on `main`, stop and create a feature branch first. Never implement features or write code directly on `main`.**

### Feature workflow

```bash
# 1. Create branch from main
git checkout main
git pull
git checkout -b feature/user-auth

# 2. Develop with TDD (tests first, then implementation)

# 3. Push branch (pre-push hook runs lint checks automatically)
git push -u origin feature/user-auth

# 4. Open PR
gh pr create

# 5. CI runs automatically on the PR (full test suite)
# 6. Merge only when CI is green
```

### Pre-push hook (local checks)

A lightweight pre-push hook runs automatically before each push. It checks **only changed files** for fast feedback (~10-30s):

- **Ruby files**: RuboCop (style/lint)
- **TypeScript files**: type check + ESLint

The hook runs on the host machine (not Docker) for speed. Full checks (RSpec, Vitest, Brakeman, bundler-audit) run in CI.

**Setup** (required once after cloning):

```bash
git config core.hooksPath .githooks
```

### Branch naming

- `feature/` — new features
- `fix/` — bug fixes
- `chore/` — maintenance, dependencies, config

## Conventions

- Commit messages: conventional commits (`feat:`, `fix:`, `chore:`, `refactor:`)
- Ruby style: follow `.rubocop.yml` config
- TypeScript style: ESLint + Prettier
- API responses: always use Blueprinter serializers, never render raw models
- API errors: consistent format `{ errors: [...] }` or `{ error: "message" }`
- Database: use migrations for all schema changes, never edit schema.rb manually
