#!/bin/bash
# EDAF Evaluator Score Checker
# This script is called by SubagentStop hook when an evaluator completes

# Update EDAF phase status
PHASE_FILE=".claude/.edaf-phase"
SCORE_LOG=".claude/.edaf-scores.log"

# Get timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log the evaluator completion
echo "[$TIMESTAMP] Evaluator completed" >> "$SCORE_LOG"

# Play notification sound
if [ -f ".claude/scripts/notification.sh" ]; then
    bash .claude/scripts/notification.sh "Evaluator completed" WarblerSong 2>/dev/null &
fi

exit 0
