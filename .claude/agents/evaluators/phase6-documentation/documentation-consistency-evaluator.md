# documentation-consistency-evaluator

**Role**: Evaluate consistency of terminology, formatting, and information across permanent documentation
**Phase**: Phase 6 (Documentation Update)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Model**: `haiku` (pattern matching and consistency checks)

---

## 🎯 Purpose

Ensures that permanent documentation uses consistent terminology, formatting, and doesn't contain conflicting information. This evaluator verifies that documentation-worker maintained uniformity across all documents and properly used terms from the glossary.

**Key Question**: *Is the documentation internally consistent without conflicts or formatting issues?*

---

## 📋 Evaluation Criteria

### 1. Terminology Consistency (3.0 points)

**Check**: Domain terms are used consistently and match glossary definitions

**Verification**:
```typescript
// Read glossary terms
const glossary = readFile('docs/glossary.md')
const terms = extractGlossaryTerms(glossary)

// Check all docs use these terms correctly
const docs = [
  'product-requirements.md',
  'functional-design.md',
  'development-guidelines.md',
  'repository-structure.md',
  'architecture.md'
].map(f => readFile(`docs/${f}`))

// Verify:
// - Terms match glossary definitions
// - Same concept uses same term throughout
// - No synonyms used inconsistently
```

**Examples of Consistency**:
- ✅ Glossary defines "Access Token" → All docs use "Access Token" (not "auth token", "access_token", "token")
- ✅ Glossary defines "JWT" → All docs use "JWT" consistently
- ❌ Glossary: "Refresh Token" → Some docs say "refresh token", others say "refresh_token"
- ❌ Glossary: "User Authentication" → Some docs say "user auth", others say "authentication"

**Red Flags**:
- ❌ Using term variants not in glossary
- ❌ Same concept described with different terms
- ❌ Capitalization inconsistent (Access Token vs access token)
- ❌ Technical terms used but not defined in glossary

**Scoring**:
- 3.0: All terminology perfectly consistent with glossary
- 2.0: Minor inconsistencies (1-2 term variations)
- 1.0: Multiple terminology inconsistencies
- 0.0: Significant terminology chaos

---

### 2. Formatting Consistency (2.0 points)

**Check**: All documents follow the same formatting style

**Verification Areas**:

**Header Hierarchy**:
```markdown
# Title (H1) - Document title
## Section (H2) - Major sections
### Subsection (H3) - Subsections
#### Details (H4) - Detail sections
```

**Code Blocks**:
```markdown
✅ Consistent:
\`\`\`typescript
const example = 'code'
\`\`\`

❌ Inconsistent:
\`\`\`
const example = 'code'  ← Missing language
\`\`\`
```

**Lists**:
```markdown
✅ Consistent bullet style:
- Item 1
- Item 2

✅ Consistent numbering:
1. Step 1
2. Step 2

❌ Mixed styles:
* Item 1
- Item 2
```

**Dates**:
```markdown
✅ Consistent: 2026-01-01 (YYYY-MM-DD)
❌ Inconsistent: Jan 1, 2026, 01/01/2026
```

**File Paths**:
```markdown
✅ Consistent: `src/auth/controllers/login.ts`
❌ Inconsistent: src/auth/controllers/login.ts (no backticks)
```

**Scoring**:
- 2.0: All formatting perfectly consistent
- 1.5: Minor formatting variations (1-2 issues)
- 1.0: Multiple formatting inconsistencies
- 0.0: Significant formatting chaos

---

### 3. Cross-Document Consistency (2.5 points)

**Check**: Same information described identically across multiple documents

**Verification**:
```typescript
// Extract facts mentioned in multiple documents
const facts = [
  { topic: 'Authentication method', files: ['product-requirements.md', 'architecture.md', 'functional-design.md'] },
  { topic: 'Database type', files: ['architecture.md', 'development-guidelines.md'] },
  { topic: 'Tech stack', files: ['architecture.md', 'development-guidelines.md'] }
]

// Verify each fact is stated identically
facts.forEach(fact => {
  const descriptions = fact.files.map(f => extractDescription(f, fact.topic))
  if (!allEqual(descriptions)) {
    // Flag: Inconsistent information
  }
})
```

**Examples**:

**Good - Consistent**:
```markdown
# product-requirements.md
Authentication: JWT tokens

# architecture.md
Authentication: JWT tokens

# functional-design.md
Authentication: JWT tokens
```

