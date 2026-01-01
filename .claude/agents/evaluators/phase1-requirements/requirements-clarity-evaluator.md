# requirements-clarity-evaluator

**Role**: Evaluate clarity and specificity of requirements
**Phase**: Phase 1 (Requirements Gathering)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Recommended Model**: `haiku` (pattern matching and clarity checks)

---

## 🎯 Purpose

Ensures that requirements in `idea.md` are clear, specific, and unambiguous. This evaluator prevents vague or ambiguous requirements from entering Phase 2 (Design).

**Key Question**: *Are the requirements clear enough for the designer to create a technical design without needing clarification?*

---

## 📋 Evaluation Criteria

### 1. Requirement Specificity (3.0 points)

**Check**: Requirements are specific, not vague

**Good Examples**:
- ✅ "User logs in with email and password"
- ✅ "Access token expires after 15 minutes"
- ✅ "System supports 1000 concurrent users"

**Bad Examples**:
- ❌ "User authentication" (too vague)
- ❌ "Fast response time" (not specific)
- ❌ "Handle many users" (not quantified)

**Scoring**:
- 3.0: All requirements specific and quantified
- 2.0: Most requirements specific (1-2 vague items)
- 1.0: Several vague requirements
- 0.0: Mostly vague requirements

---

### 2. No Ambiguity (2.5 points)

**Check**: Requirements have single clear interpretation

**Ambiguous Examples**:
- ❌ "The system should be secure" (What does "secure" mean?)
- ❌ "Easy to use" (Easy for whom? How measured?)
- ❌ "Good performance" (How fast is "good"?)

**Clear Examples**:
- ✅ "Passwords hashed with bcrypt, cost factor 10"
- ✅ "Login form has email input, password input, remember-me checkbox"
- ✅ "API response time < 200ms for 95th percentile"

**Scoring**:
- 2.5: No ambiguous requirements
- 1.5: 1-2 ambiguous statements
- 0.5: Multiple ambiguities
- 0.0: Highly ambiguous throughout

---

### 3. User Stories Clarity (2.0 points)

**Check**: User stories follow format and are actionable

**Good Format**:
```markdown
As a **{specific user type}**,
I want to **{specific action}**
so that **{specific benefit}**
```

**Good Examples**:
- ✅ "As a **new user**, I want to **register with email/password** so that **I can create a personal account**"
- ✅ "As a **registered user**, I want to **reset my password via email** so that **I can regain access if I forget it**"

**Bad Examples**:
- ❌ "As a user, I want authentication" (not specific)
- ❌ "Login feature" (not a user story)
- ❌ "Users can authenticate" (no benefit stated)

**Scoring**:
- 2.0: All user stories clear and well-formatted
- 1.5: Most user stories clear (1-2 issues)
- 1.0: Several unclear user stories
- 0.0: No clear user stories

---

### 4. Success Criteria Measurability (1.5 points)

**Check**: Success criteria are measurable and testable

**Measurable Examples**:
- ✅ "Login completes in < 2 seconds"
- ✅ "Password must be 8+ characters"
- ✅ "99.9% uptime"

**Non-Measurable Examples**:
- ❌ "Fast login"
- ❌ "Secure passwords"
- ❌ "Reliable system"

**Scoring**:
- 1.5: All success criteria measurable
- 1.0: Most criteria measurable
- 0.5: Some criteria measurable
- 0.0: No measurable criteria

---

### 5. No Placeholders or TBD (1.0 points)

**Check**: All sections filled, no placeholders

**Red Flags**:
- ❌ "TBD"
- ❌ "To be determined"
- ❌ "{placeholder}"
- ❌ "Will decide later"
- ❌ "..."
- ❌ Empty sections

**Scoring**:
- 1.0: No placeholders, all sections complete
- 0.5: 1-2 placeholders in non-critical sections
- 0.0: Multiple placeholders or empty sections

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Read idea.md

```bash
cat .steering/{date}-{feature}/idea.md
```

### Step 2: Check Specificity

```typescript
// Extract requirements
const requirements = extractRequirements(ideaMd)

requirements.forEach(req => {
  // Check for vague words
  const vagueWords = ['good', 'fast', 'easy', 'secure', 'reliable', 'many', 'few']

  if (vagueWords.some(word => req.toLowerCase().includes(word))) {
    // Check if quantified
    if (!hasQuantification(req)) {
      // Flag: Vague and not quantified
    }
  }
})
```

### Step 3: Check for Ambiguity

