# Gate Patterns

**Purpose**: Common patterns for EDAF quality gates

---

## Pass Criteria

### Scoring Scale

| Score | Rating | Action |
|-------|--------|--------|
| 9.0 - 10.0 | Excellent | Pass immediately |
| 8.0 - 8.9 | Good | Pass |
| 5.0 - 7.9 | Needs Work | Fail - requires revision |
| 0.0 - 4.9 | Poor | Fail - major issues |

**Pass criteria:**
- Phases 1, 2, 3, 5, 6, 7: ≥8.0/10.0
- Phase 4 Quality Gate: 10.0/10.0 (zero lint errors/warnings + all tests passing)

---

## Gate Evaluation Pattern

### Standard Gate Flow

```typescript
const runGate = async (
  phaseName: string,
  evaluators: string[],
  documentPath: string
): Promise<GateResult> => {

  // 1. Update status
  await updatePhaseStatus(phaseName, 'Running evaluators')

  // 2. Run all evaluators in parallel
  const results = await Promise.all(
    evaluators.map(e => Task({
      subagent_type: e,
      prompt: `Evaluate: ${documentPath}\nProvide score (0-10), findings, recommendations.`
    }))
  )

  // 3. Calculate results
  const scores = results.map(r => parseScore(r.output))
  const passed = scores.filter(s => s >= 8.0).length
  const total = scores.length
  const allPassed = passed === total

  // 4. Update status
  await updatePhaseStatus(phaseName, `${passed}/${total} evaluators passed`)

  // 5. Return result
  return {
    passed: allPassed,
    scores,
    results,
    summary: `${passed}/${total} passed`
  }
}
```

### Revision Cycle Pattern

```typescript
const revisionCycle = async (
  agentType: string,
  agentId: string,
  feedback: string,
  documentPath: string,
  maxRetries: number = 3
): Promise<RevisionResult> => {

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    console.log(`📝 Revision attempt ${attempt}/${maxRetries}`)

    // 1. Ask agent to revise
    const revisionResult = await Task({
      subagent_type: agentType,
      resume: agentId,  // Continue previous session
      prompt: `Revise the document based on feedback:

${feedback}

Update: ${documentPath}
Address all issues raised by evaluators.`
    })

    // 2. Re-run evaluators
    const gateResult = await runGate(...)

    if (gateResult.passed) {
      return { success: true, attempts: attempt }
    }

    // 3. Collect new feedback for next attempt
    feedback = gateResult.results
      .filter(r => parseScore(r.output) < 8.0)
      .map(r => r.recommendations)
      .join('\n')
  }

  return { success: false, attempts: maxRetries }
}
```

---

## Parallel Evaluation Pattern

### Launch Evaluators in Parallel

```typescript
// CRITICAL: All evaluators must run in parallel for efficiency
const runEvaluatorsParallel = async (evaluators: string[], prompt: string) => {
  // Create all task promises at once
  const taskPromises = evaluators.map(evaluator =>
    Task({
      subagent_type: evaluator,
      prompt: prompt
    })
  )

  // Wait for all to complete
  const results = await Promise.all(taskPromises)

  return results
}
```

### Partial Failure Handling

```typescript
// Handle case where some evaluators pass and some fail
const handlePartialFailure = (results: EvaluatorResult[]) => {
  const passed = results.filter(r => r.score >= 8.0)
  const failed = results.filter(r => r.score < 8.0)

  console.log(`✅ Passed: ${passed.length}`)
  for (const p of passed) {
    console.log(`   - ${p.evaluator}: ${p.score}/10`)
  }

  console.log(`❌ Failed: ${failed.length}`)
  for (const f of failed) {
    console.log(`   - ${f.evaluator}: ${f.score}/10`)
    for (const issue of f.issues) {
      console.log(`     • ${issue}`)
    }
  }

  return { passed, failed }
}
```

---

## Status Update Pattern

### Phase Status Updates

```bash
# Starting phase
bash .claude/scripts/update-edaf-phase.sh "Phase 1: Requirements" "Starting"

# Running evaluators
bash .claude/scripts/update-edaf-phase.sh "Phase 1: Requirements" "Running 7 evaluators"

# Partial progress
bash .claude/scripts/update-edaf-phase.sh "Phase 1: Requirements" "5/7 evaluators passed"

# Revision cycle
bash .claude/scripts/update-edaf-phase.sh "Phase 1: Requirements" "Revising (attempt 2/3)"

# Complete
bash .claude/scripts/update-edaf-phase.sh "Phase 1: Requirements" "Complete"
```

### Status File Format

`.claude/.edaf-phase`:
```
EDAF Phase 1: Requirements | 5/7 evaluators passed
```

---

## Notification Pattern

### Automatic Notifications (via Hooks)

Notifications are triggered automatically by hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "SubagentStop": [{
      "matcher": "*evaluator*",
      "hooks": [{
        "type": "command",
        "command": "bash .claude/scripts/notification.sh 'Evaluator complete' WarblerSong"
      }]
    }]
  }
}
```

### Manual Notifications

```bash
# Phase completion
bash .claude/scripts/notification.sh "Phase 1 complete" WarblerSong

# Error notification
bash .claude/scripts/notification.sh "Evaluation failed" CatMeow
```

---

## Score Parsing Pattern

### Extract Score from Evaluator Output

```typescript
const parseScore = (evaluatorOutput: string): number => {
  // Pattern 1: "Score: 8.5/10"
  const pattern1 = /Score:\s*(\d+\.?\d*)\/10/i
  const match1 = evaluatorOutput.match(pattern1)
  if (match1) return parseFloat(match1[1])

  // Pattern 2: "**Score:** 8.5"
  const pattern2 = /\*\*Score:\*\*\s*(\d+\.?\d*)/i
  const match2 = evaluatorOutput.match(pattern2)
  if (match2) return parseFloat(match2[1])

  // Pattern 3: "Final Score: 8.5"
  const pattern3 = /Final\s+Score:\s*(\d+\.?\d*)/i
  const match3 = evaluatorOutput.match(pattern3)
  if (match3) return parseFloat(match3[1])

  // Default: Could not parse
  console.warn('⚠️  Could not parse score from evaluator output')
  return 0
}
```

---

## Error Recovery Pattern

### Evaluator Timeout

```typescript
const runWithTimeout = async (
  task: Promise<any>,
  timeoutMs: number = 300000  // 5 minutes
): Promise<any> => {
  const timeoutPromise = new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Evaluator timeout')), timeoutMs)
  )

  try {
    return await Promise.race([task, timeoutPromise])
  } catch (error) {
    if (error.message === 'Evaluator timeout') {
      console.warn('⚠️  Evaluator timed out, retrying...')
      return await task  // Retry once
    }
    throw error
  }
}
```

### Evaluator Failure

```typescript
const safeRunEvaluator = async (evaluator: string, prompt: string) => {
  try {
    return await Task({
      subagent_type: evaluator,
      prompt: prompt
    })
  } catch (error) {
    console.error(`❌ ${evaluator} failed: ${error.message}`)
    return {
      evaluator,
      score: 0,
      error: error.message,
      failed: true
    }
  }
}
```
