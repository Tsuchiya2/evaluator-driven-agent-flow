# Quality Gate Evaluator - Phase 4

**Model**: `sonnet`
**Phase**: 4 (Implementation - Quality Gate)
**Purpose**: Enforce zero-tolerance quality compliance (lint + test execution)

---

## Objective

Verify that all generated code passes **ALL** configured quality checks:
1. **Lint checks** - Zero errors, zero warnings
2. **Test execution** - All tests pass

This evaluator enforces the strictest possible quality gate - any lint violation OR test failure results in immediate failure and worker re-execution.

---

## Evaluation Criteria

### Ultra-Strict Binary Scoring

**Score 10.0** (PASS):
- Zero lint errors AND
- Zero lint warnings AND
- All configured lint tools pass AND
- All tests pass (100% pass rate)

**Score < 10.0** (FAIL):
- 1+ lint errors, OR
- 1+ lint warnings, OR
- Any lint tool fails, OR
- 1+ test failures

**IMPORTANT**: This evaluator treats both lint warnings AND test failures as hard failures. Perfect code quality and test coverage is required.

---

## Execution Steps

### Step 1: Check Quality Check Configuration

```typescript
// Read quality check configuration
const configPath = '.claude/edaf-config.yml'
const config = fs.readFileSync(configPath, 'utf-8')

// Parse lint configuration
const lintersEnabled = config.match(/linters:\s*enabled:\s*(true|false)/)
const lintTools = config.match(/(?<=linters:[\s\S]*?tools:[\s\S]*?)name: (.+)/g)

// Parse test configuration
const testsEnabled = config.match(/tests:\s*enabled:\s*(true|false)/)
const testCommand = config.match(/command:\s*["'](.+)["']/)

console.log('🔍 Quality Gate Configuration:')
console.log(`   Linters enabled: ${lintersEnabled?.[1] || 'false'}`)
console.log(`   Tests enabled: ${testsEnabled?.[1] || 'false'}`)

// Track which checks are enabled
const checksEnabled = {
  lint: lintersEnabled?.[1] === 'true',
  test: testsEnabled?.[1] === 'true'
}

if (!checksEnabled.lint && !checksEnabled.test) {
  console.log('ℹ️  No quality checks configured - skipping evaluation')
  return {
    score: 10.0,
    status: 'PASS',
    message: 'No quality checks configured (setup phase skipped)'
  }
}
```

### Step 2a: Execute Lint Checks

```typescript
let lintPassed = true
let lintOutput = ''
let lintFailedTools = []
let lintPassedTools = []

if (checksEnabled.lint) {
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('📋 STEP 1/2: Lint Checks')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')

  // Run lint checks
  const lintResult = await bash('bash .claude/scripts/run-linters.sh')
  lintOutput = lintResult.output

  console.log(lintOutput)

  // Parse lint results
  const failedMatch = lintOutput.match(/❌ Failed \((\d+)\):/)
  const passedMatch = lintOutput.match(/✅ Passed \((\d+)\):/)

  if (failedMatch) {
    const failedSection = lintOutput.match(/❌ Failed[\s\S]*?(?=✅|$)/)
    if (failedSection) {
      const toolMatches = failedSection[0].match(/• (.+)/g)
      if (toolMatches) {
        lintFailedTools = toolMatches.map(t => t.replace('• ', ''))
      }
    }
  }

  if (passedMatch) {
    const passedSection = lintOutput.match(/✅ Passed[\s\S]*?(?=❌|━|$)/)
    if (passedSection) {
      const toolMatches = passedSection[0].match(/• (.+)/g)
      if (toolMatches) {
        lintPassedTools = toolMatches.map(t => t.replace('• ', ''))
      }
    }
  }

  lintPassed = (lintResult.exitCode === 0 && lintFailedTools.length === 0)

  console.log(`\n📊 Lint Results:`)
  console.log(`   Passed: ${lintPassedTools.length}`)
  console.log(`   Failed: ${lintFailedTools.length}`)
  console.log(`   Status: ${lintPassed ? '✅ PASS' : '❌ FAIL'}`)
}
```

### Step 2b: Execute Test Checks

