---
description: "Use when creating or editing Infrastructure layer code: controllers, Eloquent repositories, service providers, routes, middleware. This is the only layer where Laravel/Illuminate imports are allowed."
applyTo: src/**/Infrastructure/**, app/**
---
# Infrastructure Layer Rules

## Controllers
- MUST extend `ApiController` from the skeleton
- All responses through `ApiController` helpers for unified JSON structure
- Validate input with Form Requests, then dispatch Command/Query

```php
declare(strict_types=1);

namespace DbaStack\{Context}\{Module}\Infrastructure\Http;

use Dba\DddSkeleton\Infrastructure\Http\ApiController;

final class Create{Entity}Controller extends ApiController
{
    public function __invoke(Create{Entity}Request $request): JsonResponse
    {
        $this->dispatch(new Create{Entity}Command(
            id: $request->validated('id'),
            name: $request->validated('name'),
        ));

        return $this->respondCreated();
    }
}
```

## Eloquent Repositories
- MUST extend `EloquentRepository` from the skeleton
- Implement the domain repository interface
- Eloquent models stay **inside** infrastructure — never leak to domain

```php
declare(strict_types=1);

namespace DbaStack\{Context}\{Module}\Infrastructure\Persistence;

use Dba\DddSkeleton\Infrastructure\Persistence\EloquentRepository;

final class Eloquent{Entity}Repository extends EloquentRepository implements {Entity}Repository
{
    public function save({Entity} $entity): void
    {
        // Map domain entity to Eloquent model and persist
    }
}
```

## Search with Criteria
For list/search endpoints, use `RequestCriteriaBuilder`:
```php
public function __invoke(Request $request): JsonResponse
{
    $criteria = RequestCriteriaBuilder::fromRequest($request);
    $results = $this->ask(new Search{Entity}Query($criteria));
    return $this->respondWithCollection($results);
}
```

## Rules
- `declare(strict_types=1)` in every file
- Framework dependencies are OK here (and only here)
- Bind domain interfaces to infrastructure implementations in Service Providers
- `final` by default on all classes
