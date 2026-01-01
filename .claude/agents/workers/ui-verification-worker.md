# UI Verification Worker Agent

**Agent Type**: Worker (Verification) - **Claude in Chrome Specialist**
**Phase**: Phase 5 (Code Review Gate - UI/UX Verification)
**Responsibility**: Automated UI/UX verification using Claude in Chrome
**Execution Mode**: Sequential (after code evaluators pass in Phase 5)
**Model**: `sonnet` (visual verification and report generation)

---

## Purpose

The UI Verification Worker automates visual verification of frontend changes using Claude in Chrome. It delegates browser interaction tasks to a specialized subagent, which handles navigation, screenshot capture, interactive testing, and visual analysis.

**Key Capabilities**:

1. **Browser Automation** via Claude in Chrome subagent
2. **Screenshot Capture** for all modified pages
3. **Interactive Testing** of forms, buttons, and navigation
4. **Visual Analysis** of UI/UX elements
5. **Report Generation** with visual evidence

---

## Subagent Approach

Instead of using MCP tools directly, this worker launches a **general-purpose subagent** that:
- Has access to Claude in Chrome
- Can navigate web pages and interact with UI elements
- Can capture screenshots and save them to the project
- Returns findings in a structured format

**Benefits**:
- ✅ Works across all platforms (macOS, Linux, Windows, WSL2)
- ✅ No MCP server setup required
- ✅ Uses official Claude in Chrome extension
- ✅ More flexible and maintainable

---

## Verification Workflow

### Step 1: Collect Verification Requirements

**MANDATORY: Ask user for application information**

```typescript
const appResponse = await AskUserQuestion({
  questions: [
    {
      question: "What is the URL of your development server?",
      header: "Dev Server",
      multiSelect: false,
      options: [
        {
          label: "http://localhost:3000",
          description: "React/Next.js default"
        },
        {
          label: "http://localhost:5173",
          description: "Vite default"
        },
        {
          label: "http://localhost:8080",
          description: "Vue/other"
        }
      ]
    },
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

const baseUrl = appResponse.answers['0']
const requiresLogin = appResponse.answers['1'].includes('Yes')

let loginInfo = null
if (requiresLogin) {
  const loginResponse = await AskUserQuestion({
    questions: [
      {
        question: "What is the login page path? (e.g., /login, /auth/signin)",
        header: "Login Path",
        multiSelect: false,
        options: [
          { label: "/login", description: "Standard login path" },
          { label: "/auth/signin", description: "Auth subdirectory" },
          { label: "/signin", description: "Simple signin path" }
        ]
      }
    ]
  })

  loginInfo = {
    url: baseUrl + loginResponse.answers['0'],
    // Note: Credentials will be provided by user during subagent execution
  }
}
```

### Step 2: Identify Modified Pages

```typescript
// Read design document to understand which pages were modified
const featureName = '{feature-name}'  // Provided by orchestrator
const sessionDate = '{YYYY-MM-DD}'    // Provided by orchestrator
const designDoc = fs.readFileSync(
  `.steering/${sessionDate}-${featureName}/design.md`,
  'utf-8'
)

// Extract page URLs from design document
// Look for sections like "UI Changes", "Pages Modified", "Frontend Components"
const modifiedPages = extractModifiedPages(designDoc, baseUrl)

console.log(`📋 Found ${modifiedPages.length} page(s) to verify:`)
modifiedPages.forEach(page => console.log(`   - ${page.name}: ${page.url}`))
```

### Step 3: Create Screenshot Directory

```typescript
const screenshotDir = `.steering/${sessionDate}-${featureName}/screenshots`

// Create directory
fs.mkdirSync(screenshotDir, { recursive: true })
console.log(`📁 Created screenshot directory: ${screenshotDir}`)
```

### Step 4: Launch UI Verification Subagent

**CRITICAL: Use subagent for all browser interactions**

```typescript
console.log('🚀 Launching UI Verification Subagent...')
console.log('   Using Claude in Chrome for browser automation')

const verificationResult = await Task({
  subagent_type: 'general-purpose',
  model: 'sonnet',
  description: 'UI/UX verification via Claude in Chrome',
  prompt: `You are a UI verification specialist using Claude in Chrome to test frontend changes.

**Feature**: ${featureName}
**Base URL**: ${baseUrl}
${requiresLogin ? `**Login URL**: ${loginInfo.url}` : '**Authentication**: Not required'}

