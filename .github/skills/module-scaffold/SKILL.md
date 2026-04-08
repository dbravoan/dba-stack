---
name: module-scaffold
description: "Full DDD module scaffolding workflow: generates module via artisan, then refines domain entities, value objects, application handlers, infrastructure, and tests. Use when creating a new bounded context module from scratch."
argument-hint: "{Context} {Module} — e.g., Catalog Product"
---
# DDD Module Scaffold

## When to Use
- Creating a brand new module in the DBA-Stack project
- Need full end-to-end scaffolding from domain to infrastructure to tests

## Prerequisites
- Docker environment running (`./vendor/bin/sail up -d`) or local PHP 8.4 available
- Composer dependencies installed

## Procedure

### Phase 1: Scaffold
1. Run the generator: `php artisan dba:make:module {Context} {Module}`
2. Verify generated structure under `src/{Context}/{Module}/`
3. Review all generated files to understand the baseline

### Phase 2: Domain Refinement
Follow the [domain checklist](./references/domain-checklist.md):
1. Refine the Entity — add semantic methods, remove setters
2. Create Value Objects with constructor validation
3. Create domain exceptions with named constructors
4. Ensure `AggregateRoot` extension and `final` modifier
5. Use Asymmetric Visibility (`public private(set)`)

### Phase 3: Application Layer
Follow the [application checklist](./references/application-checklist.md):
1. Create `final readonly` Command/Query DTOs
2. Create `final readonly` Handlers
3. Register handlers in Service Provider with tags

### Phase 4: Infrastructure Layer
1. Implement `EloquentRepository` for the domain repository interface
2. Create Eloquent Model (stays in infrastructure)
3. Create Controller extending `ApiController`
4. Create Form Request for validation
5. Add routes

### Phase 5: Testing
1. Unit tests for each Value Object (valid/invalid cases)
2. Unit tests for Entity business logic
3. Integration tests for full request cycle
4. Architecture tests if applicable

### Phase 6: Quality Gate
Run all three checks:
```bash
vendor/bin/pint
vendor/bin/phpstan analyse src --level=max
vendor/bin/phpunit
```
Fix any issues before considering the module complete.

## Expected Output Structure
```
src/{Context}/{Module}/
├── Domain/
│   ├── {Entity}.php              # AggregateRoot
│   ├── {Entity}Id.php            # Value Object
│   ├── {Entity}Repository.php     # Interface
│   └── Exceptions/
├── Application/
│   ├── Create/
│   │   ├── Create{Entity}Command.php
│   │   └── Create{Entity}CommandHandler.php
│   ├── Find/
│   │   ├── Find{Entity}Query.php
│   │   └── Find{Entity}QueryHandler.php
│   └── Search/
│       ├── Search{Entity}Query.php
│       └── Search{Entity}QueryHandler.php
├── Infrastructure/
│   ├── Http/
│   │   ├── Create{Entity}Controller.php
│   │   ├── Find{Entity}Controller.php
│   │   └── Create{Entity}Request.php
│   └── Persistence/
│       ├── {Entity}Model.php
│       └── Eloquent{Entity}Repository.php
tests/
├── Unit/{Context}/{Module}/Domain/
└── Integration/{Context}/{Module}/
```
