# Phase 1: Design Gate

**Purpose**: Create and validate feature design before implementation
**Gate Criteria**: All 7 design evaluators must score ≥ 7.0/10.0

---

## Workflow

### Step 1: Launch Designer

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 1: Design" "Designer running"')

// Launch designer agent
const designResult = await Task({
  subagent_type: 'designer',
  prompt: `Create a comprehensive design document for the following feature:

Feature: {feature-description}

Requirements:
{user-requirements}

Save the design document to: docs/designs/{feature-slug}.md

Include these sections:
1. Overview
2. Requirements Analysis
3. System Architecture
4. Data Model
5. API Design
6. Security Considerations
7. Error Handling
8. Testing Strategy
`
})
```

### Step 2: Verify Design Document

```typescript
// Check design document exists
const designPath = `docs/designs/{feature-slug}.md`
const designExists = fs.existsSync(designPath)

if (!designExists) {
  console.error('❌ Design document not created')
  // Ask designer to retry
}
```

### Step 3: Launch All Design Evaluators (PARALLEL)

**CRITICAL: All 7 evaluators must run in parallel**

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 1: Design" "Running 7 evaluators"')

// Launch all evaluators in parallel
const evaluators = [
  'design-consistency-evaluator',
  'design-extensibility-evaluator',
  'design-goal-alignment-evaluator',
  'design-maintainability-evaluator',
  'design-observability-evaluator',
  'design-reliability-evaluator',
  'design-reusability-evaluator'
]

const evaluationPromises = evaluators.map(evaluator =>
  Task({
    subagent_type: evaluator,
    prompt: `Evaluate the design document at: docs/designs/{feature-slug}.md

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

await bash(`.claude/scripts/update-edaf-phase.sh "Phase 1: Design" "${passCount}/7 evaluators passed"`)

if (allPassed) {
  console.log('✅ Phase 1 PASSED - All evaluators approved')
  // Proceed to Phase 2
} else {
  console.log('⚠️  Phase 1 FAILED - Some evaluators did not approve')
  // Continue to revision cycle
}
```

### Step 5: Revision Cycle (if needed)

```typescript
if (!allPassed) {
  // Collect feedback from failed evaluators
  const failedEvaluators = results.filter(r => parseScore(r) < 7.0)
  const feedback = failedEvaluators.map(r => r.recommendations).join('\n')

  // Ask designer to revise
  const revisionResult = await Task({
    subagent_type: 'designer',
    resume: designResult.agentId,  // Continue previous session
    prompt: `Please revise the design document based on evaluator feedback:

${feedback}

Update the design document at: docs/designs/{feature-slug}.md
Address all issues raised by the evaluators.`
  })

  // Re-run evaluators (return to Step 3)
}
```

---

## Design Evaluators Detail

| Evaluator | Focus Area | Key Checks |
|-----------|------------|------------|
| consistency | Naming, structure, completeness | Terminology consistent, no gaps |
| extensibility | Extension points, plugin support | Can add features later |
| goal-alignment | Requirements coverage | All requirements addressed |
| maintainability | Modularity, coupling | Easy to modify |
| observability | Logging, metrics | Can monitor in production |
| reliability | Error handling, recovery | Handles failures gracefully |
| reusability | Shared components | DRY principle applied |

---

## Output Artifacts

After Phase 1 completion:

1. **Design Document**: `docs/designs/{feature-slug}.md`
2. **Evaluation Reports**: In evaluator output
3. **Phase Status**: Updated via `update-edaf-phase.sh`

---

## Transition to Phase 2

When all evaluators pass:

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 1: Design" "Complete"')
await bash('.claude/scripts/notification.sh "Phase 1 complete" WarblerSong')

// Proceed to Phase 2
// Reference: PHASE2-PLANNING.md
```