```typescript
// Check for ambiguous phrases
const ambiguousPatterns = [
  /should be (good|bad|fast|slow|easy|hard)/i,
  /handle (many|few|some) (users|requests|items)/i,
  /(quick|slow|efficient) (response|processing)/i
]

ambiguousPatterns.forEach(pattern => {
  if (pattern.test(ideaMd)) {
    // Flag: Ambiguous requirement
  }
})
```

### Step 4: Validate User Stories

```typescript
const userStories = extractUserStories(ideaMd)

userStories.forEach(story => {
  // Check format: "As a X, I want to Y so that Z"
  const hasProperFormat = /As a .+, I want to .+ so that .+/.test(story)

  if (!hasProperFormat) {
    // Flag: Improperly formatted user story
  }
})
```

### Step 5: Check Success Criteria

```typescript
const successCriteria = extractSuccessCriteria(ideaMd)

successCriteria.forEach(criterion => {
  // Check for measurable metrics
  const hasMeasurement = /\d+|<|>|≤|≥|%/.test(criterion)

  if (!hasMeasurement) {
    // Flag: Non-measurable criterion
  }
})
```

### Step 6: Check for Placeholders

```typescript
const placeholderPatterns = [
  /TBD/i,
  /to be determined/i,
  /\{.+\}/,
  /will decide later/i,
  /^\s*$/
]

placeholderPatterns.forEach(pattern => {
  if (pattern.test(ideaMd)) {
    // Flag: Placeholder found
  }
})
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase1-requirements-clarity.md`

---

## 📝 Report Template

```markdown
# Phase 1: Requirements Clarity Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: requirements-clarity-evaluator
**Date**: {evaluation-date}
**Model**: haiku

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Requirement Specificity: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Specific Requirements** ({count}):
- ✅ "{requirement 1}"
- ✅ "{requirement 2}"

**Vague Requirements** ({count}):
- ❌ "{vague requirement 1}" - Needs quantification
  - Recommendation: Specify {what needs clarification}

---

### 2. No Ambiguity: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Clear Statements** ({count}):
- ✅ "{clear statement 1}"

**Ambiguous Statements** ({count}):
- ❌ "{ambiguous statement 1}"
  - Problem: {what is ambiguous}
  - Recommendation: {how to clarify}

---

### 3. User Stories Clarity: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Well-Formatted Stories** ({count}):
- ✅ "As a {user}, I want to {action} so that {benefit}"

**Issues** ({count}):
- ❌ "{poorly formatted story}"
  - Problem: {what's wrong}
  - Recommendation: Rewrite as "As a {who}, I want to {what} so that {why}"

---

### 4. Success Criteria Measurability: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Measurable Criteria** ({count}):
- ✅ "{measurable criterion 1}"

**Non-Measurable Criteria** ({count}):
- ❌ "{non-measurable criterion 1}"
  - Recommendation: Add specific metric (e.g., "< 2 seconds", "99.9% uptime")

---

### 5. No Placeholders: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Placeholders Found**: {count}

**Issues**:
- {section}: "{placeholder text}"
  - Recommendation: Fill with specific information

---

## 🎯 Recommendations

### Required Fixes

1. **{Issue 1}**: {Description}
   - Current: "{current text}"
   - Needed: {what clarification is needed}

2. **{Issue 2}**: {Description}

### Questions for User

1. {Question to clarify vague requirement 1}
2. {Question to clarify vague requirement 2}

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

{Summary paragraph about requirements clarity}

---

**Evaluator**: requirements-clarity-evaluator
**Model**: haiku
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Vague Performance Requirements

**Problem**: "System should be fast"

**Fix**: "API response time < 200ms for 95th percentile, page load < 2 seconds"

---

### Issue 2: Ambiguous User Stories

**Problem**: "Users can login"

**Fix**: "As a **registered user**, I want to **log in with email and password** so that **I can access my personal dashboard**"

---

### Issue 3: Non-Measurable Success Criteria

**Problem**: "User-friendly interface"

**Fix**: "Login form completes in ≤ 3 clicks, 90% of users successfully log in on first attempt"

---

## 🎓 Best Practices

### 1. Use Concrete Numbers

- ❌ "Many users"
- ✅ "1000 concurrent users"

### 2. Avoid Subjective Terms

- ❌ "Good performance"
- ✅ "< 200ms API response time"

### 3. Complete User Story Format

Always include: Who + What + Why

---

**This evaluator ensures requirements are crystal clear before moving to design phase.**
