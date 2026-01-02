# Phase 1: Requirements Gathering Gate

**Purpose**: Clarify user requirements through interactive dialogue before any design or implementation
**Trigger**: User requests feature implementation or Claude Code startup (SessionStart hook)
**Duration**: Variable (dialogue-based, typically 10-30 minutes)
**Automated**: Semi-automated (interactive dialogue with user)

---

## 📋 Overview

Phase 1 ensures that every feature starts with crystal-clear, well-defined requirements. Through interactive dialogue using the 5W2H framework (What, Why, Who, When, Where, How, How much), the requirements-gatherer agent extracts comprehensive requirements and documents them in `idea.md`.

**Key Principle**: Prevent ambiguous requirements from entering the design phase. Better to spend 30 minutes clarifying now than waste weeks building the wrong thing.

---

## 🎯 Goals

1. **Clarify Requirements**: Transform vague ideas into specific, actionable requirements
2. **Prevent Scope Creep**: Define clear boundaries (In Scope vs Out of Scope)
3. **Ensure Value**: Validate that requirements provide user and business value
4. **Enable Testing**: Make requirements testable and measurable
5. **Set Foundation**: Provide Phase 2 (Design) with everything needed for technical design

---

## 🔄 Workflow

### Prerequisites

Phase 1 runs when:
- ✅ User requests feature implementation
- ✅ User mentions "implement", "build", "create", or similar keywords
- ❌ Skipped if user only wants code investigation/exploration

### Step 1: Detect User Intent

```typescript
// Analyze user's initial message
const userMessage = getUserMessage()

if (userMessage.includes('調査') || userMessage.includes('explore') || userMessage.includes('investigate')) {
  // Code investigation mode - skip to Plan mode
  console.log('📋 Investigation request detected - entering Plan mode')
  await EnterPlanMode()
  return // End Phase 1
}

if (userMessage.includes('EDAF') || userMessage.includes('エージェントフロー')) {
  // Direct to Phase 2 - user has already defined requirements
  console.log('📋 EDAF flow requested - starting from Phase 2 (Design)')
  // Skip Phase 1, start at Phase 2
  return
}

// Otherwise, start requirements gathering
console.log('📋 Feature implementation detected - starting Phase 1: Requirements Gathering')
```

### Step 2: Create Session Directory

```typescript
const today = new Date().toISOString().split('T')[0] // YYYY-MM-DD
const featureName = extractFeatureName(userMessage)
const featureSlug = toKebabCase(featureName)
const sessionDir = `.steering/${today}-${featureSlug}`

await bash(`mkdir -p ${sessionDir}/reports`)

console.log(`📁 Session directory created: ${sessionDir}`)
```

### Step 3: Launch requirements-gatherer Agent

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 1" "Requirements Gathering"')

console.log('\n💬 Starting interactive requirements gathering...')
console.log('━'.repeat(60))

const gatherResult = await Task({
  subagent_type: 'requirements-gatherer',
  model: 'opus', // Critical thinking for requirement clarification
  description: 'Gather and clarify requirements',
  prompt: `Gather comprehensive requirements for the user's request.

**User Request**: "${userMessage}"

**Task**:
1. Engage in interactive dialogue with the user
2. Use 5W2H framework (What, Why, Who, When, Where, How, How much)
3. Ask clarifying questions to eliminate ambiguity
4. Document requirements in idea.md template
5. Ensure all 15 sections are filled with specific information

**Output**: Generate .steering/${sessionDir}/idea.md

**Instructions**:
- Ask follow-up questions until requirements are crystal clear
- Don't make assumptions - get user confirmation
- Be specific - avoid vague terms like "fast", "good", "many"
- Quantify everything possible (numbers, metrics, timeframes)
- Define scope boundaries (In Scope vs Out of Scope)
- Identify risks and dependencies

**Session Directory**: ${sessionDir}
**Current Working Directory**: ${process.cwd()}
`
})

console.log('\n✅ Requirements gathering complete')
console.log(`📄 Generated: ${sessionDir}/idea.md`)
```

### Step 4: Run 7 Requirements Evaluators in Parallel

```typescript
console.log('\n📊 Running 7 requirements evaluators in parallel...')
console.log('━'.repeat(60))

