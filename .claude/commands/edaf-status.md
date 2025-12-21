---
description: Show current EDAF workflow phase and progress
allowed-tools: Bash, Read, Glob
---

# EDAF Status Check

Display the current EDAF workflow status.

## Check Current Phase

!bash .claude/scripts/edaf-status.sh

## Check Recent Documents

Check for recent design and plan documents:

**Design Documents:**
```bash
ls -la docs/designs/ 2>/dev/null || echo "No design documents yet"
```

**Plan Documents:**
```bash
ls -la docs/plans/ 2>/dev/null || echo "No plan documents yet"
```

**Verification Reports:**
```bash
ls -la docs/reports/phase3-* 2>/dev/null || echo "No verification reports yet"
```

**Screenshots:**
```bash
ls -d docs/screenshots/*/ 2>/dev/null || echo "No screenshot directories yet"
```

## Summary

Provide a brief summary of:
1. Current phase and status
2. Most recent design document (if any)
3. Most recent plan document (if any)
4. Any pending evaluations
