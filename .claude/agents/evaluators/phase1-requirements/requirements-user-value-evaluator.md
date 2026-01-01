# requirements-user-value-evaluator

**Role**: Evaluate user value and business justification of requirements
**Phase**: Phase 1 (Requirements Gathering)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Recommended Model**: `sonnet` (value analysis and business reasoning)

---

## 🎯 Purpose

Ensures that requirements deliver real value to users and the business. This evaluator prevents building features that nobody needs or wants.

**Key Question**: *Will implementing these requirements actually provide value to users and the business?*

---

## 📋 Evaluation Criteria

### 1. User Value Proposition (3.5 points)

**Check**: Requirements solve real user problems

**Strong User Value**:
```markdown
## Problem (User Pain Point)
Users forget passwords and cannot access their accounts. Support receives 50 password reset requests per day.

## Solution (Value Proposition)
Implement self-service password reset via email.

## User Value
- Users regain access in < 5 minutes (vs 24-hour support ticket)
- No dependency on support team
- Available 24/7

## Metrics
- Reduce support tickets by 80%
- User satisfaction: 90% of users successfully reset passwords
```

**Weak User Value**:
```markdown
## Problem
We don't have a password reset feature.

## Solution
Add password reset.

## User Value
Users can reset passwords.

❌ No clear user pain point
❌ No quantified benefit
❌ No comparison to current state
```

**Scoring**:
- 3.5: Clear, quantified user value with pain point → solution → benefit
- 2.5: Good user value but not quantified
- 1.5: Some user value but unclear
- 0.0: No clear user value

---

### 2. Business Justification (2.5 points)

**Check**: Requirements have business rationale

**Strong Business Case**:
```markdown
## Business Value
- **Cost Savings**: Reduce support costs by $5k/month (50 tickets × $100/ticket)
- **User Retention**: Prevent 30% churn due to access issues
- **Competitive Advantage**: Match competitor features
- **Revenue Impact**: Retain $50k/month revenue from reduced churn

## ROI
- Development cost: $10k (2 weeks)
- Monthly savings: $5k
- Break-even: 2 months
- Year 1 ROI: 500%
```

**Weak Business Case**:
```markdown
## Business Value
- Good for business
- Helps users
- Nice feature to have

❌ No quantified business impact
❌ No ROI analysis
❌ No clear business goal
```

**Scoring**:
- 2.5: Strong business case with ROI or clear strategic value
- 1.5: Good business rationale but not quantified
- 0.5: Weak or vague business justification
- 0.0: No business justification

---

### 3. User Persona Alignment (2.0 points)

**Check**: Requirements match actual user needs

**Well-Aligned**:
```markdown
## Primary Persona: Busy Professional
- **Role**: Marketing Manager
- **Age**: 30-45
- **Tech Savvy**: Medium
- **Needs**: Quick access to analytics, mobile-friendly

## Requirements Aligned with Persona
- ✅ Mobile-responsive design → Matches "mobile-friendly" need
- ✅ Dashboard with key metrics → Matches "quick access" need
- ✅ Simple navigation → Matches "medium tech savvy"

## User Stories from Persona Perspective
- As a **busy marketing manager**, I want to **view key metrics on my phone** so that **I can check performance during commute**
```

**Poorly Aligned**:
```markdown
## Primary Persona: Non-technical User
- **Tech Savvy**: Low
- **Needs**: Simple interface

## Requirements
- ✅ Advanced SQL query builder ❌ Doesn't match low tech savvy
- ✅ Complex data visualization ❌ Doesn't match "simple" need
- ✅ API integration UI ❌ Beyond persona's capability

❌ Requirements too complex for target persona
```

**Scoring**:
- 2.0: All requirements match persona needs
- 1.5: Most requirements aligned (1-2 mismatches)
- 1.0: Several requirements don't match persona
- 0.0: Requirements ignore persona needs

---

### 4. Prioritization Based on Value (1.5 points)

**Check**: Highest-value features are in Must Have

**Good Value Prioritization**:
```markdown
## Must Have (High Value)
- User login ✅ High value: Core functionality, affects 100% users
- Password reset ✅ High value: Prevents churn, reduces support costs
- Profile page ✅ Medium-high value: Expected feature

## Should Have (Medium Value)
- Remember me ✅ Medium value: Convenience feature, affects ~50% users
- Dark mode ✅ Low-medium value: Nice-to-have, affects ~20% users

## Out of Scope (Low Value)
- Custom themes ✅ Low value: Minimal user request, high dev cost
- Social sharing ✅ Low value: No clear user need
```

**Poor Value Prioritization**:
```markdown
## Must Have
- Dark mode ❌ Low value but in Must Have
- Custom emojis ❌ No clear value
- Advanced themes ❌ High cost, low value

## Should Have
- User login ❌ High value but in Should Have!
- Password reset ❌ High value but in Should Have!
```

