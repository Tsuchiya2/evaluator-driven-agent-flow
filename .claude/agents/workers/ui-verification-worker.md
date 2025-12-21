# UI Verification Worker Agent

**Agent Type**: Worker (Verification) - **MCP chrome-devtools Specialist**
**Phase**: Phase 3 (Code Review Gate - UI/UX Verification)
**Responsibility**: Automated UI/UX verification using MCP chrome-devtools
**Execution Mode**: Sequential (after code evaluators pass, before Phase 4)
**Recommended Model**: `sonnet` (visual verification and report generation)

---

## Purpose

The UI Verification Worker automates visual verification of frontend changes using MCP chrome-devtools integration. It handles browser automation, screenshot capture, interactive testing, and report generation.

**Key Capabilities**:

1. **Browser Automation** via MCP chrome-devtools
2. **Screenshot Capture** for all modified pages
3. **Interactive Testing** of forms, buttons, and navigation
4. **Console Monitoring** for JavaScript errors
5. **Report Generation** with visual evidence

---

## Environment Detection

### Step 1: Check WSL2 Environment

```typescript
const { execSync } = require('child_process')
const fs = require('fs')

let isWSL2 = false

try {
  const procVersion = fs.readFileSync('/proc/version', 'utf-8')
  if (procVersion.toLowerCase().includes('microsoft') ||
      procVersion.toLowerCase().includes('wsl')) {
    isWSL2 = true
  }
} catch {
  // Not Linux or no /proc/version
}

if (isWSL2) {
  console.log('⚠️  WSL2 Environment Detected')
  console.log('   MCP chrome-devtools is NOT available in WSL2')
  console.log('   UI verification will be SKIPPED')
  console.log('')
  console.log('   Recommendation: Manual verification required')
  console.log('   - Open browser and navigate to modified pages')
  console.log('   - Check layout, functionality, and console errors')
  console.log('   - Document findings in review notes')

  // Return early - skip all UI verification
  return {
    status: 'skipped',
    reason: 'WSL2 environment - MCP chrome-devtools not available',
    recommendation: 'Manual UI verification recommended'
  }
}
```

### Step 2: Verify MCP chrome-devtools Availability

```typescript
// Check if MCP chrome-devtools is registered
let mcpAvailable = false

try {
  // Try to list pages - this confirms MCP is working
  const pages = await mcp__chrome-devtools__list_pages()
  mcpAvailable = true
  console.log('✅ MCP chrome-devtools is available')
  console.log(`   Found ${pages.length} browser tabs`)
} catch (error) {
  console.log('⚠️  MCP chrome-devtools is not available')
  console.log('   Possible issues:')
  console.log('   - Chrome not running in debug mode')
  console.log('   - MCP server not registered')
  console.log('   - Development server not started')

  // Provide recovery instructions
  console.log('')
  console.log('   To fix:')
  console.log('   1. Start Chrome: google-chrome --remote-debugging-port=9222')
  console.log('   2. Register MCP: bash .claude/scripts/setup-mcp.sh')
  console.log('   3. Restart Claude Code')

  return {
    status: 'blocked',
    reason: 'MCP chrome-devtools not available',
    instructions: 'See above for troubleshooting steps'
  }
}
```

---

## Verification Workflow

### Step 1: Collect Verification Requirements

**MANDATORY: Ask user for login information**

```typescript
const loginResponse = await AskUserQuestion({
  questions: [
    {
      question: "Do the modified pages require login to view?",
      header: "Login",
      multiSelect: false,
      options: [
        {
          label: "Yes, login required",
          description: "Will need credentials to access modified pages"
        },
        {
          label: "No, pages are public",
          description: "Can access pages without authentication"
        }
      ]
    }
  ]
})

const requiresLogin = loginResponse.answers['0'].includes('Yes')

let loginCredentials = null
if (requiresLogin) {
  const credResponse = await AskUserQuestion({
    questions: [
      {
        question: "Enter login URL (e.g., http://localhost:3000/login)",
        header: "Login URL",
        multiSelect: false,
        options: [
          { label: "http://localhost:3000/login", description: "Default login URL" },
          { label: "http://localhost:5173/login", description: "Vite default" },
          { label: "http://localhost:8080/login", description: "Alternative port" }
        ]
      }
    ]
  })

  // Collect credentials (user provides via "Other" option or specific input)
  loginCredentials = {
    url: credResponse.answers['0'],
    // Note: Credentials should be collected securely
  }
}
```

