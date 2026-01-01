# Code Documentation Evaluator v1 - Self-Adapting

**Version**: 2.0
**Model**: haiku
**Type**: Code Evaluator (Self-Adapting)
**Language Support**: Universal (TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#, Kotlin, Swift)
**Frameworks**: All
**Status**: Production Ready
**Recommended Model**: `haiku` (documentation presence is a simple existence check)

---

## 🎯 Overview

### What This Evaluator Does

This evaluator analyzes code documentation quality across all languages:

1. **Comment Coverage** - Percentage of functions/classes with documentation
2. **Comment Quality** - Descriptiveness, clarity, accuracy
3. **API Documentation** - Public API documentation completeness
4. **Inline Comments** - Explanation of complex logic
5. **README & Guides** - Project-level documentation

### Self-Adapting Features

✅ **Automatic Language Detection** - Detects language from project files
✅ **Documentation Style Detection** - JSDoc, docstrings, JavaDoc, etc.
✅ **Convention Learning** - Learns documentation patterns from existing code
✅ **Universal Scoring** - Normalizes all languages to 0-10 scale
✅ **Zero Configuration** - Works out of the box

---

## 🔍 Detection System

### Layer 1: Automatic Detection

```typescript
async function detectDocumentationStyle(): Promise<DocumentationStyle> {
  // Step 1: Detect language
  const language = await detectLanguage()

  // Step 2: Detect documentation convention
  const convention = await detectDocConvention(language)

  // Step 3: Find existing documented code
  const documentedFiles = await findDocumentedFiles(language)

  // Step 4: Learn documentation patterns
  const patterns = await learnDocPatterns(documentedFiles)

  return { language, convention, patterns }
}
```

### Layer 2: Configuration File (if needed)

```yaml
# .claude/edaf-config.yml
documentation:
  language: typescript
  style: jsdoc
  thresholds:
    public_api_coverage: 90
    overall_coverage: 70
    min_comment_length: 10
  require_examples: true
  require_param_docs: true
```

### Layer 3: User Questions (fallback)

If detection fails, ask user:
- What programming language?
- Which documentation style? (JSDoc, docstrings, JavaDoc, etc.)
- Coverage threshold? (default: 70%)

---

## 🛠️ Language-Specific Documentation Styles

### TypeScript/JavaScript

```typescript
const jsDocumentationStyles = {
  'jsdoc': {
    indicators: {
      pattern: /\/\*\*[\s\S]*?\*\//,
      tags: ['@param', '@returns', '@description', '@example']
    },
    format: {
      functionDoc: `
/**
 * Brief description of function
 *
 * @param {string} name - Parameter description
 * @param {number} age - Parameter description
 * @returns {User} Description of return value
 * @throws {Error} When validation fails
 * @example
 * const user = createUser('John', 30)
 */`,
      classDoc: `
/**
 * Brief description of class
 *
 * @class
 * @implements {Interface}
 */`,
      propertyDoc: `
/** Description of property */`
    },
    tools: ['typedoc', 'documentation.js', 'jsdoc']
  },

  'tsdoc': {
    indicators: {
      pattern: /\/\*\*[\s\S]*?\*\//,
      tags: ['@param', '@returns', '@remarks', '@example']
    },
    format: {
      functionDoc: `
/**
 * Brief description
 *
 * @param name - Parameter description
 * @returns Description of return value
 *
 * @remarks
 * Additional details about implementation
 *
 * @example
 * \`\`\`ts
 * const result = myFunction('test')
 * \`\`\`
 */`
    },
    tools: ['typedoc']
  }
}
```

**Detection Logic**:
```typescript
async function detectJSDocStyle(): Promise<JSDocStyle> {
  const tsFiles = await Glob({ pattern: '**/*.{ts,js}' })

  // Read sample files
  const sampleFiles = tsFiles.slice(0, 5)
  const contents = await Promise.all(sampleFiles.map(f => Read(f)))

  // Analyze documentation patterns
  let jsdocCount = 0
  let tsdocCount = 0

  for (const content of contents) {
    // Check for JSDoc
    if (content.match(/@param\s+\{.*?\}/)) jsdocCount++

    // Check for TSDoc (no type annotations in tags)
    if (content.match(/@param\s+\w+\s+-/)) tsdocCount++
  }

  const style = tsdocCount > jsdocCount ? 'tsdoc' : 'jsdoc'

  return {
    style,
    confidence: Math.max(jsdocCount, tsdocCount) / sampleFiles.length
  }
}
```

### Python

```typescript
const pythonDocumentationStyles = {
  'google': {
    indicators: {
      pattern: /"""[\s\S]*?"""|'''[\s\S]*?'''/,
      sections: ['Args:', 'Returns:', 'Raises:', 'Example:']
    },
    format: {
      functionDoc: `
def function_name(param1, param2):
    """Brief description of function.

    Longer description if needed.

    Args:
        param1 (str): Description of param1
        param2 (int): Description of param2

    Returns:
        bool: Description of return value

    Raises:
        ValueError: When validation fails

    Example:
        >>> result = function_name('test', 42)
        >>> print(result)
        True
    """`,
      classDoc: `
class ClassName:
    """Brief description of class.

    Longer description if needed.

    Attributes:
        attr1 (str): Description of attr1
        attr2 (int): Description of attr2
    """`,
      moduleDoc: `
"""Module-level docstring.

This module provides functionality for...

Example:
    >>> from mymodule import MyClass
    >>> obj = MyClass()
"""
`
    },
    tools: ['sphinx', 'pdoc']
  },

  'numpy': {
    indicators: {
      pattern: /"""[\s\S]*?"""/,
      sections: ['Parameters', 'Returns', 'Raises', 'Examples']
    },
    format: {
      functionDoc: `
def function_name(param1, param2):
    """
    Brief description.

    Longer description if needed.

    Parameters
    ----------
    param1 : str
        Description of param1
    param2 : int
        Description of param2

    Returns
    -------
    bool
        Description of return value

    Examples
    --------
    >>> result = function_name('test', 42)
    True
    """
`
    }
  },

  'sphinx': {
    indicators: {
      pattern: /"""[\s\S]*?"""/,
      tags: [':param', ':type', ':return', ':rtype', ':raises']
    },
    format: {
      functionDoc: `
def function_name(param1, param2):
    """
    Brief description.

    :param param1: Description of param1
    :type param1: str
    :param param2: Description of param2
    :type param2: int
    :return: Description of return value
    :rtype: bool
    :raises ValueError: When validation fails
    """
`
    }
  }
}
```

**Detection Logic**:
```typescript
async function detectPythonDocStyle(): Promise<PythonDocStyle> {
  const pyFiles = await Glob({ pattern: '**/*.py' })

  const sampleFiles = pyFiles.slice(0, 5)
  const contents = await Promise.all(sampleFiles.map(f => Read(f)))

  let googleCount = 0
  let numpyCount = 0
  let sphinxCount = 0

  for (const content of contents) {
    if (content.match(/Args:/)) googleCount++
    if (content.match(/Parameters\n\s+-{3,}/)) numpyCount++
    if (content.match(/:param/)) sphinxCount++
  }

  const maxCount = Math.max(googleCount, numpyCount, sphinxCount)
  const style =
    maxCount === googleCount ? 'google' :
    maxCount === numpyCount ? 'numpy' :
    'sphinx'

  return {
    style,
    confidence: maxCount / sampleFiles.length
  }
}
```

### Java

```typescript
const javaDocumentationStyles = {
  'javadoc': {
    indicators: {
      pattern: /\/\*\*[\s\S]*?\*\//,
      tags: ['@param', '@return', '@throws', '@see', '@since']
    },
    format: {
      methodDoc: `
/**
 * Brief description of method.
 *
 * <p>Longer description with HTML formatting if needed.</p>
 *
 * @param name the name parameter description
 * @param age the age parameter description
 * @return the created User object
 * @throws IllegalArgumentException if validation fails
 * @see User
 * @since 1.0
 */`,
      classDoc: `
/**
 * Brief description of class.
 *
 * <p>Detailed description of class purpose and usage.</p>
 *
 * @author Author Name
 * @version 1.0
 * @since 1.0
 */`,
      packageDoc: `
/**
 * Package description.
 *
 * <p>This package provides...</p>
 */
package com.example.myapp;
`
    },
    tools: ['javadoc']
  }
}
```

### Go

```typescript
const goDocumentationStyles = {
  'godoc': {
    indicators: {
      pattern: /\/\/ \w+/,
      convention: 'Comment starts with identifier name'
    },
    format: {
      functionDoc: `
// CreateUser creates a new user with the given name and age.
// It returns an error if validation fails.
//
// Example:
//   user, err := CreateUser("John", 30)
//   if err != nil {
//       log.Fatal(err)
//   }
func CreateUser(name string, age int) (*User, error) {`,
      typeDoc: `
// User represents a user in the system.
// It contains personal information and metadata.
type User struct {`,
      packageDoc: `
// Package users provides user management functionality.
//
// This package handles user creation, authentication, and profile management.
package users
`
    },
    tools: ['godoc', 'pkgsite']
  }
}
```

### Rust

```typescript
const rustDocumentationStyles = {
  'rustdoc': {
    indicators: {
      pattern: /\/\/\/|\/\*\*|\#\[doc/,
      markdown: true
    },
    format: {
      functionDoc: `
/// Creates a new user with the given name and age.
///
/// # Arguments
///
/// * \`name\` - The user's name
/// * \`age\` - The user's age
///
/// # Returns
///
/// Returns \`Ok(User)\` if successful, or \`Err\` if validation fails.
///
/// # Examples
///
/// \`\`\`
/// let user = create_user("John", 30)?;
/// assert_eq!(user.name, "John");
/// \`\`\`
///
/// # Panics
///
/// Panics if age is negative.
pub fn create_user(name: &str, age: i32) -> Result<User, Error> {`,
      structDoc: `
/// A user in the system.
///
/// Contains personal information and metadata.
pub struct User {`,
      moduleDoc: `
//! User management module.
//!
//! This module provides functionality for creating and managing users.
`
    },
    tools: ['rustdoc']
  }
}
```

### Ruby

```typescript
const rubyDocumentationStyles = {
  'rdoc': {
    indicators: {
      pattern: /#[^{]/,
      sections: ['Returns:', 'Raises:', 'Example:']
    },
    format: {
      methodDoc: `
# Creates a new user with the given name and age.
#
# ==== Parameters
#
# * +name+ - The user's name
# * +age+ - The user's age
#
# ==== Returns
#
# * User object
#
# ==== Raises
#
# * ArgumentError - If validation fails
#
# ==== Examples
#
#   user = create_user('John', 30)
#   puts user.name
def create_user(name, age)`,
      classDoc: `
# Represents a user in the system.
#
# Contains personal information and provides user management methods.
class User`
    },
    tools: ['rdoc']
  },

  'yard': {
    indicators: {
      pattern: /@param|@return|@raise/
    },
    format: {
      methodDoc: `
# Creates a new user with the given name and age.
#
# @param name [String] the user's name
# @param age [Integer] the user's age
# @return [User] the created user
# @raise [ArgumentError] if validation fails
# @example Create a new user
#   user = create_user('John', 30)
def create_user(name, age)`
    },
    tools: ['yard']
  }
}
```

### PHP

```typescript
const phpDocumentationStyles = {
  'phpdoc': {
    indicators: {
      pattern: /\/\*\*[\s\S]*?\*\//,
      tags: ['@param', '@return', '@throws', '@var']
    },
    format: {
      functionDoc: `
/**
 * Creates a new user with the given name and age.
 *
 * @param string $name The user's name
 * @param int $age The user's age
 * @return User The created user object
 * @throws InvalidArgumentException If validation fails
 *
 * @example
 * $user = createUser('John', 30);
 */`,
      classDoc: `
/**
 * Represents a user in the system.
 *
 * @package App\\Models
 * @author Author Name
 * @version 1.0.0
 */`,
      propertyDoc: `
/**
 * The user's name.
 *
 * @var string
 */`
    },
    tools: ['phpDocumentor', 'apigen']
  }
}
```

---

## 📊 Universal Documentation Metrics

### 1. Comment Coverage

```typescript
interface CommentCoverage {
  publicFunctions: {
    documented: number
    total: number
    percentage: number
  }
  publicClasses: {
    documented: number
    total: number
    percentage: number
  }
  privateFunctions: {
    documented: number
    total: number
    percentage: number
  }
  overall: {
    documented: number
    total: number
    percentage: number
  }
}
```

**Scoring Formula**:
```typescript
function calculateCoverageScore(coverage: CommentCoverage): number {
  // Public API is most important
  const publicWeight = 0.70
  const privateWeight = 0.30

  const publicScore = (
    coverage.publicFunctions.percentage * 0.6 +
    coverage.publicClasses.percentage * 0.4
  ) / 100

  const privateScore = coverage.privateFunctions.percentage / 100

  const score = (publicScore * publicWeight + privateScore * privateWeight) * 5.0

  return score
}
```

**Examples**:
- 100% public, 80% private = 4.7/10.0
- 80% public, 50% private = 4.1/10.0
- 50% public, 50% private = 3.0/10.0
- 90% public, 0% private = 3.15/10.0

### 2. Comment Quality

```typescript
interface CommentQuality {
  averageLength: number          // Characters per comment
  hasExamples: number            // % with examples
  hasParamDocs: number           // % with param documentation
  hasReturnDocs: number          // % with return documentation
  descriptiveness: number        // 0-1 (meaningful vs trivial)
  accuracy: number               // 0-1 (matches implementation)
}
```

**Scoring Formula**:
```typescript
function calculateQualityScore(quality: CommentQuality): number {
  let score = 5.0

  // Deduct for short comments (< 20 chars = trivial)
  if (quality.averageLength < 20) {
    score -= 1.0
  } else if (quality.averageLength < 40) {
    score -= 0.5
  }

  // Deduct for missing examples
  if (quality.hasExamples < 0.3) {
    score -= 1.0
  } else if (quality.hasExamples < 0.5) {
    score -= 0.5
  }

  // Deduct for missing param/return docs
  if (quality.hasParamDocs < 0.8) {
    score -= 0.5
  }
  if (quality.hasReturnDocs < 0.8) {
    score -= 0.5
  }

  // Deduct for poor descriptiveness
  score -= (1 - quality.descriptiveness) * 1.0

  return Math.max(score, 0)
}
```

**Descriptiveness Detection**:
```typescript
function assessDescriptiveness(comment: string, functionName: string): number {
  // Trivial comments (just restate the function name)
  const trivialPatterns = [
    new RegExp(`^${functionName}`, 'i'),  // "getUserName gets the user name"
    /^(gets?|sets?|returns?|creates?)\s+\w+$/i,  // "Gets user"
    /^(this function|this method)/i  // "This function does..."
  ]

  for (const pattern of trivialPatterns) {
    if (comment.match(pattern)) {
      return 0.2  // Trivial
    }
  }

  // Good comments explain WHY, not just WHAT
  const goodIndicators = [
    /because|since|to ensure|in order to/i,
    /note that|important:|warning:/i,
    /example:/i,
    /\b(strategy|algorithm|approach|implementation)\b/i
  ]

  let score = 0.5  // Default: adequate

  for (const indicator of goodIndicators) {
    if (comment.match(indicator)) {
      score += 0.1
    }
  }

  return Math.min(score, 1.0)
}
```

### 3. API Documentation Completeness

```typescript
interface APIDocumentation {
  endpoints: {
    documented: number
    total: number
  }
  requestParams: {
    documented: number
    total: number
  }
  responseFormats: {
    documented: number
    total: number
  }
  errorCodes: {
    documented: number
    total: number
  }
}
```

**Scoring Formula**:
```typescript
function calculateAPIDocScore(apiDoc: APIDocumentation): number {
  const weights = {
    endpoints: 0.30,
    requestParams: 0.25,
    responseFormats: 0.25,
    errorCodes: 0.20
  }

  const score = (
    (apiDoc.endpoints.documented / apiDoc.endpoints.total) * weights.endpoints +
    (apiDoc.requestParams.documented / apiDoc.requestParams.total) * weights.requestParams +
    (apiDoc.responseFormats.documented / apiDoc.responseFormats.total) * weights.responseFormats +
    (apiDoc.errorCodes.documented / apiDoc.errorCodes.total) * weights.errorCodes
  ) * 5.0

  return score
}
```

### 4. README & Project Documentation

```typescript
interface ProjectDocumentation {
  hasReadme: boolean
  readmeQuality: number        // 0-1
  hasInstallInstructions: boolean
  hasUsageExamples: boolean
  hasAPIReference: boolean
  hasContributingGuide: boolean
  hasChangelog: boolean
}
```

**Scoring Formula**:
```typescript
function calculateProjectDocScore(projDoc: ProjectDocumentation): number {
  if (!projDoc.hasReadme) return 0

  let score = 2.0  // Base score for having README

  // Quality of README
  score += projDoc.readmeQuality * 1.5

  // Essential sections
  if (projDoc.hasInstallInstructions) score += 0.5
  if (projDoc.hasUsageExamples) score += 0.5
  if (projDoc.hasAPIReference) score += 0.3
  if (projDoc.hasContributingGuide) score += 0.1
  if (projDoc.hasChangelog) score += 0.1

  return Math.min(score, 5.0)
}
```

**README Quality Assessment**:
```typescript
function assessReadmeQuality(readme: string): number {
  let score = 0

  const sections = {
    title: /^#\s+.+/m,
    description: /##\s+(Description|About)/i,
    installation: /##\s+(Installation|Install|Getting Started)/i,
    usage: /##\s+(Usage|Quick Start|Examples)/i,
    api: /##\s+(API|Reference|Documentation)/i,
    contributing: /##\s+Contributing/i,
    license: /##\s+License/i
  }

  // Check for each section
  for (const [name, pattern] of Object.entries(sections)) {
    if (readme.match(pattern)) {
      score += 0.1
    }
  }

  // Check for code examples
  if (readme.match(/```/)) {
    score += 0.2
  }

  // Check for badges (indicates mature project)
  if (readme.match(/!\[.*?\]\(https:\/\/(shields\.io|img\.shields\.io)/)) {
    score += 0.1
  }

  return Math.min(score, 1.0)
}
```

### 5. Inline Comments

```typescript
interface InlineComments {
  complexFunctions: {
    commented: number      // Complex functions with inline comments
    total: number          // Total complex functions
  }
  averageCommentsPerFunction: number
  explainWhyNotWhat: number  // 0-1 (comments explain WHY)
}
```

**Scoring Formula**:
```typescript
function calculateInlineCommentScore(inline: InlineComments): number {
  // Complex functions SHOULD have inline comments
  const coverageScore = (inline.complexFunctions.commented / inline.complexFunctions.total) * 3.0

  // Quality of comments (explain WHY)
  const qualityScore = inline.explainWhyNotWhat * 2.0

  return Math.min(coverageScore + qualityScore, 5.0)
}
```

**Complex Function Detection**:
```typescript
function isComplexFunction(functionCode: string): boolean {
  // Cyclomatic complexity > 10
  const cyclomaticComplexity = calculateComplexity(functionCode)
  if (cyclomaticComplexity > 10) return true

  // Long functions (> 50 lines)
  const lineCount = functionCode.split('\n').length
  if (lineCount > 50) return true

  // Nested loops/conditions
  const nestingLevel = calculateMaxNesting(functionCode)
  if (nestingLevel > 3) return true

  return false
}
```

---

## 🎯 Evaluation Process

### Step 1: Detect Documentation Style

```typescript
async function detectDocumentationStyle(): Promise<DocStyle> {
  const language = await detectLanguage()

  const styleDetectors = {
    typescript: detectJSDocStyle,
    javascript: detectJSDocStyle,
    python: detectPythonDocStyle,
    java: () => ({ style: 'javadoc', confidence: 1.0 }),
    go: () => ({ style: 'godoc', confidence: 1.0 }),
    rust: () => ({ style: 'rustdoc', confidence: 1.0 }),
    ruby: detectRubyDocStyle,
    php: () => ({ style: 'phpdoc', confidence: 1.0 })
  }

  const detector = styleDetectors[language]
  return await detector()
}
```

### Step 2: Analyze Comment Coverage

```typescript
async function analyzeCommentCoverage(files: string[], language: string): Promise<CommentCoverage> {
  const coverage = {
    publicFunctions: { documented: 0, total: 0, percentage: 0 },
    publicClasses: { documented: 0, total: 0, percentage: 0 },
    privateFunctions: { documented: 0, total: 0, percentage: 0 },
    overall: { documented: 0, total: 0, percentage: 0 }
  }

  for (const file of files) {
    const content = await Read(file)
    const functions = extractFunctions(content, language)
    const classes = extractClasses(content, language)

    // Analyze functions
    for (const func of functions) {
      const isPublic = isPublicFunction(func, language)
      const isDocumented = hasDocumentation(func, language)

      if (isPublic) {
        coverage.publicFunctions.total++
        if (isDocumented) coverage.publicFunctions.documented++
      } else {
        coverage.privateFunctions.total++
        if (isDocumented) coverage.privateFunctions.documented++
      }
    }

    // Analyze classes
    for (const cls of classes) {
      const isPublic = isPublicClass(cls, language)
      const isDocumented = hasDocumentation(cls, language)

      if (isPublic) {
        coverage.publicClasses.total++
        if (isDocumented) coverage.publicClasses.documented++
      }
    }
  }

  // Calculate percentages
  coverage.publicFunctions.percentage =
    (coverage.publicFunctions.documented / coverage.publicFunctions.total) * 100 || 0
  coverage.publicClasses.percentage =
    (coverage.publicClasses.documented / coverage.publicClasses.total) * 100 || 0
  coverage.privateFunctions.percentage =
    (coverage.privateFunctions.documented / coverage.privateFunctions.total) * 100 || 0

  coverage.overall.total =
    coverage.publicFunctions.total + coverage.publicClasses.total + coverage.privateFunctions.total
  coverage.overall.documented =
    coverage.publicFunctions.documented + coverage.publicClasses.documented + coverage.privateFunctions.documented
  coverage.overall.percentage =
    (coverage.overall.documented / coverage.overall.total) * 100 || 0

  return coverage
}
```

### Step 3: Analyze Comment Quality

```typescript
async function analyzeCommentQuality(files: string[], language: string): Promise<CommentQuality> {
  const comments = []
  let totalLength = 0
  let hasExamplesCount = 0
  let hasParamDocsCount = 0
  let hasReturnDocsCount = 0
  let totalDescriptiveness = 0

  for (const file of files) {
    const content = await Read(file)
    const docComments = extractDocComments(content, language)

    for (const comment of docComments) {
      comments.push(comment)
      totalLength += comment.text.length

      // Check for examples
      if (hasExample(comment.text, language)) {
        hasExamplesCount++
      }

      // Check for param documentation
      if (hasParamDocumentation(comment.text, language)) {
        hasParamDocsCount++
      }

      // Check for return documentation
      if (hasReturnDocumentation(comment.text, language)) {
        hasReturnDocsCount++
      }

      // Assess descriptiveness
      totalDescriptiveness += assessDescriptiveness(comment.text, comment.functionName)
    }
  }

  const commentCount = comments.length

  return {
    averageLength: totalLength / commentCount || 0,
    hasExamples: hasExamplesCount / commentCount || 0,
    hasParamDocs: hasParamDocsCount / commentCount || 0,
    hasReturnDocs: hasReturnDocsCount / commentCount || 0,
    descriptiveness: totalDescriptiveness / commentCount || 0,
    accuracy: 1.0  // Assume accurate (hard to auto-detect)
  }
}
```

### Step 4: Calculate Scores

```typescript
async function calculateDocumentationScore(
  coverage: CommentCoverage,
  quality: CommentQuality,
  apiDoc: APIDocumentation,
  projectDoc: ProjectDocumentation,
  inline: InlineComments
): Promise<EvaluationResult> {
  const scores = {
    coverage: calculateCoverageScore(coverage),
    quality: calculateQualityScore(quality),
    apiDoc: calculateAPIDocScore(apiDoc),
    projectDoc: calculateProjectDocScore(projectDoc),
    inline: calculateInlineCommentScore(inline)
  }

  // Weighted average (coverage and quality most important)
  const weights = {
    coverage: 0.35,
    quality: 0.30,
    apiDoc: 0.15,
    projectDoc: 0.10,
    inline: 0.10
  }

  const overallScore = calculateWeightedAverage(scores, weights)

  return {
    overallScore,
    breakdown: scores,
    metrics: { coverage, quality, apiDoc, projectDoc, inline },
    recommendations: generateDocRecommendations(scores, coverage, quality)
  }
}
```

---

## 🔧 Implementation Examples

### TypeScript/JSDoc Project

```typescript
async function evaluateTypeScriptDocumentation(changedFiles: string[]): Promise<DocumentationReport> {
  // Detect JSDoc style
  const docStyle = await detectJSDocStyle()

  // Analyze coverage
  const coverage = await analyzeCommentCoverage(changedFiles, 'typescript')

  // Analyze quality
  const quality = await analyzeCommentQuality(changedFiles, 'typescript')

  // Check README
  const hasReadme = await fileExists('README.md')
  const readmeContent = hasReadme ? await Read('README.md') : ''
  const readmeQuality = assessReadmeQuality(readmeContent)

  const projectDoc = {
    hasReadme,
    readmeQuality,
    hasInstallInstructions: readmeContent.match(/##\s+(Installation|Install)/i) !== null,
    hasUsageExamples: readmeContent.match(/##\s+Usage/i) !== null,
    hasAPIReference: readmeContent.match(/##\s+API/i) !== null,
    hasContributingGuide: await fileExists('CONTRIBUTING.md'),
    hasChangelog: await fileExists('CHANGELOG.md')
  }

  // Calculate scores
  const scores = {
    coverage: calculateCoverageScore(coverage),
    quality: calculateQualityScore(quality),
    projectDoc: calculateProjectDocScore(projectDoc)
  }

  const overallScore = (
    scores.coverage * 0.50 +
    scores.quality * 0.35 +
    scores.projectDoc * 0.15
  )

  return {
    timestamp: new Date().toISOString(),
    language: 'typescript',
    style: docStyle.style,
    scores: {
      overall: overallScore,
      coverage: scores.coverage,
      quality: scores.quality,
      projectDoc: scores.projectDoc
    },
    metrics: { coverage, quality, projectDoc },
    passFail: overallScore >= 3.5 ? 'PASS' : 'FAIL',
    threshold: 3.5
  }
}
```

### Python/Docstrings Project

```typescript
async function evaluatePythonDocumentation(changedFiles: string[]): Promise<DocumentationReport> {
  // Detect docstring style
  const docStyle = await detectPythonDocStyle()

  // Analyze coverage
  const coverage = await analyzeCommentCoverage(changedFiles, 'python')

  // Analyze quality
  const quality = await analyzeCommentQuality(changedFiles, 'python')

  // Calculate scores
  return calculateDocumentationScore(coverage, quality, ...)
}
```

---

## 📐 Score Normalization

### Language-Specific Comment Extraction

```typescript
const commentExtractors = {
  typescript: {
    docComment: /\/\*\*[\s\S]*?\*\//g,
    inlineComment: /\/\/.*$/gm,
    blockComment: /\/\*[\s\S]*?\*\//g
  },
  python: {
    docComment: /"""[\s\S]*?"""|'''[\s\S]*?'''/g,
    inlineComment: /#.*$/gm
  },
  java: {
    docComment: /\/\*\*[\s\S]*?\*\//g,
    inlineComment: /\/\/.*$/gm,
    blockComment: /\/\*[\s\S]*?\*\//g
  },
  go: {
    docComment: /\/\/ \w+[\s\S]*?(?=\nfunc|\ntype|\nconst|\nvar|$)/g,
    inlineComment: /\/\/.*$/gm
  },
  rust: {
    docComment: /\/\/\/.*$|\/\*\*[\s\S]*?\*\/|\#\[doc.*?\]/gm,
    inlineComment: /\/\/.*$/gm
  }
}

function extractDocComments(content: string, language: string): DocComment[] {
  const extractor = commentExtractors[language]
  if (!extractor) return []

  const docCommentMatches = content.matchAll(extractor.docComment)
  const comments = []

  for (const match of docCommentMatches) {
    comments.push({
      text: match[0],
      position: match.index,
      functionName: extractAssociatedFunctionName(content, match.index)
    })
  }

  return comments
}
```

---

## ⚠️ Edge Cases and Error Handling

### Case 1: No Documentation Found

```typescript
async function handleNoDocumentation(): Promise<DocumentationReport> {
  return {
    timestamp: new Date().toISOString(),
    language: 'unknown',
    style: null,
    scores: {
      overall: 0,
      coverage: 0,
      quality: 0
    },
    recommendations: [
      {
        priority: 'critical',
        category: 'documentation',
        message: 'No documentation found. Add JSDoc/docstrings to public APIs.',
        actionable: true
      }
    ],
    passFail: 'FAIL',
    threshold: 3.5
  }
}
```

### Case 2: Mixed Documentation Styles

```typescript
async function handleMixedStyles(styles: string[]): Promise<string> {
  // Use majority style
  const styleCounts = {}
  for (const style of styles) {
    styleCounts[style] = (styleCounts[style] || 0) + 1
  }

  const dominantStyle = Object.keys(styleCounts)
    .sort((a, b) => styleCounts[b] - styleCounts[a])[0]

  return dominantStyle
}
```

### Case 3: Auto-Generated Documentation

```typescript
function isAutoGenerated(comment: string): boolean {
  const autoGenIndicators = [
    /Generated by/i,
    /Auto-generated/i,
    /DO NOT EDIT/i,
    /\@generated/,
    /Code generated by/i
  ]

  return autoGenIndicators.some(pattern => comment.match(pattern))
}

function filterAutoGeneratedComments(comments: DocComment[]): DocComment[] {
  return comments.filter(c => !isAutoGenerated(c.text))
}
```

---

## 📋 Configuration File Format

```yaml
# .claude/edaf-config.yml

documentation:
  # Language (auto-detected if not specified)
  language: typescript

  # Documentation style
  style: jsdoc

  # Coverage thresholds
  thresholds:
    public_api_coverage: 90
    overall_coverage: 70
    min_comment_length: 20

  # Requirements
  require_examples: true
  require_param_docs: true
  require_return_docs: true

  # Exclusions
  exclude:
    - '**/test/**'
    - '**/tests/**'
    - '**/node_modules/**'
    - '**/*.generated.*'
```

---

## 📊 Output Format

```json
{
  "evaluator": "code-documentation-evaluator-v1-self-adapting",
  "version": "2.0",
  "timestamp": "2025-11-09T10:30:00Z",
  "pr_number": 42,

  "environment": {
    "language": "typescript",
    "style": "jsdoc"
  },

  "scores": {
    "overall": 4.2,
    "breakdown": {
      "coverage": 4.5,
      "quality": 4.0,
      "apiDoc": 4.3,
      "projectDoc": 4.0,
      "inline": 3.8
    }
  },

  "metrics": {
    "coverage": {
      "publicFunctions": { "documented": 45, "total": 50, "percentage": 90 },
      "publicClasses": { "documented": 9, "total": 10, "percentage": 90 },
      "privateFunctions": { "documented": 30, "total": 50, "percentage": 60 },
      "overall": { "documented": 84, "total": 110, "percentage": 76.4 }
    },
    "quality": {
      "averageLength": 120,
      "hasExamples": 0.6,
      "hasParamDocs": 0.9,
      "hasReturnDocs": 0.85,
      "descriptiveness": 0.75
    },
    "projectDoc": {
      "hasReadme": true,
      "readmeQuality": 0.8,
      "hasInstallInstructions": true,
      "hasUsageExamples": true,
      "hasAPIReference": true
    }
  },

  "recommendations": [
    {
      "priority": "medium",
      "category": "coverage",
      "message": "5 public functions are missing documentation",
      "files": ["src/utils/helper.ts:calculateTotal", "src/services/order.ts:validateOrder"],
      "actionable": true
    },
    {
      "priority": "low",
      "category": "quality",
      "message": "40% of functions lack examples. Consider adding usage examples.",
      "actionable": true
    }
  ],

  "result": {
    "status": "PASS",
    "threshold": 3.5,
    "message": "Documentation meets standards (4.2/10.0 ≥ 3.5)"
  }
}
```

---

## 🎓 Summary

### What This Evaluator Provides

✅ **Universal Language Support** - TypeScript, Python, Java, Go, Rust, Ruby, PHP, C#
✅ **Auto Style Detection** - JSDoc, docstrings, JavaDoc, GoDoc, RustDoc, etc.
✅ **Coverage Analysis** - Public API vs private function documentation
✅ **Quality Assessment** - Meaningful vs trivial comments
✅ **Project Documentation** - README, guides, API references
✅ **Normalized Scoring** - All languages scored on same 0-10 scale
✅ **Zero Configuration** - Works out of the box

### Key Innovation

**Before**: Separate documentation evaluators for each language
**After**: One evaluator that adapts to any language/style

**Maintenance**: Minimal
**Scalability**: Language/framework agnostic

---

**Status**: ✅ Production Ready
**Next**: Implement code-maintainability-evaluator-v1-self-adapting.md
