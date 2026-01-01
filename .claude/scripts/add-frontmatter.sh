#!/bin/bash

# EDAF v1.0 - Add YAML Frontmatter to Agent Files
# This script adds the required YAML frontmatter to all agent and evaluator files
# for Claude Code to recognize them as custom agents.

set -e

CLAUDE_DIR=".claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
WORKERS_DIR="$AGENTS_DIR/workers"
EVALUATORS_DIR="$AGENTS_DIR/evaluators"

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 EDAF v1.0 - Adding YAML Frontmatter to Agents${NC}"
echo ""

# Function to add frontmatter to a file
add_frontmatter() {
  local file="$1"
  local name="$2"
  local description="$3"
  local tools="$4"

  # Check if file already has frontmatter
  if head -n 1 "$file" | grep -q "^---$"; then
    echo -e "${YELLOW}  ⚠️  Skipped: $name (already has frontmatter)${NC}"
    return
  fi

  # Create temporary file with frontmatter
  local temp_file="${file}.tmp"

  cat > "$temp_file" << EOF
---
name: $name
description: $description
tools: $tools
---

EOF

  # Append original content
  cat "$file" >> "$temp_file"

  # Replace original file
  mv "$temp_file" "$file"

  echo -e "${GREEN}  ✅ Added frontmatter: $name${NC}"
}

# Process Core Agents (Designer, Planner)
echo -e "${BLUE}📋 Processing Core Agents...${NC}"

if [ -f "$AGENTS_DIR/designer.md" ]; then
  add_frontmatter \
    "$AGENTS_DIR/designer.md" \
    "designer" \
    "Creates comprehensive design documents based on user requirements (Phase 2)" \
    "Read, Write, Grep, Glob"
fi

if [ -f "$AGENTS_DIR/planner.md" ]; then
  add_frontmatter \
    "$AGENTS_DIR/planner.md" \
    "planner" \
    "Breaks down design documents into specific, actionable implementation tasks (Phase 3)" \
    "Read, Write, Grep, Glob"
fi

echo ""

# Process Workers
echo -e "${BLUE}📋 Processing Workers...${NC}"

if [ -f "$WORKERS_DIR/database-worker-v1-self-adapting.md" ]; then
  add_frontmatter \
    "$WORKERS_DIR/database-worker-v1-self-adapting.md" \
    "database-worker-v1-self-adapting" \
    "Auto-detects ORM and generates database models, migrations, and schemas" \
    "Read, Write, Edit, Grep, Glob, Bash"
fi

if [ -f "$WORKERS_DIR/backend-worker-v1-self-adapting.md" ]; then
  add_frontmatter \
    "$WORKERS_DIR/backend-worker-v1-self-adapting.md" \
    "backend-worker-v1-self-adapting" \
    "Auto-detects framework and generates backend logic, APIs, and services" \
    "Read, Write, Edit, Grep, Glob, Bash"
fi

if [ -f "$WORKERS_DIR/frontend-worker-v1-self-adapting.md" ]; then
  add_frontmatter \
    "$WORKERS_DIR/frontend-worker-v1-self-adapting.md" \
    "frontend-worker-v1-self-adapting" \
    "Auto-detects UI framework and generates frontend components and styles" \
    "Read, Write, Edit, Grep, Glob, Bash"
fi

if [ -f "$WORKERS_DIR/test-worker-v1-self-adapting.md" ]; then
  add_frontmatter \
    "$WORKERS_DIR/test-worker-v1-self-adapting.md" \
    "test-worker-v1-self-adapting" \
    "Auto-detects testing framework and generates unit, integration, and E2E tests" \
    "Read, Write, Edit, Grep, Glob, Bash"
fi

echo ""

# Process Design Evaluators (Phase 2)
echo -e "${BLUE}📊 Processing Design Evaluators (Phase 2)...${NC}"

for evaluator in \
  "design-consistency-evaluator:Evaluates design document for consistency across sections" \
  "design-extensibility-evaluator:Evaluates design for future extensibility and flexibility" \
  "design-goal-alignment-evaluator:Evaluates design alignment with project goals and requirements" \
  "design-maintainability-evaluator:Evaluates design for long-term maintainability" \
  "design-observability-evaluator:Evaluates design for monitoring and observability capabilities" \
  "design-reliability-evaluator:Evaluates design for reliability and fault tolerance" \
  "design-reusability-evaluator:Evaluates design for component reusability and modularity"