const evaluators = [
  'requirements-clarity-evaluator',
  'requirements-completeness-evaluator',
  'requirements-feasibility-evaluator',
  'requirements-goal-alignment-evaluator',
  'requirements-scope-evaluator',
  'requirements-testability-evaluator',
  'requirements-user-value-evaluator'
]

// Launch all evaluators in parallel
const evaluatorResults = await Promise.all(
  evaluators.map((evaluator, index) =>
    Task({
      subagent_type: evaluator,
      model: ['clarity', 'completeness', 'goal-alignment', 'testability'].includes(evaluator.split('-')[1]) ? 'haiku' : 'sonnet',
      description: `Evaluate ${evaluator.replace('requirements-', '').replace('-evaluator', '')}`,
      prompt: `Evaluate requirements quality for Phase 1.

**Session Directory**: ${sessionDir}

**Task**: Evaluate ${sessionDir}/idea.md

**Evaluation Focus**:
- Read idea.md thoroughly
- Evaluate based on ${evaluator} criteria
- Generate score (0-10 scale)
- Generate detailed report with specific recommendations

**Output Report**: ${sessionDir}/reports/phase1-${evaluator}.md

**Pass Criteria**: Score ≥ 8.0/10

**Current Working Directory**: ${process.cwd()}
`
    })
  )
)

console.log('\n📊 Evaluator Results:')
console.log('━'.repeat(60))

evaluatorResults.forEach((result, index) => {
  const evaluatorName = evaluators[index].replace('requirements-', '').replace('-evaluator', '')
  const passed = result.output.includes('PASS ✅') || result.score >= 8.0
  const status = passed ? '✅ PASS' : '❌ FAIL'
  const score = result.score || extractScore(result.output)

  console.log(`${status} ${evaluatorName}: ${score}/10.0`)
})
```

### Step 5: Check if All Evaluators Passed

```typescript
const allPassed = evaluatorResults.every(result =>
  result.output.includes('PASS ✅') || result.score >= 8.0
)

if (!allPassed) {
  console.log('\n❌ Some requirements evaluators failed')
  console.log('━'.repeat(60))

  // Identify failures
  const failures = evaluatorResults
    .map((result, index) => ({
      evaluator: evaluators[index],
      result
    }))
    .filter(item => !(item.result.output.includes('PASS ✅') || item.result.score >= 8.0))

  console.log(`\nFailed evaluators (${failures.length}):`)
  failures.forEach(f => {
    console.log(`- ${f.evaluator.replace('requirements-', '').replace('-evaluator', '')}`)
  })

  // Compile feedback
  const feedbackPrompt = failures
    .map(f => {
      const evaluatorName = f.evaluator.replace('requirements-', '').replace('-evaluator', '')
      const recommendations = extractRecommendations(f.result.output)
      return `## ${evaluatorName}\n${recommendations}`
    })
    .join('\n\n')

  // Re-invoke requirements-gatherer with feedback
  console.log('\n🔄 Re-invoking requirements-gatherer with evaluator feedback...')

  const retryResult = await Task({
    subagent_type: 'requirements-gatherer',
    model: 'opus',
    description: 'Refine requirements based on feedback',
    prompt: `Refine requirements based on evaluator feedback.

**Session Directory**: ${sessionDir}

**Current idea.md**: ${sessionDir}/idea.md

**Evaluator Feedback**:
${feedbackPrompt}

**Task**:
1. Read current idea.md
2. Read evaluator reports in ${sessionDir}/reports/
3. Address all issues raised by evaluators
4. Update idea.md with improvements
5. Ensure all evaluators will pass (≥ 8.0/10)

**Instructions**:
- Be specific where evaluators found vagueness
- Add quantified metrics where missing
- Fill in missing sections
- Clarify scope boundaries
- Add acceptance criteria to user stories
- May need to ask user additional questions

**Current Working Directory**: ${process.cwd()}
`
  })

  // Re-run evaluators
  console.log('\n📊 Re-running evaluators...')
  // (Loop up to 3 times maximum)
}

console.log('\n✅ All 7 requirements evaluators passed')
console.log('━'.repeat(60))
```

### Step 6: Completion and Handoff to Phase 2

```typescript
await bash('.claude/scripts/notification.sh "Phase 1 complete" WarblerSong')