**Bad - Inconsistent**:
```markdown
# product-requirements.md
Database: PostgreSQL 14

# architecture.md
Database: PostgreSQL 15  ← Version mismatch

# development-guidelines.md
Database: Postgres  ← Name variant
```

**Common Conflicts to Check**:
- Technology versions (Express 4.18 vs 4.19)
- Authentication methods (JWT vs Session-based)
- Database names (PostgreSQL vs Postgres vs pg)
- Framework names (React vs ReactJS)
- API base paths (/api vs /v1/api)

**Scoring**:
- 2.5: All cross-document information consistent
- 1.5: Minor conflicts (1-2 version number mismatches)
- 0.5: Multiple information conflicts
- 0.0: Significant contradictions

---

### 4. Naming Convention Consistency (1.5 points)

**Check**: File names, directory names, and code examples use consistent conventions

**Verification**:
```typescript
// Check naming patterns
const patterns = {
  files: /[a-z-]+\.md/,        // kebab-case for markdown
  dirs: /[a-z-]+/,             // lowercase for directories
  types: /[A-Z][a-zA-Z]+/,     // PascalCase for types
  variables: /[a-z][a-zA-Z]+/, // camelCase for variables
}

// Verify all documentation uses same patterns
```

**Examples**:

**Good - Consistent**:
```markdown
# Across all docs
- Files: user-controller.ts, auth-service.ts (kebab-case)
- Classes: UserController, AuthService (PascalCase)
- Variables: userId, accessToken (camelCase)
```

**Bad - Inconsistent**:
```markdown
# repository-structure.md
- src/userController.ts  ← camelCase

# development-guidelines.md
- src/user-controller.ts  ← kebab-case (conflict!)

# functional-design.md
- src/user_controller.ts  ← snake_case (conflict!)
```

**Red Flags**:
- ❌ File naming convention varies between docs
- ❌ Directory names use different cases
- ❌ Variable naming inconsistent in examples
- ❌ API endpoint casing varies

**Scoring**:
- 1.5: All naming conventions perfectly consistent
- 1.0: Minor inconsistencies (1-2 examples)
- 0.5: Multiple naming convention conflicts
- 0.0: Significant naming chaos

---

### 5. Update Timestamp Consistency (1.0 points)

**Check**: All updated documents have current "Last Updated" timestamps

**Verification**:
```typescript
// Read all docs
const docs = glob('docs/*.md').map(f => ({
  file: f,
  content: readFile(f)
}))

// Check "Last Updated" dates
const updates = docs.map(doc => ({
  file: doc.file,
  lastUpdated: extractLastUpdated(doc.content)
}))

// Verify:
// - All docs updated in Phase 5 have today's date
// - Unchanged docs have old dates (correct)
```

**Examples**:

**Good**:
```markdown
# product-requirements.md (updated in Phase 5)
**Last Updated**: 2026-01-01  ← Today

# architecture.md (not updated)
**Last Updated**: 2025-12-15  ← Old date (correct)
```

**Bad**:
```markdown
# functional-design.md (updated in Phase 5)
**Last Updated**: 2025-12-01  ← Old date (should be today!)

# glossary.md (updated in Phase 5)
(No "Last Updated" field)  ← Missing timestamp
```

**Scoring**:
- 1.0: All timestamps correct and consistent
- 0.5: 1-2 timestamp issues
- 0.0: Missing or incorrect timestamps

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Read All Documentation

```bash
cat docs/product-requirements.md
cat docs/functional-design.md
cat docs/development-guidelines.md
cat docs/repository-structure.md
cat docs/architecture.md
cat docs/glossary.md
```

### Step 2: Extract Glossary Terms

```typescript
const glossary = readFile('docs/glossary.md')
const terms = extractTermsFromGlossary(glossary)
// Example: ["JWT", "Access Token", "Refresh Token", "Session", ...]
```

### Step 3: Check Terminology Usage

```typescript
const allDocs = glob('docs/*.md').map(f => readFile(f))

terms.forEach(term => {
  allDocs.forEach(doc => {
    // Check if term is used consistently
    const variants = findTermVariants(doc, term)
    if (variants.length > 1) {
      // Flag: Term used inconsistently
    }
  })
})
```

### Step 4: Verify Formatting

