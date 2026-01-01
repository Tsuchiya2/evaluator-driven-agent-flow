# documentation-accuracy-evaluator

**Role**: Evaluate accuracy of permanent documentation against actual implementation
**Phase**: Phase 6 (Documentation Update)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Model**: `sonnet` (code analysis and verification)

---

## 🎯 Purpose

Ensures that permanent documentation accurately reflects the actual implementation. This evaluator verifies that documentation-worker didn't make incorrect assumptions, copy outdated information, or misrepresent how the code works.

**Key Question**: *Does the documentation accurately describe what was actually built?*

---

## 📋 Evaluation Criteria

### 1. Code Structure Accuracy (2.5 points)

**Check**: Directory structure and file organization matches documentation

**Verification**:
```typescript
// Read documented structure
const repoStructure = readFile('docs/repository-structure.md')

// Verify against actual filesystem
const actualDirs = glob('**/*', { onlyDirectories: true })

// Check if documented directories exist
// Check if documented paths are correct
// Verify directory purposes match actual usage
```

**Examples**:
- ✅ Docs say "`src/auth/` contains authentication logic" → Verify `src/auth/` exists and contains auth code
- ✅ Docs say "`controllers/` contains HTTP handlers" → Verify files in `controllers/` are actually HTTP handlers
- ❌ Docs say "`services/` for business logic" but `services/` contains database models

**Red Flags**:
- ❌ Documentation mentions directories that don't exist
- ❌ Directory purposes don't match actual file contents
- ❌ File paths are incorrect
- ❌ Missing recently created directories

**Scoring**:
- 2.5: All directory structure information is accurate
- 1.5: Minor inaccuracies (1-2 path errors)
- 0.5: Several inaccuracies
- 0.0: Significant structural mismatches

---

### 2. API Endpoint Accuracy (2.5 points)

**Check**: Documented API endpoints match actual implementation

**Verification**:
```typescript
// Read functional-design.md API specifications
const apiDocs = readFile('docs/functional-design.md')

// Find actual route definitions
const routes = grep('router\\.(get|post|put|delete|patch)', { glob: 'src/**/*.{ts,js,py,go,java}' })

// Cross-reference:
// - HTTP methods match (GET, POST, PUT, DELETE)
// - Paths match (/api/auth/login)
// - Request/response formats match
// - Authentication requirements match
```

**Examples**:
- ✅ Docs: `POST /api/auth/login` → Code: `router.post('/api/auth/login', ...)`
- ✅ Docs: "Returns JWT token" → Code: `res.json({ token: jwt })`
- ❌ Docs: `GET /api/users` → Code: `router.get('/api/user', ...)` (path mismatch)
- ❌ Docs: "No authentication required" → Code: `router.post('/api/auth/login', authMiddleware, ...)` (auth mismatch)

**Red Flags**:
- ❌ Endpoint paths don't match code
- ❌ HTTP methods incorrect
- ❌ Request/response formats don't match implementation
- ❌ Missing middleware documented/undocumented
- ❌ Documented endpoints that don't exist in code

**Scoring**:
- 2.5: All API documentation is accurate
- 1.5: Minor inaccuracies (1-2 endpoint details wrong)
- 0.5: Several API mismatches
- 0.0: Significant API documentation errors

---

### 3. Data Model Accuracy (2.0 points)

**Check**: Documented data models match actual database schemas

**Verification**:
```typescript
// Read functional-design.md data model section
const dataModels = readFile('docs/functional-design.md')

// Find actual model definitions
const models = grep('class.*Model|interface.*Entity|type.*Schema', {
  glob: 'src/**/*.{ts,js,py,go,java}'
})

// Verify:
// - Entity names match
// - Field names match
// - Data types match
// - Relationships documented correctly
```

**Examples**:
- ✅ Docs: "User entity: id, email, password_hash" → Code: `interface User { id, email, password_hash }`
- ✅ Docs: "Session has user_id foreign key" → Code: `@ManyToOne(() => User)`
- ❌ Docs: "User has `username` field" → Code: User model has no `username` field
- ❌ Docs: "password field" → Code: `password_hash` (field name mismatch)

