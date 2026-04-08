# Application Layer Checklist

## Command/Query DTO Checklist
- [ ] `declare(strict_types=1)`
- [ ] `final readonly class`
- [ ] Constructor uses primitive types (string, int, float, bool, array)
- [ ] No domain types — Handlers construct Value Objects from primitives
- [ ] Named clearly: `Create{Entity}Command`, `Find{Entity}Query`

## Handler Checklist
- [ ] `declare(strict_types=1)`
- [ ] `final readonly class`
- [ ] Implements `__invoke()` method
- [ ] Receives appropriate Command/Query as parameter
- [ ] Uses domain repository interface (not infrastructure implementation)
- [ ] Constructs Value Objects from Command/Query primitive data
- [ ] Command handlers return `void`
- [ ] Query handlers return the domain entity or response DTO

## Service Provider Registration
Handlers MUST be tagged in a Service Provider:

```php
// Command handlers
$this->app->tag([
    Create{Entity}CommandHandler::class,
    Update{Entity}CommandHandler::class,
    Delete{Entity}CommandHandler::class,
], 'dba_ddd.command_handler');

// Query handlers  
$this->app->tag([
    Find{Entity}QueryHandler::class,
    Search{Entity}QueryHandler::class,
], 'dba_ddd.query_handler');
```

## Directory Structure
```
Application/
├── Create/
│   ├── Create{Entity}Command.php
│   └── Create{Entity}CommandHandler.php
├── Update/
│   ├── Update{Entity}Command.php
│   └── Update{Entity}CommandHandler.php
├── Find/
│   ├── Find{Entity}Query.php
│   └── Find{Entity}QueryHandler.php
└── Search/
    ├── Search{Entity}Query.php
    └── Search{Entity}QueryHandler.php
```