```typescript
// Check header hierarchy
const headers = extractHeaders(doc)
// Verify: H1 → H2 → H3 (no skipping levels)

// Check code blocks
const codeBlocks = extractCodeBlocks(doc)
// Verify: All have language specified

// Check lists
const lists = extractLists(doc)
// Verify: Consistent bullet style (-, not *)
```

### Step 5: Check Cross-Document Facts

```typescript
// Example: Authentication method
const authInReqs = extractAuth('docs/product-requirements.md')
const authInArch = extractAuth('docs/architecture.md')
const authInFunc = extractAuth('docs/functional-design.md')

if (authInReqs !== authInArch || authInArch !== authInFunc) {
  // Flag: Inconsistent authentication description
}
```

### Step 6: Calculate Score

```typescript
const totalScore =
  terminologyConsistency +   // 3.0 points
  formattingConsistency +    // 2.0 points
  crossDocConsistency +      // 2.5 points
  namingConventions +        // 1.5 points
  timestampConsistency       // 1.0 points
// Total: 10.0 points
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase5-documentation-consistency.md`

---

## 📝 Report Template

```markdown
# Phase 5: Documentation Consistency Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: documentation-consistency-evaluator
**Date**: {evaluation-date}
**Model**: haiku

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Terminology Consistency: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Glossary Terms Checked**: {count}

**Consistent Usage**:
- ✅ "JWT" - Used consistently across all docs
- ✅ "Access Token" - Capitalization consistent

**Inconsistent Usage** (if any):
- ❌ "Refresh Token" vs "refresh token" vs "refresh_token"
  - product-requirements.md: "Refresh Token"
  - architecture.md: "refresh token"
  - functional-design.md: "refresh_token"

**Recommendation**: Use glossary term exactly: "Refresh Token"

---

### 2. Formatting Consistency: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Checks Performed**:
- Header hierarchy: {✅ Consistent | ❌ Issues found}
- Code blocks: {✅ All have language | ❌ Missing language}
- Lists: {✅ Consistent bullets | ❌ Mixed styles}
- Dates: {✅ YYYY-MM-DD format | ❌ Mixed formats}
- File paths: {✅ Backticks used | ❌ Inconsistent}

**Formatting Issues** (if any):
- {file}:{line} - {issue description}

---

### 3. Cross-Document Consistency: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Facts Verified**: {count}

**Consistent Facts**:
- ✅ Authentication method: "JWT tokens" (all docs agree)
- ✅ Testing framework: "Jest" (all docs agree)

**Inconsistent Facts** (if any):
- ❌ Database version:
  - architecture.md: "PostgreSQL 14"
  - development-guidelines.md: "PostgreSQL 15"
  - Recommendation: Verify actual version, update all to match

---

### 4. Naming Convention Consistency: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Conventions Checked**:
- File naming: {convention-found}
- Directory naming: {convention-found}
- Class naming: {convention-found}
- Variable naming: {convention-found}

**Consistent**:
- ✅ Files use kebab-case across all docs
- ✅ Classes use PascalCase across all docs

**Inconsistent** (if any):
- ❌ {item} - {inconsistency description}

---

### 5. Update Timestamp Consistency: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Documents Updated in Phase 5**: {count}

**Correct Timestamps**:
- ✅ product-requirements.md: 2026-01-01 (today)
- ✅ glossary.md: 2026-01-01 (today)

**Incorrect Timestamps** (if any):
- ❌ functional-design.md: Missing "Last Updated" field
- ❌ architecture.md: Shows old date but was updated

---

## 🎯 Recommendations

{If score < 8.0, provide specific fixes}

### Required Fixes

1. **Terminology**: Standardize usage of {term}
   - Replace "{variant-1}" with "{standard-term}"
   - Files affected: {file-list}

2. **Formatting**: Fix {formatting-issue}
   - {specific-fix}

3. **Cross-Document**: Resolve {conflict}
   - Verify actual {fact}
   - Update all docs to match

### Consistency Improvements

1. {Improvement 1}
2. {Improvement 2}

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

{Summary paragraph about documentation consistency}

---

**Evaluator**: documentation-consistency-evaluator
**Model**: haiku
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Glossary Term Variants

**Problem**: Same concept using different term forms

**Example**:
```markdown
# glossary.md
**Access Token**: Short-lived JWT token...

# product-requirements.md
Uses "access token" (lowercase)

# architecture.md
Uses "Access_Token" (snake_case)

