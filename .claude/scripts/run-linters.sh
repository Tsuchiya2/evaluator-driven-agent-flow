#!/bin/bash
# run-linters.sh - Run configured lint tools
# Part of EDAF v1.0 - Phase 4 Quality Gate

set -euo pipefail

CONFIG_FILE=".claude/edaf-config.yml"
EXIT_CODE=0
FAILED_TOOLS=()
PASSED_TOOLS=()

echo "🔍 Running lint checks..."
echo ""

# Check if linters are enabled
if ! grep -q "^linters:" "$CONFIG_FILE" 2>/dev/null; then
    echo "⚠️  No linter configuration found"
    echo "   Run: bash .claude/scripts/detect-linters.sh"
    exit 0
fi

LINTERS_ENABLED=$(grep -A1 "^linters:" "$CONFIG_FILE" | grep "enabled:" | awk '{print $2}')

if [ "$LINTERS_ENABLED" != "true" ]; then
    echo "ℹ️  Linters are disabled - skipping lint checks"
    exit 0
fi

# Parse and run each linter
echo "📋 Configured linters:"
echo ""

# Extract tool configurations
TOOLS=$(sed -n '/^linters:/,/^[a-z_]*:/{/name:/p}' "$CONFIG_FILE" | sed 's/.*name: //')

if [ -z "$TOOLS" ]; then
    echo "⚠️  No lint tools configured"
    exit 0
fi

# Run each tool
while IFS= read -r tool_name; do
    # Get command for this tool
    COMMAND=$(sed -n "/name: $tool_name/,/name:/p" "$CONFIG_FILE" | grep "command:" | head -1 | sed 's/.*command: //')

    if [ -z "$COMMAND" ]; then
        continue
    fi

    echo "▶️  Running $tool_name..."
    echo "   Command: $COMMAND"

    # Run the linter
    if eval "$COMMAND" 2>&1; then
        echo "   ✅ $tool_name passed"
        PASSED_TOOLS+=("$tool_name")
    else
        echo "   ❌ $tool_name failed"
        FAILED_TOOLS+=("$tool_name")
        EXIT_CODE=1
    fi

    echo ""
done <<< "$TOOLS"

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Lint Check Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ${#PASSED_TOOLS[@]} -gt 0 ]; then
    echo "✅ Passed (${#PASSED_TOOLS[@]}):"
    for tool in "${PASSED_TOOLS[@]}"; do
        echo "   • $tool"
    done
    echo ""
fi

if [ ${#FAILED_TOOLS[@]} -gt 0 ]; then
    echo "❌ Failed (${#FAILED_TOOLS[@]}):"
    for tool in "${FAILED_TOOLS[@]}"; do
        echo "   • $tool"
    done
    echo ""
    echo "🔄 Phase 4 workers need to fix lint errors and re-run"
    echo ""
else
    echo "✨ All lint checks passed!"
    echo ""
fi

exit $EXIT_CODE