do
  IFS=':' read -r name desc <<< "$evaluator"
  file="$EVALUATORS_DIR/phase1-design/${name}.md"

  if [ -f "$file" ]; then
    add_frontmatter \
      "$file" \
      "$name" \
      "$desc (Phase 2: Design Gate)" \
      "Read, Write, Grep, Glob"
  fi
done

echo ""

# Process Planner Evaluators (Phase 3)
echo -e "${BLUE}📊 Processing Planner Evaluators (Phase 3)...${NC}"

for evaluator in \
  "planner-clarity-evaluator:Evaluates task plan for clarity and understandability" \
  "planner-deliverable-structure-evaluator:Evaluates task plan deliverable structure and organization" \
  "planner-dependency-evaluator:Evaluates task dependencies and execution order" \
  "planner-goal-alignment-evaluator:Evaluates task plan alignment with design goals" \
  "planner-granularity-evaluator:Evaluates task breakdown granularity and scope" \
  "planner-responsibility-alignment-evaluator:Evaluates task-to-worker responsibility alignment" \
  "planner-reusability-evaluator:Evaluates task plan for reusable components and patterns"
do
  IFS=':' read -r name desc <<< "$evaluator"
  file="$EVALUATORS_DIR/phase2-planner/${name}.md"

  if [ -f "$file" ]; then
    add_frontmatter \
      "$file" \
      "$name" \
      "$desc (Phase 3: Planning Gate)" \
      "Read, Write, Grep, Glob"
  fi
done

echo ""

# Process Code Evaluators (Phase 5)
echo -e "${BLUE}📊 Processing Code Evaluators (Phase 5)...${NC}"

for evaluator in \
  "code-quality-evaluator-v1-self-adapting:Auto-detects linter/type checker and evaluates code quality" \
  "code-testing-evaluator-v1-self-adapting:Auto-detects test framework and evaluates test coverage/quality" \
  "code-security-evaluator-v1-self-adapting:Auto-detects security scanners and evaluates code security" \
  "code-documentation-evaluator-v1-self-adapting:Auto-detects doc style and evaluates code documentation" \
  "code-maintainability-evaluator-v1-self-adapting:Evaluates code maintainability and complexity" \
  "code-performance-evaluator-v1-self-adapting:Evaluates code performance and efficiency" \
  "code-implementation-alignment-evaluator-v1-self-adapting:Evaluates code alignment with design and requirements"
do
  IFS=':' read -r name desc <<< "$evaluator"
  file="$EVALUATORS_DIR/phase3-code/${name}.md"

  if [ -f "$file" ]; then
    add_frontmatter \
      "$file" \
      "$name" \
      "$desc (Phase 5: Code Review Gate)" \
      "Read, Write, Grep, Glob, Bash"
  fi
done

echo ""

# Process Deployment Evaluators (Phase 7)
echo -e "${BLUE}📊 Processing Deployment Evaluators (Phase 7)...${NC}"

for evaluator in \
  "deployment-readiness-evaluator:Evaluates deployment readiness and preparation" \
  "production-security-evaluator:Evaluates production security configuration and hardening" \
  "observability-evaluator:Evaluates monitoring, logging, and alerting setup" \
  "performance-benchmark-evaluator:Evaluates performance benchmarks and optimization" \
  "rollback-plan-evaluator:Evaluates rollback strategy and disaster recovery plan"
do
  IFS=':' read -r name desc <<< "$evaluator"
  file="$EVALUATORS_DIR/phase4-deployment/${name}.md"

  if [ -f "$file" ]; then
    add_frontmatter \
      "$file" \
      "$name" \
      "$desc (Phase 7: Deployment Gate)" \
      "Read, Write, Grep, Glob, Bash"
  fi
done

echo ""
echo -e "${GREEN}✅ Frontmatter injection complete!${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Restart Claude Code to load the updated agents${NC}"
echo -e "${YELLOW}⚠️  重要: 更新されたエージェントを読み込むためにClaude Codeを再起動してください${NC}"
echo ""
