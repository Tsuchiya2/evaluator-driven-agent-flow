---
description: Interactive setup for EDAF v1.0 Self-Adapting System / EDAF v1.0 自己適応型システムのインタラクティブセットアップ
---

# EDAF v1.0 - Interactive Setup (Optimized v3)

Welcome to EDAF (Evaluator-Driven Agent Flow) v1.0!

This setup uses an **Optimized Parallel Pattern** with:
- **Improved progress visibility** (v2)
- **Context exhaustion prevention** (v3)
- **Triple-layer directory creation** (v3)
- **True Fire & Forget monitoring** (v3)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  OPTIMIZED PARALLEL PATTERN v3                                  │
│  ══════════════════════════════                                 │
│                                                                 │
│  Phase 1: Configuration (~5 seconds)                            │
│    ├── Language selection                                       │
│    ├── Docker configuration                                     │
│    ├── CLAUDE.md generation                                     │
│    └── edaf-config.yml generation                               │
│                                                                 │
│  Phase 1.5: Directory Setup (NEW in v3)                         │
│    ├── Bash: mkdir -p docs                                      │
│    └── Bash: mkdir -p .claude/skills                            │
│                                                                 │
│  Phase 2: Agent Launch (TRUE Fire & Forget in v3)               │
│    ├── 6 documentation-worker agents (parallel)                 │
│    │   └── Each agent: mkdir -p docs (defensive)                │
│    └── N standards agents (parallel)                            │
│        └── Each agent: mkdir -p .claude/skills/{name}           │
│                                                                 │
│  Phase 3: Progress Monitoring (max 300s) - v3 FIXED             │
│    ├── Poll every 10 seconds with Bash stat -f%z               │
│    ├── NO TaskOutput calls (prevents context exhaustion)        │
│    ├── Display completed files IMMEDIATELY                      │
│    ├── Early exit when ALL complete                             │
│    └── Smart fallback for timed-out files                       │
│                                                                 │
│  Result: Complete in ~5 minutes with NO context exhaustion      │
└─────────────────────────────────────────────────────────────────┘
```

### Critical Fixes: v2 → v3

**v2 Problems** (what you encountered):
- ❌ TaskOutput usage → context exhaustion
- ❌ Pseudo-code directory creation → files not written
- ❌ Partial Fire & Forget → still monitored agents

**v3 Solutions**:
- ✅ Bash stat-based monitoring → no context exhaustion
- ✅ Triple-layer mkdir → guaranteed directory existence
- ✅ True Fire & Forget → no TaskOutput calls

| Aspect | v2 (Broken) | v3 (Fixed) |
|--------|-------------|------------|
| **Monitoring** | TaskOutput (context exhaustion) | **Bash stat -f%z (lightweight)** |
| **Directory Creation** | Pseudo-code only | **Bash + Agent-level (triple-layer)** |
| **Fire & Forget** | Partial (still used TaskOutput) | **TRUE (no TaskOutput)** |
| **Context Usage** | High (exhausts) | **Minimal (safe)** |
| **File Write Success** | Low (0% observed) | **High (guaranteed by triple-layer)** |

---

## Step 0: Check for Interrupted/Existing Setup

**Action**: Check if previous setup exists:

```typescript
const fs = require('fs')
const path = require('path')
const yaml = require('js-yaml')

if (fs.existsSync('.claude/edaf-config.yml')) {
  try {
    const config = yaml.load(fs.readFileSync('.claude/edaf-config.yml', 'utf-8'))

    if (config.setup_progress && config.setup_progress.status === 'in_progress') {
      console.log('\n⚠️  Previous setup was interrupted / 前回のセットアップが中断されています')

      const resumeResponse = await AskUserQuestion({
        questions: [{
          question: "Resume or restart? / 再開しますか？",
          header: "Resume",
          multiSelect: false,
          options: [
            { label: "Resume", description: "Continue from where it left off" },
            { label: "Restart", description: "Start fresh" }
          ]
        }]
      })

      if (resumeResponse.answers['0'].includes('Resume')) {
        // Jump to Phase 3 (monitoring)
        console.log('\n🔄 Resuming setup...')
        // Continue to Step 6 (Progress Monitoring)
      } else {
        delete config.setup_progress
        fs.writeFileSync('.claude/edaf-config.yml', yaml.dump(config))
      }
    } else if (!config.setup_progress) {
      // Already configured
      const reconfigResponse = await AskUserQuestion({
        questions: [{
          question: "EDAF is already configured. What would you like to do?",
          header: "Config",
          multiSelect: false,
          options: [
            { label: "Reconfigure", description: "Start fresh with new settings" },
            { label: "Keep current", description: "Exit without changes" }
          ]
        }]
      })

      if (reconfigResponse.answers['0'].includes('Keep')) {
        console.log('\n✅ Keeping current configuration.')
        return
      }
    }
  } catch (e) {
    // Invalid config, continue with fresh setup
  }
}
```

---

## Step 1: Language Preferences

**Action**: Select language preference:

```typescript
const langResponse = await AskUserQuestion({
  questions: [{
    question: "Select your language preference for EDAF / EDAFの言語設定を選択してください",
    header: "Language",
    multiSelect: false,
    options: [
      { label: "EN docs + EN output", description: "Documentation and terminal output in English" },
      { label: "JA docs + JA output", description: "ドキュメントとターミナル出力を日本語で" },
      { label: "EN docs + JA output", description: "Documentation in English, terminal in Japanese" }
    ]
  }]
})

