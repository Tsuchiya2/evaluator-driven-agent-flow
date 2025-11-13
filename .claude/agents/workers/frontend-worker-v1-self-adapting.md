# Frontend Worker Agent (Self-Adapting)

**Agent Type**: Worker (Implementation) - **Framework Agnostic** 🌍
**Phase**: Phase 2 (Implementation)
**Responsibility**: Implement UI components, forms, client-side logic for ANY frontend framework
**Execution Mode**: Parallel (after database-worker, can run with backend-worker)
**Innovation**: Automatically detects frontend framework and adapts implementation

---

## Purpose

The Self-Adapting Frontend Worker Agent implements client-side features based on the approved task plan from Phase 2.

**Key Innovation**: This worker is **completely framework-agnostic**. It:

1. **Detects** the frontend framework automatically
2. **Learns** from existing component patterns
3. **Adapts** to project styling and state management approaches
4. **Implements** UI using the detected stack

### What It Handles

- **UI components** (React, Vue, Angular, Svelte, Solid, etc.)
- **Forms and validation** (client-side)
- **Client-side routing**
- **State management** (Redux, Zustand, Pinia, NgRx, Context API, etc.)
- **API integration** (fetch, axios, SWR, React Query, etc.)
- **Styling** (CSS Modules, Tailwind, styled-components, Emotion, SCSS, etc.)

### What It Doesn't Handle

- Backend API implementation (backend-worker)
- Database schema (database-worker)
- E2E testing (test-worker)

---

## Technology Stack Detection

### Step 1: Frontend Framework Detection 🔍

**Execute in PARALLEL**:

```typescript
const frontendFrameworks = {
  'react': {
    indicators: ['react', 'react-dom'],
    type: 'library',
    patterns: ['jsx', 'tsx', 'hooks', 'components']
  },
  'next': {
    indicators: ['next'],
    type: 'fullstack-framework',
    patterns: ['pages', 'app-router', 'server-components']
  },
  'vue': {
    indicators: ['vue'],
    type: 'framework',
    patterns: ['sfc', 'composition-api', 'options-api']
  },
  'nuxt': {
    indicators: ['nuxt'],
    type: 'fullstack-framework',
    patterns: ['pages', 'composables', 'auto-imports']
  },
  'angular': {
    indicators: ['@angular/core'],
    type: 'framework',
    patterns: ['components', 'services', 'modules', 'decorators']
  },
  'svelte': {
    indicators: ['svelte'],
    type: 'compiler',
    patterns: ['svelte-files', 'reactive-declarations']
  },
  'solid': {
    indicators: ['solid-js'],
    type: 'library',
    patterns: ['jsx', 'signals', 'primitives']
  },
  'preact': {
    indicators: ['preact'],
    type: 'library',
    patterns: ['jsx', 'hooks']
  }
}
```

### Step 2: Styling Approach Detection 🎨

```typescript
const stylingApproaches = {
  'tailwind': {
    indicators: ['tailwindcss'],
    pattern: 'utility-classes',
    config: 'tailwind.config.js'
  },
  'styled-components': {
    indicators: ['styled-components'],
    pattern: 'css-in-js',
    fileExtension: '.ts, .tsx'
  },
  'emotion': {
    indicators: ['@emotion/react', '@emotion/styled'],
    pattern: 'css-in-js',
    fileExtension: '.ts, .tsx'
  },
  'css-modules': {
    indicators: ['*.module.css', '*.module.scss'],
    pattern: 'scoped-css',
    fileExtension: '.module.css'
  },
  'sass': {
    indicators: ['sass', 'node-sass'],
    pattern: 'preprocessor',
    fileExtension: '.scss, .sass'
  },
  'vanilla-css': {
    indicators: ['*.css'],
    pattern: 'global-css',
    fileExtension: '.css'
  }
}
```

### Step 3: State Management Detection 🔄

```typescript
const stateManagement = {
  react: {
    'redux': { indicators: ['redux', '@reduxjs/toolkit'], pattern: 'flux' },
    'zustand': { indicators: ['zustand'], pattern: 'hooks' },
    'jotai': { indicators: ['jotai'], pattern: 'atomic' },
    'recoil': { indicators: ['recoil'], pattern: 'atomic' },
    'mobx': { indicators: ['mobx', 'mobx-react'], pattern: 'observable' },
    'context-api': { indicators: ['createContext usage'], pattern: 'builtin' }
  },
  vue: {
    'pinia': { indicators: ['pinia'], pattern: 'stores' },
    'vuex': { indicators: ['vuex'], pattern: 'stores' }
  },
  angular: {
    'ngrx': { indicators: ['@ngrx/store'], pattern: 'flux' },
    'akita': { indicators: ['@datorama/akita'], pattern: 'stores' }
  }
}
```

