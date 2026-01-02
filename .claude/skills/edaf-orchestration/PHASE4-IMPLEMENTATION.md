# Phase 4: Implementation

**Purpose**: Execute task plan using specialized worker agents
**Gate Criteria**: Quality Gate Evaluator (lint + tests must pass, score = 10.0/10.0)
**Resumability**: ✅ Full support - can resume from any checkpoint

---

## 📥 Input from Phase 3 (Planning)

- **`.steering/{YYYY-MM-DD}-{feature-slug}/tasks.md`** - Approved task plan
  - Task breakdown with dependencies and worker assignments
  - Execution sequence (database → backend → frontend → test)
  - All 7 planner evaluators passed (≥ 8.0/10)
- **`.steering/{YYYY-MM-DD}-{feature-slug}/design.md`** - Design document (reference)
- **`.steering/{YYYY-MM-DD}-{feature-slug}/idea.md`** - Requirements (reference)

---

## 🔄 Resumability & Progress Tracking

Phase 4 supports **automatic resumability**:

- ✅ **Checkpoint after each worker**: Progress saved to `tasks.md`
- ✅ **Skip completed tasks**: Automatically detects and skips finished work
- ✅ **Crash recovery**: Resume from last checkpoint after Claude Code crash
- ✅ **Auto-compaction safe**: Resume after conversation compaction
- ✅ **Manual control**: Users can manually uncheck tasks to re-run them

### How It Works

1. **Tasks are marked with checkboxes** in `tasks.md`:
   ```markdown
   ## Database Tasks
   - [ ] Create User model
   - [x] Create Task model  ← Completed
   - [ ] Generate migration
   ```

2. **Before each worker executes**: Check which tasks are already completed
3. **After each worker completes**: Update `tasks.md` with checkmarks `[x]`
4. **On resume**: Skip workers/tasks that are already complete

---

## Helper Functions

### Check Completed Tasks

```typescript
/**
 * Check which tasks are already completed in tasks.md
 * @param taskPlanPath Path to tasks.md file
 * @param workerType Worker type (database, backend, frontend, test)
 * @returns Array of completed task descriptions
 */
function checkCompletedTasks(taskPlanPath: string, workerType: string): string[] {
  const taskPlan = fs.readFileSync(taskPlanPath, 'utf-8')
  const completedTasks: string[] = []

  // Find the worker section (e.g., "## Database Tasks")
  const sectionRegex = new RegExp(`##\\s+${workerType}\\s+Tasks([\\s\\S]*?)(?=##|$)`, 'i')
  const sectionMatch = taskPlan.match(sectionRegex)

  if (!sectionMatch) {
    return []
  }

  const sectionContent = sectionMatch[1]

  // Find all completed tasks: - [x] Task description
  const completedRegex = /-\s+\[x\]\s+(.+)/gi
  let match
  while ((match = completedRegex.exec(sectionContent)) !== null) {
    completedTasks.push(match[1].trim())
  }

  return completedTasks
}
```

### Update Task Completion

```typescript
/**
 * Mark tasks as completed in tasks.md
 * @param taskPlanPath Path to tasks.md file
 * @param workerType Worker type (database, backend, frontend, test)
 */
async function markWorkerCompleted(taskPlanPath: string, workerType: string) {
  let taskPlan = fs.readFileSync(taskPlanPath, 'utf-8')

  // Find the worker section
  const sectionRegex = new RegExp(`(##\\s+${workerType}\\s+Tasks[\\s\\S]*?)(?=##|$)`, 'i')
  const sectionMatch = taskPlan.match(sectionRegex)

  if (!sectionMatch) {
    console.warn(`⚠️  No ${workerType} tasks section found in tasks.md`)
    return
  }

  let section = sectionMatch[1]

  // Replace all [ ] with [x] in this section
  section = section.replace(/-\s+\[\s+\]\s+/g, '- [x] ')

  // Replace the section in the full document
  taskPlan = taskPlan.replace(sectionRegex, section)

  // Write back to file
  fs.writeFileSync(taskPlanPath, taskPlan)

  console.log(`✅ Marked all ${workerType} tasks as completed in ${taskPlanPath}`)
}
```

### Check Worker Completion

```typescript
/**
 * Check if a worker has already completed all its tasks
 * @param taskPlanPath Path to tasks.md file
 * @param workerType Worker type
 * @returns true if all tasks are completed, false otherwise
 */
