# UI Verification Skill

**Skill Type**: Verification Pattern Library
**Used By**: ui-verification-worker, Main Agent (Phase 3)
**Trigger**: When frontend files are modified in Phase 3

---

## Overview

This skill provides reusable patterns for UI/UX verification using MCP chrome-devtools. It includes browser automation patterns, screenshot conventions, and report templates.

---

## When to Use This Skill

**Automatic Trigger Conditions**:

1. Frontend files modified:
   - `**/components/**/*`
   - `**/pages/**/*`
   - `**/views/**/*`
   - `**/*.css`, `**/*.scss`, `**/*.sass`, `**/*.less`
   - `**/src/**/*.{tsx,jsx,ts,js,vue,svelte}`

2. Phase 3 Code Review Gate active

3. MCP chrome-devtools available (not WSL2)

---

## Skill Contents

| File | Purpose |
|------|---------|
| `SKILL.md` | This overview file |
| `BROWSER-AUTOMATION.md` | MCP chrome-devtools usage patterns |
| `SCREENSHOT-GUIDE.md` | Screenshot naming and storage conventions |
| `CHECKLIST.md` | Verification checklist template |

---

## Quick Reference

### Environment Check

```typescript
// WSL2 Detection
const isWSL2 = fs.existsSync('/proc/version') &&
  fs.readFileSync('/proc/version', 'utf-8').toLowerCase().includes('microsoft')

if (isWSL2) {
  return { skip: true, reason: 'WSL2 environment' }
}
```

### MCP Tools Available

```typescript
mcp__chrome-devtools__list_pages     // List browser tabs
mcp__chrome-devtools__navigate_page  // Navigate to URL
mcp__chrome-devtools__take_snapshot  // Capture screenshot
mcp__chrome-devtools__fill           // Fill form inputs
mcp__chrome-devtools__click          // Click elements
```

### Directory Structure

```
docs/
├── screenshots/{feature-name}/
│   ├── login-page.png
│   ├── login-page-filled.png
│   ├── login-success.png
│   ├── {page-name}.png
│   └── {page-name}-{action}.png
└── reports/
    └── phase3-ui-verification-{feature-name}.md
```

---

## Integration with EDAF

This skill is automatically loaded when:
1. `ui-verification-worker` is launched
2. Phase 3 detects frontend changes
3. User runs `/edaf-verify-ui` command

---

## Related Resources

- **Worker**: `.claude/agents/workers/ui-verification-worker.md`
- **Template**: `.claude/templates/ui-verification-report-template.md`
- **Script**: `.claude/scripts/verify-ui.sh`
- **Guide**: `docs/UI-VERIFICATION-GUIDE.md`