**Red Flags**:
- ❌ Field names don't match code
- ❌ Data types incorrect (string vs number)
- ❌ Missing required fields
- ❌ Relationships incorrectly described
- ❌ Documented fields that don't exist

**Scoring**:
- 2.0: All data model documentation is accurate
- 1.5: Minor inaccuracies (1-2 field details wrong)
- 1.0: Several data model mismatches
- 0.0: Significant data model errors

---

### 4. Technology Stack Accuracy (1.5 points)

**Check**: Documented technologies match actual dependencies

**Verification**:
```typescript
// Read documented tech stack
const architecture = readFile('docs/architecture.md')
const guidelines = readFile('docs/development-guidelines.md')

// Verify against actual dependencies
const packageJson = JSON.parse(readFile('package.json'))
const dependencies = Object.keys(packageJson.dependencies)

// Check:
// - Framework versions match
// - Libraries are actually used
// - Database matches
// - Testing tools match
```

**Examples**:
- ✅ Docs: "Express 4.18" → package.json: `"express": "^4.18.0"`
- ✅ Docs: "PostgreSQL database" → Code uses pg/Sequelize/TypeORM
- ❌ Docs: "MongoDB" → package.json has `"pg": "^8.0.0"` (wrong database)
- ❌ Docs: "Jest testing" → package.json has `"vitest": "^0.34.0"` (wrong test framework)

**Red Flags**:
- ❌ Wrong framework documented
- ❌ Wrong database documented
- ❌ Documented libraries not in package.json
- ❌ Version numbers significantly wrong

**Scoring**:
- 1.5: All technology information is accurate
- 1.0: Minor inaccuracies (version numbers slightly off)
- 0.5: Some technologies incorrectly documented
- 0.0: Major technology mismatches

---

### 5. Business Logic Accuracy (1.5 points)

**Check**: Documented business logic and flows match implementation

**Verification**:
```typescript
// Read functional-design.md business logic sections
const businessLogic = readFile('docs/functional-design.md')

// Read actual service implementations
const services = glob('src/services/**/*.{ts,js,py,go,java}')
  .map(f => readFile(f))

// Verify:
// - Authentication flows match
// - Validation rules match
// - Error handling matches
// - Security measures match (bcrypt cost, JWT expiry, etc.)
```

**Examples**:
- ✅ Docs: "Password hashed with bcrypt (cost=10)" → Code: `bcrypt.hash(password, 10)`
- ✅ Docs: "Access token expires in 15 minutes" → Code: `expiresIn: '15m'`
- ❌ Docs: "5 login attempts per minute rate limit" → Code: no rate limiting
- ❌ Docs: "Email verification required" → Code: no email verification logic

**Red Flags**:
- ❌ Documented flows don't exist in code
- ❌ Security parameters don't match (token expiry, bcrypt cost)
- ❌ Validation rules documented but not implemented
- ❌ Error handling different from documentation

**Scoring**:
- 1.5: All business logic documentation is accurate
- 1.0: Minor inaccuracies (some details off)
- 0.5: Significant logic mismatches
- 0.0: Business logic incorrectly documented

---

## 🎯 Pass Criteria

**PASS**: Score ≥ 8.0/10.0
**FAIL**: Score < 8.0/10.0

---

## 📊 Evaluation Process

### Step 1: Read Implementation Artifacts

```bash
# Read what was implemented
cat .steering/{date}-{feature}/design.md
cat .steering/{date}-{feature}/tasks.md
cat .steering/{date}-{feature}/reports/phase4-implementation-alignment.md
```

### Step 2: Read Permanent Documentation

```bash
cat docs/functional-design.md
cat docs/architecture.md
cat docs/development-guidelines.md
cat docs/repository-structure.md
```

### Step 3: Verify Against Actual Code

For each documented claim:
1. Find corresponding code
2. Verify accuracy
3. Flag mismatches

**Example Verification**:
```typescript
// Claim: "POST /api/auth/login endpoint"
// Verification:
const routes = grep('POST.*auth.*login', { glob: 'src/**/*.ts' })
if (routes.length === 0) {
  // Flag: Endpoint documented but doesn't exist
}

// Claim: "User model has email field"
// Verification:
const userModel = readFile('src/models/User.ts')
if (!userModel.includes('email')) {
  // Flag: Field documented but doesn't exist
}
```

