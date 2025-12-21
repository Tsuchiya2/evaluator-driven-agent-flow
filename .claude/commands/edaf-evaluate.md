---
description: Run EDAF evaluators for a specific phase
allowed-tools: Task, Bash, Read
argument-hint: <phase> [feature-slug]
---

# EDAF Evaluate

Run evaluators for a specific EDAF phase.

## Arguments

- `$1` - Phase number (1, 2, 3, or 4)
- `$2` - Feature slug (e.g., "user-authentication")

## Phase 1: Design Evaluators

If phase is 1, run all 7 design evaluators in parallel:

```
Task: design-consistency-evaluator
Task: design-extensibility-evaluator
Task: design-goal-alignment-evaluator
Task: design-maintainability-evaluator
Task: design-observability-evaluator
Task: design-reliability-evaluator
Task: design-reusability-evaluator
```

Evaluate the design document at: `docs/designs/$2.md`

## Phase 2: Planner Evaluators

If phase is 2, run all 7 planner evaluators in parallel:

```
Task: planner-clarity-evaluator
Task: planner-deliverable-structure-evaluator
Task: planner-dependency-evaluator
Task: planner-goal-alignment-evaluator
Task: planner-granularity-evaluator
Task: planner-responsibility-alignment-evaluator
Task: planner-reusability-evaluator
```

Evaluate the task plan at: `docs/plans/$2-tasks.md`

## Phase 3: Code Evaluators

If phase is 3, run all 7 code evaluators in parallel:

```
Task: code-quality-evaluator-v1-self-adapting
Task: code-testing-evaluator-v1-self-adapting
Task: code-security-evaluator-v1-self-adapting
Task: code-documentation-evaluator-v1-self-adapting
Task: code-maintainability-evaluator-v1-self-adapting
Task: code-performance-evaluator-v1-self-adapting
Task: code-implementation-alignment-evaluator-v1-self-adapting
```

Reference documents:
- Design: `docs/designs/$2.md`
- Plan: `docs/plans/$2-tasks.md`

## Phase 4: Deployment Evaluators

If phase is 4, run all 5 deployment evaluators in parallel:

```
Task: deployment-readiness-evaluator
Task: production-security-evaluator
Task: observability-evaluator
Task: performance-benchmark-evaluator
Task: rollback-plan-evaluator
```

## Results

After running evaluators:
1. Parse scores from each evaluator
2. Report which passed (≥7.0) and which failed (<7.0)
3. Summarize total: X/Y evaluators passed
4. If all passed, indicate phase is complete
5. If any failed, list the issues that need to be addressed

## Usage Examples

```
/edaf-evaluate 1 user-authentication
/edaf-evaluate 2 user-authentication
/edaf-evaluate 3 user-authentication
/edaf-evaluate 4 user-authentication
```
