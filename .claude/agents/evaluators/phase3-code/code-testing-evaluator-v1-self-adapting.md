# Code Testing Evaluator v1 - Self-Adapting

**Version**: 2.0
**Type**: Code Evaluator (Self-Adapting)
**Language Support**: Universal (TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#, Kotlin, Swift)
**Frameworks**: All testing frameworks
**Status**: Production Ready

---

## 🎯 Overview

### What This Evaluator Does

This evaluator analyzes test coverage and quality using language-specific testing frameworks:

1. **Test Coverage** - Line, branch, function, and statement coverage
2. **Test Quality** - Test pyramid adherence, test organization
3. **Test Completeness** - All critical paths tested
4. **Test Performance** - Test execution time
5. **Mocking Strategy** - Proper use of mocks/stubs/spies

### Self-Adapting Features

✅ **Automatic Framework Detection** - Jest, pytest, JUnit, Go test, Rust test, etc.
✅ **Coverage Tool Detection** - Finds coverage.py, JaCoCo, go test -cover, etc.
✅ **Test Pattern Learning** - Learns test organization from existing tests
✅ **Universal Scoring** - Normalizes all frameworks to 0-5 scale
✅ **Zero Configuration** - Works out of the box

---

## 🔍 Detection System

### Layer 1: Automatic Detection

```typescript
async function detectTestingTools(): Promise<TestingTools> {
  // Step 1: Detect language
  const language = await detectLanguage()

  // Step 2: Detect testing framework
  const framework = await detectTestFramework(language)

  // Step 3: Detect coverage tool
  const coverageTool = await detectCoverageTool(language, framework)

  // Step 4: Find existing tests
  const existingTests = await findExistingTests(language, framework)

  // Step 5: Learn test patterns
  const patterns = await learnTestPatterns(existingTests)

  return { language, framework, coverageTool, patterns }
}
```

### Layer 2: Configuration File (if needed)

```yaml
# .claude/edaf-config.yml
testing:
  language: typescript
  framework: jest
  coverage_tool: jest
  coverage_threshold:
    lines: 80
    branches: 75
    functions: 80
    statements: 80
  test_directories:
    - src/**/*.test.ts
    - tests/**/*.ts
```

### Layer 3: User Questions (fallback)

If detection fails, ask user:
- What testing framework? (Jest, pytest, JUnit, etc.)
- What coverage tool? (jest, coverage.py, JaCoCo, etc.)
- Coverage threshold? (default: 80%)
- Where are test files located?

---

## 🛠️ Language-Specific Framework Detection

### TypeScript/JavaScript

```typescript
const jsTestingFrameworks = {
  'jest': {
    indicators: {
      dependencies: ['jest', '@types/jest'],
      configFiles: ['jest.config.js', 'jest.config.ts', 'jest.config.json'],
      testPatterns: ['**/*.test.{js,ts,tsx}', '**/*.spec.{js,ts,tsx}']
    },
    coverage: {
      command: 'npx jest --coverage --json',
      reporters: ['text', 'json', 'lcov', 'html'],
      thresholds: {
        global: {
          lines: 80,
          branches: 75,
          functions: 80,
          statements: 80
        }
      }
    },
    assertions: ['expect', 'toBe', 'toEqual', 'toHaveBeenCalled']
  },

  'vitest': {
    indicators: {
      dependencies: ['vitest'],
      configFiles: ['vitest.config.ts', 'vite.config.ts'],
      testPatterns: ['**/*.test.{js,ts,tsx}', '**/*.spec.{js,ts,tsx}']
    },
    coverage: {
      command: 'npx vitest run --coverage --reporter=json',
      tool: 'c8',
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80
      }
    }
  },

  'mocha': {
    indicators: {
      dependencies: ['mocha'],
      configFiles: ['.mocharc.js', '.mocharc.json'],
      testPatterns: ['test/**/*.js', 'spec/**/*.js']
    },
    coverage: {
      tool: 'nyc',
      command: 'npx nyc mocha --reporter=json'
    },
    assertions: ['chai', 'assert', 'should']
  },

  'playwright': {
    indicators: {
      dependencies: ['@playwright/test'],
      configFiles: ['playwright.config.ts'],
      testPatterns: ['e2e/**/*.spec.ts', 'tests/**/*.spec.ts']
    },
    type: 'e2e',
    coverage: {
      // E2E tests typically don't have coverage
      command: null
    }
  },

  'cypress': {
    indicators: {
      dependencies: ['cypress'],
      configFiles: ['cypress.config.ts', 'cypress.json'],
      testPatterns: ['cypress/e2e/**/*.cy.{js,ts}']
    },
    type: 'e2e'
  }
}
```

**Detection Logic**:
```typescript
async function detectJSTestFramework(): Promise<JSTestFramework> {
  const packageJson = await Read('package.json')
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies }

  // Detect unit test framework
  const unitFramework =
    deps['jest'] ? 'jest' :
    deps['vitest'] ? 'vitest' :
    deps['mocha'] ? 'mocha' :
    null

  // Detect e2e framework
  const e2eFramework =
    deps['@playwright/test'] ? 'playwright' :
    deps['cypress'] ? 'cypress' :
    null

  // Detect coverage tool
  const coverageTool =
    unitFramework === 'jest' ? 'jest' :
    unitFramework === 'vitest' ? 'c8' :
    deps['nyc'] ? 'nyc' :
    deps['c8'] ? 'c8' :
    null

  // Find test files
  const testFiles = await findTestFiles(unitFramework, e2eFramework)

  return {
    unit: unitFramework,
    e2e: e2eFramework,
    coverage: coverageTool,
    testFiles
  }
}
```

### Python

```typescript
const pythonTestingFrameworks = {
  'pytest': {
    indicators: {
      dependencies: ['pytest'],
      configFiles: ['pytest.ini', 'pyproject.toml', 'setup.cfg'],
      testPatterns: ['**/test_*.py', '**/*_test.py', 'tests/**/*.py']
    },
    coverage: {
      tool: 'coverage.py',
      command: 'pytest --cov=. --cov-report=json',
      pluginRequired: 'pytest-cov',
      thresholds: {
        lines: 80,
        branches: 75
      }
    },
    assertions: ['assert', 'pytest.raises', 'pytest.warns']
  },

  'unittest': {
    indicators: {
      dependencies: [],  // Built-in
      testPatterns: ['**/test_*.py', 'tests/**/*.py'],
      imports: ['import unittest', 'from unittest import']
    },
    coverage: {
      tool: 'coverage.py',
      command: 'coverage run -m unittest discover && coverage json'
    },
    assertions: ['assertEqual', 'assertTrue', 'assertRaises']
  },

  'nose2': {
    indicators: {
      dependencies: ['nose2'],
      configFiles: ['.nose2.cfg', 'nose2.cfg']
    },
    coverage: {
      tool: 'coverage.py',
      command: 'nose2 --with-coverage --coverage-report json'
    }
  }
}
```

**Detection Logic**:
```typescript
async function detectPythonTestFramework(): Promise<PythonTestFramework> {
  const requirementsTxt = await Read('requirements.txt').catch(() => null)
  const pyprojectToml = await Read('pyproject.toml').catch(() => null)

  // Detect framework
  const framework =
    requirementsTxt?.includes('pytest') || pyprojectToml?.includes('pytest') ? 'pytest' :
    requirementsTxt?.includes('nose2') ? 'nose2' :
    await hasUnittestTests() ? 'unittest' :
    null

  // Detect coverage tool
  const hasCoveragePy = requirementsTxt?.includes('coverage') ||
                        requirementsTxt?.includes('pytest-cov')

  // Find test files
  const testFiles = await Glob({ pattern: '**/test_*.py' })

  return {
    framework,
    coverageTool: hasCoveragePy ? 'coverage.py' : null,
    testFiles
  }
}

async function hasUnittestTests(): Promise<boolean> {
  const testFiles = await Glob({ pattern: '**/test_*.py' })
  if (testFiles.length === 0) return false

  // Check if any file imports unittest
  const firstTest = await Read(testFiles[0])
  return firstTest.includes('import unittest') || firstTest.includes('from unittest')
}
```

### Java

```typescript
const javaTestingFrameworks = {
  'junit5': {
    indicators: {
      dependencies: ['junit-jupiter', 'junit-jupiter-api'],
      imports: ['org.junit.jupiter'],
      annotations: ['@Test', '@BeforeEach', '@AfterEach']
    },
    coverage: {
      tool: 'jacoco',
      configFiles: ['pom.xml', 'build.gradle'],
      command: 'mvn test jacoco:report',
      reportFormats: ['xml', 'html', 'csv']
    },
    assertions: ['assertEquals', 'assertTrue', 'assertThrows']
  },

  'junit4': {
    indicators: {
      dependencies: ['junit'],
      imports: ['org.junit'],
      annotations: ['@Test', '@Before', '@After']
    },
    coverage: {
      tool: 'jacoco',
      command: 'mvn test jacoco:report'
    }
  },

  'testng': {
    indicators: {
      dependencies: ['testng'],
      imports: ['org.testng'],
      annotations: ['@Test', '@BeforeMethod', '@AfterMethod']
    },
    coverage: {
      tool: 'jacoco',
      command: 'mvn test jacoco:report'
    }
  },

  'spring-boot-test': {
    indicators: {
      dependencies: ['spring-boot-starter-test'],
      annotations: ['@SpringBootTest', '@WebMvcTest']
    },
    coverage: {
      tool: 'jacoco',
      command: 'mvn test jacoco:report'
    }
  }
}
```

**Detection Logic**:
```typescript
async function detectJavaTestFramework(): Promise<JavaTestFramework> {
  const pomXml = await Read('pom.xml').catch(() => null)
  const buildGradle = await Read('build.gradle').catch(() => null)

  // Detect framework from dependencies
  const framework =
    pomXml?.includes('junit-jupiter') || buildGradle?.includes('junit-jupiter') ? 'junit5' :
    pomXml?.includes('<artifactId>junit</artifactId>') ? 'junit4' :
    pomXml?.includes('testng') || buildGradle?.includes('testng') ? 'testng' :
    null

  // JaCoCo is standard for Java
  const hasJaCoCo = pomXml?.includes('jacoco') || buildGradle?.includes('jacoco')

  // Find test files
  const testFiles = await Glob({ pattern: '**/src/test/**/*.java' })

  return {
    framework,
    coverageTool: hasJaCoCo ? 'jacoco' : null,
    buildTool: pomXml ? 'maven' : buildGradle ? 'gradle' : null,
    testFiles
  }
}
```

### Go

```typescript
const goTestingFrameworks = {
  'testing': {
    indicators: {
      builtin: true,
      testPatterns: ['**/*_test.go'],
      imports: ['testing']
    },
    coverage: {
      builtin: true,
      command: 'go test -coverprofile=coverage.out -covermode=atomic -json',
      formats: ['html', 'func', 'profile'],
      thresholds: {
        coverage: 80
      }
    },
    assertions: ['t.Error', 't.Fail', 't.Fatalf']
  },

  'testify': {
    indicators: {
      dependencies: ['github.com/stretchr/testify'],
      imports: ['github.com/stretchr/testify/assert']
    },
    coverage: {
      command: 'go test -coverprofile=coverage.out -json'
    },
    assertions: ['assert.Equal', 'assert.NoError', 'require.NotNil']
  },

  'ginkgo': {
    indicators: {
      dependencies: ['github.com/onsi/ginkgo'],
      imports: ['github.com/onsi/ginkgo']
    },
    type: 'bdd',
    coverage: {
      command: 'ginkgo -r --cover --coverprofile=coverage.out'
    }
  }
}
```

**Detection Logic**:
```typescript
async function detectGoTestFramework(): Promise<GoTestFramework> {
  const goMod = await Read('go.mod').catch(() => null)

  // Go always has built-in testing
  const hasTestify = goMod?.includes('github.com/stretchr/testify')
  const hasGinkgo = goMod?.includes('github.com/onsi/ginkgo')

  // Find test files
  const testFiles = await Glob({ pattern: '**/*_test.go' })

  return {
    framework: hasGinkgo ? 'ginkgo' : hasTestify ? 'testify' : 'testing',
    coverageTool: 'built-in',  // Go has built-in coverage
    testFiles
  }
}
```

### Rust

```typescript
const rustTestingFrameworks = {
  'cargo-test': {
    indicators: {
      builtin: true,
      testPatterns: ['**/*.rs'],  // Tests are inline
      attributes: ['#[test]', '#[cfg(test)]']
    },
    coverage: {
      tool: 'cargo-tarpaulin',
      command: 'cargo tarpaulin --out Json',
      optional: true
    },
    assertions: ['assert!', 'assert_eq!', 'assert_ne!']
  }
}
```

**Detection Logic**:
```typescript
async function detectRustTestFramework(): Promise<RustTestFramework> {
  const cargoToml = await Read('Cargo.toml').catch(() => null)

  // Rust always has built-in testing
  const hasTarpaulin = cargoToml?.includes('tarpaulin')

  // Find files with tests (check for #[test] or #[cfg(test)])
  const srcFiles = await Glob({ pattern: 'src/**/*.rs' })

  return {
    framework: 'cargo-test',
    coverageTool: hasTarpaulin ? 'cargo-tarpaulin' : null,
    testFiles: srcFiles  // Tests are inline in Rust
  }
}
```

### Ruby

```typescript
const rubyTestingFrameworks = {
  'rspec': {
    indicators: {
      dependencies: ['rspec'],
      configFiles: ['.rspec', 'spec/spec_helper.rb'],
      testPatterns: ['spec/**/*_spec.rb']
    },
    coverage: {
      tool: 'simplecov',
      gemRequired: 'simplecov',
      setup: "require 'simplecov'\nSimpleCov.start"
    },
    assertions: ['expect', 'to', 'not_to']
  },

  'minitest': {
    indicators: {
      builtin: true,  // Built into Ruby
      testPatterns: ['test/**/*_test.rb'],
      imports: ['minitest/autorun']
    },
    coverage: {
      tool: 'simplecov'
    },
    assertions: ['assert', 'refute', 'assert_equal']
  }
}
```

### PHP

```typescript
const phpTestingFrameworks = {
  'phpunit': {
    indicators: {
      dependencies: ['phpunit/phpunit'],
      configFiles: ['phpunit.xml', 'phpunit.xml.dist'],
      testPatterns: ['tests/**/*Test.php']
    },
    coverage: {
      command: 'phpunit --coverage-clover coverage.xml',
      requirements: ['xdebug extension'],
      formats: ['clover', 'html', 'text']
    },
    assertions: ['assertEquals', 'assertTrue', 'assertInstanceOf']
  }
}
```

---

## 📊 Universal Test Metrics

### 1. Test Coverage

```typescript
interface CoverageMetrics {
  lines: {
    covered: number
    total: number
    percentage: number
  }
  branches: {
    covered: number
    total: number
    percentage: number
  }
  functions: {
    covered: number
    total: number
    percentage: number
  }
  statements: {
    covered: number
    total: number
    percentage: number
  }
}
```

**Scoring Formula**:
```typescript
function calculateCoverageScore(metrics: CoverageMetrics): number {
  // Weighted average (branches are most important)
  const weights = {
    lines: 0.25,
    branches: 0.35,
    functions: 0.25,
    statements: 0.15
  }

  const score = (
    (metrics.lines.percentage / 100) * weights.lines +
    (metrics.branches.percentage / 100) * weights.branches +
    (metrics.functions.percentage / 100) * weights.functions +
    (metrics.statements.percentage / 100) * weights.statements
  ) * 5.0

  return score
}
```

**Examples**:
- 100% all metrics = 5.0/5.0
- 80% lines, 75% branches, 80% functions, 80% statements = 3.9/5.0
- 50% all metrics = 2.5/5.0

### 2. Test Pyramid

```typescript
interface TestPyramid {
  unit: number        // Number of unit tests
  integration: number // Number of integration tests
  e2e: number        // Number of E2E tests
  total: number
}
```

**Recommended Ratio**: 70% unit, 20% integration, 10% e2e

**Scoring Formula**:
```typescript
function calculatePyramidScore(pyramid: TestPyramid): number {
  const { unit, integration, e2e, total } = pyramid

  if (total === 0) return 0

  // Calculate percentages
  const unitPct = (unit / total) * 100
  const integrationPct = (integration / total) * 100
  const e2ePct = (e2e / total) * 100

  // Ideal ratios
  const idealUnit = 70
  const idealIntegration = 20
  const idealE2E = 10

  // Calculate deviation from ideal
  const deviation = (
    Math.abs(unitPct - idealUnit) +
    Math.abs(integrationPct - idealIntegration) +
    Math.abs(e2ePct - idealE2E)
  ) / 3

  // Convert deviation to score (lower deviation = higher score)
  // 0% deviation = 5.0, 50% deviation = 0
  const score = Math.max(0, 5.0 - (deviation / 10))

  return score
}
```

**Examples**:
- 70% unit, 20% integration, 10% e2e = 5.0/5.0 (perfect)
- 50% unit, 30% integration, 20% e2e = 3.3/5.0
- 90% e2e, 10% unit, 0% integration = 1.2/5.0 (inverted pyramid)

### 3. Test Quality

```typescript
interface TestQualityMetrics {
  averageAssertionsPerTest: number
  testsWithoutAssertions: number
  testNamingQuality: number  // 0-1 (descriptive names)
  setupTeardownUsage: number // 0-1 (proper cleanup)
  mockingQuality: number     // 0-1 (appropriate mocking)
}
```

**Scoring Formula**:
```typescript
function calculateTestQualityScore(metrics: TestQualityMetrics, totalTests: number): number {
  let score = 5.0

  // Deduct for tests without assertions
  const noAssertionRatio = metrics.testsWithoutAssertions / totalTests
  score -= noAssertionRatio * 2.0

  // Deduct for poor test names
  score -= (1 - metrics.testNamingQuality) * 1.0

  // Deduct for missing setup/teardown
  score -= (1 - metrics.setupTeardownUsage) * 0.5

  // Deduct for poor mocking
  score -= (1 - metrics.mockingQuality) * 0.5

  return Math.max(score, 0)
}
```

### 4. Test Performance

```typescript
interface TestPerformanceMetrics {
  totalDuration: number      // Milliseconds
  slowestTest: number        // Milliseconds
  averageDuration: number    // Milliseconds
  totalTests: number
}
```

**Scoring Formula**:
```typescript
function calculateTestPerformanceScore(metrics: TestPerformanceMetrics): number {
  let score = 5.0

  // Deduct for slow test suite (> 60s)
  if (metrics.totalDuration > 60000) {
    score -= (metrics.totalDuration - 60000) / 30000  // -1 point per 30s over
  }

  // Deduct for slow individual tests (> 5s)
  if (metrics.slowestTest > 5000) {
    score -= 1.0
  }

  return Math.max(score, 0)
}
```

### 5. Critical Path Coverage

```typescript
interface CriticalPathMetrics {
  criticalPaths: string[]           // Identified critical code paths
  testedPaths: string[]             // Paths with tests
  coveragePercentage: number
}
```

**Scoring Formula**:
```typescript
function calculateCriticalPathScore(metrics: CriticalPathMetrics): number {
  // Critical paths MUST be tested
  return (metrics.coveragePercentage / 100) * 5.0
}
```

---

## 🎯 Evaluation Process

### Step 1: Detect Testing Environment

```typescript
async function detectTestingEnvironment(): Promise<TestingEnvironment> {
  // Detect language
  const language = await detectLanguage()

  // Detect framework
  const framework = await detectTestFramework(language)

  // Detect coverage tool
  const coverageTool = await detectCoverageTool(language, framework)

  // Find test files
  const testFiles = await findTestFiles(framework)

  // Learn test patterns from existing tests
  const patterns = await learnTestPatterns(testFiles)

  return { language, framework, coverageTool, testFiles, patterns }
}
```

### Step 2: Run Tests with Coverage

```typescript
async function runTestsWithCoverage(env: TestingEnvironment): Promise<TestResults> {
  const { language, framework, coverageTool } = env

  // Build command based on detected tools
  const command = buildTestCommand(language, framework, coverageTool)

  // Run tests
  const result = await Bash({
    command,
    description: `Run ${framework} tests with coverage`
  })

  // Parse results
  return parseTestResults(result, framework, coverageTool)
}
```

**Example Commands by Framework**:
```typescript
const testCommands = {
  jest: 'npx jest --coverage --json --outputFile=coverage.json',
  vitest: 'npx vitest run --coverage --reporter=json',
  pytest: 'pytest --cov=. --cov-report=json --json-report',
  'go-test': 'go test -coverprofile=coverage.out -json ./...',
  'cargo-test': 'cargo test --no-fail-fast -- --format json',
  junit: 'mvn test jacoco:report',
  phpunit: 'phpunit --coverage-clover coverage.xml'
}
```

### Step 3: Analyze Test Pyramid

```typescript
async function analyzeTestPyramid(testFiles: string[]): Promise<TestPyramid> {
  const pyramid = {
    unit: 0,
    integration: 0,
    e2e: 0,
    total: testFiles.length
  }

  // Classify each test file
  for (const file of testFiles) {
    const content = await Read(file)
    const type = classifyTestType(file, content)

    if (type === 'unit') pyramid.unit++
    else if (type === 'integration') pyramid.integration++
    else if (type === 'e2e') pyramid.e2e++
  }

  return pyramid
}

function classifyTestType(filename: string, content: string): 'unit' | 'integration' | 'e2e' {
  // E2E indicators
  if (
    filename.includes('e2e') ||
    filename.includes('.cy.') ||  // Cypress
    filename.includes('.spec.') && content.includes('@playwright') ||
    content.includes('browser.') ||
    content.includes('page.')
  ) {
    return 'e2e'
  }

  // Integration indicators
  if (
    filename.includes('integration') ||
    content.includes('@SpringBootTest') ||
    content.includes('TestContainers') ||
    content.includes('supertest') ||
    content.includes('request(app)')
  ) {
    return 'integration'
  }

  // Default to unit
  return 'unit'
}
```

### Step 4: Analyze Test Quality

```typescript
async function analyzeTestQuality(testFiles: string[]): Promise<TestQualityMetrics> {
  const metrics = {
    averageAssertionsPerTest: 0,
    testsWithoutAssertions: 0,
    testNamingQuality: 0,
    setupTeardownUsage: 0,
    mockingQuality: 0
  }

  let totalAssertions = 0
  let totalTests = 0
  let wellNamedTests = 0
  let testsWithSetup = 0
  let testsWithMocks = 0

  for (const file of testFiles) {
    const content = await Read(file)
    const analysis = analyzeTestFile(content)

    totalTests += analysis.testCount
    totalAssertions += analysis.assertionCount
    if (analysis.assertionCount === 0) metrics.testsWithoutAssertions++
    if (analysis.hasDescriptiveNames) wellNamedTests++
    if (analysis.hasSetupTeardown) testsWithSetup++
    if (analysis.hasMocking) testsWithMocks++
  }

  metrics.averageAssertionsPerTest = totalAssertions / totalTests
  metrics.testNamingQuality = wellNamedTests / testFiles.length
  metrics.setupTeardownUsage = testsWithSetup / testFiles.length
  metrics.mockingQuality = testsWithMocks / testFiles.length

  return metrics
}
```

### Step 5: Calculate Scores

```typescript
async function calculateTestingScore(
  coverage: CoverageMetrics,
  pyramid: TestPyramid,
  quality: TestQualityMetrics,
  performance: TestPerformanceMetrics
): Promise<EvaluationResult> {
  const scores = {
    coverage: calculateCoverageScore(coverage),
    pyramid: calculatePyramidScore(pyramid),
    quality: calculateTestQualityScore(quality, pyramid.total),
    performance: calculateTestPerformanceScore(performance)
  }

  // Weighted average (coverage is most important)
  const weights = {
    coverage: 0.50,
    pyramid: 0.20,
    quality: 0.20,
    performance: 0.10
  }

  const overallScore = (
    scores.coverage * weights.coverage +
    scores.pyramid * weights.pyramid +
    scores.quality * weights.quality +
    scores.performance * weights.performance
  )

  return {
    overallScore,
    breakdown: scores,
    metrics: { coverage, pyramid, quality, performance },
    recommendations: generateRecommendations(scores, coverage, pyramid, quality)
  }
}
```

---

## 🔧 Implementation Examples

### TypeScript/Jest Project

```typescript
async function evaluateJestTests(changedFiles: string[]): Promise<TestingReport> {
  // Run Jest with coverage
  const jestResult = await Bash({
    command: 'npx jest --coverage --json --outputFile=coverage.json --testLocationInResults',
    description: 'Run Jest tests with coverage'
  })

  const coverage = JSON.parse(await Read('coverage/coverage-final.json'))
  const testResults = JSON.parse(await Read('coverage.json'))

  // Parse coverage
  const coverageMetrics = parseCoverage(coverage)

  // Analyze test pyramid
  const testFiles = testResults.testResults.map(r => r.name)
  const pyramid = await analyzeTestPyramid(testFiles)

  // Analyze test quality
  const quality = await analyzeTestQuality(testFiles)

  // Analyze performance
  const performance = {
    totalDuration: testResults.testResults.reduce((sum, r) => sum + r.endTime - r.startTime, 0),
    slowestTest: Math.max(...testResults.testResults.map(r => r.endTime - r.startTime)),
    averageDuration: testResults.testResults.reduce((sum, r) => sum + r.endTime - r.startTime, 0) / testResults.numTotalTests,
    totalTests: testResults.numTotalTests
  }

  // Calculate scores
  return calculateTestingScore(coverageMetrics, pyramid, quality, performance)
}

function parseCoverage(coverageFinal: any): CoverageMetrics {
  // Jest coverage format
  const summary = Object.values(coverageFinal).reduce((acc: any, file: any) => {
    return {
      lines: {
        covered: acc.lines.covered + file.lines.covered,
        total: acc.lines.total + file.lines.total
      },
      branches: {
        covered: acc.branches.covered + file.branches.covered,
        total: acc.branches.total + file.branches.total
      },
      functions: {
        covered: acc.functions.covered + file.functions.covered,
        total: acc.functions.total + file.functions.total
      },
      statements: {
        covered: acc.statements.covered + file.statements.covered,
        total: acc.statements.total + file.statements.total
      }
    }
  }, { lines: {covered:0, total:0}, branches: {covered:0, total:0}, functions: {covered:0, total:0}, statements: {covered:0, total:0} })

  return {
    lines: {
      ...summary.lines,
      percentage: (summary.lines.covered / summary.lines.total) * 100
    },
    branches: {
      ...summary.branches,
      percentage: (summary.branches.covered / summary.branches.total) * 100
    },
    functions: {
      ...summary.functions,
      percentage: (summary.functions.covered / summary.functions.total) * 100
    },
    statements: {
      ...summary.statements,
      percentage: (summary.statements.covered / summary.statements.total) * 100
    }
  }
}
```

### Python/pytest Project

```typescript
async function evaluatePytestTests(changedFiles: string[]): Promise<TestingReport> {
  // Run pytest with coverage
  const pytestResult = await Bash({
    command: 'pytest --cov=. --cov-report=json --json-report --json-report-file=test-report.json',
    description: 'Run pytest tests with coverage'
  })

  const coverageData = JSON.parse(await Read('coverage.json'))
  const testReport = JSON.parse(await Read('test-report.json'))

  // Parse coverage (coverage.py format)
  const coverageMetrics = {
    lines: {
      covered: coverageData.totals.covered_lines,
      total: coverageData.totals.num_statements,
      percentage: coverageData.totals.percent_covered
    },
    branches: {
      covered: coverageData.totals.covered_branches || 0,
      total: coverageData.totals.num_branches || 0,
      percentage: coverageData.totals.percent_covered_branches || 0
    },
    functions: {
      // coverage.py doesn't track functions separately
      covered: 0,
      total: 0,
      percentage: 0
    },
    statements: {
      covered: coverageData.totals.covered_lines,
      total: coverageData.totals.num_statements,
      percentage: coverageData.totals.percent_covered
    }
  }

  // Analyze test pyramid
  const testFiles = Object.keys(testReport.tests)
  const pyramid = await analyzeTestPyramid(testFiles)

  return calculateTestingScore(coverageMetrics, pyramid, ...)
}
```

### Go Project

```typescript
async function evaluateGoTests(changedFiles: string[]): Promise<TestingReport> {
  // Run go test with coverage
  const goTestResult = await Bash({
    command: 'go test -coverprofile=coverage.out -covermode=atomic -json ./...',
    description: 'Run Go tests with coverage'
  })

  // Parse JSON output
  const testEvents = goTestResult.split('\n')
    .filter(line => line.trim())
    .map(line => JSON.parse(line))

  // Parse coverage
  const coverageOut = await Read('coverage.out')
  const coverageMetrics = parseGoCoverage(coverageOut)

  // Analyze test pyramid
  const testFiles = await Glob({ pattern: '**/*_test.go' })
  const pyramid = await analyzeTestPyramid(testFiles)

  return calculateTestingScore(coverageMetrics, pyramid, ...)
}

function parseGoCoverage(coverageOut: string): CoverageMetrics {
  // Go coverage format: mode: atomic
  // file.go:10.2,12.3 2 1
  const lines = coverageOut.split('\n').slice(1)  // Skip mode line

  let totalStatements = 0
  let coveredStatements = 0

  for (const line of lines) {
    if (!line.trim()) continue
    const parts = line.split(' ')
    const stmtCount = parseInt(parts[1])
    const execCount = parseInt(parts[2])

    totalStatements += stmtCount
    if (execCount > 0) coveredStatements += stmtCount
  }

  const percentage = (coveredStatements / totalStatements) * 100

  return {
    lines: { covered: coveredStatements, total: totalStatements, percentage },
    branches: { covered: 0, total: 0, percentage: 0 },  // Go doesn't track separately
    functions: { covered: 0, total: 0, percentage: 0 },
    statements: { covered: coveredStatements, total: totalStatements, percentage }
  }
}
```

---

## 📐 Score Normalization Across Frameworks

```typescript
interface NormalizedTestResults {
  framework: string
  coverage: CoverageMetrics  // Always in same format
  score: number              // Always 0-5
}

function normalizeTestResults(framework: string, rawResults: any): NormalizedTestResults {
  // Different frameworks report differently
  const normalizers = {
    jest: normalizeJestResults,
    pytest: normalizePytestResults,
    'go-test': normalizeGoTestResults,
    junit: normalizeJUnitResults,
    'cargo-test': normalizeCargoTestResults
  }

  const normalizer = normalizers[framework] || defaultNormalizer
  return normalizer(rawResults)
}
```

---

## ⚠️ Edge Cases

### Case 1: No Tests Exist

```typescript
async function handleNoTests(): Promise<TestingReport> {
  return {
    timestamp: new Date().toISOString(),
    framework: null,
    coverageTool: null,
    scores: {
      overall: 0,
      coverage: 0,
      pyramid: 0,
      quality: 0,
      performance: 0
    },
    recommendations: [
      {
        priority: 'critical',
        category: 'testing',
        message: 'No tests found! Add unit tests to ensure code correctness.',
        actionable: true
      }
    ],
    passFail: 'FAIL',
    threshold: 3.5
  }
}
```

### Case 2: Coverage Tool Not Installed

```typescript
async function handleNoCoverageTool(framework: string): Promise<void> {
  const recommendations = {
    jest: 'Coverage is built into Jest. Use: npx jest --coverage',
    pytest: 'Install pytest-cov: pip install pytest-cov',
    junit: 'Add JaCoCo to pom.xml or build.gradle',
    'go-test': 'Coverage is built-in. Use: go test -cover'
  }

  console.warn(`⚠️ Coverage tool not found. ${recommendations[framework]}`)

  // Run tests without coverage
  return await runTestsWithoutCoverage(framework)
}
```

### Case 3: Tests Pass but Coverage Low

```typescript
async function handleLowCoverage(coverage: CoverageMetrics): Promise<Recommendation[]> {
  const recommendations = []

  if (coverage.lines.percentage < 80) {
    recommendations.push({
      priority: 'high',
      category: 'coverage',
      message: `Line coverage is ${coverage.lines.percentage}%, below 80% threshold. Add tests for uncovered code paths.`,
      actionable: true
    })
  }

  if (coverage.branches.percentage < 75) {
    recommendations.push({
      priority: 'high',
      category: 'coverage',
      message: `Branch coverage is ${coverage.branches.percentage}%, below 75% threshold. Add tests for conditional branches.`,
      actionable: true
    })
  }

  return recommendations
}
```

---

## 📋 Configuration File Format

```yaml
# .claude/edaf-config.yml

testing:
  # Framework (auto-detected if not specified)
  framework: jest

  # Coverage tool
  coverage:
    tool: jest
    thresholds:
      lines: 80
      branches: 75
      functions: 80
      statements: 80

  # Test directories
  test_directories:
    - src/**/*.test.ts
    - tests/**/*.spec.ts

  # Test pyramid ratios (ideal)
  pyramid:
    unit: 70
    integration: 20
    e2e: 10

  # Performance limits
  performance:
    max_suite_duration: 60000  # ms
    max_test_duration: 5000    # ms

  # Quality checks
  quality:
    min_assertions_per_test: 1
    require_descriptive_names: true
    require_setup_teardown: false
```

---

## 📊 Output Format

```json
{
  "evaluator": "code-testing-evaluator-v1-self-adapting",
  "version": "2.0",
  "timestamp": "2025-11-09T10:30:00Z",
  "pr_number": 42,

  "environment": {
    "language": "typescript",
    "framework": "jest",
    "coverage_tool": "jest",
    "test_files": 45
  },

  "scores": {
    "overall": 4.3,
    "breakdown": {
      "coverage": 4.5,
      "pyramid": 4.8,
      "quality": 4.0,
      "performance": 3.8
    }
  },

  "metrics": {
    "coverage": {
      "lines": { "covered": 850, "total": 1000, "percentage": 85 },
      "branches": { "covered": 180, "total": 200, "percentage": 90 },
      "functions": { "covered": 95, "total": 100, "percentage": 95 },
      "statements": { "covered": 850, "total": 1000, "percentage": 85 }
    },
    "pyramid": {
      "unit": 32,
      "integration": 10,
      "e2e": 3,
      "total": 45,
      "ratios": {
        "unit": 71,
        "integration": 22,
        "e2e": 7
      }
    },
    "quality": {
      "average_assertions_per_test": 2.5,
      "tests_without_assertions": 0,
      "test_naming_quality": 0.9,
      "setup_teardown_usage": 0.8
    },
    "performance": {
      "total_duration": 45000,
      "slowest_test": 3500,
      "average_duration": 1000,
      "total_tests": 45
    }
  },

  "recommendations": [
    {
      "priority": "medium",
      "category": "coverage",
      "message": "Line coverage is 85%, just above 80% threshold. Consider adding more edge case tests.",
      "actionable": true
    },
    {
      "priority": "low",
      "category": "performance",
      "message": "One test took 3.5s. Consider optimizing or splitting into smaller tests.",
      "files": ["src/services/order.test.ts:calculateTotal with 1000 items"],
      "actionable": true
    }
  ],

  "result": {
    "status": "PASS",
    "threshold": 3.5,
    "message": "Testing meets standards (4.3/5.0 ≥ 3.5)"
  }
}
```

---

## 🎓 Summary

### What This Evaluator Provides

✅ **Universal Framework Support** - Jest, pytest, JUnit, Go test, Cargo test, etc.
✅ **Automatic Coverage Detection** - Finds and uses coverage tools automatically
✅ **Test Pyramid Analysis** - Ensures healthy test distribution
✅ **Test Quality Metrics** - Analyzes test organization and patterns
✅ **Normalized Scoring** - All frameworks scored on same 0-5 scale
✅ **Zero Configuration** - Works out of the box

### Key Innovation

**Before**: Separate test evaluators for each language/framework
**After**: One evaluator that adapts to any testing setup

**Maintenance**: Minimal
**Scalability**: Language/framework agnostic

---

**Status**: ✅ Production Ready
**Next**: Implement code-security-evaluator-v1-self-adapting.md
