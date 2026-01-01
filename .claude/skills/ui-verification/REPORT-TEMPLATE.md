# Phase 3: UI/UX Verification Report

**Feature**: `{FEATURE_NAME}`
**Date**: `{DATE}`
**Developer**: `{DEVELOPER_NAME}`
**Status**: ✅ Completed / ⚠️ Issues Found / ❌ Failed

---

## 📋 Summary

- **Total Pages Verified**: `{PAGE_COUNT}`
- **Screenshots Captured**: `{SCREENSHOT_COUNT}`
- **Console Errors Found**: `{ERROR_COUNT}`
- **Login Required**: Yes / No
- **Development Server**: `{SERVER_URL}`

---

## 🔐 Authentication Setup

**Login Required**: Yes / No

<!-- If login required, fill this section -->
**Login Process**:
- Login URL: `{LOGIN_URL}`
- Test User: `{TEST_USER_EMAIL}`
- Login Status: ✅ Success / ❌ Failed

**Screenshot**:
![Login Success](../../.steering/{YYYY-MM-DD}-{FEATURE_NAME}/screenshots/login-success.png)

**Notes**:
- {Any notes about login process}

---

## 📱 Pages Verified

### 1. {PAGE_NAME} ({PAGE_URL})

**Status**: ✅ Pass / ⚠️ Issues / ❌ Fail

#### Initial State
![{PAGE_NAME}](../../.steering/{YYYY-MM-DD}-{FEATURE_NAME}/screenshots/{page-slug}.png)

**Verification Checklist**:
- [ ] Page loads successfully
- [ ] Layout matches design specifications
- [ ] All text is readable and properly formatted
- [ ] Images/icons display correctly
- [ ] Responsive design works (if applicable)
- [ ] Color scheme matches design
- [ ] Spacing and alignment correct

**Findings**:
- ✅ {Positive finding 1}
- ✅ {Positive finding 2}
- ⚠️ {Issue or concern, if any}

#### Interactive Elements Testing

**Test 1: {ACTION_DESCRIPTION}**
- Action: {Describe what was tested, e.g., "Click submit button"}
- Expected: {Expected behavior}
- Actual: {Actual behavior}
- Status: ✅ Pass / ❌ Fail

![{PAGE_NAME} - {ACTION}](../../.steering/{YYYY-MM-DD}-{FEATURE_NAME}/screenshots/{page-slug}-{action}.png)

**Test 2: {ACTION_DESCRIPTION}**
- Action: {Describe what was tested}
- Expected: {Expected behavior}
- Actual: {Actual behavior}
- Status: ✅ Pass / ❌ Fail

![{PAGE_NAME} - {ACTION}](../../.steering/{YYYY-MM-DD}-{FEATURE_NAME}/screenshots/{page-slug}-{action-2}.png)

#### Console Check
- Browser Console Errors: None / {List errors}
- Network Errors: None / {List errors}
- Performance Issues: None / {List issues}

---

### 2. {PAGE_NAME_2} ({PAGE_URL_2})

**Status**: ✅ Pass / ⚠️ Issues / ❌ Fail

#### Initial State
![{PAGE_NAME_2}](../../.steering/{YYYY-MM-DD}-{FEATURE_NAME}/screenshots/{page-slug-2}.png)

**Verification Checklist**:
- [ ] Page loads successfully
- [ ] Layout matches design specifications
- [ ] All text is readable and properly formatted
- [ ] Images/icons display correctly
- [ ] Responsive design works (if applicable)
- [ ] Color scheme matches design
- [ ] Spacing and alignment correct

**Findings**:
- {List findings}

#### Interactive Elements Testing

{Repeat testing section as needed}

#### Console Check
- Browser Console Errors: {List or None}
- Network Errors: {List or None}
- Performance Issues: {List or None}

---

<!-- Add more pages as needed -->

---

## 🐛 Issues Found

### High Priority

1. **{Issue Title}**
   - **Location**: {Page name or component}
   - **Description**: {Detailed description}
   - **Screenshot**: ![Issue](../../.steering/{YYYY-MM-DD}-{FEATURE_NAME}/screenshots/{issue-screenshot}.png)
   - **Recommendation**: {How to fix}

### Medium Priority

1. **{Issue Title}**
   - **Location**: {Page name or component}
   - **Description**: {Detailed description}
   - **Recommendation**: {How to fix}

### Low Priority (Nice to have)

1. **{Issue Title}**
   - **Description**: {Detailed description}
   - **Recommendation**: {How to fix}

---

## ✅ Passed Checks

- ✅ All pages load without errors
- ✅ Navigation works correctly
- ✅ Forms submit successfully
- ✅ Visual design matches specifications
- ✅ Responsive layout works
- ✅ No console errors
- ✅ {Add more passed checks}

---

## 📊 Design Compliance

| Aspect | Specification | Actual | Status |
|--------|---------------|--------|--------|
| Color Scheme | {Expected colors} | {Actual colors} | ✅/❌ |
| Typography | {Expected fonts/sizes} | {Actual fonts/sizes} | ✅/❌ |
| Layout | {Expected layout} | {Actual layout} | ✅/❌ |
| Spacing | {Expected spacing} | {Actual spacing} | ✅/❌ |
| Components | {Expected components} | {Actual components} | ✅/❌ |

---

## 🎯 Recommendations

### Must Fix Before Deployment
1. {Critical issue to fix}
2. {Critical issue to fix}

### Should Fix (High Priority)
1. {Important improvement}
2. {Important improvement}

### Nice to Have
1. {Enhancement suggestion}
2. {Enhancement suggestion}

---

## 📸 Screenshot Index

All screenshots are located in: `.steering/{YYYY-MM-DD}-{FEATURE_NAME}/screenshots/`

1. `login-success.png` - Login page after successful authentication
2. `{page-slug}.png` - {Page name} initial state
3. `{page-slug}-{action}.png` - {Page name} after {action}
4. {List all screenshots}

---

## 🔍 Browser Information

- **Browser**: Chrome / Firefox / Safari / Edge
- **Version**: {Version number}
- **OS**: macOS / Windows / Linux
- **Screen Resolution**: {Resolution}

---

## ✅ Verification Completion

**All Required Steps Completed**:
- [x] Screenshots captured for all modified pages
- [x] Interactive elements tested
- [x] Console errors checked
- [x] Visual design verified
- [x] Report generated

**Next Steps**:
1. Review this report
2. Fix any high-priority issues found
3. Re-run verification if changes are made
4. Proceed to Phase 4 (Deployment Gate) if all checks pass

---

**Report Generated**: `{TIMESTAMP}`
**Generated By**: EDAF v1.0 - Claude Code
**Verification Script**: `.claude/scripts/verify-ui.sh`