```typescript
let testPassed = true
let testOutput = ''
let testStats = {
  total: 0,
  passed: 0,
  failed: 0,
  skipped: 0
}

if (checksEnabled.test) {
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('🧪 STEP 2/2: Test Execution')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n')

  // Run test execution
  const testCommand = config.match(/command:\s*["'](.+)["']/)?.[1] || 'npm test'
  console.log(`▶️  Running: ${testCommand}`)

  const testResult = await bash(testCommand)
  testOutput = testResult.output

  console.log(testOutput)

  // Parse test results (support multiple test frameworks)

  // Jest/Vitest pattern
  const jestMatch = testOutput.match(/Tests:\s+(\d+)\s+failed,\s+(\d+)\s+passed,\s+(\d+)\s+total/)
  if (jestMatch) {
    testStats.failed = parseInt(jestMatch[1])
    testStats.passed = parseInt(jestMatch[2])
    testStats.total = parseInt(jestMatch[3])
  }

  // Pytest pattern
  const pytestMatch = testOutput.match(/(\d+)\s+passed(?:,\s+(\d+)\s+failed)?/)
  if (pytestMatch) {
    testStats.passed = parseInt(pytestMatch[1])
    testStats.failed = pytestMatch[2] ? parseInt(pytestMatch[2]) : 0
    testStats.total = testStats.passed + testStats.failed
  }

  // Go test pattern
  const goMatch = testOutput.match(/PASS|FAIL/)
  if (goMatch && testOutput.includes('FAIL')) {
    testStats.failed = 1
    testStats.total = 1
  } else if (goMatch) {
    testStats.passed = 1
    testStats.total = 1
  }

  // Mocha/Chai pattern
  const mochaMatch = testOutput.match(/(\d+)\s+passing/)
  if (mochaMatch) {
    testStats.passed = parseInt(mochaMatch[1])
    testStats.total = testStats.passed
    const failMatch = testOutput.match(/(\d+)\s+failing/)
    if (failMatch) {
      testStats.failed = parseInt(failMatch[1])
      testStats.total += testStats.failed
    }
  }

  // Determine test pass/fail
  testPassed = (testResult.exitCode === 0 && testStats.failed === 0)

  console.log(`\n📊 Test Results:`)
  console.log(`   Total: ${testStats.total}`)
  console.log(`   Passed: ${testStats.passed}`)
  console.log(`   Failed: ${testStats.failed}`)
  console.log(`   Status: ${testPassed ? '✅ PASS' : '❌ FAIL'}`)
}
```

### Step 3: Calculate Ultra-Strict Score

```typescript
// Ultra-strict binary scoring
let score: number
let status: string

const allChecksPassed =
  (!checksEnabled.lint || lintPassed) &&
  (!checksEnabled.test || testPassed)

if (allChecksPassed) {
  // ONLY perfect score passes
  score = 10.0
  status = 'PASS'
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('✅ QUALITY GATE PASSED')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('All quality checks passed:')
  if (checksEnabled.lint) console.log('  ✅ Lint: Zero errors, zero warnings')
  if (checksEnabled.test) console.log('  ✅ Tests: All tests passing')
} else {
  // Everything else fails
  score = 6.0
  status = 'FAIL'
  console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('❌ QUALITY GATE FAILED')
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
  console.log('Quality violations detected:')
  if (checksEnabled.lint && !lintPassed) {
    console.log(`  ❌ Lint: ${lintFailedTools.length} tool(s) failed`)
  }
  if (checksEnabled.test && !testPassed) {
    console.log(`  ❌ Tests: ${testStats.failed} test(s) failed`)
  }
  console.log('\nPhase 4 workers must fix all issues and re-run')
}
```

### Step 4: Identify Affected Workers

```typescript
// Parse errors to determine which workers need to re-run
function parseAffectedWorkers(lintOutput: string, testOutput: string): string[] {
  const workers = new Set<string>()

  const combinedOutput = lintOutput + '\n' + testOutput

  // Database files → database-worker
  if (combinedOutput.match(/\/migrations\/|\/models\/|\/entities\/|\/schema\//)) {
    workers.add('database-worker-v1-self-adapting')
  }

  // Backend files → backend-worker
  if (combinedOutput.match(/\/controllers\/|\/services\/|\/routes\/|\/api\/|\/handlers\//)) {
    workers.add('backend-worker-v1-self-adapting')
  }

  // Frontend files → frontend-worker
  if (combinedOutput.match(/\/components\/|\/pages\/|\/views\/|\.tsx?$|\.vue$|\.svelte$|\.jsx$/)) {
    workers.add('frontend-worker-v1-self-adapting')
  }

  // Test files → test-worker
  if (combinedOutput.match(/\.test\.|\.spec\.|\/tests\/|\/test\/|__tests__/)) {
    workers.add('test-worker-v1-self-adapting')
  }

  return Array.from(workers)
}

const affectedWorkers = parseAffectedWorkers(lintOutput, testOutput)
```