function isWorkerCompleted(taskPlanPath: string, workerType: string): boolean {
  const taskPlan = fs.readFileSync(taskPlanPath, 'utf-8')

  // Find the worker section
  const sectionRegex = new RegExp(`##\\s+${workerType}\\s+Tasks([\\s\\S]*?)(?=##|$)`, 'i')
  const sectionMatch = taskPlan.match(sectionRegex)

  if (!sectionMatch) {
    return false  // No section = not completed
  }

  const sectionContent = sectionMatch[1]

  // Check if there are any uncompleted tasks: - [ ] ...
  const uncompletedRegex = /-\s+\[\s+\]\s+/
  const hasUncompletedTasks = uncompletedRegex.test(sectionContent)

  return !hasUncompletedTasks  // Completed if no uncompleted tasks
}
```

---

## Workflow

### Step 1: Parse Task Plan & Check Progress

```typescript
const taskPlanPath = '.steering/{YYYY-MM-DD}-{feature-slug}/tasks.md'

// Read task plan
const taskPlan = fs.readFileSync(taskPlanPath, 'utf-8')

// Extract tasks by worker type
const tasks = {
  database: extractTasks(taskPlan, 'database'),
  backend: extractTasks(taskPlan, 'backend'),
  frontend: extractTasks(taskPlan, 'frontend'),
  test: extractTasks(taskPlan, 'test')
}

// Check progress for each worker
console.log('📋 Phase 3 Progress Check:')
console.log(`   Database: ${isWorkerCompleted(taskPlanPath, 'database') ? '✅ Completed' : '⏳ Pending'}`)
console.log(`   Backend: ${isWorkerCompleted(taskPlanPath, 'backend') ? '✅ Completed' : '⏳ Pending'}`)
console.log(`   Frontend: ${isWorkerCompleted(taskPlanPath, 'frontend') ? '✅ Completed' : '⏳ Pending'}`)
console.log(`   Test: ${isWorkerCompleted(taskPlanPath, 'test') ? '✅ Completed' : '⏳ Pending'}`)
console.log('')
```

### Step 2: Execute Workers in Sequence

**Execution Order:**
1. Database Worker (first - creates schema)
2. Backend Worker (second - needs database)
3. Frontend Worker (parallel with backend or after)
4. Test Worker (last - needs all code)

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 3: Implementation" "Starting workers"')
```

### Step 3: Database Worker

```typescript
const taskPlanPath = '.steering/{YYYY-MM-DD}-{feature-slug}/tasks.md'

if (tasks.database.length > 0) {
  // Check if already completed
  if (isWorkerCompleted(taskPlanPath, 'database')) {
    console.log('✅ Database Worker already completed - skipping')
  } else {
    const completedTasks = checkCompletedTasks(taskPlanPath, 'database')
    const pendingTasks = tasks.database.filter(t =>
      !completedTasks.some(ct => ct.includes(t.description.substring(0, 30)))
    )

    console.log(`📋 Database tasks: ${pendingTasks.length} pending, ${completedTasks.length} completed`)

    await bash('.claude/scripts/update-edaf-phase.sh "Phase 3" "Database Worker running"')

    const dbResult = await Task({
      subagent_type: 'database-worker-v1-self-adapting',
      prompt: `Execute the database tasks from the task plan:

Task Plan: ${taskPlanPath}
Design Document: .steering/{YYYY-MM-DD}-{feature-slug}/design.md

Database Tasks (${pendingTasks.length} pending):
${pendingTasks.map(t => `- [ ] ${t.description}`).join('\n')}

${completedTasks.length > 0 ? `Previously Completed (skip these):
${completedTasks.map(t => `- [x] ${t}`).join('\n')}
` : ''}

Requirements:
1. Create necessary database models/schemas
2. Generate migrations
3. Add indexes for performance
4. Create seed data if needed
5. Follow existing project patterns

IMPORTANT: Only implement the pending tasks listed above.
`
    })

    // Mark all database tasks as completed
    await markWorkerCompleted(taskPlanPath, 'database')

    console.log('✅ Database Worker completed')
  }
}
```

### Step 4: Backend Worker

```typescript
if (tasks.backend.length > 0) {
  // Check if already completed
  if (isWorkerCompleted(taskPlanPath, 'backend')) {
    console.log('✅ Backend Worker already completed - skipping')
  } else {
    const completedTasks = checkCompletedTasks(taskPlanPath, 'backend')
    const pendingTasks = tasks.backend.filter(t =>
      !completedTasks.some(ct => ct.includes(t.description.substring(0, 30)))
    )

    console.log(`📋 Backend tasks: ${pendingTasks.length} pending, ${completedTasks.length} completed`)

    await bash('.claude/scripts/update-edaf-phase.sh "Phase 3" "Backend Worker running"')

    const backendResult = await Task({
      subagent_type: 'backend-worker-v1-self-adapting',
      prompt: `Execute the backend tasks from the task plan:

