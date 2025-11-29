#!/bin/bash

# EDAF MCP Configuration Script
# Detects environment and generates appropriate .mcp.json configuration
# 環境を検出して適切な.mcp.json設定を生成します

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 EDAF MCP Configuration / MCP設定${NC}"
echo ""

# =============================================================================
# 1. Detect Operating System
# =============================================================================
detect_os() {
  case "$(uname -s)" in
    Darwin*)
      OS="mac"
      echo -e "${GREEN}✅ Detected: macOS${NC}"
      ;;
    Linux*)
      # Check for WSL
      if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then
        OS="wsl2"
        echo -e "${YELLOW}⚠️  Detected: WSL2 (Windows Subsystem for Linux)${NC}"
      else
        OS="linux"
        echo -e "${GREEN}✅ Detected: Linux${NC}"
      fi
      ;;
    CYGWIN*|MINGW*|MSYS*)
      OS="windows"
      echo -e "${GREEN}✅ Detected: Windows (Git Bash/MSYS)${NC}"
      ;;
    *)
      OS="unknown"
      echo -e "${YELLOW}⚠️  Unknown OS: $(uname -s)${NC}"
      ;;
  esac
}

# =============================================================================
# 2. Detect Node.js Package Manager Path
# =============================================================================
detect_npx_path() {
  NPX_PATH=""
  NODE_MANAGER=""

  echo ""
  echo -e "${BLUE}🔍 Detecting Node.js environment... / Node.js環境を検出中...${NC}"

  # Try to find npx using which/command -v (works on Mac/Linux)
  if [ "$OS" != "windows" ]; then
    NPX_PATH=$(which npx 2>/dev/null || command -v npx 2>/dev/null || true)
  else
    # Windows: use where command
    NPX_PATH=$(where npx 2>/dev/null | head -n 1 || true)
  fi

  if [ -n "$NPX_PATH" ]; then
    # Detect which Node version manager is being used
    case "$NPX_PATH" in
      */.nvm/*)
        NODE_MANAGER="nvm"
        ;;
      */.nodenv/*)
        NODE_MANAGER="nodenv"
        ;;
      */.asdf/*)
        NODE_MANAGER="asdf"
        ;;
      */.volta/*)
        NODE_MANAGER="volta"
        ;;
      */mise/*)
        NODE_MANAGER="mise"
        ;;
      */fnm/*)
        NODE_MANAGER="fnm"
        ;;
      */homebrew/opt/node@*)
        NODE_MANAGER="homebrew-keg"
        ;;
      */homebrew/*)
        NODE_MANAGER="homebrew"
        ;;
      */AppData/Roaming/nvm/*)
        NODE_MANAGER="nvm-windows"
        ;;
      "/usr/bin/npx"|"/usr/local/bin/npx")
        NODE_MANAGER="system"
        ;;
      *)
        NODE_MANAGER="other"
        ;;
    esac

    echo -e "${GREEN}  ✅ npx found: ${NPX_PATH}${NC}"
    echo -e "${CYAN}     Manager: ${NODE_MANAGER}${NC}"

    # Verify npx works
    if $NPX_PATH --version > /dev/null 2>&1; then
      NPX_VERSION=$($NPX_PATH --version 2>/dev/null)
      echo -e "${GREEN}     Version: ${NPX_VERSION}${NC}"
    else
      echo -e "${YELLOW}  ⚠️  npx found but not working properly${NC}"
      NPX_PATH=""
    fi
  fi

  # Also check for bunx as alternative
  BUNX_PATH=""
  if [ "$OS" != "windows" ]; then
    BUNX_PATH=$(which bunx 2>/dev/null || command -v bunx 2>/dev/null || true)
  else
    BUNX_PATH=$(where bunx 2>/dev/null | head -n 1 || true)
  fi

  if [ -n "$BUNX_PATH" ]; then
    echo -e "${CYAN}  💡 bunx also available: ${BUNX_PATH}${NC}"
    echo -e "${CYAN}     (bunx is faster than npx)${NC}"
  fi
}

# =============================================================================
# 3. WSL2 Warning
# =============================================================================
show_wsl2_warning() {
  if [ "$OS" = "wsl2" ]; then
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}⚠️  IMPORTANT: WSL2 Limitation / 重要: WSL2の制限${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}MCP chrome-devtools DOES NOT work in WSL2 environment.${NC}"
    echo -e "${YELLOW}MCP chrome-devtools は WSL2 環境では動作しません。${NC}"
    echo ""
    echo "Reason / 理由:"
    echo "  - WSL2 cannot access Chrome browser running on Windows"
    echo "  - Network isolation prevents communication with Chrome DevTools"
    echo ""
    echo "Options / オプション:"
    echo "  1. Skip UI verification in Phase 3 (recommended for WSL2)"
    echo "     Phase 3 で UI 検証をスキップ（WSL2推奨）"
    echo ""
    echo "  2. Run Claude Code on Windows directly (not in WSL2)"
    echo "     WSL2 ではなく Windows で直接 Claude Code を実行"
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Set flag for later use
    WSL2_MODE=true
  else
    WSL2_MODE=false
  fi
}

# =============================================================================
# 4. Generate .mcp.json
# =============================================================================
generate_mcp_json() {
  local target_dir="${1:-.}"
  local mcp_file="${target_dir}/.mcp.json"

  # Ensure target directory exists
  mkdir -p "$target_dir"

  echo ""
  echo -e "${BLUE}📝 Generating .mcp.json... / .mcp.jsonを生成中...${NC}"

  # Skip for WSL2
  if [ "$WSL2_MODE" = true ]; then
    echo -e "${YELLOW}  ⏭️  Skipping .mcp.json generation for WSL2${NC}"
    echo -e "${YELLOW}     UI verification will be disabled${NC}"

    # Create minimal config noting WSL2 limitation
    cat > "$mcp_file" << 'EOF'
{
  "_comment": "MCP chrome-devtools disabled - WSL2 environment detected",
  "_wsl2_warning": "Chrome DevTools MCP does not work in WSL2. UI verification is disabled.",
  "mcpServers": {}
}
EOF
    echo -e "${GREEN}  ✅ Created minimal .mcp.json (WSL2 mode)${NC}"
    return
  fi

  # Check if npx or bunx is available
  if [ -z "$NPX_PATH" ] && [ -z "$BUNX_PATH" ]; then
    echo -e "${RED}  ❌ Error: Neither npx nor bunx found${NC}"
    echo -e "${RED}     Please install Node.js or Bun first${NC}"
    echo ""
    echo "Install options / インストールオプション:"
    echo "  - Node.js: https://nodejs.org/"
    echo "  - nvm: https://github.com/nvm-sh/nvm"
    echo "  - Bun: https://bun.sh/"
    return 1
  fi

  # Prefer bunx if available (faster)
  local cmd_path="$NPX_PATH"
  local use_bunx=false

  if [ -n "$BUNX_PATH" ]; then
    echo ""
    read -p "  Use bunx instead of npx? (faster) / bunxを使用しますか？（高速） [y/N]: " use_bunx_choice
    if [[ $use_bunx_choice =~ ^[Yy]$ ]]; then
      cmd_path="$BUNX_PATH"
      use_bunx=true
    fi
  fi

  # Generate appropriate config based on OS
  if [ "$OS" = "windows" ]; then
    # Windows: escape backslashes
    cmd_path_escaped=$(echo "$cmd_path" | sed 's/\\/\\\\/g')

    cat > "$mcp_file" << EOF
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "cmd",
      "args": ["/c", "${cmd_path_escaped}", "-y", "chrome-devtools-mcp@latest"]
    }
  }
}
EOF
  else
    # Mac/Linux: use absolute path directly
    if [ "$use_bunx" = true ]; then
      cat > "$mcp_file" << EOF
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "${cmd_path}",
      "args": ["--bun", "chrome-devtools-mcp@latest"]
    }
  }
}
EOF
    else
      cat > "$mcp_file" << EOF
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "${cmd_path}",
      "args": ["-y", "chrome-devtools-mcp@latest"]
    }
  }
}
EOF
    fi
  fi

  echo -e "${GREEN}  ✅ Generated .mcp.json${NC}"
  echo ""
  echo -e "${CYAN}  Configuration / 設定:${NC}"
  cat "$mcp_file"
  echo ""
}

# =============================================================================
# 5. Verify Configuration
# =============================================================================
verify_configuration() {
  local target_dir="${1:-.}"
  local mcp_file="${target_dir}/.mcp.json"

  echo ""
  echo -e "${BLUE}🔍 Verifying configuration... / 設定を確認中...${NC}"

  if [ ! -f "$mcp_file" ]; then
    echo -e "${RED}  ❌ .mcp.json not found${NC}"
    return 1
  fi

  # Check JSON syntax
  if command -v python3 > /dev/null 2>&1; then
    if python3 -c "import json; json.load(open('$mcp_file'))" 2>/dev/null; then
      echo -e "${GREEN}  ✅ JSON syntax valid${NC}"
    else
      echo -e "${RED}  ❌ Invalid JSON syntax${NC}"
      return 1
    fi
  elif command -v node > /dev/null 2>&1; then
    if node -e "require('$mcp_file')" 2>/dev/null; then
      echo -e "${GREEN}  ✅ JSON syntax valid${NC}"
    else
      echo -e "${RED}  ❌ Invalid JSON syntax${NC}"
      return 1
    fi
  else
    echo -e "${YELLOW}  ⚠️  Cannot verify JSON (python3/node not available)${NC}"
  fi

  echo ""
  echo -e "${GREEN}✅ MCP configuration complete! / MCP設定が完了しました！${NC}"

  if [ "$WSL2_MODE" = true ]; then
    echo ""
    echo -e "${YELLOW}Note: UI verification is disabled for WSL2 environment.${NC}"
    echo -e "${YELLOW}注意: WSL2環境ではUI検証は無効になっています。${NC}"
  else
    echo ""
    echo -e "${CYAN}Next steps / 次のステップ:${NC}"
    echo "  1. Restart Claude Code / Claude Codeを再起動"
    echo "  2. The chrome-devtools MCP server will be available"
    echo "     chrome-devtools MCPサーバーが利用可能になります"
  fi
}

# =============================================================================
# Main
# =============================================================================
main() {
  local target_dir="${1:-.}"

  detect_os
  detect_npx_path
  show_wsl2_warning
  generate_mcp_json "$target_dir"
  verify_configuration "$target_dir"
}

# Run with optional target directory argument
main "$@"