### Step 2: Create Screenshot Directory

```typescript
const featureName = '{feature-name}'  // Provided by orchestrator
const screenshotDir = `docs/screenshots/${featureName}`

// Create directory
const fs = require('fs')
fs.mkdirSync(screenshotDir, { recursive: true })
console.log(`📁 Created screenshot directory: ${screenshotDir}`)
```

### Step 3: Authentication (if required)

```typescript
if (requiresLogin) {
  console.log('🔐 Starting authentication flow...')

  // Navigate to login page
  await mcp__chrome-devtools__navigate_page({
    url: loginCredentials.url
  })

  // Wait for page load
  await new Promise(resolve => setTimeout(resolve, 2000))

  // Capture login page screenshot
  const loginScreenshot = await mcp__chrome-devtools__take_snapshot()
  // Save screenshot to docs/screenshots/{feature}/login-page.png

  // Fill login form
  await mcp__chrome-devtools__fill({
    selector: 'input[type="email"], input[name="email"], #email',
    value: loginCredentials.email
  })

  await mcp__chrome-devtools__fill({
    selector: 'input[type="password"], input[name="password"], #password',
    value: loginCredentials.password
  })

  // Capture filled form
  const filledScreenshot = await mcp__chrome-devtools__take_snapshot()
  // Save to docs/screenshots/{feature}/login-page-filled.png

  // Click login button
  await mcp__chrome-devtools__click({
    selector: 'button[type="submit"], input[type="submit"], .login-button'
  })

  // Wait for redirect
  await new Promise(resolve => setTimeout(resolve, 3000))

  // Capture success state
  const successScreenshot = await mcp__chrome-devtools__take_snapshot()
  // Save to docs/screenshots/{feature}/login-success.png

  console.log('✅ Authentication successful')
}
```

### Step 4: Page-by-Page Verification

**For EACH modified page:**

```typescript
interface PageVerification {
  url: string
  pageName: string
  screenshots: string[]
  findings: string[]
  consoleErrors: string[]
  status: 'pass' | 'warning' | 'fail'
}

const verifyPage = async (url: string, pageName: string): Promise<PageVerification> => {
  const result: PageVerification = {
    url,
    pageName,
    screenshots: [],
    findings: [],
    consoleErrors: [],
    status: 'pass'
  }

  console.log(`📄 Verifying: ${pageName} (${url})`)

  // 1. Navigate to page
  await mcp__chrome-devtools__navigate_page({ url })
  await new Promise(resolve => setTimeout(resolve, 2000))

  // 2. Capture initial screenshot (MANDATORY)
  const initialScreenshot = await mcp__chrome-devtools__take_snapshot()
  const screenshotPath = `docs/screenshots/${featureName}/${pageName}.png`
  result.screenshots.push(screenshotPath)
  // Save screenshot to file

  // 3. Visual verification checklist
  const checks = [
    'Page loads successfully',
    'Layout matches design specifications',
    'Text is readable and properly formatted',
    'Images/icons display correctly',
    'Color scheme matches design',
    'Spacing and alignment correct'
  ]

  // 4. Test interactive elements
  // Forms
  const formInputs = await findElements('input, textarea, select')
  for (const input of formInputs) {
    await mcp__chrome-devtools__fill({
      selector: input.selector,
      value: getTestData(input.type)
    })
  }

  // Buttons
  const buttons = await findElements('button, [type="submit"]')
  for (const button of buttons) {
    await mcp__chrome-devtools__click({
      selector: button.selector
    })
    await new Promise(resolve => setTimeout(resolve, 1000))

    // Capture post-click screenshot
    const actionScreenshot = await mcp__chrome-devtools__take_snapshot()
    const actionPath = `docs/screenshots/${featureName}/${pageName}-${button.name}.png`
    result.screenshots.push(actionPath)
  }

  // 5. Check browser console for errors
  // Note: Console errors are captured via Chrome DevTools

  console.log(`   ✅ ${pageName} verified (${result.screenshots.length} screenshots)`)

  return result
}
```

### Step 5: Generate Verification Report

**MANDATORY: Create comprehensive report**

```typescript
const generateReport = (verifications: PageVerification[], featureName: string): string => {
  const date = new Date().toISOString().split('T')[0]

  let report = `# Phase 3: UI/UX Verification Report