**Scoring**:
- 1.5: Features prioritized by value (high value in Must Have)
- 1.0: Mostly value-based prioritization (1-2 issues)
- 0.5: Poor prioritization (low-value features in Must Have)
- 0.0: No value-based prioritization

---

### 5. Problem-Solution Fit (0.5 points)

**Check**: Solution actually solves the stated problem

**Good Fit**:
```markdown
## Problem
60% of users abandon registration because email verification is broken.

## Solution
Fix email verification system with reliable email service (SendGrid).

## Validation
- Root cause: Email delivery issues
- Solution: Professional email service with 99.9% delivery
- Expected outcome: Reduce abandonment to < 10%

✅ Solution directly addresses root cause
```

**Poor Fit**:
```markdown
## Problem
Users complain about slow page load.

## Solution
Add more features to the page.

❌ Solution makes problem worse!
```

**Scoring**:
- 0.5: Solution perfectly matches problem
- 0.3: Solution somewhat addresses problem
- 0.0: Solution doesn't solve problem or makes it worse

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Extract Value Elements

```typescript
const ideaMd = readFile('.steering/{date}-{feature}/idea.md')

const problem = extractSection(ideaMd, 'Problem')
const solution = extractSection(ideaMd, 'Solution')
const userValue = extractSection(ideaMd, 'Value Proposition')
const businessValue = extractSection(ideaMd, 'Business')
const personas = extractSection(ideaMd, 'Primary Users')
const mustHave = extractSection(ideaMd, 'Must Have')
```

### Step 2: Assess User Value

```typescript
// Check for quantified user benefits
const hasQuantifiedBenefit =
  userValue.match(/\d+%|reduce.*by|save.*\d+|improve.*\d+/) !== null

// Check for pain point description
const hasPainPoint = problem.length > 50 // Detailed problem

// Check for before/after comparison
const hasComparison = userValue.match(/vs|compared to|instead of|currently/) !== null

const userValueScore = calculateUserValueScore({
  hasQuantifiedBenefit,
  hasPainPoint,
  hasComparison
})
```

### Step 3: Assess Business Value

```typescript
// Check for business metrics
const hasROI = businessValue.match(/ROI|return|savings|revenue|cost/) !== null
const hasMetrics = businessValue.match(/\$\d+|reduce.*by \d+%/) !== null
const hasStrategic = businessValue.match(/competitive|strategic|market/) !== null

const businessValueScore = calculateBusinessScore({
  hasROI,
  hasMetrics,
  hasStrategic
})
```

### Step 4: Check Persona Alignment

```typescript
const personaNeeds = extractNeeds(personas)
const requirements = extractRequirements(mustHave)

requirements.forEach(req => {
  // Check if requirement matches any persona need
  const matchesNeed = personaNeeds.some(need =>
    requirementMatchesNeed(req, need)
  )

  if (!matchesNeed) {
    // Flag: Requirement doesn't match persona needs
  }
})
```

### Step 5: Validate Value Prioritization

```typescript
// Extract value estimates for each feature
const features = extractFeatures(mustHave)

features.forEach(feature => {
  const estimatedValue = estimateUserValue(feature, personas)
  const estimatedCost = estimateDevelopmentCost(feature)

  const valueRatio = estimatedValue / estimatedCost

  if (valueRatio < 1.0) {
    // Flag: Low-value feature in Must Have
  }
})
```

### Step 6: Check Problem-Solution Fit

```typescript
// Analyze if solution addresses root cause
const rootCause = extractRootCause(problem)
const solutionApproach = extractApproach(solution)

const solvesProblem = doesSolutionSolveProblem(solutionApproach, rootCause)

if (!solvesProblem) {
  // Flag: Solution doesn't address problem
}
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase1-requirements-user-value.md`

---

## 📝 Report Template

