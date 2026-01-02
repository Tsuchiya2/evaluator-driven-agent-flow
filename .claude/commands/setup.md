---
description: Interactive setup for EDAF v1.0 Self-Adapting System / EDAF v1.0 自己適応型システムのインタラクティブセットアップ
---

# EDAF v1.0 - Interactive Setup (Optimized v2)

Welcome to EDAF (Evaluator-Driven Agent Flow) v1.0!

This setup uses an **Optimized Parallel Pattern** with improved progress visibility and reliability.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  OPTIMIZED PARALLEL PATTERN                                     │
│  ══════════════════════════                                     │
│                                                                 │
│  Phase 1: Configuration (~5 seconds)                            │
│    ├── Language selection                                       │
│    ├── Docker configuration                                     │
│    ├── CLAUDE.md generation                                     │
│    └── edaf-config.yml generation                               │
│                                                                 │
│  Phase 2: Agent Launch (Fire & Forget)                          │
│    ├── 6 documentation-worker agents (parallel)                 │
│    └── N standards agents (parallel)                            │
│                                                                 │
│  Phase 3: Progress Monitoring (max 300s)                        │
│    ├── Poll every 10 seconds (not 30)                           │
│    ├── Display completed files IMMEDIATELY                      │
│    ├── Early exit when ALL complete                             │
│    └── Smart fallback for timed-out files                       │
│                                                                 │
│  Result: Complete in ~5 minutes with full visibility            │
└─────────────────────────────────────────────────────────────────┘
```

### Improvements Over v1

| Aspect | v1 (Broken) | v2 (Fixed) |
|--------|-------------|------------|
| Timeout | 600s (10 min) | 300s (5 min) |
| Poll Interval | 30s | 10s |
| Progress Display | File count only | Each file as completed |
| Fallback | Generic template | Smart (project-specific) |
| User Experience | Blind waiting | Real-time progress |

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
// Create directories
fs.mkdirSync('docs', { recursive: true })
fs.mkdirSync('.claude/skills', { recursive: true })

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
1. Use Glob to find relevant source files
2. Use Read to analyze actual code patterns
3. Extract real information from the codebase
4. Generate comprehensive documentation
5. Write to: docs/${doc.file}

**Language**: ${docLang === 'en' ? 'English' : 'Japanese'}

**CRITICAL**: Do DEEP CODE ANALYSIS. Read actual source files, not just config files.
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
  fs.mkdirSync(`.claude/skills/${skillName}`, { recursive: true })

  await Task({
    subagent_type: 'general-purpose',
    model: 'sonnet',
    run_in_background: true,
    description: `Generate ${skillName}`,
    prompt: `Generate coding standards: ${skillPath}

**Instructions**:
1. Use Glob and Read to analyze existing code
2. Extract ACTUAL patterns (naming, structure, error handling)
3. Create SKILL.md with rules based on real code
4. Include concrete examples from the codebase
5. Add enforcement checklist

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

console.log('\n⏳ Monitoring progress (10s interval, max 300s)...\n')

const POLL_INTERVAL = 10000  // 10 seconds (improved from 30)
const MAX_TIMEOUT = 300000   // 300 seconds (improved from 600)
const startTime = Date.now()

// Track which files we've already reported
const reportedFiles = new Set()

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

// Helper to check file and report if new
function checkAndReport(filePath, type) {
  if (reportedFiles.has(filePath)) return false

  if (fs.existsSync(filePath)) {
    const stats = fs.statSync(filePath)
    if (stats.size > 100) {
      reportedFiles.add(filePath)
      const elapsed = Math.floor((Date.now() - startTime) / 1000)
      const name = type === 'doc' ? path.basename(filePath) : filePath.split('/')[2] + '/SKILL.md'
      console.log(`   [${elapsed}s] ✅ ${name} (${stats.size} bytes)`)
      return true
    }
  }
  return false
}

// Main polling loop
while (Date.now() - startTime < MAX_TIMEOUT) {
  // Check all expected files
  for (const doc of expectedDocs) {
    checkAndReport(doc, 'doc')
  }
  for (const skill of expectedSkills) {
    checkAndReport(skill, 'skill')
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

This optimized `/setup` v2 includes:

### Key Improvements

| Aspect | v1 | v2 |
|--------|-----|-----|
| Timeout | 600s | **300s** |
| Poll Interval | 30s | **10s** |
| Progress | Count only | **Each file immediately** |
| Fallback | Generic | **Project-specific (smart)** |

### Architecture

```
┌────────────────────────────────────────────────────────────────┐
│  Configuration (5s)                                            │
│  └── CLAUDE.md + edaf-config.yml                               │
├────────────────────────────────────────────────────────────────┤
│  Agent Launch (Fire & Forget)                                  │
│  ├── 6 documentation-worker agents                             │
│  └── N standards agents                                        │
├────────────────────────────────────────────────────────────────┤
│  Progress Monitoring (max 300s)                                │
│  ├── Poll every 10s                                            │
│  ├── Display completed files IMMEDIATELY                       │
│  ├── [10s] ✅ glossary.md (agent)                              │
│  ├── [20s] ✅ functional-design.md (agent)                     │
│  ├── [30s] ✅ test-standards/SKILL.md (agent)                  │
│  └── ... (each file as it completes)                           │
├────────────────────────────────────────────────────────────────┤
│  Smart Fallback (if timeout)                                   │
│  └── Project-specific content using projectInfo                │
├────────────────────────────────────────────────────────────────┤
│  Completion                                                    │
│  └── Summary with agent vs fallback breakdown                  │
└────────────────────────────────────────────────────────────────┘
```

### Preserved Features

- **Agent-based deep code analysis** (generality maintained)
- **Parallel execution** (efficiency)
- **Fire & Forget pattern** (no context exhaustion)
- **1 Agent = 1 File** (scalability)

### User Experience Improvements

- **Real-time progress** - See files as they complete
- **Faster completion** - 5 min max vs 10 min
- **Better feedback** - Know exactly what happened
- **Smart fallbacks** - Project-specific, not generic