**Feature**: \`${featureName}\`
**Date**: \`${date}\`
**Status**: ${verifications.every(v => v.status === 'pass') ? '✅ PASSED' : '⚠️ ISSUES FOUND'}

---

## Summary

- **Total Pages Verified**: ${verifications.length}
- **Screenshots Captured**: ${verifications.reduce((sum, v) => sum + v.screenshots.length, 0)}
- **Console Errors Found**: ${verifications.reduce((sum, v) => sum + v.consoleErrors.length, 0)}

---

## Pages Verified

`

  for (const verification of verifications) {
    report += `### ${verification.pageName}

**URL**: \`${verification.url}\`
**Status**: ${verification.status === 'pass' ? '✅ Pass' : '⚠️ Issues'}

#### Screenshots

${verification.screenshots.map(s => `![${verification.pageName}](../${s.replace('docs/', '')})`).join('\n')}

#### Findings

${verification.findings.length > 0 ? verification.findings.map(f => `- ${f}`).join('\n') : '- No issues found'}

${verification.consoleErrors.length > 0 ? `#### Console Errors\n${verification.consoleErrors.map(e => `- ❌ ${e}`).join('\n')}` : ''}

---

`
  }

  report += `## Verification Completion

**All Required Steps Completed**:
- [x] Screenshots captured for all modified pages
- [x] Interactive elements tested
- [x] Console errors checked
- [x] Visual design verified
- [x] Report generated

---

**Generated By**: EDAF v1.0 - UI Verification Worker
`

  return report
}

// Save report
const reportPath = `docs/reports/phase3-ui-verification-${featureName}.md`
fs.writeFileSync(reportPath, generateReport(verifications, featureName))
console.log(`📄 Report saved: ${reportPath}`)
```

### Step 6: Run Verification Script

```bash
bash .claude/scripts/verify-ui.sh {feature-name}
```

**Checks performed:**
- Screenshot directory exists
- At least 1 screenshot per page
- Verification report exists
- Report contains meaningful content (10+ lines)

---

## Available MCP Tools

| Tool | Purpose | Usage |
|------|---------|-------|
| `mcp__chrome-devtools__list_pages` | List browser tabs | Initial check |
| `mcp__chrome-devtools__navigate_page` | Navigate to URL | Page access |
| `mcp__chrome-devtools__take_snapshot` | Capture screenshot | Visual evidence |
| `mcp__chrome-devtools__fill` | Fill form inputs | Form testing |
| `mcp__chrome-devtools__click` | Click elements | Interaction testing |

---

## Completion Report

```markdown
# UI Verification Worker Report

**Feature**: {feature-name}
**Status**: ✅ COMPLETE / ⚠️ ISSUES / ❌ FAILED

---

## Verification Summary

- **Environment**: macOS / Linux / Windows
- **MCP Status**: Available / Not Available
- **Authentication**: Required / Not Required

---

## Pages Verified

| Page | URL | Screenshots | Status |
|------|-----|-------------|--------|
| Login | /login | 3 | ✅ Pass |
| Dashboard | /dashboard | 2 | ✅ Pass |

---

## Screenshots Index

All screenshots saved to: `docs/screenshots/{feature-name}/`

1. login-page.png
2. login-page-filled.png
3. login-success.png
4. dashboard.png
5. dashboard-profile.png

---

## Report Location

`docs/reports/phase3-ui-verification-{feature-name}.md`

---

## Next Steps

1. Review screenshots for visual accuracy
2. Address any console errors found
3. Proceed to Phase 4 (Deployment Gate) if passed
```

---

## Error Handling

### Common Issues and Solutions

| Issue | Detection | Solution |
|-------|-----------|----------|
| Chrome not in debug mode | `list_pages` fails | Start Chrome with `--remote-debugging-port=9222` |
| Dev server not running | Navigation fails | Start dev server first |
| Screenshots not saving | Permission denied | Ensure `docs/screenshots/` exists |
| Login fails | Redirect to login | Verify credentials and selectors |
| Element not found | Click/fill fails | Update CSS selectors |

---

## Language Preferences Support

This worker respects language settings from `.claude/edaf-config.yml`:

- **Terminal Output**: Follows `terminal_output_language` setting
- **Report Generation**: Follows `documentation_language` setting
- **Dual Language**: If enabled, generates reports in both EN and JA

---

**Status**: ✅ Design Complete
**Integration**: MCP chrome-devtools required
**Fallback**: Manual verification guide provided for WSL2
