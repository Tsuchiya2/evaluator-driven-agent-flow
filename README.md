# EDAF (Evaluator-Driven Agent Flow) - 自己適応型AIコード生成システム

![Version](https://img.shields.io/badge/version-1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-production%20ready-brightgreen)

## プロジェクト概要

**EDAF**は、AIによるコード生成の品質を自動的に評価・保証する**7フェーズ開発フレームワーク**です。

### 解決する課題

AIコード生成ツール（GitHub Copilot、ChatGPT等）は便利ですが、以下の課題があります：

- 生成されたコードの品質が不安定
- セキュリティ脆弱性のチェックが不十分
- プロジェクトの既存コードスタイルとの整合性がない
- 設計・要件との乖離

**EDAF**はこれらの課題を、**9つの専門エージェント**と**40の評価者**による多層的な品質ゲートで解決します。

---

## 主な機能・特徴

### 1. 7フェーズ品質ゲートシステム

```mermaid
graph LR
    Start([ユーザー要求]) --> Phase1[Phase 1<br/>要件定義]
    Phase1 --> Phase2[Phase 2<br/>設計]
    Phase2 --> Phase3[Phase 3<br/>計画]
    Phase3 --> Phase4[Phase 4<br/>実装]
    Phase4 --> Phase5[Phase 5<br/>コードレビュー]
    Phase5 --> Phase6[Phase 6<br/>ドキュメント]
    Phase6 --> Phase7[Phase 7<br/>デプロイ検証]
    Phase7 --> End([本番環境])
```

| フェーズ | 内容 | エージェント | 評価者数 |
|---------|------|-------------|---------|
| Phase 1 | 要件定義 | Requirements Gatherer | 7 |
| Phase 2 | 設計 | Designer | 7 |
| Phase 3 | タスク計画 | Planner | 7 |
| Phase 4 | 実装 | 4 Workers | 1 (Quality Gate) |
| Phase 5 | コードレビュー | - | 8 + UI検証 |
| Phase 6 | ドキュメント | Documentation Worker | 5 |
| Phase 7 | デプロイ検証 | - | 5 |

**合計: 9エージェント + 40評価者 = 49コンポーネント**

### 2. 自己適応型アーキテクチャ

プロジェクトの技術スタックを**自動検出**し、適切なツール・パターンを選択します。

```
Layer 1: 自動検出
  ├─ package.json / requirements.txt / go.mod 等を読み取り
  ├─ 言語・フレームワーク・ORM・ツールを検出
  └─ 既存のコードパターンを分析
     ↓
Layer 2: 設定ファイル（必要に応じて）
  └─ .claude/edaf-config.yml から明示的な設定を読み込み
     ↓
Layer 3: ユーザー対話（フォールバック）
  └─ 検出できない場合は対話的に確認
```

### 3. 多言語・マルチフレームワーク対応

**対応言語（11言語）:**
TypeScript, JavaScript, Python, Java, Go, Rust, Ruby, PHP, C#, Kotlin, Swift

**対応フレームワーク（50以上）:**
- **バックエンド**: Express, FastAPI, Spring Boot, Gin, Django, Flask, NestJS, Rails, Laravel, ASP.NET
- **フロントエンド**: React, Vue, Angular, Svelte, Solid, Next.js, Nuxt, SvelteKit
- **ORM**: Sequelize, TypeORM, Prisma, Django ORM, SQLAlchemy, Hibernate, GORM, ActiveRecord
- **テスト**: Jest, Vitest, pytest, JUnit, Go test, RSpec, PHPUnit, Playwright, Cypress

### 4. 自動UI/UX検証

フロントエンド変更時、**Claude in Chrome**を使用してブラウザ上で自動的にUI検証を実行します。

### 5. 日本語・英語対応

ドキュメントとターミナル出力の言語を柔軟に設定可能：
- 英語ドキュメント + 英語出力
- 日本語ドキュメント + 日本語出力
- 英語ドキュメント + 日本語出力（学習モード）

---

## 技術的なアーキテクチャ

### エージェント構成

```
.claude/agents/
├── requirements-gatherer.md       # 要件収集エージェント
├── designer.md                    # 設計エージェント（Opus使用）
├── planner.md                     # 計画エージェント
├── workers/
│   ├── database-worker-v1-self-adapting.md   # DB実装
│   ├── backend-worker-v1-self-adapting.md    # API実装
│   ├── frontend-worker-v1-self-adapting.md   # UI実装
│   ├── test-worker-v1-self-adapting.md       # テスト実装
│   ├── documentation-worker.md               # ドキュメント更新
│   └── ui-verification-worker.md             # UI検証
└── evaluators/
    ├── phase1-requirements/  # 要件評価（7種）
    ├── phase2-design/        # 設計評価（7種）
    ├── phase3-planner/       # 計画評価（7種）
    ├── phase4-quality-gate/  # 品質ゲート（1種）
    ├── phase5-code/          # コード評価（8種）
    ├── phase6-documentation/ # ドキュメント評価（5種）
    └── phase7-deployment/    # デプロイ評価（5種）
```

### モデル選択戦略

タスクの重要度に応じて最適なモデルを選択：

| モデル | 用途 | 使用エージェント |
|--------|------|-----------------|
| **Opus** | 重要な設計判断、セキュリティ分析 | Designer, セキュリティ評価者 |
| **Sonnet** | 標準的なコード生成・分析 | Planner, Workers, 主要評価者 |
| **Haiku** | パターンマッチング、チェックリスト | シンプルな評価者 |

### 評価フレームワーク

各評価者は10点満点でスコアリング：
- **8.0以上**: 合格（次フェーズへ進行）
- **8.0未満**: 不合格（フィードバックに基づき修正・再評価）

評価観点：
- **コード品質**: 型安全性、Lintエラー、複雑度
- **テスト**: カバレッジ、テスト品質、モック戦略
- **セキュリティ**: OWASP Top 10、依存関係脆弱性、認証・認可
- **保守性**: 結合度、責務分離、技術的負債
- **パフォーマンス**: アルゴリズム効率、N+1問題、メモリ使用量

---

## 実装の工夫点

### 1. 並列評価によるパフォーマンス最適化

複数の評価者を並列実行し、評価時間を短縮：

```typescript
// 7つの評価者を並列実行
Task({ subagent_type: "requirements-clarity-evaluator", ... })
Task({ subagent_type: "requirements-completeness-evaluator", ... })
Task({ subagent_type: "requirements-feasibility-evaluator", ... })
// ... 他4つも同時実行
```

### 2. サンドボックス実行

評価者は安全なサンドボックス環境で実行し、破壊的な操作を防止：

```json
{
  "sandbox": {
    "enabled": true,
    "excludedCommands": ["git push", "rm -rf"]
  }
}
```

### 3. フィードバックループ

評価に失敗した場合、具体的なフィードバックに基づいて修正し、全評価者を再実行：

```
実行 → 評価 → 失敗
  ↓
フィードバック読み取り
  ↓
修正
  ↓
全評価者を再実行（失敗したものだけでなく）
  ↓
全て合格まで繰り返し
```

---

## 使用方法

### インストール

```bash
# 1. 既存プロジェクトにクローン
cd /path/to/your/project
git clone https://github.com/Tsuchiya2/evaluator-driven-agent-flow.git

# 2. インストールスクリプト実行
bash evaluator-driven-agent-flow/scripts/install.sh

# 3. Claude Code再起動
claude

# 4. 対話的セットアップ
/setup
```

### 使用例

```bash
# 完全なEDAFワークフロー（推奨）
"ユーザー認証機能をEDAFワークフローで実装してください"

# 個別Workerの使用（クイック実装）
"database-workerでUserモデルを作成してください"
"backend-workerでREST APIを生成してください"
```

---

## 動作環境

| 環境 | 対応状況 | UI検証 |
|------|---------|--------|
| macOS | ✅ 完全対応 | ✅ 自動 |
| Windows | ✅ 完全対応 | ✅ 自動 |
| Linux | ✅ 完全対応 | ✅ 自動 |
| WSL2 | ✅ 完全対応 | ✅ 自動 |

**必要条件:**
- Claude Code CLI
- Git
- Node.js

---

## プロジェクト構成

```
.claude/
├── agents/           # エージェント定義（9種）
│   ├── workers/      # ワーカーエージェント（6種）
│   └── evaluators/   # 評価エージェント（40種）
├── skills/           # スキル定義
│   ├── edaf-orchestration/  # フェーズワークフロー
│   ├── edaf-evaluation/     # 評価フレームワーク
│   └── setup/               # セットアップウィザード
├── scripts/          # ユーティリティスクリプト
├── sounds/           # 通知サウンド
└── CLAUDE.md         # Claude Code設定
```

---

## サウンドアセットの帰属

EDAFは通知用に以下のサウンドファイルを使用しています：

### cat-meowing.mp3
- **出典**: [Chosic](https://www.chosic.com/download-audio/54581/)
- **ライセンス**: CC0（パブリックドメイン）
- **用途**: エラー通知・注意喚起

### bird_song_robin.mp3
- **出典**: [BigSoundBank - European Robin Single Call](https://bigsoundbank.com/robin-1-s1667.html)
- **ライセンス**: 帰属表示により個人・商用利用可
- **用途**: タスク完了通知

**注記**: すべてのサウンドファイルは `.claude/sounds/` に配置され、各ライセンスに従って使用しています。

---

## ライセンス

MIT License

---

## 連絡先

- GitHub: [Tsuchiya2](https://github.com/Tsuchiya2)
- Issues: [GitHub Issues](https://github.com/Tsuchiya2/evaluator-driven-agent-flow/issues)

---

**ステータス**: 本番運用可能
