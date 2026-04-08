#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# DBA-Stack: Create Issues Script — TEMPLATE
# =============================================================================
# This file is a TEMPLATE that the orchestrator agent fills in.
# The orchestrator generates a project-specific version of this script
# at .github/scripts/create-issues.sh
#
# Usage (after orchestrator generates it):
#   bash .github/scripts/setup-labels.sh   # once per repo
#   bash .github/scripts/create-issues.sh  # creates all Issues
#
# The auto-chain workflow (.github/workflows/copilot-auto-chain.yml) then
# assigns Issues to Copilot as each PR merges.
# =============================================================================

REPO="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q '.nameWithOwner')}"
BASE_BRANCH="dev"

echo "🚀 Creating orchestrated Issues for: $REPO"
echo "   Base branch: $BASE_BRANCH"
echo ""

# Verify prerequisites
command -v gh >/dev/null 2>&1 || { echo "❌ gh CLI not found. Install: https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "❌ gh not authenticated. Run: gh auth login"; exit 1; }
gh repo view "$REPO" --json name >/dev/null 2>&1 || { echo "❌ Repository not found: $REPO"; exit 1; }

# Ensure labels exist
echo "🏷️  Ensuring labels exist..."
bash "$(dirname "$0")/setup-labels.sh"
echo ""

# Helper: create a dependency label if it doesn't exist
ensure_dep_label() {
    local label="depends-on:#$1"
    gh label create "$label" --color "EDEDED" --description "Depends on Issue #$1" --repo "$REPO" 2>/dev/null || true
}

# =============================================================================
# ISSUE CREATION — Replace this section with your project's Issues
# =============================================================================
# The orchestrator agent replaces everything below this line.
# Below is an EXAMPLE for reference (E-Commerce project).
# =============================================================================

echo "📋 Creating Issues..."
echo ""

# ── Issue 1: Domain Design ──
ISSUE_1=$(gh issue create \
    --repo "$REPO" \
    --title "Diseñar el modelo de dominio completo" \
    --label "agent:ddd-architect,copilot-queued,phase:1" \
    --body "$(cat <<'BODY'
## Descripción
Diseñar el modelo de dominio completo para el proyecto antes de implementar.

## Instrucciones para Copilot
- **Agente:** ddd-architect
- **Branch base:** dev
- **Output:** Documento de diseño con entidades, VOs, reglas de negocio y plan de Issues

## Bounded Contexts a diseñar
<!-- El orchestrator rellena esto -->

## Para cada Bounded Context necesito
- Lista de entidades (AggregateRoot) con sus atributos
- Value Objects con reglas de validación
- Transiciones de estado permitidas
- Eventos de dominio
- Interfaz del repositorio
- Relaciones entre contextos

## Restricciones
- Seguir los patrones de `.github/AGENT_GUIDELINES.md`
- Cada contexto es independiente, se comunican por ID
- Los Value Objects de un contexto NO se reutilizan en otro
BODY
)" --json number -q '.number')

echo "  ✅ Issue #$ISSUE_1: Diseñar el modelo de dominio completo"

# ── Issue 2: Example Module (no dependencies) ──
ISSUE_2=$(gh issue create \
    --repo "$REPO" \
    --title "Crear módulo {Context}/{Module}" \
    --label "agent:module-builder,copilot-queued,phase:2" \
    --body "$(cat <<'BODY'
## Descripción
Implementar el módulo {Context}/{Module}.

## Scaffold
```
php artisan dba:make:module {Context} {Module}
```

## Entidad {Module} (AggregateRoot)
<!-- Atributos como Value Objects -->

## Métodos de dominio
<!-- Factory estático + métodos semánticos -->

## Reglas de negocio
<!-- Invariantes y restricciones -->

## Endpoints API
<!-- Rutas HTTP -->

## Tests requeridos
### Unit
<!-- Tests de Value Objects y reglas -->
### Integration
<!-- Tests de endpoints -->

## Checklist final
- [ ] Ejecutar vendor/bin/pint
- [ ] Ejecutar vendor/bin/phpstan analyse src --level=max
- [ ] Ejecutar vendor/bin/phpunit
- [ ] Todos los tests en verde
BODY
)" --json number -q '.number')

echo "  ✅ Issue #$ISSUE_2: Crear módulo {Context}/{Module}"

# ── Issue 3: Example with dependency ──
ensure_dep_label "$ISSUE_2"

ISSUE_3=$(gh issue create \
    --repo "$REPO" \
    --title "Crear módulo {Context2}/{Module2}" \
    --label "agent:module-builder,copilot-queued,phase:3,depends-on:#${ISSUE_2}" \
    --body "$(cat <<BODY
## Descripción
Implementar el módulo {Context2}/{Module2}. Depende de Issue #${ISSUE_2}.

## Scaffold
\`\`\`
php artisan dba:make:module {Context2} {Module2}
\`\`\`

<!-- ... mismo formato que arriba ... -->

## Checklist final
- [ ] Ejecutar vendor/bin/pint
- [ ] Ejecutar vendor/bin/phpstan analyse src --level=max
- [ ] Ejecutar vendor/bin/phpunit
- [ ] Todos los tests en verde
BODY
)" --json number -q '.number')

echo "  ✅ Issue #$ISSUE_3: Crear módulo {Context2}/{Module2} (depends on #$ISSUE_2)"

# ── Last Issue: Final Audit ──
ensure_dep_label "$ISSUE_2"
ensure_dep_label "$ISSUE_3"

ISSUE_AUDIT=$(gh issue create \
    --repo "$REPO" \
    --title "Auditoría completa de arquitectura" \
    --label "agent:code-reviewer,copilot-queued,phase:5,depends-on:#${ISSUE_2},depends-on:#${ISSUE_3}" \
    --body "$(cat <<BODY
## Descripción
Auditar todo el código antes de merge a main.

## Alcance
Todos los módulos en src/

## Verificaciones
- [ ] Domain: cero Illuminate imports, VOs validan en constructor
- [ ] Application: handlers final readonly, tags registrados
- [ ] Infrastructure: controllers extienden ApiController
- [ ] PHP 8.4: strict_types, Asymmetric Visibility, Property Hooks
- [ ] Cross-module: sin imports entre bounded contexts
- [ ] No hay TODOs/FIXMEs sin resolver

## Output
Tabla de hallazgos: Severidad | Módulo | Archivo:Línea | Descripción | Fix
BODY
)" --json number -q '.number')

echo "  ✅ Issue #$ISSUE_AUDIT: Auditoría completa (depends on #$ISSUE_2, #$ISSUE_3)"

# =============================================================================
# SUMMARY
# =============================================================================

echo ""
echo "═══════════════════════════════════════════════════"
echo "  📋 Issues Created Successfully"
echo "═══════════════════════════════════════════════════"
echo ""
echo "  #$ISSUE_1 — Diseño del dominio (ddd-architect)"
echo "  #$ISSUE_2 — Módulo {Context}/{Module} (module-builder)"
echo "  #$ISSUE_3 — Módulo {Context2}/{Module2} (module-builder)"
echo "  #$ISSUE_AUDIT — Auditoría final (code-reviewer)"
echo ""
echo "═══════════════════════════════════════════════════"
echo ""
echo "🔗 Next steps:"
echo "  1. Review Issues at: https://github.com/$REPO/issues"
echo "  2. Assign Issue #$ISSUE_1 to Copilot to start the chain"
echo "  3. After each PR merge, the auto-chain workflow assigns the next Issue"
echo ""
echo "  To start manually:"
echo "    gh issue edit $ISSUE_1 --add-assignee 'copilot-swe-agent[bot]' --repo $REPO"
echo ""
echo "  Or assign from github.com → Issue → Assignees → Copilot"
