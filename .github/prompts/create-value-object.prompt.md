---
description: "Create a new Value Object with validation, domain exception, and unit test"
agent: "agent"
argument-hint: "{Context} {Module} {ValueObjectName} {type} — e.g., Identity User UserEmail string"
---
Create a new Value Object for a DDD module in the DBA-Stack project.

## Input
The user provides: `{Context}`, `{Module}`, `{ValueObjectName}`, and the primitive `{type}` it wraps.

## Requirements
1. Create the Value Object class:
   - Location: `src/{Context}/{Module}/Domain/{ValueObjectName}.php`
   - `final readonly class` with `declare(strict_types=1)`
   - Single `$value` property with `public private(set)` visibility
   - Validation in the constructor — throw domain exception on invalid input
2. Create the domain exception:
   - Location: `src/{Context}/{Module}/Domain/{ValueObjectName}Invalid.php`
   - Named constructor pattern: `{ValueObjectName}Invalid::withValue($value)`
3. Create the unit test:
   - Location: `tests/Unit/{Context}/{Module}/Domain/{ValueObjectName}Test.php`
   - Test valid creation, invalid input rejection, edge cases
4. Run `vendor/bin/pint` and `vendor/bin/phpstan analyse src --level=max`
