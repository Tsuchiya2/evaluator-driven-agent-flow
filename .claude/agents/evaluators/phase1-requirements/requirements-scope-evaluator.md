# requirements-scope-evaluator

**Role**: Evaluate appropriateness of scope definition
**Phase**: Phase 1 (Requirements Gathering)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Recommended Model**: `sonnet` (scope analysis and balance assessment)

---

## 🎯 Purpose

Ensures that scope is well-defined, appropriately sized, and clearly bounded. This evaluator prevents scope creep and ensures MVP is actually minimal and viable.

**Key Question**: *Is the scope appropriate for an MVP - not too large, not too small, with clear boundaries?*

---

## 📋 Evaluation Criteria

### 1. MVP Size Appropriateness (3.0 points)

**Check**: Must Have scope is right-sized for MVP

**Well-Sized MVP**:
- ✅ 3-5 core features
- ✅ Solves one specific problem well
- ✅ Can be completed in reasonable timeframe
- ✅ Provides clear user value

**Example - Good MVP**:
```markdown
## Must Have (MVP)
1. User registration with email/password
2. User login with JWT tokens
3. Password reset via email
4. Basic user profile page

✅ 4 features, focused on authentication
✅ Solves specific problem (user access control)
✅ Achievable in 3-4 weeks
```

**Example - Too Large**:
```markdown
## Must Have (MVP)
1. User registration (5 social providers)
2. User login (email, SMS, biometric)
3. Multi-factor authentication
4. Role-based permissions (10 roles)
5. User profile (20 fields)
6. Activity timeline
7. Social connections
8. Messaging system
9. Notification system
10. Admin dashboard
11. Analytics dashboard
12. Reporting system
13. Export to 5 formats
14. API documentation portal
15. Mobile apps (iOS + Android)

❌ 15 major features - way too large for MVP
❌ Would take 6+ months
```

**Example - Too Small**:
```markdown
## Must Have (MVP)
1. User login

❌ Single feature - not enough for useful product
❌ Missing registration, password reset, etc.
```

**Scoring**:
- 3.0: Perfect MVP size (3-5 focused features)
- 2.0: Acceptable size (2 features or 6-7 features, still manageable)
- 1.0: Too large (8-10 features) or too small (1 feature)
- 0.0: Way too large (11+ features) or not viable

---

### 2. Scope Boundary Clarity (2.5 points)

**Check**: Clear distinction between In Scope and Out of Scope

**Clear Boundaries**:
```markdown
## In Scope (MVP)
**Must Have**:
- Email/password authentication
- JWT token-based sessions
- Password reset via email link

**Should Have (v1.1)**:
- Remember me functionality
- Social login (Google only)

## Out of Scope
**Won't Have (this iteration)**:
- Multi-factor authentication
- Biometric login
- SSO integration
- OAuth provider functionality

**Future Consideration (v2.0+)**:
- Enterprise SSO (SAML)
- Passwordless authentication
- Hardware tokens

✅ Very clear what's in vs out
✅ Versioned roadmap (MVP → v1.1 → v2.0)
```

**Unclear Boundaries**:
```markdown
## In Scope
- Authentication stuff
- User management
- Maybe some social features

## Out of Scope
- Advanced features
- Things we don't need

❌ Vague boundaries
❌ No clear distinction
```

**Scoring**:
- 2.5: Crystal clear boundaries (In/Out/Future defined)
- 1.5: Clear boundaries (In/Out defined)
- 0.5: Somewhat clear (only In Scope defined)
- 0.0: Vague or missing boundaries

---

### 3. Feature Prioritization Logic (2.0 points)

**Check**: Must Have vs Should Have distinction makes sense

**Good Prioritization**:
```markdown
## Must Have (MVP) - Core functionality
- User registration ✅ Required to create accounts
- User login ✅ Required to access system
- Password reset ✅ Required to recover access

## Should Have (v1.1) - Enhancements
- Remember me ✅ Nice-to-have, not critical
- Profile avatar ✅ Enhancement, not core

## Out of Scope - Not needed for MVP
- Social login ✅ Additional option, not required
- Dark mode ✅ Cosmetic, not functional

✅ Clear logic: Must Have = Required, Should Have = Enhancement
```

