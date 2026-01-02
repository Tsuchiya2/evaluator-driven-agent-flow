---
description: Interactive setup for EDAF v1.0 Self-Adapting System / EDAF v1.0 自己適応型システムのインタラクティブセットアップ
---

# EDAF v1.0 - Interactive Setup (Optimized)

Welcome to EDAF (Evaluator-Driven Agent Flow) v1.0!

This setup wizard uses an optimized **Fire & Forget** pattern to prevent context exhaustion.

---

## Architecture Overview

```
Phase 1: Interactive Setup (Main Agent)
    ├── Language selection
    ├── Project auto-detection
    ├── Docker configuration
    ├── CLAUDE.md generation
    └── edaf-config.yml generation (with setup_progress)

Phase 2: Fire & Forget (Background Agents) - SCALABLE 1:1 PATTERN
    ├── documentation-worker × 6 (one per doc file)
    │   ├── product-requirements.md
    │   ├── functional-design.md
    │   ├── development-guidelines.md
    │   ├── repository-structure.md
    │   ├── architecture.md
    │   └── glossary.md
    └── *-standards agents × N (one per skill)
    # NO TaskOutput - results not retrieved
    # Each agent generates exactly ONE file (scalable pattern)

Phase 3: Polling (Main Agent)
    └── Check file existence every 30s (max 600s)

Phase 4: Fallback (Main Agent) - NEW
    └── Generate minimal templates for missing files

Phase 5: Completion (Main Agent)
    ├── Display generated files (success/fallback/missing)
    └── Remove setup_progress from edaf-config.yml
```

### Scalability Principles

1. **1 Agent = 1 File**: Each agent generates exactly one output file
2. **Parallel Execution**: All agents run simultaneously in background
3. **Independent Failure**: One agent failing doesn't affect others
4. **Fallback Templates**: Missing files get minimal templates on timeout

---

## Step 0: Check for Interrupted Setup

**Action**: Check if previous setup was interrupted:

```typescript
const fs = require('fs')
const path = require('path')
const yaml = require('js-yaml')

// Check for interrupted setup
if (fs.existsSync('.claude/edaf-config.yml')) {
  try {
    const existingConfig = yaml.load(fs.readFileSync('.claude/edaf-config.yml', 'utf-8'))

    if (existingConfig && existingConfig.setup_progress && existingConfig.setup_progress.status === 'in_progress') {
      console.log('\n⚠️  Previous setup was interrupted / 前回のセットアップが中断されています\n')

      const resumeResponse = await AskUserQuestion({
        questions: [
          {
            question: "Resume from where it left off? / 中断した箇所から再開しますか？",
            header: "Resume",
            multiSelect: false,
            options: [
              {
                label: "Resume - Check file generation status",
                description: "Continue polling for file generation. Recommended if agents are still running."
              },
              {
                label: "Restart - Start fresh setup",
                description: "Delete progress and start from the beginning."
              }
            ]
          }
        ]
      })

      if (resumeResponse.answers['0'].includes('Resume')) {
        // Jump to Phase 3 (Polling)
        console.log('\n🔄 Resuming setup... / セットアップを再開中...\n')
        // The polling logic will be executed in Step 6
      } else {
        // Clear setup_progress and restart
        delete existingConfig.setup_progress
        fs.writeFileSync('.claude/edaf-config.yml', yaml.dump(existingConfig))
        console.log('\n🔄 Restarting setup... / セットアップを最初から開始...\n')
      }
    }
  } catch (e) {
    // Config file exists but is invalid, continue with fresh setup
  }
}
```

---

## Step 1: Language Preferences

**Action**: Select language preference:

```typescript
const langResponse = await AskUserQuestion({
  questions: [
    {
      question: "Select your language preference for EDAF / EDAFの言語設定を選択してください",
      header: "Language",
      multiSelect: false,
      options: [
        {
          label: "Option 1: EN docs + EN output",
          description: "Documentation in English, Terminal output in English. Best for English-speaking teams."
        },
        {
          label: "Option 2: JA docs + JA output",
          description: "Documentation in Japanese, Terminal output in Japanese. Best for Japanese teams."
        },
        {
          label: "Option 3: EN docs + JA output",
          description: "Documentation in English, Terminal output in Japanese."
        }
      ]
    }
  ]
})

// Parse the selected option
const selected = langResponse.answers['0']
let docLang = 'en'
let termLang = 'en'

if (selected.includes('Option 1')) {
  docLang = 'en'
  termLang = 'en'
} else if (selected.includes('Option 2')) {
  docLang = 'ja'
  termLang = 'ja'
} else if (selected.includes('Option 3')) {
  docLang = 'en'
  termLang = 'ja'
}

console.log('\n✅ Language preference set:')
console.log('   Documentation:', docLang === 'en' ? 'English' : 'Japanese')
console.log('   Terminal Output:', termLang === 'en' ? 'English' : 'Japanese')
```

---

## Step 2: Verify Installation

**Action**: Check for installed components:

```typescript
const checks = {
  workers: fs.existsSync('.claude/agents/workers/database-worker-v1-self-adapting.md'),
  evaluators: fs.existsSync('.claude/agents/evaluators/phase5-code/code-quality-evaluator-v1-self-adapting.md'),
  setupCommand: fs.existsSync('.claude/commands/setup.md')
}

console.log('\n📋 Installation Status:')
console.log('   Workers:', checks.workers ? '✅ Installed' : '❌ Not found')
console.log('   Evaluators:', checks.evaluators ? '✅ Installed' : '❌ Not found')
console.log('   /setup command:', checks.setupCommand ? '✅ Installed' : '❌ Not found')

if (!checks.workers || !checks.evaluators) {
  console.log('\n⚠️  Some components are missing. Please run install.sh first.')
  console.log('   bash evaluator-driven-agent-flow/scripts/install.sh')
}
```

---

## Step 3: Project Auto-Detection & Docker Configuration

**Action**: Detect project type and Docker environment:

```typescript
// Detect project type
let projectType = 'unknown'
let detectedFrameworks = []

if (fs.existsSync('package.json')) {
  const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf-8'))
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies }

  projectType = 'node'
  console.log('\n📦 Detected: JavaScript/TypeScript Project\n')

  if (deps.react) detectedFrameworks.push('React')
  if (deps.next) detectedFrameworks.push('Next.js')
  if (deps.vue) detectedFrameworks.push('Vue')
  if (deps.express) detectedFrameworks.push('Express')
  if (deps['@nestjs/core']) detectedFrameworks.push('NestJS')
  if (deps.typescript) detectedFrameworks.push('TypeScript')
  if (deps.jest) detectedFrameworks.push('Jest')
  if (deps.vitest) detectedFrameworks.push('Vitest')
  if (deps.eslint) detectedFrameworks.push('ESLint')

  console.log('   Frameworks:', detectedFrameworks.join(', ') || 'None detected')
}

if (fs.existsSync('requirements.txt') || fs.existsSync('pyproject.toml')) {
  projectType = 'python'
  console.log('\n🐍 Detected: Python Project')
}

if (fs.existsSync('go.mod')) {
  projectType = 'go'
  console.log('\n🔵 Detected: Go Project')
}

// Docker detection
let dockerConfig = { enabled: false }
const composeFiles = ['compose.yml', 'compose.yaml', 'docker-compose.yml', 'docker-compose.yaml']
let composeFile = composeFiles.find(f => fs.existsSync(f))

if (composeFile) {
  console.log('\n🐳 Docker Compose detected:', composeFile)

  const compose = fs.readFileSync(composeFile, 'utf-8')
  const serviceMatches = compose.match(/^  (\w+):/gm)
  const services = serviceMatches ? serviceMatches.map(s => s.trim().replace(':', '')) : []

  const dockerResponse = await AskUserQuestion({
    questions: [
      {
        question: "How should commands be executed?",
        header: "Docker",
        multiSelect: false,
        options: [
          {
            label: "Docker container",
            description: "Execute via docker compose exec (recommended for Docker development)"
          },
          {
            label: "Local machine",
            description: "Execute on host machine directly"
          }
        ]
      }
    ]
  })

  if (dockerResponse.answers['0'].includes('Docker')) {
    // Select service
    if (services.length > 1) {
      const serviceResponse = await AskUserQuestion({
        questions: [
          {
            question: "Select main service for command execution",
            header: "Service",
            multiSelect: false,
            options: services.slice(0, 4).map(s => ({
              label: s,
              description: `Execute commands in '${s}' container`
            }))
          }
        ]
      })
      dockerConfig = {
        enabled: true,
        compose_file: composeFile,
        main_service: serviceResponse.answers['0'],
        exec_prefix: `docker compose exec ${serviceResponse.answers['0']}`
      }
    } else if (services.length === 1) {
      dockerConfig = {
        enabled: true,
        compose_file: composeFile,
        main_service: services[0],
        exec_prefix: `docker compose exec ${services[0]}`
      }
    }
    console.log('   Docker execution enabled:', dockerConfig.exec_prefix)
  }
}
```