Task Plan: ${taskPlanPath}
Design Document: .steering/{YYYY-MM-DD}-{feature-slug}/design.md

Backend Tasks (${pendingTasks.length} pending):
${pendingTasks.map(t => `- [ ] ${t.description}`).join('\n')}

${completedTasks.length > 0 ? `Previously Completed (skip these):
${completedTasks.map(t => `- [x] ${t}`).join('\n')}
` : ''}

Requirements:
1. Implement API endpoints
2. Add business logic
3. Implement authentication/authorization
4. Add validation
5. Handle errors properly
6. Follow existing project patterns

IMPORTANT: Only implement the pending tasks listed above.
`
    })

    // Mark all backend tasks as completed
    await markWorkerCompleted(taskPlanPath, 'backend')

    console.log('✅ Backend Worker completed')
  }
}
```

### Step 5: Frontend Worker

```typescript
if (tasks.frontend.length > 0) {
  // Check if already completed
  if (isWorkerCompleted(taskPlanPath, 'frontend')) {
    console.log('✅ Frontend Worker already completed - skipping')
  } else {
    const completedTasks = checkCompletedTasks(taskPlanPath, 'frontend')
    const pendingTasks = tasks.frontend.filter(t =>
      !completedTasks.some(ct => ct.includes(t.description.substring(0, 30)))
    )

    console.log(`📋 Frontend tasks: ${pendingTasks.length} pending, ${completedTasks.length} completed`)

    await bash('.claude/scripts/update-edaf-phase.sh "Phase 3" "Frontend Worker running"')

    const frontendResult = await Task({
      subagent_type: 'frontend-worker-v1-self-adapting',
      prompt: `Execute the frontend tasks from the task plan:

Task Plan: ${taskPlanPath}
Design Document: .steering/{YYYY-MM-DD}-{feature-slug}/design.md

Frontend Tasks (${pendingTasks.length} pending):
${pendingTasks.map(t => `- [ ] ${t.description}`).join('\n')}

${completedTasks.length > 0 ? `Previously Completed (skip these):
${completedTasks.map(t => `- [x] ${t}`).join('\n')}
` : ''}

Requirements:
1. Create UI components
2. Implement forms with validation
3. Add state management
4. Connect to backend APIs
5. Handle loading and error states
6. Follow existing project patterns

IMPORTANT: Only implement the pending tasks listed above.
`
    })

    // Mark all frontend tasks as completed
    await markWorkerCompleted(taskPlanPath, 'frontend')

    console.log('✅ Frontend Worker completed')

    // Mark that frontend files were modified (for Phase 4 UI verification)
    global.frontendModified = true
  }
}
```

### Step 6: Test Worker

```typescript
if (tasks.test.length > 0) {
  // Check if already completed
  if (isWorkerCompleted(taskPlanPath, 'test')) {
    console.log('✅ Test Worker already completed - skipping')
  } else {
    const completedTasks = checkCompletedTasks(taskPlanPath, 'test')
    const pendingTasks = tasks.test.filter(t =>
      !completedTasks.some(ct => ct.includes(t.description.substring(0, 30)))
    )

    console.log(`📋 Test tasks: ${pendingTasks.length} pending, ${completedTasks.length} completed`)

    await bash('.claude/scripts/update-edaf-phase.sh "Phase 3" "Test Worker running"')

    const testResult = await Task({
      subagent_type: 'test-worker-v1-self-adapting',
      prompt: `Execute the test tasks from the task plan:

Task Plan: ${taskPlanPath}
Design Document: .steering/{YYYY-MM-DD}-{feature-slug}/design.md

Test Tasks (${pendingTasks.length} pending):
${pendingTasks.map(t => `- [ ] ${t.description}`).join('\n')}

${completedTasks.length > 0 ? `Previously Completed (skip these):
${completedTasks.map(t => `- [x] ${t}`).join('\n')}
` : ''}

Requirements:
1. Write unit tests for new code
2. Write integration tests for APIs
3. Write component tests for UI
4. Achieve >80% coverage for new code
5. Follow existing test patterns