### Step 5: Generate Comprehensive Report

```typescript
// Determine feature slug from current .steering/ directory
const steeringDirs = fs.readdirSync('.steering').filter(d => d.match(/^\d{4}-\d{2}-\d{2}-/))
const latestDir = steeringDirs.sort().reverse()[0]

if (!latestDir) {
  throw new Error('No .steering/{YYYY-MM-DD}-{feature-slug}/ directory found')
}

const reportPath = `.steering/${latestDir}/reports/phase4-quality-gate.md`
const reportDir = path.dirname(reportPath)

// Ensure reports directory exists
await bash(`mkdir -p "${reportDir}"`)

// Generate report content
const report = `# Phase 4: Quality Gate Evaluation

**Date**: ${new Date().toISOString()}
**Evaluator**: quality-gate-evaluator
**Status**: ${status}
**Score**: ${score}/10.0

---

## Summary

### Quality Checks Enabled

${checksEnabled.lint ? '- ✅ Lint checks' : '- ⚪ Lint checks (disabled)'}
${checksEnabled.test ? '- ✅ Test execution' : '- ⚪ Test execution (disabled)'}

### Results

| Check | Status | Details |
|-------|--------|---------|
${checksEnabled.lint ? `| Lint | ${lintPassed ? '✅ PASS' : '❌ FAIL'} | ${lintPassedTools.length} passed, ${lintFailedTools.length} failed |` : ''}
${checksEnabled.test ? `| Tests | ${testPassed ? '✅ PASS' : '❌ FAIL'} | ${testStats.passed}/${testStats.total} passed, ${testStats.failed} failed |` : ''}

**Overall Status**: ${status} (${score}/10.0)

---

## Scoring Criteria (Ultra-Strict)

This evaluator enforces **zero-tolerance** quality compliance:

- **Score 10.0** (PASS): Zero lint errors AND zero warnings AND all tests passing
- **Score < 10.0** (FAIL): Any lint errors OR warnings OR test failures

**Result**: ${status} (${score}/10.0)

---

${checksEnabled.lint ? `## Lint Results

### Summary

- **Total Tools**: ${lintPassedTools.length + lintFailedTools.length}
- **Passed**: ${lintPassedTools.length}
- **Failed**: ${lintFailedTools.length}

${lintPassedTools.length > 0 ? `### ✅ Passed Tools (${lintPassedTools.length})

${lintPassedTools.map(t => `- ${t}`).join('\n')}
` : ''}
${lintFailedTools.length > 0 ? `### ❌ Failed Tools (${lintFailedTools.length})

${lintFailedTools.map(t => `- ${t}`).join('\n')}
` : ''}
### Detailed Output

\`\`\`
${lintOutput}
\`\`\`

---
` : ''}

${checksEnabled.test ? `## Test Execution Results

### Summary

- **Total Tests**: ${testStats.total}
- **Passed**: ${testStats.passed}
- **Failed**: ${testStats.failed}
- **Pass Rate**: ${testStats.total > 0 ? ((testStats.passed / testStats.total) * 100).toFixed(1) : 0}%

### Detailed Output

\`\`\`
${testOutput}
\`\`\`

---
` : ''}

${status === 'FAIL' ? `## Required Actions

**Affected Workers**: ${affectedWorkers.length > 0 ? affectedWorkers.join(', ') : 'Unknown'}

**Next Steps**:
1. Review ${checksEnabled.lint && !lintPassed ? 'lint errors' : ''}${checksEnabled.lint && !lintPassed && checksEnabled.test && !testPassed ? ' and ' : ''}${checksEnabled.test && !testPassed ? 'test failures' : ''} in output above
2. Re-invoke affected workers with error feedback
3. Workers must fix ALL quality violations
4. Re-run quality-gate-evaluator to verify fixes

**Worker Re-execution Prompt Template**:

\`\`\`
Fix quality issues in your previously generated code:

${checksEnabled.lint && !lintPassed ? `## Lint Errors

${lintOutput}
` : ''}
${checksEnabled.test && !testPassed ? `## Test Failures

${testOutput}
` : ''}

Requirements:
1. Read the error messages above
2. Fix ALL lint errors/warnings and failing tests in affected files
3. Do NOT change functionality unless required for tests
4. Follow project's lint configuration and testing standards
5. Re-run quality checks locally to verify fixes

Previous Task Plan: .steering/${latestDir}/tasks.md
Design Document: .steering/${latestDir}/design.md
\`\`\`

---
` : `## Next Steps

✅ All quality checks passed - proceed to Phase 5 (Code Review Gate)

---
`}

