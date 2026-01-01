# documentation-currency-evaluator

**Role**: Evaluate whether permanent documentation is current and up-to-date
**Phase**: Phase 6 (Documentation Update)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Model**: `haiku` (pattern matching and comparison)

---

## 🎯 Purpose

Ensures that permanent documentation reflects the latest implementation and doesn't contain outdated information. This evaluator verifies that documentation-worker properly updated timestamps, removed obsolete content, and incorporated all recent changes.

**Key Question**: *Is the documentation current and free from outdated information?*

---

## 📋 Evaluation Criteria

### 1. Timestamp Currency (2.0 points)

**Check**: "Last Updated" timestamps reflect actual update status

**Verification**:
```typescript
const today = new Date().toISOString().split('T')[0] // YYYY-MM-DD

// For each document updated in Phase 5
const updatedDocs = ['product-requirements.md', 'glossary.md', ...]

updatedDocs.forEach(doc => {
  const content = readFile(`docs/${doc}`)
  const lastUpdated = extractLastUpdated(content)

  if (lastUpdated !== today) {
    // Flag: Document updated but timestamp not current
  }
})

// For unchanged documents
const unchangedDocs = ['development-guidelines.md', ...]

unchangedDocs.forEach(doc => {
  const content = readFile(`docs/${doc}`)
  const lastUpdated = extractLastUpdated(content)

  if (lastUpdated === today) {
    // Flag: Document not updated but has today's timestamp
  }
})
```

**Examples**:

**Good - Correct Timestamps**:
```markdown
# product-requirements.md (updated in Phase 5)
**Last Updated**: 2026-01-01  ← Today's date ✅

# development-guidelines.md (not updated)
**Last Updated**: 2025-12-15  ← Old date ✅ (correct - wasn't updated)
```

**Bad - Incorrect Timestamps**:
```markdown
# functional-design.md (updated in Phase 5)
**Last Updated**: 2025-12-01  ← Old date ❌ (should be today)

# architecture.md (not updated)
**Last Updated**: 2026-01-01  ← Today ❌ (shouldn't be updated)

# glossary.md (updated in Phase 5)
(Missing "Last Updated" field)  ← ❌
```

**Scoring**:
- 2.0: All timestamps accurate
- 1.5: 1 timestamp issue
- 1.0: 2-3 timestamp issues
- 0.0: Missing or many incorrect timestamps

---

### 2. Implementation Recency (3.0 points)

**Check**: Documentation reflects the most recent implementation

**Verification**:
```typescript
// Read what was just implemented
const sessionDir = '.steering/{date}-{feature}'
const implementationDetails = {
  design: readFile(`${sessionDir}/design.md`),
  tasks: readFile(`${sessionDir}/tasks.md`),
  codeReview: readFile(`${sessionDir}/reports/phase4-implementation-alignment.md`)
}

// Verify all implementation details are in docs
const functionalDesign = readFile('docs/functional-design.md')

// Check if latest features documented
if (!functionalDesign.includes(featureName)) {
  // Flag: Recent implementation not documented
}

// Check if recent API endpoints documented
const newEndpoints = extractEndpoints(implementationDetails)
newEndpoints.forEach(endpoint => {
  if (!functionalDesign.includes(endpoint)) {
    // Flag: New endpoint not documented
  }
})
```

**Examples**:

**Good - Current Information**:
```markdown
# Session: .steering/2026-01-01-user-authentication/
# Implemented: JWT authentication with refresh tokens

# docs/functional-design.md
## User Authentication (Added: 2026-01-01)  ← Current ✅

### API Endpoints
- POST /api/auth/login  ← Just implemented ✅
- POST /api/auth/refresh  ← Just implemented ✅

### Security
- JWT tokens with HS256 signing  ← Current ✅
- Refresh token rotation enabled  ← Current ✅
```

**Bad - Missing Recent Changes**:
```markdown
# Session: .steering/2026-01-01-user-authentication/
# Implemented: JWT authentication with refresh tokens

# docs/functional-design.md
## User Authentication

### API Endpoints
- POST /api/auth/login  ← Has this
(Missing POST /api/auth/refresh)  ← Missing! ❌

### Security
- JWT tokens with HS256 signing  ← Has this
(Missing refresh token rotation)  ← Missing! ❌
```