---

## Step 4: Generate CLAUDE.md and Configuration

**Action**: Generate CLAUDE.md:

```typescript
// Generate CLAUDE.md content
let claudeMd = `# EDAF v1.0 - Claude Code Configuration

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

// Save CLAUDE.md
fs.writeFileSync('.claude/CLAUDE.md', claudeMd)
console.log('\n✅ CLAUDE.md generated')
```

---

## Step 5: Standards Learning Selection & Fire & Forget Launch

**Action**: Ask about standards learning and launch agents:

```typescript
// Detect code for standards learning
const codePatterns = {
  typescript: [],
  react: [],
  python: [],
  test: []
}

// Use Glob to detect files (simplified check)
try {
  const { execSync } = require('child_process')
  const tsFiles = execSync('find . -name "*.ts" -not -path "*/node_modules/*" -not -path "*/dist/*" 2>/dev/null | head -5', { encoding: 'utf-8' }).trim()
  if (tsFiles) codePatterns.typescript = tsFiles.split('\n').filter(f => f)

  const tsxFiles = execSync('find . -name "*.tsx" -not -path "*/node_modules/*" -not -path "*/dist/*" 2>/dev/null | head -5', { encoding: 'utf-8' }).trim()
  if (tsxFiles) codePatterns.react = tsxFiles.split('\n').filter(f => f)

  const testFiles = execSync('find . -name "*.test.*" -o -name "*.spec.*" 2>/dev/null | head -5', { encoding: 'utf-8' }).trim()
  if (testFiles) codePatterns.test = testFiles.split('\n').filter(f => f)
} catch (e) {
  // Ignore errors
}

const hasCode = codePatterns.typescript.length > 0 || codePatterns.react.length > 0 || codePatterns.python.length > 0

// Define expected files (FIXED - docs are always the same 6 files)
const expectedDocs = [
  'docs/product-requirements.md',
  'docs/functional-design.md',
  'docs/development-guidelines.md',
  'docs/repository-structure.md',
  'docs/architecture.md',
  'docs/glossary.md'
]

let expectedSkills = []
let selectedStandards = []

if (hasCode) {
  console.log('\n📚 Existing code detected for standards learning')

  const standardsResponse = await AskUserQuestion({
    questions: [
      {
        question: "Learn coding standards from existing code?",
        header: "Standards",
        multiSelect: false,
        options: [
          {
            label: "Yes, learn all standards (Recommended)",
            description: "Analyze code and create enforceable standards for Phase 4-6"
          },
          {
            label: "Skip for now",
            description: "You can run /setup again later to create standards"
          }
        ]
      }
    ]
  })

  if (standardsResponse.answers['0'].includes('Yes')) {
    // Determine which standards to create based on detected code
    if (codePatterns.typescript.length > 0) {
      selectedStandards.push('typescript-standards')
      expectedSkills.push('.claude/skills/typescript-standards/SKILL.md')
    }
    if (codePatterns.react.length > 0) {
      selectedStandards.push('react-standards')
      expectedSkills.push('.claude/skills/react-standards/SKILL.md')
    }
    if (codePatterns.test.length > 0) {
      selectedStandards.push('test-standards')
      expectedSkills.push('.claude/skills/test-standards/SKILL.md')
    }
    // Always add security if any code exists
    selectedStandards.push('security-standards')
    expectedSkills.push('.claude/skills/security-standards/SKILL.md')

    console.log('   Standards to learn:', selectedStandards.join(', '))
  }
} else {
  console.log('\n📚 No existing code detected, skipping standards learning')
}

