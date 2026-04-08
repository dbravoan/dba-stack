---
name: quality-gate
description: "Run the full DBA-Stack quality triangle: Laravel Pint code style, PHPStan static analysis at max level, and PHPUnit tests. Use when checking code quality, before committing, or before opening a pull request."
argument-hint: "Optional: path to analyse (defaults to full project)"
---
# Quality Gate — The Triangle

## When to Use
- Before committing code
- Before opening a Pull Request
- After refactoring or adding new code
- When CI fails and you need to reproduce locally

## Procedure

### Step 1: Code Style (Pint)
```bash
vendor/bin/pint --test
```
- If failures: run `vendor/bin/pint` (without `--test`) to auto-fix
- Review fixed files before committing

### Step 2: Static Analysis (PHPStan)
```bash
vendor/bin/phpstan analyse src --level=max
```
- Fix all errors — level max is non-negotiable
- Common issues: missing return types, generic type parameters, null safety

### Step 3: Tests (PHPUnit)
```bash
vendor/bin/phpunit
```
- All tests must pass
- For faster iteration: `vendor/bin/phpunit --testsuite=Unit` first
- Then: `vendor/bin/phpunit --testsuite=Integration`

### Step 4: Frontend Build (if package.json exists)
```bash
npm run build
```
- TypeScript and Vue must compile cleanly — zero errors
- Validates both client-side and SSR bundles
- Skip this step only if the project has no `package.json`

### Step 5: Report
Summarize results:
- **Pint**: PASS/FAIL (number of files fixed if any)
- **PHPStan**: PASS/FAIL (number of errors)
- **PHPUnit**: PASS/FAIL (tests run, assertions, failures)
- **Frontend Build**: PASS/FAIL/SKIPPED (TypeScript + Vue compilation)

## Quick One-Liner
```bash
vendor/bin/pint --test && vendor/bin/phpstan analyse src --level=max && vendor/bin/phpunit && ([ -f package.json ] && npm run build || true)
```

## Common PHPStan Fixes
See [common fixes reference](./references/phpstan-fixes.md) for typical error patterns and solutions.
