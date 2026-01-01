# documentation-clarity-evaluator

**Role**: Evaluate clarity and understandability of permanent documentation
**Phase**: Phase 6 (Documentation Update)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Model**: `haiku` (readability checking is straightforward)

---

## 🎯 Purpose

Ensures that permanent documentation is clear, understandable, and accessible to developers. This evaluator verifies that documentation-worker created content that is easy to read, properly explained, and provides helpful examples.

**Key Question**: *Can developers easily understand the documentation?*

---

## 📋 Evaluation Criteria

### 1. Explanation Quality (3.0 points)

**Check**: Concepts are clearly explained with sufficient context

**Good Explanation Characteristics**:
- ✅ Provides context (what and why)
- ✅ Uses plain language where possible
- ✅ Defines technical terms before using them
- ✅ Explains rationale for design decisions
- ✅ Avoids unexplained jargon

**Examples**:

**Good - Clear Explanation**:
```markdown
## Authentication

The system uses JWT (JSON Web Token) authentication for stateless API authentication.
JWTs allow clients to authenticate without server-side sessions, improving scalability.

**How it works:**
1. User logs in with email/password
2. Server generates JWT containing user ID and permissions
3. Client includes JWT in Authorization header for subsequent requests
4. Server validates JWT signature without database lookup

**Why JWT?**
- Stateless (no server-side session storage)
- Scalable (no session replication needed)
- Secure (cryptographically signed)
```

**Bad - Unclear Explanation**:
```markdown
## Authentication

Uses JWT. Access tokens expire in 15 min.
```
*Problems*: No explanation of what JWT is, why it's used, or how it works

**Red Flags**:
- ❌ Unexplained acronyms (JWT, RBAC, ORM)
- ❌ No context provided
- ❌ Assumes reader knowledge
- ❌ Missing "why" for design decisions
- ❌ Technical jargon without definitions

**Scoring**:
- 3.0: All concepts clearly explained with context
- 2.0: Most concepts explained (some minor gaps)
- 1.0: Many concepts poorly explained
- 0.0: Minimal or no explanations

---

### 2. Example Quality (2.5 points)

**Check**: Concrete examples provided for important concepts

**Good Example Characteristics**:
- ✅ Realistic code examples
- ✅ Proper syntax highlighting
- ✅ Shows typical use cases
- ✅ Includes input/output
- ✅ Demonstrates best practices

**Examples**:

**Good - Helpful Example**:
```markdown
### User Registration Endpoint

**Endpoint**: POST /api/auth/register

**Request Body**:
\`\`\`json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
\`\`\`

**Success Response** (201 Created):
\`\`\`json
{
  "user": {
    "id": 42,
    "email": "user@example.com",
    "created_at": "2026-01-01T10:00:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
\`\`\`

**Error Response** (409 Conflict - Email already exists):
\`\`\`json
{
  "error": "EMAIL_ALREADY_EXISTS",
  "message": "An account with this email already exists"
}
\`\`\`

**Example Usage** (JavaScript):
\`\`\`typescript
const response = await fetch('/api/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'SecurePass123!'
  })
})

const data = await response.json()
console.log(data.access_token) // Store this for authenticated requests
\`\`\`
```

**Bad - Poor Example**:
```markdown
### User Registration

POST /api/auth/register

Accepts email and password.
```
*Problems*: No example request/response, no code, no error handling

**Red Flags**:
- ❌ No code examples for important features
- ❌ Examples missing syntax highlighting
- ❌ Unrealistic or trivial examples
- ❌ No error case examples
- ❌ Missing input/output

**Scoring**:
- 2.5: Excellent examples for all important concepts
- 1.5: Good examples but some gaps
- 0.5: Few or poor-quality examples
- 0.0: No examples provided

---

### 3. Structural Clarity (2.0 points)

**Check**: Information is logically organized and easy to navigate

**Good Structure Characteristics**:
- ✅ Logical section order (overview → details → examples)
- ✅ Clear hierarchy (H1 → H2 → H3)
- ✅ Related information grouped together
- ✅ Important information prominently placed
- ✅ Table of contents for long documents

**Examples**:

**Good - Clear Structure**:
```markdown
# User Authentication

## Overview
Brief description of authentication system

## Authentication Flow
Step-by-step explanation with diagram

## API Endpoints
### Registration
Details and examples

### Login
Details and examples

### Token Refresh
Details and examples

## Security Considerations
Security measures and best practices

## Error Handling
Common errors and how to handle them

## Testing
How to test authentication
```