// Save configuration WITH setup_progress (temporary section)
const config = {
  language_preferences: {
    documentation_language: docLang,
    terminal_output_language: termLang,
    save_dual_language_docs: false
  },
  docker: dockerConfig,
  // Temporary section - will be removed on completion
  setup_progress: {
    status: 'in_progress',
    started_at: new Date().toISOString(),
    expected_docs: expectedDocs,
    expected_skills: expectedSkills
  }
}

fs.writeFileSync('.claude/edaf-config.yml', yaml.dump(config))
console.log('\n✅ Configuration saved to .claude/edaf-config.yml')

// Create directories
if (!fs.existsSync('docs')) fs.mkdirSync('docs', { recursive: true })
if (!fs.existsSync('.claude/skills')) fs.mkdirSync('.claude/skills', { recursive: true })

// === FIRE & FORGET: Launch agents in background ===
console.log('\n🚀 Launching background agents (Fire & Forget)...\n')

// Define documentation files with their specific focus areas
const docDefinitions = [
  {
    file: 'product-requirements.md',
    focus: 'Product vision, user personas, user stories, and acceptance criteria',
    description: 'product requirements documentation'
  },
  {
    file: 'functional-design.md',
    focus: 'Functional specifications, feature descriptions, and system behavior',
    description: 'functional design documentation'
  },
  {
    file: 'development-guidelines.md',
    focus: 'Coding conventions, development workflow, and best practices',
    description: 'development guidelines'
  },
  {
    file: 'repository-structure.md',
    focus: 'Directory structure, file organization, and module responsibilities',
    description: 'repository structure documentation'
  },
  {
    file: 'architecture.md',
    focus: 'System architecture, component diagrams, and technical decisions',
    description: 'architecture documentation'
  },
  {
    file: 'glossary.md',
    focus: 'Domain terms, technical terminology, and acronym definitions',
    description: 'glossary of terms'
  }
]

// Launch 6 documentation-worker agents in parallel (1 agent = 1 file)
console.log('   📄 Launching documentation agents (6 agents × 1 file each):')

for (const doc of docDefinitions) {
  await Task({
    subagent_type: 'documentation-worker',
    model: 'sonnet',
    run_in_background: true,
    description: `Generate ${doc.file}`,
    prompt: `Generate ONLY the file: docs/${doc.file}

**IMPORTANT**: Generate ONLY this ONE file. Do NOT generate any other files.

**Focus Area**: ${doc.focus}

**Instructions**:
1. Use Read and Glob tools to analyze the codebase
2. Detect language, framework, and architecture patterns
3. Generate comprehensive but concise ${doc.description}
4. Write the file to: docs/${doc.file}

**Documentation Language**: ${docLang === 'en' ? 'English' : 'Japanese'}

**Current Working Directory**: ${process.cwd()}

**Output**: Write ONLY docs/${doc.file} - nothing else.`
  })

  console.log(`      - ${doc.file}`)
}

// Launch standards agents if selected
for (const standard of selectedStandards) {
  // Create directory
  fs.mkdirSync(`.claude/skills/${standard}`, { recursive: true })

  await Task({
    subagent_type: 'general-purpose',
    model: 'sonnet',
    run_in_background: true,
    description: `Generate ${standard} (background)`,
    prompt: `Generate coding standards: ${standard}

**Output**: .claude/skills/${standard}/SKILL.md

**Instructions**:
1. Analyze existing code using Glob and Read tools
2. Extract naming conventions, file structure, patterns
3. Create SKILL.md with actionable rules and examples
4. Include enforcement checklist for Phase 4-6

**Current Working Directory**: ${process.cwd()}`
  })

  console.log(`   📖 ${standard} agent launched (background)`)
}