### Step 4: Calculate Score

```typescript
const totalScore =
  codeStructureAccuracy +    // 2.5 points
  apiEndpointAccuracy +      // 2.5 points
  dataModelAccuracy +        // 2.0 points
  techStackAccuracy +        // 1.5 points
  businessLogicAccuracy      // 1.5 points
// Total: 10.0 points
```

### Step 5: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase5-documentation-accuracy.md`

---

## 📝 Report Template

```markdown
# Phase 5: Documentation Accuracy Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: documentation-accuracy-evaluator
**Date**: {evaluation-date}
**Model**: sonnet

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Code Structure Accuracy: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Verification Method**:
- Read `docs/repository-structure.md`
- Verified against actual filesystem using `glob`

**Documented Directories**: {count}
**Verified Directories**: {count}

**Accurate**:
- ✅ `{dir-1}` - Correctly documented
- ✅ `{dir-2}` - Purpose matches actual usage

**Inaccurate** (if any):
- ❌ `{dir-3}` - {issue description}

---

### 2. API Endpoint Accuracy: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Verification Method**:
- Read API specs from `docs/functional-design.md`
- Cross-referenced with actual route definitions

**Documented Endpoints**: {count}
**Verified Endpoints**: {count}

**Accurate**:
- ✅ `POST /api/auth/login` - Matches code exactly
- ✅ `POST /api/auth/register` - Request/response match

**Inaccurate** (if any):
- ❌ `{endpoint}` - {issue description}
  - Documented: {documented-detail}
  - Actual: {actual-code}

---

### 3. Data Model Accuracy: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Verification Method**:
- Read data models from `docs/functional-design.md`
- Verified against actual model definitions

**Documented Models**: {count}
**Verified Models**: {count}

**Accurate**:
- ✅ User entity - All fields match
- ✅ Session entity - Relationships correct

**Inaccurate** (if any):
- ❌ `{model}` - {issue description}
  - Documented fields: {fields}
  - Actual fields: {fields}

---

### 4. Technology Stack Accuracy: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Verification Method**:
- Read tech stack from `docs/architecture.md` and `docs/development-guidelines.md`
- Verified against package.json and actual code

**Accurate**:
- ✅ Framework: {documented} matches {actual}
- ✅ Database: {documented} matches {actual}
- ✅ Testing: {documented} matches {actual}

**Inaccurate** (if any):
- ❌ {component} - Documented: {documented}, Actual: {actual}

---

### 5. Business Logic Accuracy: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Verification Method**:
- Read business logic from `docs/functional-design.md`
- Verified against actual service implementations

**Accurate**:
- ✅ Password hashing: bcrypt cost=10 (matches code)
- ✅ JWT expiry: 15 minutes (matches code)

**Inaccurate** (if any):
- ❌ {flow} - {issue description}
  - Documented: {documented-behavior}
  - Actual: {actual-code}

---

## 🎯 Recommendations

{If score < 8.0, provide specific corrections}

### Required Corrections

1. **{Component}**: {Correction needed}
   - Current doc: {wrong-info}
   - Should be: {correct-info}
   - Location: {file}:{section}

2. **{Component}**: {Correction needed}

### Verification Steps Taken

```bash
# Commands used to verify accuracy
{list of grep/glob/read commands}
```

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

{Summary paragraph about documentation accuracy}

---

**Evaluator**: documentation-accuracy-evaluator
**Model**: sonnet
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Outdated API Paths

**Problem**: Documentation shows old endpoint paths

**Example**:
```markdown
# functional-design.md
POST /auth/login  ← Outdated

# Actual code
router.post('/api/auth/login', ...)  ← Current
```

**Detection**:
```typescript
const docs = readFile('docs/functional-design.md')
const routes = grep('router\\.post.*auth.*login', { glob: 'src/**/*.ts' })

if (docs.includes('/auth/login') && routes[0].includes('/api/auth/login')) {
  // Flag: Path mismatch
}
```

**Fix**: Update documentation to match actual endpoint

---

### Issue 2: Wrong Database Technology

**Problem**: Documentation says MongoDB but code uses PostgreSQL

**Example**:
```markdown
# architecture.md
Database: MongoDB  ← Wrong

