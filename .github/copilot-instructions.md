# DBA-Stack — Copilot Workspace Instructions

## Project Overview

Laravel 12 + PHP 8.4 **template repository** using **DDD & Hexagonal Architecture** via the `dbravoan/dba-ddd-skeleton` core package. All domain code lives under `src/{Context}/{Module}/` with strict layer separation.

This is a template designed for both **local Copilot** and **Cloud Agent** workflows.

## Architecture

| Layer | Location | Rules |
|-------|----------|-------|
| **Domain** | `src/{Context}/{Module}/Domain/` | Pure PHP. Entities extend `AggregateRoot`. Use Value Objects for all attributes. **Zero** `Illuminate\*` imports. |
| **Application** | `src/{Context}/{Module}/Application/` | Command/Query Bus. `readonly` Handlers and DTOs. Tag handlers: `dba_ddd.command_handler` / `dba_ddd.query_handler`. |
| **Infrastructure** | `src/{Context}/{Module}/Infrastructure/` | Controllers extend `ApiController`. Repositories extend `EloquentRepository`. Laravel internals stay here. |
| **Frontend** | `resources/js/Pages/{Context}/{Module}/` | Vue 3 + Inertia.js. `<script setup lang="ts">`. Tailwind CSS. Composition API only. |

Reference: [AGENT_GUIDELINES.md](.github/AGENT_GUIDELINES.md) for detailed patterns.

## Module Scaffolding

**Always** start new modules with:
```bash
php artisan dba:make:module {Context} {Module}
```
Then refine: add rich domain methods, Value Object validation, domain exceptions.

## PHP 8.4 Standards

- `declare(strict_types=1);` in every file
- Property Hooks for computed domain properties
- Asymmetric Visibility (`public private(set)`) for encapsulation
- `final` and `readonly` by default
- Strict comparisons (`===`) only

## Frontend (Vue 3 + Inertia.js)

- Pages in `resources/js/Pages/{Context}/{Module}/` (Index, Show, Create, Edit)
- TypeScript interfaces in `resources/js/types/` matching backend entities
- `<script setup lang="ts">` in every `.vue` file
- Tailwind CSS only — no custom CSS per component
- Inertia `useForm()` for forms — never raw fetch/axios
- Ziggy `route()` helper — no hardcoded URLs
- Web Controllers use `Inertia::render()` and dispatch the same Commands/Queries

## Quality Gate

All checks must pass before any PR:
```bash
vendor/bin/pint          # Code style
vendor/bin/phpstan analyse src --level=max  # Static analysis
vendor/bin/phpunit       # Tests
npm run build            # Frontend build (if package.json exists)
```

## Git Workflow

- Feature branches from `dev`: `feature/{task-name}`
- PRs target `dev` only — **never** `main`
- Only the human supervisor merges `dev` → `main`

## Cloud Agent: Important Context

When running as a **Copilot Cloud Agent** (GitHub Issues, Agents panel):
- The environment is pre-configured via `copilot-setup-steps.yml` (PHP 8.4, Composer, MySQL)
- Always branch from `dev`, never from `main`
- Run the quality gate before finishing: `vendor/bin/pint && vendor/bin/phpstan analyse src --level=max && vendor/bin/phpunit`
- Use `php artisan dba:make:module` for new modules — never create the directory structure manually
- Follow `AGENT_GUIDELINES.md` for all implementation decisions

## Orchestration System

This template includes an auto-chain system for sequential Issue execution:
- Issues are labeled with `copilot-queued`, `phase:N`, and `depends-on:#N`
- The `copilot-auto-chain.yml` workflow assigns the next eligible Issue when a PR merges to `dev`
- The `orchestrator` agent decomposes a project idea into sequenced Issues
- Labels: `agent:ddd-architect`, `agent:module-builder`, `agent:frontend-builder`, `agent:code-reviewer`, `agent:orchestrator`

## Build & Test

```bash
composer install
cp .env.example .env
php artisan key:generate
npm ci && npm run build                    # Frontend (if package.json exists)
vendor/bin/phpunit                         # All tests
vendor/bin/phpunit --testsuite=Unit        # Unit only
vendor/bin/phpunit --testsuite=Integration # Integration only
```

## Key Patterns

- Responses always through `ApiController` helpers (unified JSON structure)
- Search operations use `RequestCriteriaBuilder` for filtering
- Semantic domain methods (`$user->changeEmail()`) instead of setters
- Domain exceptions in Value Object constructors