console.log('\n✅ All agents launched. NO TaskOutput called (Fire & Forget).')
console.log('   Agents are working in the background...\n')
```

---

## Step 6: Polling for File Generation

**Action**: Poll for file existence (30s interval, max 600s):

```typescript
console.log('\n⏳ Polling for file generation (30s interval, max 600s)...\n')

const pollInterval = 30000  // 30 seconds
const maxPolls = 20         // 20 * 30s = 600s (10 minutes)
let pollCount = 0

// Read expected files from config
let expectedDocsToCheck = expectedDocs
let expectedSkillsToCheck = expectedSkills

// If resuming, read from config
if (fs.existsSync('.claude/edaf-config.yml')) {
  try {
    const configData = yaml.load(fs.readFileSync('.claude/edaf-config.yml', 'utf-8'))
    if (configData.setup_progress) {
      expectedDocsToCheck = configData.setup_progress.expected_docs || expectedDocs
      expectedSkillsToCheck = configData.setup_progress.expected_skills || []
    }
  } catch (e) {}
}

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms))

// Track completion status
const fileStatus = {
  docs: {},
  skills: {}
}

// Initialize status
for (const doc of expectedDocsToCheck) {
  fileStatus.docs[doc] = { generated: false, fallback: false }
}
for (const skill of expectedSkillsToCheck) {
  fileStatus.skills[skill] = { generated: false, fallback: false }
}

while (pollCount < maxPolls) {
  // Check which files exist
  const completedDocs = expectedDocsToCheck.filter(doc => fs.existsSync(doc))
  const completedSkills = expectedSkillsToCheck.filter(skill => fs.existsSync(skill))

  // Update status
  for (const doc of completedDocs) {
    if (!fileStatus.docs[doc].generated) {
      fileStatus.docs[doc].generated = true
      console.log(`   ✅ ${path.basename(doc)} generated`)
    }
  }
  for (const skill of completedSkills) {
    if (!fileStatus.skills[skill].generated) {
      fileStatus.skills[skill].generated = true
      const skillName = skill.split('/')[2]
      console.log(`   ✅ ${skillName}/SKILL.md generated`)
    }
  }

  // Check if all files are generated
  const allDocsComplete = completedDocs.length === expectedDocsToCheck.length
  const allSkillsComplete = completedSkills.length === expectedSkillsToCheck.length

  if (allDocsComplete && allSkillsComplete) {
    console.log('\n✅ All files generated successfully!')
    break
  }

  pollCount++

  // Progress indicator
  const totalExpected = expectedDocsToCheck.length + expectedSkillsToCheck.length
  const totalCompleted = completedDocs.length + completedSkills.length
  console.log(`   [${pollCount * 30}s] Progress: ${totalCompleted}/${totalExpected} files`)

  if (pollCount >= maxPolls) {
    console.log('\n⚠️  Timeout reached (600s). Generating fallback templates for missing files...')
    break
  }

  await sleep(pollInterval)
}
```

---

## Step 7: Fallback Template Generation

**Action**: Generate minimal templates for files that weren't created by agents:

```typescript
// Fallback templates for missing documentation files
const fallbackTemplates = {
  'product-requirements.md': `# Product Requirements

> ⚠️ This is a fallback template. Please update with actual project requirements.

## Overview

<!-- Describe the product vision and goals -->

## User Personas

<!-- Define target users -->

## User Stories

<!-- List user stories in "As a... I want... So that..." format -->

## Acceptance Criteria

<!-- Define success criteria -->

---
*Generated by EDAF Setup (fallback template)*
`,
  'functional-design.md': `# Functional Design

> ⚠️ This is a fallback template. Please update with actual functional specifications.

## Features

<!-- List and describe main features -->

## System Behavior

<!-- Describe system behavior and workflows -->

## API Specifications

<!-- Document API endpoints if applicable -->

---
*Generated by EDAF Setup (fallback template)*
`,
  'development-guidelines.md': `# Development Guidelines

> ⚠️ This is a fallback template. Please update with project-specific guidelines.

## Code Style

<!-- Define coding conventions -->

## Development Workflow

<!-- Describe git workflow, PR process, etc. -->

## Best Practices

<!-- List development best practices -->

---
*Generated by EDAF Setup (fallback template)*
`,
  'repository-structure.md': `# Repository Structure

> ⚠️ This is a fallback template. Please update with actual structure.

## Directory Layout

\`\`\`
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
└── .claude/       # EDAF configuration
\`\`\`

## Module Responsibilities

<!-- Describe each module's purpose -->

---
*Generated by EDAF Setup (fallback template)*
`,
  'architecture.md': `# Architecture

> ⚠️ This is a fallback template. Please update with actual architecture.

## System Overview

<!-- High-level architecture description -->

## Components

<!-- List main components and their responsibilities -->

## Technical Decisions

<!-- Document key technical decisions and rationale -->

---
*Generated by EDAF Setup (fallback template)*
`,
  'glossary.md': `# Glossary

> ⚠️ This is a fallback template. Please update with project-specific terms.

## Domain Terms

| Term | Definition |
|------|------------|
| <!-- term --> | <!-- definition --> |

## Technical Terms

| Term | Definition |
|------|------------|
| <!-- term --> | <!-- definition --> |

---
*Generated by EDAF Setup (fallback template)*
`
}

