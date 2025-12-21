---
description: Run UI verification for a feature using MCP chrome-devtools
allowed-tools: Task, Bash, Read, Write, AskUserQuestion
argument-hint: <feature-slug>
---

# EDAF UI Verification

Run UI/UX verification for a feature using MCP chrome-devtools.

## Arguments

- `$1` - Feature slug (e.g., "user-authentication")

## Pre-flight Checks

1. **Check environment:**
   - Detect if running in WSL2 (skip if true)
   - Verify MCP chrome-devtools is available

2. **Check prerequisites:**
   - Development server running
   - Chrome in debug mode

## Verification Workflow

If not in WSL2 and MCP is available:

1. **Ask user for login information:**
   Use AskUserQuestion:
   - "Do the modified pages require login?"
   - If yes: collect login URL, email, password

2. **Create screenshot directory:**
   ```bash
   mkdir -p docs/screenshots/$1
   ```

3. **Launch UI verification worker:**
   ```
   Task: ui-verification-worker
   ```

   Prompt the worker to:
   - Navigate to each modified page
   - Capture screenshots
   - Test interactive elements
   - Check browser console
   - Generate verification report

4. **Run verification script:**
   ```bash
   bash .claude/scripts/verify-ui.sh $1
   ```

## Output

- Screenshots: `docs/screenshots/$1/`
- Report: `docs/reports/phase3-ui-verification-$1.md`

## WSL2 Fallback

If running in WSL2:
- Display message that UI verification is not available
- Recommend manual verification
- Provide checklist for manual testing

## Usage Examples

```
/edaf-verify-ui user-authentication
/edaf-verify-ui task-management
/edaf-verify-ui payment-integration
```