const selected = langResponse.answers['0']
const docLang = selected.includes('JA docs') ? 'ja' : 'en'
const termLang = selected.includes('JA output') ? 'ja' : 'en'

console.log(`\n✅ Language: ${docLang === 'en' ? 'English' : 'Japanese'} docs, ${termLang === 'en' ? 'English' : 'Japanese'} output`)
```

---

## Step 2: Verify Installation

**Action**: Check for installed EDAF components:

```typescript
const checks = {
  workers: fs.existsSync('.claude/agents/workers/database-worker-v1-self-adapting.md'),
  evaluators: fs.existsSync('.claude/agents/evaluators/phase5-code/code-quality-evaluator-v1-self-adapting.md'),
  setupCommand: fs.existsSync('.claude/commands/setup.md')
}

console.log('\n📋 Installation Status:')
console.log(`   Workers: ${checks.workers ? '✅' : '❌'}`)
console.log(`   Evaluators: ${checks.evaluators ? '✅' : '❌'}`)
console.log(`   /setup: ${checks.setupCommand ? '✅' : '❌'}`)

if (!checks.workers || !checks.evaluators) {
  console.log('\n⚠️  Missing components. Run: bash evaluator-driven-agent-flow/scripts/install.sh')
}
```

---

## Step 3: Project Analysis & Docker Configuration

**Action**: Analyze project and configure Docker:

```typescript
// ═══════════════════════════════════════════════════════════════
// PROJECT ANALYSIS - Extract information for smart fallbacks
// ═══════════════════════════════════════════════════════════════

const projectInfo = {
  type: 'unknown',
  name: 'project',
  language: '',
  frameworks: [],
  testFramework: '',
  linter: '',
  packageManager: '',
  directories: []
}

// Analyze package.json
if (fs.existsSync('package.json')) {
  const pkg = JSON.parse(fs.readFileSync('package.json', 'utf-8'))
  const deps = { ...pkg.dependencies, ...pkg.devDependencies }

  projectInfo.type = 'node'
  projectInfo.name = pkg.name || 'node-project'
  projectInfo.language = deps.typescript ? 'TypeScript' : 'JavaScript'

  if (deps.react) projectInfo.frameworks.push('React')
  if (deps.next) projectInfo.frameworks.push('Next.js')
  if (deps.vue) projectInfo.frameworks.push('Vue')
  if (deps.express) projectInfo.frameworks.push('Express')
  if (deps['@nestjs/core']) projectInfo.frameworks.push('NestJS')

  if (deps.vitest) projectInfo.testFramework = 'Vitest'
  else if (deps.jest) projectInfo.testFramework = 'Jest'

  if (deps.eslint) projectInfo.linter = 'ESLint'
  if (deps.biome || deps['@biomejs/biome']) projectInfo.linter = 'Biome'

  if (fs.existsSync('pnpm-lock.yaml')) projectInfo.packageManager = 'pnpm'
  else if (fs.existsSync('yarn.lock')) projectInfo.packageManager = 'yarn'
  else projectInfo.packageManager = 'npm'

  console.log(`\n📦 Detected: ${projectInfo.language} Project`)
  console.log(`   Name: ${projectInfo.name}`)
  if (projectInfo.frameworks.length) console.log(`   Frameworks: ${projectInfo.frameworks.join(', ')}`)
}

// Analyze go.mod
if (fs.existsSync('go.mod')) {
  const goMod = fs.readFileSync('go.mod', 'utf-8')
  const moduleMatch = goMod.match(/module\s+(.+)/)

  projectInfo.type = 'go'
  projectInfo.language = 'Go'
  projectInfo.name = moduleMatch ? moduleMatch[1].split('/').pop() : 'go-project'
  projectInfo.testFramework = 'go test'
  projectInfo.linter = 'golangci-lint'

  if (goMod.includes('gin-gonic/gin')) projectInfo.frameworks.push('Gin')
  if (goMod.includes('labstack/echo')) projectInfo.frameworks.push('Echo')
  if (goMod.includes('jackc/pgx')) projectInfo.frameworks.push('pgx')

  console.log(`\n🔵 Detected: Go Project`)
  console.log(`   Module: ${projectInfo.name}`)
  if (projectInfo.frameworks.length) console.log(`   Libraries: ${projectInfo.frameworks.join(', ')}`)
}

