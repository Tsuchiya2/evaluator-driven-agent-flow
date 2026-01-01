# requirements-testability-evaluator

**Role**: Evaluate testability of requirements
**Phase**: Phase 1 (Requirements Gathering)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Recommended Model**: `haiku` (pattern matching for testability checks)

---

## 🎯 Purpose

Ensures that requirements can be tested and verified. This evaluator prevents untestable requirements from entering Phase 2 (Design), ensuring quality can be validated later.

**Key Question**: *Can we write tests to verify that these requirements have been successfully implemented?*

---

## 📋 Evaluation Criteria

### 1. Observable Behavior (3.0 points)

**Check**: Requirements describe observable, verifiable behavior

**Observable (Testable)**:
- ✅ "User can register with email and password"
  - Test: Submit registration form, verify account created
- ✅ "Login returns JWT token with 15-minute expiry"
  - Test: Login, check token expiry timestamp
- ✅ "Password must be 8+ characters"
  - Test: Submit 7-char password, expect validation error

**Non-Observable (Untestable)**:
- ❌ "System should feel responsive"
  - Cannot test "feel"
- ❌ "User experience should be good"
  - "Good" is subjective
- ❌ "Code should be maintainable"
  - Not observable from user perspective

**Fix**: Convert to measurable criteria
- ✅ "API response time < 200ms"
- ✅ "Login success rate ≥ 95%"
- ✅ "Cyclomatic complexity < 10"

**Scoring**:
- 3.0: All requirements have observable behavior
- 2.0: Most requirements observable (1-2 subjective)
- 1.0: Several subjective requirements
- 0.0: Many untestable requirements

---

### 2. Measurable Success Criteria (2.5 points)

**Check**: Success criteria can be objectively measured

**Measurable Criteria**:
- ✅ "Login completes in < 2 seconds"
  - Test: Measure login time
- ✅ "Password must contain 1 uppercase, 1 lowercase, 1 number"
  - Test: Validate password regex
- ✅ "System supports 1000 concurrent users"
  - Test: Load testing with 1000 users

**Non-Measurable Criteria**:
- ❌ "Fast login"
  - What is "fast"?
- ❌ "Strong passwords"
  - What is "strong"?
- ❌ "Many concurrent users"
  - How many is "many"?

**Scoring**:
- 2.5: All success criteria measurable
- 1.5: Most criteria measurable (1-2 vague)
- 0.5: Several vague criteria
- 0.0: No measurable criteria

---

### 3. Testable Acceptance Criteria (2.0 points)

**Check**: Each user story has clear acceptance criteria

**Well-Defined Acceptance Criteria**:
```markdown
**User Story**: As a new user, I want to register with email/password

**Acceptance Criteria**:
- [ ] Registration form has email and password fields
- [ ] Email must be valid format (contains @)
- [ ] Password must be 8+ characters
- [ ] Submit button sends POST to /api/auth/register
- [ ] Success returns 201 status + user object
- [ ] Duplicate email returns 409 status
- [ ] User receives verification email
```

**Missing Acceptance Criteria**:
```markdown
**User Story**: As a user, I want to log in

(No acceptance criteria)
```

**Vague Acceptance Criteria**:
```markdown
**User Story**: As a user, I want to log in

**Acceptance Criteria**:
- Login should work
- User gets authenticated
```

**Scoring**:
- 2.0: All user stories have clear, testable acceptance criteria
- 1.5: Most stories have criteria (1-2 missing)
- 1.0: Several stories lack clear criteria
- 0.0: No acceptance criteria defined

---

### 4. Verifiable Non-Functional Requirements (1.5 points)

**Check**: Non-functional requirements can be tested

**Verifiable NFRs**:
- ✅ "Performance: API response < 200ms (95th percentile)"
  - Test: Performance monitoring
- ✅ "Security: Passwords hashed with bcrypt (cost ≥ 10)"
  - Test: Verify bcrypt implementation
- ✅ "Availability: 99.9% uptime"
  - Test: Monitor downtime
- ✅ "Scalability: Support 10,000 concurrent users"
  - Test: Load testing

**Non-Verifiable NFRs**:
- ❌ "Performance: Should be fast"
  - How to test "fast"?
- ❌ "Security: Should be secure"
  - What does "secure" mean?
- ❌ "Scalability: Handle many users"
  - How many?

**Scoring**:
- 1.5: All NFRs verifiable with specific metrics
- 1.0: Most NFRs verifiable (1-2 vague)
- 0.5: Several vague NFRs
- 0.0: No verifiable NFRs

