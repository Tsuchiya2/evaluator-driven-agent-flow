---
description: Display the latest EDAF evaluation reports for a feature
allowed-tools: Read, Glob, Bash
argument-hint: <feature-slug>
---

# EDAF Report Viewer

Display the latest evaluation reports and verification results for a feature.

## Arguments

- `$1` - Feature slug (e.g., "user-authentication")

## Reports to Display

### 1. Design Document

Check and display summary of:
```
docs/designs/$1.md
```

### 2. Task Plan

Check and display summary of:
```
docs/plans/$1-tasks.md
```

### 3. UI Verification Report

Check and display:
```
docs/reports/phase3-ui-verification-$1.md
```

### 4. Screenshot Index

List all screenshots:
```bash
ls -la docs/screenshots/$1/ 2>/dev/null || echo "No screenshots found"
```

## Report Summary

Provide a consolidated summary including:

1. **Feature Overview**
   - Feature name and slug
   - Current phase status

2. **Design Summary**
   - Key design decisions
   - Architecture overview

3. **Task Summary**
   - Total tasks planned
   - Worker assignments

4. **Code Review Status**
   - Evaluator scores (if available)
   - Issues found and fixed

5. **UI Verification Status**
   - Pages verified
   - Screenshots captured
   - Issues found

6. **Next Steps**
   - Remaining work
   - Recommendations

## Output Format

Display reports in a clean, readable format:

```markdown
# EDAF Report: $1

## Status: [Phase X] [Status]

### Design
- Created: [date]
- Sections: [count]

### Plan
- Tasks: [count]
- Workers: database, backend, frontend, test

### UI Verification
- Pages: [count]
- Screenshots: [count]
- Status: PASSED/FAILED/PENDING

### Screenshots
[List of screenshots with relative paths]
```

## Usage Examples

```
/edaf-report user-authentication
/edaf-report task-management
```
