# UI/UX Verification Guide

**EDAF Phase 4: Frontend Verification with Claude in Chrome**

---

## 📋 Overview

When frontend files are modified during Phase 3 (Implementation), EDAF automatically triggers UI/UX verification in Phase 4 using the official **Claude in Chrome** extension.

**Key Features:**
- **Zero setup required** - Uses official Claude in Chrome browser extension
- **Cross-platform** - Works on macOS, Windows, Linux, and WSL2
- **Automated screenshots** - Captures visual state of all modified pages
- **Interactive testing** - Tests forms, buttons, navigation
- **Detailed reports** - Generates comprehensive verification reports

---

## 🌐 Claude in Chrome Extension

### Installation

1. **Install the extension:**
   - Visit [Chrome Web Store](https://chromewebstore.google.com/detail/claude-in-chrome/ijfomgcjkobjbebagjkpfipodkljkcdl)
   - Click "Add to Chrome"
   - Grant necessary permissions

2. **Verify installation:**
   - Look for Claude icon in Chrome toolbar
   - Extension should be active and ready

**That's it!** No MCP server setup, no configuration files needed.

### How It Works

The `ui-verification-worker` uses a **subagent pattern**:

1. Main Claude Code launches a general-purpose subagent
2. Subagent has access to Claude in Chrome extension
3. Subagent navigates pages, captures screenshots, tests interactions
4. Results are collected and formatted into a report

---

## 🚀 Usage in EDAF Workflow

### Automatic Trigger

UI verification runs automatically in **Phase 4** when:
- Frontend files were modified in Phase 3
- `global.frontendModified = true` flag is set

### Manual Trigger

You can manually run UI verification:

```bash
# Inside Claude Code
"Run UI verification for the login feature"
```

---

## 📸 What Gets Verified

### 1. Visual Appearance
- Layout matches design specifications
- Colors, fonts, spacing are correct
- Responsive design works properly
- No visual glitches or overlaps

### 2. Interactive Elements
- Forms accept input correctly
- Buttons trigger expected actions
- Navigation links work
- Dropdowns, modals, tooltips function properly

### 3. Browser Console
- No JavaScript errors
- No console warnings
- No network failures

### 4. Accessibility
- Proper heading hierarchy
- Alt text for images
- Keyboard navigation works
- Color contrast is sufficient

---

## 📁 Output Structure

```
.steering/{YYYY-MM-DD}-{feature-slug}/
├── screenshots/
│   ├── login-page.png
│   ├── login-page-filled.png
│   ├── login-page-submitted.png
│   ├── dashboard.png
│   └── profile-page.png
└── reports/
    └── phase4-ui-verification.md
```

### Screenshot Naming Convention

- `{page-name}.png` - Initial page state
- `{page-name}-{action}.png` - After interaction
- Examples:
  - `login-page.png`
  - `login-page-filled.png`
  - `login-page-submitted.png`
  - `signup-form.png`
  - `signup-form-validation-error.png`

---

## 🔄 Verification Workflow

### Step 1: Prerequisites Check

The ui-verification-worker will ask:
- Is the development server running?
- What is the base URL? (e.g., http://localhost:3000)
- Do pages require login?
- If yes, provide login credentials

### Step 2: Navigation & Screenshots

For each modified page:
1. Navigate to the page URL
2. Wait for page to fully load
3. Capture full-page screenshot
4. Save to `.steering/{date}-{feature}/screenshots/`

### Step 3: Interactive Testing

For each interactive element:
1. Fill forms with sample data
2. Click buttons and links
3. Test dropdowns and modals
4. Capture screenshots after each action

### Step 4: Console Check

- Check for JavaScript errors
- Check for console warnings
- Check for failed network requests
- Report any issues found

### Step 5: Report Generation

Generate detailed report including:
- List of all verified pages
- Screenshots with descriptions
- Issues found (if any)
- Comparison with design specs
- Console errors/warnings
- Accessibility notes

---

## 📊 Verification Report Format

```markdown
# UI/UX Verification Report - {Feature Name}

**Feature ID**: {feature-id}
**Verification Date**: {YYYY-MM-DD}
**Verifier**: ui-verification-worker

---

## Pages Verified

### 1. Login Page

**URL**: http://localhost:3000/login
**Screenshot**: ![Login Page](../screenshots/login-page.png)

**Visual Check**:
- ✅ Layout matches design
- ✅ Form centered correctly
- ✅ Colors match brand guidelines
- ⚠️  Submit button slightly misaligned (2px off)

**Interactive Check**:
- ✅ Email field accepts input
- ✅ Password field masked correctly
- ✅ Submit button triggers login
- ![Form Filled](../screenshots/login-page-filled.png)
- ![After Submit](../screenshots/login-page-submitted.png)

**Console Check**:
- ✅ No JavaScript errors
- ✅ No console warnings
- ✅ All API calls successful

**Issues**:
1. Submit button alignment off by 2px (Minor)

---

### 2. Dashboard Page

**URL**: http://localhost:3000/dashboard
**Screenshot**: ![Dashboard](../screenshots/dashboard.png)

**Visual Check**:
- ✅ All widgets render correctly
- ✅ Charts display properly
- ✅ Responsive on mobile

**Interactive Check**:
- ✅ Navigation menu works
- ✅ User dropdown functions
- ✅ Logout button works

**Console Check**:
- ✅ No errors

**Issues**: None

---

## Summary

**Total Pages Verified**: 2
**Screenshots Captured**: 5
**Issues Found**: 1 minor issue

**Overall Status**: ✅ PASS (minor fixes recommended)
```

---

## 🛠️ Troubleshooting

### Claude in Chrome extension not detected

**Solution**:
1. Verify extension is installed in Chrome
2. Restart Chrome browser
3. Ensure extension is enabled (not disabled)

### Cannot navigate to page

**Solution**:
1. Verify development server is running
2. Check the URL is correct
3. Check for CORS or authentication issues

### Screenshots not saving

**Solution**:
1. Verify `.steering/{date}-{feature}/screenshots/` directory exists
2. Check file permissions
3. Ensure enough disk space

### Console errors during verification

**Solution**:
- These are expected - they're part of what we're testing!
- ui-verification-worker will report them in the verification report

---

## 📚 Best Practices

### 1. Always verify development server is running

Before starting verification:
```bash
# Check if server is running
curl http://localhost:3000

# Or start your dev server
npm run dev
```

### 2. Use realistic test data

When testing forms:
- Use valid email formats
- Use realistic names and values
- Test edge cases (long text, special characters)

### 3. Verify on clean browser state

- Clear browser cache if needed
- Use incognito mode for authentication tests
- Ensure no browser extensions interfere

### 4. Document findings clearly

In verification reports:
- Include screenshots for every issue
- Describe expected vs actual behavior
- Provide steps to reproduce
- Suggest fixes if obvious

---

## 🎯 Success Criteria

UI verification passes when:
- ✅ All pages load without errors
- ✅ Visual appearance matches design specs
- ✅ All interactive elements function correctly
- ✅ No console errors (or only expected warnings)
- ✅ Accessibility requirements met
- ✅ All screenshots captured and saved

---

## 📧 Support

For issues or questions:
- Check `.claude/skills/ui-verification/` for detailed patterns
- Review `ui-verification-worker.md` agent documentation
- See `BROWSER-AUTOMATION.md` for technical details
- Check `SCREENSHOT-GUIDE.md` for screenshot best practices

---

**Last Updated**: 2026-01-01
**EDAF Version**: 1.0
**UI Verification**: Claude in Chrome (Official Extension)