// Analyze Python
if (fs.existsSync('pyproject.toml') || fs.existsSync('requirements.txt')) {
  projectInfo.type = 'python'
  projectInfo.language = 'Python'
  projectInfo.name = 'python-project'
  projectInfo.testFramework = 'pytest'

  console.log(`\n🐍 Detected: Python Project`)
}

// Get directory structure
try {
  const { execSync } = require('child_process')
  const dirs = execSync('ls -d */ 2>/dev/null | head -10', { encoding: 'utf-8' })
    .trim().split('\n').filter(d => d && !d.startsWith('.') && !d.includes('node_modules'))
  projectInfo.directories = dirs.map(d => d.replace('/', ''))
} catch (e) {}

// ═══════════════════════════════════════════════════════════════
// DOCKER CONFIGURATION
// ═══════════════════════════════════════════════════════════════

const composeFiles = ['compose.yml', 'compose.yaml', 'docker-compose.yml', 'docker-compose.yaml']
const composeFile = composeFiles.find(f => fs.existsSync(f))
let dockerConfig = { enabled: false }

if (composeFile) {
  console.log(`\n🐳 Docker Compose: ${composeFile}`)

  const compose = fs.readFileSync(composeFile, 'utf-8')
  const serviceMatches = compose.match(/^  (\w+):/gm)
  const services = serviceMatches ? serviceMatches.map(s => s.trim().replace(':', '')) : []

  const dockerResponse = await AskUserQuestion({
    questions: [{
      question: termLang === 'ja' ? "コマンド実行方法を選択" : "How should commands be executed?",
      header: "Docker",
      multiSelect: false,
      options: [
        { label: "Docker container (Recommended)", description: "Execute via docker compose exec" },
        { label: "Local machine", description: "Execute on host directly" }
      ]
    }]
  })

  if (dockerResponse.answers['0'].includes('Docker')) {
    let selectedService = services[0]

    if (services.length > 1) {
      const serviceResponse = await AskUserQuestion({
        questions: [{
          question: termLang === 'ja' ? "実行サービスを選択" : "Select service",
          header: "Service",
          multiSelect: false,
          options: services.slice(0, 4).map(s => ({ label: s, description: `Execute in '${s}'` }))
        }]
      })
      selectedService = serviceResponse.answers['0']
    }

    dockerConfig = {
      enabled: true,
      compose_file: composeFile,
      main_service: selectedService,
      exec_prefix: `docker compose exec ${selectedService}`
    }
    console.log(`   Execution: ${dockerConfig.exec_prefix}`)
  }
}
```

---

## Step 4: Generate Configuration Files

**Action**: Generate CLAUDE.md and edaf-config.yml:

```typescript
// ═══════════════════════════════════════════════════════════════
// GENERATE CLAUDE.md
// ═══════════════════════════════════════════════════════════════

