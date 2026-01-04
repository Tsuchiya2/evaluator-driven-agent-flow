# Phase 7: Deployment Gate (Optional)

**Purpose**: Verify deployment readiness and production safety
**Gate Criteria**: All 5 deployment evaluators must score ≥ 8.0/10.0
**Trigger**: After Phase 6 (Documentation Update) completes

---

## 📥 Input from Phase 6 (Documentation)

- **Updated Documentation**: All `docs/` files synchronized with implementation
- **Implementation Code**: All source code that passed code review
- **`.steering/{YYYY-MM-DD}-{feature-slug}/design.md`** - Design document
- **`.steering/{YYYY-MM-DD}-{feature-slug}/tasks.md`** - Task plan
- **`.steering/{YYYY-MM-DD}-{feature-slug}/idea.md`** - Requirements
- **All Previous Reports**: Quality gate, code review, documentation evaluation reports

---

## Workflow

### Step 1: Launch All Deployment Evaluators (PARALLEL)

**CRITICAL: All 5 evaluators must run in parallel**

> **IMPORTANT**: See [GATE-PATTERNS.md](./GATE-PATTERNS.md#context-efficient-evaluation-pattern-critical) for the Context-Efficient Evaluation Pattern. Evaluators return lightweight YAML summaries (~50 tokens) instead of full reports to prevent context exhaustion.

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 7: Deployment" "Running 5 evaluators"')

// Launch all evaluators in parallel
const evaluators = [
  'deployment-readiness-evaluator',
  'production-security-evaluator',
  'observability-evaluator',
  'performance-benchmark-evaluator',
  'rollback-plan-evaluator'
]

const evaluationPromises = evaluators.map(evaluator =>
  Task({
    subagent_type: evaluator,
    prompt: `Evaluate deployment readiness for feature: {feature-slug}

Reference documents:
- Requirements: .steering/{YYYY-MM-DD}-{feature-slug}/idea.md
- Design: .steering/{YYYY-MM-DD}-{feature-slug}/design.md
- Task Plan: .steering/{YYYY-MM-DD}-{feature-slug}/tasks.md
- Code Review: .steering/{YYYY-MM-DD}-{feature-slug}/reports/phase5-*.md

Provide:
1. Score (0-10)
2. Findings (positive and negative)
3. Deployment risks identified
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
const allPassed = scores.every(s => s >= 8.0)
const passCount = scores.filter(s => s >= 8.0).length

await bash(`.claude/scripts/update-edaf-phase.sh "Phase 7: Deployment" "${passCount}/5 evaluators passed"`)

if (allPassed) {
  console.log('✅ Phase 7 PASSED - Ready for deployment')
} else {
  console.log('⚠️  Phase 7 FAILED - Address deployment issues')
}
```

### Step 3: Fix Issues (if needed)

```typescript
if (!allPassed) {
  // Collect issues from failed evaluators
  const failedEvaluators = results.filter(r => parseScore(r) < 7.0)
  const issues = failedEvaluators.flatMap(r => r.issues)

  console.log('⚠️  Deployment issues found:')
  for (const issue of issues) {
    console.log(`  - ${issue.category}: ${issue.message}`)
  }

  // Fix deployment issues
  // Then re-run evaluators
}
```

---

## Deployment Evaluators Detail

| Evaluator | Focus Area | Key Checks |
|-----------|------------|------------|
| deployment-readiness | CI/CD | Build passes, configs set |
| production-security | Security | Secrets, access control, TLS |
| observability | Monitoring | Logging, metrics, alerting |
| performance-benchmark | Load | Response times, throughput |
| rollback-plan | Recovery | Rollback procedures, RTO |

---

## Deployment Readiness Checklist

### Build & Configuration
- [ ] CI/CD pipeline passes
- [ ] All tests pass
- [ ] Build artifacts created
- [ ] Environment variables configured
- [ ] Database migrations ready

### Security
- [ ] No secrets in code
- [ ] Authentication configured
- [ ] Authorization rules set
- [ ] TLS/HTTPS enabled
- [ ] Security headers configured

### Observability
- [ ] Logging configured
- [ ] Metrics exposed
- [ ] Alerts defined
- [ ] Health checks implemented
- [ ] Tracing enabled (optional)

### Performance
- [ ] Load testing completed
- [ ] Response times acceptable
- [ ] Resource limits set
- [ ] Caching configured
- [ ] Database indexes optimized

### Rollback
- [ ] Rollback procedure documented
- [ ] Database rollback plan
- [ ] Feature flags ready (optional)
- [ ] Previous version available
- [ ] RTO defined

---

## Output Artifacts

After Phase 5 (Documentation Update) completion:

1. **Deployment Report**: Summary of all evaluations
2. **Rollback Plan**: `docs/deployment/rollback-plan-{feature-slug}.md`
3. **Runbook**: `docs/deployment/runbook-{feature-slug}.md`

---

## 📤 Output: EDAF Completion

When all evaluators pass:

1. **Deployment Readiness Verified**: All 5 deployment evaluators passed (≥ 8.0/10)
2. **Complete Feature Package**:
   - Requirements: `.steering/{YYYY-MM-DD}-{feature-slug}/idea.md`
   - Design: `.steering/{YYYY-MM-DD}-{feature-slug}/design.md`
   - Plan: `.steering/{YYYY-MM-DD}-{feature-slug}/tasks.md`
   - Implementation: All source code (database, backend, frontend, tests)
   - Quality Reports: All evaluation reports from Phases 1-7
   - Documentation: Updated `docs/` files
3. **Ready for Production Deployment**

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 7: Deployment" "Complete"')
await bash('.claude/scripts/notification.sh "Phase 7 deployment ready" WarblerSong')

console.log('🎉 EDAF 7-Phase workflow complete!')
console.log('')
console.log('Feature: {feature-slug}')
console.log('Status: Ready for deployment')
console.log('')
console.log('📁 Documents generated:')
console.log('  - Phase 1: .steering/{YYYY-MM-DD}-{feature-slug}/idea.md (requirements)')
console.log('  - Phase 2: .steering/{YYYY-MM-DD}-{feature-slug}/design.md')
console.log('  - Phase 3: .steering/{YYYY-MM-DD}-{feature-slug}/tasks.md')
console.log('  - Phase 4: Implementation code + quality-gate report')
console.log('  - Phase 5: Code review reports + UI verification')
console.log('  - Phase 6: Updated docs/ (6 files)')
console.log('  - Phase 7: Deployment readiness reports')
```

---

## Post-Deployment

After deployment:

1. **Monitor** - Watch metrics and logs
2. **Validate** - Verify feature works in production
3. **Document** - Update any post-deployment docs
4. **Celebrate** - Feature shipped successfully! 🎉
