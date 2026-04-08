# Domain Refinement Checklist

## Entity Checklist
- [ ] Extends `AggregateRoot`
- [ ] `declare(strict_types=1)` at top
- [ ] `final class` modifier
- [ ] All properties are Value Objects
- [ ] Properties use `public private(set)` (Asymmetric Visibility)
- [ ] Static factory method: `{Entity}::create(...)`
- [ ] Semantic methods instead of setters (`changeName()`, not `setName()`)
- [ ] No `Illuminate\*` imports

## Value Object Checklist
- [ ] `final readonly class`
- [ ] Single `$value` property with `public private(set)`
- [ ] Constructor validates input
- [ ] Throws domain exception on invalid input
- [ ] Named exception constructor: `Invalid{VO}::withValue($value)`

## Domain Exception Checklist
- [ ] Extends `\DomainException` or a project base exception
- [ ] Named constructor pattern (static factory)
- [ ] Descriptive message including the invalid value
- [ ] `final class` modifier

## Repository Interface Checklist
- [ ] Defined in Domain layer
- [ ] Methods use domain types (Value Objects, Entities)
- [ ] No Eloquent/Laravel types in signatures
- [ ] Core methods: `save()`, `search()`, `delete()`
