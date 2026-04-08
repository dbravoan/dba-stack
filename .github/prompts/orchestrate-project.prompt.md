---
agent: "orchestrator"
description: "Decompose a project idea into sequenced GitHub Issues with a creation script"
---

# Orchestrate a New Project

Take the following project description and decompose it into a fully sequenced plan
of GitHub Issues that the Copilot Cloud Agent can execute autonomously.

## Project Description

${input}

## What I need

1. **Project Plan** (`docs/project-plan.md`):
   - Bounded Contexts and their modules
   - Entity designs with Value Objects and business rules
   - Dependency graph between modules
   - Issue sequence table (number, title, agent, dependencies)
   - Timeline estimate
   - Notes: what falls outside DDD scope (frontend, external APIs, etc.)

2. **Issue Creation Script** (`.github/scripts/create-issues.sh`):
   - Bash script using `gh` CLI
   - Creates all Issues with complete bodies (entities, rules, endpoints, tests)
   - Applies labels: `agent:{name}`, `phase:{n}`, `depends-on:#{n}`
   - Outputs summary table after creation

3. **Dependency Diagram**: ASCII art showing the Issue flow and parallelization options

## Rules
- Read `.github/AGENT_GUIDELINES.md` and existing modules in `src/` first
- Each Issue = one module or one cross-cutting concern
- Issue #1 = `ddd-architect` domain design (always)
- Last Issue = `code-reviewer` final audit (always)
- Every module uses `php artisan dba:make:module {Context} {Module}`
- Every Issue targets branch `dev`
- Every Issue includes the quality gate checklist