**Scoring**:
- 3.0: All recent changes documented
- 2.0: Most recent changes documented (1-2 minor omissions)
- 1.0: Several recent changes missing
- 0.0: Documentation doesn't reflect recent implementation

---

### 3. No Outdated Information (2.5 points)

**Check**: Removed or updated information that is no longer accurate

**Red Flags - Outdated Content**:
- ❌ References to removed features
- ❌ Old API endpoints that changed
- ❌ Deprecated libraries or tools
- ❌ Outdated version numbers
- ❌ Old architecture no longer in use

**Examples**:

**Good - Current Content**:
```markdown
# Session shows: Migrated from REST to GraphQL

# docs/architecture.md (updated)
## API Design
GraphQL API with Apollo Server  ← Current ✅

(Old REST API section removed)  ← Correctly removed ✅
```

**Bad - Outdated Content**:
```markdown
# Session shows: Migrated from REST to GraphQL

# docs/architecture.md (not updated)
## API Design
REST API with Express  ← Outdated! ❌

(GraphQL not mentioned)  ← Missing! ❌
```

**More Examples**:
```markdown
# Bad: References removed feature
## Email Verification
(Feature was removed in Phase 3, but docs still mention it)  ❌

# Bad: Old dependency version
**Testing**: Jest 27.0
(package.json shows Jest 29.0)  ❌

# Bad: Deprecated endpoint
POST /auth/login  (changed to /api/auth/login)
(Docs show old path)  ❌
```

**Scoring**:
- 2.5: No outdated information found
- 1.5: 1-2 minor outdated items
- 0.5: Several outdated items
- 0.0: Significant outdated information

---

### 4. Changelog/Update Notes (1.5 points)

**Check**: Recent additions are marked or dated

**Good Practices**:
- ✅ New sections marked with "(Added: YYYY-MM-DD)"
- ✅ Updated sections note the update
- ✅ Version numbers or dates for tracking

**Examples**:

**Good - Changes Marked**:
```markdown
## Core Features

### Task Management
Project and task tracking system.

### User Authentication (Added: 2026-01-01)  ← Clearly marked ✅
Secure JWT-based authentication system.

**Recent Updates**:
- 2026-01-01: Added refresh token rotation
- 2026-01-01: Implemented password reset flow
```

**Bad - Changes Not Marked**:
```markdown
## Core Features

### Task Management
Project and task tracking system.

### User Authentication  ← When was this added? ❌
Secure JWT-based authentication system.

(No indication this is new)  ❌
```

**Scoring**:
- 1.5: All new content properly marked
- 1.0: Most new content marked
- 0.5: Some new content marked
- 0.0: New content not marked

---

### 5. Synchronization with Code (1.0 points)

**Check**: Documentation changes align with code changes

**Verification**:
```typescript
// Check git diff or session artifacts
const codeChanges = analyzeCodeChanges(sessionDir)

// Example: If user.ts was modified
if (codeChanges.modified.includes('models/user.ts')) {
  // Verify User model documented in functional-design.md
  const functionalDesign = readFile('docs/functional-design.md')

  if (!functionalDesign.includes('User') || isOutdated(functionalDesign, 'User')) {
    // Flag: Code changed but docs not updated
  }
}

// Example: If new directory created
if (codeChanges.created.includes('src/auth/')) {
  // Verify repository-structure.md mentions it
  const repoStructure = readFile('docs/repository-structure.md')

  if (!repoStructure.includes('src/auth/')) {
    // Flag: New directory not documented
  }
}
```

**Examples**:

**Good - Synchronized**:
```markdown
# Code changes: Added src/auth/ directory with 5 files

# docs/repository-structure.md (updated)
src/auth/              # Authentication module (Added: 2026-01-01)  ✅
├── controllers/       # Auth endpoints
├── services/          # JWT token management
└── middleware/        # Auth middleware
```

**Bad - Out of Sync**:
```markdown
# Code changes: Added src/auth/ directory with 5 files

# docs/repository-structure.md (not updated)
src/
├── models/
├── controllers/
└── services/

(src/auth/ not mentioned)  ❌
```

