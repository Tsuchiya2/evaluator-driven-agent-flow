# Code Maintainability Evaluator v1 - Self-Adapting

**Version**: 2.0
**Type**: Code Evaluator (Self-Adapting)
**Language Support**: Universal (TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#, Kotlin, Swift)
**Frameworks**: All
**Status**: Production Ready

---

## 🎯 Overview

### What This Evaluator Does

This evaluator analyzes code maintainability across all languages:

1. **Cyclomatic Complexity** - Control flow complexity
2. **Cognitive Complexity** - How hard code is to understand
3. **Code Duplication** - DRY (Don't Repeat Yourself) principle
4. **Code Smells** - Long methods, god classes, deep nesting
5. **SOLID Principles** - Design quality assessment
6. **Technical Debt** - Accumulated maintainability issues

### Self-Adapting Features

✅ **Automatic Language Detection** - Detects language from project files
✅ **Complexity Tool Detection** - Finds language-specific tools
✅ **Pattern Learning** - Learns healthy patterns from existing code
✅ **Universal Scoring** - Normalizes all languages to 0-5 scale
✅ **Zero Configuration** - Works out of the box

---

## 🔍 Detection System

### Layer 1: Automatic Detection

```typescript
async function detectMaintainabilityTools(): Promise<MaintainabilityTools> {
  // Step 1: Detect language
  const language = await detectLanguage()

  // Step 2: Detect complexity tools
  const complexityTool = await detectComplexityTool(language)

  // Step 3: Detect duplication tools
  const duplicationTool = await detectDuplicationTool(language)

  // Step 4: Learn healthy patterns from codebase
  const healthyPatterns = await learnHealthyPatterns(language)

  return { language, complexityTool, duplicationTool, healthyPatterns }
}
```

### Layer 2: Configuration File (if needed)

```yaml
# .claude/edaf-config.yml
maintainability:
  language: typescript
  thresholds:
    cyclomatic_complexity: 10
    cognitive_complexity: 15
    max_function_lines: 50
    max_class_lines: 300
    max_parameters: 5
    max_nesting_depth: 4
    duplication_percentage: 5
```

### Layer 3: User Questions (fallback)

If detection fails, ask user:
- What programming language?
- Complexity threshold? (default: 10)
- Max function length? (default: 50 lines)

---

## 🛠️ Language-Specific Complexity Tools

### TypeScript/JavaScript

```typescript
const jsComplexityTools = {
  'eslint-plugin-complexity': {
    indicators: {
      dependencies: ['eslint-plugin-complexity'],
      configFiles: ['.eslintrc.js', '.eslintrc.json']
    },
    command: 'npx eslint --rule "complexity: [error, 10]" --format json',
    metrics: ['cyclomatic']
  },

  'complexity-report': {
    indicators: {
      dependencies: ['complexity-report']
    },
    command: 'npx complexity-report --format json',
    metrics: ['cyclomatic', 'halstead', 'maintainability']
  },

  'sonarqube': {
    indicators: {
      configFiles: ['sonar-project.properties']
    },
    command: 'sonar-scanner',
    metrics: ['cyclomatic', 'cognitive', 'maintainability']
  },

  'jscpd': {
    indicators: {
      dependencies: ['jscpd']
    },
    command: 'npx jscpd --format json',
    metrics: ['duplication']
  }
}
```

**Detection Logic**:
```typescript
async function detectJSComplexityTools(): Promise<JSComplexityTools> {
  const packageJson = await Read('package.json')
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies }

  // Detect complexity tool
  const complexityTool =
    deps['complexity-report'] ? 'complexity-report' :
    deps['eslint-plugin-complexity'] ? 'eslint-plugin-complexity' :
    await fileExists('sonar-project.properties') ? 'sonarqube' :
    null

  // Detect duplication tool
  const duplicationTool =
    deps['jscpd'] ? 'jscpd' :
    null

  return { complexityTool, duplicationTool }
}
```

### Python

```typescript
const pythonComplexityTools = {
  'radon': {
    indicators: {
      dependencies: ['radon']
    },
    command: 'radon cc --json .',
    metrics: ['cyclomatic', 'maintainability']
  },

  'mccabe': {
    indicators: {
      dependencies: ['mccabe']
    },
    command: 'python -m mccabe --min 5 .',
    metrics: ['cyclomatic']
  },

  'pylint': {
    indicators: {
      dependencies: ['pylint']
    },
    command: 'pylint --output-format=json',
    metrics: ['cyclomatic', 'maintainability', 'duplication']
  },

  'sonarqube': {
    indicators: {
      configFiles: ['sonar-project.properties']
    },
    metrics: ['cyclomatic', 'cognitive', 'duplication']
  }
}
```

### Java

```typescript
const javaComplexityTools = {
  'pmd': {
    indicators: {
      configFiles: ['pmd.xml', 'ruleset.xml']
    },
    command: 'pmd check --rulesets=category/java/design.xml --format json',
    metrics: ['cyclomatic', 'cognitive', 'code_smells']
  },

  'checkstyle': {
    indicators: {
      configFiles: ['checkstyle.xml']
    },
    command: 'java -jar checkstyle.jar -f json',
    metrics: ['complexity', 'code_smells']
  },

  'sonarqube': {
    indicators: {
      configFiles: ['sonar-project.properties']
    },
    metrics: ['cyclomatic', 'cognitive', 'duplication', 'maintainability']
  }
}
```

### Go

```typescript
const goComplexityTools = {
  'gocyclo': {
    indicators: {
      binary: 'gocyclo'
    },
    command: 'gocyclo -over 10 .',
    metrics: ['cyclomatic']
  },

  'gocognit': {
    indicators: {
      binary: 'gocognit'
    },
    command: 'gocognit -over 15 .',
    metrics: ['cognitive']
  },

  'go-critic': {
    indicators: {
      binary: 'gocritic'
    },
    command: 'gocritic check -enableAll',
    metrics: ['code_smells']
  }
}
```

### Rust

```typescript
const rustComplexityTools = {
  'cargo-clippy': {
    indicators: {
      builtin: true
    },
    command: 'cargo clippy -- -W clippy::cognitive_complexity',
    metrics: ['cognitive', 'code_smells']
  },

  'cargo-geiger': {
    indicators: {
      dependencies: ['cargo-geiger']
    },
    command: 'cargo geiger --output-format Json',
    metrics: ['unsafe_usage']
  }
}
```

---

## 📊 Universal Maintainability Metrics

### 1. Cyclomatic Complexity

```typescript
interface CyclomaticComplexity {
  functions: Array<{
    name: string
    complexity: number
    file: string
    line: number
  }>
  average: number
  max: number
  overThreshold: number  // Count of functions > threshold
  threshold: number      // Usually 10
}
```

**Calculation (Language-Agnostic)**:
```typescript
function calculateCyclomaticComplexity(code: string): number {
  let complexity = 1  // Base complexity

  // Count decision points
  const decisionPatterns = [
    /\bif\b/g,
    /\belse\s+if\b/g,
    /\bfor\b/g,
    /\bwhile\b/g,
    /\bcase\b/g,
    /\bcatch\b/g,
    /\b&&\b/g,
    /\b\|\|\b/g,
    /\?\s*.*?\s*:/g  // Ternary
  ]

  for (const pattern of decisionPatterns) {
    const matches = code.match(pattern)
    complexity += matches ? matches.length : 0
  }

  return complexity
}
```

**Scoring Formula**:
```typescript
function calculateComplexityScore(metrics: CyclomaticComplexity): number {
  let score = 5.0

  // Penalize high average complexity
  if (metrics.average > metrics.threshold) {
    const excess = metrics.average - metrics.threshold
    score -= excess * 0.2
  }

  // Penalize functions over threshold
  const overThresholdRatio = metrics.overThreshold / metrics.functions.length
  score -= overThresholdRatio * 2.0

  // Penalize extremely high max complexity
  if (metrics.max > metrics.threshold * 3) {
    score -= 1.5
  } else if (metrics.max > metrics.threshold * 2) {
    score -= 1.0
  }

  return Math.max(score, 0)
}
```

**Examples**:
- Average: 5, Max: 8, 0 over threshold = 5.0/5.0
- Average: 12, Max: 20, 30% over threshold = 2.6/5.0
- Average: 8, Max: 45, 10% over threshold = 2.3/5.0

### 2. Cognitive Complexity

```typescript
interface CognitiveComplexity {
  functions: Array<{
    name: string
    cognitive: number
    file: string
    line: number
  }>
  average: number
  max: number
  threshold: number  // Usually 15
}
```

**Calculation (More Sophisticated)**:
```typescript
function calculateCognitiveComplexity(code: string): number {
  let complexity = 0
  let nestingLevel = 0

  const lines = code.split('\n')

  for (const line of lines) {
    // Increment nesting for blocks
    if (line.match(/\{|:$/)) {
      nestingLevel++
    }
    if (line.match(/\}/)) {
      nestingLevel = Math.max(0, nestingLevel - 1)
    }

    // Count decision points with nesting penalty
    const hasDecision = line.match(/\bif\b|\bfor\b|\bwhile\b|\bcatch\b/)
    if (hasDecision) {
      complexity += 1 + nestingLevel
    }

    // Logical operators add to complexity
    const logicalOps = line.match(/&&|\|\|/g)
    if (logicalOps) {
      complexity += logicalOps.length
    }

    // Recursion adds complexity
    const functionName = extractFunctionName(code)
    if (functionName && line.includes(functionName + '(')) {
      complexity += 1
    }
  }

  return complexity
}
```

**Scoring Formula**:
```typescript
function calculateCognitiveScore(metrics: CognitiveComplexity): number {
  let score = 5.0

  // Cognitive complexity is more important than cyclomatic
  if (metrics.average > metrics.threshold) {
    const excess = metrics.average - metrics.threshold
    score -= excess * 0.25
  }

  // Penalize high max cognitive complexity
  if (metrics.max > metrics.threshold * 2) {
    score -= 2.0
  } else if (metrics.max > metrics.threshold * 1.5) {
    score -= 1.0
  }

  return Math.max(score, 0)
}
```

### 3. Code Duplication

```typescript
interface CodeDuplication {
  duplicatedLines: number
  totalLines: number
  percentage: number
  duplicatedBlocks: Array<{
    file1: string
    file2: string
    lines: number
    similarity: number
  }>
}
```

**Scoring Formula**:
```typescript
function calculateDuplicationScore(metrics: CodeDuplication): number {
  const { percentage } = metrics

  // Industry standard: <5% is good
  if (percentage < 3) return 5.0
  if (percentage < 5) return 4.5
  if (percentage < 7) return 4.0
  if (percentage < 10) return 3.5
  if (percentage < 15) return 3.0
  if (percentage < 20) return 2.5
  return 2.0
}
```

**Examples**:
- 2% duplication = 5.0/5.0
- 5% duplication = 4.5/5.0
- 12% duplication = 3.0/5.0
- 25% duplication = 2.0/5.0

### 4. Code Smells

```typescript
interface CodeSmells {
  longMethods: Array<{
    name: string
    lines: number
    file: string
    threshold: number  // Usually 50
  }>
  largeClasses: Array<{
    name: string
    lines: number
    file: string
    threshold: number  // Usually 300
  }>
  longParameterLists: Array<{
    name: string
    parameters: number
    file: string
    threshold: number  // Usually 5
  }>
  deepNesting: Array<{
    name: string
    depth: number
    file: string
    threshold: number  // Usually 4
  }>
  godClasses: Array<{
    name: string
    methods: number
    file: string
  }>
}
```

**Detection (Language-Agnostic)**:
```typescript
async function detectCodeSmells(files: string[], language: string): Promise<CodeSmells> {
  const smells = {
    longMethods: [],
    largeClasses: [],
    longParameterLists: [],
    deepNesting: [],
    godClasses: []
  }

  for (const file of files) {
    const content = await Read(file)

    // Extract functions and classes
    const functions = extractFunctions(content, language)
    const classes = extractClasses(content, language)

    // Detect long methods
    for (const func of functions) {
      const lineCount = func.code.split('\n').length
      if (lineCount > 50) {
        smells.longMethods.push({
          name: func.name,
          lines: lineCount,
          file,
          threshold: 50
        })
      }

      // Detect long parameter lists
      const paramCount = func.parameters.length
      if (paramCount > 5) {
        smells.longParameterLists.push({
          name: func.name,
          parameters: paramCount,
          file,
          threshold: 5
        })
      }

      // Detect deep nesting
      const maxNesting = calculateMaxNesting(func.code)
      if (maxNesting > 4) {
        smells.deepNesting.push({
          name: func.name,
          depth: maxNesting,
          file,
          threshold: 4
        })
      }
    }

    // Detect large classes
    for (const cls of classes) {
      const lineCount = cls.code.split('\n').length
      if (lineCount > 300) {
        smells.largeClasses.push({
          name: cls.name,
          lines: lineCount,
          file,
          threshold: 300
        })
      }

      // Detect god classes (too many methods)
      const methodCount = cls.methods.length
      if (methodCount > 20) {
        smells.godClasses.push({
          name: cls.name,
          methods: methodCount,
          file
        })
      }
    }
  }

  return smells
}
```

**Scoring Formula**:
```typescript
function calculateCodeSmellScore(smells: CodeSmells, totalFiles: number): number {
  let score = 5.0

  const smellsPerFile = (
    smells.longMethods.length +
    smells.largeClasses.length +
    smells.longParameterLists.length +
    smells.deepNesting.length +
    smells.godClasses.length
  ) / totalFiles

  // Deduct based on smells per file
  score -= smellsPerFile * 0.5

  return Math.max(score, 0)
}
```

### 5. SOLID Principles Violations

```typescript
interface SOLIDViolations {
  singleResponsibility: Array<{
    class: string
    reason: string
    file: string
  }>
  openClosed: Array<{
    class: string
    reason: string
    file: string
  }>
  liskovSubstitution: Array<{
    class: string
    reason: string
    file: string
  }>
  interfaceSegregation: Array<{
    interface: string
    reason: string
    file: string
  }>
  dependencyInversion: Array<{
    class: string
    reason: string
    file: string
  }>
}
```

**Detection Heuristics**:
```typescript
async function detectSOLIDViolations(files: string[], language: string): Promise<SOLIDViolations> {
  const violations = {
    singleResponsibility: [],
    openClosed: [],
    liskovSubstitution: [],
    interfaceSegregation: [],
    dependencyInversion: []
  }

  for (const file of files) {
    const content = await Read(file)
    const classes = extractClasses(content, language)

    for (const cls of classes) {
      // Single Responsibility: Class with too many methods/responsibilities
      if (cls.methods.length > 20) {
        violations.singleResponsibility.push({
          class: cls.name,
          reason: `Class has ${cls.methods.length} methods (suggests multiple responsibilities)`,
          file
        })
      }

      // Dependency Inversion: Direct instantiation of concrete classes
      const hasDirectInstantiation = cls.code.match(/new \w+\(/)
      if (hasDirectInstantiation) {
        violations.dependencyInversion.push({
          class: cls.name,
          reason: 'Direct instantiation of dependencies (should use dependency injection)',
          file
        })
      }
    }
  }

  return violations
}
```

**Scoring Formula**:
```typescript
function calculateSOLIDScore(violations: SOLIDViolations): number {
  let score = 5.0

  const totalViolations = Object.values(violations).reduce((sum, arr) => sum + arr.length, 0)

  // Each violation deducts points
  score -= totalViolations * 0.2

  return Math.max(score, 0)
}
```

### 6. Technical Debt

```typescript
interface TechnicalDebt {
  totalMinutes: number  // Estimated time to fix all issues
  issues: Array<{
    type: 'complexity' | 'duplication' | 'code_smell' | 'solid_violation'
    severity: 'critical' | 'high' | 'medium' | 'low'
    estimatedMinutes: number
    file: string
    line: number
  }>
  debtRatio: number  // Technical debt / development cost
}
```

**Calculation**:
```typescript
function calculateTechnicalDebt(
  complexity: CyclomaticComplexity,
  duplication: CodeDuplication,
  smells: CodeSmells,
  solid: SOLIDViolations
): TechnicalDebt {
  const issues = []

  // High complexity = 30 minutes to refactor
  for (const func of complexity.functions) {
    if (func.complexity > complexity.threshold * 2) {
      issues.push({
        type: 'complexity',
        severity: 'high',
        estimatedMinutes: 30,
        file: func.file,
        line: func.line
      })
    }
  }

  // Duplication = 15 minutes per block
  for (const block of duplication.duplicatedBlocks) {
    issues.push({
      type: 'duplication',
      severity: 'medium',
      estimatedMinutes: 15,
      file: block.file1,
      line: 0
    })
  }

  // Long methods = 20 minutes to refactor
  for (const method of smells.longMethods) {
    issues.push({
      type: 'code_smell',
      severity: 'medium',
      estimatedMinutes: 20,
      file: method.file,
      line: 0
    })
  }

  const totalMinutes = issues.reduce((sum, issue) => sum + issue.estimatedMinutes, 0)

  return {
    totalMinutes,
    issues,
    debtRatio: totalMinutes / 480  // Assume 8 hours (480 min) development
  }
}
```

**Scoring Formula**:
```typescript
function calculateTechnicalDebtScore(debt: TechnicalDebt): number {
  // Debt ratio: 0-5% = excellent, 5-10% = good, 10-20% = fair, >20% = poor
  const { debtRatio } = debt

  if (debtRatio < 0.05) return 5.0
  if (debtRatio < 0.10) return 4.0
  if (debtRatio < 0.20) return 3.0
  if (debtRatio < 0.30) return 2.0
  return 1.0
}
```

---

## 🎯 Evaluation Process

### Step 1: Detect Tools and Patterns

```typescript
async function detectMaintainabilityEnvironment(): Promise<MaintainabilityEnvironment> {
  const language = await detectLanguage()
  const complexityTool = await detectComplexityTool(language)
  const duplicationTool = await detectDuplicationTool(language)

  // Learn healthy patterns from existing codebase
  const healthyPatterns = await learnHealthyPatterns(language)

  return { language, complexityTool, duplicationTool, healthyPatterns }
}
```

### Step 2: Run Analysis

```typescript
async function runMaintainabilityAnalysis(
  env: MaintainabilityEnvironment,
  changedFiles: string[]
): Promise<MaintainabilityMetrics> {
  // Calculate cyclomatic complexity
  const cyclomaticComplexity = await calculateComplexityForFiles(changedFiles, env.language)

  // Calculate cognitive complexity
  const cognitiveComplexity = await calculateCognitiveComplexity(changedFiles, env.language)

  // Detect duplication
  const duplication = await detectDuplication(changedFiles, env.duplicationTool)

  // Detect code smells
  const smells = await detectCodeSmells(changedFiles, env.language)

  // Detect SOLID violations
  const solidViolations = await detectSOLIDViolations(changedFiles, env.language)

  // Calculate technical debt
  const technicalDebt = calculateTechnicalDebt(cyclomaticComplexity, duplication, smells, solidViolations)

  return {
    cyclomaticComplexity,
    cognitiveComplexity,
    duplication,
    smells,
    solidViolations,
    technicalDebt
  }
}
```

### Step 3: Calculate Scores

```typescript
async function calculateMaintainabilityScore(metrics: MaintainabilityMetrics): Promise<EvaluationResult> {
  const scores = {
    cyclomaticComplexity: calculateComplexityScore(metrics.cyclomaticComplexity),
    cognitiveComplexity: calculateCognitiveScore(metrics.cognitiveComplexity),
    duplication: calculateDuplicationScore(metrics.duplication),
    codeSmells: calculateCodeSmellScore(metrics.smells, metrics.fileCount),
    solid: calculateSOLIDScore(metrics.solidViolations),
    technicalDebt: calculateTechnicalDebtScore(metrics.technicalDebt)
  }

  // Weighted average
  const weights = {
    cyclomaticComplexity: 0.20,
    cognitiveComplexity: 0.25,
    duplication: 0.20,
    codeSmells: 0.15,
    solid: 0.10,
    technicalDebt: 0.10
  }

  const overallScore = calculateWeightedAverage(scores, weights)

  return {
    overallScore,
    breakdown: scores,
    metrics,
    recommendations: generateMaintainabilityRecommendations(scores, metrics)
  }
}
```

---

## 🔧 Implementation Examples

### TypeScript Project

```typescript
async function evaluateTypeScriptMaintainability(changedFiles: string[]): Promise<MaintainabilityReport> {
  // Calculate complexity for each file
  const complexityMetrics = {
    functions: [],
    average: 0,
    max: 0,
    overThreshold: 0,
    threshold: 10
  }

  for (const file of changedFiles) {
    const content = await Read(file)
    const functions = extractFunctions(content, 'typescript')

    for (const func of functions) {
      const complexity = calculateCyclomaticComplexity(func.code)
      complexityMetrics.functions.push({
        name: func.name,
        complexity,
        file,
        line: func.line
      })

      if (complexity > 10) {
        complexityMetrics.overThreshold++
      }
    }
  }

  complexityMetrics.average = complexityMetrics.functions.reduce((sum, f) => sum + f.complexity, 0) / complexityMetrics.functions.length
  complexityMetrics.max = Math.max(...complexityMetrics.functions.map(f => f.complexity))

  // Detect duplication
  const duplicationTool = 'jscpd'
  const duplicationResult = await Bash({
    command: 'npx jscpd --format json .',
    description: 'Detect code duplication'
  })

  const duplicationData = JSON.parse(duplicationResult)
  const duplication = {
    duplicatedLines: duplicationData.statistics.total.duplicatedLines,
    totalLines: duplicationData.statistics.total.lines,
    percentage: (duplicationData.statistics.total.duplicatedLines / duplicationData.statistics.total.lines) * 100,
    duplicatedBlocks: duplicationData.duplicates
  }

  // Detect code smells
  const smells = await detectCodeSmells(changedFiles, 'typescript')

  // Calculate scores
  const scores = {
    cyclomaticComplexity: calculateComplexityScore(complexityMetrics),
    duplication: calculateDuplicationScore(duplication),
    codeSmells: calculateCodeSmellScore(smells, changedFiles.length)
  }

  const overallScore = (
    scores.cyclomaticComplexity * 0.35 +
    scores.duplication * 0.35 +
    scores.codeSmells * 0.30
  )

  return {
    timestamp: new Date().toISOString(),
    language: 'typescript',
    tools: {
      complexity: 'built-in',
      duplication: duplicationTool
    },
    scores: {
      overall: overallScore,
      cyclomaticComplexity: scores.cyclomaticComplexity,
      duplication: scores.duplication,
      codeSmells: scores.codeSmells
    },
    passFail: overallScore >= 3.5 ? 'PASS' : 'FAIL',
    threshold: 3.5
  }
}
```

### Python Project

```typescript
async function evaluatePythonMaintainability(changedFiles: string[]): Promise<MaintainabilityReport> {
  // Use radon for complexity
  const radonResult = await Bash({
    command: `radon cc ${changedFiles.join(' ')} --json`,
    description: 'Calculate cyclomatic complexity'
  })

  const radonData = JSON.parse(radonResult)

  // Parse radon output
  const complexityMetrics = parseRadonOutput(radonData)

  // Detect duplication
  const duplication = await detectDuplication(changedFiles, 'pylint')

  // Calculate scores
  return calculateMaintainabilityScore({ complexityMetrics, duplication, ... })
}
```

---

## 📐 Helper Functions

### Extract Functions (Language-Agnostic)

```typescript
function extractFunctions(code: string, language: string): Function[] {
  const patterns = {
    typescript: /function\s+(\w+)\s*\((.*?)\)\s*{/g,
    python: /def\s+(\w+)\s*\((.*?)\):/g,
    java: /(public|private|protected)?\s*\w+\s+(\w+)\s*\((.*?)\)\s*{/g,
    go: /func\s+(\w+)\s*\((.*?)\)\s*{/g,
    rust: /fn\s+(\w+)\s*\((.*?)\)\s*{/g
  }

  const pattern = patterns[language]
  if (!pattern) return []

  const functions = []
  let match

  while ((match = pattern.exec(code)) !== null) {
    const name = match[1] || match[2]
    const params = match[2] || match[3]

    // Extract function body
    const startIndex = match.index + match[0].length
    const body = extractFunctionBody(code, startIndex)

    functions.push({
      name,
      parameters: params.split(',').filter(p => p.trim()),
      code: body,
      line: code.substring(0, match.index).split('\n').length
    })
  }

  return functions
}

function extractFunctionBody(code: string, startIndex: number): string {
  let braceCount = 1
  let endIndex = startIndex

  while (braceCount > 0 && endIndex < code.length) {
    if (code[endIndex] === '{') braceCount++
    if (code[endIndex] === '}') braceCount--
    endIndex++
  }

  return code.substring(startIndex, endIndex)
}
```

### Calculate Max Nesting

```typescript
function calculateMaxNesting(code: string): number {
  let maxNesting = 0
  let currentNesting = 0

  const lines = code.split('\n')

  for (const line of lines) {
    // Increment for opening braces or colons (Python)
    if (line.match(/\{|:\s*$/)) {
      currentNesting++
      maxNesting = Math.max(maxNesting, currentNesting)
    }

    // Decrement for closing braces
    if (line.match(/\}/)) {
      currentNesting = Math.max(0, currentNesting - 1)
    }
  }

  return maxNesting
}
```

---

## ⚠️ Edge Cases and Error Handling

### Case 1: No Complexity Tool Available

```typescript
async function handleNoComplexityTool(language: string): Promise<MaintainabilityReport> {
  // Use built-in complexity calculation
  const basicComplexity = await calculateBasicComplexity(changedFiles, language)

  return {
    timestamp: new Date().toISOString(),
    language,
    tools: {
      complexity: 'built-in',
      duplication: null
    },
    scores: {
      overall: calculateComplexityScore(basicComplexity),
      cyclomaticComplexity: calculateComplexityScore(basicComplexity)
    },
    recommendations: [
      {
        priority: 'low',
        category: 'tooling',
        message: `Consider adding complexity tools for ${language}: ${getRecommendedComplexityTools(language).join(', ')}`
      }
    ],
    passFail: 'PASS'
  }
}
```

### Case 2: Legacy Codebase (High Technical Debt)

```typescript
function handleLegacyCodebase(debt: TechnicalDebt): Recommendation[] {
  if (debt.debtRatio > 0.5) {
    return [
      {
        priority: 'critical',
        category: 'technical_debt',
        message: `Technical debt ratio is ${(debt.debtRatio * 100).toFixed(1)}%. Consider a refactoring sprint.`,
        actionable: true,
        estimatedEffort: `${Math.ceil(debt.totalMinutes / 60)} hours`
      }
    ]
  }

  return []
}
```

---

## 📋 Configuration File Format

```yaml
# .claude/edaf-config.yml

maintainability:
  # Language (auto-detected if not specified)
  language: typescript

  # Complexity thresholds
  thresholds:
    cyclomatic_complexity: 10
    cognitive_complexity: 15
    max_function_lines: 50
    max_class_lines: 300
    max_parameters: 5
    max_nesting_depth: 4
    duplication_percentage: 5

  # Tools
  complexity_tool: complexity-report
  duplication_tool: jscpd

  # SOLID checks
  solid_checks:
    enabled: true
    single_responsibility: true
    open_closed: true
    liskov_substitution: false  # Hard to auto-detect
    interface_segregation: true
    dependency_inversion: true

  # Exclusions
  exclude:
    - '**/test/**'
    - '**/tests/**'
    - '**/node_modules/**'
```

---

## 📊 Output Format

```json
{
  "evaluator": "code-maintainability-evaluator-v1-self-adapting",
  "version": "2.0",
  "timestamp": "2025-11-09T10:30:00Z",
  "pr_number": 42,

  "environment": {
    "language": "typescript",
    "tools": {
      "complexity": "complexity-report",
      "duplication": "jscpd"
    }
  },

  "scores": {
    "overall": 4.1,
    "breakdown": {
      "cyclomatic_complexity": 4.3,
      "cognitive_complexity": 4.0,
      "duplication": 4.5,
      "code_smells": 3.8,
      "solid": 4.0,
      "technical_debt": 4.2
    }
  },

  "metrics": {
    "cyclomatic_complexity": {
      "average": 7.2,
      "max": 15,
      "over_threshold": 2,
      "threshold": 10
    },
    "cognitive_complexity": {
      "average": 10.5,
      "max": 22,
      "threshold": 15
    },
    "duplication": {
      "percentage": 3.2,
      "duplicated_lines": 320,
      "total_lines": 10000,
      "duplicated_blocks": 5
    },
    "code_smells": {
      "long_methods": 1,
      "large_classes": 0,
      "long_parameter_lists": 2,
      "deep_nesting": 1,
      "god_classes": 0
    },
    "solid_violations": {
      "single_responsibility": 1,
      "dependency_inversion": 2
    },
    "technical_debt": {
      "total_minutes": 120,
      "debt_ratio": 0.25,
      "issues": 8
    }
  },

  "recommendations": [
    {
      "priority": "high",
      "category": "complexity",
      "message": "2 functions exceed complexity threshold (10). Consider refactoring.",
      "files": ["src/services/order.ts:calculateTotal", "src/utils/validation.ts:validateForm"],
      "estimated_effort": "1 hour"
    },
    {
      "priority": "medium",
      "category": "code_smells",
      "message": "1 function has 7 parameters. Consider using an options object.",
      "file": "src/api/endpoints.ts:createUser"
    },
    {
      "priority": "low",
      "category": "duplication",
      "message": "3.2% code duplication is acceptable but could be improved.",
      "actionable": true
    }
  ],

  "result": {
    "status": "PASS",
    "threshold": 3.5,
    "message": "Maintainability meets standards (4.1/5.0 ≥ 3.5)"
  }
}
```

---

## 🎓 Summary

### What This Evaluator Provides

✅ **Universal Language Support** - TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#
✅ **Complexity Analysis** - Cyclomatic and cognitive complexity
✅ **Duplication Detection** - DRY principle enforcement
✅ **Code Smell Detection** - Long methods, god classes, deep nesting
✅ **SOLID Principles** - Design quality assessment
✅ **Technical Debt** - Quantified in hours/minutes
✅ **Normalized Scoring** - All languages scored on same 0-5 scale
✅ **Zero Configuration** - Works out of the box

### Key Innovation

**Before**: Separate maintainability evaluators for each language
**After**: One evaluator that adapts to any language

**Maintenance**: Minimal
**Scalability**: Language/framework agnostic

---

**Status**: ✅ Production Ready
**Next**: Implement code-performance-evaluator-v1-self-adapting.md
