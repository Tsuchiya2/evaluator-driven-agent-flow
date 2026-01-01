# Browser Automation Patterns (Claude in Chrome)

**Purpose**: Reusable patterns for UI verification using Claude in Chrome via subagent

---

## Overview

This document provides patterns for browser automation using **Claude in Chrome** through a subagent approach. Instead of direct MCP tool calls, all browser interactions are delegated to a general-purpose subagent.

---

## Subagent Pattern

### Basic Subagent Launch

```typescript
const verificationResult = await Task({
  subagent_type: 'general-purpose',
  model: 'sonnet',
  description: 'UI verification via Claude in Chrome',
  prompt: `You are a UI verification specialist using Claude in Chrome.

  **Your Task**: Verify the following page(s) by opening them in Chrome:

  1. Navigate to: http://localhost:3000/dashboard
  2. Capture screenshot and save to: .steering/2026-01-01-feature/screenshots/dashboard.png
  3. Test all buttons and forms
  4. Check console for errors
  5. Return findings in JSON format

  **Use Claude in Chrome extension to**:
  - Open and interact with web pages
  - Capture screenshots
  - Inspect page elements
  - Monitor console output

  **Output Format**:
  \`\`\`json
  {
    "page": "dashboard",
    "url": "http://localhost:3000/dashboard",
    "screenshots": [".steering/2026-01-01-feature/screenshots/dashboard.png"],
    "findings": ["All elements render correctly"],
    "consoleErrors": [],
    "status": "pass"
  }
  \`\`\`
  `
})
```

---

## Navigation Patterns

### Single Page Verification

```typescript
const prompt = `Navigate to ${pageUrl} using Claude in Chrome:

1. Open Chrome with Claude in Chrome extension
2. Navigate to: ${pageUrl}
3. Wait for page to fully load (check network activity)
4. Capture full-page screenshot
5. Save to: ${screenshotPath}
6. Report any visual issues or console errors

Return: Screenshot path and any findings`
```

### Multi-Page Verification

```typescript
const pages = [
  { name: 'login', url: 'http://localhost:3000/login' },
  { name: 'dashboard', url: 'http://localhost:3000/dashboard' },
  { name: 'profile', url: 'http://localhost:3000/profile' }
]

