---
description: "Use when creating or editing Domain layer code: entities, aggregate roots, value objects, domain events, domain exceptions, repository contracts. Enforces pure PHP with zero framework dependencies."
applyTo: "src/**/Domain/**"
---
# Domain Layer Rules

## Absolute Constraints
- **Zero** `Illuminate\*` or framework imports — this is pure PHP
- Entities MUST extend `AggregateRoot` from `dbravoan/dba-ddd-skeleton`
- Every attribute MUST be a Value Object (e.g., `UserId`, `UserEmail`, `UserName`)
- **No setters** — use semantic domain methods (`changeEmail()`, `activate()`, `suspend()`)

## Entity Pattern
```php
declare(strict_types=1);

namespace DbaStack\{Context}\{Module}\Domain;

use Dba\DddSkeleton\Domain\Aggregate\AggregateRoot;

final class {Entity} extends AggregateRoot
{
    public function __construct(
        public private(set) {Entity}Id $id,
        public private(set) {Entity}Name $name,
    ) {}

    public static function create({Entity}Id $id, {Entity}Name $name): self
    {
        return new self(id: $id, name: $name);
    }

    public function changeName({Entity}Name $newName): void
    {
        $this->name = $newName;
    }
}
```

## Value Object Pattern
```php
declare(strict_types=1);

namespace DbaStack\{Context}\{Module}\Domain;

final readonly class {Entity}Email
{
    public function __construct(public private(set) string $value)
    {
        if ($value === '' || !filter_var($value, FILTER_VALIDATE_EMAIL)) {
            throw {Entity}InvalidEmail::withValue($value);
        }
    }
}
```

## PHP 8.4 Features to Use
- **Asymmetric Visibility**: `public private(set)` on entity properties
- **Property Hooks**: For computed/derived domain properties
- **`final readonly`**: On all Value Objects
- **`final`**: On entities and domain services

## Repository Contracts
Define interfaces here — implementations go in Infrastructure:
```php
interface {Entity}Repository
{
    public function save({Entity} $entity): void;
    public function search({Entity}Id $id): ?{Entity};
}
```
