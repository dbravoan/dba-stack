---
description: "Use when creating or editing tests: unit tests, integration tests, architecture tests. Covers PHPUnit 11 patterns, test organization, and DDD test strategies."
applyTo: "tests/**"
---
# Testing Guidelines

## Test Organization
```
tests/
├── Unit/          # Pure domain logic, no DB/framework
│   └── {Context}/{Module}/Domain/
├── Integration/   # Full stack with DB, controllers
│   └── {Context}/{Module}/
└── Architecture/  # Architecture rule enforcement
```

## Unit Tests (Domain)
- Test Value Object validation and domain exceptions
- Test Entity business logic and state transitions
- **No** database, no framework, no mocks of infrastructure
- Fast and deterministic

```php
declare(strict_types=1);

namespace Tests\Unit\{Context}\{Module}\Domain;

use PHPUnit\Framework\TestCase;

final class {Entity}EmailTest extends TestCase
{
    public function test_it_rejects_invalid_email(): void
    {
        $this->expectException({Entity}InvalidEmail::class);
        new {Entity}Email('not-an-email');
    }

    public function test_it_accepts_valid_email(): void
    {
        $email = new {Entity}Email('user@example.com');
        $this->assertSame('user@example.com', $email->value);
    }
}
```

## Integration Tests
- Test full request-response cycles via controllers
- Verify database persistence through repositories
- Use Laravel's `RefreshDatabase` trait

## Rules
- `declare(strict_types=1)` in every test file
- `final` on all test classes
- Descriptive method names: `test_it_does_something_specific`
- One assertion concept per test method
- Run full suite: `vendor/bin/phpunit`
- Run suites: `--testsuite=Unit` or `--testsuite=Integration`