---

### 5. Error Scenario Coverage (1.0 points)

**Check**: Error cases and edge cases are defined

**Good Error Coverage**:
```markdown
## Functional Criteria
- [ ] User can log in with valid credentials
- [ ] Invalid email shows error message
- [ ] Invalid password shows error message
- [ ] Expired token shows 401 error
- [ ] Rate limit exceeded shows 429 error
- [ ] Server error shows 500 with message
```

**Missing Error Coverage**:
```markdown
## Functional Criteria
- [ ] User can log in

(No error scenarios)
```

**Scoring**:
- 1.0: Error scenarios well-defined
- 0.5: Some error scenarios defined
- 0.0: No error scenarios

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Extract Requirements

```typescript
const ideaMd = readFile('.steering/{date}-{feature}/idea.md')

const functionalReqs = extractSection(ideaMd, 'What')
const userStories = extractUserStories(ideaMd)
const successCriteria = extractSection(ideaMd, 'Success Criteria')
const nfrs = extractNFRs(successCriteria)
```

### Step 2: Check Observable Behavior

```typescript
const subjectiveTerms = ['good', 'bad', 'easy', 'hard', 'fast', 'slow', 'nice', 'feel', 'intuitive', 'simple', 'complex']

functionalReqs.forEach(req => {
  const hasSubjectiveTerm = subjectiveTerms.some(term =>
    req.toLowerCase().includes(term)
  )

  const hasMeasurableCriterion = /\d+|<|>|≤|≥|%/.test(req)

  if (hasSubjectiveTerm && !hasMeasurableCriterion) {
    // Flag: Subjective, non-observable requirement
  }
})
```

### Step 3: Check Measurability

```typescript
const criteria = extractCriteria(successCriteria)

criteria.forEach(criterion => {
  // Check for measurable metrics
  const hasMeasurement =
    /\d+/.test(criterion) ||          // Contains numbers
    /<|>|≤|≥/.test(criterion) ||      // Contains comparisons
    /%/.test(criterion) ||             // Contains percentages
    /seconds?|minutes?/.test(criterion) // Contains time units

  if (!hasMeasurement) {
    // Flag: Non-measurable criterion
  }
})
```

### Step 4: Check Acceptance Criteria

```typescript
userStories.forEach(story => {
  // Look for acceptance criteria after the story
  const hasAcceptanceCriteria =
    ideaMd.includes('Acceptance Criteria') ||
    ideaMd.includes('- [ ]')  // Checkbox format

  if (!hasAcceptanceCriteria) {
    // Flag: User story without acceptance criteria
  }

  // Check if acceptance criteria are testable
  const acceptanceCriteria = extractAcceptanceCriteria(story)
  acceptanceCriteria.forEach(ac => {
    const isTestable = isObservableAndMeasurable(ac)
    if (!isTestable) {
      // Flag: Untestable acceptance criterion
    }
  })
})
```

### Step 5: Check NFR Verifiability

```typescript
const nfrCategories = ['Performance', 'Security', 'Usability', 'Scalability', 'Availability']

nfrCategories.forEach(category => {
  const nfr = extractNFR(successCriteria, category)

  if (nfr) {
    const hasMetric = /\d+|<|>|%/.test(nfr)

    if (!hasMetric) {
      // Flag: Non-verifiable NFR
    }
  }
})
```

### Step 6: Check Error Scenarios

```typescript
const hasErrorScenarios =
  ideaMd.match(/error|fail|invalid|exception/gi)?.length > 0

const errorCriteria = criteria.filter(c =>
  /error|fail|invalid|exception/i.test(c)
)

if (errorCriteria.length === 0) {
  // Flag: No error scenarios defined
}
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase1-requirements-testability.md`

---

## 📝 Report Template

