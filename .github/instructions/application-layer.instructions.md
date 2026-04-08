---
description: "Use when creating or editing Application layer code: commands, queries, handlers, DTOs, application services. Enforces CQRS bus pattern with readonly classes."
applyTo: "src/**/Application/**"
---
# Application Layer Rules

## Command/Query Bus Pattern
- Commands represent **write** intentions (create, update, delete)
- Queries represent **read** intentions (find, search, list)
- Each Command/Query has exactly ONE Handler

## Handler Pattern
```php
declare(strict_types=1);

namespace DbaStack\{Context}\{Module}\Application\Create;

final readonly class Create{Entity}CommandHandler
{
    public function __construct(
        private {Entity}Repository $repository,
    ) {}

    public function __invoke(Create{Entity}Command $command): void
    {
        $entity = {Entity}::create(
            id: new {Entity}Id($command->id),
            name: new {Entity}Name($command->name),
        );

        $this->repository->save($entity);
    }
}
```

## Command/Query Pattern
```php
declare(strict_types=1);

namespace DbaStack\{Context}\{Module}\Application\Create;

final readonly class Create{Entity}Command
{
    public function __construct(
        public string $id,
        public string $name,
    ) {}
}
```

## Registration
Handlers **must** be tagged in a Service Provider:
```php
$this->app->tag(Create{Entity}CommandHandler::class, 'dba_ddd.command_handler');
$this->app->tag(Find{Entity}QueryHandler::class, 'dba_ddd.query_handler');
```

## Rules
- All Handlers and DTOs must be `final readonly`
- Handlers receive primitives via Command/Query, then construct Value Objects
- Use the domain repository interface, NOT the Eloquent implementation
- Search operations use `RequestCriteriaBuilder` for advanced filtering
- `declare(strict_types=1)` in every file
