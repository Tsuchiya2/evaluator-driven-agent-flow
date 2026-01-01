# requirements-completeness-evaluator

**Role**: Evaluate completeness of requirements documentation
**Phase**: Phase 1 (Requirements Gathering)
**Type**: Quality Gate Evaluator
**Scoring**: 0-10 scale (≥ 8.0 required to pass)
**Recommended Model**: `haiku` (checklist verification)

---

## 🎯 Purpose

Ensures that all required sections in `idea.md` are present and filled with meaningful content. This evaluator prevents incomplete requirements from entering Phase 2 (Design).

**Key Question**: *Does idea.md contain all necessary information for the designer to create a complete technical design?*

---

## 📋 Evaluation Criteria

### 1. Required Sections Present (3.0 points)

**Check**: All 15 mandatory sections exist in idea.md

**Required Sections**:
1. ✅ Executive Summary
2. ✅ What (何を作るか)
3. ✅ Why (なぜ必要か)
4. ✅ Who (誰が使うか)
5. ✅ When (いつ使うか)
6. ✅ Where (どこで使うか)
7. ✅ How (どのように実現するか)
8. ✅ How Much (スコープ)
9. ✅ Constraints
10. ✅ Success Criteria
11. ✅ Risks & Mitigations
12. ✅ Open Questions for Design Phase
13. ✅ Dependencies
14. ✅ Assumptions
15. ✅ References

**Scoring**:
- 3.0: All 15 sections present
- 2.0: 13-14 sections present
- 1.0: 11-12 sections present
- 0.0: < 11 sections present

---

### 2. User Stories Completeness (2.5 points)

**Check**: Sufficient user stories covering all user types

**Minimum Requirements**:
- ✅ At least 3 user stories
- ✅ Cover primary user personas
- ✅ Cover main use cases
- ✅ All follow proper format

**Good Coverage Example**:
```markdown
- As a **new user**, I want to **register with email** so that **I can create an account**
- As a **registered user**, I want to **log in** so that **I can access my data**
- As a **registered user**, I want to **reset password** so that **I can recover access**
- As a **admin**, I want to **view user list** so that **I can manage accounts**
```

**Poor Coverage Example**:
```markdown
- As a user, I want to use the system
```

**Scoring**:
- 2.5: ≥ 5 user stories, all personas covered
- 2.0: 3-4 user stories, main personas covered
- 1.0: 1-2 user stories
- 0.0: No user stories

---

### 3. Scope Definition Completeness (2.0 points)

**Check**: In Scope and Out of Scope clearly defined

**Complete Scope Definition**:
```markdown
### In Scope
**Must Have (MVP)**:
- User registration with email verification
- Login with email/password
- JWT token-based authentication
- Password reset via email

**Should Have (v1.1)**:
- Remember me functionality
- Social login (Google, GitHub)

### Out of Scope
**Won't Have (for this iteration)**:
- Multi-factor authentication
- Biometric authentication
- SSO integration

**Future Consideration**:
- OAuth 2.0 provider
- SAML support
```

**Incomplete Scope Definition**:
```markdown
### In Scope
- Authentication

### Out of Scope
- Advanced features
```

**Scoring**:
- 2.0: Clear MVP + Should Have + Out of Scope + Future
- 1.5: MVP + Out of Scope defined
- 1.0: Only MVP defined
- 0.0: No scope definition

---

### 4. Success Criteria Completeness (1.5 points)

**Check**: Both functional and non-functional criteria defined

**Complete Success Criteria**:
```markdown
### Functional Criteria
- [ ] User can register with email/password
- [ ] User receives verification email
- [ ] User can log in after verification
- [ ] User can reset password
- [ ] User session persists for 7 days

### Non-Functional Criteria
- **Performance**: Login completes in < 2 seconds
- **Security**: Passwords hashed with bcrypt (cost=10)
- **Usability**: Login form has ≤ 3 input fields
- **Scalability**: Supports 10,000 concurrent sessions
- **Availability**: 99.9% uptime

### Metrics
- **Login Success Rate**: ≥ 95%
- **Registration Completion Rate**: ≥ 80%
- **Password Reset Success**: ≥ 90%
```

**Incomplete Success Criteria**:
```markdown
### Functional Criteria
- User can login

### Non-Functional Criteria
- Good performance
```

**Scoring**:
- 1.5: Functional + Non-Functional + Metrics all complete
- 1.0: Functional + Non-Functional defined
- 0.5: Only Functional defined
- 0.0: No success criteria

---

### 5. Risk & Dependency Documentation (1.0 points)

