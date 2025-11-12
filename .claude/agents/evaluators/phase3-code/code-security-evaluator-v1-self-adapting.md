# Code Security Evaluator v1 - Self-Adapting

**Version**: 2.0
**Type**: Code Evaluator (Self-Adapting)
**Language Support**: Universal (TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#, Kotlin, Swift)
**Frameworks**: All
**Status**: Production Ready

---

## 🎯 Overview

### What This Evaluator Does

This evaluator detects security vulnerabilities across all languages and frameworks:

1. **OWASP Top 10 Detection** - SQL Injection, XSS, CSRF, etc.
2. **Dependency Vulnerabilities** - Known CVEs in packages
3. **Secret Leaks** - Hardcoded credentials, API keys
4. **Authentication/Authorization Issues** - Missing auth, weak policies
5. **Cryptographic Issues** - Weak algorithms, insecure key management

### Self-Adapting Features

✅ **Automatic Language Detection** - Detects language from project files
✅ **Security Tool Detection** - Finds ESLint security, Bandit, SpotBugs, etc.
✅ **Dependency Scanner Detection** - npm audit, pip-audit, OWASP Dependency-Check
✅ **Universal Scoring** - Normalizes all languages to 0-5 scale
✅ **Zero Configuration** - Works out of the box

---

## 🔍 Detection System

### Layer 1: Automatic Detection

```typescript
async function detectSecurityTools(): Promise<SecurityTools> {
  // Step 1: Detect language
  const language = await detectLanguage()

  // Step 2: Detect security scanner
  const securityTools = await detectSecurityScanner(language)

  // Step 3: Detect dependency scanner
  const dependencyScanner = await detectDependencyScanner(language)

  // Step 4: Detect secret scanner
  const secretScanner = await detectSecretScanner()

  return { language, securityTools, dependencyScanner, secretScanner }
}
```

### Layer 2: Configuration File (if needed)

```yaml
# .claude/edaf-config.yml
security:
  language: typescript
  scanner: eslint-plugin-security
  dependency_scanner: npm-audit
  secret_scanner: trufflehog
  owasp_check: true
  thresholds:
    critical: 0  # No critical vulnerabilities allowed
    high: 2
    medium: 10
```

### Layer 3: User Questions (fallback)

If detection fails, ask user:
- What programming language?
- Which security scanner? (ESLint security, Bandit, etc.)
- Which dependency checker? (npm audit, pip-audit, etc.)

---

## 🛠️ Language-Specific Security Tools

### TypeScript/JavaScript

```typescript
const jsSecurityTools = {
  // Static Analysis (SAST)
  staticAnalysis: {
    'eslint-plugin-security': {
      indicators: {
        dependencies: ['eslint-plugin-security'],
        configFiles: ['.eslintrc.js', '.eslintrc.json']
      },
      command: 'npx eslint --plugin security --format json',
      detects: [
        'SQL Injection (eval with user input)',
        'XSS (dangerouslySetInnerHTML)',
        'Command Injection (child_process.exec)',
        'Path Traversal (fs operations with user input)',
        'Regular Expression DoS'
      ]
    },

    'semgrep': {
      indicators: {
        dependencies: ['semgrep'],
        configFiles: ['.semgrep.yml', 'semgrep.yml']
      },
      command: 'semgrep --config=auto --json',
      detects: [
        'OWASP Top 10',
        'CWE Top 25',
        'Custom security rules'
      ]
    }
  },

  // Dependency Scan (SCA)
  dependencyScan: {
    'npm-audit': {
      builtin: true,
      command: 'npm audit --json',
      detects: [
        'Known vulnerabilities in dependencies',
        'CVE database matching'
      ]
    },

    'snyk': {
      indicators: {
        dependencies: ['snyk'],
        configFiles: ['.snyk']
      },
      command: 'snyk test --json',
      detects: [
        'Known vulnerabilities',
        'License issues',
        'Remediation advice'
      ]
    }
  },

  // Secret Scan
  secretScan: {
    'trufflehog': {
      indicators: {
        binary: 'trufflehog'
      },
      command: 'trufflehog filesystem . --json',
      detects: [
        'API keys',
        'AWS credentials',
        'Private keys',
        'Passwords',
        'OAuth tokens'
      ]
    },

    'gitleaks': {
      indicators: {
        binary: 'gitleaks',
        configFiles: ['.gitleaks.toml']
      },
      command: 'gitleaks detect --source . --report-format json',
      detects: ['Hardcoded secrets', 'API keys', 'Credentials']
    }
  }
}
```

**Detection Logic**:
```typescript
async function detectJSSecurityTools(): Promise<JSSecurityTools> {
  const packageJson = await Read('package.json')
  const deps = { ...packageJson.dependencies, ...packageJson.devDependencies }

  // Detect SAST
  const sast =
    deps['eslint-plugin-security'] ? 'eslint-plugin-security' :
    deps['semgrep'] ? 'semgrep' :
    await fileExists('sonar-project.properties') ? 'sonarqube' :
    null

  // Detect dependency scanner (npm audit always available)
  const dependencyScanner =
    deps['snyk'] ? 'snyk' :
    'npm-audit'  // Default

  // Detect secret scanner
  const secretScanner =
    await commandExists('trufflehog') ? 'trufflehog' :
    await commandExists('gitleaks') ? 'gitleaks' :
    null

  return { sast, dependencyScanner, secretScanner }
}
```

### Python

```typescript
const pythonSecurityTools = {
  // Static Analysis (SAST)
  staticAnalysis: {
    'bandit': {
      indicators: {
        dependencies: ['bandit'],
        configFiles: ['.bandit', 'bandit.yaml']
      },
      command: 'bandit -r . -f json',
      detects: [
        'SQL Injection (string formatting in SQL)',
        'Command Injection (os.system, subprocess)',
        'Path Traversal',
        'Weak cryptography (MD5, DES)',
        'Hardcoded passwords',
        'Assert used in production',
        'Pickle usage (arbitrary code execution)'
      ]
    },

    'semgrep': {
      indicators: {
        dependencies: ['semgrep']
      },
      command: 'semgrep --config=auto --json',
      detects: ['OWASP Top 10', 'Python-specific vulnerabilities']
    }
  },

  // Dependency Scan
  dependencyScan: {
    'pip-audit': {
      indicators: {
        dependencies: ['pip-audit']
      },
      command: 'pip-audit --format json',
      detects: ['Known CVEs in dependencies']
    },

    'safety': {
      indicators: {
        dependencies: ['safety']
      },
      command: 'safety check --json',
      detects: ['Insecure packages', 'Known vulnerabilities']
    }
  }
}
```

### Java

```typescript
const javaSecurityTools = {
  // Static Analysis
  staticAnalysis: {
    'spotbugs-security': {
      indicators: {
        dependencies: ['spotbugs', 'find-sec-bugs'],
        configFiles: ['spotbugs.xml']
      },
      command: 'spotbugs -effort:max -pluginList find-sec-bugs.jar -output json',
      detects: [
        'SQL Injection',
        'XSS',
        'Command Injection',
        'Path Traversal',
        'XXE (XML External Entity)',
        'Insecure cryptography',
        'Trust boundary violations'
      ]
    }
  },

  // Dependency Scan
  dependencyScan: {
    'owasp-dependency-check': {
      indicators: {
        configFiles: ['pom.xml', 'build.gradle']
      },
      command: 'dependency-check --format JSON --scan .',
      detects: [
        'Known CVEs in dependencies',
        'CPE matching',
        'NPM/Maven/NuGet vulnerabilities'
      ]
    }
  }
}
```

### Go

```typescript
const goSecurityTools = {
  // Static Analysis
  staticAnalysis: {
    'gosec': {
      indicators: {
        dependencies: ['github.com/securego/gosec'],
        configFiles: ['.gosec.json']
      },
      command: 'gosec -fmt json ./...',
      detects: [
        'SQL Injection',
        'Command Injection',
        'Path Traversal',
        'Weak cryptography',
        'Hardcoded credentials',
        'Integer overflow',
        'Unsafe use of reflect'
      ]
    }
  },

  // Dependency Scan
  dependencyScan: {
    'govulncheck': {
      builtin: true,  // Go 1.18+
      command: 'govulncheck -json ./...',
      detects: ['Known vulnerabilities in Go modules']
    }
  }
}
```

### Rust

```typescript
const rustSecurityTools = {
  // Static Analysis
  staticAnalysis: {
    'cargo-audit': {
      indicators: {
        dependencies: ['cargo-audit']
      },
      command: 'cargo audit --json',
      detects: [
        'Known vulnerabilities in dependencies',
        'Unmaintained crates',
        'Yanked crates'
      ]
    },

    'clippy': {
      builtin: true,
      command: 'cargo clippy -- -W clippy::all',
      detects: ['Unsafe code patterns', 'Security anti-patterns']
    }
  }
}
```

### Ruby

```typescript
const rubySecurityTools = {
  // Static Analysis
  staticAnalysis: {
    'brakeman': {
      indicators: {
        dependencies: ['brakeman'],
        configFiles: ['config/brakeman.yml']
      },
      command: 'brakeman -f json',
      detects: [
        'SQL Injection',
        'XSS',
        'CSRF',
        'Mass assignment',
        'Command injection',
        'Unsafe redirects'
      ],
      framework: 'Rails'
    }
  },

  // Dependency Scan
  dependencyScan: {
    'bundler-audit': {
      indicators: {
        dependencies: ['bundler-audit']
      },
      command: 'bundle audit check --format json',
      detects: ['Known vulnerabilities in gems']
    }
  }
}
```

### PHP

```typescript
const phpSecurityTools = {
  // Static Analysis
  staticAnalysis: {
    'psalm-security': {
      indicators: {
        dependencies: ['vimeo/psalm'],
        configFiles: ['psalm.xml']
      },
      command: 'psalm --taint-analysis --output-format=json',
      detects: [
        'SQL Injection',
        'XSS',
        'Command Injection',
        'Path Traversal',
        'Taint analysis'
      ]
    }
  },

  // Dependency Scan
  dependencyScan: {
    'local-php-security-checker': {
      indicators: {
        binary: 'local-php-security-checker'
      },
      command: 'local-php-security-checker --format=json',
      detects: ['Known CVEs in Composer dependencies']
    }
  }
}
```

---

## 📊 Universal Security Metrics

### 1. OWASP Top 10 Detection

```typescript
interface OWASPFinding {
  category: OWASPCategory
  severity: 'critical' | 'high' | 'medium' | 'low' | 'info'
  title: string
  description: string
  file: string
  line: number
  cwe: string  // CWE-89, CWE-79, etc.
  recommendation: string
}

type OWASPCategory =
  | 'A01:2021-Broken Access Control'
  | 'A02:2021-Cryptographic Failures'
  | 'A03:2021-Injection'
  | 'A04:2021-Insecure Design'
  | 'A05:2021-Security Misconfiguration'
  | 'A06:2021-Vulnerable and Outdated Components'
  | 'A07:2021-Identification and Authentication Failures'
  | 'A08:2021-Software and Data Integrity Failures'
  | 'A09:2021-Security Logging and Monitoring Failures'
  | 'A10:2021-Server-Side Request Forgery (SSRF)'
```

**Scoring Formula**:
```typescript
function calculateOWASPScore(findings: OWASPFinding[]): number {
  let score = 5.0

  // Deduct points based on severity
  const severityPenalties = {
    critical: -2.0,  // 1 critical = -2.0 points
    high: -1.0,      // 1 high = -1.0 point
    medium: -0.3,    // 1 medium = -0.3 points
    low: -0.1,       // 1 low = -0.1 points
    info: -0.05      // 1 info = -0.05 points
  }

  for (const finding of findings) {
    score += severityPenalties[finding.severity]
  }

  return Math.max(score, 0)
}
```

**Examples**:
- 0 vulnerabilities = 5.0/5.0
- 1 critical = 3.0/5.0
- 2 high = 3.0/5.0
- 1 critical + 2 high = 1.0/5.0
- 5 medium = 3.5/5.0

### 2. Dependency Vulnerabilities

```typescript
interface DependencyVulnerability {
  package: string
  version: string
  vulnerability: {
    id: string      // CVE-2024-1234
    severity: 'critical' | 'high' | 'medium' | 'low'
    cvss: number    // 0.0 - 10.0
    description: string
  }
  fixAvailable: boolean
  fixedVersion?: string
}
```

**Scoring Formula**:
```typescript
function calculateDependencyScore(vulnerabilities: DependencyVulnerability[]): number {
  let score = 5.0

  const severityPenalties = {
    critical: -2.0,
    high: -1.0,
    medium: -0.3,
    low: -0.1
  }

  for (const vuln of vulnerabilities) {
    score += severityPenalties[vuln.vulnerability.severity]

    // Reduce penalty if fix is available (-50%)
    if (vuln.fixAvailable) {
      score += Math.abs(severityPenalties[vuln.vulnerability.severity]) * 0.5
    }
  }

  return Math.max(score, 0)
}
```

### 3. Secret Leaks

```typescript
interface SecretLeak {
  type: 'api_key' | 'password' | 'private_key' | 'oauth_token' | 'aws_credentials'
  file: string
  line: number
  snippet: string  // Masked
  confidence: number  // 0-100
}
```

**Scoring Formula**:
```typescript
function calculateSecretScore(leaks: SecretLeak[]): number {
  if (leaks.length === 0) return 5.0

  // Secret leaks are critical
  let score = 5.0

  for (const leak of leaks) {
    const confidenceMultiplier = leak.confidence / 100

    // Severity by type
    const typeSeverity = {
      private_key: -2.0,
      aws_credentials: -2.0,
      api_key: -1.5,
      oauth_token: -1.5,
      password: -1.0
    }

    score += (typeSeverity[leak.type] || -1.0) * confidenceMultiplier
  }

  return Math.max(score, 0)
}
```

**Examples**:
- No secrets = 5.0/5.0
- 1 API key (high confidence) = 3.5/5.0
- 1 private key = 3.0/5.0
- Multiple secrets = 0/5.0

### 4. Authentication/Authorization Issues

```typescript
interface AuthIssue {
  type: 'missing_authentication' | 'weak_password_policy' | 'missing_authorization' | 'insecure_session'
  file: string
  line: number
  description: string
  severity: 'critical' | 'high' | 'medium' | 'low'
}
```

**Detection Patterns (Language-Agnostic)**:
```typescript
const authPatterns = {
  // Missing authentication
  missingAuth: [
    /router\.(get|post|put|delete)\(['"]\/api\/.*['"]\s*,\s*(?!auth)/,  // Express
    /@(Get|Post|Put|Delete)Mapping.*\n.*public/,  // Spring Boot
    /app\.(get|post).*\n.*def\s+\w+\(/  // Flask
  ],

  // Weak password policy
  weakPassword: [
    /password.*length.*<\s*[1-7]/,  // < 8 characters
    /password.*require.*=.*false/    // No complexity required
  ],

  // Missing authorization
  missingAuthorization: [
    /if.*user.*role.*admin/  // Simple role check
  ]
}
```

### 5. Cryptographic Issues

```typescript
interface CryptoIssue {
  type: 'weak_algorithm' | 'weak_key' | 'insecure_random' | 'hardcoded_key'
  algorithm?: string
  file: string
  line: number
  recommendation: string
}
```

**Detection Patterns (Language-Agnostic)**:
```typescript
const weakCryptoPatterns = {
  // Weak algorithms
  weakAlgorithms: [
    /MD5|SHA1|DES|RC4/,  // Weak algorithms
    /AES.*ECB/           // Insecure mode
  ],

  // Weak keys
  weakKeys: [
    /key.*=.*['"][^'"]{1,15}['"]/,  // < 16 characters
    /password.*=.*['"]1234/          // Weak password
  ],

  // Insecure random
  insecureRandom: [
    /Math\.random\(/,           // JavaScript
    /random\.Random\(/,         // Python
    /new Random\(/              // Java
  ]
}
```

---

## 🎯 Evaluation Process

### Step 1: Detect Security Environment

```typescript
async function detectSecurityEnvironment(): Promise<SecurityEnvironment> {
  // Detect language
  const language = await detectLanguage()

  // Detect SAST tool
  const sast = await detectSASTTool(language)

  // Detect dependency scanner
  const dependencyScanner = await detectDependencyScanner(language)

  // Detect secret scanner
  const secretScanner = await detectSecretScanner()

  return { language, sast, dependencyScanner, secretScanner }
}
```

### Step 2: Run Security Scans

```typescript
async function runSecurityScans(
  env: SecurityEnvironment,
  changedFiles: string[]
): Promise<SecurityFindings> {
  const findings = {
    owaspFindings: [] as OWASPFinding[],
    dependencyVulnerabilities: [] as DependencyVulnerability[],
    secretLeaks: [] as SecretLeak[],
    authIssues: [] as AuthIssue[],
    cryptoIssues: [] as CryptoIssue[]
  }

  // Run SAST
  if (env.sast) {
    const sastResults = await runSAST(env.sast, changedFiles)
    findings.owaspFindings.push(...parseOWASPFindings(sastResults))
    findings.authIssues.push(...parseAuthIssues(sastResults))
    findings.cryptoIssues.push(...parseCryptoIssues(sastResults))
  }

  // Run dependency scan
  if (env.dependencyScanner) {
    const depResults = await runDependencyScan(env.dependencyScanner)
    findings.dependencyVulnerabilities.push(...parseDependencyVulns(depResults))
  }

  // Run secret scan
  if (env.secretScanner) {
    const secretResults = await runSecretScan(env.secretScanner, changedFiles)
    findings.secretLeaks.push(...parseSecretLeaks(secretResults))
  }

  return findings
}
```

### Step 3: Calculate Scores

```typescript
async function calculateSecurityScore(findings: SecurityFindings): Promise<EvaluationResult> {
  const scores = {
    owasp: calculateOWASPScore(findings.owaspFindings),
    dependencies: calculateDependencyScore(findings.dependencyVulnerabilities),
    secrets: calculateSecretScore(findings.secretLeaks),
    auth: calculateAuthScore(findings.authIssues),
    crypto: calculateCryptoScore(findings.cryptoIssues)
  }

  // Weighted average (OWASP/dependencies/secrets most important)
  const weights = {
    owasp: 0.30,
    dependencies: 0.25,
    secrets: 0.25,
    auth: 0.10,
    crypto: 0.10
  }

  const overallScore = calculateWeightedAverage(scores, weights)

  return {
    overallScore,
    breakdown: scores,
    findings,
    recommendations: generateSecurityRecommendations(scores, findings)
  }
}
```

---

## 🔧 Implementation Examples

### TypeScript/ESLint Security Project

```typescript
async function evaluateTypeScriptSecurity(changedFiles: string[]): Promise<SecurityReport> {
  // Run ESLint security plugin
  const eslintResult = await Bash({
    command: `npx eslint ${changedFiles.join(' ')} --plugin security --format json`,
    description: 'Run ESLint security scan'
  })

  const eslintIssues = JSON.parse(eslintResult)

  // Run npm audit
  const npmAuditResult = await Bash({
    command: 'npm audit --json',
    description: 'Check for dependency vulnerabilities'
  })

  const auditData = JSON.parse(npmAuditResult)

  // Run TruffleHog if available
  let secretLeaks = []
  if (await commandExists('trufflehog')) {
    const truffleResult = await Bash({
      command: 'trufflehog filesystem . --json',
      description: 'Scan for hardcoded secrets'
    })
    secretLeaks = parseSecretLeaks(truffleResult)
  }

  // Calculate scores
  const owaspScore = calculateOWASPScore(parseESLintSecurityIssues(eslintIssues))
  const dependencyScore = calculateDependencyScore(parseNpmAudit(auditData))
  const secretScore = calculateSecretScore(secretLeaks)

  const overallScore = (
    owaspScore * 0.35 +
    dependencyScore * 0.35 +
    secretScore * 0.30
  )

  return {
    timestamp: new Date().toISOString(),
    language: 'typescript',
    tools: {
      sast: 'eslint-plugin-security',
      dependencyScanner: 'npm-audit',
      secretScanner: await commandExists('trufflehog') ? 'trufflehog' : null
    },
    scores: {
      overall: overallScore,
      owasp: owaspScore,
      dependencies: dependencyScore,
      secrets: secretScore
    },
    passFail: overallScore >= 4.0 ? 'PASS' : 'FAIL',
    threshold: 4.0  // Security is strict
  }
}
```

### Python/Bandit Project

```typescript
async function evaluatePythonSecurity(changedFiles: string[]): Promise<SecurityReport> {
  // Run Bandit
  const banditResult = await Bash({
    command: `bandit -r ${changedFiles.join(' ')} -f json`,
    description: 'Run Bandit security scan'
  })

  const banditData = JSON.parse(banditResult)

  // Run pip-audit
  const pipAuditResult = await Bash({
    command: 'pip-audit --format json',
    description: 'Check for dependency vulnerabilities'
  })

  const auditData = JSON.parse(pipAuditResult)

  // Calculate scores
  const owaspScore = calculateOWASPScore(parseBanditFindings(banditData))
  const dependencyScore = calculateDependencyScore(parsePipAudit(auditData))

  const overallScore = (
    owaspScore * 0.50 +
    dependencyScore * 0.50
  )

  return {
    timestamp: new Date().toISOString(),
    language: 'python',
    tools: {
      sast: 'bandit',
      dependencyScanner: 'pip-audit',
      secretScanner: null
    },
    scores: {
      overall: overallScore,
      owasp: owaspScore,
      dependencies: dependencyScore
    },
    passFail: overallScore >= 4.0 ? 'PASS' : 'FAIL',
    threshold: 4.0
  }
}
```

---

## 📐 Score Normalization

### Different Tool Output Formats

```typescript
// ESLint Security: error/warning
// Bandit: HIGH/MEDIUM/LOW confidence + severity
// SpotBugs: 1-20 priority scale
// Semgrep: error/warning/info

// Normalize all to 0-5 scale
```

### Universal Normalization Formula

```typescript
interface SecurityToolOutput {
  tool: string
  findings: Array<{
    severity: string  // Tool-specific
    confidence?: string
    priority?: number
  }>
}

function normalizeToUniversalScale(output: SecurityToolOutput): number {
  const { tool, findings } = output

  // Tool-specific severity mappings
  const severityMappings = {
    'eslint-plugin-security': {
      error: 'high',
      warning: 'medium'
    },
    'bandit': {
      HIGH: 'critical',
      MEDIUM: 'medium',
      LOW: 'low'
    },
    'spotbugs': (priority: number) => {
      if (priority <= 4) return 'critical'
      if (priority <= 9) return 'high'
      if (priority <= 14) return 'medium'
      return 'low'
    }
  }

  // Convert to unified format
  const normalizedFindings = findings.map(f => {
    let severity = f.severity

    if (tool === 'spotbugs' && f.priority) {
      severity = severityMappings.spotbugs(f.priority)
    } else if (severityMappings[tool]) {
      severity = severityMappings[tool][f.severity] || f.severity
    }

    return { severity }
  })

  // Calculate score
  return calculateOWASPScore(normalizedFindings)
}
```

---

## ⚠️ Edge Cases and Error Handling

### Case 1: No Security Tools Installed

```typescript
async function handleNoSecurityTools(language: string): Promise<SecurityReport> {
  // Use basic pattern matching for vulnerability detection
  const basicFindings = await runBasicSecurityChecks(language)

  return {
    timestamp: new Date().toISOString(),
    language,
    tools: {
      sast: null,
      dependencyScanner: null,
      secretScanner: null
    },
    scores: {
      overall: calculateBasicScore(basicFindings),
      owasp: calculateBasicScore(basicFindings)
    },
    recommendations: [
      {
        priority: 'high',
        category: 'tooling',
        message: `Consider adding security tools for ${language}: ${getRecommendedSecurityTools(language).join(', ')}`
      }
    ],
    passFail: 'PASS'  // Pass with warning when no tools
  }
}

async function runBasicSecurityChecks(language: string): Promise<OWASPFinding[]> {
  // Language-agnostic basic checks
  const findings: OWASPFinding[] = []

  const codeFiles = await Glob({ pattern: getCodePattern(language) })

  for (const file of codeFiles) {
    const content = await Read(file)

    // SQL Injection
    if (content.match(/execute.*\+.*user|query.*\+.*req\./)) {
      findings.push({
        category: 'A03:2021-Injection',
        severity: 'high',
        title: 'Potential SQL Injection',
        description: 'String concatenation in SQL query detected',
        file,
        line: 0,
        cwe: 'CWE-89',
        recommendation: 'Use parameterized queries or ORM'
      })
    }

    // Hardcoded secrets
    if (content.match(/password.*=.*['"][^'"]{8,}['"]|api_key.*=.*['"][^'"]+['"]/i)) {
      findings.push({
        category: 'A02:2021-Cryptographic Failures',
        severity: 'critical',
        title: 'Hardcoded Secret Detected',
        description: 'Password or API key hardcoded in source',
        file,
        line: 0,
        cwe: 'CWE-798',
        recommendation: 'Use environment variables or secret management'
      })
    }

    // Weak cryptography
    if (content.match(/MD5|SHA1|DES/)) {
      findings.push({
        category: 'A02:2021-Cryptographic Failures',
        severity: 'medium',
        title: 'Weak Cryptographic Algorithm',
        description: 'Use of weak hash or encryption algorithm',
        file,
        line: 0,
        cwe: 'CWE-327',
        recommendation: 'Use SHA-256 or stronger'
      })
    }
  }

  return findings
}
```

### Case 2: Critical Vulnerabilities Found

```typescript
async function handleCriticalVulnerabilities(
  findings: SecurityFindings
): Promise<RecommendationAction> {
  const criticalFindings = [
    ...findings.owaspFindings.filter(f => f.severity === 'critical'),
    ...findings.dependencyVulnerabilities.filter(v => v.vulnerability.severity === 'critical'),
    ...findings.secretLeaks.filter(s => s.confidence > 80)
  ]

  if (criticalFindings.length > 0) {
    return {
      action: 'BLOCK_MERGE',
      reason: `${criticalFindings.length} critical vulnerabilities detected`,
      criticalIssues: criticalFindings,
      mustFix: true,
      autoFixAvailable: checkAutoFixAvailability(criticalFindings)
    }
  }

  return { action: 'ALLOW', mustFix: false }
}
```

### Case 3: False Positive Assessment

```typescript
interface SecurityFinding {
  // ... existing fields
  confidence: number  // 0-100
  falsePositiveIndicators: string[]
}

function assessFalsePositiveRisk(finding: SecurityFinding): number {
  let risk = 0

  // Low confidence = high false positive risk
  if (finding.confidence < 50) risk += 0.5
  else if (finding.confidence < 70) risk += 0.3

  // In test code = likely false positive
  if (finding.file.includes('test') || finding.file.includes('spec')) {
    risk += 0.4
  }

  // In comments
  if (finding.falsePositiveIndicators.includes('in_comment')) {
    risk += 0.6
  }

  return Math.min(risk, 1.0)  // 0-1 scale
}

function adjustScoreForFalsePositives(
  findings: SecurityFinding[],
  baseScore: number
): number {
  let adjustment = 0

  for (const finding of findings) {
    const fpRisk = assessFalsePositiveRisk(finding)

    // High FP risk = reduce penalty
    if (fpRisk > 0.7) {
      adjustment += 0.5  // Restore half of penalty
    }
  }

  return Math.min(baseScore + adjustment, 5.0)
}
```

---

## 📋 Configuration File Format

```yaml
# .claude/edaf-config.yml

security:
  # Language (auto-detected if not specified)
  language: typescript

  # SAST tool
  sast:
    tool: eslint-plugin-security
    config_file: .eslintrc.js
    enabled: true

  # Dependency scanner
  dependency_scanner:
    tool: npm-audit
    enabled: true
    auto_fix: true  # Auto-fix when possible

  # Secret scanner
  secret_scanner:
    tool: trufflehog
    enabled: true

  # Thresholds
  thresholds:
    overall_score: 4.0  # Strict for security
    critical: 0         # No critical allowed
    high: 2             # Max 2 high
    medium: 10          # Max 10 medium

  # OWASP Top 10 check
  owasp_check: true

  # Exclusions
  exclude:
    - '**/test/**'
    - '**/tests/**'
    - '**/node_modules/**'

  # Custom rules
  custom_rules:
    - id: no-eval
      severity: critical
      pattern: 'eval\('
      message: 'eval() usage is prohibited'
```

---

## 📊 Output Format

```json
{
  "evaluator": "code-security-evaluator-v1-self-adapting",
  "version": "2.0",
  "timestamp": "2025-11-09T10:30:00Z",
  "pr_number": 42,

  "environment": {
    "language": "typescript",
    "tools": {
      "sast": "eslint-plugin-security",
      "dependency_scanner": "npm-audit",
      "secret_scanner": "trufflehog"
    }
  },

  "scores": {
    "overall": 3.8,
    "breakdown": {
      "owasp": 4.0,
      "dependencies": 3.5,
      "secrets": 5.0,
      "auth": 3.5,
      "crypto": 4.0
    }
  },

  "findings": {
    "owasp": [
      {
        "category": "A03:2021-Injection",
        "severity": "high",
        "title": "Potential SQL Injection",
        "file": "src/services/user.ts",
        "line": 45,
        "cwe": "CWE-89",
        "recommendation": "Use parameterized queries"
      }
    ],
    "dependencies": [
      {
        "package": "express",
        "version": "4.17.1",
        "vulnerability": {
          "id": "CVE-2024-1234",
          "severity": "high",
          "cvss": 7.5
        },
        "fix_available": true,
        "fixed_version": "4.18.2"
      }
    ],
    "secrets": [],
    "summary": {
      "total": 3,
      "by_severity": {
        "critical": 0,
        "high": 2,
        "medium": 1,
        "low": 0
      }
    }
  },

  "recommendations": [
    {
      "priority": "critical",
      "category": "dependencies",
      "message": "1 high vulnerability: Update express 4.17.1 to v4.18.2",
      "actionable": true,
      "auto_fixable": true,
      "command": "npm install express@4.18.2"
    },
    {
      "priority": "high",
      "category": "owasp",
      "message": "Potential SQL Injection: Use parameterized queries",
      "file": "src/services/user.ts:45",
      "actionable": true,
      "auto_fixable": false
    }
  ],

  "result": {
    "status": "FAIL",
    "threshold": 4.0,
    "message": "Security score 3.8/5.0 is below threshold 4.0"
  }
}
```

---

## 🎓 Summary

### What This Evaluator Provides

✅ **Universal Language Support** - TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#
✅ **Automatic Tool Detection** - Finds ESLint security, Bandit, SpotBugs, gosec, etc.
✅ **OWASP Top 10 Detection** - Language-agnostic security vulnerability detection
✅ **Dependency Scanning** - CVE database matching
✅ **Secret Detection** - Hardcoded credentials detection
✅ **Normalized Scoring** - All languages scored on same 0-5 scale
✅ **Zero Configuration** - Works out of the box

### Key Innovation

**Before**: Separate security evaluators for each language
**After**: One evaluator that adapts to any language

**Maintenance**: Minimal
**Scalability**: Language/framework agnostic

---

**Status**: ✅ Production Ready
**Next**: Implement code-documentation-evaluator-v1-self-adapting.md