const claudeMd = `# EDAF v1.0 - Claude Code Configuration

## Language Preferences

This file is auto-generated by \`/setup\` command.
Do not edit manually - run \`/setup\` again to change preferences.

**Current Settings:**

- **Documentation Language**: ${docLang === 'en' ? 'English' : 'Japanese'}
- **Terminal Output Language**: ${termLang === 'en' ? 'English' : 'Japanese'}
- **Save Dual Language Docs**: No

---

## EDAF 7-Phase Gate System

**When implementing features, fixing bugs, or making changes, automatically follow this workflow:**

> Triggered by natural language requests for implementation work (no need to say "EDAF")
> Detailed workflows: \`.claude/skills/edaf-orchestration/PHASE{1-7}-*.md\`

### Quick Reference

| Phase | Agent | Evaluators | Pass Criteria |
|-------|-------|------------|---------------|
| 1. Requirements | requirements-gatherer | 7 | All ≥ 8.0/10 |
| 2. Design | designer | 7 | All ≥ 8.0/10 |
| 3. Planning | planner | 7 | All ≥ 8.0/10 |
| 4. Implementation | 4 workers | 1 quality-gate | 10.0 (lint+tests) |
| 5. Code Review | - | 7 + UI | All ≥ 8.0/10 |
| 6. Documentation | documentation-worker | 5 | All ≥ 8.0/10 |
| 7. Deployment | - | 5 | All ≥ 8.0/10 |

---

### EDAF Execution Pattern

**For each phase**:

1. **Execute** → Run agent/worker to generate artifact
2. **Evaluate** → Run ALL evaluators in parallel (use Task tool)
3. **Check** results:
   - ✅ **ALL pass (≥ threshold)** → Proceed to next phase
   - ❌ **ANY fail (< threshold)** → Feedback loop:
     1. Read evaluator reports for specific feedback
     2. Revise artifact based on feedback
     3. Re-run ALL evaluators (not just failed ones)
     4. Repeat until ALL pass (unlimited iterations)

**This feedback loop is EDAF's core quality mechanism.**

**Artifacts by Phase**:
- Phase 1: \`.steering/{date}-{feature}/idea.md\` (requirements)
- Phase 2: \`.steering/{date}-{feature}/design.md\` (technical design)
- Phase 3: \`.steering/{date}-{feature}/tasks.md\` (task plan)
- Phase 4: Source code (implementation)
- Phase 5: \`.steering/{date}-{feature}/reports/\` (evaluation reports)
- Phase 6: \`docs/\` (permanent documentation updates)
- Phase 7: Deployment configs

**Permanent Documentation** (\`docs/\`):
- \`product-requirements.md\`, \`functional-design.md\`, \`development-guidelines.md\`
- \`repository-structure.md\`, \`architecture.md\`, \`glossary.md\`

---

## Critical Rules

1. **NEVER skip phases**
2. **ALWAYS run evaluators in parallel** (use Task tool)
3. **ALWAYS iterate until ALL evaluators pass** (no exceptions)
4. **IF any evaluator fails**:
   - Read evaluator report for specific feedback
   - Revise artifact based on feedback
   - Re-run ALL evaluators (not just failed ones)
   - Repeat until ALL pass (unlimited iterations)
5. **Phase 1 is mandatory** for new features (requirements gathering)
6. **Phase 4 quality-gate is ultra-strict** (10.0 = zero lint errors/warnings + all tests pass)
7. **UI verification required** if frontend modified (Phase 5)

---

## Component Discovery

**All components are auto-discovered from file system. No manual listing needed.**

**Locations**:
- **Agents**: \`.claude/agents/*.md\` + \`.claude/agents/workers/*.md\`
- **Evaluators**: \`.claude/agents/evaluators/phase{1-7}-*/*.md\`
- **Skills**: \`.claude/skills/*/SKILL.md\` (coding standards, workflows)
- **Commands**: \`.claude/commands/*.md\` (e.g., \`/review-standards\`)
- **Config**: \`.claude/edaf-config.yml\`, \`.claude/agent-models.yml\`

**Component Count**:
- 9 Agents (requirements-gatherer, designer, planner, 4 workers, documentation-worker, ui-verification-worker)
- 39 Evaluators (7 per phase for phases 1-3,5,6; 1 for phase 4; 5 for phase 7)
- Total: 48 components

---

## Instructions for Claude Code

### Terminal Output Language
Respond in **${termLang === 'en' ? 'ENGLISH' : 'JAPANESE'}** for all output.

### Documentation Language
Generate documentation in **${docLang === 'en' ? 'ENGLISH' : 'JAPANESE'}**.

### Agent Behavior
- **Workers**: Follow project coding standards in \`.claude/skills/\`
- **Evaluators**: Output in terminal language, generate reports in documentation language
- **All agents**: Read detailed phase instructions in \`.claude/skills/edaf-orchestration/\`

### Setup
For initial project setup, see README.md for \`/setup\` command instructions.

---

**Last Updated**: Auto-generated by \`/setup\` command
**Configuration**: \`.claude/edaf-config.yml\`
`

fs.mkdirSync('.claude', { recursive: true })
fs.writeFileSync('.claude/CLAUDE.md', claudeMd)
console.log('\n✅ CLAUDE.md generated')

// Define expected files
const expectedDocs = [
  'docs/product-requirements.md',
  'docs/functional-design.md',
  'docs/development-guidelines.md',
  'docs/repository-structure.md',
  'docs/architecture.md',
  'docs/glossary.md'
]

// Determine which standards to create
let expectedSkills = []
if (projectInfo.type === 'node') {
  expectedSkills.push('.claude/skills/typescript-standards/SKILL.md')
  if (projectInfo.frameworks.some(f => ['React', 'Next.js', 'Vue'].includes(f))) {
    expectedSkills.push('.claude/skills/react-standards/SKILL.md')
  }
}
if (projectInfo.type === 'go') {
  expectedSkills.push('.claude/skills/go-standards/SKILL.md')
}
if (projectInfo.type === 'python') {
  expectedSkills.push('.claude/skills/python-standards/SKILL.md')
}
if (projectInfo.testFramework) {
  expectedSkills.push('.claude/skills/test-standards/SKILL.md')
}
expectedSkills.push('.claude/skills/security-standards/SKILL.md')