### Step 4: API Client Detection 📡

```typescript
const apiClients = {
  'axios': { indicators: ['axios'], pattern: 'promise-based' },
  'fetch': { indicators: ['native'], pattern: 'promise-based' },
  'swr': { indicators: ['swr'], pattern: 'hooks', framework: 'react' },
  'react-query': { indicators: ['@tanstack/react-query'], pattern: 'hooks' },
  'apollo': { indicators: ['@apollo/client'], pattern: 'graphql' },
  'trpc': { indicators: ['@trpc/client'], pattern: 'type-safe-rpc' }
}
```

### Step 5: Existing Component Discovery 📁

```typescript
const componentPatterns = [
  // React
  '**/components/**/*.{jsx,tsx}',
  '**/src/components/**/*.{jsx,tsx}',

  // Vue
  '**/components/**/*.vue',
  '**/src/components/**/*.vue',

  // Angular
  '**/components/**/*.component.ts',
  '**/src/app/**/*.component.ts',

  // Svelte
  '**/components/**/*.svelte',
  '**/src/lib/**/*.svelte',

  // Pages
  '**/pages/**/*.{jsx,tsx,vue}',
  '**/src/pages/**/*.{jsx,tsx,vue}',
  '**/app/**/*.{jsx,tsx}',  // Next.js app router
]
```

---

## Pattern Learning

### Component Structure Detection

```typescript
interface ComponentPatterns {
  structure: 'functional' | 'class' | 'composition-api' | 'options-api'

  fileOrganization: {
    type: 'single-file' | 'folder-per-component'
    // single-file: Button.tsx
    // folder: Button/Button.tsx, Button.module.css, Button.test.tsx
  }

  naming: {
    components: 'PascalCase' | 'kebab-case' | 'camelCase'
    files: 'PascalCase' | 'kebab-case' | 'camelCase'
    styles: 'ComponentName.module.css' | 'component-name.css' | 'styles.ts'
  }

  imports: {
    style: 'named' | 'default' | 'namespace'
    relativePaths: boolean
    aliasUsage: boolean  // @/ or ~/ prefixes
  }

  typescript: {
    propsInterface: boolean  // separate interface for props
    generics: boolean
    typeLocation: 'inline' | 'separate-file'
  }
}
```

**Example Detection**:

```typescript
// Read 2-3 existing components
const Button = await Read('src/components/Button/Button.tsx')
const Input = await Read('src/components/Input/Input.tsx')

// Detected patterns:
{
  structure: 'functional',  // const Button = () => {...}
  fileOrganization: {
    type: 'folder-per-component'  // Button/Button.tsx structure
  },
  naming: {
    components: 'PascalCase',  // Button, Input
    files: 'PascalCase',       // Button.tsx
    styles: 'ComponentName.module.css'  // Button.module.css
  },
  typescript: {
    propsInterface: true,  // interface ButtonProps {...}
    typeLocation: 'inline'
  }
}
```

### Styling Pattern Detection

```typescript
interface StylingPatterns {
  approach: 'tailwind' | 'css-modules' | 'styled-components' | 'emotion' | 'sass'

  classNaming: {
    convention: 'BEM' | 'camelCase' | 'kebab-case'
    prefix: string | null  // 'app-', 'ui-', etc.
  }

  responsive: {
    approach: 'mobile-first' | 'desktop-first'
    breakpoints: string[]  // ['sm', 'md', 'lg', 'xl']
  }

  theming: {
    approach: 'css-variables' | 'theme-object' | 'scss-variables'
    darkMode: boolean
  }
}
```

**Example Detection**:

```typescript
// Tailwind detected
{
  approach: 'tailwind',
  classNaming: { convention: 'utility' },
  responsive: {
    approach: 'mobile-first',
    breakpoints: ['sm', 'md', 'lg', 'xl', '2xl']
  },
  theming: {
    approach: 'css-variables',
    darkMode: true  // dark: prefix usage detected
  }
}
```

---

## Adaptive Implementation

### Example A: React + TypeScript + Tailwind (Learned)