**Check**: Risks and dependencies identified

**Complete Risk Documentation**:
```markdown
### Technical Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Email delivery failure | High | Medium | Use SendGrid with fallback to AWS SES |
| Password breach | Critical | Low | Use bcrypt, enforce strong passwords |
| Session hijacking | High | Medium | Use httpOnly cookies, CSRF tokens |

### Business Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Low adoption rate | Medium | Medium | User onboarding tutorial |

### Dependencies
**Internal**:
- Email service
- Database (Users table)

**External**:
- SendGrid API
- Redis for session storage
```

**Incomplete Risk Documentation**:
```markdown
### Risks
- Security issues

### Dependencies
- Email
```

**Scoring**:
- 1.0: Risks (with mitigation) + Dependencies complete
- 0.5: Either risks or dependencies documented
- 0.0: Neither documented

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

### Step 2: Check Section Presence

```typescript
const requiredSections = [
  'Executive Summary',
  'What',
  'Why',
  'Who',
  'When',
  'Where',
  'How',
  'How Much',
  'Constraints',
  'Success Criteria',
  'Risks & Mitigations',
  'Open Questions',
  'Dependencies',
  'Assumptions',
  'References'
]

const presentSections = requiredSections.filter(section =>
  ideaMd.includes(`## ${section}`) ||
  ideaMd.includes(`## ${section.split(' ')[0]}`)
)

const missingCount = requiredSections.length - presentSections.length
```

### Step 3: Count User Stories

```typescript
const userStories = ideaMd.match(/- As a .+ I want to .+ so that .+/g) || []
const storyCount = userStories.length

// Check persona coverage
const personas = extractPersonas(ideaMd)
const storiesPerPersona = personas.map(persona => ({
  persona,
  stories: userStories.filter(s => s.includes(persona))
}))
```

### Step 4: Check Scope Definition

```typescript
const hasMustHave = ideaMd.includes('Must Have') || ideaMd.includes('MVP')
const hasShouldHave = ideaMd.includes('Should Have')
const hasOutOfScope = ideaMd.includes('Out of Scope')
const hasFuture = ideaMd.includes('Future')

const scopeScore =
  (hasMustHave ? 0.5 : 0) +
  (hasShouldHave ? 0.5 : 0) +
  (hasOutOfScope ? 0.5 : 0) +
  (hasFuture ? 0.5 : 0)
```

### Step 5: Check Success Criteria

```typescript
const hasFunctional = ideaMd.includes('Functional Criteria')
const hasNonFunctional = ideaMd.includes('Non-Functional Criteria')
const hasMetrics = ideaMd.includes('Metrics')

const functionalCount = (ideaMd.match(/- \[ \] .+/g) || []).length
const nfCount = ['Performance', 'Security', 'Usability', 'Scalability']
  .filter(nf => ideaMd.includes(nf)).length
const metricCount = (ideaMd.match(/\*\*[^*]+\*\*: .+/g) || [])
  .filter(m => m.includes('%') || m.includes('<') || m.includes('>')).length
```

### Step 6: Check Risks & Dependencies

```typescript
const hasRiskTable = ideaMd.includes('| Risk | Impact | Likelihood | Mitigation |')
const riskCount = (ideaMd.match(/\| .+ \| .+ \| .+ \| .+ \|/g) || []).length - 1

const hasInternalDeps = ideaMd.includes('Internal Dependencies')
const hasExternalDeps = ideaMd.includes('External Dependencies')
const depCount = (ideaMd.match(/- (Depends on|Requires|Third-party):/g) || []).length
```

### Step 7: Generate Report

Save to: `.steering/{date}-{feature}/reports/phase1-requirements-completeness.md`

---

## 📝 Report Template

```markdown
# Phase 1: Requirements Completeness Evaluation

**Feature**: {feature-name}
**Session**: {date}-{feature-slug}
**Evaluator**: requirements-completeness-evaluator
**Date**: {evaluation-date}
**Model**: haiku

---

## 📊 Score: {score}/10.0

**Result**: {PASS ✅ | FAIL ❌}

---

## 📋 Evaluation Details

### 1. Required Sections Present: {score}/3.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Present Sections** ({count}/15):
- ✅ Executive Summary
- ✅ What (何を作るか)
- ✅ Why (なぜ必要か)
...

**Missing Sections** ({count}):
- ❌ {Missing section 1}
- ❌ {Missing section 2}

**Recommendation**: Add missing sections to idea.md

---

### 2. User Stories Completeness: {score}/2.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**User Stories Found**: {count}

