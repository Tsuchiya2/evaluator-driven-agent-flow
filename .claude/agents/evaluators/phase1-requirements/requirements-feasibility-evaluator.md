# requirements-feasibility-evaluator

**Role**: Evaluate technical and business feasibility of requirements
**Phase**: Phase 1 (Requirements Gathering)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Recommended Model**: `sonnet` (deeper analysis of technical feasibility)

---

## 🎯 Purpose

Ensures that requirements are technically feasible and practically achievable within stated constraints. This evaluator prevents unrealistic or impossible requirements from entering Phase 2 (Design).

**Key Question**: *Can these requirements be realistically implemented with available technology, time, and resources?*

---

## 📋 Evaluation Criteria

### 1. Technical Feasibility (3.5 points)

**Check**: Requirements can be implemented with current technology

**Technically Feasible Examples**:
- ✅ "JWT authentication with 15-minute expiry" (standard practice)
- ✅ "Support 1000 concurrent users" (achievable with proper architecture)
- ✅ "Password hashing with bcrypt" (proven technology)

**Technically Questionable Examples**:
- ⚠️ "Support 10 million concurrent users" (requires distributed architecture, may be unrealistic for MVP)
- ⚠️ "Real-time sync across 1000 devices with < 1ms latency" (physics limitations)
- ❌ "100% uptime guarantee" (impossible)

**Verification Process**:
```typescript
// Check if requirements align with common practices
const requirementChecks = [
  {
    requirement: 'JWT authentication',
    technology: 'jsonwebtoken library',
    feasibility: 'High',
    effort: 'Low'
  },
  {
    requirement: 'Support 1M concurrent users',
    technology: 'Requires: Load balancing, caching, DB sharding',
    feasibility: 'Medium',
    effort: 'High'
  }
]
```

**Scoring**:
- 3.5: All requirements technically feasible with standard technology
- 2.5: Most requirements feasible (1-2 require significant effort)
- 1.5: Several requirements questionable or very difficult
- 0.0: Requirements contain impossible or unrealistic items

---

### 2. Resource Alignment (2.5 points)

**Check**: Requirements fit within stated constraints

**Constraint Categories**:
1. **Time Constraints**
2. **Technical Constraints**
3. **Resource Constraints**
4. **Budget Constraints** (if applicable)

**Aligned Example**:
```markdown
## Constraints
**Time**: MVP in 4 weeks

## Scope
**Must Have**:
- User registration (1 week)
- Login with JWT (1 week)
- Password reset (1 week)
- Basic profile page (1 week)

✅ Total: 4 weeks (aligned with constraint)
```

**Misaligned Example**:
```markdown
## Constraints
**Time**: MVP in 2 weeks

## Scope
**Must Have**:
- User registration
- Login with JWT
- Social login (Google, Facebook, Twitter)
- Multi-factor authentication
- Advanced role-based permissions
- Audit logging
- Admin dashboard

❌ Scope far exceeds time constraint
```

**Scoring**:
- 2.5: Requirements clearly fit within all stated constraints
- 1.5: Requirements fit with minor adjustments needed
- 0.5: Requirements significantly exceed constraints
- 0.0: Requirements impossible given constraints

---

### 3. Dependency Availability (2.0 points)

**Check**: Required dependencies are available and accessible

**Available Dependencies Examples**:
- ✅ "Use SendGrid for email" (public API available)
- ✅ "PostgreSQL database" (open source, widely supported)
- ✅ "JWT tokens" (standard library support)

**Questionable Dependencies Examples**:
- ⚠️ "Integrate with internal legacy system (no API docs available)"
- ⚠️ "Use proprietary XYZ service (no access yet)"
- ❌ "Requires access to restricted government database"

**Verification**:
```typescript
// Check each dependency
const dependencies = extractDependencies(ideaMd)

dependencies.forEach(dep => {
  // Check availability
  const isAvailable = checkAvailability(dep)
  const hasDocumentation = checkDocs(dep)
  const isAccessible = checkAccess(dep)

  if (!isAvailable || !hasDocumentation || !isAccessible) {
    // Flag: Dependency risk
  }
})
```

**Scoring**:
- 2.0: All dependencies available and accessible
- 1.5: Most dependencies available (1-2 need investigation)
- 1.0: Several dependencies unavailable or uncertain
- 0.0: Critical dependencies unavailable

---

### 4. Scope Realism (1.5 points)

**Check**: "Must Have" scope is realistic for MVP

**Realistic MVP Scope**:
- ✅ 3-5 core features
- ✅ Focused on single use case
- ✅ Can be completed in stated timeframe

**Unrealistic MVP Scope**:
- ❌ 15+ features in MVP
- ❌ Trying to solve too many problems at once
- ❌ Feature list that would take 6 months for a team