// Save config with progress tracking
const config = {
  language_preferences: {
    documentation_language: docLang,
    terminal_output_language: termLang,
    save_dual_language_docs: false
  },
  docker: dockerConfig,
  project: {
    type: projectInfo.type,
    name: projectInfo.name,
    language: projectInfo.language,
    frameworks: projectInfo.frameworks
  },
  setup_progress: {
    status: 'in_progress',
    started_at: new Date().toISOString(),
    expected_docs: expectedDocs,
    expected_skills: expectedSkills
  }
}

fs.writeFileSync('.claude/edaf-config.yml', yaml.dump(config))
console.log('✅ edaf-config.yml generated')
```

---

## Step 5: Launch Agents (Fire & Forget)

**Action**: Launch all agents in parallel:

```typescript
// ═══════════════════════════════════════════════════════════════
// CRITICAL: Create directories BEFORE launching agents
// ═══════════════════════════════════════════════════════════════

// Use Bash tool to create directories (NOT pseudo-code)
await Bash({
  command: 'mkdir -p docs .claude/skills',
  description: 'Create docs and skills directories'
})

console.log('\n🚀 Launching agents (Fire & Forget)...\n')

// ═══════════════════════════════════════════════════════════════
// LAUNCH DOCUMENTATION AGENTS (1 agent = 1 file)
// ═══════════════════════════════════════════════════════════════

const docDefinitions = [
  { file: 'product-requirements.md', focus: 'Product vision, user personas, user stories, acceptance criteria' },
  { file: 'functional-design.md', focus: 'Feature specifications, API design, data models, business logic' },
  { file: 'development-guidelines.md', focus: 'Coding conventions, workflow, best practices, git workflow' },
  { file: 'repository-structure.md', focus: 'Directory organization, file purposes, module responsibilities' },
  { file: 'architecture.md', focus: 'System architecture, components, technical decisions, diagrams' },
  { file: 'glossary.md', focus: 'Domain terms, technical terminology, acronyms, entity definitions' }
]

console.log('   📄 Documentation agents:')
for (const doc of docDefinitions) {
  await Task({
    subagent_type: 'documentation-worker',
    model: 'sonnet',
    run_in_background: true,
    description: `Generate ${doc.file}`,
    prompt: `Generate ONLY: docs/${doc.file}

**Focus**: ${doc.focus}

**Instructions**:
1. FIRST: Ensure directory exists with Bash: mkdir -p docs
2. Use Glob to find relevant source files
3. Use Read to analyze actual code patterns
4. Extract real information from the codebase
5. Generate comprehensive documentation
6. Write to: docs/${doc.file}

**Language**: ${docLang === 'en' ? 'English' : 'Japanese'}

**CRITICAL**:
- Create docs/ directory BEFORE writing (Step 1 above)
- Do DEEP CODE ANALYSIS. Read actual source files, not just config files.

**OUTPUT**: Write ONLY docs/${doc.file}`
  })
  console.log(`      - ${doc.file}`)
}

// ═══════════════════════════════════════════════════════════════
// LAUNCH STANDARDS AGENTS (1 agent = 1 skill)
// ═══════════════════════════════════════════════════════════════

console.log('   📖 Standards agents:')
for (const skillPath of expectedSkills) {
  const skillName = skillPath.split('/')[2]

  // Create skill directory using Bash tool
  await Bash({
    command: `mkdir -p .claude/skills/${skillName}`,
    description: `Create ${skillName} directory`
  })

  await Task({
    subagent_type: 'general-purpose',
    model: 'sonnet',
    run_in_background: true,
    description: `Generate ${skillName}`,
    prompt: `Generate coding standards: ${skillPath}

**Instructions**:
1. FIRST: Ensure directory exists with Bash: mkdir -p $(dirname ${skillPath})
2. Use Glob and Read to analyze existing code
3. Extract ACTUAL patterns (naming, structure, error handling)
4. Create SKILL.md with rules based on real code
5. Include concrete examples from the codebase
6. Add enforcement checklist

**CRITICAL**: Create parent directory BEFORE writing file
**OUTPUT**: Write ${skillPath}`
  })
  console.log(`      - ${skillName}/SKILL.md`)
}