// Generate fallback templates for missing docs
const missingDocs = expectedDocsToCheck.filter(doc => !fs.existsSync(doc))
if (missingDocs.length > 0) {
  console.log('\n📝 Generating fallback templates for missing docs:')
  for (const doc of missingDocs) {
    const fileName = path.basename(doc)
    if (fallbackTemplates[fileName]) {
      fs.writeFileSync(doc, fallbackTemplates[fileName])
      fileStatus.docs[doc].fallback = true
      console.log(`   📄 ${fileName} (fallback template)`)
    }
  }
}

// Generate fallback templates for missing skills
const missingSkills = expectedSkillsToCheck.filter(skill => !fs.existsSync(skill))
if (missingSkills.length > 0) {
  console.log('\n📝 Generating fallback templates for missing skills:')
  for (const skill of missingSkills) {
    const skillName = skill.split('/')[2]
    const fallbackSkillContent = `# ${skillName.replace('-', ' ').replace(/\b\w/g, l => l.toUpperCase())}

> ⚠️ This is a fallback template. Run \`/review-standards\` to generate actual standards.

## Overview

This skill defines coding standards for the project.

## Rules

<!-- Define specific rules -->

## Examples

<!-- Provide code examples -->

---
*Generated by EDAF Setup (fallback template)*
`
    // Ensure directory exists
    const skillDir = path.dirname(skill)
    if (!fs.existsSync(skillDir)) {
      fs.mkdirSync(skillDir, { recursive: true })
    }
    fs.writeFileSync(skill, fallbackSkillContent)
    fileStatus.skills[skill].fallback = true
    console.log(`   📖 ${skillName}/SKILL.md (fallback template)`)
  }
}
```

---

## Step 8: Cleanup and Completion

**Action**: Remove setup_progress and display final summary:

```typescript
// Remove setup_progress from config
if (fs.existsSync('.claude/edaf-config.yml')) {
  const finalConfig = yaml.load(fs.readFileSync('.claude/edaf-config.yml', 'utf-8'))
  delete finalConfig.setup_progress
  fs.writeFileSync('.claude/edaf-config.yml', yaml.dump(finalConfig))
  console.log('\n✅ Cleaned up setup_progress from edaf-config.yml')
}

// Final summary
console.log('\n' + '═'.repeat(60))
console.log('  EDAF v1.0 Setup Complete!')
console.log('═'.repeat(60))

console.log('\n📁 Generated Files:')

// List docs with status indicators
console.log('\n   docs/:')
for (const doc of expectedDocsToCheck) {
  const fileName = path.basename(doc)
  const status = fileStatus.docs[doc]
  if (status.generated && !status.fallback) {
    console.log(`     ✅ ${fileName} (agent-generated)`)
  } else if (status.fallback) {
    console.log(`     📄 ${fileName} (fallback template - please review)`)
  } else {
    console.log(`     ❌ ${fileName} (not generated)`)
  }
}