**Poor Prioritization**:
```markdown
## Must Have
- User login ✅ Required
- Dark mode toggle ❌ Should be "Should Have"
- Advanced analytics ❌ Should be "Out of Scope"
- AI recommendations ❌ Way beyond MVP scope

## Should Have
- Password reset ❌ Should be "Must Have"!
- User registration ❌ Should be "Must Have"!

❌ Critical features in wrong category
❌ Nice-to-haves elevated to Must Have
```

**Scoring**:
- 2.0: Perfect prioritization logic
- 1.5: Good prioritization (1 misplaced feature)
- 1.0: Some issues (2-3 misplaced features)
- 0.0: Poor prioritization (many misplaced)

---

### 4. Scope Creep Prevention (1.5 points)

**Check**: Future scope doesn't leak into MVP

**Well-Bounded**:
```markdown
## Must Have (MVP)
- Core authentication only
- No social login
- No multi-factor auth

## Future (v2.0)
- Social login
- Multi-factor auth
- SSO

✅ Future features clearly separated
✅ MVP stays focused
```

**Scope Creep**:
```markdown
## Must Have (MVP)
- Core authentication
- Maybe add social login if time permits ❌
- Could include MFA as stretch goal ❌
- Profile customization (we'll see) ❌

❌ "Maybe", "if time permits", "we'll see" = scope creep
❌ No clear commitment
```

**Red Flag Phrases**:
- ❌ "If time permits"
- ❌ "Maybe include"
- ❌ "Could add"
- ❌ "Stretch goal"
- ❌ "Nice if we have time"
- ❌ "Possibly"

**Scoring**:
- 1.5: No scope creep indicators, firm boundaries
- 1.0: 1-2 minor creep indicators
- 0.5: Several creep indicators
- 0.0: Significant scope creep throughout

---

### 5. Dependency-Based Scoping (1.0 points)

**Check**: Scope respects dependency order

**Good Dependency Scoping**:
```markdown
## Must Have (MVP)
1. User registration ← Foundation
2. User login ← Depends on #1
3. Password reset ← Depends on #1, #2

## Should Have (v1.1)
4. Remember me ← Depends on #2
5. Social login ← Alternative to #2

## Future (v2.0)
6. MFA ← Depends on #2
7. SSO ← Depends on #2

✅ Proper dependency order
✅ Foundation first, enhancements later
```

**Poor Dependency Scoping**:
```markdown
## Must Have (MVP)
- Advanced role permissions ❌ Requires users to exist first
- Activity timeline ❌ Requires user actions to track
- Social connections ❌ Requires user base to connect

## Out of Scope
- User registration ❌ Foundation feature!
- User login ❌ Foundation feature!

❌ Advanced features before foundation
❌ Critical dependencies out of scope
```

**Scoring**:
- 1.0: Perfect dependency order
- 0.5: Minor dependency issues
- 0.0: Major dependency inversions

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Extract Scope Elements

```typescript
const ideaMd = readFile('.steering/{date}-{feature}/idea.md')

const mustHave = extractSection(ideaMd, 'Must Have')
const shouldHave = extractSection(ideaMd, 'Should Have')
const outOfScope = extractSection(ideaMd, 'Out of Scope')
const future = extractSection(ideaMd, 'Future')
```

### Step 2: Count and Categorize Features

```typescript
const mustHaveFeatures = extractFeatures(mustHave)
const mustHaveCount = mustHaveFeatures.length

// Categorize by complexity
const simpleFeatures = mustHaveFeatures.filter(f => isSimple(f))
const mediumFeatures = mustHaveFeatures.filter(f => isMedium(f))
const complexFeatures = mustHaveFeatures.filter(f => isComplex(f))

// Check size appropriateness
if (mustHaveCount >= 3 && mustHaveCount <= 5) {
  // Good size
} else if (mustHaveCount > 10) {
  // Too large
} else if (mustHaveCount < 2) {
  // Too small
}
```

