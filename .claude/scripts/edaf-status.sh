#!/bin/bash
# EDAF Status Line Script
# Displays current EDAF phase and progress in Claude Code status line

PHASE_FILE=".claude/.edaf-phase"
SCORE_LOG=".claude/.edaf-scores.log"

# Default status
STATUS="EDAF: Ready"

# Check if phase file exists
if [ -f "$PHASE_FILE" ]; then
    PHASE_INFO=$(cat "$PHASE_FILE" 2>/dev/null)
    if [ -n "$PHASE_INFO" ]; then
        STATUS="$PHASE_INFO"
    fi
fi

# Check recent evaluator activity
if [ -f "$SCORE_LOG" ]; then
    LAST_EVAL=$(tail -1 "$SCORE_LOG" 2>/dev/null | cut -d']' -f1 | tr -d '[')
    if [ -n "$LAST_EVAL" ]; then
        # Calculate time since last evaluation
        NOW=$(date +%s)
        LAST_TIME=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_EVAL" +%s 2>/dev/null || echo "0")
        if [ "$LAST_TIME" != "0" ]; then
            DIFF=$((NOW - LAST_TIME))
            if [ "$DIFF" -lt 300 ]; then
                STATUS="$STATUS | Last eval: ${DIFF}s ago"
            fi
        fi
    fi
fi

echo "$STATUS"