console.log('\n✅ Phase 1 Complete: Requirements Gathering')
console.log('━'.repeat(60))

console.log('\n📄 Deliverables:')
console.log(`- Requirements: ${sessionDir}/idea.md`)
console.log(`- Evaluation reports: ${sessionDir}/reports/phase1-*.md`)

console.log('\n📊 Quality Gates:')
console.log('- ✅ requirements-clarity-evaluator: ≥ 8.0/10')
console.log('- ✅ requirements-completeness-evaluator: ≥ 8.0/10')
console.log('- ✅ requirements-feasibility-evaluator: ≥ 8.0/10')
console.log('- ✅ requirements-goal-alignment-evaluator: ≥ 8.0/10')
console.log('- ✅ requirements-scope-evaluator: ≥ 8.0/10')
console.log('- ✅ requirements-testability-evaluator: ≥ 8.0/10')
console.log('- ✅ requirements-user-value-evaluator: ≥ 8.0/10')

console.log('\n📋 Next: Phase 2 - Design')
console.log('Input for Phase 2: idea.md will be passed to designer agent')
```

---

## 📁 Input/Output

### Input (from User)
- Natural language feature request
- User's responses to clarifying questions during dialogue

### Process
1. Interactive dialogue using 5W2H framework
2. Generate `idea.md` with 15 sections
3. Run 7 evaluators in parallel
4. Iterate if any evaluator fails
5. All evaluators must pass (≥ 8.0/10)

### Output (to Phase 2)
- **`.steering/{YYYY-MM-DD}-{feature-slug}/idea.md`**: Comprehensive requirements document
- **`.steering/{YYYY-MM-DD}-{feature-slug}/reports/phase1-*.md`**: 7 evaluation reports

---

## 🎯 Success Criteria

Phase 1 is **COMPLETE** when:

- ✅ `idea.md` generated with all 15 sections filled
- ✅ Requirements are clear, specific, and unambiguous
- ✅ User stories have acceptance criteria
- ✅ Scope is well-defined (In/Out/Future)
- ✅ Success criteria are measurable
- ✅ Requirements are technically feasible
- ✅ Requirements align with user/business goals
- ✅ Requirements provide clear user value
- ✅ **All 7 evaluators passed** (≥ 8.0/10):
  - requirements-clarity-evaluator
  - requirements-completeness-evaluator
  - requirements-feasibility-evaluator
  - requirements-goal-alignment-evaluator
  - requirements-scope-evaluator
  - requirements-testability-evaluator
  - requirements-user-value-evaluator

**Gate Requirement**: All 7 evaluators must score ≥ 8.0/10 to proceed to Phase 2.

---

## 📊 idea.md Structure

The generated `idea.md` contains 15 sections:

1. **Executive Summary**: One-sentence description, problem, solution
2. **What**: Feature overview, capabilities, user interactions
3. **Why**: Problem, solution, value proposition
4. **Who**: User personas, user stories
5. **When**: Usage timing, trigger events, frequency
6. **Where**: UI location, integration points, navigation
7. **How**: High-level approach, key components, data flow
8. **How Much**: Scope (In/Out/Future)
9. **Constraints**: Technical, business, time, resource
10. **Success Criteria**: Functional, non-functional, metrics
11. **Risks & Mitigations**: Technical and business risks
12. **Open Questions**: Questions for Phase 2 (Design)
13. **Dependencies**: Internal and external
14. **Assumptions**: What we're assuming
15. **References**: Related documents, inspiration

---

## 🚨 Common Anti-Patterns

### Anti-Pattern 1: Skipping Phase 1

❌ **Bad**: "Just start coding, we know what we want"

✅ **Good**: Spend 20-30 minutes in Phase 1 to prevent weeks of rework

### Anti-Pattern 2: Accepting Vague Requirements

❌ **Bad**: "System should be fast" → Accept and move to Phase 2

✅ **Good**: "Define 'fast' - what's the target response time?"

### Anti-Pattern 3: No Scope Definition

❌ **Bad**: Only define what's included, no boundaries

✅ **Good**: Explicitly define In Scope, Out of Scope, and Future

### Anti-Pattern 4: Ignoring Evaluator Feedback

❌ **Bad**: Evaluator fails → Proceed anyway

✅ **Good**: Address feedback, refine requirements, re-evaluate

---

## 📈 Best Practices

### 1. Ask "Why" Five Times

For each requirement, keep asking "why" to get to root cause:
```
User: "I want password reset"
Agent: "Why do users need password reset?"
User: "They forget passwords"
Agent: "Why do they forget passwords?"
User: "They use different passwords for many sites"
Agent: "Why not use a password manager?"
User: "They don't know about password managers"
Agent: "Should we include password manager education?"
→ Discovered additional requirement
```

### 2. Quantify Everything

Replace subjective terms with numbers:
- "Fast" → "< 200ms response time"
- "Many users" → "1000 concurrent users"
- "Good uptime" → "99.9% availability"

### 3. Use Examples

When defining requirements, provide concrete examples:
```markdown
**User Story**: As a user, I want to reset my password