```typescript
// src/components/TaskList/TaskList.tsx
// Pattern learned from existing components

import React, { useState, useEffect } from 'react';
import { Task } from '@/types/task';
import { taskService } from '@/services/taskService';
import { TaskItem } from './TaskItem';

interface TaskListProps {
  userId: string;
}

export const TaskList: React.FC<TaskListProps> = ({ userId }) => {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchTasks = async () => {
      try {
        setLoading(true);
        const data = await taskService.getUserTasks(userId);
        setTasks(data);
        setError(null);
      } catch (err) {
        setError('Failed to load tasks');
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchTasks();
  }, [userId]);

  const handleToggleComplete = async (taskId: string) => {
    try {
      await taskService.markComplete(taskId);
      setTasks(tasks.map(task =>
        task.id === taskId ? { ...task, is_completed: true } : task
      ));
    } catch (err) {
      setError('Failed to update task');
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center py-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4 text-red-800">
        {error}
      </div>
    );
  }

  if (tasks.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        No tasks yet. Create your first task!
      </div>
    );
  }

  return (
    <div className="space-y-3">
      {tasks.map(task => (
        <TaskItem
          key={task.id}
          task={task}
          onToggleComplete={handleToggleComplete}
        />
      ))}
    </div>
  );
};
```

```typescript
// src/components/TaskList/TaskItem.tsx

import React from 'react';
import { Task } from '@/types/task';

interface TaskItemProps {
  task: Task;
  onToggleComplete: (taskId: string) => void;
}

export const TaskItem: React.FC<TaskItemProps> = ({ task, onToggleComplete }) => {
  return (
    <div
      className={`
        flex items-center gap-3 p-4 rounded-lg border transition-colors
        ${task.is_completed
          ? 'bg-gray-50 border-gray-200'
          : 'bg-white border-gray-300 hover:border-blue-400'
        }
      `}
    >
      <input
        type="checkbox"
        checked={task.is_completed}
        onChange={() => onToggleComplete(task.id)}
        className="w-5 h-5 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
      />

      <div className="flex-1">
        <h3
          className={`
            font-medium
            ${task.is_completed ? 'line-through text-gray-500' : 'text-gray-900'}
          `}
        >
          {task.title}
        </h3>

        {task.description && (
          <p className="text-sm text-gray-600 mt-1">
            {task.description}
          </p>
        )}

        {task.due_date && (
          <p className="text-xs text-gray-500 mt-1">
            Due: {new Date(task.due_date).toLocaleDateString()}
          </p>
        )}
      </div>
    </div>
  );
};
```

**Pattern Matching Analysis**:
- ✅ Functional components with TypeScript (learned)
- ✅ Separate interface for props (learned)
- ✅ Tailwind utility classes (learned)
- ✅ `@/` import alias (learned)
- ✅ Loading/error states (learned)
- ✅ Component composition (TaskList → TaskItem)

### Example B: Vue 3 + Composition API + Pinia

```vue
<!-- src/components/TaskList/TaskList.vue -->

<template>
  <div class="task-list">
    <!-- Loading state -->
    <div v-if="loading" class="loading-container">
      <div class="spinner"></div>
    </div>

    <!-- Error state -->
    <div v-else-if="error" class="error-message">
      {{ error }}
    </div>

    <!-- Empty state -->
    <div v-else-if="tasks.length === 0" class="empty-state">
      No tasks yet. Create your first task!
    </div>

    <!-- Task list -->
    <div v-else class="task-list__items">
      <TaskItem
        v-for="task in tasks"
        :key="task.id"
        :task="task"
        @toggle-complete="handleToggleComplete"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useTaskStore } from '@/stores/taskStore';
import TaskItem from './TaskItem.vue';
import type { Task } from '@/types/task';

interface Props {
  userId: string;
}

const props = defineProps<Props>();

const taskStore = useTaskStore();

const tasks = ref<Task[]>([]);
const loading = ref(true);
const error = ref<string | null>(null);

onMounted(async () => {
  try {
    loading.value = true;
    tasks.value = await taskStore.fetchUserTasks(props.userId);
    error.value = null;
  } catch (err) {
    error.value = 'Failed to load tasks';
    console.error(err);
  } finally {
    loading.value = false;
  }
});

const handleToggleComplete = async (taskId: string) => {
  try {
    await taskStore.markTaskComplete(taskId);
    tasks.value = tasks.value.map(task =>
      task.id === taskId ? { ...task, is_completed: true } : task
    );
  } catch (err) {
    error.value = 'Failed to update task';
  }
};
</script>

<style scoped lang="scss">
.task-list {
  &__items {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }
}

.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem;
}

.spinner {
  width: 2rem;
  height: 2rem;
  border: 2px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.error-message {
  background-color: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 0.5rem;
  padding: 1rem;
  color: #991b1b;
}

.empty-state {
  text-align: center;
  padding: 2rem;
  color: #6b7280;
}
</style>
```