**Evaluation**:
```typescript
const mustHaveFeatures = extractMustHaveFeatures(ideaMd)

// Check feature count
if (mustHaveFeatures.length > 7) {
  // Warning: Scope too large for MVP
}

// Check feature complexity
const complexFeatures = mustHaveFeatures.filter(f => isComplex(f))
if (complexFeatures.length > 2) {
  // Warning: Too many complex features
}
```

**Scoring**:
- 1.5: Realistic, focused MVP scope
- 1.0: Slightly ambitious but achievable
- 0.5: Overly ambitious scope
- 0.0: Unrealistic scope

---

### 5. Risk Mitigation Quality (0.5 points)

**Check**: Identified risks have realistic mitigations

**Good Risk Mitigation**:
```markdown
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Email delivery failure | High | Medium | Use SendGrid with AWS SES fallback, implement retry queue |
| Password database breach | Critical | Low | Use bcrypt (cost=10), implement rate limiting, add breach detection |
```

**Poor Risk Mitigation**:
```markdown
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Email delivery failure | High | Medium | Hope it works |
| Password breach | Critical | Low | Be careful |
```

**Scoring**:
- 0.5: All major risks have concrete, actionable mitigations
- 0.3: Most risks have mitigations (some vague)
- 0.0: No mitigations or all mitigations are vague

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Read idea.md and Project Context

```bash
cat .steering/{date}-{feature}/idea.md

# Also check existing codebase
ls -la src/
cat package.json  # or requirements.txt, go.mod, etc.
```

### Step 2: Assess Technical Feasibility

```typescript
// Extract technical requirements
const techRequirements = extractTechnicalRequirements(ideaMd)

techRequirements.forEach(req => {
  // Check against known technologies
  const feasibility = assessFeasibility(req)

  // Consider: Is this standard practice? Is technology mature?
  // Examples:
  // - "JWT auth" → High feasibility (standard)
  // - "Blockchain for session storage" → Low feasibility (overcomplicated)
  // - "AI to predict user behavior" → Medium feasibility (depends on scope)
})
```

### Step 3: Check Resource Alignment

```typescript
// Extract constraints
const timeConstraint = extractConstraint(ideaMd, 'Time')
const techConstraint = extractConstraint(ideaMd, 'Technical')
const resourceConstraint = extractConstraint(ideaMd, 'Resource')

// Extract scope
const mustHave = extractMustHave(ideaMd)
const shouldHave = extractShouldHave(ideaMd)

// Rough effort estimation
const estimatedEffort = estimateEffort(mustHave)

// Compare
if (estimatedEffort > timeConstraint) {
  // Flag: Scope exceeds time constraint
}
```

### Step 4: Verify Dependencies

```typescript
const internalDeps = extractDependencies(ideaMd, 'Internal')
const externalDeps = extractDependencies(ideaMd, 'External')

// Check if internal dependencies exist
internalDeps.forEach(dep => {
  const exists = checkCodebaseFor(dep)
  if (!exists) {
    // Flag: Internal dependency doesn't exist
  }
})

// Check if external dependencies are accessible
externalDeps.forEach(dep => {
  const isPublic = checkPublicAvailability(dep)
  const hasDocs = checkDocumentation(dep)

  if (!isPublic || !hasDocs) {
    // Flag: External dependency risk
  }
})
```

### Step 5: Evaluate Scope Realism

```typescript
const mustHaveCount = mustHave.length

// Rule of thumb: MVP should have 3-5 core features
if (mustHaveCount > 7) {
  // Warning: Scope too large
} else if (mustHaveCount < 2) {
  // Warning: Scope too small (not useful)
}

// Check complexity
const complexityScore = mustHave.reduce((sum, feature) =>
  sum + estimateComplexity(feature), 0
)

if (complexityScore > threshold) {
  // Warning: Too complex for MVP
}
```

### Step 6: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase1-requirements-feasibility.md`

---

## 📝 Report Template

