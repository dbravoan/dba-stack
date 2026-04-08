---
description: "Scaffold a new DDD module with Context and Module names, then refine the domain model"
agent: "module-builder"
argument-hint: "{Context} {Module} — e.g., Catalog Product"
---
Create a new DDD module in the DBA-Stack project.

## Input
The user provides `{Context}` and `{Module}` names (e.g., `Catalog Product`, `Identity User`, `Billing Invoice`).

## Steps
1. Run `php artisan dba:make:module {Context} {Module}` to scaffold
2. Inspect the generated files under `src/{Context}/{Module}/`
3. Refine the Domain Entity:
   - Add semantic methods (no setters)
   - Create Value Objects with validation
   - Add domain exceptions
4. Refine the Application layer:
   - Create Command/Query DTOs (`final readonly`)
   - Create Handlers (`final readonly`)
   - Register handlers with appropriate tags
5. Refine the Infrastructure layer:
   - Implement Repository
   - Create Controller extending `ApiController`
   - Add routes
6. Create unit tests for Value Objects and entity logic
7. Run the quality gate: `vendor/bin/pint && vendor/bin/phpstan analyse src --level=max && vendor/bin/phpunit`