**Bad - Poor Structure**:
```markdown
# User Authentication

Token expires in 15 minutes.

POST /api/auth/login

Uses bcrypt for passwords.

Refresh tokens last 7 days.

POST /api/auth/register
```
*Problems*: No logical order, mixed details, hard to follow

**Red Flags**:
- ❌ Random information order
- ❌ No clear sections
- ❌ Related info scattered across document
- ❌ Header hierarchy skipped (H1 → H3)
- ❌ Wall of text without breaks

**Scoring**:
- 2.0: Perfectly organized and easy to navigate
- 1.5: Good structure with minor issues
- 1.0: Somewhat disorganized
- 0.0: Chaotic or confusing structure

---

### 4. Terminology Usage (1.5 points)

**Check**: Technical terms are introduced and used appropriately

**Good Terminology Usage**:
- ✅ Define terms on first use
- ✅ Use glossary for complex terms
- ✅ Provide context for acronyms
- ✅ Link to glossary for detailed definitions
- ✅ Balance technical accuracy with readability

**Examples**:

**Good - Clear Terminology**:
```markdown
## Session Management

The system uses **JWT (JSON Web Token)** for session management.
A JWT is a cryptographically signed token that contains user information
and is used to authenticate requests without server-side storage.

**Key Terms** (see [Glossary](./glossary.md) for details):
- **Access Token**: Short-lived JWT (15 minutes) for API authentication
- **Refresh Token**: Long-lived token (7 days) for obtaining new access tokens
- **Token Rotation**: Issuing new refresh token on each use

### Token Structure

An access token contains:
\`\`\`json
{
  "sub": "42",          // User ID (subject)
  "email": "user@example.com",
  "exp": 1672531200,    // Expiration timestamp
  "iat": 1672530300     // Issued at timestamp
}
\`\`\`
```

**Bad - Poor Terminology**:
```markdown
## Session Management

Uses JWT with RBAC. Implements token rotation via RT and AT mechanisms.
Expiry handled through exp claim validation.
```
*Problems*: Unexplained acronyms, assumes reader knowledge, no context

**Red Flags**:
- ❌ Acronyms not defined
- ❌ Technical jargon without explanation
- ❌ Terms used before being introduced
- ❌ No links to glossary
- ❌ Overly technical without need

**Scoring**:
- 1.5: All terms properly introduced and explained
- 1.0: Most terms explained (some gaps)
- 0.5: Many unexplained terms
- 0.0: Heavy jargon without explanations

---

### 5. Visual Aids (1.0 points)

**Check**: Diagrams, tables, or visual representations provided where helpful

**Good Visual Aids**:
- ✅ Architecture diagrams (ASCII art or mermaid)
- ✅ Flow charts for processes
- ✅ Tables for structured data
- ✅ Code examples with comments
- ✅ Directory trees

**Examples**:

**Good - Helpful Visual**:
```markdown
## Authentication Flow

\`\`\`mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Database

    Client->>Server: POST /api/auth/login {email, password}
    Server->>Database: Find user by email
    Database-->>Server: User record
    Server->>Server: Verify password with bcrypt
    Server->>Server: Generate JWT tokens
    Server-->>Client: {access_token, refresh_token}
    Client->>Server: GET /api/users/profile (with access_token)
    Server->>Server: Validate JWT
    Server-->>Client: User profile data
\`\`\`

## Directory Structure

\`\`\`
src/auth/
├── controllers/
│   ├── login.controller.ts      # Login endpoint handler
│   ├── register.controller.ts   # Registration endpoint handler
│   └── refresh.controller.ts    # Token refresh handler
├── services/
│   ├── auth.service.ts          # Authentication business logic
│   └── jwt.service.ts           # JWT generation/validation
├── middleware/
│   └── auth.middleware.ts       # JWT verification middleware
└── models/
    └── session.model.ts         # Session data model
\`\`\`

## Token Comparison

| Feature | Access Token | Refresh Token |
|---------|-------------|---------------|
| **Lifetime** | 15 minutes | 7 days |
| **Purpose** | API authentication | Get new access token |
| **Storage** | Memory (volatile) | httpOnly cookie |
| **Rotation** | No | Yes (on each use) |
\`\`\`
```

**Bad - No Visuals**:
```markdown
## Authentication Flow

User logs in, server verifies password, generates tokens, returns them.
Server validates tokens on subsequent requests.

## Directory Structure

The auth directory contains controllers, services, middleware, and models.
```
*Problems*: No diagrams, no tables, hard to visualize

