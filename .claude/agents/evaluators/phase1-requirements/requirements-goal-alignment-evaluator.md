# requirements-goal-alignment-evaluator

**Role**: Evaluate alignment between requirements and stated goals
**Phase**: Phase 1 (Requirements Gathering)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Recommended Model**: `haiku` (pattern matching and alignment checks)

---

## 🎯 Purpose

Ensures that requirements directly support the stated problem and goals. This evaluator prevents scope creep and ensures features actually solve the problem they're meant to address.

**Key Question**: *Do all requirements contribute to solving the stated problem and achieving the stated goals?*

---

## 📋 Evaluation Criteria

### 1. Problem-Solution Alignment (3.0 points)

**Check**: Requirements directly address the stated problem

**Well-Aligned Example**:
```markdown
## Problem
Users cannot access their data securely. Currently, anyone can access any user's information.

## Solution
Implement user authentication with JWT tokens.

## Requirements (Must Have)
- User registration with email/password ✅ Solves access control
- User login with JWT tokens ✅ Solves authentication
- Password hashing with bcrypt ✅ Solves security
- Session management ✅ Solves access persistence
```

**Poorly Aligned Example**:
```markdown
## Problem
Users cannot access their data securely.

## Solution
Implement user authentication.

## Requirements (Must Have)
- User registration ✅ Solves problem
- User login ✅ Solves problem
- Dark mode toggle ❌ Doesn't solve stated problem
- Advanced analytics dashboard ❌ Doesn't solve stated problem
- Export data to PDF ❌ Doesn't solve stated problem
```

**Scoring**:
- 3.0: All must-have requirements directly solve stated problem
- 2.0: Most requirements aligned (1-2 nice-to-haves in must-have)
- 1.0: Several requirements unrelated to problem
- 0.0: Requirements don't address problem

---

### 2. Goal-Feature Traceability (2.5 points)

**Check**: Each requirement maps to at least one stated goal

**Traceable Example**:
```markdown
## Goals
1. Enable secure user authentication
2. Protect user data from unauthorized access
3. Provide seamless login experience

## Requirements Mapping
- User registration → Goal 1 (enable authentication) ✅
- Email/password login → Goal 1 (enable authentication) ✅
- JWT tokens → Goal 2 (protect data) ✅
- httpOnly cookies → Goal 2 (protect data) ✅
- Remember me → Goal 3 (seamless experience) ✅
- Password reset → Goal 3 (seamless experience) ✅
```

**Non-Traceable Example**:
```markdown
## Goals
1. Enable user authentication

## Requirements
- User login ✅ Maps to goal
- Social media integration ❓ No goal for this
- AI-powered recommendations ❓ No goal for this
- Blockchain ledger ❓ No goal for this
```

**Scoring**:
- 2.5: All requirements trace to stated goals
- 1.5: Most requirements traceable (1-2 orphaned)
- 0.5: Several requirements don't trace to goals
- 0.0: Many requirements unrelated to goals

---

### 3. Success Criteria Alignment (2.0 points)

**Check**: Success criteria measure goal achievement

**Aligned Success Criteria**:
```markdown
## Goal
Provide secure, easy-to-use authentication

## Success Criteria
- Login success rate ≥ 95% ✅ Measures "easy-to-use"
- Password strength ≥ 8 characters ✅ Measures "secure"
- Login time < 2 seconds ✅ Measures "easy-to-use"
- Zero password breaches ✅ Measures "secure"
- 90% users complete registration ✅ Measures "easy-to-use"
```

**Misaligned Success Criteria**:
```markdown
## Goal
Provide secure authentication

## Success Criteria
- Pretty UI ❌ Doesn't measure security
- Many color themes ❌ Doesn't measure authentication
- Code is well-commented ❌ Internal metric, not goal-related
```

**Scoring**:
- 2.0: All success criteria directly measure goal achievement
- 1.5: Most criteria aligned (1-2 indirect)
- 1.0: Several criteria don't measure goals
- 0.0: Success criteria unrelated to goals

---

### 4. Out-of-Scope Justification (1.5 points)

**Check**: Items in "Out of Scope" are genuinely out of scope, not missing requirements

**Justified Out-of-Scope**:
```markdown
## Goals
Enable basic user authentication

## Out of Scope
- Multi-factor authentication ✅ Beyond "basic" goal
- Biometric authentication ✅ Not needed for basic goal
- SSO integration ✅ Future enhancement, not core goal
- OAuth provider ✅ Different use case
```

**Unjustified Out-of-Scope**:
```markdown
## Goals
Provide secure user authentication

## Out of Scope
- Password hashing ❌ Required for security goal!
- Session management ❌ Required for authentication!
- HTTPS ❌ Required for security!
```

