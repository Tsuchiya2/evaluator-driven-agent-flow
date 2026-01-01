# UI Verification Skill

**Skill Type**: Verification Pattern Library
**Used By**: ui-verification-worker, Main Agent (Phase 5)
**Trigger**: When frontend files are modified in Phase 4
**Method**: MCP chrome-devtools

---

## Overview

This skill provides reusable patterns for UI/UX verification using **Claude in Chrome**. It uses a subagent-based approach where browser interactions are delegated to a general-purpose agent with access to Claude in Chrome extension.

---

## When to Use This Skill

**Automatic Trigger Conditions**:

1. Frontend files modified:
   - `**/components/**/*`
   - `**/pages/**/*`
   - `**/views/**/*`
   - `**/*.css`, `**/*.scss`, `**/*.sass`, `**/*.less`
   - `**/src/**/*.{tsx,jsx,ts,js,vue,svelte}`

2. Phase 5 Code Review Gate active

3. User has MCP chrome-devtools server configured

---

## Skill Contents

| File | Purpose |
|------|---------|
| `SKILL.md` | This overview file |
| `BROWSER-AUTOMATION.md` | Claude in Chrome subagent patterns |
| `SCREENSHOT-GUIDE.md` | Screenshot naming and storage conventions |
| `CHECKLIST.md` | Verification checklist template |
| `REPORT-TEMPLATE.md` | Markdown report template |
| `USER-GUIDE.md` | User guide for manual verification |

---

## Quick Reference

### Subagent Approach

```typescript
// Launch subagent with Claude in Chrome access
const verificationResult = await Task({
  subagent_type: 'general-purpose',
  model: 'sonnet',
  description: 'UI verification via Claude in Chrome',
  prompt: `You are a UI verification specialist using Claude in Chrome...

  **Tasks**:
  1. Open browser with Claude in Chrome extension
  2. Navigate to pages and capture screenshots
  3. Test interactive elements
  4. Check console for errors
  5. Return structured JSON report
  `
})
```

### Directory Structure

```
.steering/{YYYY-MM-DD}-{feature-name}/
├── screenshots/
│   ├── login-page.png
│   ├── login-filled.png
│   ├── login-success.png
│   ├── {page-name}.png
│   └── {page-name}-{action}.png
└── reports/
    └── phase5-ui-verification.md
```

---

## Integration with EDAF

This skill is automatically loaded when:
1. `ui-verification-worker` is launched
2. Phase 5 detects frontend changes
3. User asks Claude Code to run UI verification

**Key Difference from MCP Approach**:
- ❌ No MCP server setup required
- ❌ No WSL2 environment restrictions
- ✅ Uses official Claude in Chrome extension
- ✅ Subagent handles all browser interactions
- ✅ Works across all platforms

---

## Subagent Workflow

```
Main Worker
    ↓
    ├─→ Collect requirements (dev server URL, login info)
    ├─→ Identify modified pages from design doc
    ├─→ Create screenshot directory
    ↓
Launch Subagent (general-purpose)
    ↓
    ├─→ Open browser with Claude in Chrome
    ├─→ Authenticate (if required)
    ├─→ For each page:
    │     ├─→ Navigate to page
    │     ├─→ Capture screenshot
    │     ├─→ Test interactive elements
    │     └─→ Check console errors
    ↓
Return JSON report to main worker
    ↓
Main Worker
    ├─→ Parse JSON results
    ├─→ Generate markdown report
    └─→ Verify all screenshots saved
```

---

## Advantages

**Claude in Chrome Benefits**:
- ✅ **Official Support**: Anthropic's official extension
- ✅ **No Setup**: No MCP server configuration needed
- ✅ **Cross-Platform**: Works on macOS, Linux, Windows, WSL2
- ✅ **Flexible**: Subagent can handle complex scenarios
- ✅ **Maintainable**: Less infrastructure to manage
- ✅ **Reliable**: Direct browser integration

---

## Related Resources

- **Worker**: `.claude/agents/workers/ui-verification-worker.md`
- **Report Template**: `REPORT-TEMPLATE.md` (same directory)
- **User Guide**: `USER-GUIDE.md` (same directory)
- **Checklist**: `CHECKLIST.md` (same directory)