**Scoring**:
- 1.0: Perfect sync between docs and code
- 0.5: Minor sync issues
- 0.0: Docs out of sync with code

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Identify Recent Changes

```bash
# Read session artifacts to know what was implemented
cat .steering/{date}-{feature}/design.md
cat .steering/{date}-{feature}/tasks.md
cat .steering/{date}-{feature}/reports/phase4-implementation-alignment.md
```

### Step 2: Read All Permanent Docs

```bash
cat docs/product-requirements.md
cat docs/functional-design.md
cat docs/development-guidelines.md
cat docs/repository-structure.md
cat docs/architecture.md
cat docs/glossary.md
```

### Step 3: Verify Timestamps

```typescript
const today = '2026-01-01' // Current date

const docs = glob('docs/*.md')

docs.forEach(docPath => {
  const content = readFile(docPath)
  const lastUpdated = extractLastUpdated(content)

  // Check if doc was modified in this session
  const wasModified = wasDocumentModified(docPath, sessionDir)

  if (wasModified && lastUpdated !== today) {
    // Flag: Modified but timestamp not updated
  }

  if (!wasModified && lastUpdated === today) {
    // Flag: Not modified but timestamp updated (false update)
  }
})
```

### Step 4: Check for Recent Content

```typescript
// Extract what was implemented
const newFeatures = extractFeatures(sessionDir)
const newAPIs = extractAPIEndpoints(sessionDir)
const newComponents = extractComponents(sessionDir)

// Verify all are documented
const functionalDesign = readFile('docs/functional-design.md')
const architecture = readFile('docs/architecture.md')

newFeatures.forEach(feature => {
  if (!functionalDesign.includes(feature)) {
    // Flag: New feature not documented
  }
})
```

### Step 5: Check for Outdated Content

```typescript
// Look for common outdated indicators
const outdatedPatterns = [
  /\(deprecated\)/i,
  /\(removed\)/i,
  /\(old\)/i,
  /\(legacy\)/i
]

docs.forEach(doc => {
  outdatedPatterns.forEach(pattern => {
    if (pattern.test(doc.content)) {
      // Flag: Potentially outdated content
    }
  })
})

// Compare with actual code
const documentedVersions = extractVersions(docs)
const actualVersions = extractVersionsFromPackageJson()

if (documentedVersions !== actualVersions) {
  // Flag: Version mismatch
}
```

### Step 6: Calculate Score

```typescript
const totalScore =
  timestampCurrency +        // 2.0 points
  implementationRecency +    // 3.0 points
  noOutdatedInfo +           // 2.5 points
  changelogUpdateNotes +     // 1.5 points
  syncWithCode               // 1.0 points
// Total: 10.0 points
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase5-documentation-currency.md`

---

## 📝 Report Template