const prompt = `Verify multiple pages using Claude in Chrome:

**Pages to Verify**:
${pages.map(p => `- ${p.name}: ${p.url}`).join('\n')}

**For Each Page**:
1. Navigate to the URL
2. Wait for full page load
3. Capture screenshot as: ${screenshotDir}/{page-name}.png
4. Check for visual issues
5. Check console errors

**Return JSON Array**:
\`\`\`json
[
  {
    "name": "login",
    "url": "...",
    "screenshots": ["..."],
    "findings": [...],
    "status": "pass"
  }
]
\`\`\``
```

---

## Screenshot Patterns

### Full Page Screenshot

```typescript
const prompt = `Capture full-page screenshot using Claude in Chrome:

1. Navigate to: ${url}
2. Wait for page load (2-3 seconds)
3. Scroll to ensure full page is visible
4. Capture screenshot
5. Save to: ${screenshotPath}
6. Verify screenshot was saved successfully

Use browser's built-in screenshot functionality or Claude in Chrome features.`
```

### Screenshot After Action

```typescript
const prompt = `Capture screenshots during user flow:

1. Navigate to: ${url}
2. Initial screenshot: ${screenshotDir}/initial.png
3. Fill form with test data
4. After-fill screenshot: ${screenshotDir}/filled.png
5. Click submit button
6. Success screenshot: ${screenshotDir}/success.png

Return paths to all 3 screenshots.`
```

---

## Form Interaction Patterns

### Login Flow

```typescript
const prompt = `Perform login flow using Claude in Chrome:

1. Navigate to: ${loginUrl}
2. Screenshot: login-page.png
3. Fill email field with: ${testEmail}
4. Fill password field with: ${testPassword}
5. Screenshot: login-filled.png
6. Click submit/login button
7. Wait for redirect (3 seconds)
8. Screenshot: login-success.png
9. Verify successful login (check for dashboard/profile elements)

**Ask user for credentials** if not provided.

Return:
- Screenshot paths
- Login success: true/false
- Any errors encountered`
```

### Form Testing

```typescript
const prompt = `Test form interactions using Claude in Chrome:

1. Navigate to form page: ${formUrl}
2. Identify all input fields (text, email, select, checkbox, etc.)
3. Fill each field with appropriate test data:
   - Text: "Test User"
   - Email: "test@example.com"
   - Phone: "123-456-7890"
   - etc.
4. Capture screenshot after filling
5. Click submit button
6. Capture result screenshot
7. Check for validation errors or success messages

Return:
- Form fields tested
- Screenshots
- Validation results
- Any errors`
```

---

## Interactive Element Testing

### Button Testing

```typescript
const prompt = `Test all buttons on the page:

1. Navigate to: ${pageUrl}
2. Identify all buttons on the page
3. For each button:
   - Screenshot before click: {page}-{button-name}-before.png
   - Click the button
   - Wait 1 second
   - Screenshot after click: {page}-{button-name}-after.png
   - Observe state changes
4. Report findings for each button

Return:
- List of buttons tested
- Screenshot paths
- Observed behaviors
- Any errors`
```

### Link Testing

```typescript
const prompt = `Test navigation links:

1. Navigate to: ${pageUrl}
2. Identify all navigation links
3. For each link:
   - Note the link text and href
   - Click the link
   - Verify navigation works
   - Capture screenshot of destination
   - Navigate back
4. Report broken links or navigation issues

Return:
- Links tested
- Broken links (if any)
- Screenshot evidence`
```

---

## Console Monitoring

### Check Console Errors

```typescript
const prompt = `Monitor browser console for errors:

1. Navigate to: ${pageUrl}
2. Open browser DevTools console
3. Look for:
   - JavaScript errors (red text)
   - Warnings (yellow/orange)
   - Failed network requests
   - 404 errors
4. Record all errors with:
   - Error message
   - File/line number
   - Stack trace (if applicable)

Return:
- Console errors found
- Severity (error/warning)
- Context for each error`
```

---

## Authentication Patterns

### Pre-Authentication Required

```typescript
const prompt = `Authenticate before testing protected pages:

**Step 1: Login**
1. Navigate to: ${loginUrl}
2. Ask user for credentials (email, password)
3. Fill login form
4. Submit and wait for redirect
5. Verify authentication success

**Step 2: Verify Protected Pages**
Once logged in, test these pages:
${protectedPages.map(p => `- ${p.name}: ${p.url}`).join('\n')}

For each page:
1. Navigate (should not redirect to login)
2. Capture screenshot
3. Test interactive elements
4. Check console

**IMPORTANT**: Maintain authentication session throughout testing.`
```

---

## Responsive Testing (Optional)

### Mobile Viewport Test

```typescript
const prompt = `Test responsive design using Chrome DevTools:

1. Open Claude in Chrome
2. Navigate to: ${pageUrl}
3. Open DevTools (F12)
4. Enable device toolbar
5. Test viewports:
   - Mobile: 375x667 (iPhone)
   - Tablet: 768x1024 (iPad)
   - Desktop: 1920x1080
6. For each viewport:
   - Capture screenshot: {page}-{viewport}.png
   - Check layout correctness
   - Test menu/navigation

Return screenshots and layout findings for each viewport.`
```

---

## Complete Verification Flow Example

```typescript
const fullVerificationPrompt = `Complete UI verification using Claude in Chrome:

**Feature**: User Authentication
**Base URL**: http://localhost:3000

**Pages to Verify**:
1. Login Page (/login)
2. Dashboard (/dashboard) - requires login
3. Profile (/profile) - requires login

**Your Tasks**:

1. **Environment Setup**:
   - Open Chrome with Claude in Chrome extension
   - Ensure dev server is running at ${baseUrl}

2. **Login Flow**:
   - Navigate to /login
   - Screenshot: login-page.png
   - Ask user for test credentials
   - Fill and submit form
   - Screenshot: login-success.png
   - Verify redirect to dashboard

3. **Dashboard Verification**:
   - Ensure you're on /dashboard
   - Screenshot: dashboard-main.png
   - Test sidebar navigation
   - Click "Profile" button
   - Screenshot: dashboard-profile-click.png

4. **Profile Verification**:
   - Verify navigation to /profile
   - Screenshot: profile-page.png
   - Test profile form
   - Fill with test data
   - Screenshot: profile-filled.png
   - Submit changes
   - Screenshot: profile-updated.png

5. **Console Check**:
   - Review all pages for console errors
   - Document any errors found

6. **Final Report**:
   Return JSON with all screenshots, findings, and status.

**Screenshot Directory**: .steering/2026-01-01-user-auth/screenshots/

**Output Format**:
\`\`\`json
{
  "feature": "User Authentication",
  "baseUrl": "http://localhost:3000",
  "authenticationRequired": true,
  "pages": [
    {
      "name": "login",
      "url": "http://localhost:3000/login",
      "screenshots": ["login-page.png", "login-success.png"],
      "findings": ["Form validation works correctly"],
      "consoleErrors": [],
      "status": "pass"
    },
    {
      "name": "dashboard",
      "url": "http://localhost:3000/dashboard",
      "screenshots": ["dashboard-main.png", "dashboard-profile-click.png"],
      "findings": ["All navigation works"],
      "consoleErrors": [],
      "status": "pass"
    },
    {
      "name": "profile",
      "url": "http://localhost:3000/profile",
      "screenshots": ["profile-page.png", "profile-filled.png", "profile-updated.png"],
      "findings": ["Profile update successful"],
      "consoleErrors": [],
      "status": "pass"
    }
  ],
  "totalScreenshots": 8,
  "totalIssues": 0,
  "overallStatus": "pass"
}
\`\`\`
`
```

---

## Best Practices

1. **Ask User for Credentials**: Never hardcode or assume credentials
2. **Wait for Page Load**: Allow 2-3 seconds after navigation
3. **Capture Evidence**: Screenshot before and after actions
4. **Handle Errors Gracefully**: Document errors, don't fail completely
5. **Use Realistic Test Data**: Valid emails, proper formats
6. **Check Console**: Always monitor for JS errors
7. **Verify Screenshots Saved**: Confirm files exist after capture
8. **Return Structured Data**: Use JSON for easy parsing

---

## Error Handling

### Common Issues

| Issue | Solution |
|-------|----------|
| Page doesn't load | Check dev server is running, retry navigation |
| Element not found | Update selectors, check if page structure changed |
| Screenshot not saving | Verify write permissions, check path exists |
| Login fails | Verify credentials, check form selectors |
| Console errors found | Document them, don't block verification |

### Recovery Patterns

```typescript
// If subagent encounters errors, provide recovery instructions
const recoveryPrompt = `If you encounter issues:

1. **Page Load Timeout**: Wait longer (5 seconds), retry once
2. **Element Not Found**: Try alternate selectors, document missing element
3. **Screenshot Fail**: Try browser screenshot tool, or skip and document
4. **Login Fail**: Ask user to verify credentials, provide error details
5. **Console Errors**: Document but continue verification

**IMPORTANT**: Complete as much as possible, document what failed.`
```

---

## Advantages of Claude in Chrome Approach

- ✅ **No MCP Setup**: Official extension, no server configuration
- ✅ **Cross-Platform**: Works on all OS including WSL2
- ✅ **Flexible**: Subagent can adapt to complex scenarios
- ✅ **Natural**: Uses Claude's visual understanding capabilities
- ✅ **Maintainable**: Less infrastructure dependencies
- ✅ **Reliable**: Official Anthropic support

---

**Method**: Subagent with Claude in Chrome
**No MCP Required**: Uses official extension only