**Scoring**:
- 1.5: All out-of-scope items correctly excluded
- 1.0: Most items justified (1-2 questionable)
- 0.5: Several items should be in scope
- 0.0: Out-of-scope contains required features

---

### 5. No Gold Plating (1.0 points)

**Check**: No unnecessary features added beyond what's needed

**Focused (Good)**:
```markdown
## Problem
Users need to log in securely

## Must Have
- User login with email/password
- Password hashing
- JWT tokens
- Session management

✅ Minimal, focused feature set
```

**Gold Plated (Bad)**:
```markdown
## Problem
Users need to log in securely

## Must Have
- User login with email/password
- Password hashing
- JWT tokens
- Session management
- Advanced user profile with avatar upload ❌ Gold plating
- Activity timeline ❌ Gold plating
- Social connections ❌ Gold plating
- Gamification badges ❌ Gold plating
- Custom themes per user ❌ Gold plating
```

**Scoring**:
- 1.0: No unnecessary features (lean MVP)
- 0.5: 1-2 nice-to-have features in must-have
- 0.0: Significant gold plating

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Extract Key Elements

```typescript
// Read idea.md
const ideaMd = readFile('.steering/{date}-{feature}/idea.md')

// Extract problem, goals, and requirements
const problem = extractSection(ideaMd, 'Problem')
const solution = extractSection(ideaMd, 'Solution')
const goals = extractSection(ideaMd, 'Why')
const mustHave = extractSection(ideaMd, 'Must Have')
const shouldHave = extractSection(ideaMd, 'Should Have')
const outOfScope = extractSection(ideaMd, 'Out of Scope')
const successCriteria = extractSection(ideaMd, 'Success Criteria')
```

### Step 2: Check Problem-Solution Alignment

```typescript
const requirements = extractRequirements(mustHave)

requirements.forEach(req => {
  // Check if requirement addresses problem
  const addressesProblem = doesAddressProblem(req, problem)

  if (!addressesProblem) {
    // Flag: Requirement doesn't solve stated problem
  }
})
```

### Step 3: Trace Goals to Requirements

```typescript
const goalList = extractGoals(goals)

goalList.forEach(goal => {
  // Find requirements that support this goal
  const supportingReqs = requirements.filter(req =>
    supportsGoal(req, goal)
  )

  if (supportingReqs.length === 0) {
    // Flag: Goal has no supporting requirements
  }
})

// Also check reverse: requirements without goals
requirements.forEach(req => {
  const supportsAnyGoal = goalList.some(goal =>
    supportsGoal(req, goal)
  )

  if (!supportsAnyGoal) {
    // Flag: Orphaned requirement (no goal)
  }
})
```

### Step 4: Validate Success Criteria

```typescript
const criteria = extractCriteria(successCriteria)

criteria.forEach(criterion => {
  // Check if criterion measures goal achievement
  const measuresGoal = goalList.some(goal =>
    measureGoalAchievement(criterion, goal)
  )

  if (!measuresGoal) {
    // Flag: Success criterion doesn't measure goals
  }
})
```

### Step 5: Check Out-of-Scope Justification

```typescript
const outOfScopeItems = extractItems(outOfScope)

outOfScopeItems.forEach(item => {
  // Check if item should actually be in scope
  const isNecessary = isNecessaryForGoals(item, goalList)

  if (isNecessary) {
    // Flag: Out-of-scope item is actually required
  }
})
```

### Step 6: Detect Gold Plating

```typescript
const allFeatures = [...mustHave, ...shouldHave]

allFeatures.forEach(feature => {
  // Check if feature is necessary for stated goals
  const isNecessary = isNecessaryForGoals(feature, goalList)

  if (!isNecessary && !isNiceToHave(feature, shouldHave)) {
    // Flag: Gold plating detected
  }
})
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase1-requirements-goal-alignment.md`

---

## 📝 Report Template