## Evaluation Metadata

- **Evaluator Version**: v2.0 (quality-gate)
- **Model**: sonnet
- **Execution Time**: ${new Date().toISOString()}
- **Report Path**: ${reportPath}
- **Checks Enabled**: ${Object.entries(checksEnabled).filter(([_, v]) => v).map(([k]) => k).join(', ')}
`

// Write report
fs.writeFileSync(reportPath, report, 'utf-8')
console.log(`\n📄 Report saved: ${reportPath}`)
```

### Step 6: Return Evaluation Result

```typescript
return {
  score: score,
  status: status,
  message: status === 'PASS'
    ? 'All quality checks passed (lint + tests)'
    : `Quality violations detected - ${
        [
          !lintPassed && checksEnabled.lint ? `${lintFailedTools.length} lint tool(s) failed` : null,
          !testPassed && checksEnabled.test ? `${testStats.failed} test(s) failed` : null
        ].filter(Boolean).join(', ')
      }`,
  reportPath: reportPath,
  affectedWorkers: affectedWorkers,
  checks: {
    lint: {
      enabled: checksEnabled.lint,
      passed: lintPassed,
      failedTools: lintFailedTools,
      passedTools: lintPassedTools
    },
    test: {
      enabled: checksEnabled.test,
      passed: testPassed,
      stats: testStats
    }
  },
  requiresRework: status === 'FAIL',
  feedback: status === 'FAIL' ? {
    summary: `Phase 4 workers must fix ${
      [
        !lintPassed && checksEnabled.lint ? 'lint errors/warnings' : null,
        !testPassed && checksEnabled.test ? 'failing tests' : null
      ].filter(Boolean).join(' and ')
    }`,
    details: [lintOutput, testOutput].filter(Boolean).join('\n\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n'),
    workerPrompt: `Fix quality issues in your previously generated code:\n\n${
      checksEnabled.lint && !lintPassed ? `## Lint Errors\n\n${lintOutput}\n\n` : ''
    }${
      checksEnabled.test && !testPassed ? `## Test Failures\n\n${testOutput}\n\n` : ''
    }Requirements:\n1. Read the error messages above\n2. Fix ALL lint errors/warnings and failing tests in affected files\n3. Do NOT change functionality unless required for tests\n4. Follow project's lint configuration and testing standards\n5. Re-run quality checks locally to verify fixes`
  } : null
}
```

---

## Success Criteria

**PASS** (Score 10.0):
- ✅ All configured lint tools execute successfully
- ✅ Zero lint errors detected
- ✅ Zero lint warnings detected
- ✅ All tests pass (100% pass rate)
- ✅ Exit code 0 from both lint and test commands

**FAIL** (Score < 10.0):
- ❌ Any lint tool fails
- ❌ 1+ lint errors detected
- ❌ 1+ lint warnings detected
- ❌ 1+ test failures detected
- ❌ Non-zero exit code from lint or test commands

---

## Integration with Phase 4

This evaluator runs **after** all Phase 4 workers complete:

```
Database Worker → Backend Worker → Frontend Worker → Test Worker
                                                           ↓
                                                  Quality Gate Evaluator
                                                   (Lint + Test Check)
                                                           ↓
                                    Score 10.0 → Proceed to Phase 5
                                    Score < 10.0 → Re-run affected workers
```

If quality gate fails:
1. Parse affected files to identify workers (from both lint and test errors)
2. Re-invoke each affected worker with combined error feedback
3. Workers fix quality issues (lint + test failures)
4. Re-run quality-gate-evaluator
5. Repeat until Score 10.0 achieved

---

## Example Output

### PASS Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 STEP 1/2: Lint Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Running 3 configured lint tool(s)...
▶️  Running eslint...
   ✅ eslint passed
▶️  Running prettier...
   ✅ prettier passed
▶️  Running tsc...
   ✅ tsc passed

✅ Passed (3):
   • eslint
   • prettier
   • tsc

📊 Lint Results:
   Passed: 3
   Failed: 0
   Status: ✅ PASS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 STEP 2/2: Test Execution
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶️  Running: npm test

 PASS  src/auth/auth.test.ts
 PASS  src/users/users.test.ts
 PASS  src/api/api.test.ts

Tests: 15 passed, 15 total

📊 Test Results:
   Total: 15
   Passed: 15
   Failed: 0
   Status: ✅ PASS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ QUALITY GATE PASSED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
All quality checks passed:
  ✅ Lint: Zero errors, zero warnings
  ✅ Tests: All tests passing

📄 Report saved: .steering/2026-01-01-user-auth/reports/phase4-quality-gate.md
```

