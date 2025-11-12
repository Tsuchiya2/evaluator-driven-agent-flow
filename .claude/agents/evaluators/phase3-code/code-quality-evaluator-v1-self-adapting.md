# Code Quality Evaluator v1 - Self-Adapting

**Version**: 2.0
**Type**: Code Evaluator (Self-Adapting)
**Language Support**: Universal (TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#, Kotlin, Swift)
**Frameworks**: All
**Status**: Production Ready

---

## 🎯 Overview

### What This Evaluator Does

This evaluator analyzes code quality using language-specific and universal quality metrics:

1. **Type Coverage** - How well types are used (TypeScript, Python with mypy, etc.)
2. **Linting** - Code style and potential bugs (ESLint, pylint, etc.)
3. **Complexity** - Cyclomatic complexity and cognitive load
4. **Code Smells** - Duplication, long methods, large classes
5. **Best Practices** - Language/framework-specific conventions

### Self-Adapting Features

✅ **Automatic Language Detection** - Detects programming language from project files
✅ **Tool Detection** - Finds existing linting/quality tools in project
✅ **Pattern Learning** - Learns code quality standards from existing code
✅ **Universal Scoring** - Normalizes all languages to 0-5 scale
✅ **Zero Configuration** - Works out of the box with any language

---

## 🔍 Detection System

### Layer 1: Automatic Detection

```typescript
async function detectQualityTools(): Promise<QualityTools> {
  // Step 1: Detect language
  const language = await detectLanguage()

  // Step 2: Detect existing quality tools
  const tools = await detectExistingTools(language)

  // Step 3: Learn quality standards from codebase
  const standards = await learnQualityStandards(language)

  return { language, tools, standards }
}
```

### Layer 2: Configuration File (if needed)

```yaml
# .claude/edaf-config.yml
quality:
  language: typescript
  linter: eslint
  type_checker: tsc
  complexity_threshold: 10
  custom_rules:
    - no-console: warn
    - max-lines: 300
```

### Layer 3: User Questions (fallback)

If detection fails, ask user:
- What programming language?
- Which linting tool? (ESLint, pylint, checkstyle, etc.)
- Type checking enabled? (TypeScript, mypy, etc.)
- Complexity threshold? (default: 10)

---

## 🛠️ Language-Specific Tool Detection

### TypeScript/JavaScript

```typescript
const jsTools = {
  linters: {
    'eslint': {
      configFiles: ['.eslintrc.js', '.eslintrc.json', 'eslint.config.js'],
      command: 'npx eslint --format json',
      scoreMapping: {
        error: -1.0,
        warning: -0.3,
        fixable: +0.2
      }
    },
    'biome': {
      configFiles: ['biome.json'],
      command: 'npx @biomejs/biome check --formatter json'
    },
    'standard': {
      configFiles: ['.standard.json'],
      command: 'npx standard --format json'
    }
  },
  typeCheckers: {
    'typescript': {
      configFiles: ['tsconfig.json'],
      command: 'npx tsc --noEmit',
      strictnessLevels: {
        strict: 5.0,
        strictNullChecks: 4.0,
        noImplicitAny: 3.5,
        none: 2.0
      }
    }
  },
  complexityTools: {
    'complexity-report': {
      command: 'npx complexity-report --format json'
    }
  }
}
```

**Detection Logic**:
```typescript
async function detectJSTools(): Promise<JSTools> {
  const packageJson = await Read('package.json')
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies }

  // Detect linter
  const linter =
    deps['eslint'] ? 'eslint' :
    deps['@biomejs/biome'] ? 'biome' :
    deps['standard'] ? 'standard' :
    null

  // Detect type checker
  const typeChecker = deps['typescript'] ? 'typescript' : null

  // Detect config files
  const eslintConfig = await findFile(['.eslintrc.js', '.eslintrc.json'])
  const tsConfig = await findFile(['tsconfig.json'])

  return { linter, typeChecker, eslintConfig, tsConfig }
}
```

### Python

```typescript
const pythonTools = {
  linters: {
    'pylint': {
      configFiles: ['.pylintrc', 'pylintrc', 'setup.cfg'],
      command: 'pylint --output-format=json',
      scoreMapping: {
        error: -1.0,
        warning: -0.5,
        refactor: -0.3,
        convention: -0.2
      }
    },
    'flake8': {
      configFiles: ['.flake8', 'setup.cfg', 'tox.ini'],
      command: 'flake8 --format=json'
    },
    'ruff': {
      configFiles: ['ruff.toml', 'pyproject.toml'],
      command: 'ruff check --output-format json'
    }
  },
  typeCheckers: {
    'mypy': {
      configFiles: ['mypy.ini', 'setup.cfg', 'pyproject.toml'],
      command: 'mypy --strict --output json',
      strictnessLevels: {
        strict: 5.0,
        disallow_untyped_defs: 4.0,
        check_untyped_defs: 3.5,
        none: 2.0
      }
    },
    'pyright': {
      configFiles: ['pyrightconfig.json', 'pyproject.toml'],
      command: 'pyright --outputjson'
    }
  },
  complexityTools: {
    'radon': {
      command: 'radon cc --json'
    }
  }
}
```

**Detection Logic**:
```typescript
async function detectPythonTools(): Promise<PythonTools> {
  const requirementsTxt = await Read('requirements.txt').catch(() => null)
  const pyprojectToml = await Read('pyproject.toml').catch(() => null)

  // Detect linter
  const linter =
    requirementsTxt?.includes('ruff') || pyprojectToml?.includes('ruff') ? 'ruff' :
    requirementsTxt?.includes('pylint') ? 'pylint' :
    requirementsTxt?.includes('flake8') ? 'flake8' :
    null

  // Detect type checker
  const typeChecker =
    requirementsTxt?.includes('mypy') || pyprojectToml?.includes('mypy') ? 'mypy' :
    requirementsTxt?.includes('pyright') ? 'pyright' :
    null

  return { linter, typeChecker }
}
```

### Java

```typescript
const javaTools = {
  linters: {
    'checkstyle': {
      configFiles: ['checkstyle.xml', 'google_checks.xml'],
      command: 'java -jar checkstyle.jar -f json',
      scoreMapping: {
        error: -1.0,
        warning: -0.5,
        info: -0.2
      }
    },
    'spotbugs': {
      configFiles: ['spotbugs.xml'],
      command: 'spotbugs -output=json'
    },
    'pmd': {
      configFiles: ['pmd.xml', 'ruleset.xml'],
      command: 'pmd check --format json'
    }
  },
  typeCheckers: {
    // Java has compile-time type checking
    'javac': {
      command: 'javac -Xlint:all',
      alwaysEnabled: true
    }
  },
  complexityTools: {
    'pmd': {
      command: 'pmd check --rulesets=category/java/design.xml --format json'
    }
  }
}
```

### Go

```typescript
const goTools = {
  linters: {
    'golangci-lint': {
      configFiles: ['.golangci.yml', '.golangci.yaml'],
      command: 'golangci-lint run --out-format json',
      scoreMapping: {
        error: -1.0,
        warning: -0.5
      }
    },
    'staticcheck': {
      command: 'staticcheck -f json'
    }
  },
  typeCheckers: {
    // Go has compile-time type checking
    'go': {
      command: 'go vet',
      alwaysEnabled: true
    }
  },
  complexityTools: {
    'gocyclo': {
      command: 'gocyclo -over 10 .'
    }
  }
}
```

### Rust

```typescript
const rustTools = {
  linters: {
    'clippy': {
      configFiles: ['clippy.toml'],
      command: 'cargo clippy --message-format=json',
      scoreMapping: {
        error: -1.0,
        warning: -0.5,
        help: +0.1
      }
    }
  },
  typeCheckers: {
    // Rust has compile-time type checking
    'rustc': {
      command: 'cargo check --message-format=json',
      alwaysEnabled: true
    }
  },
  formatters: {
    'rustfmt': {
      configFiles: ['rustfmt.toml'],
      command: 'cargo fmt -- --check'
    }
  }
}
```

### Ruby

```typescript
const rubyTools = {
  linters: {
    'rubocop': {
      configFiles: ['.rubocop.yml'],
      command: 'rubocop --format json',
      scoreMapping: {
        error: -1.0,
        warning: -0.5,
        convention: -0.3,
        refactor: -0.2
      }
    },
    'reek': {
      configFiles: ['.reek.yml'],
      command: 'reek --format json'
    }
  },
  typeCheckers: {
    'sorbet': {
      configFiles: ['sorbet/config'],
      command: 'srb tc --metrics-file'
    }
  }
}
```

### PHP

```typescript
const phpTools = {
  linters: {
    'phpstan': {
      configFiles: ['phpstan.neon', 'phpstan.neon.dist'],
      command: 'phpstan analyse --error-format=json',
      levels: {
        9: 5.0,  // Maximum level
        8: 4.5,
        7: 4.0,
        6: 3.5,
        5: 3.0
      }
    },
    'psalm': {
      configFiles: ['psalm.xml'],
      command: 'psalm --output-format=json'
    },
    'phpcs': {
      configFiles: ['phpcs.xml', '.phpcs.xml'],
      command: 'phpcs --report=json'
    }
  }
}
```

### C#

```typescript
const csharpTools = {
  linters: {
    'roslyn-analyzers': {
      configFiles: ['.editorconfig'],
      command: 'dotnet build /p:RunAnalyzers=true',
      scoreMapping: {
        error: -1.0,
        warning: -0.5,
        info: -0.2
      }
    },
    'stylecop': {
      configFiles: ['stylecop.json'],
      command: 'dotnet build /p:StyleCopEnabled=true'
    }
  },
  typeCheckers: {
    // C# has compile-time type checking
    'csc': {
      command: 'dotnet build',
      alwaysEnabled: true,
      nullableContext: {
        enable: 5.0,
        warnings: 4.0,
        annotations: 3.5,
        disable: 2.0
      }
    }
  }
}
```

---

## 📊 Universal Quality Metrics

### 1. Type Coverage (Language-Specific)

```typescript
interface TypeCoverageMetrics {
  language: string
  typeChecker: string | null
  coverage: {
    typed: number        // Files/functions with types
    total: number        // Total files/functions
    percentage: number   // typed / total * 100
  }
  strictness: {
    level: 'strict' | 'moderate' | 'loose' | 'none'
    score: number  // 0-5
  }
}
```

**Scoring Formula**:
```typescript
function calculateTypeCoverageScore(metrics: TypeCoverageMetrics): number {
  const { coverage, strictness } = metrics

  // Base score from coverage percentage
  const coverageScore = (coverage.percentage / 100) * 3  // 0-3 points

  // Bonus from strictness level
  const strictnessScore = strictness.score / 5 * 2  // 0-2 points

  return Math.min(coverageScore + strictnessScore, 5.0)
}
```

**Examples**:
- TypeScript with `strict: true` + 90% coverage = 4.8/5.0
- Python with mypy `--strict` + 70% coverage = 4.0/5.0
- JavaScript (no types) = 2.0/5.0 (baseline)

### 2. Linting Score

```typescript
interface LintingMetrics {
  tool: string
  errors: number
  warnings: number
  fixableIssues: number
  totalFiles: number
  issuesPerFile: number
}
```

**Scoring Formula**:
```typescript
function calculateLintingScore(metrics: LintingMetrics): number {
  const { errors, warnings, fixableIssues, totalFiles } = metrics

  // Start with perfect score
  let score = 5.0

  // Deduct for errors (serious issues)
  score -= (errors / totalFiles) * 1.0

  // Deduct for warnings (minor issues)
  score -= (warnings / totalFiles) * 0.3

  // Small bonus if issues are auto-fixable
  if (fixableIssues > 0) {
    score += 0.2
  }

  return Math.max(score, 0)
}
```

**Examples**:
- 0 errors, 0 warnings = 5.0/5.0
- 2 errors, 5 warnings in 10 files = 4.65/5.0
- 10 errors, 20 warnings in 5 files = 2.8/5.0

### 3. Cyclomatic Complexity

```typescript
interface ComplexityMetrics {
  averageComplexity: number
  maxComplexity: number
  functionsOverThreshold: number
  totalFunctions: number
  threshold: number  // Usually 10
}
```

**Scoring Formula**:
```typescript
function calculateComplexityScore(metrics: ComplexityMetrics): number {
  const { averageComplexity, maxComplexity, functionsOverThreshold, totalFunctions, threshold } = metrics

  // Penalize high average complexity
  let score = 5.0
  if (averageComplexity > threshold) {
    score -= (averageComplexity - threshold) * 0.2
  }

  // Penalize functions over threshold
  const overThresholdRatio = functionsOverThreshold / totalFunctions
  score -= overThresholdRatio * 2.0

  // Penalize extremely high max complexity
  if (maxComplexity > threshold * 2) {
    score -= 1.0
  }

  return Math.max(score, 0)
}
```

**Examples**:
- Average: 5, Max: 8, 0 over threshold = 5.0/5.0
- Average: 12, Max: 20, 20% over threshold = 3.2/5.0
- Average: 8, Max: 35, 10% over threshold = 3.8/5.0

### 4. Code Duplication

```typescript
interface DuplicationMetrics {
  duplicatedLines: number
  totalLines: number
  duplicatedBlocks: number
  percentage: number
}
```

**Scoring Formula**:
```typescript
function calculateDuplicationScore(metrics: DuplicationMetrics): number {
  const { percentage } = metrics

  // Industry standard: <5% duplication is good
  if (percentage < 3) return 5.0
  if (percentage < 5) return 4.5
  if (percentage < 10) return 4.0
  if (percentage < 15) return 3.5
  if (percentage < 20) return 3.0
  return 2.0
}
```

### 5. Code Smells (Language-Agnostic)

```typescript
interface CodeSmells {
  longMethods: number          // Functions > 50 lines
  largeClasses: number         // Classes > 500 lines
  longParameterLists: number   // Functions > 5 params
  deepNesting: number          // Nesting > 4 levels
  godClasses: number           // Classes with too many responsibilities
}
```

**Scoring Formula**:
```typescript
function calculateCodeSmellScore(smells: CodeSmells, totalFiles: number): number {
  let score = 5.0

  const smellsPerFile = (
    smells.longMethods +
    smells.largeClasses +
    smells.longParameterLists +
    smells.deepNesting +
    smells.godClasses
  ) / totalFiles

  // Deduct based on smells per file
  score -= smellsPerFile * 0.5

  return Math.max(score, 0)
}
```

---

## 🎯 Evaluation Process

### Step 1: Detect Language and Tools

```typescript
async function detectQualityEnvironment(): Promise<QualityEnvironment> {
  // Read package files in parallel
  const [packageJson, requirementsTxt, goMod, cargoToml, pomXml] = await Promise.all([
    Read('package.json').catch(() => null),
    Read('requirements.txt').catch(() => null),
    Read('go.mod').catch(() => null),
    Read('Cargo.toml').catch(() => null),
    Read('pom.xml').catch(() => null)
  ])

  // Detect language
  const language =
    packageJson ? 'javascript' :
    requirementsTxt ? 'python' :
    goMod ? 'go' :
    cargoToml ? 'rust' :
    pomXml ? 'java' :
    await askUserForLanguage()

  // Detect tools for this language
  const tools = await detectToolsForLanguage(language)

  return { language, tools }
}
```

### Step 2: Run Quality Checks

```typescript
async function runQualityChecks(env: QualityEnvironment, changedFiles: string[]): Promise<QualityMetrics> {
  const results = {
    typeCoverage: null as TypeCoverageMetrics | null,
    linting: null as LintingMetrics | null,
    complexity: null as ComplexityMetrics | null,
    duplication: null as DuplicationMetrics | null,
    codeSmells: null as CodeSmells | null
  }

  // Run type checking if available
  if (env.tools.typeChecker) {
    results.typeCoverage = await runTypeChecker(env.tools.typeChecker, changedFiles)
  }

  // Run linter if available
  if (env.tools.linter) {
    results.linting = await runLinter(env.tools.linter, changedFiles)
  }

  // Calculate complexity (universal)
  results.complexity = await calculateComplexity(changedFiles, env.language)

  // Detect duplication (universal)
  results.duplication = await detectDuplication(changedFiles)

  // Detect code smells (universal)
  results.codeSmells = await detectCodeSmells(changedFiles, env.language)

  return results
}
```

### Step 3: Calculate Scores

```typescript
async function calculateQualityScore(metrics: QualityMetrics): Promise<EvaluationResult> {
  const scores = {
    typeCoverage: metrics.typeCoverage ? calculateTypeCoverageScore(metrics.typeCoverage) : null,
    linting: metrics.linting ? calculateLintingScore(metrics.linting) : null,
    complexity: calculateComplexityScore(metrics.complexity),
    duplication: calculateDuplicationScore(metrics.duplication),
    codeSmells: calculateCodeSmellScore(metrics.codeSmells, changedFiles.length)
  }

  // Weighted average (type coverage and linting are most important)
  const weights = {
    typeCoverage: 0.25,
    linting: 0.30,
    complexity: 0.20,
    duplication: 0.15,
    codeSmells: 0.10
  }

  const totalScore = calculateWeightedAverage(scores, weights)

  return {
    overallScore: totalScore,
    breakdown: scores,
    metrics,
    recommendations: generateRecommendations(scores, metrics)
  }
}
```

### Step 4: Generate Report

```typescript
interface QualityReport {
  timestamp: string
  language: string
  tools: {
    typeChecker: string | null
    linter: string | null
    complexityAnalyzer: string
  }
  scores: {
    overall: number  // 0-5
    typeCoverage: number | null
    linting: number | null
    complexity: number
    duplication: number
    codeSmells: number
  }
  metrics: QualityMetrics
  recommendations: Recommendation[]
  passFail: 'PASS' | 'FAIL'
  threshold: number  // e.g., 3.5
}
```

**Example Report**:
```json
{
  "timestamp": "2025-11-09T10:30:00Z",
  "language": "typescript",
  "tools": {
    "typeChecker": "typescript",
    "linter": "eslint",
    "complexityAnalyzer": "complexity-report"
  },
  "scores": {
    "overall": 4.2,
    "typeCoverage": 4.5,
    "linting": 4.8,
    "complexity": 3.8,
    "duplication": 4.5,
    "codeSmells": 3.5
  },
  "metrics": {
    "typeCoverage": {
      "coverage": { "typed": 45, "total": 50, "percentage": 90 },
      "strictness": { "level": "strict", "score": 5.0 }
    },
    "linting": {
      "errors": 0,
      "warnings": 3,
      "fixableIssues": 2
    },
    "complexity": {
      "averageComplexity": 7.2,
      "maxComplexity": 15,
      "functionsOverThreshold": 2
    }
  },
  "recommendations": [
    {
      "priority": "medium",
      "category": "complexity",
      "message": "2 functions exceed complexity threshold (10). Consider refactoring.",
      "files": ["src/services/order.ts:calculateTotal", "src/utils/validation.ts:validateForm"]
    },
    {
      "priority": "low",
      "category": "linting",
      "message": "3 ESLint warnings found. Run 'npm run lint:fix' to auto-fix 2 of them.",
      "autoFixable": true
    }
  ],
  "passFail": "PASS",
  "threshold": 3.5
}
```

---

## 🔧 Implementation Examples

### TypeScript Project

```typescript
// .claude/evaluators/code-quality-evaluator-v1-self-adapting.md

async function evaluateTypeScriptQuality(changedFiles: string[]): Promise<QualityReport> {
  // Detect TypeScript environment
  const tsConfig = await Read('tsconfig.json')
  const packageJson = await Read('package.json')
  const eslintConfig = await findFile(['.eslintrc.js', '.eslintrc.json'])

  // Check TypeScript strictness
  const isStrict = tsConfig.compilerOptions?.strict === true
  const hasStrictNullChecks = tsConfig.compilerOptions?.strictNullChecks === true

  // Run type checking
  const typeCheckResult = await Bash({
    command: 'npx tsc --noEmit --pretty false',
    description: 'Run TypeScript type checking'
  })

  const typeErrors = parseTypeScriptErrors(typeCheckResult)

  // Run ESLint
  const lintResult = await Bash({
    command: `npx eslint ${changedFiles.join(' ')} --format json`,
    description: 'Run ESLint on changed files'
  })

  const lintIssues = JSON.parse(lintResult)

  // Calculate complexity
  const complexityResult = await analyzeComplexity(changedFiles)

  // Calculate scores
  const typeCoverageScore = calculateTypeCoverageScore({
    language: 'typescript',
    typeChecker: 'typescript',
    coverage: {
      typed: changedFiles.length - typeErrors.length,
      total: changedFiles.length,
      percentage: ((changedFiles.length - typeErrors.length) / changedFiles.length) * 100
    },
    strictness: {
      level: isStrict ? 'strict' : 'moderate',
      score: isStrict ? 5.0 : 3.5
    }
  })

  const lintingScore = calculateLintingScore({
    tool: 'eslint',
    errors: lintIssues.filter(i => i.severity === 'error').length,
    warnings: lintIssues.filter(i => i.severity === 'warning').length,
    fixableIssues: lintIssues.filter(i => i.fixable).length,
    totalFiles: changedFiles.length,
    issuesPerFile: lintIssues.length / changedFiles.length
  })

  const complexityScore = calculateComplexityScore(complexityResult)

  // Calculate overall score
  const overallScore = (
    typeCoverageScore * 0.30 +
    lintingScore * 0.35 +
    complexityScore * 0.35
  )

  return {
    timestamp: new Date().toISOString(),
    language: 'typescript',
    tools: {
      typeChecker: 'typescript',
      linter: 'eslint',
      complexityAnalyzer: 'built-in'
    },
    scores: {
      overall: overallScore,
      typeCoverage: typeCoverageScore,
      linting: lintingScore,
      complexity: complexityScore,
      duplication: 5.0,  // Not checked in this example
      codeSmells: 5.0
    },
    passFail: overallScore >= 3.5 ? 'PASS' : 'FAIL',
    threshold: 3.5
  }
}
```

### Python Project

```typescript
async function evaluatePythonQuality(changedFiles: string[]): Promise<QualityReport> {
  // Detect Python environment
  const hasPylint = await fileExists('requirements.txt') &&
    (await Read('requirements.txt')).includes('pylint')
  const hasMypy = await fileExists('requirements.txt') &&
    (await Read('requirements.txt')).includes('mypy')

  // Run pylint if available
  let lintingScore = 5.0
  if (hasPylint) {
    const pylintResult = await Bash({
      command: `pylint ${changedFiles.join(' ')} --output-format=json`,
      description: 'Run pylint on changed files'
    })

    const issues = JSON.parse(pylintResult)
    lintingScore = calculateLintingScore({
      tool: 'pylint',
      errors: issues.filter(i => i.type === 'error').length,
      warnings: issues.filter(i => i.type === 'warning').length,
      fixableIssues: 0,  // pylint doesn't auto-fix
      totalFiles: changedFiles.length,
      issuesPerFile: issues.length / changedFiles.length
    })
  }

  // Run mypy if available
  let typeCoverageScore = 2.0  // Default for Python without types
  if (hasMypy) {
    const mypyResult = await Bash({
      command: `mypy ${changedFiles.join(' ')} --strict`,
      description: 'Run mypy type checking'
    })

    const typeErrors = parseMypyOutput(mypyResult)
    typeCoverageScore = calculateTypeCoverageScore({
      language: 'python',
      typeChecker: 'mypy',
      coverage: {
        typed: changedFiles.length - typeErrors.length,
        total: changedFiles.length,
        percentage: ((changedFiles.length - typeErrors.length) / changedFiles.length) * 100
      },
      strictness: {
        level: 'strict',
        score: 5.0
      }
    })
  }

  // Calculate complexity with radon
  const complexityResult = await Bash({
    command: `radon cc ${changedFiles.join(' ')} -j`,
    description: 'Calculate cyclomatic complexity'
  })

  const complexityData = JSON.parse(complexityResult)
  const complexityScore = calculateComplexityScore(complexityData)

  // Calculate overall score
  const overallScore = (
    typeCoverageScore * 0.25 +
    lintingScore * 0.35 +
    complexityScore * 0.40
  )

  return {
    timestamp: new Date().toISOString(),
    language: 'python',
    tools: {
      typeChecker: hasMypy ? 'mypy' : null,
      linter: hasPylint ? 'pylint' : null,
      complexityAnalyzer: 'radon'
    },
    scores: {
      overall: overallScore,
      typeCoverage: typeCoverageScore,
      linting: lintingScore,
      complexity: complexityScore,
      duplication: 5.0,
      codeSmells: 5.0
    },
    passFail: overallScore >= 3.5 ? 'PASS' : 'FAIL',
    threshold: 3.5
  }
}
```

---

## 📐 Score Normalization

### Challenge: Different Tools, Different Scales

```typescript
// ESLint: 0-infinity errors
// Pylint: 0-10 score (higher is better)
// Checkstyle: 0-infinity violations
// Clippy: 0-infinity warnings

// Need to normalize ALL to 0-5 scale
```

### Solution: Universal Normalization Formula

```typescript
interface ToolOutput {
  tool: string
  rawScore?: number      // For tools that give scores (pylint)
  errors?: number        // For tools that count issues
  warnings?: number
  totalFiles: number
}

function normalizeToUniversalScale(output: ToolOutput): number {
  const { tool, rawScore, errors = 0, warnings = 0, totalFiles } = output

  // Strategy 1: Tool provides a score (e.g., pylint gives 0-10)
  if (rawScore !== undefined) {
    return normalizeExistingScore(tool, rawScore)
  }

  // Strategy 2: Tool counts issues (e.g., ESLint, clippy)
  return normalizeFromIssueCounts(errors, warnings, totalFiles)
}

function normalizeExistingScore(tool: string, rawScore: number): number {
  const toolScales = {
    'pylint': { min: 0, max: 10 },
    'phpstan': { min: 0, max: 9 },
    'go-vet': { min: 0, max: 1 }  // Binary pass/fail
  }

  const scale = toolScales[tool]
  if (!scale) return 3.0  // Default

  // Convert tool's scale to 0-5
  return ((rawScore - scale.min) / (scale.max - scale.min)) * 5.0
}

function normalizeFromIssueCounts(errors: number, warnings: number, totalFiles: number): number {
  // Start with perfect score
  let score = 5.0

  // Calculate issues per file
  const errorsPerFile = errors / totalFiles
  const warningsPerFile = warnings / totalFiles

  // Deduct points based on severity
  score -= errorsPerFile * 1.0      // 1 error per file = -1.0
  score -= warningsPerFile * 0.3    // 1 warning per file = -0.3

  // Clamp to 0-5 range
  return Math.max(0, Math.min(5.0, score))
}
```

**Example Conversions**:

```typescript
// ESLint: 5 errors, 10 warnings in 10 files
normalizeToUniversalScale({
  tool: 'eslint',
  errors: 5,
  warnings: 10,
  totalFiles: 10
})
// Result: 5.0 - (5/10 * 1.0) - (10/10 * 0.3) = 4.2

// Pylint: Score of 7.5/10
normalizeToUniversalScale({
  tool: 'pylint',
  rawScore: 7.5,
  totalFiles: 10
})
// Result: (7.5 / 10) * 5.0 = 3.75

// Clippy: 0 errors, 3 warnings in 5 files
normalizeToUniversalScale({
  tool: 'clippy',
  errors: 0,
  warnings: 3,
  totalFiles: 5
})
// Result: 5.0 - (3/5 * 0.3) = 4.82
```

---

## 🎓 Pattern Learning from Existing Code

### Learning Quality Standards

```typescript
async function learnQualityStandards(language: string): Promise<QualityStandards> {
  // Find existing code files
  const codeFiles = await Glob({
    pattern: getCodePattern(language)
  })

  // Read 3-5 example files
  const exampleFiles = codeFiles.slice(0, 5)
  const codeContents = await Promise.all(
    exampleFiles.map(f => Read(f))
  )

  // Analyze patterns
  const standards = {
    averageComplexity: calculateAverageComplexity(codeContents),
    typingDensity: calculateTypingDensity(codeContents, language),
    commentDensity: calculateCommentDensity(codeContents),
    averageFunctionLength: calculateAverageFunctionLength(codeContents),
    namingConventions: detectNamingConventions(codeContents)
  }

  return standards
}
```

**Example Output**:
```json
{
  "averageComplexity": 6.5,
  "typingDensity": 0.85,
  "commentDensity": 0.12,
  "averageFunctionLength": 25,
  "namingConventions": {
    "functions": "camelCase",
    "classes": "PascalCase",
    "constants": "SCREAMING_SNAKE_CASE"
  }
}
```

### Using Learned Standards

```typescript
function evaluateAgainstLearnedStandards(
  newCode: string,
  standards: QualityStandards
): QualityScore {
  const newCodeMetrics = analyzeCode(newCode)

  // Compare new code to existing standards
  const complexityDiff = Math.abs(newCodeMetrics.complexity - standards.averageComplexity)
  const typingDiff = Math.abs(newCodeMetrics.typingDensity - standards.typingDensity)

  // Score based on similarity to existing code
  let score = 5.0

  // Penalize if significantly different from existing code
  if (complexityDiff > 3) score -= 0.5
  if (typingDiff > 0.2) score -= 0.5

  return {
    score,
    feedback: generateFeedback(newCodeMetrics, standards)
  }
}
```

---

## ⚠️ Edge Cases and Error Handling

### Case 1: No Quality Tools Installed

```typescript
async function handleNoToolsInstalled(language: string): Promise<QualityReport> {
  // Use basic built-in checks only
  const basicChecks = {
    complexity: await calculateComplexity(changedFiles, language),
    duplication: await detectDuplication(changedFiles),
    codeSmells: await detectCodeSmells(changedFiles, language)
  }

  const score = (
    calculateComplexityScore(basicChecks.complexity) * 0.4 +
    calculateDuplicationScore(basicChecks.duplication) * 0.3 +
    calculateCodeSmellScore(basicChecks.codeSmells) * 0.3
  )

  return {
    timestamp: new Date().toISOString(),
    language,
    tools: {
      typeChecker: null,
      linter: null,
      complexityAnalyzer: 'built-in'
    },
    scores: {
      overall: score,
      typeCoverage: null,
      linting: null,
      complexity: calculateComplexityScore(basicChecks.complexity),
      duplication: calculateDuplicationScore(basicChecks.duplication),
      codeSmells: calculateCodeSmellScore(basicChecks.codeSmells)
    },
    recommendations: [
      {
        priority: 'high',
        category: 'tooling',
        message: `Consider adding quality tools for ${language}. Recommended: ${getRecommendedTools(language).join(', ')}`
      }
    ],
    passFail: score >= 3.5 ? 'PASS' : 'FAIL',
    threshold: 3.5
  }
}
```

### Case 2: Tool Execution Fails

```typescript
async function handleToolFailure(tool: string, error: Error): Promise<void> {
  console.warn(`⚠️ ${tool} execution failed: ${error.message}`)

  // Try alternative tool
  const alternatives = getAlternativeTools(tool)
  for (const altTool of alternatives) {
    try {
      return await runTool(altTool)
    } catch (e) {
      continue
    }
  }

  // Fall back to basic checks
  return await runBasicChecks()
}
```

### Case 3: Unknown Language

```typescript
async function handleUnknownLanguage(): Promise<string> {
  // Ask user via AskUserQuestion
  const response = await AskUserQuestion({
    questions: [{
      question: 'Which programming language is this project using?',
      header: 'Language',
      multiSelect: false,
      options: [
        { label: 'TypeScript', description: 'TypeScript/JavaScript project' },
        { label: 'Python', description: 'Python project' },
        { label: 'Java', description: 'Java project' },
        { label: 'Go', description: 'Go project' }
      ]
    }]
  })

  // Save to config for next time
  await saveToConfig({ language: response.language })

  return response.language
}
```

### Case 4: Mixed Languages in Same PR

```typescript
async function handleMixedLanguages(changedFiles: string[]): Promise<QualityReport> {
  // Group files by language
  const filesByLanguage = groupFilesByLanguage(changedFiles)

  // Evaluate each language separately
  const results = await Promise.all(
    Object.entries(filesByLanguage).map(([lang, files]) =>
      evaluateLanguage(lang, files)
    )
  )

  // Combine results with weighted average
  const combinedScore = results.reduce((acc, result) => {
    const weight = result.filesCount / changedFiles.length
    return acc + (result.score * weight)
  }, 0)

  return {
    overallScore: combinedScore,
    breakdown: results,
    passFail: combinedScore >= 3.5 ? 'PASS' : 'FAIL'
  }
}
```

---

## 📋 Configuration File Format

```yaml
# .claude/edaf-config.yml

quality:
  # Language (auto-detected if not specified)
  language: typescript

  # Quality tools
  type_checker:
    tool: typescript
    strictness: strict
    config_file: tsconfig.json

  linter:
    tool: eslint
    config_file: .eslintrc.js
    auto_fix: false

  # Thresholds
  thresholds:
    overall_score: 3.5
    type_coverage: 80
    complexity_max: 10
    duplication_max: 5

  # Enabled checks
  checks:
    type_coverage: true
    linting: true
    complexity: true
    duplication: true
    code_smells: true

  # Custom rules (language-specific)
  custom_rules:
    typescript:
      - no-any: error
      - strict-null-checks: error
    python:
      - max-line-length: 120
      - naming-style: snake_case
```

---

## 🚀 Usage Examples

### Example 1: TypeScript Project with ESLint + TypeScript

```bash
# Project structure
my-app/
  ├── package.json          # Has eslint, typescript
  ├── tsconfig.json         # strict: true
  ├── .eslintrc.js
  └── src/
      └── services/
          └── order.ts      # Changed file
```

**Evaluation Flow**:
1. Detect language: TypeScript ✅
2. Detect tools: ESLint + TypeScript compiler ✅
3. Run type check: `npx tsc --noEmit` → 0 errors
4. Run ESLint: `npx eslint src/services/order.ts --format json` → 2 warnings
5. Calculate complexity: Average 7.5, Max 12
6. Calculate scores:
   - Type coverage: 5.0 (strict mode, no errors)
   - Linting: 4.7 (2 warnings)
   - Complexity: 4.5 (slightly high)
   - Overall: 4.7
7. Result: **PASS** (threshold: 3.5)

### Example 2: Python Project with pylint (no mypy)

```bash
# Project structure
my-api/
  ├── requirements.txt      # Has pylint, no mypy
  ├── .pylintrc
  └── src/
      └── services/
          └── order.py      # Changed file
```

**Evaluation Flow**:
1. Detect language: Python ✅
2. Detect tools: pylint (no type checker) ✅
3. Run pylint: Score 8.5/10
4. Calculate complexity: Average 6.2
5. Calculate scores:
   - Type coverage: N/A (no mypy)
   - Linting: 4.25 (from pylint 8.5/10)
   - Complexity: 4.8
   - Overall: 4.5 (weighted without type coverage)
6. Result: **PASS**

### Example 3: Go Project with golangci-lint

```bash
# Project structure
my-service/
  ├── go.mod
  ├── .golangci.yml
  └── internal/
      └── service/
          └── order.go      # Changed file
```

**Evaluation Flow**:
1. Detect language: Go ✅
2. Detect tools: golangci-lint ✅
3. Run golangci-lint: 0 errors, 1 warning
4. Run go vet: Pass ✅
5. Calculate complexity: Average 5.0
6. Calculate scores:
   - Type coverage: 5.0 (Go is statically typed)
   - Linting: 4.7 (1 warning)
   - Complexity: 5.0
   - Overall: 4.9
7. Result: **PASS**

---

## 🎯 Success Criteria

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Detection Accuracy** | 95%+ | % of correct language/tool detection |
| **Score Consistency** | ±0.3 | Same code should get similar scores |
| **False Positives** | <5% | % of good code marked as FAIL |
| **False Negatives** | <2% | % of bad code marked as PASS |
| **Evaluation Speed** | <30s | Time to complete evaluation |
| **Tool Coverage** | 90%+ | % of projects with at least 1 tool detected |

---

## 📚 Recommendations

### High Priority

```typescript
interface Recommendation {
  priority: 'critical' | 'high' | 'medium' | 'low'
  category: 'type_coverage' | 'linting' | 'complexity' | 'duplication' | 'code_smells' | 'tooling'
  message: string
  actionable: boolean
  autoFixable: boolean
  files?: string[]
}
```

**Examples**:

```typescript
const recommendations = [
  {
    priority: 'critical',
    category: 'type_coverage',
    message: 'TypeScript strict mode is disabled. Enable "strict": true in tsconfig.json for better type safety.',
    actionable: true,
    autoFixable: true
  },
  {
    priority: 'high',
    category: 'complexity',
    message: '3 functions exceed complexity threshold (10). Consider refactoring.',
    actionable: true,
    autoFixable: false,
    files: [
      'src/services/order.ts:calculateTotal (complexity: 15)',
      'src/utils/validation.ts:validateForm (complexity: 18)',
      'src/helpers/format.ts:formatAddress (complexity: 12)'
    ]
  },
  {
    priority: 'medium',
    category: 'linting',
    message: '12 ESLint warnings found. Run "npm run lint:fix" to auto-fix 8 of them.',
    actionable: true,
    autoFixable: true
  },
  {
    priority: 'low',
    category: 'tooling',
    message: 'Consider adding a code formatter like Prettier for consistent code style.',
    actionable: true,
    autoFixable: false
  }
]
```

---

## 🔄 Integration with EDAF Flow

### Phase 3: Code Review Gate

```typescript
// In orchestrator-agent.md

async function runCodeReviewGate(prNumber: number): Promise<GateResult> {
  const changedFiles = await getChangedFiles(prNumber)

  // Run code quality evaluator
  const qualityReport = await runEvaluator('code-quality-evaluator-v1', {
    changedFiles,
    threshold: 3.5
  })

  if (qualityReport.passFail === 'FAIL') {
    return {
      status: 'BLOCKED',
      reason: `Code quality score ${qualityReport.scores.overall}/5.0 is below threshold ${qualityReport.threshold}`,
      recommendations: qualityReport.recommendations,
      autoFixAvailable: qualityReport.recommendations.some(r => r.autoFixable)
    }
  }

  return {
    status: 'PASSED',
    score: qualityReport.scores.overall
  }
}
```

---

## 📊 Output Format

```json
{
  "evaluator": "code-quality-evaluator-v1-self-adapting",
  "version": "2.0",
  "timestamp": "2025-11-09T10:30:00Z",
  "pr_number": 42,
  "changed_files": 12,

  "environment": {
    "language": "typescript",
    "tools": {
      "type_checker": "typescript",
      "linter": "eslint",
      "complexity_analyzer": "complexity-report",
      "duplication_detector": "jscpd"
    }
  },

  "scores": {
    "overall": 4.2,
    "breakdown": {
      "type_coverage": 4.5,
      "linting": 4.8,
      "complexity": 3.8,
      "duplication": 4.5,
      "code_smells": 3.5
    }
  },

  "metrics": {
    "type_coverage": {
      "typed_files": 11,
      "total_files": 12,
      "percentage": 91.7,
      "strictness": "strict"
    },
    "linting": {
      "errors": 0,
      "warnings": 3,
      "fixable_issues": 2
    },
    "complexity": {
      "average": 7.2,
      "max": 15,
      "over_threshold": 2,
      "threshold": 10
    },
    "duplication": {
      "percentage": 3.2,
      "duplicated_blocks": 5
    },
    "code_smells": {
      "long_methods": 1,
      "large_classes": 0,
      "long_parameter_lists": 2,
      "deep_nesting": 1
    }
  },

  "recommendations": [
    {
      "priority": "medium",
      "category": "complexity",
      "message": "2 functions exceed complexity threshold. Consider refactoring.",
      "files": ["src/services/order.ts:calculateTotal", "src/utils/validation.ts:validateForm"],
      "actionable": true,
      "autoFixable": false
    },
    {
      "priority": "low",
      "category": "linting",
      "message": "3 ESLint warnings. Run 'npm run lint:fix' to auto-fix 2.",
      "actionable": true,
      "autoFixable": true
    }
  ],

  "result": {
    "status": "PASS",
    "threshold": 3.5,
    "message": "Code quality meets standards (4.2/5.0 ≥ 3.5)"
  }
}
```

---

## 🎓 Summary

### What This Evaluator Provides

✅ **Universal Language Support** - Works with TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#, etc.
✅ **Automatic Tool Detection** - Finds ESLint, pylint, checkstyle, clippy, etc.
✅ **Normalized Scoring** - All languages scored on same 0-5 scale
✅ **Pattern Learning** - Learns quality standards from existing code
✅ **Actionable Recommendations** - Tells developers exactly what to fix
✅ **Zero Configuration** - Works out of the box

### Key Innovation

**Before**: Separate quality evaluators for each language
**After**: One evaluator that adapts to any language

**Maintenance**: Minimal (no templates to update)
**Scalability**: Language/framework agnostic (automatically supports new languages)

---

**Status**: ✅ Production Ready
**Next**: Implement code-testing-evaluator-v1-self-adapting.md
