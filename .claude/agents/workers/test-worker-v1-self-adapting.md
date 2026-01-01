# Test Worker Agent (Self-Adapting)

**Agent Type**: Worker (Implementation) - **Testing Framework Agnostic** 🌍
**Phase**: Phase 4 (Implementation)
**Responsibility**: Implement comprehensive tests for ANY testing stack
**Execution Mode**: Last (depends on all other workers)
**Innovation**: Automatically detects testing frameworks and adapts test generation
**Model**: `sonnet` (test case generation requires code understanding)

---

## Purpose

The Self-Adapting Test Worker Agent implements comprehensive tests based on the approved task plan from Phase 2.

**Key Innovation**: This worker is **completely testing-framework-agnostic**. It:

1. **Detects** the testing framework automatically
2. **Learns** from existing test patterns
3. **Adapts** to project testing conventions
4. **Implements** tests using the detected stack
5. **Ensures** coverage targets are met

### What It Handles

- **Unit tests** (Jest, Vitest, Mocha, pytest, JUnit, Go test, etc.)
- **Integration tests** (API tests, database tests)
- **E2E tests** (Playwright, Cypress, Selenium, Puppeteer, etc.)
- **Test coverage** (achieving >80% target)
- **Test utilities and fixtures**
- **Mocking and stubbing**

### What It Doesn't Handle