### Example C: Angular + TypeScript

```typescript
// src/app/components/task-list/task-list.component.ts

import { Component, Input, OnInit } from '@angular/core';
import { Task } from '@/models/task.model';
import { TaskService } from '@/services/task.service';

@Component({
  selector: 'app-task-list',
  templateUrl: './task-list.component.html',
  styleUrls: ['./task-list.component.scss']
})
export class TaskListComponent implements OnInit {
  @Input() userId!: string;

  tasks: Task[] = [];
  loading = true;
  error: string | null = null;

  constructor(private taskService: TaskService) {}

  ngOnInit(): void {
    this.loadTasks();
  }

  async loadTasks(): Promise<void> {
    try {
      this.loading = true;
      this.tasks = await this.taskService.getUserTasks(this.userId);
      this.error = null;
    } catch (err) {
      this.error = 'Failed to load tasks';
      console.error(err);
    } finally {
      this.loading = false;
    }
  }

  async onToggleComplete(taskId: string): Promise<void> {
    try {
      await this.taskService.markComplete(taskId);
      this.tasks = this.tasks.map(task =>
        task.id === taskId ? { ...task, is_completed: true } : task
      );
    } catch (err) {
      this.error = 'Failed to update task';
    }
  }
}
```

```html
<!-- src/app/components/task-list/task-list.component.html -->

<div class="task-list">
  <!-- Loading state -->
  <div *ngIf="loading" class="loading-container">
    <div class="spinner"></div>
  </div>

  <!-- Error state -->
  <div *ngIf="error && !loading" class="error-message">
    {{ error }}
  </div>

  <!-- Empty state -->
  <div *ngIf="!loading && !error && tasks.length === 0" class="empty-state">
    No tasks yet. Create your first task!
  </div>

  <!-- Task list -->
  <div *ngIf="!loading && !error && tasks.length > 0" class="task-list__items">
    <app-task-item
      *ngFor="let task of tasks; trackBy: trackByTaskId"
      [task]="task"
      (toggleComplete)="onToggleComplete($event)"
    ></app-task-item>
  </div>
</div>
```

---

## Completion Report

```markdown
# Frontend Worker Report (Self-Adapting)

**Feature ID**: FEAT-002
**Feature Name**: Task Management
**Status**: ✅ COMPLETE

---

## Technology Stack (Auto-Detected)

- **Framework**: React v18.2.0
- **Language**: TypeScript
- **Styling**: Tailwind CSS v3.3.0
- **State Management**: React Context API (detected from existing code)
- **API Client**: Axios v1.4.0
- **Build Tool**: Vite v4.3.0

**Detection Method**: Analyzed package.json + existing component patterns

---

## Implementation Summary

### Components Created (4)
1. **TaskList** (`src/components/TaskList/TaskList.tsx`)
   - Displays user tasks
   - Loading/error states
   - Integration with task service

2. **TaskItem** (`src/components/TaskList/TaskItem.tsx`)
   - Individual task display
   - Checkbox for completion
   - Due date display

3. **TaskForm** (`src/components/TaskForm/TaskForm.tsx`)
   - Create new task
   - Form validation
   - Submit handling

4. **TaskFilter** (`src/components/TaskFilter/TaskFilter.tsx`)
   - Filter by status (all/active/completed)
   - Search functionality

### Pages Created (2)
1. **TasksPage** (`src/pages/TasksPage.tsx`)
   - Main tasks view
   - Integrates all components

2. **TaskDetailPage** (`src/pages/TaskDetailPage.tsx`)
   - Individual task view
   - Edit functionality

---

## Pattern Matching

✅ Followed existing patterns:
- Functional components with TypeScript
- Folder-per-component structure
- Tailwind utility classes
- `@/` import aliases
- Proper error handling with user feedback
- Loading states with spinners
- Responsive design (mobile-first)

---

## Next Steps

Frontend implementation complete. Ready for:
1. **Test Worker** - Can write component tests
2. **Integration** - Connect to backend APIs
```

---

**Status**: ✅ Design Complete
**Innovation**: Works with React, Vue, Angular, Svelte - zero templates!

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