**Example Scenario**:
1. User clicks "Forgot password"
2. User enters email: "user@example.com"
3. System sends reset link to email
4. User clicks link (valid for 1 hour)
5. User enters new password (8+ chars)
6. System confirms "Password reset successful"
```

### 4. Define Edge Cases

Don't just define happy path:
```markdown
**Success Case**: User logs in successfully
**Error Cases**:
- Invalid email format → Show error
- Wrong password → Show error, lock after 5 attempts
- Account locked → Show message, require password reset
- Expired token → Show error, require new login
```

---

## 🔄 Integration with EDAF Flow

### Before Phase 1

**User Request**:
```
"ユーザー認証機能を実装したい"
or
"I want to add user authentication"
```

### After Phase 1

**Phase 2 Input** (idea.md):
```markdown
# Feature Idea: User Authentication

## Executive Summary
Implement JWT-based authentication with email/password registration,
login, and password reset to secure user data access.

## What
- User registration with email verification
- Login with JWT tokens (15-min expiry)
- Password reset via email
- Session management with refresh tokens

...
(14 more sections with comprehensive details)
```

**Phase 2** (Design) will use this as input to create technical design.

---

## 🎓 Example Invocation

Full Phase 1 execution:

```typescript
// User: "ユーザー認証機能を実装したい"

console.log('🔄 Phase 1: Requirements Gathering')
console.log('━'.repeat(60))

// Step 1: Detect intent
if (!isInvestigation(userMessage) && !isEDAFDirectRequest(userMessage)) {

  // Step 2: Create session
  const sessionDir = '.steering/2026-01-01-user-authentication'
  await bash(`mkdir -p ${sessionDir}/reports`)

  // Step 3: Launch requirements-gatherer
  await Task({
    subagent_type: 'requirements-gatherer',
    model: 'opus',
    prompt: `Gather requirements for user authentication feature...`
  })

  // Step 4: Run 7 evaluators in parallel
  const results = await Promise.all([
    Task({ subagent_type: 'requirements-clarity-evaluator', ... }),
    Task({ subagent_type: 'requirements-completeness-evaluator', ... }),
    Task({ subagent_type: 'requirements-feasibility-evaluator', ... }),
    Task({ subagent_type: 'requirements-goal-alignment-evaluator', ... }),
    Task({ subagent_type: 'requirements-scope-evaluator', ... }),
    Task({ subagent_type: 'requirements-testability-evaluator', ... }),
    Task({ subagent_type: 'requirements-user-value-evaluator', ... })
  ])

  // Step 5: Check results and iterate if needed
  if (!allPassed(results)) {
    // Re-invoke requirements-gatherer with feedback
    // Re-run evaluators
  }

  // Step 6: Complete
  console.log('\n✅ Phase 1 Complete')
  console.log('📋 Next: Phase 2 - Design')
}
```

---

## 📊 Metrics

Phase 1 typically takes:
- **Simple feature**: 10-15 minutes (3-5 questions)
- **Medium feature**: 20-30 minutes (10-15 questions)
- **Complex feature**: 30-45 minutes (20+ questions)

**Time investment vs savings**:
- Phase 1: 30 minutes
- Prevents: Hours/days of building wrong feature
- ROI: 10-100x

---

**Phase 1 ensures every feature starts with a solid foundation of clear, valuable, testable requirements.**
