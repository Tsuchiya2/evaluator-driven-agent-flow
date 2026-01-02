#!/bin/bash
# detect-linters.sh - Detect lint tools in the project
# Part of EDAF v1.0 - Phase 4 Quality Gate

set -euo pipefail

CONFIG_FILE=".claude/edaf-config.yml"
DETECTED_TOOLS=()

echo "🔍 Detecting lint tools in project..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# ============================================
# JavaScript/TypeScript
# ============================================

if file_exists "package.json"; then
    echo "📦 Found package.json - checking Node.js linters..."

    # ESLint
    if grep -q '"eslint"' package.json 2>/dev/null; then
        if command_exists npx; then
            DETECTED_TOOLS+=("eslint:npx eslint --max-warnings 0 .")
            echo "  ✅ ESLint detected"
        fi
    fi

    # Prettier
    if grep -q '"prettier"' package.json 2>/dev/null; then
        if command_exists npx; then
            DETECTED_TOOLS+=("prettier:npx prettier --check .")
            echo "  ✅ Prettier detected"
        fi
    fi

    # TypeScript
    if grep -q '"typescript"' package.json 2>/dev/null; then
        if command_exists npx; then
            DETECTED_TOOLS+=("tsc:npx tsc --noEmit")
            echo "  ✅ TypeScript compiler detected"
        fi
    fi
fi

# ============================================
# Python
# ============================================

# Ruff (modern all-in-one linter)
if file_exists "pyproject.toml" && grep -q '\[tool.ruff\]' pyproject.toml 2>/dev/null; then
    if command_exists ruff; then
        DETECTED_TOOLS+=("ruff:ruff check .")
        echo "  ✅ Ruff detected"
    fi
fi

# Black
if file_exists "pyproject.toml" && grep -q '\[tool.black\]' pyproject.toml 2>/dev/null; then
    if command_exists black; then
        DETECTED_TOOLS+=("black:black --check .")
        echo "  ✅ Black detected"
    fi
fi

# Flake8
if file_exists ".flake8" || file_exists "setup.cfg"; then
    if command_exists flake8; then
        DETECTED_TOOLS+=("flake8:flake8 .")
        echo "  ✅ Flake8 detected"
    fi
fi

# mypy
if file_exists "mypy.ini" || (file_exists "pyproject.toml" && grep -q '\[tool.mypy\]' pyproject.toml 2>/dev/null); then
    if command_exists mypy; then
        DETECTED_TOOLS+=("mypy:mypy .")
        echo "  ✅ mypy detected"
    fi
fi

# pylint
if file_exists ".pylintrc" || (file_exists "pyproject.toml" && grep -q '\[tool.pylint\]' pyproject.toml 2>/dev/null); then
    if command_exists pylint; then
        DETECTED_TOOLS+=("pylint:pylint **/*.py")
        echo "  ✅ pylint detected"
    fi
fi

# ============================================
# Go
# ============================================

if file_exists "go.mod"; then
    echo "🐹 Found go.mod - checking Go linters..."

    # golangci-lint
    if command_exists golangci-lint; then
        DETECTED_TOOLS+=("golangci-lint:golangci-lint run")
        echo "  ✅ golangci-lint detected"
    fi

    # gofmt (standard)
    if command_exists gofmt; then
        DETECTED_TOOLS+=("gofmt:gofmt -l .")
        echo "  ✅ gofmt detected"
    fi
fi

# ============================================
# Rust
# ============================================

if file_exists "Cargo.toml"; then
    echo "🦀 Found Cargo.toml - checking Rust linters..."

    if command_exists cargo; then
        DETECTED_TOOLS+=("rustfmt:cargo fmt --check")
        DETECTED_TOOLS+=("clippy:cargo clippy -- -D warnings")
        echo "  ✅ rustfmt and clippy detected"
    fi
fi

# ============================================
# Ruby
# ============================================

if file_exists "Gemfile"; then
    echo "💎 Found Gemfile - checking Ruby linters..."

    # Check if rubocop is in Gemfile
    if grep -q 'rubocop' Gemfile 2>/dev/null; then
        if command_exists bundle; then
            DETECTED_TOOLS+=("rubocop:bundle exec rubocop")
            echo "  ✅ RuboCop detected (via Bundler)"
        elif command_exists rubocop; then
            DETECTED_TOOLS+=("rubocop:rubocop")
            echo "  ✅ RuboCop detected"
        fi
    fi
elif file_exists ".rubocop.yml"; then
    if command_exists rubocop; then
        DETECTED_TOOLS+=("rubocop:rubocop")
        echo "  ✅ RuboCop detected"
    fi
fi

# ============================================
# PHP
# ============================================

if file_exists "composer.json"; then
    if command_exists phpcs; then
        DETECTED_TOOLS+=("phpcs:phpcs")
        echo "  ✅ PHP_CodeSniffer detected"
    fi

    if command_exists phpstan; then
        DETECTED_TOOLS+=("phpstan:phpstan analyse")
        echo "  ✅ PHPStan detected"
    fi
fi

# ============================================
# Save to config
# ============================================

echo ""
if [ ${#DETECTED_TOOLS[@]} -eq 0 ]; then
    echo "⚠️  No lint tools detected in this project"
    echo "   Phase 3 will complete without lint checks"

    # Update config
    if ! grep -q "^linters:" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "\nlinters:\n  enabled: false\n  tools: []" >> "$CONFIG_FILE"
    fi
else
    echo "✅ Detected ${#DETECTED_TOOLS[@]} lint tool(s)"

    # Update config
    {
        if grep -q "^linters:" "$CONFIG_FILE" 2>/dev/null; then
            # Remove existing linters section
            sed -i.bak '/^linters:/,/^[a-z_]*:/{ /^linters:/d; /^[a-z_]*:/!d; }' "$CONFIG_FILE"
        fi

        echo ""
        echo "linters:"
        echo "  enabled: true"
        echo "  tools:"
        for tool in "${DETECTED_TOOLS[@]}"; do
            IFS=':' read -r name command <<< "$tool"
            echo "    - name: $name"
            echo "      command: $command"
        done
    } >> "$CONFIG_FILE"

    echo "📝 Configuration saved to $CONFIG_FILE"
fi

echo ""
echo "✅ Lint detection complete"
