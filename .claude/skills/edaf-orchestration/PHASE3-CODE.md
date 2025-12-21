# Phase 3: Code Review Gate

**Purpose**: Verify code quality, security, and completeness
**Gate Criteria**: All 7 code evaluators must score ≥ 7.0/10.0 + UI verification (if frontend changed)

---

## Workflow

### Step 1: Launch All Code Evaluators (PARALLEL)

**CRITICAL: All 7 evaluators must run in parallel**

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 3: Code Review" "Running 7 evaluators"')

// Launch all evaluators in parallel
const evaluators = [
  'code-quality-evaluator-v1-self-adapting',
  'code-testing-evaluator-v1-self-adapting',
  'code-security-evaluator-v1-self-adapting',
  'code-documentation-evaluator-v1-self-adapting',
  'code-maintainability-evaluator-v1-self-adapting',
  'code-performance-evaluator-v1-self-adapting',
  'code-implementation-alignment-evaluator-v1-self-adapting'
]

const evaluationPromises = evaluators.map(evaluator =>
  Task({
    subagent_type: evaluator,
    prompt: `Evaluate the code implementation for feature: {feature-slug}

Reference documents:
- Design: docs/designs/{feature-slug}.md
- Task Plan: docs/plans/{feature-slug}-tasks.md

Provide:
1. Score (0-10)
2. Findings (positive and negative)
3. Specific issues with file:line references
4. Recommendations for improvement
5. Pass/Fail determination (≥7.0 = Pass)`
  })
)

const results = await Promise.all(evaluationPromises)
```

### Step 2: Review Results

```typescript
// Check all evaluators passed
const scores = results.map(r => parseScore(r))
const allPassed = scores.every(s => s >= 7.0)
const passCount = scores.filter(s => s >= 7.0).length

await bash(`.claude/scripts/update-edaf-phase.sh "Phase 3: Code Review" "${passCount}/7 evaluators passed"`)
```

### Step 3: Fix Issues (if needed)

```typescript
if (!allPassed) {
  // Collect issues from failed evaluators
  const failedEvaluators = results.filter(r => parseScore(r) < 7.0)
  const issues = failedEvaluators.flatMap(r => r.issues)

  console.log('⚠️  Code issues found:')
  for (const issue of issues) {
    console.log(`  - ${issue.file}:${issue.line} - ${issue.message}`)
  }

  // Fix issues directly (main agent or worker)
  // Then re-run evaluators

  // Update status
  await bash('.claude/scripts/update-edaf-phase.sh "Phase 3: Code Review" "Fixing issues"')
}
```

### Step 4: UI Verification (if frontend changed)

**CRITICAL: Only required when frontend files were modified**

```typescript
// Check if frontend files were modified
const frontendPatterns = [
  '**/components/**/*',
  '**/pages/**/*',
  '**/views/**/*',
  '**/*.css', '**/*.scss',
  '**/src/**/*.{tsx,jsx,ts,js,vue,svelte}'
]

const frontendModified = await checkFilesModified(frontendPatterns)

if (frontendModified) {
  await bash('.claude/scripts/update-edaf-phase.sh "Phase 3: Code Review" "UI Verification"')

  // Launch UI verification worker
  const uiResult = await Task({
    subagent_type: 'ui-verification-worker',
    prompt: `Perform UI/UX verification for feature: {feature-slug}

Reference documents:
- Design: docs/designs/{feature-slug}.md
- Task Plan: docs/plans/{feature-slug}-tasks.md

Requirements:
1. Verify all modified pages visually
2. Capture screenshots for evidence
3. Test interactive elements
4. Check browser console for errors
5. Generate verification report

Save report to: docs/reports/phase3-ui-verification-{feature-slug}.md
Save screenshots to: docs/screenshots/{feature-slug}/`
  })

  // Check UI verification result
  if (uiResult.status === 'skipped') {
    console.log('⚠️  UI verification skipped (WSL2 environment)')
    console.log('   Manual verification recommended')
  } else if (uiResult.status === 'passed') {
    console.log('✅ UI verification passed')
  } else {
    console.log('❌ UI verification failed')
    // Show issues and fix
  }
}
```

### Step 5: Run Verification Script

```bash
bash .claude/scripts/verify-ui.sh {feature-slug}
```

---

## Code Evaluators Detail

| Evaluator | Focus Area | Key Checks |
|-----------|------------|------------|
| quality | Code style | Linting, formatting, type safety |
| testing | Test coverage | Unit tests, coverage >80% |
| security | Vulnerabilities | OWASP Top 10, secrets, injection |
| documentation | Code docs | JSDoc, README, comments |
| maintainability | Complexity | Cyclomatic complexity, SOLID |
| performance | Efficiency | N+1 queries, memory, algorithms |
| implementation-alignment | Requirements | Matches design, all features |

---

## Issue Categories

### Critical (Must Fix)
- Security vulnerabilities
- Missing authentication/authorization
- Data validation failures
- Breaking changes

### High (Should Fix)
- Poor test coverage (<80%)
- Performance issues
- Missing error handling
- Type safety issues

### Medium (Consider Fixing)
- Code duplication
- Complex functions
- Missing documentation
- Inconsistent naming

### Low (Optional)
- Style inconsistencies
- Minor refactoring opportunities
- Comment improvements

---

## Output Artifacts

After Phase 3 completion:

1. **Fixed Code**: All issues resolved
2. **Evaluation Reports**: From each evaluator
3. **UI Verification Report**: `docs/reports/phase3-ui-verification-{feature-slug}.md`
4. **Screenshots**: `docs/screenshots/{feature-slug}/`

---

## Transition to Phase 4

When all evaluators pass AND UI verification passes:

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 3: Code Review" "Complete"')
await bash('.claude/scripts/notification.sh "Code review passed" WarblerSong')

// Ask user if they want Phase 4 (deployment)
const deployResponse = await AskUserQuestion({
  questions: [{
    question: "Proceed to Phase 4 (Deployment Gate)?",
    header: "Deploy",
    multiSelect: false,
    options: [
      { label: "Yes, continue to deployment", description: "Run deployment evaluators" },
      { label: "No, stop here", description: "Feature is ready but not deploying" }
    ]
  }]
})

if (deployResponse.answers['0'].includes('Yes')) {
  // Proceed to Phase 4
  // Reference: PHASE4-DEPLOYMENT.md
}
```