```markdown
# Phase 1: Requirements Goal Alignment Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: requirements-goal-alignment-evaluator
**Date**: {evaluation-date}
**Model**: haiku

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Problem-Solution Alignment: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Stated Problem**:
"{problem statement}"

**Requirements Addressing Problem** ({count}):
- ✅ "{requirement 1}" → Solves {aspect of problem}
- ✅ "{requirement 2}" → Solves {aspect of problem}

**Requirements NOT Addressing Problem** ({count}):
- ❌ "{requirement 3}"
  - Does not address stated problem
  - Recommendation: {Remove | Move to Should Have | Justify how it solves problem}

---

### 2. Goal-Feature Traceability: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Goals**: {count}

**Traceability Matrix**:

Goal 1: "{goal 1}"
- ✅ {requirement 1}
- ✅ {requirement 2}

Goal 2: "{goal 2}"
- ✅ {requirement 3}

**Orphaned Requirements** ({count} - no goal mapping):
- ❌ "{requirement X}"
  - Recommendation: {Add goal | Remove requirement | Justify}

**Goals Without Requirements** ({count}):
- ❌ Goal: "{goal Y}"
  - Recommendation: Add requirements to achieve this goal

---

### 3. Success Criteria Alignment: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Aligned Criteria** ({count}):
- ✅ "{criterion 1}" → Measures Goal: "{goal}"
- ✅ "{criterion 2}" → Measures Goal: "{goal}"

**Misaligned Criteria** ({count}):
- ❌ "{criterion 3}"
  - Does not measure any stated goal
  - Recommendation: {Remove | Revise to measure {goal}}

---

### 4. Out-of-Scope Justification: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Correctly Out-of-Scope** ({count}):
- ✅ "{item 1}" - Justification: {why it's out of scope}

**Questionable Out-of-Scope** ({count}):
- ⚠️ "{item 2}"
  - Concern: This may be required for Goal "{goal}"
  - Recommendation: Reconsider including in MVP

**Should Be In Scope** ({count}):
- ❌ "{item 3}"
  - Problem: Required for Goal "{goal}"
  - Recommendation: Move to Must Have

---

### 5. No Gold Plating: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Necessary Features** ({count}):
- ✅ All must-have features support stated goals

**Potential Gold Plating** ({count}):
- ⚠️ "{feature 1}"
  - Concern: Not directly required for any goal
  - Recommendation: Move to Should Have or Future

**Definite Gold Plating** ({count}):
- ❌ "{feature 2}"
  - Problem: Unrelated to any goal
  - Recommendation: Remove from MVP

---

## 🎯 Recommendations

### Alignment Improvements

1. **Remove/Relocate Features**:
   - {Feature 1}: Move to "Should Have" (nice-to-have, not critical)
   - {Feature 2}: Remove (gold plating)

2. **Add Missing Requirements**:
   - Goal "{goal}" has no requirements → Add: {suggested requirement}

3. **Clarify Goal Connection**:
   - Requirement "{req}" seems unrelated → Clarify how it supports: {goal}

4. **Refine Success Criteria**:
   - "{criterion}" doesn't measure goals → Change to: {revised criterion}

5. **Reconsider Out-of-Scope**:
   - "{item}" may be needed for "{goal}" → Move to Must Have

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

**Alignment Level**: {Excellent | Good | Needs Improvement | Poor}

{Summary of goal alignment assessment}

---

**Evaluator**: requirements-goal-alignment-evaluator
**Model**: haiku
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Scope Creep in Must Have

**Problem**: Must Have contains features unrelated to stated goals

**Example**:
- Goal: "Enable user authentication"
- Must Have: Authentication ✅ + Dark mode ❌ + Analytics ❌ + Export ❌

**Fix**: Move unrelated features to Should Have or Future

---

### Issue 2: Goals Without Requirements

**Problem**: Goal stated but no requirements to achieve it

**Example**:
- Goal: "Provide seamless login experience"
- Requirements: (none related to UX)

**Fix**: Add requirements like "Remember me", "Password reset", "Clear error messages"

---

### Issue 3: Requirements Without Goals

**Problem**: Features added without stated goal

**Example**:
- Requirements: Social sharing buttons
- Goals: (no mention of social features)

**Fix**: Either add goal or remove feature

---

### Issue 4: Success Criteria Don't Measure Goals

**Problem**: Criteria measure wrong things

**Example**:
- Goal: "Secure authentication"
- Criteria: "Pretty login form" ❌

**Fix**: Change to "Zero password breaches", "bcrypt cost ≥ 10"

---

## 🎓 Best Practices

### 1. Traceability Matrix

Create explicit mapping:
```markdown
Goal 1 → Requirements A, B, C
Goal 2 → Requirements D, E
```

### 2. The "Why" Test

For each requirement, ask: "Why is this needed?"
- If answer is a stated goal → ✅ Keep
- If answer is "nice to have" → Move to Should Have
- If no clear answer → ❌ Remove

### 3. Minimum Viable Product Mindset

MVP should contain **only** what's needed to solve the problem
- Not: "All features we can think of"
- But: "Minimum features to achieve goals"

---

## 🔄 Integration with Phase 1

This evaluator runs **after** requirements-gatherer completes, in parallel with other Phase 1 evaluators.

If this evaluator fails (< 8.0), requirements have alignment issues. The requirements-gatherer must:
1. Review misaligned requirements with user
2. Remove gold-plated features
3. Add missing requirements for stated goals
4. Clarify goal connections
5. Update idea.md
6. Re-run all 7 evaluators

---

**This evaluator ensures every requirement has a purpose and contributes to solving the actual problem.**