console.log('\n   ✅ All agents launched')
```

---

## Step 6: Progress Monitoring (Optimized)

**Action**: Monitor progress with improved visibility:

```typescript
// ═══════════════════════════════════════════════════════════════
// PROGRESS MONITORING - 10s interval, 300s max, immediate display
// ═══════════════════════════════════════════════════════════════
//
// CRITICAL RULES:
// 1. DO NOT use TaskOutput tool - it causes context exhaustion
// 2. Use ONLY file existence checks (Bash tool with test -f)
// 3. Agents are Fire & Forget - don't wait for their completion
// 4. Report files as they appear in filesystem
// ═══════════════════════════════════════════════════════════════

console.log('\n⏳ Monitoring progress (10s interval, max 300s)...\n')

const POLL_INTERVAL = 10000  // 10 seconds (improved from 30)
const MAX_TIMEOUT = 300000   // 300 seconds (improved from 600)
const startTime = Date.now()

// Track which files we've already reported
const reportedFiles = new Set()

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

// Helper to check file using Bash (NOT fs.existsSync - use actual Bash tool)
async function checkAndReport(filePath, type) {
  if (reportedFiles.has(filePath)) return false

  // Use Bash tool to check file existence and size
  const sizeCheck = await Bash({
    command: `test -f ${filePath} && stat -f%z ${filePath} 2>/dev/null || echo 0`,
    description: `Check ${filePath} size`
  })

  const size = parseInt(sizeCheck.trim())
  if (size > 100) {
    reportedFiles.add(filePath)
    const elapsed = Math.floor((Date.now() - startTime) / 1000)
    const name = type === 'doc' ? path.basename(filePath) : filePath.split('/')[2] + '/SKILL.md'
    console.log(`   [${elapsed}s] ✅ ${name} (${size} bytes)`)
    return true
  }
  return false
}

// Main polling loop
while (Date.now() - startTime < MAX_TIMEOUT) {
  // Check all expected files
  for (const doc of expectedDocs) {
    await checkAndReport(doc, 'doc')
  }
  for (const skill of expectedSkills) {
    await checkAndReport(skill, 'skill')
  }

  // Check if all complete
  const allDocs = expectedDocs.every(d => reportedFiles.has(d))
  const allSkills = expectedSkills.every(s => reportedFiles.has(s))

  if (allDocs && allSkills) {
    console.log('\n   🎉 All files generated successfully!')
    break
  }

  await sleep(POLL_INTERVAL)
}

// Show timeout message if not all complete
const remainingDocs = expectedDocs.filter(d => !reportedFiles.has(d))
const remainingSkills = expectedSkills.filter(s => !reportedFiles.has(s))

if (remainingDocs.length > 0 || remainingSkills.length > 0) {
  console.log('\n   ⏱️  Timeout reached. Generating smart fallbacks for remaining files...')
}
```

---

## Step 7: Smart Fallback Generation

**Action**: Generate project-specific fallbacks for incomplete files:

```typescript
// ═══════════════════════════════════════════════════════════════
// SMART FALLBACK - Uses projectInfo for project-specific content
// ═══════════════════════════════════════════════════════════════

// Fallback for documentation files
for (const docPath of remainingDocs) {
  const fileName = path.basename(docPath)
  let content = ''

  switch(fileName) {
    case 'product-requirements.md':
      content = `# Product Requirements

## Product Overview

**Project**: ${projectInfo.name}
**Tech Stack**: ${projectInfo.language}${projectInfo.frameworks.length ? ` with ${projectInfo.frameworks.join(', ')}` : ''}

## Vision

<!-- Define the product vision -->

## Target Users

<!-- Define user personas -->

## User Stories

<!-- Add user stories -->

## Non-Functional Requirements

### Performance
- Response time: < 200ms

### Security
- Authentication required

---
*Smart fallback - Run /review-standards to enhance with code analysis*
`
      break

    case 'functional-design.md':
      content = `# Functional Design

## System Overview

**Project**: ${projectInfo.name}
**Architecture**: ${projectInfo.language} Application
${projectInfo.frameworks.length ? `**Frameworks**: ${projectInfo.frameworks.join(', ')}` : ''}

## Feature Specifications

<!-- Add feature specs -->

## API Design

<!-- Add API endpoints -->

## Data Models

<!-- Add data models -->

---
*Smart fallback - Run /review-standards to enhance with code analysis*
`
      break

    case 'development-guidelines.md':
      content = `# Development Guidelines

## Tech Stack

| Category | Technology |
|----------|------------|
| Language | ${projectInfo.language} |
${projectInfo.frameworks.length ? `| Frameworks | ${projectInfo.frameworks.join(', ')} |` : ''}
| Testing | ${projectInfo.testFramework || 'Not detected'} |
| Linting | ${projectInfo.linter || 'Not detected'} |
${projectInfo.packageManager ? `| Package Manager | ${projectInfo.packageManager} |` : ''}

## Code Style

<!-- Add code style guidelines -->

## Git Workflow

- Branch: \`feat/\`, \`fix/\`, \`refactor/\`
- Commits: Conventional commits

${dockerConfig.enabled ? `
## Docker

\`\`\`bash
${dockerConfig.exec_prefix} [command]
\`\`\`
` : ''}

---
*Smart fallback - Run /review-standards to enhance with code analysis*
`
      break

    case 'repository-structure.md':
      content = `# Repository Structure

## Directory Layout

\`\`\`
${projectInfo.name}/
${projectInfo.directories.map(d => `├── ${d}/`).join('\n')}
├── docs/
└── .claude/
\`\`\`

## Key Files

<!-- Add file descriptions -->

---
*Smart fallback - Run /review-standards to enhance with code analysis*
`
      break

    case 'architecture.md':
      content = `# Architecture

## System Overview

**Project**: ${projectInfo.name}
**Language**: ${projectInfo.language}
${projectInfo.frameworks.length ? `**Frameworks**: ${projectInfo.frameworks.join(', ')}` : ''}

## Components

<!-- Add component descriptions -->

## Technical Decisions

<!-- Add architectural decisions -->

---
*Smart fallback - Run /review-standards to enhance with code analysis*
`
      break

    case 'glossary.md':
      content = `# Glossary

## Domain Terms

| Term | Definition |
|------|------------|
| <!-- term --> | <!-- definition --> |

## Technical Terms

| Term | Definition |
|------|------------|
${projectInfo.language ? `| ${projectInfo.language} | Programming language used |` : ''}
${projectInfo.frameworks.map(f => `| ${f} | Framework |`).join('\n')}
| EDAF | Evaluator-Driven Agent Flow |

---
*Smart fallback - Run /review-standards to enhance with code analysis*
`
      break
  }

  fs.writeFileSync(docPath, content)
  console.log(`   📄 ${fileName} (smart fallback)`)
}