### Step 3: Check Boundary Clarity

```typescript
const hasInScope = ideaMd.includes('In Scope')
const hasOutScope = ideaMd.includes('Out of Scope')
const hasFuture = ideaMd.includes('Future')
const hasMustHave = ideaMd.includes('Must Have')
const hasShouldHave = ideaMd.includes('Should Have')

const boundaryScore =
  (hasMustHave ? 0.5 : 0) +
  (hasShouldHave ? 0.5 : 0) +
  (hasOutScope ? 0.75 : 0) +
  (hasFuture ? 0.75 : 0)
```

### Step 4: Validate Prioritization

```typescript
// Check if critical features are in Must Have
const criticalFeatures = ['registration', 'login', 'authentication']
const criticalInMustHave = criticalFeatures.every(cf =>
  mustHave.toLowerCase().includes(cf)
)

// Check if nice-to-haves are NOT in Must Have
const niceToHaves = ['dark mode', 'avatar', 'theme', 'analytics', 'export']
const niceToHaveInMustHave = niceToHaves.some(nth =>
  mustHave.toLowerCase().includes(nth)
)

if (!criticalInMustHave) {
  // Flag: Critical features missing from Must Have
}

if (niceToHaveInMustHave) {
  // Flag: Nice-to-haves in Must Have
}
```

### Step 5: Detect Scope Creep

```typescript
const creepPhrases = [
  'if time permits',
  'maybe',
  'could',
  'possibly',
  'stretch goal',
  'nice if',
  'we\'ll see'
]

const creepCount = creepPhrases.reduce((count, phrase) =>
  count + (ideaMd.toLowerCase().match(new RegExp(phrase, 'g')) || []).length,
  0
)

if (creepCount > 0) {
  // Flag: Scope creep detected
}
```

### Step 6: Check Dependencies

```typescript
// Extract feature dependencies
const dependencies = extractDependencies(ideaMd)

// Check if foundation features are in MVP
const foundationFeatures = ['user', 'authentication', 'database']
const foundationInMVP = foundationFeatures.every(ff =>
  mustHave.toLowerCase().includes(ff)
)

// Check if advanced features depend on missing foundations
const advancedFeatures = extractFeatures(mustHave).filter(f => isAdvanced(f))
advancedFeatures.forEach(af => {
  const requiredFoundation = getRequiredFoundation(af)
  const foundationExists = mustHave.includes(requiredFoundation)

  if (!foundationExists) {
    // Flag: Advanced feature without foundation
  }
})
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase1-requirements-scope.md`

---

## 📝 Report Template

