#!/bin/bash

# EDAF v1.0 - UI Verification Script
# Validates that UI verification was completed properly

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if session directory is provided
if [ -z "$1" ]; then
  echo -e "${RED}❌ Error: Session directory required${NC}"
  echo ""
  echo "Usage: bash .claude/scripts/verify-ui.sh <session-directory>"
  echo "Example: bash .claude/scripts/verify-ui.sh .steering/2026-01-01-user-authentication"
  exit 1
fi

SESSION_DIR=$1
SCREENSHOT_DIR="$SESSION_DIR/screenshots"
REPORT_FILE="$SESSION_DIR/reports/phase5-ui-verification.md"

echo -e "${BLUE}🔍 EDAF UI Verification Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Session:${NC} $SESSION_DIR"
echo ""

# Track validation status
VALIDATION_PASSED=true

# 1. Check screenshot directory exists
echo -e "${BLUE}📂 Checking screenshot directory...${NC}"
if [ ! -d "$SCREENSHOT_DIR" ]; then
  echo -e "${RED}   ❌ Screenshot directory not found: $SCREENSHOT_DIR${NC}"
  VALIDATION_PASSED=false
else
  echo -e "${GREEN}   ✅ Screenshot directory exists${NC}"

  # Count screenshots
  SCREENSHOT_COUNT=$(find "$SCREENSHOT_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | wc -l | tr -d ' ')
  echo -e "${BLUE}   📸 Screenshots found: $SCREENSHOT_COUNT${NC}"

  if [ "$SCREENSHOT_COUNT" -lt 1 ]; then
    echo -e "${RED}   ❌ At least 1 screenshot required${NC}"
    VALIDATION_PASSED=false
  else
    echo -e "${GREEN}   ✅ Screenshot count: $SCREENSHOT_COUNT${NC}"

    # List screenshots
    echo -e "${BLUE}   Screenshots:${NC}"
    find "$SCREENSHOT_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" | while read screenshot; do
      echo -e "${BLUE}     - $(basename "$screenshot")${NC}"
    done
  fi
fi

echo ""

# 2. Check verification report exists
echo -e "${BLUE}📄 Checking verification report...${NC}"
if [ ! -f "$REPORT_FILE" ]; then
  echo -e "${RED}   ❌ Verification report not found: $REPORT_FILE${NC}"
  VALIDATION_PASSED=false
else
  echo -e "${GREEN}   ✅ Verification report exists${NC}"

  # Check report content
  REPORT_LINE_COUNT=$(wc -l < "$REPORT_FILE" | tr -d ' ')
  echo -e "${BLUE}   📝 Report size: $REPORT_LINE_COUNT lines${NC}"

  if [ "$REPORT_LINE_COUNT" -lt 10 ]; then
    echo -e "${YELLOW}   ⚠️  Report seems too short (less than 10 lines)${NC}"
    VALIDATION_PASSED=false
  fi

  # Check if report references screenshots
  SCREENSHOT_REFS=$(grep -c "\.png\|\.jpg\|\.jpeg" "$REPORT_FILE" || echo "0")
  echo -e "${BLUE}   🖼️  Screenshot references in report: $SCREENSHOT_REFS${NC}"

  if [ "$SCREENSHOT_REFS" -lt 1 ]; then
    echo -e "${YELLOW}   ⚠️  Report should reference at least 1 screenshot${NC}"
  fi
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Final result
if [ "$VALIDATION_PASSED" = true ]; then
  echo -e "${GREEN}✅ UI Verification PASSED${NC}"
  echo ""
  echo -e "${GREEN}All checks completed successfully!${NC}"
  echo -e "${BLUE}Report location: $REPORT_FILE${NC}"
  echo -e "${BLUE}Screenshots: $SCREENSHOT_DIR${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}❌ UI Verification FAILED${NC}"
  echo ""
  echo -e "${YELLOW}Please ensure:${NC}"
  echo -e "${YELLOW}  1. Screenshot directory exists: $SCREENSHOT_DIR${NC}"
  echo -e "${YELLOW}  2. At least 1 screenshot is saved${NC}"
  echo -e "${YELLOW}  3. Verification report exists: $REPORT_FILE${NC}"
  echo -e "${YELLOW}  4. Report contains meaningful content (10+ lines)${NC}"
  echo ""
  exit 1
fi
