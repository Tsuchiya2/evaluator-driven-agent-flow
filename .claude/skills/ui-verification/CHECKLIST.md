# UI Verification Checklist

**Purpose**: Dynamic checklist template for UI verification tasks

---

## Pre-Verification Checklist

Before starting UI verification:

- [ ] Development server is running
- [ ] Chrome is installed with Claude in Chrome extension
- [ ] Claude in Chrome extension is enabled and active
- [ ] Screenshot directory created: `.steering/{YYYY-MM-DD}-{feature-name}/screenshots/`
- [ ] Login credentials available (if required)
- [ ] Subagent launched with Claude in Chrome access

---

## Authentication Checklist

If pages require login:

- [ ] Navigate to login page
- [ ] Screenshot: `00-login-page.png`
- [ ] Fill email/username field
- [ ] Fill password field
- [ ] Screenshot: `01-login-page-filled.png`
- [ ] Click submit button
- [ ] Wait for redirect (3 seconds)
- [ ] Screenshot: `02-login-success.png`
- [ ] Verify successful authentication

---

## Page Verification Checklist

For EACH modified page, complete these checks:

### Visual Verification

- [ ] Navigate to page URL
- [ ] Screenshot: `{sequence}-{page-name}.png`
- [ ] **Layout**: Matches design specifications
- [ ] **Typography**: Fonts correct, text readable
- [ ] **Colors**: Color scheme matches design
- [ ] **Spacing**: Margins and padding correct
- [ ] **Alignment**: Elements properly aligned
- [ ] **Images**: All images load correctly
- [ ] **Icons**: Icons display properly
- [ ] **Responsive**: Layout works at different sizes (if applicable)

### Interactive Element Testing

- [ ] **Forms**: All inputs accept data
- [ ] **Buttons**: All buttons are clickable
- [ ] **Links**: Navigation links work
- [ ] **Dropdowns**: Menus open and close properly
- [ ] **Modals**: Dialogs open and close properly
- [ ] **Tooltips**: Hover states work (if applicable)

### State Verification

- [ ] **Loading**: Loading states display correctly
- [ ] **Empty**: Empty states display correctly
- [ ] **Error**: Error states display correctly
- [ ] **Success**: Success states display correctly

### Console Check

- [ ] No JavaScript errors in console
- [ ] No network errors (failed API calls)
- [ ] No performance warnings

---

## Post-Action Screenshots

After each significant action:

- [ ] Form submission: `{page}-submitted.png`
- [ ] Button click: `{page}-{action}.png`
- [ ] Navigation: `{destination-page}.png`
- [ ] Modal open: `{page}-modal-open.png`
- [ ] Success message: `{page}-success.png`
- [ ] Error message: `{page}-error.png`

---

## Report Generation Checklist

After all pages verified:

- [ ] All screenshots saved to `.steering/{YYYY-MM-DD}-{feature-name}/screenshots/`
- [ ] Create report: `.steering/{YYYY-MM-DD}-{feature-name}/reports/phase4-ui-verification.md`
- [ ] Report includes Summary section
- [ ] Report includes all screenshots with relative paths
- [ ] Report includes Findings section
- [ ] Report includes Console Errors section (if any)
- [ ] Report includes Screenshot Index

---

## Final Verification

Run the verification script:

```bash
bash .claude/scripts/verify-ui.sh {feature-name}
```

- [ ] Script output shows `✅ PASSED`
- [ ] All checklist items completed
- [ ] No blocking issues found

---

## Checklist Generation Template

Use this template to generate dynamic checklists based on modified files:

```typescript
interface VerificationChecklist {
  feature: string
  pages: {
    name: string
    url: string
    requiresAuth: boolean
    interactiveElements: string[]
  }[]
  totalScreenshots: number
}

const generateChecklist = (pages: string[]): VerificationChecklist => {
  return {
    feature: '{feature-name}',
    pages: pages.map((page, index) => ({
      name: page,
      url: `http://localhost:3000/${page}`,
      requiresAuth: false,
      interactiveElements: []
    })),
    totalScreenshots: pages.length * 2 // initial + action
  }
}
```

---

## Quick Reference

| Step | Action | Screenshot |
|------|--------|------------|
| 1 | Navigate to page | `{page}.png` |
| 2 | Verify visual design | - |
| 3 | Test form inputs | `{page}-filled.png` |
| 4 | Click submit | `{page}-submitted.png` |
| 5 | Check result | `{page}-success.png` or `{page}-error.png` |
| 6 | Check console | - |
| 7 | Move to next page | Repeat |

---

## Example: Complete Feature Checklist

### Feature: User Registration

**Pre-Verification:**
- [x] Dev server running on localhost:3000
- [x] Chrome in debug mode
- [x] MCP available
- [x] Directory: `.steering/{YYYY-MM-DD}-user-registration/screenshots/`

**Page 1: Registration Form**
- [x] Navigate to `/register`
- [x] Screenshot: `00-register-page.png`
- [x] Fill name, email, password fields
- [x] Screenshot: `01-register-page-filled.png`
- [x] Click submit
- [x] Screenshot: `02-register-success.png`
- [x] Console: No errors

**Page 2: Email Verification**
- [x] Navigate to `/verify-email`
- [x] Screenshot: `03-verify-email.png`
- [x] Enter verification code
- [x] Screenshot: `04-verify-email-filled.png`
- [x] Click verify
- [x] Screenshot: `05-verify-success.png`
- [x] Console: No errors

**Report:**
- [x] Created: `.steering/{YYYY-MM-DD}-user-registration/reports/phase4-ui-verification.md`
- [x] All 6 screenshots included
- [x] Findings documented

**Verification Script:**
- [x] `bash .claude/scripts/verify-ui.sh user-registration`
- [x] Output: `✅ PASSED`
