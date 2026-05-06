# API — Rails 8

> Backend service for the `{{PROJECT_NAME}}` monorepo. This file documents API-specific patterns. For monorepo-wide context (architecture principles, Docker, CI, deploy, git workflow, auth strategy), see the root [`AGENTS.md`](../../AGENTS.md). `CLAUDE.md` in this directory is a symlink to this file.

## Overview

Rails 8 in API mode. PostgreSQL for persistence, Solid Queue for background jobs, Rails 8 built-in authentication for session-based auth. All endpoints are versioned under `/api/v1/`.

## Tech Stack

| Concern        | Tool                                              |
| -------------- | ------------------------------------------------- |
| Framework      | Rails 8 (API mode)                                |
| Database       | PostgreSQL                                        |
| Background Jobs| Solid Queue                                       |
| Auth           | Rails 8 built-in authentication (session cookies) |
| Serialization  | Blueprinter                                       |
| Testing        | RSpec + FactoryBot                                |
| Linting        | RuboCop                                           |
| Security       | Brakeman + bundler-audit                          |

## Directory Layout

```
apps/api/
├── app/
│   ├── controllers/
│   │   └── api/v1/        # Versioned API controllers (thin)
│   ├── models/
│   ├── serializers/       # Blueprinter serializers
│   ├── services/          # Service objects (business logic)
│   └── jobs/              # Solid Queue jobs
├── config/
│   └── deploy.yml         # Kamal deploy config
├── spec/                  # RSpec tests
├── Dockerfile
├── Gemfile
└── .rubocop.yml
```

## Backend Patterns

### Service Objects

All business logic goes in service objects under `app/services/`. Controllers stay thin — they parse params, call a service, and render the response.

```ruby
# app/services/users/create_service.rb
module Users
  class CreateService
    def initialize(params:)
      @params = params
    end

    def call
      user = User.new(@params)
      if user.save
        ServiceResult.success(user)
      else
        ServiceResult.failure(user.errors)
      end
    end
  end
end
```

Services return a result object (`ServiceResult.success(data)` / `ServiceResult.failure(errors)`) to keep the interface consistent across the codebase.

### Controllers

Thin controllers. Namespaced under `Api::V1::`. They parse params, call a service, and render — nothing else.

```ruby
# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApplicationController
      def create
        result = Users::CreateService.new(params: user_params).call

        if result.success?
          render json: UserSerializer.render(result.data), status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end
    end
  end
end
```

### Serializers (Blueprinter)

All API responses go through Blueprinter serializers under `app/serializers/`. Never render raw models.

```ruby
# app/serializers/user_serializer.rb
class UserSerializer < Blueprinter::Base
  identifier :id
  fields :email, :name, :created_at
end
```

### Error responses

Consistent error shape across the API:

- Validation errors: `{ "errors": [...] }` with status `422`
- Single message errors: `{ "error": "message" }` with the appropriate status
- Never leak stack traces or internal error messages in production

## Testing (RSpec)

Tests are written before the implementation (Red-Green-Refactor). See the TDD section in the root `AGENTS.md`.

```
spec/
├── models/             # validations, associations, scopes
├── services/           # business logic — main test focus
├── requests/api/v1/    # integration tests for API endpoints
├── factories/          # FactoryBot
└── support/
```

**What to test:**

- **Models**: validations, associations, scopes, custom methods.
- **Services**: every business operation. Cover both success and failure paths.
- **Requests**: full HTTP flow per endpoint — auth, params, response shape, status codes.

**What NOT to test:**

- Controllers in isolation — request specs already cover them.
- Trivial getters/setters or framework behavior.

**Conventions:**

- Use FactoryBot factories, not fixtures.
- One `describe` block per public method/endpoint.
- Use `let`/`let!` over instance variables.
- Reset `Current` attributes between tests (handled by RSpec config).

## Authentication (server-side details)

Rails 8 built-in auth with server-side sessions. See the root `AGENTS.md` for the cross-cutting strategy.

**Server-side specifics:**

- CORS configured with `credentials: true` and explicit origin (no wildcards). See `config/initializers/cors.rb`.
- Session cookie attributes in production: `HttpOnly; Secure; SameSite=None` (cross-origin between `{{WEB_DOMAIN}}` and `{{API_DOMAIN}}`).
- `Current.user` is set via a `before_action` in `ApplicationController` and is accessible in any controller, service, or job.
- Endpoints:
  - `POST /api/v1/session` — login (sets session cookie)
  - `DELETE /api/v1/session` — logout (destroys session)
  - `GET /api/v1/me` — returns current user

## Common Commands

All commands run inside the Docker container — never on the host.

```bash
# Tests
docker compose exec api bundle exec rspec
docker compose exec api bundle exec rspec spec/services/users/create_service_spec.rb

# Lint + security (run all three before pushing)
docker compose exec api bundle exec rubocop
docker compose exec api bundle exec brakeman -q
docker compose exec api bundler-audit check --update

# One-shot full pre-push check
docker compose exec api bash -c "bundle exec rubocop && bundle exec brakeman -q && bundler-audit check"

# Rails console
docker compose exec api rails console

# Generators
docker compose exec api rails generate model User name:string email:string
docker compose exec api rails generate migration AddFieldToTable

# Database
docker compose exec api rails db:create
docker compose exec api rails db:migrate
docker compose exec api rails db:rollback
docker compose exec api rails db:seed

# Solid Queue (jobs)
docker compose exec api bin/jobs        # run worker manually if needed
```

## Deploy

Deploy is managed via Kamal. From this directory:

```bash
cd apps/api
kamal deploy
kamal logs -f
kamal console
```

See the Deploy section in the root `AGENTS.md` for full details.