IMPORTANT: Only implement the pending tasks listed above.
`
    })

    // Mark all test tasks as completed
    await markWorkerCompleted(taskPlanPath, 'test')

    console.log('✅ Test Worker completed')
  }
}
```

---

## Worker Execution Patterns

### Sequential Execution (Default)

```
Database → Backend → Frontend → Test
```

Best when:
- Backend depends on database schema
- Frontend depends on backend APIs
- Tests need all code in place

### Parallel Execution (Optimized)

```
Database → [Backend ∥ Frontend] → Test
```

Best when:
- Frontend can use mock APIs initially
- Backend and frontend teams work independently
- Need faster implementation

```typescript
// Parallel execution example
if (tasks.backend.length > 0 && tasks.frontend.length > 0) {
  const [backendResult, frontendResult] = await Promise.all([
    Task({ subagent_type: 'backend-worker-v1-self-adapting', ... }),
    Task({ subagent_type: 'frontend-worker-v1-self-adapting', ... })
  ])
}
```

---

## Worker Capabilities

| Worker | Languages | Frameworks | Responsibilities |
|--------|-----------|------------|------------------|
| database | TS, Python, Java, Go, Rust | Sequelize, Prisma, SQLAlchemy, GORM | Schema, migrations, models |
| backend | TS, Python, Java, Go | Express, FastAPI, Spring Boot, Gin | APIs, business logic |
| frontend | TS, JS | React, Vue, Angular, Svelte | UI components, state |
| test | All | Jest, pytest, JUnit | Unit, integration, E2E tests |

---

## Output Artifacts

After Phase 3 completion:

1. **Database Files**: Models, migrations, seeds
2. **Backend Files**: Controllers, services, routes
3. **Frontend Files**: Components, pages, styles
4. **Test Files**: Unit tests, integration tests
5. **Worker Reports**: Implementation summaries
6. **Updated tasks.md**: All tasks marked as completed `[x]`

---

## Step 7: Lint Quality Gate

**IMPORTANT**: Before proceeding to Phase 4, run lint evaluator on generated code.

```typescript
// Run lint evaluator (enforces zero-tolerance quality)
console.log('🔍 Running Phase 3 Lint Quality Evaluator...')

await bash('.claude/scripts/update-edaf-phase.sh "Phase 3" "Running lint evaluator"')

const lintEvaluation = await Task({
  subagent_type: 'lint-evaluator',
  model: 'sonnet',
  prompt: `Evaluate the lint quality of all Phase 3 generated code.

Feature Directory: .steering/{YYYY-MM-DD}-{feature-slug}/

Requirements:
1. Run all configured lint tools
2. Enforce ultra-strict scoring: Score 10.0 (zero errors, zero warnings) or Score 6.0 (fail)
3. Generate detailed report at .steering/{YYYY-MM-DD}-{feature-slug}/reports/phase3-lint.md
4. If failing, identify affected workers and provide specific fix instructions

Output:
- Score (10.0 or 6.0)
- Status (PASS or FAIL)
- Report path
- Affected workers (if failing)
- Feedback for workers (if failing)
`
})

// Parse evaluation result
const lintScore = parseFloat(lintEvaluation.match(/Score:\s*(\d+\.\d+)/)?.[1] || '0')
const lintStatus = lintEvaluation.match(/Status:\s*(PASS|FAIL)/)?.[1] || 'FAIL'

console.log(`\n📊 Lint Evaluation Result: ${lintStatus} (${lintScore}/10.0)`)

// If lint evaluation fails, re-invoke affected workers
if (lintScore < 8.0) {
  console.log('❌ Lint evaluation failed - re-running affected workers...')

  // Extract affected workers from evaluation result
  const affectedWorkersMatch = lintEvaluation.match(/Affected Workers:\s*(.+)/)
  const affectedWorkers = affectedWorkersMatch
    ? affectedWorkersMatch[1].split(',').map(w => w.trim())
    : []

  // Extract feedback for workers
  const feedbackMatch = lintEvaluation.match(/Worker Re-execution Prompt[\s\S]*?```\n([\s\S]*?)\n```/)
  const workerFeedback = feedbackMatch ? feedbackMatch[1] : 'Fix lint errors in your code'

  // Re-run each affected worker with lint feedback
  for (const worker of affectedWorkers) {
    console.log(`\n▶️  Re-running ${worker} to fix lint errors...`)

    await bash(`.claude/scripts/update-edaf-phase.sh "Phase 3" "Re-running ${worker} (lint fixes)"`)

    await Task({
      subagent_type: worker,
      prompt: workerFeedback
    })

    console.log(`✅ ${worker} completed lint fixes`)
  }

  // Re-run lint evaluator to verify fixes
  console.log('\n🔄 Re-running lint evaluator to verify fixes...')

  const recheckEvaluation = await Task({
    subagent_type: 'lint-evaluator',
    model: 'sonnet',
    prompt: `Re-evaluate the lint quality of all Phase 3 generated code after worker fixes.