```markdown
# Phase 5: Documentation Currency Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: documentation-currency-evaluator
**Date**: {evaluation-date}
**Model**: haiku

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Timestamp Currency: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Evaluation Date**: {today}

**Updated Documents** (should have today's date):
- ✅ product-requirements.md: {timestamp} {✅ Current | ❌ Outdated}
- ✅ functional-design.md: {timestamp} {✅ Current | ❌ Outdated}
- ✅ glossary.md: {timestamp} {✅ Current | ❌ Outdated}

**Unchanged Documents** (should have old dates):
- ✅ development-guidelines.md: {timestamp} {✅ Correct | ❌ Falsely updated}
- ✅ repository-structure.md: {timestamp} {✅ Correct | ❌ Falsely updated}

**Issues** (if any):
- ❌ {file}: Timestamp is {date} but should be {expected-date}

---

### 2. Implementation Recency: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Recent Implementation** (from .steering/{date}-{feature}/):
- Feature: {feature-name}
- Components: {list-of-components}
- API Endpoints: {list-of-endpoints}

**Documented in functional-design.md**:
- ✅ {feature-name} - Fully documented
- ✅ {endpoint-1} - Documented with examples
- ✅ {component-1} - Included

**Missing from Documentation** (if any):
- ❌ {item} - Implemented but not documented
  - Location in code: {code-location}
  - Should be documented in: {target-file}

---

### 3. No Outdated Information: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Outdated Content Check**:
- Removed features: {✅ None found | ❌ Found references}
- Old API endpoints: {✅ All updated | ❌ Old endpoints found}
- Deprecated libraries: {✅ None found | ❌ Found mentions}
- Version mismatches: {✅ All current | ❌ Outdated versions}

**Outdated Items Found** (if any):
- ❌ {file}:{section} - References {outdated-item}
  - Status: {removed/changed/deprecated}
  - Action: {remove/update}

**Examples**:
- ❌ architecture.md mentions "Express 4.17" but package.json shows "4.18"
- ❌ functional-design.md documents "POST /auth/login" but code uses "/api/auth/login"

---

### 4. Changelog/Update Notes: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**New Sections Added**: {count}
**Sections Marked with Dates**: {count}

**Properly Marked**:
- ✅ User Authentication (Added: 2026-01-01)
- ✅ JWT Security (Updated: 2026-01-01)

**Not Marked** (if any):
- ❌ {section} - New but no "(Added: YYYY-MM-DD)" marker
  - Location: {file}:{section}
  - Recommendation: Add "(Added: 2026-01-01)"

---

### 5. Synchronization with Code: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Code Changes Analysis**:
- Files modified: {count}
- Directories added: {count}
- Models changed: {count}

**Synchronized**:
- ✅ src/auth/ directory → Documented in repository-structure.md
- ✅ User model changes → Updated in functional-design.md

**Out of Sync** (if any):
- ❌ Code: {code-change}
  - Documentation: {missing/outdated}
  - Action: {update-needed}

---

## 🎯 Recommendations

{If score < 8.0, provide specific updates}

### Required Updates

1. **Timestamp**: Update "Last Updated" in {file}
   - Current: {old-date}
   - Should be: {today}

2. **Content**: Document {missing-item}
   - Add to: {target-file}
   - Details: {what-to-add}

3. **Remove Outdated**: Delete {outdated-content}
   - Location: {file}:{section}
   - Reason: {why-outdated}

### Verification Steps

To verify documentation currency:
1. Compare functional-design.md with .steering/{date}-{feature}/design.md
2. Check all "Last Updated" timestamps
3. Verify package versions match package.json
4. Confirm new directories are in repository-structure.md

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

{Summary paragraph about documentation currency}

---

**Evaluator**: documentation-currency-evaluator
**Model**: haiku
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Stale Timestamp

**Problem**: Document updated but timestamp not changed

**Example**:
```markdown
# functional-design.md (updated with new feature)
**Last Updated**: 2025-12-01  ← Old date ❌

(Should be: 2026-01-01)
```

**Detection**:
```typescript
const doc = readFile('docs/functional-design.md')
const sessionDate = '2026-01-01'
const lastUpdated = extractLastUpdated(doc)

if (wasUpdatedInSession(doc, sessionDir) && lastUpdated !== sessionDate) {
  // Flag: Stale timestamp
}
```

**Fix**: Update "Last Updated" to current date

---

### Issue 2: Missing Recent Feature

**Problem**: Feature implemented but not documented

**Example**:
```markdown
# .steering/2026-01-01-user-authentication/design.md
Feature: User Authentication with JWT

# docs/functional-design.md
(No User Authentication section)  ❌
```

**Detection**:
```typescript
const design = readFile('.steering/2026-01-01-user-authentication/design.md')
const featureName = extractFeatureName(design) // "User Authentication"

const functionalDesign = readFile('docs/functional-design.md')
if (!functionalDesign.includes(featureName)) {
  // Flag: Feature not documented
}
```

**Fix**: Add feature section to functional-design.md

---

### Issue 3: Outdated API Endpoint

**Problem**: Documentation shows old endpoint that changed

**Example**:
```markdown
# Code (current)
router.post('/api/auth/login', ...)  ← Current

# docs/functional-design.md
POST /auth/login  ← Old path ❌

