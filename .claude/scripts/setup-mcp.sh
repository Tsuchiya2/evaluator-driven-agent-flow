#!/bin/bash

# EDAF MCP Configuration Script
# Registers chrome-devtools MCP server using 'claude mcp add' command
# 'claude mcp add' コマンドを使用して chrome-devtools MCP サーバーを登録します

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
# 2. WSL2 Warning
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
# 3. Check if MCP server already exists
# =============================================================================
check_existing_mcp() {
  echo ""
  echo -e "${BLUE}🔍 Checking existing MCP servers... / 既存のMCPサーバーを確認中...${NC}"

  # Check .mcp.json file (project scope)
  if [ -f ".mcp.json" ] && grep -q "chrome-devtools" ".mcp.json"; then
    echo -e "${GREEN}  ✅ chrome-devtools MCP is already registered in .mcp.json${NC}"
    echo -e "${GREEN}     chrome-devtools MCP は .mcp.json に既に登録されています${NC}"
    ALREADY_EXISTS=true
  # Check claude mcp list (user/local scope)
  elif claude mcp list 2>/dev/null | grep -q "chrome-devtools"; then
    echo -e "${GREEN}  ✅ chrome-devtools MCP is already registered${NC}"
    echo -e "${GREEN}     chrome-devtools MCP は既に登録されています${NC}"
    ALREADY_EXISTS=true
  else
    echo -e "${CYAN}  ℹ️  chrome-devtools MCP is not registered${NC}"
    echo -e "${CYAN}     chrome-devtools MCP は登録されていません${NC}"
    ALREADY_EXISTS=false
  fi
}

# =============================================================================
# 4. Register MCP server using claude mcp add
# =============================================================================
register_mcp_server() {
  local scope="${1:-project}"

  echo ""
  echo -e "${BLUE}📝 Registering MCP server... / MCPサーバーを登録中...${NC}"

  # Skip for WSL2
  if [ "$WSL2_MODE" = true ]; then
    echo -e "${YELLOW}  ⏭️  Skipping MCP registration for WSL2${NC}"
    echo -e "${YELLOW}     UI verification will be disabled${NC}"
    return 0
  fi

  # Skip if already exists
  if [ "$ALREADY_EXISTS" = true ]; then
    echo -e "${CYAN}  ⏭️  Skipping - already registered${NC}"
    echo ""
    echo -e "${GREEN}Current MCP servers / 現在のMCPサーバー:${NC}"
    claude mcp list
    return 0
  fi

  # Register chrome-devtools MCP
  echo -e "${CYAN}  Running: claude mcp add -s ${scope} chrome-devtools -- npx -y chrome-devtools-mcp@latest${NC}"
  echo ""

  if claude mcp add -s "$scope" chrome-devtools -- npx -y chrome-devtools-mcp@latest; then
    echo ""
    echo -e "${GREEN}  ✅ MCP server registered successfully!${NC}"
    echo -e "${GREEN}     MCPサーバーの登録が完了しました！${NC}"
  else
    echo ""
    echo -e "${RED}  ❌ Failed to register MCP server${NC}"
    echo -e "${RED}     MCPサーバーの登録に失敗しました${NC}"
    return 1
  fi
}

# =============================================================================
# 5. Verify Configuration
# =============================================================================
verify_configuration() {
  echo ""
  echo -e "${BLUE}🔍 Verifying configuration... / 設定を確認中...${NC}"

  # Check .mcp.json file for project scope
  if [ -f ".mcp.json" ] && grep -q "chrome-devtools" ".mcp.json"; then
    echo -e "${GREEN}  ✅ chrome-devtools MCP is registered in .mcp.json${NC}"
    echo ""
    echo -e "${GREEN}Configuration / 設定内容:${NC}"
    cat .mcp.json
  # Also check claude mcp list for user/local scope
  elif claude mcp list 2>/dev/null | grep -q "chrome-devtools"; then
    echo -e "${GREEN}  ✅ chrome-devtools MCP is registered${NC}"
    echo ""
    echo -e "${GREEN}Registered MCP servers / 登録済みMCPサーバー:${NC}"
    claude mcp list
  else
    echo -e "${RED}  ❌ chrome-devtools MCP not found${NC}"
    return 1
  fi

  echo ""
  echo -e "${GREEN}✅ MCP configuration complete! / MCP設定が完了しました！${NC}"

  if [ "$WSL2_MODE" = true ]; then
    echo ""
    echo -e "${YELLOW}Note: UI verification is disabled for WSL2 environment.${NC}"
    echo -e "${YELLOW}注意: WSL2環境ではUI検証は無効になっています。${NC}"
  else
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🔄 IMPORTANT: Restart Claude Code / 重要: Claude Codeを再起動${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "MCP servers are loaded at Claude Code startup."
    echo "MCPサーバーはClaude Code起動時に読み込まれます。"
    echo ""
    echo "Please restart Claude Code to enable chrome-devtools MCP."
    echo "chrome-devtools MCPを有効にするためにClaude Codeを再起動してください。"
    echo ""
  fi
}

# =============================================================================
# Main
# =============================================================================
main() {
  # Parse arguments
  local scope="project"
  while [[ $# -gt 0 ]]; do
    case $1 in
      --scope|-s)
        scope="$2"
        shift 2
        ;;
      --user)
        scope="user"
        shift
        ;;
      --project)
        scope="project"
        shift
        ;;
      --local)
        scope="local"
        shift
        ;;
      *)
        # Ignore unknown arguments (for backward compatibility with old usage)
        shift
        ;;
    esac
  done

  detect_os
  show_wsl2_warning
  check_existing_mcp
  register_mcp_server "$scope"
  verify_configuration
}

# Run
main "$@"
