# DBA-STACK: AGENT GUIDELINES & CODE OF EXCELLENCE (v2.0)

## 1. IDENTITY & MISSION
You are a Senior Software Architect specializing in Domain-Driven Design (DDD) and Hexagonal Architecture. Your goal is to expand the **DBA-Stack** using the `dbravoan/dba-ddd-skeleton` core. We prioritize code excellence, strict typing, and high maintainability.

## 2. THE COMMAND-FIRST RULE
The scaffolding process is standardized. **Always start by using the built-in generator.**
- **Action**: Run `php artisan dba:make:module {Context} {Module}`.
- **Purpose**: This ensures the directory structure (`Domain`, `Application`, `Infrastructure`) and base files (Repository, Controller, Command/Query) are perfectly aligned with the skeleton's patterns.
- **Refinement**: Once generated, you MUST refactor the Domain Entity and Value Objects to move beyond anemic models. Add business logic, domain constraints, and semantic methods.

## 3. ARCHITECTURAL SYNERGY
Every module must reside in `src/{Context}/{Module}/`. Use the `Identity/User` module as the "Gold Standard" for implementation reference.

### Layer Responsibilities:
1. **Domain**: 
   - Entities must extend `AggregateRoot`.
   - Use Value Objects for all attributes (e.g., `UserId`, `UserEmail`).
   - **Zero Dependencies**: No framework classes (`Illuminate\*`) allowed here.
2. **Application**:
   - Implement the **Command/Query Bus** pattern.
   - Use `readonly` classes for Handlers and DTOs.
   - Handlers must be registered in the `DddSkeletonServiceProvider` or a dedicated provider using tags: `dba_ddd.command_handler` or `dba_ddd.query_handler`.
3. **Infrastructure**:
   - Controllers must extend `ApiController`.
   - Repositories must extend `EloquentRepository` for DB operations, hiding Eloquent models from the upper layers.

## 4. TECH STACK & PHP 8.4 STANDARDS
- **PHP 8.4 Strictness**:
  - Mandatory `declare(strict_types=1);` in every file.
  - Use **Property Hooks** for calculated domain properties.
  - Use **Asymmetric Visibility** (`public private(set)`) where it improves encapsulation.
  - Heavy use of `final` and `readonly`.
- **Laravel 12**: Use the latest framework features, focusing on performance and clean service registration.

## 5. REFINEMENT & EXCELLENCE CHECKLIST
After running the `make:module` command, you must:
1. **Rich Domain**: Replace generic setters in the Entity with semantic methods (e.g., `$user->changeEmail()` instead of `setEmail()`).
2. **Value Object Validation**: Add domain exceptions inside Value Object constructors.
3. **Criteria Pattern**: For search operations, always utilize `RequestCriteriaBuilder` to leverage the skeleton's advanced filtering.
4. **Consistency**: Ensure all responses return through the `ApiController` helpers to maintain a unified JSON structure.

## 6. QUALITY GATE
Before submitting a Pull Request:
- **Static Analysis**: Must pass `phpstan` at **Level Max**.
- **Coding Style**: Must pass `laravel/pint` rules.
- **Testing**: Ensure all unit and integration tests are green.

## 7. BRANCHING & DEPLOYMENT POLICY
- **Work Branch**: Create feature branches from `dev` (e.g., `feature/task-name`).
- **Submission**: All Pull Requests must target the `dev` branch.
- **Main Branch**: **NEVER** target `main` or `master`. Direct pushes or PRs to `main` will be automatically rejected.
- **Deployment**: Deployment to the VPS happens ONLY when the Human Supervisor merges `dev` into `main`.

## 8. FRONTEND LAYER (Vue 3 + Inertia.js)
The project uses **Vue 3 + Inertia.js** for the frontend, connected to the same DDD backend. Frontend code stays separate from domain logic.

### Standards
- **`<script setup lang="ts">`** in every `.vue` file — no exceptions.
- **Composition API only** — never Options API.
- **TypeScript strict mode** — no `any` types.
- **Tailwind CSS** — no custom CSS files per component.
- **Inertia `useForm()`** — never raw `fetch()` or `axios`.
- **Ziggy `route()`** — never hardcoded URLs.

### File Organization
```
resources/js/
├── Pages/{Context}/{Module}/   # Inertia pages mirroring backend module structure
├── Components/UI/              # Reusable primitives (Button, Modal, DataTable)
├── Components/Forms/           # Form components (TextInput, Select)
├── Composables/                # use* composable functions
├── Layouts/                    # AppLayout, GuestLayout, BackofficeLayout
└── types/                      # TypeScript interfaces matching backend entities
```

### Web Controllers
Web controllers live alongside API controllers in the module's `Infrastructure/` layer:
- Dispatch the **same** Commands/Queries as API controllers (no logic duplication).
- Use `Inertia::render()` to serve Vue pages with typed props.
- Routes use named conventions: `{context}.{module}.{action}`.

### SSR (Server-Side Rendering)
- SSR entry point: `resources/js/ssr.ts`
- Build includes SSR: `npm run build` generates both client and SSR bundles.
- Production SSR managed via **supervisord** (see `deploy.yml` comments).
- Quality gate includes `npm run build` — TypeScript and Vue must compile cleanly.

### Frontend Quality Gate
In addition to the PHP quality gate, the frontend must pass:
```bash
npm run build    # TypeScript + Vue compilation — zero errors
```