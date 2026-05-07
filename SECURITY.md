# Security Policy

## Reporting a vulnerability

If you discover a security vulnerability in this template, please report it privately so it can be addressed before public disclosure.

**Please do not open a public GitHub issue for security problems.**

### How to report

- **Preferred**: open a [private security advisory](https://github.com/jcflorville/rails-tanstack-starter/security/advisories/new) on GitHub.
- **Alternative**: email `jcflorville@gmail.com` with the subject line `[security] rails-tanstack-starter`.

Please include:

- A clear description of the vulnerability and its impact.
- Steps to reproduce, or a proof-of-concept if available.
- The affected version or commit SHA.
- Any suggested mitigation, if you have one.

### What to expect

- Acknowledgement of your report within **72 hours**.
- An initial assessment and proposed timeline within **7 days**.
- Coordinated disclosure once a fix is available — you will be credited unless you prefer to remain anonymous.

## Scope

This policy covers the template code in this repository. Vulnerabilities in upstream dependencies (Rails, React, etc.) should be reported to those projects directly; we will track and ship security updates via Dependabot.

## Security tooling in this project

The template ships with three layers of automated security checks that run in CI:

- **Brakeman** — static analysis for Rails security issues (SQL injection, XSS, mass assignment, unsafe redirects, etc.).
- **bundler-audit** — checks `Gemfile.lock` against the Ruby Advisory Database.
- **Dependabot** — opens PRs for vulnerable or outdated dependencies (gems, npm packages, GitHub Actions).

Run the backend security checks locally before pushing:

```bash
docker compose exec api bash -c "bundle exec brakeman -q && bundler-audit check --update"
```