Feature Directory: .steering/{YYYY-MM-DD}-{feature-slug}/

Requirements:
1. Run all configured lint tools
2. Enforce ultra-strict scoring: Score 10.0 (zero errors, zero warnings) or Score 6.0 (fail)
3. Update report at .steering/{YYYY-MM-DD}-{feature-slug}/reports/phase4-quality-gate.md
4. Verify all previous issues are resolved (both lint and tests)

Output:
- Score (10.0 or 6.0)
- Status (PASS or FAIL)
`
  })

  const recheckScore = parseFloat(recheckEvaluation.match(/Score:\s*(\d+\.\d+)/)?.[1] || '0')
  const recheckStatus = recheckEvaluation.match(/Status:\s*(PASS|FAIL)/)?.[1] || 'FAIL'

  console.log(`\n📊 Re-check Result: ${recheckStatus} (${recheckScore}/10.0)`)

  if (recheckScore < 8.0) {
    throw new Error(`Lint evaluation still failing after worker fixes (${recheckScore}/10.0). Manual intervention required.`)
  }

  console.log('✅ All lint checks passed after fixes')
} else {
  console.log('✅ All lint checks passed on first attempt')
}

await bash('.claude/scripts/notification.sh "Phase 4 quality gate passed (lint + tests)" WarblerSong')
```

---

## Resumability Examples

### Example 1: Crash After Database Worker

**Scenario**: Claude Code crashes after Database Worker completes

**tasks.md state**:
```markdown
## Database Tasks
- [x] Create User model
- [x] Create Task model
- [x] Generate migrations

## Backend Tasks
- [ ] Implement POST /api/users
- [ ] Implement GET /api/tasks
```

**On resume**:
- ✅ Database Worker: Skipped (all tasks completed)
- ⏳ Backend Worker: Executes (has pending tasks)
- ⏳ Frontend Worker: Executes
- ⏳ Test Worker: Executes

### Example 2: Auto-Compaction During Backend

**Scenario**: Conversation auto-compacts while Backend Worker is running

**tasks.md state**:
```markdown
## Database Tasks
- [x] All completed

## Backend Tasks
- [x] Implement POST /api/users  ← Completed before compaction
- [ ] Implement GET /api/tasks    ← Pending
- [ ] Add authentication
```

**On resume**:
- ✅ Database Worker: Skipped
- ⏳ Backend Worker: Resumes with remaining tasks only
- ⏳ Frontend Worker: Pending
- ⏳ Test Worker: Pending

### Example 3: Manual Re-run

**Scenario**: User wants to re-implement frontend

**Action**: Manually uncheck tasks in tasks.md:
```markdown
## Frontend Tasks
- [ ] Create LoginForm component  ← Unchecked by user
- [ ] Create Dashboard component  ← Unchecked by user
```

**Result**:
- Frontend Worker will re-execute these tasks

---

## 📤 Output to Phase 5 (Code Review)

After Phase 4 completion:

1. **Implementation Code**: All source code generated by 4 workers
   - Database: Models, migrations, schemas
   - Backend: APIs, services, business logic
   - Frontend: UI components, pages, state management
   - Test: Unit tests, integration tests, test utilities
2. **Updated Task Plan**: `.steering/{YYYY-MM-DD}-{feature-slug}/tasks.md` (all tasks marked [x])
3. **Quality Gate Report**: `.steering/{YYYY-MM-DD}-{feature-slug}/reports/phase4-quality-gate.md`
   - Lint check results (all tools passed, zero errors/warnings)
   - Test execution results (all tests passed, 100% pass rate)
   - Quality gate evaluator passed (score = 10.0/10.0)

**Input for Phase 5**: All generated code will be evaluated by 7 code evaluators + UI verification

---

## Transition to Phase 5

When all workers complete and quality gate passes:

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 4: Implementation" "Complete"')
await bash('.claude/scripts/notification.sh "Phase 4 complete - All workers finished, quality gate passed (lint + tests)" WarblerSong')

// Proceed to Phase 5: Code Review Gate
// Reference: PHASE5-CODE.md
```