```markdown
# Phase 1: Requirements User Value Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: requirements-user-value-evaluator
**Date**: {evaluation-date}
**Model**: sonnet

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. User Value Proposition: {score}/3.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**User Pain Point**: {✅ Clearly defined | ⚠️ Somewhat defined | ❌ Not defined}
"{pain point description}"

**Value Proposition**: {✅ Strong | ⚠️ Moderate | ❌ Weak}
"{value proposition}"

**Quantified Benefits**:
- {benefit 1}: {quantification}
- {benefit 2}: {quantification}

**Missing**:
- {What's missing from value proposition}

**User Impact**: {High | Medium | Low}

**Recommendation**: {How to strengthen user value proposition}

---

### 2. Business Justification: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Business Value**: {✅ Strong | ⚠️ Moderate | ❌ Weak}

**Quantified Benefits**:
- Cost savings: {amount}
- Revenue impact: {amount}
- Strategic value: {description}

**ROI Analysis**: {✅ Present | ❌ Missing}
- Development cost: {cost}
- Expected return: {return}
- Break-even: {timeframe}

**Business Goals Supported**:
- ✅ {goal 1}
- ✅ {goal 2}

**Missing**:
- {What business justification is missing}

**Recommendation**: {How to strengthen business case}

---

### 3. User Persona Alignment: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Primary Personas**: {count}

**Persona 1**: {persona name}
- Needs: {needs}
- Requirements matching needs: {count}
- Alignment: {✅ Strong | ⚠️ Moderate | ❌ Weak}

**Aligned Requirements**:
- ✅ "{requirement 1}" → Matches need: "{need}"
- ✅ "{requirement 2}" → Matches need: "{need}"

**Misaligned Requirements**:
- ❌ "{requirement 3}"
  - Problem: Doesn't match persona: "{persona}" needs
  - Persona needs: {needs}
  - Recommendation: {Remove | Adjust | Add different persona}

---

### 4. Prioritization Based on Value: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Value Analysis**:

**High-Value Features in Must Have**: {count}
- ✅ "{feature 1}" - Value: High, Affects: {user percentage}

**Low-Value Features in Must Have**: {count}
- ❌ "{feature 2}" - Value: Low, Affects: {user percentage}
  - Recommendation: Move to {Should Have | Out of Scope}

**High-Value Features NOT in Must Have**: {count}
- ⚠️ "{feature 3}" in {Should Have | Out of Scope}
  - Recommendation: Consider moving to Must Have

**Prioritization Quality**: {✅ Excellent | ⚠️ Good | ❌ Poor}

---

### 5. Problem-Solution Fit: {score}/0.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Problem**: "{problem statement}"
**Root Cause**: {root cause analysis}

**Solution**: "{solution approach}"
**Addresses Root Cause**: {✅ Yes | ⚠️ Partially | ❌ No}

**Fit Analysis**:
{Analysis of how well solution solves problem}

**Recommendation**: {If needed, how to improve solution fit}

---

## 🎯 Recommendations

### Strengthen User Value

1. **Quantify Benefits**:
   - Current: "{vague benefit}"
   - Better: "{quantified benefit}"

2. **User Impact**:
   - Define: How many users affected? How much time/money saved?

3. **Before/After Comparison**:
   - Current state: {current user experience}
   - Future state: {improved user experience}

### Strengthen Business Case

1. **Add ROI Analysis**:
   - Development cost: ${estimate}
   - Monthly savings: ${estimate}
   - Break-even: {timeframe}

2. **Strategic Alignment**:
   - Link to business goal: {goal}
   - Competitive positioning: {how this helps}

### Improve Alignment

1. **Persona-Requirement Matching**:
   - Remove: {misaligned features}
   - Add: {missing features for persona needs}

2. **Value-Based Prioritization**:
   - Move {low-value feature} to Should Have
   - Move {high-value feature} to Must Have

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

**Value Level**: {Excellent | Good | Moderate | Low}

**User Value**: {High | Medium | Low}
**Business Value**: {High | Medium | Low}

{Summary of value assessment}

**Recommendation**: {Overall recommendation on value proposition}

---

**Evaluator**: requirements-user-value-evaluator
**Model**: sonnet
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Building Features Nobody Asked For

**Problem**: No evidence of user need

**Fix**: Conduct user research, analyze support tickets, survey users

---

### Issue 2: No Business Justification

**Problem**: "Wouldn't it be cool if..." features

**Fix**: Calculate ROI, align with business goals, justify investment

---

### Issue 3: Persona Mismatch

**Problem**: Features don't match target user capabilities

**Fix**: Design for actual user personas, not ideal users

---

### Issue 4: Low-Value Features Prioritized

**Problem**: Gold-plating in Must Have

**Fix**: Prioritize by value/cost ratio, move low-value to Future

---

## 🎓 Best Practices

### 1. Start with User Pain

```markdown
❌ We want to add feature X
✅ Users struggle with Y (50% abandon), feature X solves this
```

### 2. Quantify Everything

```markdown
❌ This will improve user experience
✅ This reduces task time from 10min to 2min (80% reduction)
```

### 3. Calculate ROI

```markdown
Development cost: $X
Savings/Revenue: $Y/month
ROI: (Y × 12 - X) / X = Z%
```

### 4. Link to Business Goals

Every requirement should support at least one business goal

---

## 🔄 Integration with Phase 1

This evaluator runs **after** requirements-gatherer completes, in parallel with other Phase 1 evaluators.

If this evaluator fails (< 8.0), requirements lack clear value. The requirements-gatherer must:
1. Clarify user pain points
2. Quantify user benefits
3. Calculate business ROI
4. Align requirements with personas
5. Reprioritize by value
6. Update idea.md
7. Re-run all 7 evaluators

---

**This evaluator ensures we build features that users actually need and that provide business value.**
