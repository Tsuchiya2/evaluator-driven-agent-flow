# UI/UX Verification Guide

**EDAF Phase 3: Frontend Verification with MCP chrome-devtools**

---

## 📋 Overview

When frontend files are modified during Phase 3 (Code Review Gate), EDAF automatically triggers UI/UX verification using MCP chrome-devtools integration.

**Key Features:**
- ✅ Automatic detection of frontend changes
- ✅ Interactive browser automation
- ✅ Screenshot capture (mandatory)
- ✅ Visual consistency checks
- ✅ Console error monitoring
- ✅ Report generation

---

## ⚠️ Environment Support

| Environment | Status | Notes |
|-------------|--------|-------|
| **macOS** | ✅ Supported | Full functionality |
| **Windows (Native)** | ✅ Supported | Use cmd wrapper |
| **Linux** | ✅ Supported | Full functionality |
| **WSL2** | ❌ Not Supported | Cannot access Windows Chrome |
| **Docker** | ⚠️ Limited | Requires special config |

### WSL2 Limitation

**MCP chrome-devtools does NOT work in WSL2 environment.**

Reasons:
- WSL2 runs in a virtualized network namespace
- Cannot communicate with Chrome running on Windows host
- `--remote-debugging-port` is not accessible from WSL2

**Workarounds for WSL2 users:**
1. UI verification is automatically SKIPPED in Phase 3
2. Manual verification recommended (open browser and check UI)
3. Run Claude Code on Windows directly (not in WSL2)

---

## 🔧 Prerequisites

### 1. MCP Configuration (Automatic)

The install script automatically configures `.mcp.json` with the correct npx path for your environment:

```bash
# Check your configuration
cat .mcp.json
```

**If not configured, run:**
```bash
bash .claude/scripts/setup-mcp.sh
```

### 2. Chrome Browser
- Chrome must be running (MCP will start it automatically)
- Or start manually: `google-chrome --remote-debugging-port=9222`

### 3. Node.js Environment

The setup script auto-detects your Node.js installation:

| Manager | Path Example |
|---------|--------------|
| **Homebrew** | `/opt/homebrew/bin/npx` |
| **nvm** | `~/.nvm/versions/node/v22.x.x/bin/npx` |
| **nodenv** | `~/.nodenv/shims/npx` |
| **asdf** | `~/.asdf/shims/npx` |
| **volta** | `~/.volta/bin/npx` |
| **mise** | `~/.local/share/mise/shims/npx` |
| **Bun** | `~/.bun/bin/bunx` (faster alternative) |

### 4. Development Server
- Your application's dev server must be running
- Example: `npm run dev`, `rails server`, `python manage.py runserver`

---

## 🚀 How It Works

### Step 1: Automatic Detection

EDAF detects frontend changes by monitoring these file patterns:
- Components: `**/components/**/*`, `**/pages/**/*`, `**/views/**/*`
- Styles: `**/*.css`, `**/*.scss`, `**/*.sass`, `**/*.less`
- Scripts: `**/src/**/*.{tsx,jsx,ts,js,vue,svelte}`

### Step 2: Login Information Prompt

**ALWAYS** prompts the user:
```
Question: "Do the modified pages require login to view?"
Options:
  - Yes (collects credentials)
  - No (proceeds without authentication)
```

**If YES, collects:**
- Login URL (e.g., `http://localhost:3000/login`)
- Email/Username
- Password
- Development server confirmation

### Step 3: Screenshot Directory Creation

Creates directory structure:
```
docs/screenshots/{feature-name}/
```

Example:
```
docs/screenshots/user-authentication/
├── login-page.png
├── login-page-submitted.png
├── dashboard.png
└── dashboard-profile-open.png
```

### Step 4: Page-by-Page Verification

For EACH modified page:

1. **Navigate to page**
   - Tool: `mcp__chrome-devtools__navigate_page`

2. **Capture initial screenshot** (MANDATORY)
   - Tool: `mcp__chrome-devtools__take_snapshot`
   - Save to: `docs/screenshots/{feature-name}/{page-slug}.png`

3. **Verify visual design**
   - Layout matches specifications
   - Colors, fonts, spacing correct
   - Images/icons display properly
   - Responsive design works

4. **Test interactive elements**
   - Fill forms: `mcp__chrome-devtools__fill`
   - Click buttons: `mcp__chrome-devtools__click`
   - Test navigation

5. **Capture interaction screenshots** (MANDATORY)
   - Save to: `docs/screenshots/{feature-name}/{page-slug}-{action}.png`

6. **Check browser console**
   - JavaScript errors
   - Network errors
   - Performance warnings

### Step 5: Report Generation

Creates comprehensive report:
```
docs/reports/phase3-ui-verification-{feature-name}.md
```

