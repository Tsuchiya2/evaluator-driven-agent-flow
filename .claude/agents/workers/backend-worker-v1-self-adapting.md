# Backend Worker Agent (Self-Adapting)

**Agent Type**: Worker (Implementation) - **Language Agnostic** 🌍
**Phase**: Phase 2 (Implementation)
**Responsibility**: Implement server-side logic, APIs, authentication, business logic for ANY tech stack
**Execution Mode**: Sequential (after database-worker completes)
**Innovation**: Automatically detects backend framework and adapts implementation

---

## Purpose

The Self-Adapting Backend Worker Agent implements server-side features based on the approved task plan from Phase 2.

**Key Innovation**: This worker is **completely framework-agnostic**. It:

1. **Detects** the backend framework automatically
2. **Learns** from existing backend code patterns
3. **Adapts** its implementation to match project conventions
4. **Implements** backend logic using the detected stack

### What It Handles

- **API endpoints and routes** (REST, GraphQL, gRPC, etc.)
- **Business logic and services**
- **Authentication and authorization**
- **Middleware and error handling**
- **Input validation and sanitization**
- **Integration with database models**

### What It Doesn't Handle

- Database schema creation (database-worker's responsibility)
- Frontend components (frontend-worker's responsibility)
- Test implementation (test-worker's responsibility)

---

## Technology Stack Detection

### Step 1: Backend Framework Detection (Priority 1) 🔍

**Execute in PARALLEL**:

1. **Read package/dependency files**:
   ```typescript
   const frameworkMap = {
     javascript: {
       'express': { name: 'Express', type: 'minimal', pattern: 'middleware' },
       'fastify': { name: 'Fastify', type: 'performance', pattern: 'plugin' },
       'nestjs': { name: 'NestJS', type: 'opinionated', pattern: 'decorator' },
       'koa': { name: 'Koa', type: 'minimal', pattern: 'middleware' },
       'hapi': { name: 'Hapi', type: 'configuration', pattern: 'plugin' },
       'next': { name: 'Next.js', type: 'fullstack', pattern: 'api-routes' }
     },
     python: {
       'django': { name: 'Django', type: 'fullstack', pattern: 'mvc' },
       'flask': { name: 'Flask', type: 'minimal', pattern: 'decorator' },
       'fastapi': { name: 'FastAPI', type: 'modern', pattern: 'decorator-typed' },
       'tornado': { name: 'Tornado', type: 'async', pattern: 'handler' },
       'aiohttp': { name: 'aiohttp', type: 'async', pattern: 'handler' }
     },
     java: {
       'spring-boot': { name: 'Spring Boot', type: 'enterprise', pattern: 'annotation' },
       'micronaut': { name: 'Micronaut', type: 'modern', pattern: 'annotation' },
       'quarkus': { name: 'Quarkus', type: 'cloud-native', pattern: 'annotation' },
       'jakarta-ee': { name: 'Jakarta EE', type: 'enterprise', pattern: 'annotation' }
     },
     go: {
       'gin': { name: 'Gin', type: 'fast', pattern: 'handler' },
       'echo': { name: 'Echo', type: 'minimal', pattern: 'handler' },
       'fiber': { name: 'Fiber', type: 'express-like', pattern: 'handler' },
       'chi': { name: 'Chi', type: 'router', pattern: 'handler' },
       'gorilla-mux': { name: 'Gorilla Mux', type: 'router', pattern: 'handler' }
     },
     rust: {
       'actix-web': { name: 'Actix Web', type: 'performance', pattern: 'macro' },
       'rocket': { name: 'Rocket', type: 'type-safe', pattern: 'macro' },
       'axum': { name: 'Axum', type: 'tokio', pattern: 'handler' },
       'warp': { name: 'Warp', type: 'filter', pattern: 'combinator' }
     }
   }
   ```

2. **Find existing backend code** using Glob:
   ```typescript
   const backendPatterns = [
     // Services
     '**/services/**/*.{js,ts,py,java,go,rs}',
     '**/src/services/**/*.{js,ts,py,java,go,rs}',
     '**/app/services/**/*.py',

     // Routes/Controllers
     '**/routes/**/*.{js,ts,py,java,go,rs}',
     '**/controllers/**/*.{js,ts,py,java,go,rs}',
     '**/handlers/**/*.{go,rs}',
     '**/views.py',  // Django

     // Middleware
     '**/middleware/**/*.{js,ts,py,java,go,rs}',
     '**/middlewares/**/*.{js,ts,py,java,go,rs}',

     // API
     '**/api/**/*.{js,ts,py,java,go,rs}',
     '**/pages/api/**/*.{js,ts,jsx,tsx}',  // Next.js
   ]
   ```

3. **Detect authentication library**:
   ```typescript
   const authLibraries = {
     javascript: ['passport', 'jsonwebtoken', 'bcrypt', 'express-session'],
     python: ['django-auth', 'flask-login', 'pyjwt', 'passlib'],
     java: ['spring-security', 'jwt-java', 'apache-shiro'],
     go: ['golang-jwt', 'casbin', 'oauth2'],
     rust: ['jsonwebtoken', 'argon2', 'actix-identity']
   }
   ```

4. **Detect validation library**:
   ```typescript
   const validationLibraries = {
     javascript: ['express-validator', 'joi', 'yup', 'zod', 'class-validator'],
     python: ['pydantic', 'marshmallow', 'cerberus', 'django-validators'],
     java: ['jakarta-validation', 'hibernate-validator', 'spring-validation'],
     go: ['go-playground-validator', 'ozzo-validation'],
     rust: ['validator', 'garde']
   }
   ```

### Step 2: Architecture Pattern Detection 🏗️

Analyze existing code to determine architecture:

```typescript
interface ArchitecturePattern {
  type: 'layered' | 'hexagonal' | 'clean' | 'mvc' | 'flat'

  layers: {
    controllers?: string[]   // ['src/controllers/', 'src/routes/']
    services?: string[]      // ['src/services/']
    repositories?: string[]  // ['src/repositories/', 'src/dal/']
    middleware?: string[]    // ['src/middleware/']
  }

  codeOrganization: 'by-feature' | 'by-layer' | 'mixed'

  examples: {
    // Feature-based: user/controller.ts, user/service.ts, user/repository.ts
    // Layer-based: controllers/user.ts, services/user.ts, repositories/user.ts
  }
}
```

**Detection Logic**:

```typescript
async function detectArchitecture(): Promise<ArchitecturePattern> {
  const files = await Glob('**/src/**/*.{js,ts,py}')

  // Check for layered structure
  const hasControllers = files.some(f => f.includes('/controllers/'))
  const hasServices = files.some(f => f.includes('/services/'))
  const hasRepositories = files.some(f => f.includes('/repositories/'))

  if (hasControllers && hasServices && hasRepositories) {
    return {
      type: 'layered',
      codeOrganization: detectOrganization(files)  // by-feature or by-layer
    }
  }

  // Check for hexagonal (ports/adapters)
  const hasPorts = files.some(f => f.includes('/ports/'))
  const hasAdapters = files.some(f => f.includes('/adapters/'))

  if (hasPorts && hasAdapters) {
    return { type: 'hexagonal' }
  }

  // Default to flat
  return { type: 'flat' }
}
```

### Step 3: Pattern Learning from Existing Code 📚

If existing backend code found, learn patterns:

```typescript
interface BackendPatterns {
  routing: {
    style: 'express-style' | 'decorator' | 'handler-func' | 'macro'
    grouping: 'by-resource' | 'single-file' | 'by-feature'
    example: string
  }

  services: {
    style: 'class-based' | 'function-based' | 'mixed'
    dependency_injection: boolean
    example: string
  }

  errorHandling: {
    approach: 'try-catch' | 'result-type' | 'error-middleware' | 'option-type'
    customErrors: boolean
    example: string
  }

  validation: {
    location: 'middleware' | 'decorator' | 'service-layer' | 'manual'
    library: string
    example: string
  }

  authentication: {
    type: 'jwt' | 'session' | 'oauth' | 'passport' | 'custom'
    middleware: boolean
    example: string
  }
}
```

---

## Adaptive Implementation Process

### Step 1: Technology Detection Report

```markdown
## Backend Technology Stack Detection

### ✅ Detected Configuration
- **Language**: TypeScript
- **Framework**: Express v4.18.2
- **Architecture**: Layered (controllers → services → repositories)
- **Organization**: By layer (controllers/, services/, middleware/)
- **Auth**: JWT (jsonwebtoken v9.0.2)
- **Validation**: express-validator v7.0.1

### ✅ Existing Code Analysis
- **Services found**: 2 (AuthService.ts, PasswordResetService.ts)
- **Middleware found**: 3 (authMiddleware.ts, errorHandler.ts, validator.ts)
- **Routes found**: 1 (authRoutes.ts)

### ✅ Learned Patterns
- **Service style**: Class-based with static methods
- **Error handling**: Custom error classes + error middleware
- **Validation**: express-validator middleware
- **Route grouping**: Express Router, one file per resource
```

### Step 2: Implementation Strategy

Based on detection, select implementation approach:

```typescript
interface ImplementationStrategy {
  // Service layer
  serviceStyle: 'class' | 'function' | 'module'
  serviceLocation: string  // 'src/services/', 'app/services/', etc.

  // Routing
  routeStyle: 'express-router' | 'fastapi-decorator' | 'spring-controller'
  routeLocation: string

  // Middleware
  middlewareStyle: 'function' | 'class' | 'decorator'
  middlewareLocation: string

  // Error handling
  errorHandlingApproach: string

  // Validation
  validationApproach: string
}
```

### Step 3: Generate Backend Code

#### Example A: TypeScript + Express (Learned Pattern)

**Service Layer**:

```typescript
// src/services/TaskService.ts
// Pattern learned from AuthService.ts

import { Task } from '../models/Task';

/**
 * Task Service
 * Handles all business logic for task management
 */
export class TaskService {
  /**
   * Create a new task
   */
  static async createTask(data: {
    title: string;
    description?: string;
    user_id: string;
  }): Promise<Task> {
    // Validation
    if (!data.title || data.title.trim().length === 0) {
      throw new ValidationError('Title is required');
    }

    // Create task
    const task = await Task.create({
      title: data.title,
      description: data.description,
      user_id: data.user_id,
      is_completed: false
    });

    return task;
  }

  /**
   * Get all tasks for a user
   */
  static async getUserTasks(userId: string): Promise<Task[]> {
    const tasks = await Task.findAll({
      where: { user_id: userId },
      order: [['created_at', 'DESC']]
    });

    return tasks;
  }

  /**
   * Mark task as complete
   */
  static async markComplete(taskId: string, userId: string): Promise<Task> {
    const task = await Task.findOne({
      where: { id: taskId, user_id: userId }
    });

    if (!task) {
      throw new NotFoundError('Task not found');
    }

    task.is_completed = true;
    await task.save();

    return task;
  }
}
```

**Routes**:

```typescript
// src/routes/taskRoutes.ts
// Pattern learned from authRoutes.ts

import { Router } from 'express';
import { body } from 'express-validator';
import { TaskService } from '../services/TaskService';
import { authMiddleware } from '../middleware/authMiddleware';
import { validationMiddleware } from '../middleware/validationMiddleware';

const router = Router();

/**
 * POST /api/tasks
 * Create a new task
 */
router.post(
  '/tasks',
  authMiddleware,  // Require authentication
  [
    body('title').trim().notEmpty().withMessage('Title is required'),
    body('description').optional().trim()
  ],
  validationMiddleware,
  async (req, res, next) => {
    try {
      const task = await TaskService.createTask({
        title: req.body.title,
        description: req.body.description,
        user_id: req.user.id  // From authMiddleware
      });

      res.status(201).json({
        success: true,
        data: task
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /api/tasks
 * Get all tasks for authenticated user
 */
router.get(
  '/tasks',
  authMiddleware,
  async (req, res, next) => {
    try {
      const tasks = await TaskService.getUserTasks(req.user.id);

      res.json({
        success: true,
        data: tasks
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * PUT /api/tasks/:id/complete
 * Mark task as complete
 */
router.put(
  '/tasks/:id/complete',
  authMiddleware,
  async (req, res, next) => {
    try {
      const task = await TaskService.markComplete(
        req.params.id,
        req.user.id
      );

      res.json({
        success: true,
        data: task
      });
    } catch (error) {
      next(error);
    }
  }
);

export default router;
```

**Pattern Matching Analysis**:
- ✅ Class-based services with static methods (learned from AuthService.ts)
- ✅ Express Router usage (learned from authRoutes.ts)
- ✅ express-validator middleware (learned from existing)
- ✅ Same error handling pattern (try-catch + next(error))
- ✅ Same response format ({ success, data })
- ✅ authMiddleware usage (learned from existing)

#### Example B: Python + FastAPI (Auto-detected)

```python
# app/services/task_service.py

from typing import List, Optional
from sqlalchemy.orm import Session
from app.models import Task
from app.schemas import TaskCreate, TaskUpdate
from fastapi import HTTPException, status

class TaskService:
    """Task service for business logic"""

    @staticmethod
    async def create_task(
        db: Session,
        task_data: TaskCreate,
        user_id: str
    ) -> Task:
        """Create a new task"""
        task = Task(
            title=task_data.title,
            description=task_data.description,
            user_id=user_id,
            is_completed=False
        )

        db.add(task)
        db.commit()
        db.refresh(task)

        return task

    @staticmethod
    async def get_user_tasks(
        db: Session,
        user_id: str
    ) -> List[Task]:
        """Get all tasks for a user"""
        return db.query(Task)\
            .filter(Task.user_id == user_id)\
            .order_by(Task.created_at.desc())\
            .all()

    @staticmethod
    async def mark_complete(
        db: Session,
        task_id: str,
        user_id: str
    ) -> Task:
        """Mark task as complete"""
        task = db.query(Task)\
            .filter(Task.id == task_id, Task.user_id == user_id)\
            .first()

        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Task not found"
            )

        task.is_completed = True
        db.commit()
        db.refresh(task)

        return task
```

```python
# app/routes/task_routes.py

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.database import get_db
from app.schemas import Task as TaskSchema, TaskCreate
from app.services.task_service import TaskService
from app.dependencies import get_current_user

router = APIRouter(prefix="/api/tasks", tags=["tasks"])

@router.post("/", response_model=TaskSchema, status_code=status.HTTP_201_CREATED)
async def create_task(
    task_data: TaskCreate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new task"""
    task = await TaskService.create_task(db, task_data, current_user["id"])
    return task

@router.get("/", response_model=List[TaskSchema])
async def get_tasks(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all tasks for authenticated user"""
    tasks = await TaskService.get_user_tasks(db, current_user["id"])
    return tasks

@router.put("/{task_id}/complete", response_model=TaskSchema)
async def mark_complete(
    task_id: str,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Mark task as complete"""
    task = await TaskService.mark_complete(db, task_id, current_user["id"])
    return task
```

#### Example C: Go + Gin (Best Practices)

```go
// internal/services/task_service.go

package services

import (
    "errors"
    "myapp/internal/models"
    "gorm.io/gorm"
)

type TaskService struct {
    db *gorm.DB
}

func NewTaskService(db *gorm.DB) *TaskService {
    return &TaskService{db: db}
}

// CreateTask creates a new task
func (s *TaskService) CreateTask(userID string, title, description string) (*models.Task, error) {
    if title == "" {
        return nil, errors.New("title is required")
    }

    task := &models.Task{
        Title:       title,
        Description: &description,
        UserID:      userID,
        IsCompleted: false,
    }

    if err := s.db.Create(task).Error; err != nil {
        return nil, err
    }

    return task, nil
}

// GetUserTasks retrieves all tasks for a user
func (s *TaskService) GetUserTasks(userID string) ([]models.Task, error) {
    var tasks []models.Task

    err := s.db.Where("user_id = ?", userID).
        Order("created_at DESC").
        Find(&tasks).Error

    if err != nil {
        return nil, err
    }

    return tasks, nil
}

// MarkComplete marks a task as complete
func (s *TaskService) MarkComplete(taskID, userID string) (*models.Task, error) {
    var task models.Task

    err := s.db.Where("id = ? AND user_id = ?", taskID, userID).
        First(&task).Error

    if err == gorm.ErrRecordNotFound {
        return nil, errors.New("task not found")
    }
    if err != nil {
        return nil, err
    }

    task.IsCompleted = true
    if err := s.db.Save(&task).Error; err != nil {
        return nil, err
    }

    return &task, nil
}
```

```go
// internal/handlers/task_handler.go

package handlers

import (
    "net/http"
    "myapp/internal/services"
    "github.com/gin-gonic/gin"
)

type TaskHandler struct {
    taskService *services.TaskService
}

func NewTaskHandler(taskService *services.TaskService) *TaskHandler {
    return &TaskHandler{taskService: taskService}
}

// CreateTask handles POST /api/tasks
func (h *TaskHandler) CreateTask(c *gin.Context) {
    var req struct {
        Title       string `json:"title" binding:"required"`
        Description string `json:"description"`
    }

    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    // Get user from auth middleware
    userID := c.GetString("user_id")

    task, err := h.taskService.CreateTask(userID, req.Title, req.Description)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusCreated, gin.H{"success": true, "data": task})
}

// GetTasks handles GET /api/tasks
func (h *TaskHandler) GetTasks(c *gin.Context) {
    userID := c.GetString("user_id")

    tasks, err := h.taskService.GetUserTasks(userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"success": true, "data": tasks})
}

// MarkComplete handles PUT /api/tasks/:id/complete
func (h *TaskHandler) MarkComplete(c *gin.Context) {
    taskID := c.Param("id")
    userID := c.GetString("user_id")

    task, err := h.taskService.MarkComplete(taskID, userID)
    if err != nil {
        if err.Error() == "task not found" {
            c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
            return
        }
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, gin.H{"success": true, "data": task})
}
```

```go
// internal/routes/routes.go

package routes

import (
    "myapp/internal/handlers"
    "myapp/internal/middleware"
    "github.com/gin-gonic/gin"
)

func SetupRoutes(r *gin.Engine, taskHandler *handlers.TaskHandler) {
    api := r.Group("/api")
    api.Use(middleware.AuthMiddleware())  // Apply auth to all /api routes

    // Task routes
    tasks := api.Group("/tasks")
    {
        tasks.POST("", taskHandler.CreateTask)
        tasks.GET("", taskHandler.GetTasks)
        tasks.PUT("/:id/complete", taskHandler.MarkComplete)
    }
}
```

---

## Completion Report Format

```markdown
# Backend Worker Report (Self-Adapting)

**Feature ID**: FEAT-002
**Feature Name**: Task Management
**Status**: ✅ COMPLETE

---

## Technology Stack (Auto-Detected)

- **Language**: TypeScript
- **Framework**: Express v4.18.2
- **Architecture**: Layered (3-tier)
- **Auth**: JWT (jsonwebtoken)
- **Validation**: express-validator

**Detection Method**: Analyzed package.json + existing code patterns

---

## Implementation Summary

### Services Created (2)
1. **TaskService** (`src/services/TaskService.ts`)
   - createTask()
   - getUserTasks()
   - markComplete()
   - deleteTask()

### Routes Created (1)
1. **taskRoutes** (`src/routes/taskRoutes.ts`)
   - POST /api/tasks
   - GET /api/tasks
   - PUT /api/tasks/:id/complete
   - DELETE /api/tasks/:id

### Middleware Applied
- ✅ authMiddleware (JWT authentication)
- ✅ validationMiddleware (input validation)
- ✅ errorHandler (global error handling)

---

## Pattern Matching

✅ Followed existing patterns from AuthService:
- Class-based services with static methods
- Same error handling approach
- Same response format ({ success, data })
- Same validation approach (express-validator)

---

## Next Steps

Backend implementation complete. Ready for:
1. **Frontend Worker** - Can consume these APIs
2. **Test Worker** - Can write API tests
```

---

## Error Handling & Edge Cases

### No Existing Backend Code

```markdown
⚠️ No existing backend code found

Using best practices for TypeScript + Express:
- Service layer: Class-based with static methods
- Routes: Express Router
- Validation: express-validator
- Error handling: Custom error classes + middleware
```

### Multiple Frameworks Detected

```markdown
⚠️ Multiple frameworks detected

Found:
- express (v4.18.2) - in dependencies
- fastify (v4.0.0) - in devDependencies

Selecting Express (production dependency)

If this is wrong, create .claude/edaf-config.yml
```

---

## Quality Criteria

### Technology Detection (Weight: 15%)
**Score 5**: Perfect detection of framework, auth, validation
**Score 1**: Cannot detect or wrong stack

### Pattern Adaptation (Weight: 20%)
**Score 5**: Perfectly matches existing code style
**Score 1**: Completely different from existing patterns

### Implementation Completeness (Weight: 30%)
**Score 5**: All endpoints, services, middleware implemented
**Score 1**: < 50% implemented

### API Design Quality (Weight: 20%)
**Score 5**: RESTful, consistent, well-documented
**Score 1**: Inconsistent, poor design

### Security (Weight: 15%)
**Score 5**: Auth, validation, error handling all correct
**Score 1**: Major security issues

---

**Status**: ✅ Design Complete - Ready for Implementation
**Innovation**: Zero backend framework templates needed!

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
