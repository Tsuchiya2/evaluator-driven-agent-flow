# Screenshot Naming & Storage Guide

**Purpose**: Standardized conventions for UI verification screenshots

---

## Directory Structure

```
docs/
└── screenshots/
    └── {feature-name}/
        ├── 00-login-page.png
        ├── 01-login-page-filled.png
        ├── 02-login-success.png
        ├── 03-dashboard.png
        ├── 04-dashboard-menu-open.png
        ├── 05-profile-page.png
        └── 06-profile-page-updated.png
```

---

## Naming Convention

### Format

```
{sequence}-{page-name}[-{action}].png
```

### Components

| Component | Format | Examples |
|-----------|--------|----------|
| Sequence | 2-digit number | `00`, `01`, `02` |
| Page Name | kebab-case | `login-page`, `dashboard`, `user-profile` |
| Action | kebab-case (optional) | `filled`, `submitted`, `menu-open` |

### Examples

| Screenshot | Name |
|------------|------|
| Initial login page | `00-login-page.png` |
| Login form filled | `01-login-page-filled.png` |
| After login redirect | `02-login-success.png` |
| Dashboard view | `03-dashboard.png` |
| Dashboard with menu open | `04-dashboard-menu-open.png` |
| Form validation error | `05-form-validation-error.png` |
| Success message | `06-success-message.png` |

---

## Feature Name Convention

Use the same slug as design documents:

| Feature | Slug | Directory |
|---------|------|-----------|
| User Authentication | `user-authentication` | `docs/screenshots/user-authentication/` |
| Task Management | `task-management` | `docs/screenshots/task-management/` |
| Payment Integration | `payment-integration` | `docs/screenshots/payment-integration/` |

---

## Required Screenshots

### Minimum Requirements

Every UI verification MUST include:

1. **One screenshot per modified page** (initial state)
2. **One screenshot per form submission** (after submit)
3. **One screenshot per navigation action** (after navigation)

### Recommended Screenshots

For comprehensive verification:

| Scenario | Screenshots |
|----------|-------------|
| Login Flow | login-page, login-filled, login-success |
| Form Submission | form-empty, form-filled, form-submitted, form-success |
| CRUD Operations | list-view, create-form, edit-form, delete-confirm |
| Navigation | current-page, destination-page |
| Error States | error-state, error-message |
| Responsive | mobile-view, tablet-view, desktop-view |

---

## Screenshot Quality

### Resolution

- **Minimum**: 1280x720 (HD)
- **Recommended**: 1920x1080 (Full HD)
- **Mobile**: 375x667 (iPhone SE) or 390x844 (iPhone 14)

### Format

- **Format**: PNG (lossless)
- **Color**: Full color (24-bit)
- **Compression**: Default (balanced)

---

## Report Integration

### Markdown Reference

```markdown
## Login Page Verification

### Initial State
![Login Page](../screenshots/user-authentication/00-login-page.png)

### Filled Form
![Login Filled](../screenshots/user-authentication/01-login-page-filled.png)

### Success State
![Login Success](../screenshots/user-authentication/02-login-success.png)
```

### Relative Paths

From `docs/reports/phase3-ui-verification-{feature}.md`:

```markdown
![Screenshot](../screenshots/{feature-name}/{screenshot-name}.png)
```

From `docs/designs/{feature}.md`:

```markdown
![Screenshot](../screenshots/{feature-name}/{screenshot-name}.png)
```

---

## Screenshot Index Template

Include this at the end of verification reports:

```markdown
## Screenshot Index

All screenshots saved to: `docs/screenshots/{feature-name}/`

| # | Filename | Description |
|---|----------|-------------|
| 1 | 00-login-page.png | Login page initial state |
| 2 | 01-login-page-filled.png | Login form with credentials |
| 3 | 02-login-success.png | Dashboard after successful login |
| 4 | 03-dashboard.png | Main dashboard view |
| 5 | 04-dashboard-profile.png | Profile dropdown open |
```

---

## Cleanup

### After Feature Completion

Screenshots are kept for:
- Code review reference
- Documentation
- Regression testing baseline

### Archival

After feature is merged and deployed:

```bash
# Option 1: Keep for reference (recommended)
# Screenshots remain in docs/screenshots/

# Option 2: Archive to separate location
mv docs/screenshots/{feature-name} archive/screenshots/

# Option 3: Remove (if space is concern)
rm -rf docs/screenshots/{feature-name}
```

---

## Automation Script

Create screenshots directory automatically:

```bash
#!/bin/bash
# .claude/scripts/create-screenshot-dir.sh

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: create-screenshot-dir.sh <feature-name>"
  exit 1
fi

mkdir -p "docs/screenshots/${FEATURE_NAME}"
echo "✅ Created: docs/screenshots/${FEATURE_NAME}/"
```

---

## Verification

Run verification script to check screenshots:

```bash
bash .claude/scripts/verify-ui.sh {feature-name}
```

**Checks:**
- Directory exists
- At least 1 screenshot per modified page
- All screenshots are valid PNG files
- Report references existing screenshots