// List skills with status indicators
if (expectedSkillsToCheck.length > 0) {
  console.log('\n   .claude/skills/:')
  for (const skill of expectedSkillsToCheck) {
    const skillName = skill.split('/')[2]
    const status = fileStatus.skills[skill]
    if (status.generated && !status.fallback) {
      console.log(`     ✅ ${skillName}/SKILL.md (agent-generated)`)
    } else if (status.fallback) {
      console.log(`     📖 ${skillName}/SKILL.md (fallback - run /review-standards)`)
    } else {
      console.log(`     ❌ ${skillName}/SKILL.md (not generated)`)
    }
  }
}

console.log('\n📋 Configuration:')
console.log(`   Language: ${docLang === 'en' ? 'English' : 'Japanese'} docs, ${termLang === 'en' ? 'English' : 'Japanese'} output`)
console.log(`   Docker: ${dockerConfig.enabled ? 'Enabled (' + dockerConfig.main_service + ')' : 'Disabled'}`)

// Count fallbacks
const fallbackDocsCount = Object.values(fileStatus.docs).filter(s => s.fallback).length
const fallbackSkillsCount = Object.values(fileStatus.skills).filter(s => s.fallback).length
const totalFallbacks = fallbackDocsCount + fallbackSkillsCount

if (totalFallbacks > 0) {
  console.log('\n⚠️  Note:')
  console.log(`   ${totalFallbacks} file(s) used fallback templates.`)
  console.log('   Please review and update these files with actual content.')
  if (fallbackSkillsCount > 0) {
    console.log('   Run /review-standards to regenerate skill files from your code.')
  }
}

console.log('\n🚀 Next Steps:')
console.log('   1. Review generated docs in docs/')
if (totalFallbacks > 0) {
  console.log('   2. Update fallback templates with actual content')
  console.log('   3. Run /review-standards if skill templates need updating')
  console.log('   4. Start implementing features with EDAF 7-phase workflow')
} else {
  console.log('   2. Start implementing features with EDAF 7-phase workflow')
  console.log('   3. Run /review-standards to update coding standards anytime')
}

console.log('\n' + '═'.repeat(60))
```

---

## Summary

This optimized `/setup` command uses a **scalable 1:1 pattern**:

### Core Principles

1. **1 Agent = 1 File**: Each agent generates exactly one output file
   - Documentation: 6 `documentation-worker` instances (one per doc file)
   - Skills: N `general-purpose` instances (one per skill)

2. **Parallel Execution**: All agents run simultaneously in background
   - Maximizes throughput
   - Independent failure handling

3. **Fire & Forget + Fallback**: No TaskOutput calls, but fallback on timeout
   - Prevents context exhaustion
   - Ensures all files exist after setup

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SCALABLE 1:1 PATTERN                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Documentation (6 agents × 1 file)                          │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │
│  │doc-wkr │ │doc-wkr │ │doc-wkr │ │doc-wkr │ │doc-wkr │ │doc-wkr │ │
│  │prod-req│ │func-dsg│ │dev-gide│ │repo-str│ │arch    │ │glossary│ │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ │
│                                                             │
│  Skills (N agents × 1 file)                                 │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐                │
│  │general │ │general │ │general │ │general │ ...            │
│  │ts-std  │ │react-st│ │test-std│ │sec-std │                │
│  └────────┘ └────────┘ └────────┘ └────────┘                │
│                                                             │
│  Monitoring: File existence polling (30s interval)          │
│  Fallback: Template generation on 600s timeout              │
└─────────────────────────────────────────────────────────────┘
```

### Key Features

| Feature | Description |
|---------|-------------|
| Context Safety | Fire & Forget - no TaskOutput calls |
| Scalability | 1:1 pattern - add files by adding to array |
| Resilience | Fallback templates ensure setup always completes |
| Progress Tracking | Real-time file existence monitoring |
| Recovery | `setup_progress` in config enables resume |

### Benefits Over Previous Design

| Aspect | Before | After |
|--------|--------|-------|
| Doc agents | 1 agent × 6 files | 6 agents × 1 file |
| Failure impact | All 6 docs fail | Only 1 doc fails |
| Timeout handling | Nothing generated | Fallback templates |
| Scalability | Hard to add files | Just add to array |
