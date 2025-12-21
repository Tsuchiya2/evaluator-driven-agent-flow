# Phase 4: Deployment Gate (Optional)

**Purpose**: Verify deployment readiness and production safety
**Gate Criteria**: All 5 deployment evaluators must score ≥ 7.0/10.0

---

## Workflow

### Step 1: Launch All Deployment Evaluators (PARALLEL)

**CRITICAL: All 5 evaluators must run in parallel**

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 4: Deployment" "Running 5 evaluators"')

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
- Design: docs/designs/{feature-slug}.md
- Task Plan: docs/plans/{feature-slug}-tasks.md
- Code Review: docs/reports/phase3-*.md

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
const allPassed = scores.every(s => s >= 7.0)
const passCount = scores.filter(s => s >= 7.0).length

await bash(`.claude/scripts/update-edaf-phase.sh "Phase 4: Deployment" "${passCount}/5 evaluators passed"`)

if (allPassed) {
  console.log('✅ Phase 4 PASSED - Ready for deployment')
} else {
  console.log('⚠️  Phase 4 FAILED - Address deployment issues')
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

After Phase 4 completion:

1. **Deployment Report**: Summary of all evaluations
2. **Rollback Plan**: `docs/deployment/rollback-plan-{feature-slug}.md`
3. **Runbook**: `docs/deployment/runbook-{feature-slug}.md`

---

## EDAF Completion

When all evaluators pass:

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 4: Deployment" "Complete"')
await bash('.claude/scripts/notification.sh "Deployment ready" WarblerSong')

console.log('🎉 EDAF workflow complete!')
console.log('')
console.log('Feature: {feature-slug}')
console.log('Status: Ready for deployment')
console.log('')
console.log('Documents generated:')
console.log('  - Design: docs/designs/{feature-slug}.md')
console.log('  - Plan: docs/plans/{feature-slug}-tasks.md')
console.log('  - UI Report: docs/reports/phase3-ui-verification-{feature-slug}.md')
console.log('  - Screenshots: docs/screenshots/{feature-slug}/')
```

---

## Post-Deployment

After deployment:

1. **Monitor** - Watch metrics and logs
2. **Validate** - Verify feature works in production
3. **Document** - Update any post-deployment docs
4. **Celebrate** - Feature shipped successfully! 🎉