**Report includes:**
- Summary (pages verified, screenshots captured, errors found)
- Authentication setup (if required)
- Page-by-page verification results
- Issues found (prioritized)
- Design compliance table
- Screenshot index
- Recommendations

### Step 6: Verification Script

Runs automated validation:
```bash
bash .claude/scripts/verify-ui.sh {feature-name}
```

**Checks:**
- ✅ Screenshot directory exists
- ✅ At least 1 screenshot per page
- ✅ Verification report exists
- ✅ Report contains meaningful content (10+ lines)

---

## 🛠️ Available MCP Tools

### Navigation
```javascript
mcp__chrome-devtools__list_pages
// Lists all available browser tabs

mcp__chrome-devtools__navigate_page
// Navigates to specified URL
```

### Screenshot Capture (MANDATORY)
```javascript
mcp__chrome-devtools__take_snapshot
// Captures screenshot of current page
// MUST be called for every modified page
```

### Interactive Testing
```javascript
mcp__chrome-devtools__fill
// Fills form inputs with test data

mcp__chrome-devtools__click
// Clicks buttons, links, and interactive elements
```

---

## 📝 Example Workflow

### Scenario: Login Feature Implementation

**Modified files:**
- `components/LoginForm.tsx`
- `components/Dashboard.tsx`
- `styles/auth.css`

**Verification process:**

1. **Prompt user:**
   ```
   Q: Do the modified pages require login?
   A: Yes

   Q: Login URL?
   A: http://localhost:3000/login

   Q: Test credentials?
   A: test@example.com / password123
   ```

2. **Create directory:**
   ```bash
   mkdir -p docs/screenshots/login-feature/
   ```

3. **Verify login page:**
   ```
   Navigate: http://localhost:3000/login
   Screenshot: login-page.png
   Fill: email (test@example.com)
   Fill: password (password123)
   Screenshot: login-page-filled.png
   Click: Login button
   Screenshot: login-success.png
   Console: Check for errors
   ```

4. **Verify dashboard:**
   ```
   Navigate: http://localhost:3000/dashboard
   Screenshot: dashboard.png
   Click: Profile button
   Screenshot: dashboard-profile.png
   Console: Check for errors
   ```

5. **Generate report:**
   ```
   File: docs/reports/phase3-ui-verification-login-feature.md

   Contents:
   - Summary: 2 pages, 5 screenshots, 0 errors
   - Authentication: Successful
   - Login page: ✅ PASS
   - Dashboard: ✅ PASS
   ```

6. **Run verification:**
   ```bash
   bash .claude/scripts/verify-ui.sh login-feature
   # Output: ✅ UI Verification PASSED
   ```

---

## ✅ Success Criteria

### Must Have:
- ✅ All modified pages verified
- ✅ Minimum 1 screenshot per page
- ✅ Interactive elements tested
- ✅ Console errors checked
- ✅ Report generated
- ✅ Verification script passes

### Best Practices:
- ✅ Screenshot before AND after interactions
- ✅ Test with realistic data
- ✅ Verify responsive design (if applicable)
- ✅ Check loading states
- ✅ Test error states

---

## 🚫 Common Issues

### Issue 1: Chrome not in debug mode
**Error:** Cannot connect to Chrome

**Solution:**
```bash
# Start Chrome in debug mode
google-chrome --remote-debugging-port=9222
```

### Issue 2: Dev server not running
**Error:** Navigation fails

**Solution:**
```bash
# Start your dev server first
npm run dev
# or
rails server
```

### Issue 3: Screenshots not saving
**Error:** Permission denied

**Solution:**
```bash
# Ensure directories exist
mkdir -p docs/screenshots
mkdir -p docs/reports
```

### Issue 4: Login fails
**Error:** Authentication error

**Solution:**
- Verify credentials are correct
- Check if dev server has test user
- Ensure login URL is correct

---

## 📚 Additional Resources

- **MCP chrome-devtools documentation:** [Claude Code MCP Docs](https://docs.claude.com)
- **Report template:** `.claude/templates/ui-verification-report-template.md`
- **Verification script:** `.claude/scripts/verify-ui.sh`
- **Phase 3 configuration:** `.claude/CLAUDE.md` (UI/UX Verification section)

---

## 🎯 Quick Reference

**When frontend changes detected:**
```
1. Ask: Login required?
2. Create: docs/screenshots/{feature}/
3. For each page:
   - Navigate
   - Screenshot
   - Test interactions
   - Screenshot again
   - Check console
4. Generate: docs/reports/phase3-ui-verification-{feature}.md
5. Run: bash .claude/scripts/verify-ui.sh {feature}
6. Result: ✅ PASS → Proceed to Phase 4
```

---

**Last Updated:** 2025-11-10
**EDAF Version:** 1.0