**Scoring**:
- 1.0: Excellent use of visual aids
- 0.5: Some visual aids but could use more
- 0.0: No visual aids where they would help

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
```

### Step 2: Evaluate Explanations

For each major concept:
1. Check if it's explained (not just mentioned)
2. Verify context is provided
3. Ensure technical terms are defined
4. Look for "why" (rationale)

```typescript
const concepts = extractConcepts(doc)
// ["JWT Authentication", "Database Schema", "API Design", ...]

concepts.forEach(concept => {
  const explanation = extractExplanation(doc, concept)
  if (!explanation) {
    // Flag: Concept mentioned but not explained
  }
  if (!explanation.includes('why')) {
    // Flag: Missing rationale
  }
})
```

### Step 3: Evaluate Examples

```typescript
const codeBlocks = extractCodeBlocks(doc)
const apiEndpoints = extractAPIEndpoints(doc)

apiEndpoints.forEach(endpoint => {
  const hasExample = codeBlocks.some(block =>
    block.includes(endpoint.path)
  )
  if (!hasExample) {
    // Flag: API endpoint without example
  }
})
```

### Step 4: Evaluate Structure

```typescript
const headers = extractHeaders(doc)

// Check logical flow
const order = analyzeHeaderOrder(headers)
if (!isLogical(order)) {
  // Flag: Illogical organization
}

// Check hierarchy
if (hasSkippedLevels(headers)) {
  // Flag: Header hierarchy issues
}
```

### Step 5: Evaluate Terminology

```typescript
const acronyms = findAcronyms(doc)
const glossary = readFile('docs/glossary.md')

acronyms.forEach(acronym => {
  const defined = isDefinedBeforeUse(doc, acronym)
  const inGlossary = glossary.includes(acronym)

  if (!defined && !inGlossary) {
    // Flag: Undefined acronym
  }
})
```

### Step 6: Evaluate Visual Aids

```typescript
const hasDiagrams = doc.includes('```mermaid') || doc.includes('```')
const hasTables = doc.includes('|')
const hasDirectoryTrees = doc.includes('├──')

// Check if visuals would help
if (isComplexConcept(concept) && !hasDiagrams) {
  // Suggest: Add diagram
}
```

### Step 7: Calculate Score

```typescript
const totalScore =
  explanationQuality +   // 3.0 points
  exampleQuality +       // 2.5 points
  structuralClarity +    // 2.0 points
  terminologyUsage +     // 1.5 points
  visualAids             // 1.0 points
// Total: 10.0 points
```

### Step 8: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase5-documentation-clarity.md`

---

## 📝 Report Template

```markdown
# Phase 5: Documentation Clarity Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: documentation-clarity-evaluator
**Date**: {evaluation-date}
**Model**: sonnet

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Explanation Quality: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Major Concepts Evaluated**: {count}

**Well-Explained**:
- ✅ JWT Authentication - Clear explanation with context and rationale
- ✅ Data Model - Well-described with purpose

**Needs Improvement** (if any):
- ⚠️ {concept} - Missing context
  - Current: "{brief-mention}"
  - Needed: Explanation of what, why, and how

**Missing Explanations** (if any):
- ❌ {concept} - Mentioned but not explained
  - Location: {file}:{section}
  - Recommendation: Add {explanation-needed}

---

### 2. Example Quality: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Code Examples Found**: {count}
**API Endpoint Examples**: {count}

**Good Examples**:
- ✅ Login endpoint - Complete request/response with error cases
- ✅ User model - Clear TypeScript example

**Missing Examples** (if any):
- ❌ {feature} - No code example provided
  - Recommendation: Add example showing {use-case}

**Poor Examples** (if any):
- ⚠️ {feature} - Example too basic
  - Current: {basic-example}
  - Improvement: Show realistic use case

---

### 3. Structural Clarity: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Structure Analysis**:
- Header hierarchy: {✅ Logical | ❌ Issues found}
- Section order: {✅ Flows well | ❌ Confusing}
- Information grouping: {✅ Well organized | ❌ Scattered}

**Well-Structured Sections**:
- ✅ {section} - Clear progression from overview to details

**Structure Issues** (if any):
- ❌ {section} - {issue description}
  - Problem: {what's wrong}
  - Recommendation: {reorganization suggestion}

---

### 4. Terminology Usage: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Acronyms Found**: {count}
**Defined Before Use**: {count}

**Well-Handled Terms**:
- ✅ JWT - Defined on first use with full expansion
- ✅ API - Common term, appropriately used

**Undefined Terms** (if any):
- ❌ {acronym} - Used without definition
  - First use: {file}:{line}
  - Recommendation: Define on first use or link to glossary

**Jargon Issues** (if any):
- ⚠️ {section} - Heavy technical jargon
  - Recommendation: Simplify or add explanations

---

### 5. Visual Aids: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Visual Aids Found**:
- Diagrams: {count}
- Tables: {count}
- Directory trees: {count}
- Flowcharts: {count}

**Effective Visuals**:
- ✅ Authentication flow diagram - Makes process clear
- ✅ Token comparison table - Easy to compare

**Missing Visuals** (if any):
- ❌ {concept} - Would benefit from diagram
  - Recommendation: Add {type-of-visual}

---

## 🎯 Recommendations

{If score < 8.0, provide specific improvements}

### Required Improvements

1. **Explanations**: Add context for {concept}
   - Location: {file}:{section}
   - Add: {what-to-add}

2. **Examples**: Provide code example for {feature}
   - Show: {use-case}
   - Include: {details}

3. **Structure**: Reorganize {section}
   - Move {content} to {better-location}

### Suggested Enhancements

1. {Enhancement 1}
2. {Enhancement 2}

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

{Summary paragraph about documentation clarity}

---

**Evaluator**: documentation-clarity-evaluator
**Model**: sonnet
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Unexplained Acronyms

**Problem**: Technical acronyms used without definition

**Example**:
```markdown
## Authentication