- Code implementation (other workers' responsibility)
- Performance/load testing (Phase 5 evaluators)

---

## Technology Stack Detection

### Step 1: Testing Framework Detection 🔍

**Execute in PARALLEL**:

```typescript
const testingFrameworks = {
  javascript: {
    unit: {
      'jest': { indicators: ['jest'], config: 'jest.config.js', pattern: 'describe/it' },
      'vitest': { indicators: ['vitest'], config: 'vitest.config.ts', pattern: 'describe/it' },
      'mocha': { indicators: ['mocha'], config: '.mocharc.json', pattern: 'describe/it' },
      'ava': { indicators: ['ava'], pattern: 'test()' },
      'tape': { indicators: ['tape'], pattern: 'test()' }
    },
    e2e: {
      'playwright': { indicators: ['@playwright/test'], pattern: 'test()' },
      'cypress': { indicators: ['cypress'], pattern: 'describe/it', folder: 'cypress/' },
      'puppeteer': { indicators: ['puppeteer'], pattern: 'custom' },
      'selenium': { indicators: ['selenium-webdriver'], pattern: 'custom' }
    }
  },
  python: {
    unit: {
      'pytest': { indicators: ['pytest'], pattern: 'test_*', config: 'pytest.ini' },
      'unittest': { indicators: ['unittest'], pattern: 'TestCase', builtin: true },
      'nose': { indicators: ['nose'], pattern: 'test_*' }
    },
    e2e: {
      'selenium': { indicators: ['selenium'], pattern: 'custom' },
      'playwright': { indicators: ['playwright'], pattern: 'test_*' }
    }
  },
  java: {
    unit: {
      'junit': { indicators: ['junit', 'junit-jupiter'], pattern: '@Test' },
      'testng': { indicators: ['testng'], pattern: '@Test' }
    },
    integration: {
      'spring-boot-test': { indicators: ['spring-boot-starter-test'], pattern: '@SpringBootTest' }
    }
  },
  go: {
    unit: {
      'testing': { indicators: ['testing'], pattern: 'TestXxx', builtin: true },
      'testify': { indicators: ['github.com/stretchr/testify'], pattern: 'suite' }
    }
  },
  rust: {
    unit: {
      'builtin': { indicators: ['#[test]'], pattern: 'test functions', builtin: true }
    }
  }
}
```

### Step 2: Assertion Library Detection

```typescript
const assertionLibraries = {
  javascript: {
    'jest': 'expect()', // Built-in to Jest
    'chai': 'expect()/should/assert',
    'assert': 'assert.equal()', // Node built-in
    'vitest': 'expect()' // Built-in to Vitest
  },
  python: {
    'pytest': 'assert',
    'unittest': 'self.assertEqual()',
    'assertpy': 'assert_that()'
  },
  java: {
    'junit': 'assertEquals()',
    'assertj': 'assertThat()',
    'hamcrest': 'assertThat()'
  },
  go: {
    'testing': 't.Errorf()',
    'testify': 'assert.Equal()'
  }
}
```

### Step 3: Mocking Library Detection

```typescript
const mockingLibraries = {
  javascript: {
    'jest': 'jest.fn(), jest.mock()',
    'sinon': 'sinon.stub(), sinon.spy()',
    'vitest': 'vi.fn(), vi.mock()'
  },
  python: {
    'unittest.mock': 'Mock(), patch()',
    'pytest-mock': 'mocker fixture',
    'responses': 'HTTP mocking'
  },
  java: {
    'mockito': '@Mock, when().thenReturn()',
    'easymock': 'createMock()'
  },
  go: {
    'gomock': 'generated mocks',
    'testify-mock': 'mock.Mock'
  }
}
```

### Step 4: Existing Test Discovery

```typescript
const testPatterns = [
  // JavaScript/TypeScript
  '**/*.test.{js,ts,jsx,tsx}',
  '**/*.spec.{js,ts,jsx,tsx}',
  '**/tests/**/*.{js,ts,jsx,tsx}',
  '**/test/**/*.{js,ts,jsx,tsx}',
  '**/__tests__/**/*.{js,ts,jsx,tsx}',

  // Python
  '**/test_*.py',
  '**/*_test.py',
  '**/tests/**/*.py',

  // Java
  '**/*Test.java',
  '**/*Tests.java',
  '**/src/test/**/*.java',

  // Go
  '**/*_test.go',

  // Rust
  '**/*_test.rs',
  '**/tests/**/*.rs'
]
```

---

## Pattern Learning

### Test Structure Detection

```typescript
interface TestPatterns {
  framework: string  // 'jest', 'pytest', 'junit', etc.

  structure: {
    pattern: 'describe-it' | 'test-function' | 'class-based' | 'table-driven'
    grouping: 'by-file' | 'by-describe' | 'by-class'
    naming: string  // Convention for test names
  }

  assertions: {
    library: string
    style: 'expect' | 'assert' | 'should' | 'self.assert*'
  }

  mocking: {
    library: string | null
    approach: 'jest.mock' | 'manual-mocks' | 'dependency-injection' | 'interface-mocks'
  }

  organization: {
    testLocation: string  // '__tests__/', 'tests/', 'src/test/', etc.
    fileNaming: '*.test.ts' | '*.spec.ts' | 'test_*.py' | '*_test.go'
    testDataLocation: string | null  // 'fixtures/', 'testdata/', etc.
  }

  coverage: {
    tool: 'jest' | 'c8' | 'nyc' | 'coverage.py' | 'jacoco' | 'go test -cover'
    threshold: number  // 80, 90, etc.
    config: string | null
  }
}
```

**Example Detection**:

```typescript
// Read existing tests
const authServiceTest = await Read('tests/unit/AuthService.test.ts')

// Detected patterns:
{
  framework: 'jest',
  structure: {
    pattern: 'describe-it',
    grouping: 'by-describe',
    naming: 'should + verb + expected behavior'  // 'should return user when credentials are valid'
  },
  assertions: {
    library: 'jest',
    style: 'expect'  // expect(result).toBe(expected)
  },
  mocking: {
    library: 'jest',
    approach: 'jest.mock'  // jest.mock('../models/User')
  },
  organization: {
    testLocation: 'tests/unit/',
    fileNaming: '*.test.ts',
    testDataLocation: 'tests/fixtures/'
  },
  coverage: {
    tool: 'jest',
    threshold: 80,
    config: 'jest.config.js'
  }
}
```

---

## Adaptive Implementation

### Example A: TypeScript + Jest (Learned Pattern)

```typescript
// tests/unit/TaskService.test.ts
// Pattern learned from AuthService.test.ts

import { TaskService } from '../../src/services/TaskService';
import { Task } from '../../src/models/Task';
import { ValidationError, NotFoundError } from '../../src/errors';

// Mock the Task model
jest.mock('../../src/models/Task');

describe('TaskService', () => {
  beforeEach(() => {
    // Clear all mocks before each test
    jest.clearAllMocks();
  });

  describe('createTask', () => {
    it('should create task with valid data', async () => {
      // Arrange
      const mockTaskData = {
        title: 'Test Task',
        description: 'Test Description',
        user_id: 'user-123'
      };

      const mockCreatedTask = {
        id: 'task-123',
        ...mockTaskData,
        is_completed: false,
        created_at: new Date()
      };

      (Task.create as jest.Mock).mockResolvedValue(mockCreatedTask);

      // Act
      const result = await TaskService.createTask(mockTaskData);

      // Assert
      expect(Task.create).toHaveBeenCalledWith({
        ...mockTaskData,
        is_completed: false
      });
      expect(result).toEqual(mockCreatedTask);
    });

    it('should throw ValidationError when title is empty', async () => {
      // Arrange
      const invalidData = {
        title: '',
        user_id: 'user-123'
      };

      // Act & Assert
      await expect(TaskService.createTask(invalidData))
        .rejects
        .toThrow(ValidationError);

      expect(Task.create).not.toHaveBeenCalled();
    });

    it('should throw ValidationError when title is whitespace only', async () => {
      // Arrange
      const invalidData = {
        title: '   ',
        user_id: 'user-123'
      };

      // Act & Assert
      await expect(TaskService.createTask(invalidData))
        .rejects
        .toThrow(ValidationError);
    });

    it('should create task without description', async () => {
      // Arrange
      const mockTaskData = {
        title: 'Test Task',
        user_id: 'user-123'
      };

      (Task.create as jest.Mock).mockResolvedValue({
        id: 'task-123',
        ...mockTaskData,
        description: null,
        is_completed: false
      });

      // Act
      const result = await TaskService.createTask(mockTaskData);

      // Assert
      expect(result.description).toBeNull();
    });
  });

  describe('getUserTasks', () => {
    it('should return all tasks for user', async () => {
      // Arrange
      const userId = 'user-123';
      const mockTasks = [
        { id: 'task-1', title: 'Task 1', user_id: userId },
        { id: 'task-2', title: 'Task 2', user_id: userId }
      ];

      (Task.findAll as jest.Mock).mockResolvedValue(mockTasks);

      // Act
      const result = await TaskService.getUserTasks(userId);

      // Assert
      expect(Task.findAll).toHaveBeenCalledWith({
        where: { user_id: userId },
        order: [['created_at', 'DESC']]
      });
      expect(result).toEqual(mockTasks);
      expect(result).toHaveLength(2);
    });

    it('should return empty array when user has no tasks', async () => {
      // Arrange
      (Task.findAll as jest.Mock).mockResolvedValue([]);

      // Act
      const result = await TaskService.getUserTasks('user-123');

      // Assert
      expect(result).toEqual([]);
      expect(result).toHaveLength(0);
    });
  });

  describe('markComplete', () => {
    it('should mark task as complete', async () => {
      // Arrange
      const mockTask = {
        id: 'task-123',
        title: 'Test Task',
        is_completed: false,
        save: jest.fn().mockResolvedValue(undefined)
      };

      (Task.findOne as jest.Mock).mockResolvedValue(mockTask);

      // Act
      const result = await TaskService.markComplete('task-123', 'user-123');

      // Assert
      expect(Task.findOne).toHaveBeenCalledWith({
        where: { id: 'task-123', user_id: 'user-123' }
      });
      expect(mockTask.is_completed).toBe(true);
      expect(mockTask.save).toHaveBeenCalled();
      expect(result).toEqual(mockTask);
    });

    it('should throw NotFoundError when task does not exist', async () => {
      // Arrange
      (Task.findOne as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(TaskService.markComplete('invalid-id', 'user-123'))
        .rejects
        .toThrow(NotFoundError);
    });

    it('should throw NotFoundError when task belongs to different user', async () => {
      // Arrange
      (Task.findOne as jest.Mock).mockResolvedValue(null);

      // Act & Assert
      await expect(TaskService.markComplete('task-123', 'other-user'))
        .rejects
        .toThrow(NotFoundError);
    });
  });
});
```

**Pattern Matching Analysis**:
- ✅ `describe/it` structure (learned)
- ✅ AAA pattern (Arrange-Act-Assert) with comments (learned)
- ✅ `jest.mock()` for mocking (learned)
- ✅ `beforeEach` for test isolation (learned)
- ✅ Test naming: "should + verb + expected" (learned)
- ✅ Clear test organization (learned)

### Example B: Python + pytest

```python
# tests/unit/test_task_service.py

import pytest
from datetime import datetime
from unittest.mock import Mock, patch
from app.services.task_service import TaskService
from app.models import Task
from app.exceptions import ValidationError, NotFoundError

class TestTaskService:
    """Test suite for TaskService"""

    @pytest.fixture
    def mock_db(self):
        """Mock database session"""
        return Mock()

    @pytest.fixture
    def task_service(self, mock_db):
        """Create TaskService instance with mocked db"""
        return TaskService()

    def test_create_task_with_valid_data(self, mock_db):
        """Should create task with valid data"""
        # Arrange
        task_data = {
            'title': 'Test Task',
            'description': 'Test Description',
            'user_id': 'user-123'
        }

        mock_task = Task(
            id='task-123',
            **task_data,
            is_completed=False,
            created_at=datetime.now()
        )

        mock_db.add = Mock()
        mock_db.commit = Mock()
        mock_db.refresh = Mock()

        # Act
        with patch('app.models.Task', return_value=mock_task):
            result = TaskService.create_task(mock_db, task_data, 'user-123')

        # Assert
        assert result.title == 'Test Task'
        assert result.is_completed is False
        mock_db.add.assert_called_once()
        mock_db.commit.assert_called_once()

    def test_create_task_with_empty_title_raises_error(self, mock_db):
        """Should raise ValidationError when title is empty"""
        # Arrange
        task_data = {'title': '', 'user_id': 'user-123'}

        # Act & Assert
        with pytest.raises(ValidationError, match="Title is required"):
            TaskService.create_task(mock_db, task_data, 'user-123')

    @pytest.mark.parametrize('title', [
        '',
        '   ',
        None
    ])
    def test_create_task_with_invalid_titles(self, mock_db, title):
        """Should raise ValidationError for various invalid titles"""
        with pytest.raises(ValidationError):
            TaskService.create_task(mock_db, {'title': title}, 'user-123')

    def test_get_user_tasks_returns_all_tasks(self, mock_db):
        """Should return all tasks for a user"""
        # Arrange
        mock_tasks = [
            Mock(id='task-1', title='Task 1'),
            Mock(id='task-2', title='Task 2')
        ]

        mock_db.query.return_value.filter.return_value.order_by.return_value.all.return_value = mock_tasks

        # Act
        result = TaskService.get_user_tasks(mock_db, 'user-123')

        # Assert
        assert len(result) == 2
        assert result == mock_tasks

    def test_mark_complete_updates_task(self, mock_db):
        """Should mark task as complete"""
        # Arrange
        mock_task = Mock(is_completed=False)
        mock_db.query.return_value.filter.return_value.first.return_value = mock_task

        # Act
        result = TaskService.mark_complete(mock_db, 'task-123', 'user-123')

        # Assert
        assert mock_task.is_completed is True
        mock_db.commit.assert_called_once()
        assert result == mock_task

    def test_mark_complete_raises_not_found_for_invalid_task(self, mock_db):
        """Should raise NotFoundError when task doesn't exist"""
        # Arrange
        mock_db.query.return_value.filter.return_value.first.return_value = None

        # Act & Assert
        with pytest.raises(NotFoundError, match="Task not found"):
            TaskService.mark_complete(mock_db, 'invalid-id', 'user-123')
```

### Example C: Go + testing package

```go
// internal/services/task_service_test.go

package services

import (
    "errors"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
    "myapp/internal/models"
)

// Mock DB
type MockDB struct {
    mock.Mock
}

func (m *MockDB) Create(task *models.Task) error {
    args := m.Called(task)
    return args.Error(0)
}

func (m *MockDB) Find(userID string) ([]models.Task, error) {
    args := m.Called(userID)
    return args.Get(0).([]models.Task), args.Error(1)
}

func TestCreateTask(t *testing.T) {
    t.Run("should create task with valid data", func(t *testing.T) {
        // Arrange
        mockDB := new(MockDB)
        service := NewTaskService(mockDB)

        mockDB.On("Create", mock.AnythingOfType("*models.Task")).Return(nil)

        // Act
        task, err := service.CreateTask("user-123", "Test Task", "Description")

        // Assert
        assert.NoError(t, err)
        assert.NotNil(t, task)
        assert.Equal(t, "Test Task", task.Title)
        assert.False(t, task.IsCompleted)
        mockDB.AssertExpectations(t)
    })

    t.Run("should return error when title is empty", func(t *testing.T) {
        // Arrange
        mockDB := new(MockDB)
        service := NewTaskService(mockDB)

        // Act
        task, err := service.CreateTask("user-123", "", "Description")

        // Assert
        assert.Error(t, err)
        assert.Nil(t, task)
        assert.Equal(t, "title is required", err.Error())
    })
}

func TestGetUserTasks(t *testing.T) {
    t.Run("should return all tasks for user", func(t *testing.T) {
        // Arrange
        mockDB := new(MockDB)
        service := NewTaskService(mockDB)

        mockTasks := []models.Task{
            {ID: "task-1", Title: "Task 1"},
            {ID: "task-2", Title: "Task 2"},
        }

        mockDB.On("Find", "user-123").Return(mockTasks, nil)

        // Act
        tasks, err := service.GetUserTasks("user-123")

        // Assert
        assert.NoError(t, err)
        assert.Len(t, tasks, 2)
        mockDB.AssertExpectations(t)
    })
}

// Table-driven test example
func TestValidateTitle(t *testing.T) {
    tests := []struct {
        name    string
        title   string
        wantErr bool
    }{
        {"valid title", "Test Task", false},
        {"empty title", "", true},
        {"whitespace title", "   ", true},
        {"long title", "This is a very long task title that should be accepted", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validateTitle(tt.title)
            if tt.wantErr {
                assert.Error(t, err)
            } else {
                assert.NoError(t, err)
            }
        })
    }
}
```

---

## Test Coverage Tracking

```typescript
interface CoverageReport {
  overall: number        // 85%
  statements: number     // 87%
  branches: number       // 82%
  functions: number      // 90%
  lines: number         // 85%

  uncoveredFiles: string[]  // Files below threshold
  recommendations: string[]
}

// Auto-generate coverage report
async function generateCoverageReport(): Promise<CoverageReport> {
  // Run tests with coverage
  await runTests({ coverage: true })

  // Parse coverage results
  const coverage = await parseCoverageResults()

  return {
    overall: coverage.overall,
    statements: coverage.statements,
    branches: coverage.branches,
    functions: coverage.functions,
    lines: coverage.lines,
    uncoveredFiles: coverage.files.filter(f => f.coverage < 80),
    recommendations: generateRecommendations(coverage)
  }
}
```

---

## Completion Report

```markdown
# Test Worker Report (Self-Adapting)

**Feature ID**: FEAT-002
**Feature Name**: Task Management
**Status**: ✅ COMPLETE

---

## Technology Stack (Auto-Detected)

- **Unit Test Framework**: Jest v29.5.0
- **E2E Test Framework**: Playwright v1.32.0
- **Assertion Library**: Jest (expect)
- **Mocking Library**: Jest (jest.fn, jest.mock)
- **Coverage Tool**: Jest (--coverage)

**Detection Method**: Analyzed package.json + existing test patterns

---

## Test Summary

### Unit Tests (7 files, 145 tests)
1. **TaskService.test.ts** (25 tests)
   - createTask: 5 tests
   - getUserTasks: 3 tests
   - markComplete: 4 tests
   - deleteTask: 3 tests

2. **TaskController.test.ts** (20 tests)
   - POST /api/tasks: 8 tests
   - GET /api/tasks: 5 tests
   - PUT /api/tasks/:id: 7 tests

3. **Task.model.test.ts** (15 tests)
   - Model creation
   - Validation rules
   - Associations

### Integration Tests (1 file, 35 tests)
1. **task.integration.test.ts** (35 tests)
   - Full API workflow tests
   - Database integration tests
   - Authentication integration

### E2E Tests (1 file, 20 tests)
1. **task-management.e2e.test.ts** (20 tests)
   - Complete user journeys
   - UI interactions
   - Cross-browser testing

---

## Coverage Report

| Metric | Coverage | Target | Status |
|--------|----------|--------|--------|
| **Overall** | **91%** | 80% | ✅ PASS |
| Statements | 92% | 80% | ✅ PASS |
| Branches | 88% | 80% | ✅ PASS |
| Functions | 95% | 80% | ✅ PASS |
| Lines | 91% | 80% | ✅ PASS |

### Uncovered Code
- `src/utils/logger.ts` (72% - below threshold)
  - Recommendation: Add error logging tests

---

## Pattern Matching

✅ Followed existing test patterns:
- describe/it structure (learned)
- AAA pattern with comments (learned)
- jest.mock for dependencies (learned)
- beforeEach for isolation (learned)
- Test naming: "should + behavior" (learned)

---

## Test Quality Metrics

- ✅ All tests independent (no shared state)
- ✅ Average execution time: 3.2s (unit tests)
- ✅ No flaky tests detected
- ✅ 100% deterministic
- ✅ Clear test names
- ✅ Proper assertions (not just "no error")

---

## Next Steps

All testing complete! Ready for:
1. **Phase 4 (Code Review Gate)** - Evaluators can review code + tests
2. **Phase 5 (Deployment Gate)** - Can deploy with confidence (91% coverage)
```

---

**Status**: ✅ Design Complete
**Innovation**: Works with Jest, pytest, JUnit, Go test - zero templates!

---

## Language Preferences Support 🌐

This worker respects the language preferences configured in `.claude/CLAUDE.md` (generated by `/setup` command).

### Reading Language Configuration

Before generating documentation, read the configuration:

```typescript
const fs = require('fs')
const yaml = require('js-yaml')

let docLang = 'en'  // default
let dualDocs = false  // default

if (fs.existsSync('.claude/edaf-config.yml')) {
  const config = yaml.load(fs.readFileSync('.claude/edaf-config.yml', 'utf-8'))
  docLang = config.language_preferences?.documentation_language || 'en'
  dualDocs = config.language_preferences?.save_dual_language_docs || false
}
```

### Option 4: Dual Language Documentation

If `save_dual_language_docs: true`, save both English and Japanese versions:

```typescript
// After generating documentation
const docPath = 'docs/...'  // appropriate path for this worker
const docContent = /* generated documentation in English */

// Save English version
fs.writeFileSync(docPath, docContent)
console.log(`✅ Documentation saved to ${docPath}`)

// Option 4: Also save Japanese translation
if (dualDocs && docLang === 'en') {
  console.log('📝 Generating Japanese translation...')
  
  // Request translation from Claude
  const translationPrompt = `以下の英語ドキュメントを日本語に翻訳してください。

技術用語は適切に日本語化し、コードブロックはそのまま保持してください。

---

${docContent}`

  // Save Japanese version to docs/tmp/ja/
  const jaPath = docPath.replace('docs/', 'docs/tmp/ja/')
  fs.mkdirSync(path.dirname(jaPath), { recursive: true })
  
  console.log(`✅ Japanese version saved to ${jaPath}`)
}
```

### Key Points

1. **Option 1-3**: No code changes needed
   - CLAUDE.md instructs Claude Code to respond in the target language
   - Documentation is automatically generated in the specified language

2. **Option 4**: Requires dual documentation save
   - Generate English documentation first
   - Request translation from Claude
   - Save Japanese version to `docs/tmp/ja/`

3. **Terminal Output Language**:
   - CLAUDE.md handles this automatically
   - Worker doesn't need to change console.log statements
   - Claude Code translates output based on `terminal_output_language` setting

No template maintenance, no language-specific code branches! 🎉
