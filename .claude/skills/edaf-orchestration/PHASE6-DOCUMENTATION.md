# Phase 6: Documentation Update Gate

**Purpose**: Update permanent product-level documentation based on implementation
**Trigger**: After Phase 5 (Code Review) passes
**Duration**: ~5-10 minutes
**Automated**: Yes (documentation-worker)

---

## 📥 Input from Phase 5 (Code Review)

- **Reviewed & Fixed Code**: All implementation code that passed code review
- **`.steering/{YYYY-MM-DD}-{feature-slug}/design.md`** - Design document (reference)
- **`.steering/{YYYY-MM-DD}-{feature-slug}/tasks.md`** - Task plan (reference)
- **`.steering/{YYYY-MM-DD}-{feature-slug}/idea.md`** - Requirements (reference)
- **Evaluation Reports**: Code review findings and fixes

---

## 📋 Overview

Phase 6 ensures that permanent documentation in `docs/` stays synchronized with the codebase. After implementing a feature, the documentation-worker analyzes what changed and updates relevant documentation files.

**Key Principle**: Documentation is a first-class citizen, not an afterthought.

---

## 🎯 Goals

1. **Keep Documentation Current**: Reflect latest implementation in permanent docs
2. **Capture New Concepts**: Add new domain terms to glossary
3. **Update Architecture**: Document new components and integrations
4. **Maintain Guidelines**: Update coding standards if new patterns introduced
5. **Track Structure**: Document new directories and organization changes

---

## 📁 Documentation Files

### Permanent Documentation (`docs/`)

| File | Purpose | Update Triggers |
|------|---------|-----------------|
| `product-requirements.md` | What the product does | New features, use cases |
| `functional-design.md` | Feature details (screens, APIs, data) | New features, design changes |
| `development-guidelines.md` | How to write code | New patterns, standards |
| `repository-structure.md` | How code is organized | New directories, restructuring |
| `architecture.md` | How system is designed | New components, integrations |
| `glossary.md` | Ubiquitous language (DDD) | New domain terms |

### Session Documentation (`.steering/`)