```markdown
# Phase 1: Requirements Testability Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: requirements-testability-evaluator
**Date**: {evaluation-date}
**Model**: haiku

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Observable Behavior: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Observable Requirements** ({count}):
- ✅ "{requirement 1}" - Observable: {how to observe}
- ✅ "{requirement 2}" - Observable: {how to observe}

**Subjective Requirements** ({count}):
- ❌ "{requirement 3}" - Contains: "{subjective term}"
  - Problem: Not objectively observable
  - Recommendation: Change to "{measurable version}"

**Non-Observable** ({count}):
- ❌ "{requirement 4}"
  - Problem: Cannot verify through testing
  - Recommendation: {how to make observable}

---

### 2. Measurable Success Criteria: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Measurable Criteria** ({count}):
- ✅ "{criterion 1}" - Metric: {metric}
- ✅ "{criterion 2}" - Metric: {metric}

**Non-Measurable Criteria** ({count}):
- ❌ "{criterion 3}"
  - Problem: No specific metric
  - Recommendation: Add metric (e.g., "< 2 seconds", "≥ 95%")

---

### 3. Testable Acceptance Criteria: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**User Stories**: {total}
**With Acceptance Criteria**: {count}
**Without Acceptance Criteria**: {count}

**Well-Defined**:
- ✅ "{story 1}" - Has {count} testable criteria

**Missing or Vague**:
- ❌ "{story 2}" - No acceptance criteria
  - Recommendation: Add criteria defining what "done" means

- ⚠️ "{story 3}" - Vague criteria: "{vague criterion}"
  - Recommendation: Make specific and testable

---

### 4. Verifiable Non-Functional Requirements: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**NFR Categories Evaluated**: {count}

**Verifiable NFRs**:
- ✅ Performance: {specific metric}
- ✅ Security: {specific metric}

**Non-Verifiable NFRs**:
- ❌ {Category}: "{vague NFR}"
  - Problem: No measurable metric
  - Recommendation: Define as "{specific NFR}"

---

### 5. Error Scenario Coverage: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Error Scenarios Defined**: {count}

**Covered**:
- ✅ Invalid input handling
- ✅ Authentication failures

**Missing**:
- ❌ Network error handling
- ❌ Server error responses
- ❌ Rate limiting

**Recommendation**: Add error scenarios for {missing areas}

---

## 🎯 Recommendations

### Make Requirements Testable

1. **{Requirement}**: Change from "{vague}" to "{specific}"
   - Test method: {how to test}

2. **{Requirement}**: Add metric
   - Current: "{current}"
   - Better: "{with metric}"
   - Test method: {how to test}

### Add Acceptance Criteria

1. **{User Story}**: Add criteria:
   - [ ] {criterion 1}
   - [ ] {criterion 2}
   - [ ] {criterion 3}

### Define Error Scenarios

1. Add to success criteria:
   - [ ] {error scenario 1}
   - [ ] {error scenario 2}

### Quantify NFRs

1. **Performance**: Define as "< Xms" or "≥ Y requests/second"
2. **Security**: Define specific measures (bcrypt cost, token expiry, etc.)
3. **Scalability**: Define user/request capacity

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

**Testability Level**: {Excellent | Good | Needs Improvement | Poor}

{Summary of testability assessment}

**Test Coverage Potential**: {High | Medium | Low}

---

**Evaluator**: requirements-testability-evaluator
**Model**: haiku
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Subjective Requirements

**Problem**: "User experience should be good"

**Fix**: "Login success rate ≥ 95%, login time < 2 seconds"

---

### Issue 2: No Acceptance Criteria

**Problem**: User story without definition of "done"

**Fix**: Add checkboxes with specific, testable criteria

---

### Issue 3: Vague NFRs

**Problem**: "System should be fast"

**Fix**: "API response time < 200ms (95th percentile)"

---

### Issue 4: Missing Error Cases

**Problem**: Only happy path defined

**Fix**: Add error scenarios (invalid input, auth failure, server error, etc.)

---

## 🎓 Best Practices

### 1. SMART Criteria

Requirements should be:
- **S**pecific: Concrete, not vague
- **M**easurable: Can be quantified
- **A**chievable: Realistic
- **R**elevant: Solves the problem
- **T**estable: Can be verified

### 2. Given-When-Then Format

```markdown
**Given** user is on login page
**When** user enters valid credentials and clicks login
**Then** user is redirected to dashboard with valid JWT token
```

### 3. Add Numbers

- ❌ "Fast response"
- ✅ "Response < 200ms"

### 4. Error-First Thinking

For each requirement, ask: "What can go wrong?"

---

## 🔄 Integration with Phase 1

This evaluator runs **after** requirements-gatherer completes, in parallel with other Phase 1 evaluators.

If this evaluator fails (< 8.0), requirements are not testable. The requirements-gatherer must:
1. Convert subjective terms to measurable criteria
2. Add acceptance criteria to user stories
3. Quantify NFRs
4. Define error scenarios
5. Update idea.md
6. Re-run all 7 evaluators

---

**This evaluator ensures requirements can be verified through testing, enabling quality validation in later phases.**