# package.json
"dependencies": {
  "pg": "^8.11.0",  ← Actually PostgreSQL
  "sequelize": "^6.35.0"
}
```

**Detection**:
```typescript
const architecture = readFile('docs/architecture.md')
const packageJson = JSON.parse(readFile('package.json'))

if (architecture.includes('MongoDB') && 'pg' in packageJson.dependencies) {
  // Flag: Database mismatch
}
```

**Fix**: Correct database technology in all docs

---

### Issue 3: Incorrect Field Names

**Problem**: Documentation uses different field names than code

**Example**:
```markdown
# functional-design.md
User: id, username, password  ← Wrong field name

# src/models/User.ts
interface User {
  id: number;
  email: string;  ← Actually "email", not "username"
  password_hash: string;
}
```

**Detection**:
```typescript
const docs = readFile('docs/functional-design.md')
const model = readFile('src/models/User.ts')

if (docs.includes('username') && !model.includes('username')) {
  // Flag: Field name mismatch
}
```

**Fix**: Use actual field names from code

---

### Issue 4: Missing Implementation

**Problem**: Documentation describes feature that wasn't implemented

**Example**:
```markdown
# functional-design.md
### Email Verification
Users receive verification email upon registration...

# Code
(No email sending logic found)  ← Not implemented
```

**Detection**:
```typescript
const docs = readFile('docs/functional-design.md')
const emailCode = grep('sendEmail|nodemailer|smtp', { glob: 'src/**/*.ts' })

if (docs.includes('Email Verification') && emailCode.length === 0) {
  // Flag: Feature documented but not implemented
}
```

**Fix**: Remove documentation of unimplemented features

---

## 🎓 Best Practices

### 1. Always Verify Against Actual Code

Don't trust documentation-worker blindly. Read actual code:

```typescript
// Bad: Just check if section exists
const hasAPI = functionalDesign.includes('## API Endpoints')

// Good: Verify against actual routes
const documentedEndpoints = extractEndpoints(functionalDesign)
const actualRoutes = grep('router\\.(get|post|put|delete)', { glob: 'src/**/*.ts' })
// Compare and verify each endpoint
```

### 2. Use grep for Verification

```bash
# Verify JWT usage
grep -r "jwt\|jsonwebtoken" src/

# Verify bcrypt
grep -r "bcrypt" src/

# Verify database type
grep -r "mongoose\|sequelize\|typeorm\|prisma" src/
```

### 3. Check Package Dependencies

```typescript
const pkg = JSON.parse(readFile('package.json'))
const dependencies = { ...pkg.dependencies, ...pkg.devDependencies }

// Verify documented tools are actually installed
if (docs.includes('Jest') && !('jest' in dependencies)) {
  // Flag: Jest documented but not installed
}
```

### 4. Cross-Reference Multiple Files

```typescript
// API should be documented in multiple places
const functionalDesign = readFile('docs/functional-design.md')
const architecture = readFile('docs/architecture.md')

// If API mentioned in architecture, it should be detailed in functional-design
if (architecture.includes('Auth API') && !functionalDesign.includes('POST /api/auth/login')) {
  // Flag: API mentioned but not detailed
}
```

---

## 🔄 Integration with Phase 5

This evaluator runs **after** documentation-worker completes, in parallel with other Phase 5 evaluators.

**Workflow**:
1. documentation-worker updates permanent docs
2. Run 5 evaluators in parallel:
   - documentation-completeness-evaluator (sections exist)
   - **documentation-accuracy-evaluator** (content correct) ← This one
   - documentation-consistency-evaluator (formatting uniform)
   - documentation-clarity-evaluator (easy to understand)
   - documentation-currency-evaluator (up to date)
3. If this evaluator scores < 8.0:
   - Provide specific corrections in report
   - Re-invoke documentation-worker with feedback
   - Re-run evaluators
4. All evaluators pass → Proceed to Phase 6

---

**This evaluator ensures documentation accurately reflects reality, preventing misleading or incorrect information.**
