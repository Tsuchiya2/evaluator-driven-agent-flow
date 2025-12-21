# Phase 2.5: Implementation

**Purpose**: Execute task plan using specialized worker agents
**Gate Criteria**: None (implementation phase, not a gate)

---

## Workflow

### Step 1: Parse Task Plan

```typescript
// Read task plan
const taskPlan = fs.readFileSync('docs/plans/{feature-slug}-tasks.md', 'utf-8')

// Extract tasks by worker type
const tasks = {
  database: extractTasks(taskPlan, 'database'),
  backend: extractTasks(taskPlan, 'backend'),
  frontend: extractTasks(taskPlan, 'frontend'),
  test: extractTasks(taskPlan, 'test')
}
```

### Step 2: Execute Workers in Sequence

**Execution Order:**
1. Database Worker (first - creates schema)
2. Backend Worker (second - needs database)
3. Frontend Worker (parallel with backend or after)
4. Test Worker (last - needs all code)

```typescript
// Update status
await bash('.claude/scripts/update-edaf-phase.sh "Phase 2.5: Implementation" "Starting workers"')
```

### Step 3: Database Worker

```typescript
if (tasks.database.length > 0) {
  await bash('.claude/scripts/update-edaf-phase.sh "Phase 2.5" "Database Worker running"')

  const dbResult = await Task({
    subagent_type: 'database-worker-v1-self-adapting',
    prompt: `Execute the database tasks from the task plan:

Task Plan: docs/plans/{feature-slug}-tasks.md
Design Document: docs/designs/{feature-slug}.md

Database Tasks:
${tasks.database.map(t => `- ${t.description}`).join('\n')}

Requirements:
1. Create necessary database models/schemas
2. Generate migrations
3. Add indexes for performance
4. Create seed data if needed
5. Follow existing project patterns
`
  })

  console.log('✅ Database Worker completed')
}
```

### Step 4: Backend Worker

```typescript
if (tasks.backend.length > 0) {
  await bash('.claude/scripts/update-edaf-phase.sh "Phase 2.5" "Backend Worker running"')

  const backendResult = await Task({
    subagent_type: 'backend-worker-v1-self-adapting',
    prompt: `Execute the backend tasks from the task plan:

Task Plan: docs/plans/{feature-slug}-tasks.md
Design Document: docs/designs/{feature-slug}.md

Backend Tasks:
${tasks.backend.map(t => `- ${t.description}`).join('\n')}

Requirements:
1. Implement API endpoints
2. Add business logic
3. Implement authentication/authorization
4. Add validation
5. Handle errors properly
6. Follow existing project patterns
`
  })

  console.log('✅ Backend Worker completed')
}
```

### Step 5: Frontend Worker

```typescript
if (tasks.frontend.length > 0) {
  await bash('.claude/scripts/update-edaf-phase.sh "Phase 2.5" "Frontend Worker running"')

  const frontendResult = await Task({
    subagent_type: 'frontend-worker-v1-self-adapting',
    prompt: `Execute the frontend tasks from the task plan:

Task Plan: docs/plans/{feature-slug}-tasks.md
Design Document: docs/designs/{feature-slug}.md

Frontend Tasks:
${tasks.frontend.map(t => `- ${t.description}`).join('\n')}

Requirements:
1. Create UI components
2. Implement forms with validation
3. Add state management
4. Connect to backend APIs
5. Handle loading and error states
6. Follow existing project patterns
`
  })

  console.log('✅ Frontend Worker completed')

  // Mark that frontend files were modified (for Phase 3 UI verification)
  global.frontendModified = true
}
```

### Step 6: Test Worker

```typescript
if (tasks.test.length > 0) {
  await bash('.claude/scripts/update-edaf-phase.sh "Phase 2.5" "Test Worker running"')

  const testResult = await Task({
    subagent_type: 'test-worker-v1-self-adapting',
    prompt: `Execute the test tasks from the task plan:

Task Plan: docs/plans/{feature-slug}-tasks.md
Design Document: docs/designs/{feature-slug}.md

Test Tasks:
${tasks.test.map(t => `- ${t.description}`).join('\n')}

Requirements:
1. Write unit tests for new code
2. Write integration tests for APIs
3. Write component tests for UI
4. Achieve >80% coverage for new code
5. Follow existing test patterns
`
  })

  console.log('✅ Test Worker completed')
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

After Phase 2.5 completion:

1. **Database Files**: Models, migrations, seeds
2. **Backend Files**: Controllers, services, routes
3. **Frontend Files**: Components, pages, styles
4. **Test Files**: Unit tests, integration tests
5. **Worker Reports**: Implementation summaries

---

## Transition to Phase 3

When all workers complete:

```typescript
await bash('.claude/scripts/update-edaf-phase.sh "Phase 2.5: Implementation" "Complete"')
await bash('.claude/scripts/notification.sh "Implementation complete" WarblerSong')

// Proceed to Phase 3
// Reference: PHASE3-CODE.md
```
