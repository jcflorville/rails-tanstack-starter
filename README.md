<div align="center">

# rails-tanstack-starter

[![CI](https://github.com/jcflorville/rails-tanstack-starter/actions/workflows/ci.yml/badge.svg)](https://github.com/jcflorville/rails-tanstack-starter/actions/workflows/ci.yml)
[![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?logo=rubyonrails&logoColor=white)](https://rubyonrails.org)
[![Ruby](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white)](https://www.ruby-lang.org)
[![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-6-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-4-06B6D4?logo=tailwindcss&logoColor=white)](https://tailwindcss.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

A production-ready monorepo starter for SaaS products — **Rails 8 API** backend + **Vite/React/TypeScript** frontend with TanStack Router & Query, fully dockerized and deployable to a single VPS via Kamal 2.

[Overview](#overview) • [What's included](#whats-included) • [Quick start](#quick-start) • [Running tests](#running-tests) • [Deploy](#deploy)

</div>

---

## Overview

Starting a new SaaS from scratch means wiring up the same things every time: auth, API conventions, error handling, CI, deploy config. This template eliminates that setup so you can focus on your product.

It follows a clean separation of concerns — the Rails API and the React frontend are independent apps that share nothing except HTTP. Both live in the same repository and are orchestrated together with Docker Compose for local development.

```
apps/
├── web/   # Vite + React + TypeScript frontend
└── api/   # Rails 8 API (API mode)
```

> [!NOTE]
> This is a template repository, not a framework. It gives you a solid, opinionated starting point that you own entirely — no lock-in, no magic.

## What's included

### Authentication

- Sign up, sign in, sign out — fully wired end to end
- Password reset via time-limited email tokens
- Session-based auth with HttpOnly cookies (no JWT, no token storage on the client)
- `Current.user` pattern for accessing the authenticated user in controllers and services

### API layer (Rails)

- Versioned REST endpoints under `/api/v1/`
- Thin controllers — all business logic lives in service objects
- [Blueprinter](https://github.com/procore-oss/blueprinter) serializers — controllers never render raw models
- Centralized error handling in `BaseController`:
  - `ActiveRecord::RecordNotFound` → `404 Not Found`
  - `ActionController::ParameterMissing` → `400 Bad Request`
  - `ActiveRecord::RecordInvalid` → `422 Unprocessable Content`
- CORS configured for session cookie auth (explicit origin, `credentials: true`, no wildcards)
- Rate limiting via [Rack::Attack](https://github.com/rack/rack-attack) — login and password reset endpoints throttled out of the box, plus a per-IP safety net

### Frontend (React)

- File-based routing with [TanStack Router](https://tanstack.com/router)
- Data fetching and caching with [TanStack Query](https://tanstack.com/query)
- Feature-based folder structure — co-located components, hooks, and API hooks per feature
- [shadcn/ui](https://ui.shadcn.com/) component primitives on Tailwind CSS v4
- Strict TypeScript — no `any`, full type coverage on API responses

### Developer experience

- **Docker Compose** — one command to start Postgres, the API (with hot reload), and the frontend (with HMR)
- **Pre-push hook** — lints only changed files for fast feedback (~10–30s), not the whole codebase
- **GitHub Actions CI** — two parallel jobs on every push and PR:
  - Backend: RuboCop · Brakeman · bundler-audit · RSpec
  - Frontend: ESLint · Prettier · TypeScript · Vitest
- **Dependabot** — weekly grouped PRs for gems, npm packages, and GitHub Actions
- **AGENTS.md / CLAUDE.md** — machine-readable project spec for AI-assisted development

## Quick start

> [!IMPORTANT]
> All commands run inside Docker containers. Do not run `rails`, `bundle`, or `pnpm` directly on the host — use `docker compose exec` to ensure the right runtime versions are used.

### 1. Use this template

Click **Use this template** on GitHub, or clone directly:

```bash
git clone https://github.com/jcflorville/rails-tanstack-starter.git my-app
cd my-app
```

### 2. Replace placeholders

Search and replace these tokens across the entire repo:

| Placeholder         | Description                        | Example                  |
| ------------------- | ---------------------------------- | ------------------------ |
| `{{PROJECT_NAME}}`  | kebab-case project name            | `my-app`                 |
| `{{WEB_DOMAIN}}`    | frontend domain                    | `app.example.com`        |
| `{{API_DOMAIN}}`    | API domain                         | `api.example.com`        |
| `{{VPS_IP}}`        | production server IP               | `123.45.67.89`           |
| `{{REGISTRY}}`      | container registry                 | `ghcr.io`                |
| `{{REGISTRY_USER}}` | registry username                  | `your-github-username`   |

### 3. Set up git hooks

```bash
git config core.hooksPath .githooks
```

### 4. Copy environment files

```bash
cp apps/api/.env.example apps/api/.env
cp apps/web/.env.example apps/web/.env
```

### 5. Start the stack

```bash
docker compose up
```

| Service  | URL                       |
| -------- | ------------------------- |
| Frontend | http://localhost:5173     |
| API      | http://localhost:3000     |

### 6. Seed the database

```bash
docker compose exec api rails db:seed
# Creates: test@example.com / password
```

You're ready. Visit http://localhost:5173, sign in, and start building.

## Running tests

```bash
# Backend — RSpec
docker compose exec api bundle exec rspec

# Frontend — Vitest
docker compose exec web pnpm test
```

> [!TIP]
> Run linting and security scans locally before pushing to catch issues before CI does:
> ```bash
> docker compose exec api bundle exec rubocop
> docker compose exec api bundle exec brakeman -q
> docker compose exec api bundler-audit check --update
> docker compose exec web pnpm lint
> docker compose exec web pnpm type-check
> ```

## Deploy

This template is configured for [Kamal 2](https://kamal-deploy.org/) deployment to a single VPS. Both apps deploy as separate containers on the same server — the frontend (Nginx) serves the React static build, the API (Rails + Thruster) runs behind Kamal's built-in proxy with SSL via Let's Encrypt.

**First-time setup:**

```bash
# API
cd apps/api && kamal setup

# Frontend (from repo root)
kamal setup -c apps/web/config/deploy.yml
```

**Deploy:**

```bash
# API
cd apps/api && kamal deploy

# Frontend (from repo root)
kamal deploy -c apps/web/config/deploy.yml
```

> [!NOTE]
> Database migrations run automatically on every API deploy via `bin/docker-entrypoint`. No manual migration step needed.

See [CLAUDE.md](./CLAUDE.md) for the full list of Kamal commands, secrets setup, and architecture details.

## Contributing

Contributions are welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the workflow, and the [Code of Conduct](./CODE_OF_CONDUCT.md) for community guidelines.

For security vulnerabilities, please follow the responsible disclosure process in [SECURITY.md](./SECURITY.md) — do not open a public issue.