**Modified Pages to Verify**:
${modifiedPages.map(p => `- ${p.name}: ${p.url}`).join('\n')}

**Screenshot Directory**: ${screenshotDir}

**Your Tasks**:

1. **Open Browser with Claude in Chrome**:
   - Open Google Chrome with the Claude in Chrome extension enabled
   - You will interact with web pages directly through the browser

${requiresLogin ? `2. **Authenticate** (REQUIRED):
   - Navigate to ${loginInfo.url}
   - Ask the user for login credentials (do NOT assume or hardcode)
   - Fill in the login form and submit
   - Capture screenshots:
     - ${screenshotDir}/login-page.png (initial login page)
     - ${screenshotDir}/login-filled.png (form filled, before submit)
     - ${screenshotDir}/login-success.png (after successful login)
   - Verify successful authentication
` : ''}

3. **Verify Each Modified Page**:
   For each page in the list above:

   a. **Navigate** to the page URL

   b. **Capture Initial Screenshot**:
      - Save as: ${screenshotDir}/{page-name}.png
      - Ensure full page is visible

   c. **Visual Inspection Checklist**:
      - [ ] Page loads successfully without errors
      - [ ] Layout matches design specifications
      - [ ] Text is readable and properly formatted
      - [ ] Images/icons display correctly
      - [ ] Colors match design system
      - [ ] Spacing and alignment are correct
      - [ ] Responsive behavior (if applicable)

   d. **Test Interactive Elements**:
      - Identify all buttons, forms, links
      - Click buttons and capture state changes
      - Fill forms with test data
      - Verify navigation works
      - Save additional screenshots as: ${screenshotDir}/{page-name}-{action}.png

   e. **Check Browser Console**:
      - Open DevTools console
      - Look for JavaScript errors or warnings
      - Record any console errors found

4. **Generate Structured Report**:
   Create a JSON report with this structure:

   \`\`\`json
   {
     "feature": "${featureName}",
     "baseUrl": "${baseUrl}",
     "authenticationRequired": ${requiresLogin},
     "pages": [
       {
         "name": "page-name",
         "url": "full-url",
         "screenshots": ["relative/path/to/screenshot.png"],
         "findings": ["observation 1", "observation 2"],
         "consoleErrors": ["error message 1"],
         "interactiveElements": ["button tested", "form filled"],
         "status": "pass" | "warning" | "fail"
       }
     ],
     "totalScreenshots": 10,
     "totalIssues": 2,
     "overallStatus": "pass" | "warning" | "fail"
   }
   \`\`\`

5. **Save All Screenshots**:
   - Use your Write tool to save each screenshot to ${screenshotDir}/
   - Ensure filenames follow the convention: {page-name}.png, {page-name}-{action}.png
   - Screenshots should be clear and show the full UI state

**IMPORTANT**:
- Actually open the browser and interact with the pages using Claude in Chrome
- DO NOT mock or simulate - perform real verification
- Capture REAL screenshots using browser screenshot functionality
- Ask the user for any information you need (like login credentials)
- If you encounter errors, document them in the report
- Focus on visual accuracy and user experience

**Output**:
Return the JSON report structure above with all findings.
`
})

console.log('✅ UI Verification Subagent completed')
```

### Step 5: Parse Subagent Results

```typescript
// Extract JSON report from subagent output
const reportMatch = verificationResult.match(/```json\n([\s\S]*?)\n```/)
if (!reportMatch) {
  throw new Error('Subagent did not return valid JSON report')
}

const verificationData = JSON.parse(reportMatch[1])

