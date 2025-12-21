#!/bin/bash
# EDAF Phase Update Script
# Usage: bash update-edaf-phase.sh "Phase 1: Design" "Designer running"
# Usage: bash update-edaf-phase.sh "Phase 3: Code Review" "7/7 evaluators"

PHASE_FILE=".claude/.edaf-phase"

PHASE="$1"
DETAILS="$2"

if [ -z "$PHASE" ]; then
    echo "Usage: $0 <phase> [details]"
    echo "Example: $0 'Phase 1: Design' 'Designer running'"
    exit 1
fi

if [ -n "$DETAILS" ]; then
    echo "EDAF $PHASE | $DETAILS" > "$PHASE_FILE"
else
    echo "EDAF $PHASE" > "$PHASE_FILE"
fi

echo "Phase updated: $PHASE"