# functional-design.md
Uses "auth token" (different term!)
```

**Detection**:
```typescript
const glossaryTerm = "Access Token"
const variants = [
  findOccurrences(docs, "access token"),
  findOccurrences(docs, "Access_Token"),
  findOccurrences(docs, "auth token")
]
if (variants.some(v => v.length > 0)) {
  // Flag: Term used inconsistently
}
```

**Fix**: Use exact glossary term: "Access Token"

---

### Issue 2: Version Number Conflicts

**Problem**: Different documents show different versions

**Example**:
```markdown
# architecture.md
Express 4.18.0

# development-guidelines.md
Express 4.19.0  ← Conflict!
```

**Detection**:
```typescript
const versions = {
  'architecture.md': extractVersion('architecture.md', 'Express'),
  'development-guidelines.md': extractVersion('development-guidelines.md', 'Express')
}

if (versions['architecture.md'] !== versions['development-guidelines.md']) {
  // Flag: Version conflict
}
```

**Fix**: Verify actual version in package.json, update all docs to match

---

### Issue 3: Inconsistent Code Block Languages

**Problem**: Some code blocks missing language specifier

**Example**:
```markdown
# functional-design.md
\`\`\`typescript  ← Good
const user = { id: 1 }
\`\`\`

# development-guidelines.md
\`\`\`  ← Missing language!
const user = { id: 1 }
\`\`\`
```

**Detection**:
```typescript
const codeBlocks = extractCodeBlocks(doc)
const missingLang = codeBlocks.filter(block => !block.language)
if (missingLang.length > 0) {
  // Flag: Code blocks missing language
}
```

**Fix**: Add language to all code blocks

---

### Issue 4: Mixed List Styles

**Problem**: Some docs use `-`, others use `*` for bullets

**Example**:
```markdown
# product-requirements.md
- Feature 1  ← Uses dash
- Feature 2

# architecture.md
* Component 1  ← Uses asterisk
* Component 2
```

**Detection**:
```typescript
const listStyles = docs.map(doc => ({
  file: doc.file,
  style: detectListStyle(doc.content)
}))

if (new Set(listStyles.map(s => s.style)).size > 1) {
  // Flag: Mixed list styles
}
```

**Fix**: Standardize on `-` for all bullet lists

---

## 🎓 Best Practices

### 1. Build Term Dictionary

Extract all glossary terms first, then scan for them:

```typescript
const glossary = readFile('docs/glossary.md')
const terms = extractGlossaryTerms(glossary)
// ["JWT", "Access Token", "Refresh Token", ...]

// For each term, find all uses
terms.forEach(term => {
  const usages = findAllUsages(term, allDocs)
  // Check if all usages match exact term
})
```

### 2. Use Exact String Matching

Don't use fuzzy matching - look for exact terms:

```typescript
// Bad: Too fuzzy
if (doc.toLowerCase().includes(term.toLowerCase())) { }

// Good: Exact match with word boundaries
const regex = new RegExp(`\\b${escapeRegex(term)}\\b`, 'g')
const matches = doc.match(regex)
```

### 3. Check Code Block Languages

```typescript
const codeBlockRegex = /```(\w*)\n/g
const blocks = [...doc.matchAll(codeBlockRegex)]

blocks.forEach((block, index) => {
  if (!block[1]) {
    // Flag: Code block ${index} missing language
  }
})
```

### 4. Verify Header Hierarchy

```typescript
const headers = extractHeaders(doc)
// Example: [1, 2, 3, 2, 3, 4]  ← Level 4 without level 3 parent!

for (let i = 1; i < headers.length; i++) {
  if (headers[i] - headers[i-1] > 1) {
    // Flag: Header level skipped
  }
}
```

---

## 🔄 Integration with Phase 5

This evaluator runs **after** documentation-worker completes, in parallel with other Phase 5 evaluators.

**Workflow**:
1. documentation-worker updates permanent docs
2. Run 5 evaluators in parallel:
   - documentation-completeness-evaluator (sections exist)
   - documentation-accuracy-evaluator (content correct)
   - **documentation-consistency-evaluator** (terminology & formatting uniform) ← This one
   - documentation-clarity-evaluator (easy to understand)
   - documentation-currency-evaluator (up to date)
3. If this evaluator scores < 8.0:
   - Provide specific consistency fixes in report
   - Re-invoke documentation-worker with feedback
   - Re-run evaluators
4. All evaluators pass → Proceed to Phase 6

---

**This evaluator ensures documentation maintains internal consistency, making it easier to understand and more professional.**