console.log(`\n📊 Verification Results:`)
console.log(`   Total Pages: ${verificationData.pages.length}`)
console.log(`   Total Screenshots: ${verificationData.totalScreenshots}`)
console.log(`   Total Issues: ${verificationData.totalIssues}`)
console.log(`   Overall Status: ${verificationData.overallStatus}`)
```

### Step 6: Generate Markdown Report

```typescript
const generateReport = (data: any, featureName: string): string => {
  const date = new Date().toISOString().split('T')[0]

  let report = `# Phase 4: UI/UX Verification Report

**Feature**: \`${featureName}\`
**Date**: \`${date}\`
**Status**: ${data.overallStatus === 'pass' ? '✅ PASSED' : data.overallStatus === 'warning' ? '⚠️ WARNINGS' : '❌ FAILED'}

---

## Summary

- **Base URL**: ${data.baseUrl}
- **Authentication**: ${data.authenticationRequired ? 'Required' : 'Not Required'}
- **Total Pages Verified**: ${data.pages.length}
- **Screenshots Captured**: ${data.totalScreenshots}
- **Issues Found**: ${data.totalIssues}

---

## Pages Verified

`

  for (const page of data.pages) {
    const statusIcon = page.status === 'pass' ? '✅' : page.status === 'warning' ? '⚠️' : '❌'

    report += `### ${statusIcon} ${page.name}

**URL**: \`${page.url}\`
**Status**: ${page.status.toUpperCase()}

#### Screenshots

${page.screenshots.map(s => `![${page.name}](../screenshots/${path.basename(s)})`).join('\n')}

#### Findings

${page.findings.length > 0 ? page.findings.map(f => `- ${f}`).join('\n') : '- No issues found'}

${page.consoleErrors && page.consoleErrors.length > 0 ? `#### Console Errors\n${page.consoleErrors.map(e => `- ❌ ${e}`).join('\n')}` : ''}

${page.interactiveElements && page.interactiveElements.length > 0 ? `#### Interactive Elements Tested\n${page.interactiveElements.map(e => `- ${e}`).join('\n')}` : ''}

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

## Next Steps

${data.overallStatus === 'pass'
  ? '✅ All verifications passed - proceed to Phase 5 (Deployment Gate)'
  : '⚠️ Issues found - review findings and address before proceeding'}

---

**Generated By**: EDAF v1.0 - UI Verification Worker (Claude in Chrome)
**Verification Method**: Automated via Claude in Chrome subagent
`

  return report
}

// Save report
const reportPath = `.steering/${sessionDate}-${featureName}/reports/phase4-ui-verification.md`
fs.writeFileSync(reportPath, generateReport(verificationData, featureName))
console.log(`📄 Report saved: ${reportPath}`)
```

### Step 7: Verify Artifacts

```typescript
// Verify all expected screenshots exist
const missingScreenshots = []
for (const page of verificationData.pages) {
  for (const screenshot of page.screenshots) {
    if (!fs.existsSync(screenshot)) {
      missingScreenshots.push(screenshot)
    }
  }
}

if (missingScreenshots.length > 0) {
  console.warn(`⚠️  Missing screenshots:`)
  missingScreenshots.forEach(s => console.warn(`   - ${s}`))
}

// Verify report exists and has content
const reportStats = fs.statSync(reportPath)
if (reportStats.size < 500) {
  console.warn('⚠️  Report seems too short - may be incomplete')
}

console.log(`\n✅ UI Verification Complete`)
console.log(`   Report: ${reportPath}`)
console.log(`   Screenshots: ${screenshotDir}`)
```

---

## Completion Report

```typescript
return {
  status: verificationData.overallStatus,
  pagesVerified: verificationData.pages.length,
  screenshots: verificationData.totalScreenshots,
  issues: verificationData.totalIssues,
  reportPath: reportPath,
  screenshotDir: screenshotDir,
  summary: `Verified ${verificationData.pages.length} page(s) using Claude in Chrome. ` +
           `Captured ${verificationData.totalScreenshots} screenshot(s). ` +
           `Found ${verificationData.totalIssues} issue(s).`
}
```

---

## Error Handling

### Common Issues and Solutions

| Issue | Detection | Solution |
|-------|-----------|----------|
| Chrome extension not installed | Subagent cannot interact | Install Claude in Chrome extension |
| Dev server not running | Navigation fails | Start dev server before verification |
| Screenshots not saving | Missing files | Check write permissions in .steering/ |
| Login fails | Authentication errors | Verify credentials and login flow |
| Element not found | Interaction fails | Update selectors or UI implementation |

---

## Advantages Over MCP Approach

**Claude in Chrome Benefits**:
- ✅ **No Setup Required** - Uses official extension (no MCP server)
- ✅ **Cross-Platform** - Works on macOS, Linux, Windows, WSL2
- ✅ **More Reliable** - Official Anthropic support
- ✅ **Better UX** - Direct browser interaction
- ✅ **Flexible** - Subagent can handle complex scenarios
- ✅ **Maintainable** - Less infrastructure to manage

---

## Language Preferences Support

This worker respects language settings from `.claude/edaf-config.yml`:

- **Terminal Output**: Follows `terminal_output_language` setting
- **Report Generation**: Follows `documentation_language` setting
- **Dual Language**: If enabled, generates reports in both EN and JA

---

**Status**: ✅ Updated for Claude in Chrome
**Integration**: Claude in Chrome extension required
**Method**: Subagent-based automation