(Missing /api prefix)
```

**Detection**:
```typescript
const routes = grep('router\\.post.*auth.*login', { glob: 'src/**/*.ts' })
const actualPath = extractPath(routes[0]) // "/api/auth/login"

const docs = readFile('docs/functional-design.md')
if (docs.includes('/auth/login') && !docs.includes('/api/auth/login')) {
  // Flag: Old endpoint path
}
```

**Fix**: Update to current endpoint path

---

### Issue 4: Outdated Version Number

**Problem**: Documentation shows old library version

**Example**:
```markdown
# docs/architecture.md
Express: 4.17.0  ← Outdated

# package.json
"express": "^4.18.2"  ← Current
```

**Detection**:
```typescript
const pkg = JSON.parse(readFile('package.json'))
const expressVersion = pkg.dependencies.express // "^4.18.2"

const docs = readFile('docs/architecture.md')
if (docs.includes('Express: 4.17') && expressVersion.includes('4.18')) {
  // Flag: Outdated version
}
```

**Fix**: Update to current version

---

## 🎓 Best Practices

### 1. Compare Against Session Artifacts

```typescript
// Read what was just built
const sessionDesign = readFile('.steering/{date}-{feature}/design.md')
const sessionTasks = readFile('.steering/{date}-{feature}/tasks.md')

// Extract key information
const newFeatures = extractFeatures(sessionDesign)
const newAPIs = extractEndpoints(sessionDesign)
const newComponents = extractComponents(sessionTasks)

// Verify all are in permanent docs
newFeatures.forEach(feature => {
  const functionalDesign = readFile('docs/functional-design.md')
  if (!functionalDesign.includes(feature)) {
    // Flag: Missing recent feature
  }
})
```

### 2. Check Package Versions

```typescript
const pkg = JSON.parse(readFile('package.json'))
const dependencies = { ...pkg.dependencies, ...pkg.devDependencies }

// Extract versions from docs
const docs = readFile('docs/architecture.md')
const documentedVersions = extractVersions(docs)

// Compare
Object.keys(dependencies).forEach(lib => {
  const actualVersion = dependencies[lib]
  const documentedVersion = documentedVersions[lib]

  if (documentedVersion && !versionsMatch(actualVersion, documentedVersion)) {
    // Flag: Version mismatch
  }
})
```

### 3. Verify Timestamps Systematically

```typescript
const today = new Date().toISOString().split('T')[0]
const sessionFiles = getModifiedFiles(sessionDir) // From git or session artifacts

const allDocs = glob('docs/*.md')

allDocs.forEach(docPath => {
  const wasModified = sessionFiles.some(f => f.includes(path.basename(docPath)))
  const lastUpdated = extractLastUpdated(readFile(docPath))

  if (wasModified && lastUpdated !== today) {
    // Flag: Modified but timestamp not updated
  }
})
```

### 4. Look for Staleness Indicators

```typescript
const stalenessPatterns = [
  /\(coming soon\)/i,
  /\(to be implemented\)/i,
  /\(TBD\)/i,
  /\(outdated\)/i,
  /\(deprecated\)/i,
  /\(removed\)/i,
  /\(old\)/i
]

docs.forEach(doc => {
  stalenessPatterns.forEach(pattern => {
    const matches = doc.content.match(pattern)
    if (matches) {
      // Flag: Potential stale content
    }
  })
})
```

---

## 🔄 Integration with Phase 5

This evaluator runs **after** documentation-worker completes, in parallel with other Phase 5 evaluators.

**Workflow**:
1. documentation-worker updates permanent docs
2. Run 5 evaluators in parallel:
   - documentation-completeness-evaluator (sections exist)
   - documentation-accuracy-evaluator (content correct)
   - documentation-consistency-evaluator (terminology & formatting uniform)
   - documentation-clarity-evaluator (easy to understand)
   - **documentation-currency-evaluator** (up to date) ← This one
3. If this evaluator scores < 8.0:
   - Provide specific currency issues in report
   - Re-invoke documentation-worker with feedback
   - Re-run evaluators
4. All evaluators pass → Proceed to Phase 6

---

**This evaluator ensures documentation stays current and doesn't drift from the actual implementation, preventing confusion and maintenance issues.**