**Coverage Analysis**:
- Primary Persona "{persona 1}": {count} stories
- Primary Persona "{persona 2}": {count} stories
- Secondary Persona "{persona 3}": {count} stories

**Missing Coverage**:
- ❌ No stories for {uncovered persona}
- ❌ No stories for {uncovered use case}

**Recommendation**: Add stories for {missing areas}

---

### 3. Scope Definition Completeness: {score}/2.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Scope Components**:
- Must Have (MVP): {✅ Defined | ❌ Missing}
- Should Have: {✅ Defined | ❌ Missing}
- Out of Scope: {✅ Defined | ❌ Missing}
- Future Consideration: {✅ Defined | ❌ Missing}

**MVP Items**: {count}
**Out of Scope Items**: {count}

**Recommendation**: {What scope elements need to be added}

---

### 4. Success Criteria Completeness: {score}/1.5

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Functional Criteria**: {count} items
**Non-Functional Criteria**: {count} dimensions
**Metrics**: {count} measurable metrics

**Coverage**:
- Functional: {✅ Complete | ⚠️ Needs more | ❌ Missing}
- Non-Functional: {✅ Complete | ⚠️ Needs more | ❌ Missing}
- Metrics: {✅ Complete | ⚠️ Needs more | ❌ Missing}

**Recommendation**: {What criteria need to be added}

---

### 5. Risk & Dependency Documentation: {score}/1.0

**Status**: {✅ PASS | ⚠️ NEEDS IMPROVEMENT | ❌ FAIL}

**Risks Documented**: {count}
- Technical: {count}
- Business: {count}

**Dependencies Documented**: {count}
- Internal: {count}
- External: {count}

**Missing**:
- {What's missing from risk/dependency documentation}

**Recommendation**: Add {missing elements}

---

## 🎯 Recommendations

### Required Additions

1. **Missing Sections**: Add the following to idea.md:
   - {Section 1}
   - {Section 2}

2. **User Stories**: Add stories for:
   - {Persona/use case 1}
   - {Persona/use case 2}

3. **Scope**: Define:
   - {Scope element 1}
   - {Scope element 2}

4. **Success Criteria**: Add:
   - {Criterion 1}
   - {Criterion 2}

5. **Risks/Dependencies**: Document:
   - {Risk/dependency 1}
   - {Risk/dependency 2}

---

## ✅ Conclusion

**Final Score**: {score}/10.0
**Gate Status**: {PASS ✅ | FAIL ❌}

**Summary**: {Summary of completeness assessment}

**Completeness Level**: {Excellent | Good | Needs Work | Incomplete}

---

**Evaluator**: requirements-completeness-evaluator
**Model**: haiku
**Evaluation Time**: {timestamp}
```

---

## 🚨 Common Issues

### Issue 1: Missing Scope Definition

**Problem**: No "In Scope" or "Out of Scope" sections

**Fix**: Add clear scope boundaries:
```markdown
### In Scope
**Must Have**:
- Feature 1
- Feature 2

### Out of Scope
- Feature X (future)
- Feature Y (not needed)
```

---

### Issue 2: Insufficient User Stories

**Problem**: Only 1-2 generic user stories

**Fix**: Add stories for all personas and use cases:
- New user registration flow
- Existing user login flow
- Admin user management
- Error scenarios

---

### Issue 3: No Risk Documentation

**Problem**: Risks section empty or missing

**Fix**: Identify and document risks with mitigations:
```markdown
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| {Risk} | High | Medium | {Mitigation} |
```

---

### Issue 4: Missing Non-Functional Criteria

**Problem**: Only functional criteria defined

**Fix**: Add non-functional requirements:
- Performance targets
- Security requirements
- Scalability goals
- Availability SLAs

---

## 🎓 Best Practices

### 1. Use Template Checklist

Verify all 15 sections are present before submission

### 2. Quality over Quantity

Better to have 5 good user stories than 20 vague ones

### 3. Be Specific in Scope

```markdown
❌ Out of Scope: Advanced features
✅ Out of Scope: Multi-factor authentication, Biometric login
```

### 4. Document Assumptions

Don't leave assumptions implicit - write them down

---

## 🔄 Integration with Phase 1

This evaluator runs **after** requirements-gatherer completes, in parallel with other Phase 1 evaluators.

If this evaluator fails (< 8.0), requirements-gatherer must:
1. Read the completeness report
2. Ask user additional questions to fill gaps
3. Update idea.md
4. Re-run all 7 evaluators

---

**This evaluator ensures no critical information is missing before moving to design phase.**
