# Contributing

Thanks for your interest in contributing! This is an open-source template, and contributions of all sizes are welcome — bug fixes, documentation improvements, new patterns, or feedback on the developer experience.

## Before you start

- For **bug fixes** and small improvements, feel free to open a PR directly.
- For **new features** or anything that changes the public template surface (auth flow, API conventions, deploy setup), please open an issue first so we can discuss the direction.

## Development setup

1. Fork and clone the repo.
2. Install Docker Desktop (or another OCI-compatible runtime).
3. Set up the git hooks:
   ```bash
   git config core.hooksPath .githooks
   ```
4. Copy the example env files:
   ```bash
   cp apps/api/.env.example apps/api/.env
   cp apps/web/.env.example apps/web/.env
   ```
5. Boot the stack:
   ```bash
   docker compose up
   ```

All commands run inside Docker — see the [README](./README.md#quick-start) for the full workflow.

## Workflow

This project follows [GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow): `main` is always deployable, and all work happens in feature branches via Pull Requests.

```bash
git checkout -b feature/your-change
# ...write tests, then code...
git push -u origin feature/your-change
gh pr create
```

Branch naming:

- `feature/` — new features
- `fix/` — bug fixes
- `chore/` — maintenance, dependencies, config

## Test-Driven Development

Every change must come with tests. Write the failing test first, then the implementation.

- Backend: RSpec (`apps/api/spec/`)
- Frontend: Vitest + Testing Library (`apps/web/src/`)

```bash
docker compose exec api bundle exec rspec
docker compose exec web pnpm test
```

## Before pushing

The pre-push hook lints only the files you changed (~10–30s). Full checks run in CI. To run everything locally before pushing:

```bash
# Backend
docker compose exec api bash -c "bundle exec rubocop && bundle exec brakeman -q && bundler-audit check"

# Frontend
docker compose exec web pnpm lint
docker compose exec web pnpm type-check
```

## Pull Requests

- Keep PRs focused — one logical change per PR.
- Use [Conventional Commits](https://www.conventionalcommits.org/) for commit messages: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`.
- Fill out the PR template — it helps reviewers move faster.
- All CI checks must pass before merge.

## Code style

- All code, comments, variable names, commit messages, and documentation are in **English**.
- Backend: follow the project's `.rubocop.yml`.
- Frontend: ESLint + Prettier, strict TypeScript.
- See [`AGENTS.md`](./AGENTS.md) for architectural patterns and per-app conventions (`apps/api/AGENTS.md`, `apps/web/AGENTS.md`).

## Reporting security issues

Please do **not** open a public issue for security vulnerabilities. See [`SECURITY.md`](./SECURITY.md) for the responsible disclosure process.

## Code of conduct

By participating, you agree to abide by the [Code of Conduct](./CODE_OF_CONDUCT.md).