The API uses JWT with RBAC for access control.
```
*Problems*: JWT and RBAC not defined

**Fix**:
```markdown
## Authentication

The API uses **JWT (JSON Web Token)** for stateless authentication
and **RBAC (Role-Based Access Control)** for authorization.

**JWT** is a cryptographically signed token containing user claims...
**RBAC** allows assigning permissions based on user roles...
```

---

### Issue 2: Missing Examples

**Problem**: Important features described without code examples

**Example**:
```markdown
## User Registration Endpoint

POST /api/auth/register

Accepts email and password. Returns user object and tokens.
```

**Fix**: Add complete request/response examples (see Example Quality section above)

---

### Issue 3: Poor Organization

**Problem**: Information scattered, no logical flow

**Example**:
```markdown
# User Authentication

Password must be 8+ characters.

POST /api/auth/login

JWT expires in 15 minutes.

POST /api/auth/register

Uses bcrypt for hashing.
```

**Fix**: Reorganize into logical sections with clear hierarchy

---

### Issue 4: Wall of Text

**Problem**: Long paragraphs without breaks or structure

**Example**:
```markdown
The authentication system uses JWT tokens for stateless authentication where the user first registers by providing their email and password which gets hashed using bcrypt with a cost factor of 10 and stored in the database then when they log in the server verifies the password and generates an access token that expires in 15 minutes and a refresh token that lasts 7 days...
```

**Fix**: Break into sections, use lists, add headers:
```markdown
## Authentication System

### Registration
1. User provides email and password
2. Password hashed with bcrypt (cost factor: 10)
3. User stored in database

### Login
1. User provides credentials
2. Server verifies password
3. Generates two tokens:
   - **Access token**: Expires in 15 minutes
   - **Refresh token**: Lasts 7 days
```

---

## 🎓 Best Practices

### 1. Progressive Disclosure

Start simple, add complexity gradually:

```markdown
## Authentication (Simple)

Users log in with email and password. The server returns a token for API access.

## How It Works (More Detail)

1. User submits credentials
2. Server verifies password against stored hash
3. Server generates JWT containing user ID
4. Client uses JWT for subsequent requests

## Technical Details (Advanced)

### Token Structure
\`\`\`json
{
  "sub": "user-id",
  "exp": 1672531200,
  ...
}
\`\`\`

### Security Considerations
- Tokens signed with HS256
- Bcrypt cost factor: 10
- Refresh token rotation enabled
```

### 2. Show, Don't Just Tell

```markdown
# Bad
The endpoint accepts a JSON payload.

# Good
The endpoint accepts a JSON payload:

\`\`\`json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
\`\`\`
```

### 3. Use Consistent Section Structure

```markdown
For each feature:
1. Overview (what and why)
2. How it works (step-by-step)
3. API/Code reference (technical details)
4. Examples (practical usage)
5. Error handling (common issues)
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
   - **documentation-clarity-evaluator** (easy to understand) ← This one
   - documentation-currency-evaluator (up to date)
3. If this evaluator scores < 8.0:
   - Provide specific clarity improvements in report
   - Re-invoke documentation-worker with feedback
   - Re-run evaluators
4. All evaluators pass → Proceed to Phase 6

---

**This evaluator ensures documentation is accessible and understandable, making it easier for developers to learn and use the system.**