// Fallback for skills
for (const skillPath of remainingSkills) {
  const skillName = skillPath.split('/')[2]
  let content = `# ${skillName.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')}

## Overview

Standards for ${projectInfo.name} (${projectInfo.language}).

## Naming Conventions

<!-- Add naming conventions -->

## Best Practices

<!-- Add best practices -->

## Enforcement Checklist

- [ ] Follow naming conventions
- [ ] Apply best practices
- [ ] Pass linting

---
*Smart fallback - Run /review-standards to regenerate from code analysis*
`

  fs.mkdirSync(path.dirname(skillPath), { recursive: true })
  fs.writeFileSync(skillPath, content)
  console.log(`   📖 ${skillName}/SKILL.md (smart fallback)`)
}
```

---

## Step 8: Cleanup and Completion

**Action**: Remove progress tracking and show summary:

```typescript
// ═══════════════════════════════════════════════════════════════
// CLEANUP AND COMPLETION
// ═══════════════════════════════════════════════════════════════

// Remove setup_progress from config
const finalConfig = yaml.load(fs.readFileSync('.claude/edaf-config.yml', 'utf-8'))
delete finalConfig.setup_progress
fs.writeFileSync('.claude/edaf-config.yml', yaml.dump(finalConfig))

// Calculate stats
const agentGenerated = reportedFiles.size
const fallbackGenerated = remainingDocs.length + remainingSkills.length
const totalFiles = expectedDocs.length + expectedSkills.length
const elapsedSeconds = Math.floor((Date.now() - startTime) / 1000)

// Final summary
console.log('\n' + '═'.repeat(60))
console.log('  EDAF v1.0 Setup Complete!')
console.log('═'.repeat(60))

console.log('\n📁 Generated Files:')
console.log('   docs/')
for (const doc of expectedDocs) {
  const name = path.basename(doc)
  const isAgent = reportedFiles.has(doc)
  console.log(`     ${isAgent ? '✅' : '📄'} ${name} ${isAgent ? '(agent)' : '(fallback)'}`)
}

console.log('   .claude/skills/')
for (const skill of expectedSkills) {
  const name = skill.split('/')[2]
  const isAgent = reportedFiles.has(skill)
  console.log(`     ${isAgent ? '✅' : '📖'} ${name}/SKILL.md ${isAgent ? '(agent)' : '(fallback)'}`)
}

console.log('   .claude/')
console.log('     ✅ CLAUDE.md')
console.log('     ✅ edaf-config.yml')

console.log('\n📊 Statistics:')
console.log(`   Agent-generated: ${agentGenerated}/${totalFiles}`)
console.log(`   Fallback: ${fallbackGenerated}/${totalFiles}`)
console.log(`   Time: ${elapsedSeconds}s`)

