# Browser Automation Patterns

**Purpose**: Reusable MCP chrome-devtools patterns for UI verification

---

## Connection Setup

### 1. Verify Chrome Debug Mode

Chrome must be running with remote debugging enabled:

```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Linux
google-chrome --remote-debugging-port=9222

# Windows
chrome.exe --remote-debugging-port=9222
```

### 2. Verify MCP Connection

```typescript
try {
  const pages = await mcp__chrome-devtools__list_pages()
  console.log(`✅ Connected to Chrome (${pages.length} tabs)`)
} catch (error) {
  console.error('❌ Chrome connection failed')
  throw new Error('Start Chrome with --remote-debugging-port=9222')
}
```

---

## Navigation Patterns

### Basic Navigation

```typescript
// Navigate and wait for load
await mcp__chrome-devtools__navigate_page({
  url: 'http://localhost:3000/dashboard'
})

// Wait for page to stabilize (network idle)
await new Promise(resolve => setTimeout(resolve, 2000))
```

### Navigation with Retry

```typescript
const navigateWithRetry = async (url: string, maxRetries = 3) => {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await mcp__chrome-devtools__navigate_page({ url })
      await new Promise(resolve => setTimeout(resolve, 2000))
      return true
    } catch (error) {
      if (attempt === maxRetries) throw error
      console.log(`  Retry ${attempt}/${maxRetries}...`)
      await new Promise(resolve => setTimeout(resolve, 1000))
    }
  }
}
```

---

## Screenshot Patterns

### Capture Full Page

```typescript
const captureScreenshot = async (pageName: string, featureName: string) => {
  const screenshot = await mcp__chrome-devtools__take_snapshot()
  const path = `docs/screenshots/${featureName}/${pageName}.png`

  // Save screenshot (implementation depends on MCP response format)
  // Usually base64 encoded image data

  return path
}
```

### Capture After Action

```typescript
const captureAction = async (
  pageName: string,
  actionName: string,
  featureName: string
) => {
  // Perform action first, then capture
  const screenshot = await mcp__chrome-devtools__take_snapshot()
  const path = `docs/screenshots/${featureName}/${pageName}-${actionName}.png`

  return path
}
```

---

## Form Interaction Patterns

### Fill Text Input

```typescript
// By ID
await mcp__chrome-devtools__fill({
  selector: '#email',
  value: 'test@example.com'
})

// By name attribute
await mcp__chrome-devtools__fill({
  selector: 'input[name="email"]',
  value: 'test@example.com'
})

// By type (less specific)
await mcp__chrome-devtools__fill({
  selector: 'input[type="email"]',
  value: 'test@example.com'
})
```

### Fill Password

```typescript
await mcp__chrome-devtools__fill({
  selector: 'input[type="password"]',
  value: 'testpassword123'
})
```

### Fill Multiple Fields

```typescript
const formData = {
  '#firstName': 'John',
  '#lastName': 'Doe',
  '#email': 'john@example.com',
  '#phone': '123-456-7890'
}

for (const [selector, value] of Object.entries(formData)) {
  await mcp__chrome-devtools__fill({ selector, value })
  await new Promise(resolve => setTimeout(resolve, 200))
}
```

---

## Click Patterns

### Button Click

```typescript
// By type
await mcp__chrome-devtools__click({
  selector: 'button[type="submit"]'
})

// By text content (if supported)
await mcp__chrome-devtools__click({
  selector: 'button:contains("Submit")'
})

// By class
await mcp__chrome-devtools__click({
  selector: '.submit-button'
})
```

### Link Click

```typescript
await mcp__chrome-devtools__click({
  selector: 'a[href="/dashboard"]'
})
```

### Wait After Click

```typescript
await mcp__chrome-devtools__click({
  selector: 'button[type="submit"]'
})

// Wait for navigation or API response
await new Promise(resolve => setTimeout(resolve, 2000))
```

---

## Common Selector Patterns

### Login Form

```typescript
const loginSelectors = {
  email: [
    '#email',
    'input[name="email"]',
    'input[type="email"]',
    '[data-testid="email-input"]'
  ],
  password: [
    '#password',
    'input[name="password"]',
    'input[type="password"]',
    '[data-testid="password-input"]'
  ],
  submit: [
    'button[type="submit"]',
    '.login-button',
    '[data-testid="login-button"]',
    'button:contains("Login")',
    'button:contains("Sign in")'
  ]
}
```

### Navigation Menu

```typescript
const navSelectors = {
  hamburger: '.hamburger-menu, .menu-toggle, [data-testid="menu-toggle"]',
  navLink: 'nav a, .nav-link, [data-testid="nav-link"]',
  dropdown: '.dropdown-menu, [data-testid="dropdown"]'
}
```

### Forms

```typescript
const formSelectors = {
  textInput: 'input[type="text"], input:not([type])',
  select: 'select, [role="listbox"]',
  checkbox: 'input[type="checkbox"]',
  radio: 'input[type="radio"]',
  submit: 'button[type="submit"], input[type="submit"]',
  cancel: 'button[type="button"]:contains("Cancel"), .cancel-button'
}
```

---

## Error Handling

### Element Not Found

```typescript
const safeClick = async (selector: string) => {
  try {
    await mcp__chrome-devtools__click({ selector })
    return true
  } catch (error) {
    console.warn(`⚠️  Element not found: ${selector}`)
    return false
  }
}
```

### Navigation Timeout

```typescript
const safeNavigate = async (url: string, timeout = 10000) => {
  const startTime = Date.now()

  try {
    await mcp__chrome-devtools__navigate_page({ url })

    // Wait for page load or timeout
    while (Date.now() - startTime < timeout) {
      // Check if page is loaded (implementation varies)
      await new Promise(resolve => setTimeout(resolve, 500))
    }

    return true
  } catch (error) {
    console.error(`❌ Navigation failed: ${url}`)
    return false
  }
}
```

---

## Complete Login Flow Example

```typescript
const performLogin = async (loginUrl: string, email: string, password: string) => {
  console.log('🔐 Starting login flow...')

  // 1. Navigate to login page
  await mcp__chrome-devtools__navigate_page({ url: loginUrl })
  await new Promise(resolve => setTimeout(resolve, 2000))

  // 2. Screenshot: Login page
  await mcp__chrome-devtools__take_snapshot()
  // Save as: login-page.png

  // 3. Fill credentials
  await mcp__chrome-devtools__fill({
    selector: 'input[type="email"], input[name="email"], #email',
    value: email
  })

  await mcp__chrome-devtools__fill({
    selector: 'input[type="password"], input[name="password"], #password',
    value: password
  })

  // 4. Screenshot: Filled form
  await mcp__chrome-devtools__take_snapshot()
  // Save as: login-page-filled.png

  // 5. Submit
  await mcp__chrome-devtools__click({
    selector: 'button[type="submit"]'
  })

  // 6. Wait for redirect
  await new Promise(resolve => setTimeout(resolve, 3000))

  // 7. Screenshot: Success state
  await mcp__chrome-devtools__take_snapshot()
  // Save as: login-success.png

  console.log('✅ Login completed')
}
```

---

## Best Practices

1. **Always wait after navigation** - Pages need time to render
2. **Use multiple selector fallbacks** - Different frameworks use different patterns
3. **Screenshot before AND after actions** - Visual evidence of state changes
4. **Handle errors gracefully** - Don't fail entire verification for one issue
5. **Use meaningful wait times** - Too short causes flakiness, too long wastes time
6. **Test with realistic data** - Use valid email formats, realistic names
