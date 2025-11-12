#!/bin/bash

# EDAF (Evaluator-Driven Agent Flow) v1.0 - Installation Script
# Self-Adapting Workers and Evaluators
# Version: 1.0.0

set -e

echo "🚀 EDAF v1.0 - Self-Adapting System Installation / 自己適応型システム インストール"
echo ""

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Detect EDAF directory name
EDAF_DIR="evaluator-driven-agent-flow"

if [ ! -d "$EDAF_DIR" ]; then
  echo -e "${RED}❌ Error: EDAF directory not found / エラー: EDAFディレクトリが見つかりません${NC}"
  echo ""
  echo "Please run this script from your project root (parent of EDAF directory)."
  echo "プロジェクトルート（EDAFディレクトリの親ディレクトリ）からこのスクリプトを実行してください。"
  echo ""
  echo "Example / 例:"
  echo "  cd my-project"
  echo "  git clone https://github.com/Tsuchiya2/evaluator-driven-agent-flow.git"
  echo "  bash evaluator-driven-agent-flow/scripts/install.sh"
  exit 1
fi

echo -e "${BLUE}📂 Working directory / 作業ディレクトリ:${NC} $(pwd)"
echo ""

# 2. Check if Claude Code is installed
if ! command -v claude &> /dev/null; then
  echo -e "${YELLOW}⚠️  Warning: Claude Code CLI not found / 警告: Claude Code CLIが見つかりません${NC}"
  echo ""
  echo "Install Claude Code from / Claude Codeをインストール:"
  echo "  https://claude.com/claude-code"
  echo ""
  read -p "Continue anyway? / このまま続けますか？ (y/N): " continue_without_claude
  if [[ ! $continue_without_claude =~ ^[Yy]$ ]]; then
    echo -e "${RED}❌ Installation cancelled / インストールをキャンセルしました${NC}"
    exit 1
  fi
fi

# 3. Create .claude directory structure
echo -e "${BLUE}📦 Creating .claude directory structure... / .claudeディレクトリ構造を作成中...${NC}"
mkdir -p .claude/agents
mkdir -p .claude/evaluators
mkdir -p .claude/commands
mkdir -p .claude/scripts
mkdir -p .claude/sounds

