# Phase 2: Planning Gate

**Purpose**: Break down design into actionable tasks with proper sequencing
**Gate Criteria**: All 7 planner evaluators must score ≥ 7.0/10.0

---

## Workflow

### Step 1: Launch Planner

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 2: Planning" "Planner running"')

// Launch planner agent
const planResult = await Task({
  subagent_type: 'planner',
  prompt: `Create a detailed task plan based on the approved design document:

Design Document: docs/designs/{feature-slug}.md

Create a task plan at: docs/plans/{feature-slug}-tasks.md

Include:
1. Task breakdown with clear descriptions
2. Dependencies between tasks
3. Worker assignments (database, backend, frontend, test)
4. Execution sequence
5. Risk assessment
6. Estimated complexity per task
`
})
```

### Step 2: Verify Task Plan

```typescript
// Check task plan exists
const planPath = `docs/plans/{feature-slug}-tasks.md`
const planExists = fs.existsSync(planPath)

if (!planExists) {
  console.error('❌ Task plan not created')
  // Ask planner to retry
}
```

### Step 3: Launch All Planner Evaluators (PARALLEL)

**CRITICAL: All 7 evaluators must run in parallel**

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 2: Planning" "Running 7 evaluators"')

// Launch all evaluators in parallel
const evaluators = [
  'planner-clarity-evaluator',
  'planner-deliverable-structure-evaluator',
  'planner-dependency-evaluator',
  'planner-goal-alignment-evaluator',
  'planner-granularity-evaluator',
  'planner-responsibility-alignment-evaluator',
  'planner-reusability-evaluator'
]

const evaluationPromises = evaluators.map(evaluator =>
  Task({
    subagent_type: evaluator,
    prompt: `Evaluate the task plan at: docs/plans/{feature-slug}-tasks.md

Reference design document: docs/designs/{feature-slug}.md

Provide:
1. Score (0-10)
2. Findings (positive and negative)
3. Recommendations for improvement
4. Pass/Fail determination (≥7.0 = Pass)`
  })
)

const results = await Promise.all(evaluationPromises)
```

### Step 4: Review Results

```typescript
// Check all evaluators passed
const scores = results.map(r => parseScore(r))
const allPassed = scores.every(s => s >= 7.0)
const passCount = scores.filter(s => s >= 7.0).length

await bash(`.claude/scripts/update-edaf-phase.sh "Phase 2: Planning" "${passCount}/7 evaluators passed"`)

if (allPassed) {
  console.log('✅ Phase 2 PASSED - All evaluators approved')
  // Proceed to Phase 2.5 Implementation
} else {
  console.log('⚠️  Phase 2 FAILED - Some evaluators did not approve')
  // Continue to revision cycle
}
```

### Step 5: Revision Cycle (if needed)

```typescript
if (!allPassed) {
  // Collect feedback from failed evaluators
  const failedEvaluators = results.filter(r => parseScore(r) < 7.0)
  const feedback = failedEvaluators.map(r => r.recommendations).join('\n')

  // Ask planner to revise
  const revisionResult = await Task({
    subagent_type: 'planner',
    resume: planResult.agentId,  // Continue previous session
    prompt: `Please revise the task plan based on evaluator feedback:

${feedback}

Update the task plan at: docs/plans/{feature-slug}-tasks.md
Address all issues raised by the evaluators.`
  })

  // Re-run evaluators (return to Step 3)
}
```

---

## Planner Evaluators Detail

| Evaluator | Focus Area | Key Checks |
|-----------|------------|------------|
| clarity | Task descriptions | Clear, unambiguous tasks |
| deliverable-structure | Output format | Well-structured deliverables |
| dependency | Task dependencies | No circular deps, correct order |
| goal-alignment | Design coverage | All design items covered |
| granularity | Task size | Right-sized tasks (not too big/small) |
| responsibility-alignment | Worker assignment | Correct worker for each task |
| reusability | Pattern detection | Reusable patterns identified |

---

## Task Plan Structure

Expected structure in `docs/plans/{feature-slug}-tasks.md`:

```markdown
# Task Plan: {Feature Name}

## Overview
Brief description of the implementation plan.

## Task Summary
| Task ID | Description | Worker | Depends On | Complexity |
|---------|-------------|--------|------------|------------|
| T1 | Create User model | database | - | Medium |
| T2 | Implement auth API | backend | T1 | High |
| T3 | Create login form | frontend | T2 | Medium |
| T4 | Write tests | test | T1, T2, T3 | Medium |

## Execution Sequence
1. Database tasks first
2. Backend tasks (after database)
3. Frontend tasks (parallel with backend)
4. Test tasks last

## Risk Assessment
- Risk 1: Description and mitigation
- Risk 2: Description and mitigation
```

---

## Output Artifacts

After Phase 2 completion:

1. **Task Plan**: `docs/plans/{feature-slug}-tasks.md`
2. **Evaluation Reports**: In evaluator output
3. **Phase Status**: Updated via `update-edaf-phase.sh`

---

## Transition to Phase 2.5

When all evaluators pass:

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 2: Planning" "Complete"')
await bash('.claude/scripts/notification.sh "Phase 2 complete" WarblerSong')

// Proceed to Phase 2.5
// Reference: PHASE25-IMPLEMENTATION.md
```