console.log('\n📋 Configuration:')
console.log(`   Language: ${docLang === 'en' ? 'English' : 'Japanese'} docs, ${termLang === 'en' ? 'English' : 'Japanese'} output`)
console.log(`   Docker: ${dockerConfig.enabled ? 'Enabled (' + dockerConfig.main_service + ')' : 'Disabled'}`)

if (fallbackGenerated > 0) {
  console.log('\n💡 To enhance fallback files:')
  console.log('   Run /review-standards to regenerate with deep code analysis')
}

console.log('\n🚀 Next Steps:')
console.log('   1. Start implementing features with EDAF 7-phase workflow')
console.log('   2. Run /review-standards anytime to update coding standards')

console.log('\n' + '═'.repeat(60))
```

---

## Summary

This optimized `/setup` v3 includes:

### Key Improvements from v2 → v3 (Context Exhaustion Fix)

**Problem**: v2 suffered from context exhaustion due to TaskOutput usage, causing:
- Incomplete progress monitoring
- Missing file generation
- Setup terminating prematurely

**Solution**: Triple-layer defensive strategy

| Issue | v2 (Broken) | v3 (Fixed) |
|-------|-------------|------------|
| Progress Monitoring | Used TaskOutput (context exhaustion) | **File existence checks only (Bash)** |
| Directory Creation | Pseudo-code only | **Explicit Bash + Agent-level creation** |
| Monitoring Method | TaskOutput polling | **stat -f%z file size check** |
| Fire & Forget | Partial (still used TaskOutput) | **True Fire & Forget** |

### What Changed: v2 → v3

| Aspect | v2 (Broken) | v3 (Fixed) |
|--------|-------------|------------|
| Monitoring | TaskOutput | **Bash stat -f%z** |
| Directory Creation | Pseudo-code | **Bash + Agent-level** |
| Fire & Forget | Partial | **TRUE (no TaskOutput)** |
| Context Safety | ❌ Exhausts | **✅ Safe** |

### Architecture v3

```
┌────────────────────────────────────────────────────────────────┐
│  Configuration (5s)                                            │
│  ├── CLAUDE.md generation                                      │
│  └── edaf-config.yml generation                                │
├────────────────────────────────────────────────────────────────┤
│  Directory Setup (NEW in v3)                                   │
│  ├── Bash: mkdir -p docs                                       │
│  └── Bash: mkdir -p .claude/skills                             │
├────────────────────────────────────────────────────────────────┤
│  Agent Launch (TRUE Fire & Forget in v3)                       │
│  ├── 6 documentation-worker agents (each runs mkdir -p docs)   │
│  └── N standards agents (each runs mkdir -p for its skill)     │
│  └── NO TaskOutput calls (v3 fix)                              │
├────────────────────────────────────────────────────────────────┤
│  Progress Monitoring (max 300s) - v3 FIXED                     │
│  ├── Poll every 10s with Bash: stat -f%z FILE                  │
│  ├── NO TaskOutput usage (prevents context exhaustion)         │
│  ├── Display completed files IMMEDIATELY                       │
│  ├── [10s] ✅ glossary.md (5234 bytes)                         │
│  ├── [20s] ✅ functional-design.md (8921 bytes)                │
│  ├── [30s] ✅ test-standards/SKILL.md (3104 bytes)             │
│  └── ... (each file as it completes)                           │
├────────────────────────────────────────────────────────────────┤
│  Smart Fallback (if timeout)                                   │
│  └── Project-specific content using projectInfo                │
├────────────────────────────────────────────────────────────────┤
│  Completion                                                    │
│  └── Summary with agent vs fallback breakdown                  │
└────────────────────────────────────────────────────────────────┘
```

### v3 Critical Fixes

**Triple-layer defensive strategy** to prevent file write errors:

1. **Setup-level**: Bash `mkdir -p docs .claude/skills` before launching agents
2. **Agent-level**: Each agent runs `mkdir -p` for its target directory
3. **Monitoring-level**: Use Bash `stat -f%z` instead of TaskOutput

**Context Exhaustion Prevention**:
- **NO TaskOutput calls** during monitoring
- Use only lightweight Bash file checks
- True Fire & Forget (agents run independently)

### Preserved Features

- **Agent-based deep code analysis** (generality maintained)
- **Parallel execution** (efficiency)
- **TRUE Fire & Forget pattern** (v3: no context exhaustion)
- **1 Agent = 1 File** (scalability)

### User Experience: What v3 Fixes

- **No more context exhaustion** - Setup completes without "Context low" errors
- **Files actually get created** - Triple-layer mkdir ensures success
- **Real-time progress** - See each file as it completes (preserved from v2)
- **Reliable monitoring** - Lightweight Bash checks instead of heavy TaskOutput
- **True Fire & Forget** - Agents run independently, no monitoring overhead