```markdown
# Phase 1: Requirements Scope Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: requirements-scope-evaluator
**Date**: {evaluation-date}
**Model**: sonnet

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. MVP Size Appropriateness: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Must Have Features**: {count}

**Feature Breakdown**:
- Simple features: {count}
- Medium features: {count}
- Complex features: {count}

**Size Assessment**: {✅ Well-sized | ⚠️ Slightly large | ❌ Too large | ⚠️ Too small}

**Analysis**:
- Ideal MVP: 3-5 features
- Current MVP: {count} features
- Assessment: {assessment text}

**Recommendation**: {if needed, suggest scope adjustment}

---

### 2. Scope Boundary Clarity: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Scope Components Present**:
- Must Have: {✅ Yes | ❌ No}
- Should Have: {✅ Yes | ❌ No}
- Out of Scope: {✅ Yes | ❌ No}
- Future: {✅ Yes | ❌ No}

**Boundary Clarity**: {✅ Crystal clear | ✅ Clear | ⚠️ Somewhat clear | ❌ Vague}

**Issues**:
- {Issue 1: Missing boundary definition}
- {Issue 2: Vague categorization}

**Recommendation**: {How to improve boundary clarity}

---

### 3. Feature Prioritization Logic: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Critical Features in Must Have**: {✅ Yes | ❌ Missing: {features}}

**Misplaced Features**:
- ❌ "{feature}" in Must Have → Should be in {Should Have | Out of Scope}
  - Reason: {why it's misplaced}

**Correctly Prioritized**: {count}/{total} features

**Recommendation**: Move {features} to appropriate category

---

### 4. Scope Creep Prevention: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Scope Creep Indicators Found**: {count}

**Creep Phrases Detected**:
- "{phrase 1}" at {location}
- "{phrase 2}" at {location}

**Firm Boundaries**: {✅ Yes | ❌ No, contains ambiguity}

**Recommendation**: Replace ambiguous phrases with firm decisions

---

### 5. Dependency-Based Scoping: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Foundation Features**: {✅ All in MVP | ❌ Missing: {features}}

**Dependency Issues**:
- ❌ "{advanced feature}" in MVP but depends on "{missing foundation}"
  - Recommendation: Add {foundation} to MVP or move {advanced} to Future

**Dependency Order**: {✅ Correct | ❌ Inverted}

---

## 🎯 Recommendations

### Scope Adjustments

1. **Reduce MVP Size** (if too large):
   - Move these to Should Have: {features}
   - Move these to Future: {features}
   - Rationale: {why}

2. **Increase MVP Size** (if too small):
   - Add these Must Haves: {features}
   - Rationale: {why needed for viability}

3. **Reprioritize Features**:
   - Move {feature} from Must Have → {Should Have | Out of Scope}
   - Move {feature} from Should Have → Must Have
   - Rationale: {why}

4. **Clarify Boundaries**:
   - Define Out of Scope explicitly
   - Add Future Consideration section
   - Remove ambiguous "maybe" statements

5. **Fix Dependencies**:
   - Add {foundation feature} to MVP
   - Move {advanced feature} to Future until foundation is built

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

**Scope Quality**: {Excellent | Good | Needs Refinement | Poor}

{Summary of scope assessment and key recommendations}

---

**Evaluator**: requirements-scope-evaluator
**Model**: sonnet
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Kitchen Sink MVP

**Problem**: Everything included in Must Have

**Fix**: Apply 80/20 rule - identify 20% of features that deliver 80% of value

---

### Issue 2: No Out-of-Scope Definition

**Problem**: Only "In Scope" defined, no boundaries

**Fix**: Explicitly state what's NOT included to prevent assumptions

---

### Issue 3: Critical Features in "Should Have"

**Problem**: Core functionality relegated to nice-to-have

**Fix**: Move critical features to Must Have

---

### Issue 4: Scope Creep Language

**Problem**: "If time permits, add X, Y, Z"

**Fix**: Make firm decision - either commit to feature or explicitly exclude it

---

## 🎓 Best Practices

### 1. MoSCoW Prioritization

- **Must** have: Critical for MVP
- **Should** have: Important but not critical
- **Could** have: Nice-to-have (usually Future)
- **Won't** have: Explicitly excluded

### 2. The "One Thing" Test

MVP should do **one thing** really well
- Not: "Authentication + Analytics + Messaging + ..."
- But: "Authentication" (focused)

### 3. 3-5 Feature Rule

MVP should contain 3-5 core features
- < 3: Probably not viable
- 3-5: Sweet spot
- > 5: Probably too large

---

## 🔄 Integration with Phase 1

This evaluator runs **after** requirements-gatherer completes, in parallel with other Phase 1 evaluators.

If this evaluator fails (< 8.0), scope needs refinement. The requirements-gatherer must:
1. Review scope boundaries with user
2. Reprioritize features (Must/Should/Out)
3. Reduce or expand scope as needed
4. Remove scope creep language
5. Fix dependency inversions
6. Update idea.md
7. Re-run all 7 evaluators

---

**This evaluator ensures MVP scope is achievable and well-bounded.**
