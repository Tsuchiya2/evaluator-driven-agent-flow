# EDAF Common Issue Patterns

## Critical Issues (Immediate Fix Required)

### Security
- **SQL Injection**: Raw query strings with user input
- **XSS Vulnerabilities**: Unescaped user content in HTML
- **Hardcoded Secrets**: API keys, passwords in source code
- **Authentication Bypass**: Missing auth checks on protected routes
- **Insecure Deserialization**: Unsafe object parsing

### Reliability
- **Unhandled Exceptions**: Missing try-catch in async operations
- **Race Conditions**: Concurrent data access without locks
- **Memory Leaks**: Unreleased resources, circular references
- **Infinite Loops**: Missing break conditions

## High Severity Issues

### Code Quality
- **God Objects**: Classes with too many responsibilities
- **Deep Nesting**: >4 levels of indentation
- **Long Methods**: >50 lines per function
- **Magic Numbers**: Unexplained numeric literals
- **Duplicate Code**: >10 lines of identical logic

### Performance
- **N+1 Queries**: Database calls inside loops
- **Synchronous I/O**: Blocking operations in async context
- **Missing Indexes**: Queries on unindexed columns
- **Large Payloads**: Unbounded data fetching

### Testing
- **No Unit Tests**: Business logic without test coverage
- **Flaky Tests**: Tests that randomly fail
- **Missing Edge Cases**: No boundary condition tests

## Medium Severity Issues

### Maintainability
- **Poor Naming**: Unclear variable/function names
- **Missing Types**: Any types in TypeScript
- **Complex Conditionals**: >3 conditions in if statements
- **Tight Coupling**: Direct dependencies between modules

### Documentation
- **Missing API Docs**: Public methods without documentation
- **Outdated Comments**: Comments that don't match code
- **No README**: Missing setup/usage instructions

### Design
- **Inconsistent Patterns**: Mixed architectural styles
- **Over-Engineering**: Unnecessary abstractions
- **Under-Specified**: Vague requirements

## Low Severity Issues

### Style
- **Inconsistent Formatting**: Mixed indentation/spacing
- **Long Lines**: >120 characters
- **Unused Imports**: Dead code imports
- **TODO Comments**: Unresolved technical debt markers

### Best Practices
- **Console Logs**: Debug statements in production code
- **Commented Code**: Dead code blocks
- **Missing Error Messages**: Generic error responses

## Detection Patterns by Language

### TypeScript/JavaScript
```typescript
// N+1 Query Pattern
users.forEach(async (user) => {
  const orders = await db.orders.findByUserId(user.id); // ❌
});

// Better: Batch query
const orders = await db.orders.findByUserIds(userIds); // ✅
```

### Python
```python
# SQL Injection Pattern
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")  # ❌

# Better: Parameterized query
cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))  # ✅
```

### Go
```go
// Resource Leak Pattern
file, _ := os.Open("data.txt")  // ❌ Error ignored, no defer close

// Better: Handle error and defer close
file, err := os.Open("data.txt")
if err != nil {
    return err
}
defer file.Close()  // ✅
```

## Quick Reference Checklist

### Before Approval (Must Pass)
- [ ] No critical security vulnerabilities
- [ ] All async operations have error handling
- [ ] No hardcoded secrets
- [ ] Test coverage ≥80%
- [ ] No N+1 query patterns
- [ ] API documentation complete

### Recommended (Nice to Have)
- [ ] No code duplication
- [ ] Cyclomatic complexity <10
- [ ] All public methods documented
- [ ] Performance benchmarks pass
- [ ] Zero linting warnings