These are **NOT** updated in Phase 6 (they're immutable after creation):
- `.steering/{date}-{feature}/idea.md` - Phase 1 output (requirements)
- `.steering/{date}-{feature}/design.md` - Phase 2 output (design)
- `.steering/{date}-{feature}/tasks.md` - Phase 3 output (plan)
- `.steering/{date}-{feature}/reports/` - Evaluation reports (all phases)

---

## 📊 Documentation Evaluators

Phase 6 includes **5 documentation evaluators** that validate documentation quality:

| Evaluator | Purpose | Pass Criteria |
|-----------|---------|---------------|
| **documentation-completeness-evaluator** | All required sections present | ≥ 8.0/10 |
| **documentation-accuracy-evaluator** | Content matches implementation | ≥ 8.0/10 |
| **documentation-consistency-evaluator** | Terminology & formatting uniform | ≥ 8.0/10 |
| **documentation-clarity-evaluator** | Easy to understand | ≥ 8.0/10 |
| **documentation-currency-evaluator** | Up to date, no stale info | ≥ 8.0/10 |

**All 5 evaluators must pass** (≥ 8.0/10) for Phase 6 to complete.

### Evaluator Details

1. **completeness-evaluator**: Checks all required sections exist, new features documented, glossary updated
2. **accuracy-evaluator**: Verifies code structure, API endpoints, data models, tech stack match docs
3. **consistency-evaluator**: Validates terminology from glossary, formatting, cross-document consistency
4. **clarity-evaluator**: Evaluates explanation quality, examples, structure, terminology usage
5. **currency-evaluator**: Ensures timestamps current, recent changes documented, no outdated info

---

## 🔄 Workflow

### Prerequisites

Phase 6 runs **ONLY** if:
- ✅ Phase 5 (Code Review) passed
- ✅ All code evaluators approved (≥ 8.0/10)
- ✅ UI verification completed (if frontend modified)
- ✅ Implementation is complete

### Step 1: Analyze Implementation

Read session artifacts to understand what was implemented:

```typescript
const sessionDir = '.steering/2026-01-01-user-authentication'

// Read Phase 1 design
const designDoc = fs.readFileSync(`${sessionDir}/design.md`, 'utf-8')

// Read Phase 2 tasks
const taskPlan = fs.readFileSync(`${sessionDir}/tasks.md`, 'utf-8')

// Read Phase 4 code reviews
const codeReviews = fs.readdirSync(`${sessionDir}/reports`)
  .filter(f => f.startsWith('phase4-'))
  .map(f => fs.readFileSync(`${sessionDir}/reports/${f}`, 'utf-8'))

// Analyze what changed
console.log('📋 Analyzing implementation for documentation updates...')
```

### Step 2: Launch documentation-worker

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 5" "Documentation Update"')

const docResult = await Task({
  subagent_type: 'documentation-worker',
  model: 'sonnet',
  description: 'Update permanent documentation',
  prompt: `Update permanent documentation based on recent implementation.

**Session Directory**: ${sessionDir}

**Task**: Review implementation and update relevant docs in docs/:

**Input Documents** (read these first):
1. ${sessionDir}/design.md - Feature design
2. ${sessionDir}/tasks.md - Implementation tasks
3. ${sessionDir}/reports/phase4-code-quality.md - Code quality review
4. ${sessionDir}/reports/phase4-implementation-alignment.md - Implementation review

**Output**: Update permanent docs if needed:
- docs/product-requirements.md (if new features added)
- docs/functional-design.md (if new feature details/APIs/screens)
- docs/development-guidelines.md (if new patterns introduced)
- docs/repository-structure.md (if new directories added)
- docs/architecture.md (if architecture changed)
- docs/glossary.md (if new domain terms introduced)

**Instructions**:
- Only update docs that are actually affected
- Preserve existing content, only add/modify relevant sections
- Update glossary with any new domain terms used
- Use Edit tool for surgical updates (not Write for existing files)
- Report which docs were updated and why

**Current Working Directory**: ${process.cwd()}
`
})

console.log('✅ Documentation worker completed')
```

### Step 3: Run Documentation Evaluators

Run 5 documentation evaluators in parallel to validate documentation quality:

```typescript
console.log('\n📊 Running 5 documentation evaluators in parallel...')

const evaluators = [
  'documentation-completeness-evaluator',
  'documentation-accuracy-evaluator',
  'documentation-consistency-evaluator',
  'documentation-clarity-evaluator',
  'documentation-currency-evaluator'
]

// Launch all evaluators in parallel
const evaluatorResults = await Promise.all(
  evaluators.map(evaluator =>
    Task({
      subagent_type: evaluator,
      model: 'haiku', // Fast pattern matching (except accuracy uses sonnet)
      description: `Evaluate ${evaluator.replace('documentation-', '').replace('-evaluator', '')}`,
      prompt: `Evaluate documentation quality for Phase 5.

**Session Directory**: ${sessionDir}

**Task**: Evaluate permanent documentation updates

**Evaluation Focus**:
- Read all permanent docs in docs/
- Read session artifacts in ${sessionDir}/
- Evaluate based on ${evaluator} criteria
- Generate score (0-10 scale)
- Generate detailed report

**Output Report**: ${sessionDir}/reports/phase5-${evaluator}.md

**Pass Criteria**: Score ≥ 8.0/10

**Current Working Directory**: ${process.cwd()}
`
    })
  )
)

// Check results
const allPassed = evaluatorResults.every(result =>
  result.output.includes('PASS ✅') || result.score >= 8.0
)

if (!allPassed) {
  console.log('\n❌ Some documentation evaluators failed')

  // Identify failures
  const failures = evaluatorResults
    .filter(result => !(result.output.includes('PASS ✅') || result.score >= 8.0))
    .map(result => result.evaluator)

  console.log(`Failed evaluators: ${failures.join(', ')}`)

  // Re-invoke documentation-worker with feedback
  console.log('\n🔄 Re-invoking documentation-worker with evaluator feedback...')

  const feedbackPrompt = evaluatorResults
    .map(result => `${result.evaluator}: ${result.feedback}`)
    .join('\n\n')

  const retryResult = await Task({
    subagent_type: 'documentation-worker',
    model: 'sonnet',
    description: 'Fix documentation issues',
    prompt: `Fix documentation issues based on evaluator feedback.

**Session Directory**: ${sessionDir}

**Evaluator Feedback**:
${feedbackPrompt}

**Task**: Address all issues raised by evaluators

**Instructions**:
- Read evaluator reports in ${sessionDir}/reports/phase5-*.md
- Fix identified issues
- Re-generate or update affected documentation
- Ensure all evaluators will pass (≥ 8.0/10)
`
  })

  // Re-run evaluators
  console.log('\n📊 Re-running evaluators...')
  // (Repeat evaluator workflow)
}

console.log('\n✅ All 5 documentation evaluators passed')
```

### Step 4: Review Updates

```typescript
// documentation-worker returns summary of changes
const updates = docResult.output

console.log('\n📝 Documentation Updates:')
console.log(updates)

// Example output:
// ✅ Updated 3 files:
//   - product-requirements.md: Added "User Authentication" feature
//   - architecture.md: Added Authentication Service component
//   - glossary.md: Added 5 new domain terms
//
// ⏭️  Skipped 2 files (no changes needed):
//   - development-guidelines.md
//   - repository-structure.md
```

### Step 5: Completion

```typescript
await bash('.claude/scripts/notification.sh "Phase 5 complete" WarblerSong')

console.log('\n✅ Phase 5 Complete: Documentation is up to date')
console.log('📊 All evaluators passed')
console.log('📋 Next: Phase 6 - Deployment Readiness (optional)')
```

---

## 🎨 Update Decision Logic

### When to Update `product-requirements.md`

**Trigger**:
- New feature added to the product
- New use case introduced
- Non-functional requirements changed

**Check**:
```typescript
if (designDoc.includes('## Features') || designDoc.includes('## Use Cases')) {
  // Update product-requirements.md
  // Add new feature section
  // Update feature list
}
```

**Example Update**:
```markdown
## Core Features

...existing features...

### User Authentication (Added: 2026-01-01)

Secure user authentication system using JWT tokens.

**Capabilities**:
- User registration with email verification
- Login with email/password
- JWT access and refresh tokens
- Password reset flow
- Session management
```

---

### When to Update `development-guidelines.md`

**Trigger**:
- New coding pattern introduced
- New testing standard established
- New security practice adopted

**Check**:
```typescript
const codeReview = readCodeReview(`${sessionDir}/reports/phase4-code-quality.md`)

if (codeReview.includes('pattern') || codeReview.includes('standard')) {
  // Update development-guidelines.md
}
```

**Example Update**:
```markdown
## Authentication Patterns (Added: 2026-01-01)

All protected routes must use the `authMiddleware`:

\`\`\`typescript
router.get('/api/users/profile', authMiddleware, getUserProfile)
\`\`\`

**JWT Token Handling**:
- Access tokens: 15-minute expiry
- Refresh tokens: 7-day expiry
- Store tokens in httpOnly cookies (not localStorage)
```

---

### When to Update `repository-structure.md`

**Trigger**:
- New directories created
- Code reorganization
- New modules added

**Check**:
```typescript
const newDirs = detectNewDirectories(sessionDir)

if (newDirs.length > 0) {
  // Update repository-structure.md
  // Add new directories to tree
  // Document their purpose
}
```

**Example Update**:
```markdown
## Directory Tree

\`\`\`
.
├── src/
│   ├── auth/              # Authentication module (Added: 2026-01-01)
│   │   ├── controllers/   # Auth endpoints
│   │   ├── services/      # JWT token management
│   │   └── middleware/    # Auth middleware
...
\`\`\`

### `/src/auth` (Added: 2026-01-01)

Authentication module handling user login, registration, and JWT token management.
```

---

### When to Update `architecture.md`

**Trigger**:
- New component added
- New integration introduced
- Architecture pattern changed

**Check**:
```typescript
if (designDoc.includes('component') || designDoc.includes('service')) {
  // Update architecture.md
}
```

**Example Update**:
```markdown
## Components

### Authentication Service (Added: 2026-01-01)

Handles user authentication and JWT token management.

**Responsibilities**:
- User registration and login
- JWT token generation and validation
- Password hashing (bcrypt)
- Session management

**Dependencies**:
- Database: Users table
- External: None

**API Endpoints**:
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/refresh
- POST /api/auth/logout
```

---

### When to Update `glossary.md`

**Trigger**: **ALWAYS** - Check for new domain terms in every implementation

**Check**:
```typescript
const newTerms = extractDomainTerms([
  designDoc,
  taskPlan,
  codeReview
])

if (newTerms.length > 0) {
  // Update glossary.md
}
```

**Example Update**:
```markdown
## A

**Access Token**: Short-lived JWT token (15 minutes) used to authenticate API requests. Must be included in Authorization header.

**Authentication**: Process of verifying user identity through email and password credentials.

## J

**JWT (JSON Web Token)**: Stateless authentication token containing user claims. Used for API authentication.

## R

**Refresh Token**: Long-lived token (7 days) used to obtain new access tokens without re-authenticating.

## S

**Session**: User authentication state maintained through JWT tokens stored in httpOnly cookies.
```

---

## 📊 Examples

### Example 1: User Authentication Feature

**Session**: `.steering/2026-01-01-user-authentication/`

**Implementation**:
- Added `src/auth/` module
- Created JWT middleware
- Implemented login/register endpoints

**Documentation Updates**:

1. ✅ **product-requirements.md**
   - Added "User Authentication" feature
   - Added security requirements (JWT, bcrypt)

2. ✅ **architecture.md**
   - Added "Authentication Service" component
   - Updated system diagram with auth flow

3. ✅ **repository-structure.md**
   - Added `src/auth/` directory description

4. ✅ **glossary.md**
   - Added 7 terms: JWT, Access Token, Refresh Token, Session, Authentication, Authorization, bcrypt

5. ⏭️ **development-guidelines.md**
   - No update needed (used existing patterns)

---

### Example 2: Task Management Refactor

**Session**: `.steering/2026-01-02-task-refactor/`

**Implementation**:
- Refactored task service to use repository pattern
- Moved business logic from controllers to services
- Added unit tests

**Documentation Updates**:

1. ✅ **development-guidelines.md**
   - Added "Repository Pattern" section
   - Updated "Service Layer" best practices

2. ✅ **architecture.md**
   - Updated component diagram (added repository layer)

3. ⏭️ **product-requirements.md**
   - No update (no user-facing changes)

4. ⏭️ **repository-structure.md**
   - No update (no new directories)

5. ⏭️ **glossary.md**
   - No new domain terms

---

## 🚫 What NOT to Update

### Do NOT Update Session Docs

Session documents in `.steering/` are **immutable** after creation:

❌ Do NOT modify:
- `.steering/{date}-{feature}/design.md`
- `.steering/{date}-{feature}/tasks.md`
- `.steering/{date}-{feature}/reports/`
- `.steering/{date}-{feature}/screenshots/`

✅ Only update:
- `docs/product-requirements.md`
- `docs/development-guidelines.md`
- `docs/repository-structure.md`
- `docs/architecture.md`
- `docs/glossary.md`

### Do NOT Update If Nothing Changed

If the implementation doesn't introduce new concepts, **skip the update**:

```
⏭️  Skipped 5 files (no changes needed):
  - product-requirements.md (no new features)
  - development-guidelines.md (used existing patterns)
  - repository-structure.md (no new directories)
  - architecture.md (no new components)
  - glossary.md (no new domain terms)

✅ Documentation is already up to date!
```

---

## 🎯 Success Criteria

Phase 5 is **COMPLETE** when:

- ✅ documentation-worker has analyzed the implementation
- ✅ All affected permanent docs are updated
- ✅ New domain terms are added to glossary
- ✅ Updates are accurate and reflect actual code
- ✅ No unnecessary changes were made
- ✅ **All 5 documentation evaluators passed** (≥ 8.0/10):
  - documentation-completeness-evaluator
  - documentation-accuracy-evaluator
  - documentation-consistency-evaluator
  - documentation-clarity-evaluator
  - documentation-currency-evaluator

**Gate Requirement**: All 5 evaluators must score ≥ 8.0/10 to proceed to Phase 6.

**Phase 5 is optional** - if no documentation updates are needed, it can be skipped.

---

## 📈 Best Practices

### 1. Be Surgical, Not Destructive

- Use **Edit** tool for existing files (preserve content)
- Use **Write** only for creating new files
- Don't rewrite entire sections unnecessarily

### 2. Extract Real Information

- Read actual code, not just design docs
- Verify directory names, file paths
- Use real examples from the codebase

### 3. Maintain Consistency

- Use terms from `glossary.md`
- Follow existing documentation style
- Keep formatting consistent

### 4. Document What Changed, Not Everything

- Focus on the delta (what's new)
- Don't repeat information already documented
- Add timestamps to new sections

---

## 🔁 Integration with EDAF Flow

### Before Phase 5

**Phase 4 Complete**:
```
✅ Phase 4: Code Review Gate PASSED
   - All 7 code evaluators approved
   - UI verification completed
   - Code is production-ready

📋 Next: Phase 5 - Documentation Update
```

### After Phase 5

**Documentation Updated**:
```
✅ Phase 5: Documentation Update COMPLETE
   - 3 files updated
   - Glossary has 5 new terms
   - Documentation is current

📋 Next Options:
   1. Phase 7 - Deployment Readiness (optional)
   2. Complete EDAF flow (if no deployment needed)
```

---

## 📤 Output to Phase 7 (Deployment - Optional)

After Phase 6 completion:

1. **Updated Documentation Files** in `docs/`:
   - `product-requirements.md` - Updated with new features
   - `functional-design.md` - Updated with feature details
   - `development-guidelines.md` - Updated with new patterns
   - `repository-structure.md` - Updated with new directories
   - `architecture.md` - Updated with new components
   - `glossary.md` - Updated with new domain terms
2. **Documentation Evaluation Reports**: All 5 evaluators passed (≥ 8.0/10)

**Input for Phase 7** (Optional): Documentation ready for deployment verification

---

## 🎓 Example Invocation

Full Phase 6 execution:

```typescript
console.log('\n🔄 Phase 6: Documentation Update')
console.log('━'.repeat(60))

const sessionDir = '.steering/2026-01-01-user-authentication'

// Step 1: Announce phase
await bash('.claude/scripts/update-edaf-phase.sh "Phase 6" "Documentation Update"')

// Step 2: Launch documentation-worker
const docResult = await Task({
  subagent_type: 'documentation-worker',
  model: 'sonnet',
  description: 'Update permanent documentation',
  prompt: `Update permanent documentation based on recent implementation.

**Session Directory**: ${sessionDir}

**Task**: Review implementation artifacts and update docs/ as needed.

Read these first:
1. ${sessionDir}/idea.md (requirements)
2. ${sessionDir}/design.md
3. ${sessionDir}/tasks.md
4. ${sessionDir}/reports/phase5-*.md (code review reports)

Update these if needed:
- docs/product-requirements.md
- docs/development-guidelines.md
- docs/repository-structure.md
- docs/architecture.md
- docs/glossary.md

Use Edit tool for existing files. Report what you updated and why.
`
})

// Step 3: Notify completion
await bash('.claude/scripts/notification.sh "Phase 6 documentation updated" WarblerSong')

console.log('\n✅ Phase 6 Complete')
console.log('━'.repeat(60))
```

---

**Phase 6 ensures documentation stays synchronized with code, making it easier for developers to understand the system and maintain consistency.**
