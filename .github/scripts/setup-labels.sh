#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# DBA-Stack: Setup GitHub Labels for Agent Orchestration
# =============================================================================
# Run once per repository to create the labels used by the auto-chain workflow,
# issue templates, and the orchestrator agent.
#
# Usage:
#   gh auth login          # if not already authenticated
#   bash .github/scripts/setup-labels.sh
# =============================================================================

REPO="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner -q '.nameWithOwner')}"

echo "🏷️  Setting up orchestration labels for: $REPO"
echo ""

create_label() {
    local name="$1"
    local color="$2"
    local description="$3"

    if gh label create "$name" --color "$color" --description "$description" --repo "$REPO" 2>/dev/null; then
        echo "  ✅ Created: $name"
    else
        gh label edit "$name" --color "$color" --description "$description" --repo "$REPO" 2>/dev/null
        echo "  🔄 Updated: $name"
    fi
}

echo "── Agent Labels ──"
create_label "agent:ddd-architect"    "7057FF" "Issue para el agente ddd-architect (diseño)"
create_label "agent:module-builder"   "0E8A16" "Issue para el agente module-builder (implementación backend)"
create_label "agent:frontend-builder" "1D9BF0" "Issue para el agente frontend-builder (Vue/Inertia)"
create_label "agent:code-reviewer"    "FBCA04" "Issue para el agente code-reviewer (auditoría)"
create_label "agent:orchestrator"     "D93F0B" "Issue para el agente orchestrator (planificación)"

echo ""
echo "── Phase Labels ──"
create_label "phase:1" "C2E0C6" "Fase 1 — Base (sin dependencias)"
create_label "phase:2" "98D8A0" "Fase 2 — Dominio principal"
create_label "phase:3" "6EC87A" "Fase 3 — Dependencias cruzadas"
create_label "phase:4" "44B854" "Fase 4 — Integración"
create_label "phase:5" "1A7F37" "Fase 5 — Refinamiento y auditoría"

echo ""
echo "── Status Labels ──"
create_label "copilot-queued"  "BFD4F2" "En cola para asignación automática a Copilot"
create_label "copilot-working" "1D76DB" "Copilot está trabajando en esta Issue"
create_label "copilot-done"    "0E8A16" "Copilot completó esta Issue (PR creado)"

echo ""
echo "── Dependency Labels (create as needed) ──"
echo "  ℹ️  Labels 'depends-on:#N' se crean dinámicamente por create-issues.sh"
echo "  ℹ️  Ejemplo: depends-on:#1, depends-on:#2, etc."

echo ""
echo "✅ Labels setup complete for $REPO"
echo ""
echo "Next steps:"
echo "  1. Run the orchestrator: use /orchestrate-project prompt in VS Code"
echo "  2. Review the generated plan in docs/project-plan.md"
echo "  3. Run the Issue creation script: bash .github/scripts/create-issues.sh"
echo "  4. Assign the first Issue to Copilot (or let auto-chain handle it)"
