# Common PHPStan Fixes (Level Max)

## Missing Generic Types
**Error**: `Generic type ... does not specify its types`
```php
// Bad
/** @var Collection */
private Collection $items;

// Good
/** @var Collection<int, OrderItem> */
private Collection $items;
```

## Missing Return Types
**Error**: `Method ... has no return type specified`
```php
// Bad
public function getId() { return $this->id; }

// Good
public function getId(): UserId { return $this->id; }
```

## Null Safety
**Error**: `Cannot call method ... on null`
```php
// Bad
$user->getName()->value;

// Good
$user = $this->repository->search($id);
if ($user === null) {
    throw UserNotFound::withId($id);
}
$user->getName()->value;
```

## Dead Code
**Error**: `Unreachable statement - code above always terminates`
- Remove code after `throw`, `return`, or `exit`

## Strict Comparisons
**Error**: `Loose comparison via == is not allowed`
```php
// Bad
if ($status == 'active') { ... }

// Good
if ($status === 'active') { ... }
```

## Value Object Type Narrowing
**Error**: `Parameter ... expects string, mixed given`
```php
// Bad
new UserEmail($request->input('email'));

// Good — validate first
$validated = $request->validated();
new UserEmail($validated['email']); // string guaranteed by Form Request
```
