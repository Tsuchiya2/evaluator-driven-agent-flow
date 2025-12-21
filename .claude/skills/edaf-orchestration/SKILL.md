# EDAF Orchestration Skill

**Skill Type**: Workflow Orchestration
**Used By**: Main Agent
**Trigger**: When user requests feature implementation with "エージェントフロー" or "EDAF"

---

## Overview

This skill provides the 4-Phase Gate System workflow for EDAF (Evaluator-Driven Agent Flow). It defines the complete workflow from design to deployment with quality gates at each phase.

---

## Trigger Conditions

Use this skill when user says:
- "エージェントフローで実装して"
- "EDAFで開発して"
- "Use EDAF for this feature"
- "Implement with agent flow"

---

## Skill Contents

| File | Purpose |
|------|---------|
| `SKILL.md` | This overview file |
| `PHASE1-DESIGN.md` | Phase 1: Design Gate workflow |
| `PHASE2-PLANNING.md` | Phase 2: Planning Gate workflow |
| `PHASE25-IMPLEMENTATION.md` | Phase 2.5: Implementation workflow |
| `PHASE3-CODE.md` | Phase 3: Code Review Gate workflow |
| `PHASE4-DEPLOYMENT.md` | Phase 4: Deployment Gate workflow |
| `GATE-PATTERNS.md` | Common gate patterns and pass criteria |

---

## Quick Reference

### Phase Overview

```
Phase 1: Design Gate
├── Designer creates design document
└── 7 Design Evaluators approve (≥7.0/10.0)
    ↓
Phase 2: Planning Gate
├── Planner creates task plan
└── 7 Planner Evaluators approve (≥7.0/10.0)
    ↓
Phase 2.5: Implementation
├── Database Worker
├── Backend Worker
├── Frontend Worker
└── Test Worker
    ↓
Phase 3: Code Review Gate
├── 7 Code Evaluators approve (≥7.0/10.0)
└── UI Verification (if frontend changed)
    ↓
Phase 4: Deployment Gate (Optional)
└── 5 Deployment Evaluators approve (≥7.0/10.0)
```

### Critical Rules

1. **NEVER skip phases**
2. **ALWAYS launch evaluators in parallel**
3. **WAIT for ALL evaluators to approve before proceeding**
4. **Minimum passing score: 7.0/10.0**

---

## Phase Flow Control

### Starting EDAF

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Starting" "Initializing EDAF workflow"')

// Begin Phase 1
// Reference: PHASE1-DESIGN.md
```

### Phase Transition

```typescript
// After Phase 1 passes
await bash('.claude/scripts/update-edaf-phase.sh "Phase 1" "Complete - 7/7 evaluators passed"')

// Transition to Phase 2
await bash('.claude/scripts/update-edaf-phase.sh "Phase 2" "Starting planning"')
```

---

## Evaluator Reference

### Phase 1: Design Evaluators (7)
- design-consistency-evaluator
- design-extensibility-evaluator
- design-goal-alignment-evaluator
- design-maintainability-evaluator
- design-observability-evaluator
- design-reliability-evaluator
- design-reusability-evaluator

### Phase 2: Planner Evaluators (7)
- planner-clarity-evaluator
- planner-deliverable-structure-evaluator
- planner-dependency-evaluator
- planner-goal-alignment-evaluator
- planner-granularity-evaluator
- planner-responsibility-alignment-evaluator
- planner-reusability-evaluator

### Phase 3: Code Evaluators (7)
- code-quality-evaluator-v1-self-adapting
- code-testing-evaluator-v1-self-adapting
- code-security-evaluator-v1-self-adapting
- code-documentation-evaluator-v1-self-adapting
- code-maintainability-evaluator-v1-self-adapting
- code-performance-evaluator-v1-self-adapting
- code-implementation-alignment-evaluator-v1-self-adapting

### Phase 4: Deployment Evaluators (5)
- deployment-readiness-evaluator
- production-security-evaluator
- observability-evaluator
- performance-benchmark-evaluator
- rollback-plan-evaluator

---

## Related Resources

- **Workers**: `.claude/agents/workers/`
- **Evaluators**: `.claude/agents/evaluators/`
- **Scoring Skill**: `.claude/skills/edaf-evaluation/`
- **UI Verification Skill**: `.claude/skills/ui-verification/`