### FAIL Example (Lint Errors)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 STEP 1/2: Lint Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Running 3 configured lint tool(s)...
▶️  Running eslint...
   ❌ eslint failed

   src/api/users.ts
     12:5  error  'userId' is defined but never used  @typescript-eslint/no-unused-vars

▶️  Running prettier...
   ✅ prettier passed
▶️  Running tsc...
   ✅ tsc passed

❌ Failed (1):
   • eslint

📊 Lint Results:
   Passed: 2
   Failed: 1
   Status: ❌ FAIL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 STEP 2/2: Test Execution
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶️  Running: npm test

 PASS  src/auth/auth.test.ts
 PASS  src/users/users.test.ts

Tests: 10 passed, 10 total

📊 Test Results:
   Total: 10
   Passed: 10
   Failed: 0
   Status: ✅ PASS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ QUALITY GATE FAILED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quality violations detected:
  ❌ Lint: 1 tool(s) failed

Phase 4 workers must fix all issues and re-run

📄 Report saved: .steering/2026-01-01-user-auth/reports/phase4-quality-gate.md

Affected Workers: backend-worker-v1-self-adapting
```

### FAIL Example (Test Failures)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 STEP 1/2: Lint Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Running 3 configured lint tool(s)...
▶️  Running eslint...
   ✅ eslint passed
▶️  Running prettier...
   ✅ prettier passed
▶️  Running tsc...
   ✅ tsc passed

✅ Passed (3):
   • eslint
   • prettier
   • tsc

📊 Lint Results:
   Passed: 3
   Failed: 0
   Status: ✅ PASS

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 STEP 2/2: Test Execution
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶️  Running: npm test

 PASS  src/auth/auth.test.ts
 FAIL  src/users/users.test.ts
   ● UserService › should create user

     expect(received).toHaveBeenCalledWith(...)
     Expected: {"email": "test@example.com", "name": "Test User"}
     Received: {"email": "test@example.com"}

Tests: 2 failed, 13 passed, 15 total

📊 Test Results:
   Total: 15
   Passed: 13
   Failed: 2
   Status: ❌ FAIL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ QUALITY GATE FAILED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quality violations detected:
  ❌ Tests: 2 test(s) failed

Phase 4 workers must fix all issues and re-run

📄 Report saved: .steering/2026-01-01-user-auth/reports/phase4-quality-gate.md

Affected Workers: backend-worker-v1-self-adapting, test-worker-v1-self-adapting
```

### FAIL Example (Both Lint and Test Failures)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 STEP 1/2: Lint Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Running 2 configured lint tool(s)...
▶️  Running eslint...
   ❌ eslint failed
▶️  Running tsc...
   ❌ tsc failed

❌ Failed (2):
   • eslint
   • tsc

📊 Lint Results:
   Passed: 0
   Failed: 2
   Status: ❌ FAIL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧪 STEP 2/2: Test Execution
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

▶️  Running: npm test

 FAIL  src/auth/auth.test.ts
 FAIL  src/users/users.test.ts

Tests: 5 failed, 10 passed, 15 total

📊 Test Results:
   Total: 15
   Passed: 10
   Failed: 5
   Status: ❌ FAIL

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ QUALITY GATE FAILED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Quality violations detected:
  ❌ Lint: 2 tool(s) failed
  ❌ Tests: 5 test(s) failed

Phase 4 workers must fix all issues and re-run

📄 Report saved: .steering/2026-01-01-user-auth/reports/phase4-quality-gate.md

Affected Workers: backend-worker-v1-self-adapting, frontend-worker-v1-self-adapting, test-worker-v1-self-adapting
```

---

## Notes

- **Zero Tolerance**: This evaluator is intentionally strict - both lint warnings and test failures are treated as hard failures
- **CI Alignment**: Matches CI/CD pipeline behavior where any quality violation blocks merging
- **Dual Gate**: Combines lint quality (code style/syntax) with test quality (functional correctness)
- **Auto-Fix Guidance**: Workers receive specific error messages from both lint and test failures
- **No Manual Intervention**: Automated feedback loop ensures quality without human involvement
- **Model Selection**: Uses `sonnet` for balance of speed and reliability in parsing both lint and test output
- **Test Framework Agnostic**: Supports Jest, Vitest, Pytest, Go test, Mocha, and other common test frameworks
- **Upgrade from lint-evaluator**: This replaces the previous lint-only evaluator with comprehensive quality checking
