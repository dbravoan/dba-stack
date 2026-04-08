---
description: "Run the full quality gate: Pint code style, PHPStan static analysis, PHPUnit tests"
agent: "agent"
---
Run the DBA-Stack quality triangle and report results.

## Steps
1. Run `vendor/bin/pint --test` to check code style (dry-run mode)
2. Run `vendor/bin/phpstan analyse src --level=max` for static analysis
3. Run `vendor/bin/phpunit` for all tests
4. Run `npm run build` to verify frontend compiles (skip if no `package.json`)
5. Summarize: PASS/FAIL for each tool, with details on any failures

If any tool fails, suggest specific fixes for each issue found.