# 4. Copy Agents (Workers + Designer + Planner)
echo -e "${BLUE}📋 Installing Agents... / エージェントをインストール中...${NC}"
if [ -d "$EDAF_DIR/.claude/agents" ]; then
  cp $EDAF_DIR/.claude/agents/*.md .claude/agents/
  echo -e "${GREEN}  ✅ Installed 6 Agents (4 Workers + Designer + Planner) / 6つのエージェント（4ワーカー + デザイナー + プランナー）をインストールしました${NC}"
else
  echo -e "${RED}  ❌ Error: Agents not found / エラー: エージェントが見つかりません${NC}"
  exit 1
fi

# 5. Copy All Evaluators (26 total)
echo -e "${BLUE}📋 Installing Evaluators... / エバリュエーターをインストール中...${NC}"
if [ -d "$EDAF_DIR/.claude/evaluators" ]; then
  cp $EDAF_DIR/.claude/evaluators/*.md .claude/evaluators/
  echo -e "${GREEN}  ✅ Installed 26 Evaluators / 26個のエバリュエーターをインストールしました${NC}"
  echo -e "${GREEN}     - Phase 1: 7 Design Evaluators / フェーズ1: 7つのデザインエバリュエーター${NC}"
  echo -e "${GREEN}     - Phase 2.5: 7 Planner Evaluators / フェーズ2.5: 7つのプランナーエバリュエーター${NC}"
  echo -e "${GREEN}     - Phase 3: 7 Code Evaluators / フェーズ3: 7つのコードエバリュエーター${NC}"
  echo -e "${GREEN}     - Phase 4: 5 Deployment Evaluators / フェーズ4: 5つのデプロイエバリュエーター${NC}"
else
  echo -e "${RED}  ❌ Error: Evaluators not found / エラー: エバリュエーターが見つかりません${NC}"
  exit 1
fi

# 6. Copy /setup command
echo -e "${BLUE}📋 Installing /setup command... / /setupコマンドをインストール中...${NC}"
if [ -f "$EDAF_DIR/.claude/commands/setup.md" ]; then
  cp $EDAF_DIR/.claude/commands/setup.md .claude/commands/setup.md
  echo -e "${GREEN}  ✅ /setup command installed / /setupコマンドをインストールしました${NC}"
else
  echo -e "${YELLOW}  ⚠️  Warning: setup.md not found (skipped) / 警告: setup.mdが見つかりません（スキップ）${NC}"
fi

# 7. Copy scripts (notification + frontmatter injection)
echo -e "${BLUE}📋 Installing scripts... / スクリプトをインストール中...${NC}"
if [ -d "$EDAF_DIR/.claude/scripts" ]; then
  cp -r $EDAF_DIR/.claude/scripts/* .claude/scripts/
  chmod +x .claude/scripts/*.sh 2>/dev/null
  echo -e "${GREEN}  ✅ Scripts installed / スクリプトをインストールしました${NC}"
  echo -e "${GREEN}     - notification.sh (Sound notifications / 音声通知)${NC}"
  echo -e "${GREEN}     - add-frontmatter.sh (Agent configuration / エージェント設定)${NC}"
fi

if [ -d "$EDAF_DIR/.claude/sounds" ]; then
  cp -r $EDAF_DIR/.claude/sounds/* .claude/sounds/
  echo -e "${GREEN}  ✅ Sound files installed / 音声ファイルをインストールしました${NC}"
fi

# 8. Copy configuration example (optional)
echo -e "${BLUE}📋 Installing configuration template... / 設定テンプレートをインストール中...${NC}"
if [ -f "$EDAF_DIR/.claude/edaf-config.example.yml" ]; then
  if [ ! -f ".claude/edaf-config.yml" ]; then
    cp $EDAF_DIR/.claude/edaf-config.example.yml .claude/edaf-config.example.yml
    echo -e "${GREEN}  ✅ Configuration template installed / 設定テンプレートをインストールしました${NC}"
    echo -e "${YELLOW}  💡 Optional: Copy to .claude/edaf-config.yml to customize / オプション: .claude/edaf-config.ymlにコピーしてカスタマイズできます${NC}"
  else
    echo -e "${YELLOW}  ⚠️  .claude/edaf-config.yml already exists (skipped) / .claude/edaf-config.ymlはすでに存在します（スキップ）${NC}"
  fi
fi

# 8.5. Copy settings.json with hooks for notifications
echo -e "${BLUE}📋 Installing Claude Code settings with hooks... / フック付きClaude Code設定をインストール中...${NC}"
if [ -f "$EDAF_DIR/.claude/settings.json.example" ]; then
  if [ ! -f ".claude/settings.json" ]; then
    cp $EDAF_DIR/.claude/settings.json.example .claude/settings.json
    echo -e "${GREEN}  ✅ settings.json installed with notification hooks / 通知フック付きsettings.jsonをインストールしました${NC}"
  else
    echo -e "${YELLOW}  ⚠️  .claude/settings.json already exists (skipped) / .claude/settings.jsonはすでに存在します（スキップ）${NC}"
  fi
fi

# 9. Create docs directories for UI verification
echo -e "${BLUE}📁 Creating docs directories... / docsディレクトリを作成中...${NC}"
mkdir -p docs/reports
mkdir -p docs/screenshots
echo -e "${GREEN}  ✅ Created docs/reports and docs/screenshots / docs/reportsとdocs/screenshotsを作成しました${NC}"

echo ""
echo -e "${GREEN}✅ Installation complete! / インストール完了！${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 What was installed / インストールされたもの${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 .claude/agents/ (6 total)"
echo "  ├── 4 Worker Agents (Self-Adapting)"
echo "  │   ├── database-worker-v1-self-adapting.md"
echo "  │   ├── backend-worker-v1-self-adapting.md"
echo "  │   ├── frontend-worker-v1-self-adapting.md"
echo "  │   └── test-worker-v1-self-adapting.md"
echo "  ├── designer.md (Phase 1)"
echo "  └── planner.md (Phase 2)"
echo ""
echo "📁 .claude/evaluators/ (26 total)"
echo "  ├── Phase 1: Design Evaluators (7)"
echo "  │   ├── design-consistency-evaluator.md"
echo "  │   ├── design-extensibility-evaluator.md"
echo "  │   ├── design-goal-alignment-evaluator.md"
echo "  │   ├── design-maintainability-evaluator.md"
echo "  │   ├── design-observability-evaluator.md"
echo "  │   ├── design-reliability-evaluator.md"
echo "  │   └── design-reusability-evaluator.md"
echo "  │"
echo "  ├── Phase 2.5: Planner Evaluators (7)"
echo "  │   ├── planner-clarity-evaluator.md"
echo "  │   ├── planner-deliverable-structure-evaluator.md"
echo "  │   ├── planner-dependency-evaluator.md"
echo "  │   ├── planner-goal-alignment-evaluator.md"
echo "  │   ├── planner-granularity-evaluator.md"
echo "  │   ├── planner-responsibility-alignment-evaluator.md"
echo "  │   └── planner-reusability-evaluator.md"
echo "  │"
echo "  ├── Phase 3: Code Evaluators (7 - Self-Adapting)"
echo "  │   ├── code-quality-evaluator-v1-self-adapting.md"
echo "  │   ├── code-testing-evaluator-v1-self-adapting.md"
echo "  │   ├── code-security-evaluator-v1-self-adapting.md"
echo "  │   ├── code-documentation-evaluator-v1-self-adapting.md"
echo "  │   ├── code-maintainability-evaluator-v1-self-adapting.md"
echo "  │   ├── code-performance-evaluator-v1-self-adapting.md"
echo "  │   └── code-implementation-alignment-evaluator-v1-self-adapting.md"
echo "  │"
echo "  └── Phase 4: Deployment Evaluators (5)"
echo "      ├── deployment-readiness-evaluator.md"
echo "      ├── production-security-evaluator.md"
echo "      ├── observability-evaluator.md"
echo "      ├── performance-benchmark-evaluator.md"
echo "      └── rollback-plan-evaluator.md"
echo ""
echo "📁 .claude/commands/"
echo "  └── setup.md (Interactive setup wizard / インタラクティブセットアップウィザード)"
echo ""
echo "📁 .claude/scripts/"
echo "  └── notification.sh (Sound notification system / 音声通知システム)"
echo ""
echo "📁 .claude/sounds/"
echo "  ├── cat-meowing.mp3"
echo "  └── bird_song_robin.mp3"
echo ""
echo "📁 .claude/edaf-config.example.yml (optional / オプション)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🚀 Next Steps / 次のステップ${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT: Restart Claude Code to load /setup command${NC}"
echo -e "${YELLOW}⚠️  重要: /setupコマンドを読み込むためにClaude Codeを再起動してください${NC}"
echo ""
echo "1. Restart Claude Code / Claude Codeを再起動:"
echo -e "   ${BLUE}# If Claude Code is running, exit it first / 実行中の場合は終了してから${NC}"
echo -e "   ${BLUE}claude${NC}  # Start Claude Code / Claude Codeを起動"
echo ""
echo "2. Run interactive setup (recommended) / インタラクティブセットアップを実行（推奨）:"
echo -e "   ${BLUE}/setup${NC}  # Inside Claude Code / Claude Code内で実行"
echo ""
echo "3. (Optional) Remove the installation directory / （オプション）インストールディレクトリを削除:"
echo -e "   ${BLUE}rm -rf $EDAF_DIR${NC}"
echo ""
echo "4. (Optional) Customize configuration / （オプション）設定をカスタマイズ:"
echo -e "   ${BLUE}cp .claude/edaf-config.example.yml .claude/edaf-config.yml${NC}"
echo -e "   ${BLUE}vim .claude/edaf-config.yml${NC}"
echo ""
echo "5. Start using EDAF / EDAFを使い始める:"
echo "   - Workers automatically detect your language/framework"
echo "     ワーカーは言語/フレームワークを自動検出します"
echo "   - Evaluators automatically detect your tools"
echo "     エバリュエーターはツールを自動検出します"
echo "   - No configuration needed for most projects!"
echo "     ほとんどのプロジェクトで設定不要です！"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${YELLOW}💡 Quick Start / クイックスタート${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Supported languages (auto-detected) / サポート言語（自動検出）:"
echo "  ✅ TypeScript/JavaScript"
echo "  ✅ Python"
echo "  ✅ Java"
echo "  ✅ Go"
echo "  ✅ Rust"
echo "  ✅ Ruby"
echo "  ✅ PHP"
echo "  ✅ C#, Kotlin, Swift"
echo ""
echo "Supported frameworks (50+) / サポートフレームワーク（50以上）:"
echo "  - Express, FastAPI, Spring Boot, Gin, Django, Flask"
echo "  - React, Vue, Angular, Svelte"
echo "  - Sequelize, TypeORM, Prisma, SQLAlchemy, Hibernate"
echo "  - Jest, pytest, JUnit, Go test"
echo ""
echo "For more information / 詳細情報:"
echo "  - Workers / ワーカー: .claude/agents/"
echo "  - Evaluators / エバリュエーター: .claude/evaluators/"
echo "  - GitHub: https://github.com/Tsuchiya2/evaluator-driven-agent-flow"
echo ""