```markdown
# Phase 1: Requirements Feasibility Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: requirements-feasibility-evaluator
**Date**: {evaluation-date}
**Model**: sonnet

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Technical Feasibility: {score}/3.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Feasible Requirements** ({count}):
- ✅ "{requirement 1}" - Feasibility: High, Technology: {technology}
- ✅ "{requirement 2}" - Feasibility: High, Technology: {technology}

**Questionable Requirements** ({count}):
- ⚠️ "{requirement 3}" - Feasibility: Medium
  - Concern: {what makes it difficult}
  - Recommendation: {how to make it feasible}

**Infeasible Requirements** ({count}):
- ❌ "{requirement 4}" - Feasibility: Low/Impossible
  - Problem: {why it's infeasible}
  - Recommendation: {alternative approach}

---

### 2. Resource Alignment: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Constraints**:
- Time: {time constraint}
- Technical: {technical constraint}
- Resources: {resource constraint}

**Scope Analysis**:
- Must Have features: {count}
- Estimated effort: {rough estimate}
- Constraint capacity: {available capacity}

**Alignment**: {✅ Aligned | ⚠️ Tight fit | ❌ Exceeds constraints}

**Issues**:
- {Issue 1: Scope vs time mismatch}
- {Issue 2: Technical constraint conflict}

**Recommendation**: {How to align scope with constraints}

---

### 3. Dependency Availability: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Internal Dependencies** ({count}):
- ✅ {dependency 1} - Exists: Yes, Location: {path}
- ⚠️ {dependency 2} - Exists: No
  - Recommendation: Create before starting feature

**External Dependencies** ({count}):
- ✅ {dependency 1} - Available: Yes, Docs: Yes
- ⚠️ {dependency 2} - Available: Yes, Docs: Limited
  - Recommendation: Investigate API before committing

**Dependency Risks**:
- {Risk 1}
- {Risk 2}

---

### 4. Scope Realism: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**MVP Scope**: {count} Must Have features

**Complexity Analysis**:
- Simple features: {count}
- Medium features: {count}
- Complex features: {count}

**Realism Assessment**: {✅ Realistic | ⚠️ Ambitious | ❌ Unrealistic}

**Issues**:
- {Issue: Too many features for MVP}
- {Issue: Complexity too high}

**Recommendation**: {How to make scope more realistic}

---

### 5. Risk Mitigation Quality: {score}/0.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Risks with Good Mitigations** ({count}):
- ✅ {risk 1}: {mitigation}

**Risks with Weak Mitigations** ({count}):
- ⚠️ {risk 2}: "{vague mitigation}"
  - Recommendation: {specific mitigation strategy}

**Unmitigated Risks** ({count}):
- ❌ {risk 3}: No mitigation
  - Recommendation: {proposed mitigation}

---

## 🎯 Recommendations

### Required Changes

1. **{Category}**: {Change needed}
   - Current: {current state}
   - Needed: {required state}
   - Reason: {why this change is necessary}

2. **{Category}**: {Change needed}

### Feasibility Improvements

1. {Improvement 1}
2. {Improvement 2}

### Risk Mitigations

1. {Risk}: Add mitigation "{specific mitigation}"
2. {Risk}: Improve mitigation from "{vague}" to "{specific}"

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

**Feasibility Assessment**: {High | Medium | Low}

{Summary paragraph about overall feasibility}

---

**Evaluator**: requirements-feasibility-evaluator
**Model**: sonnet
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Unrealistic Performance Requirements

**Problem**: "System must handle 100M requests/second on single server"

**Reality Check**: Even Google doesn't handle this on a single server

**Fix**: "System should handle 1000 requests/second with horizontal scaling capability"

---

### Issue 2: Scope Too Large for Constraints

**Problem**:
- Constraint: "2 weeks"
- Scope: 15 must-have features

**Fix**: Reduce to 3-4 core features for MVP

---

### Issue 3: Dependency on Unavailable Systems

**Problem**: "Integrate with legacy System X (no API, no documentation)"

**Fix**: "Phase 1: Build without legacy integration. Phase 2: Add integration after API is documented"

---

### Issue 4: Technology Mismatch

**Problem**: Requirements need real-time websockets, but codebase is REST-only

**Fix**: Either: (a) Add websocket capability, or (b) Revise requirements to work with REST

---

## 🎓 Best Practices

### 1. Sanity Check Against Current Codebase

```bash
# Check what technology is currently used
cat package.json
# Ensure requirements align with existing stack
```

### 2. Use Industry Benchmarks

- Authentication: JWT is standard (feasible)
- Real-time: WebSockets are proven (feasible)
- AI predictions: Depends heavily on scope (investigate)

### 3. Consider Team Capability

Requirements should match team's current skill level or include time for learning

### 4. Break Down Ambitious Goals

```markdown
❌ Must Have: Full AI-powered recommendation engine
✅ Must Have: Basic collaborative filtering recommendations
✅ Should Have: ML-based recommendations (after MVP)
```

---

## 🔄 Integration with Phase 1

This evaluator runs **after** requirements-gatherer completes, in parallel with other Phase 1 evaluators.

If this evaluator fails (< 8.0), it means requirements are not feasible as stated. The requirements-gatherer must:
1. Discuss feasibility concerns with user
2. Adjust scope, constraints, or approach
3. Update idea.md
4. Re-run all 7 evaluators

---

**This evaluator prevents wasted effort on impossible or unrealistic requirements.**
