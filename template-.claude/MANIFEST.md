# テンプレートマニフェスト

このファイルはテンプレートの分類情報を管理します。
`deploy-to-project.sh` がこのファイルを参照して選択的デプロイを行います。

---

## 分類基準

### レベル (level)

| レベル | 説明 |
|--------|------|
| `beginner` | 即座に活用可能。設定不要 |
| `intermediate` | 軽微な設定が必要。テストフレームワーク等の前提あり |
| `advanced` | カスタムセットアップが必要。学習システム等 |

### タイプ (type)

| タイプ | 説明 |
|--------|------|
| `general` | どのプロジェクトでも使用可能 |
| `web` | Web開発固有（React, Next.js, E2E等） |
| `excluded` | 除外対象（言語/DB固有） |

### アドオン (addon)

| アドオン | 説明 |
|---------|------|
| `-` | アドオンなし（level/type のみでフィルタ） |
| `learning` | 自己学習・進化（eval, instinct, continuous-learning 等） |
| `multi-model` | マルチAI連携（orchestrate, multi-* 等） |
| `infra` | 基盤・運用ツール（codemaps, pm2, sessions 等） |

---

## Agents

| ファイル | レベル | タイプ | 説明 | アドオン |
|----------|--------|--------|------|---------|
| `planner.md` | beginner | general | 実装計画立案 | - |
| `code-reviewer.md` | beginner | general | コードレビュー | - |
| `refactor-cleaner.md` | beginner | general | リファクタリング | - |
| `architect.md` | intermediate | general | アーキテクチャ設計 | - |
| `doc-updater.md` | intermediate | general | ドキュメント更新 | - |
| `tdd-guide.md` | intermediate | general | TDDガイド | - |
| `build-error-resolver.md` | intermediate | general | ビルドエラー解決 | - |
| `security-reviewer.md` | intermediate | general | セキュリティレビュー | - |
| `chief-of-staff.md` | intermediate | general | コミュニケーショントリアージ | - |
| `docs-lookup.md` | intermediate | general | ドキュメント検索 | - |
| `performance-optimizer.md` | intermediate | general | パフォーマンス最適化 | - |
| `typescript-reviewer.md` | intermediate | general | TypeScript レビュー | - |
| `e2e-runner.md` | intermediate | web | E2Eテスト実行 | - |
| `harness-optimizer.md` | advanced | general | ハーネス最適化 | learning |
| `loop-operator.md` | advanced | general | 自律ループオペレーター | - |
| `opensource-forker.md` | advanced | general | OSS フォーク準備 | - |
| `opensource-packager.md` | advanced | general | OSS パッケージング | - |
| `opensource-sanitizer.md` | advanced | general | OSS サニタイズ検証 | - |

---

## Commands

| ファイル | レベル | タイプ | 説明 | アドオン |
|----------|--------|--------|------|---------|
| `plan.md` | beginner | general | 計画作成 | - |
| `verify.md` | beginner | general | 検証 | - |
| `code-review.md` | beginner | general | コードレビュー | - |
| `refactor-clean.md` | beginner | general | リファクタリング | - |
| `tdd.md` | intermediate | general | TDD実行 | - |
| `build-fix.md` | intermediate | general | ビルド修正 | - |
| `test-coverage.md` | intermediate | general | テストカバレッジ | - |
| `checkpoint.md` | intermediate | general | チェックポイント | - |
| `update-docs.md` | intermediate | general | ドキュメント更新 | - |
| `aside.md` | intermediate | general | サイドタスク実行 | - |
| `context-budget.md` | intermediate | general | コンテキスト予算管理 | - |
| `docs.md` | intermediate | general | ドキュメント参照 | - |
| `projects.md` | intermediate | general | プロジェクト管理 | - |
| `prune.md` | intermediate | general | 不要コード削除 | - |
| `quality-gate.md` | intermediate | general | 品質ゲートチェック | - |
| `promote.md` | intermediate | general | プロモート | - |
| `prompt-optimize.md` | intermediate | general | プロンプト最適化 | - |
| `prp-commit.md` | intermediate | general | PRPコミット | - |
| `prp-implement.md` | intermediate | general | PRP実装 | - |
| `prp-plan.md` | intermediate | general | PRP計画 | - |
| `prp-pr.md` | intermediate | general | PRP PR作成 | - |
| `prp-prd.md` | intermediate | general | PRP PRD作成 | - |
| `e2e.md` | intermediate | web | E2Eテスト | - |
| `eval.md` | advanced | general | 評価 | learning |
| `evolve.md` | advanced | general | 進化 | learning |
| `learn.md` | advanced | general | 学習 | learning |
| `skill-create.md` | advanced | general | スキル作成 | learning |
| `learn-eval.md` | advanced | general | 学習評価 | learning |
| `harness-audit.md` | advanced | general | ハーネス監査 | learning |
| `instinct-export.md` | advanced | general | インスティンクトエクスポート | learning |
| `instinct-import.md` | advanced | general | インスティンクトインポート | learning |
| `instinct-status.md` | advanced | general | インスティンクトステータス | learning |
| `rules-distill.md` | advanced | general | ルール蒸留 | learning |
| `skill-health.md` | advanced | general | スキルヘルスチェック | learning |
| `orchestrate.md` | advanced | general | オーケストレーション | multi-model |
| `multi-plan.md` | advanced | general | マルチモデル計画（Codex+Gemini+Claude） | multi-model |
| `multi-execute.md` | advanced | general | マルチモデル実行 | multi-model |
| `multi-backend.md` | advanced | general | マルチモデルバックエンド | multi-model |
| `multi-frontend.md` | advanced | general | マルチモデルフロントエンド | multi-model |
| `multi-workflow.md` | advanced | general | マルチモデルワークフロー | multi-model |
| `model-route.md` | advanced | general | モデルルーティング | multi-model |
| `update-codemaps.md` | advanced | general | コードマップ更新 | infra |
| `setup-pm.md` | advanced | general | パッケージマネージャー設定 | infra |
| `pm2.md` | advanced | general | PM2プロセス管理 | infra |
| `sessions.md` | advanced | general | セッション管理 | infra |
| `resume-session.md` | advanced | general | セッション再開 | infra |
| `save-session.md` | advanced | general | セッション保存 | infra |
| `loop-start.md` | advanced | general | ループ開始 | - |
| `loop-status.md` | advanced | general | ループ状態確認 | - |
| `santa-loop.md` | advanced | general | SANTAループ | - |

### カスタムサンプル（custom-samples/）

以下はプロジェクト固有のカスタマイズ用コマンドです。プリセットのデプロイ対象外ですが、`deploy-custom-skills.sh` でデプロイできます。

| ファイル | 説明 |
|----------|------|
| `custom-samples/create-pr.md` | PR作成（ブランチ作成→コミット→プッシュ→PR） |
| `custom-samples/merge-pr.md` | PRマージ（CI確認→マージ→ブランチクリーンアップ） |

---

## Rules

v2 よりサブディレクトリ構造（`common/` + `typescript/`）に変更。

### common/（共通ルール）

| ファイル | レベル | タイプ | 説明 | アドオン |
|----------|--------|--------|------|---------|
| `common/git-workflow.md` | beginner | general | Git運用ルール | - |
| `common/coding-style.md` | beginner | general | コーディングスタイル | - |
| `common/security.md` | beginner | general | セキュリティ | - |
| `common/agents.md` | intermediate | general | エージェント活用 | - |
| `common/hooks.md` | intermediate | general | フック設定 | - |
| `common/testing.md` | intermediate | general | テスト | - |
| `common/performance.md` | intermediate | general | パフォーマンス | - |
| `common/patterns.md` | intermediate | general | 共通パターン | - |
| `common/code-review.md` | intermediate | general | コードレビュー基準 | - |
| `common/development-workflow.md` | intermediate | general | 開発ワークフロー | - |

### typescript/（TypeScript固有ルール）

| ファイル | レベル | タイプ | 説明 | アドオン |
|----------|--------|--------|------|---------|
| `typescript/coding-style.md` | intermediate | general | TypeScriptコーディングスタイル | - |
| `typescript/hooks.md` | intermediate | general | TypeScriptフック設定 | - |
| `typescript/testing.md` | intermediate | general | TypeScriptテスト | - |
| `typescript/security.md` | intermediate | general | TypeScriptセキュリティ | - |
| `typescript/patterns.md` | intermediate | web | TypeScriptパターン（React/Next.js等） | - |

### その他

| ファイル | レベル | タイプ | 説明 | アドオン |
|----------|--------|--------|------|---------|
| `README.md` | — | — | ルールディレクトリの説明 | - |

---

## Skills

| ディレクトリ | レベル | タイプ | 説明 | アドオン |
|-------------|--------|--------|------|---------|
| `coding-standards/` | beginner | general | コーディング標準 | - |
| `verification-loop/` | beginner | general | 検証ワークフロー | - |
| `strategic-compact/` | beginner | general | コンテキスト管理 | - |
| `api-design/` | beginner | general | API設計パターン | - |
| `git-workflow/` | beginner | general | Gitワークフロー | - |
| `codebase-onboarding/` | beginner | general | コードベースオンボーディング | - |
| `search-first/` | beginner | general | 検索ファースト開発 | - |
| `documentation-lookup/` | beginner | general | ドキュメント検索 | - |
| `tdd-workflow/` | intermediate | general | TDDワークフロー | - |
| `security-review/` | intermediate | general | セキュリティレビュー | - |
| `benchmark/` | intermediate | general | ベンチマーク | - |
| `blueprint/` | intermediate | general | ブループリント設計 | - |
| `deployment-patterns/` | intermediate | general | デプロイパターン | - |
| `docker-patterns/` | intermediate | general | Dockerパターン | - |
| `database-migrations/` | intermediate | general | データベースマイグレーション | - |
| `hexagonal-architecture/` | intermediate | general | ヘキサゴナルアーキテクチャ | - |
| `design-system/` | intermediate | general | デザインシステム | - |
| `security-scan/` | intermediate | general | セキュリティスキャン | - |
| `architecture-decision-records/` | intermediate | general | アーキテクチャ決定記録 | - |
| `article-writing/` | intermediate | general | 記事執筆 | - |
| `claude-api/` | intermediate | general | Claude API活用 | - |
| `content-hash-cache-pattern/` | intermediate | general | コンテンツハッシュキャッシュ | - |
| `data-scraper-agent/` | intermediate | general | データスクレイピング | - |
| `exa-search/` | intermediate | general | Exa検索連携 | - |
| `mcp-server-patterns/` | intermediate | general | MCPサーバーパターン | - |
| `product-lens/` | intermediate | general | プロダクトレンズ分析 | - |
| `project-flow-ops/` | intermediate | general | プロジェクトフロー運用 | - |
| `regex-vs-llm-structured-text/` | intermediate | general | 正規表現 vs LLM構造化テキスト | - |
| `workspace-surface-audit/` | intermediate | general | ワークスペースサーフェス監査 | - |
| `frontend-patterns/` | intermediate | web | フロントエンドパターン | - |
| `backend-patterns/` | intermediate | web | バックエンドパターン | - |
| `frontend-slides/` | intermediate | web | フロントエンドスライド | - |
| `nextjs-turbopack/` | intermediate | web | Next.js Turbopack | - |
| `nuxt4-patterns/` | intermediate | web | Nuxt 4パターン | - |
| `bun-runtime/` | intermediate | web | Bunランタイム | - |
| `e2e-testing/` | intermediate | web | E2Eテスト | - |
| `browser-qa/` | intermediate | web | ブラウザQA | - |
| `ui-demo/` | intermediate | web | UIデモ | - |
| `agent-eval/` | advanced | general | エージェント評価 | - |
| `agentic-engineering/` | advanced | general | エージェンティックエンジニアリング | - |
| `ai-first-engineering/` | advanced | general | AIファーストエンジニアリング | - |
| `ai-regression-testing/` | advanced | general | AIリグレッションテスト | - |
| `autonomous-loops/` | advanced | general | 自律ループ | - |
| `continuous-agent-loop/` | advanced | general | 継続エージェントループ | - |
| `enterprise-agent-ops/` | advanced | general | エンタープライズエージェント運用 | - |
| `cost-aware-llm-pipeline/` | advanced | general | コスト意識LLMパイプライン | - |
| `deep-research/` | advanced | general | 深層リサーチ | - |
| `santa-method/` | advanced | general | SANTAメソッド | - |
| `safety-guard/` | advanced | general | セーフティガード | - |
| `team-builder/` | advanced | general | チームビルダー | - |
| `project-guidelines-example/` | advanced | general | プロジェクトガイドライン例 | - |
| `nutrient-document-processing/` | advanced | general | Nutrientドキュメント処理 | - |
| `continuous-learning/` | advanced | general | 継続学習 | learning |
| `continuous-learning-v2/` | advanced | general | 継続学習v2 | learning |
| `eval-harness/` | advanced | general | 評価ハーネス | learning |
| `agent-harness-construction/` | advanced | general | エージェントハーネス構築 | learning |
| `skill-comply/` | advanced | general | スキルコンプライアンス | learning |
| `skill-stocktake/` | advanced | general | スキル棚卸し | learning |
| `rules-distill/` | advanced | general | ルール蒸留 | learning |
| `canary-watch/` | advanced | general | カナリアウォッチ | learning |
| `repo-scan/` | advanced | general | リポジトリスキャン | learning |
| `prompt-optimizer/` | advanced | general | プロンプト最適化 | multi-model |
| `context-budget/` | advanced | general | コンテキスト予算管理 | multi-model |
| `token-budget-advisor/` | advanced | general | トークン予算アドバイザー | multi-model |
| `iterative-retrieval/` | advanced | general | 反復取得 | multi-model |
| `configure-ecc/` | advanced | general | Everything Claude Code設定 | infra |

### カスタムサンプル（custom-samples/）

以下はプロジェクト固有のカスタマイズ用サンプルです。デプロイ対象外ですが、手動でコピーして使用できます。

| ディレクトリ | 説明 |
|-------------|------|
| `custom-samples/adapt-external-docs/` | 外部ドキュメントをプロジェクト形式に適合 |
| `custom-samples/merge-reference-docs/` | 参考ドキュメントをマージして拡張 |

---

## Contexts

| ファイル | レベル | タイプ | 説明 | アドオン |
|----------|--------|--------|------|---------|
| `dev.md` | beginner | general | 開発モード | - |
| `research.md` | beginner | general | 調査モード | - |
| `review.md` | beginner | general | レビューモード | - |

---

## Settings

プリセットのデプロイ対象外。`deploy-settings.sh` でデプロイできます。

| ファイル | 説明 |
|----------|------|
| `settings-samples/teammate-idle.json` | TeammateIdle フック（アイドル時にタスク継続を促す） |

---

## Agent Teams

プリセットのデプロイ対象外。`setup-agent-teams.sh` で一括セットアップできます。
`agent-teams/` ディレクトリに格納されています（`template-.claude/` 外）。

| ファイル | 種別 | 説明 |
|----------|------|------|
| `agent-teams/settings-fragment.json` | settings | Agent Teams 用 settings.json テンプレート（env + hooks） |
| `agent-teams/hooks/keep-teammate-busy.sh` | hook | TeammateIdle フック（未完了タスクがあれば作業継続を促す） |
| `agent-teams/commands/team-start.md` | command | Agent Teams を起動してタスクを並列実行する |
| `agent-teams/commands/team-review.md` | command | チーム状態の確認・統合レポート・シャットダウン |
| `agent-teams/agents/team-orchestrator.md` | agent | チーム全体のオーケストレーション |
| `agent-teams/rules/agent-teams.md` | rule | Agent Teams 起動の自動判断ルール |
| `agent-teams/CLAUDE_ADDITION.md` | docs | CLAUDE.md に追記する Agent Team ルール |

---

## プリセット

### minimal（最小構成）

- レベル: beginner のみ
- タイプ: general のみ
- ファイル数: 約21

### standard（標準構成）

- レベル: beginner + intermediate
- タイプ: general のみ
- ファイル数: 約80

### standard-web（標準構成 + Web）

- レベル: beginner + intermediate
- タイプ: general + web
- ファイル数: 約92

### standard-learning（標準 + 自己学習）

- レベル: beginner + intermediate
- タイプ: general のみ
- アドオン: learning
- ファイル数: 約80

### standard-multi（標準 + マルチモデル）

- レベル: beginner + intermediate
- タイプ: general のみ
- アドオン: multi-model
- ファイル数: 約80

### full（フル構成）

- レベル: 全て
- タイプ: general + web
- ファイル数: 約152

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-04-02 | v3: Agents×9・Commands×23・Rules×2・Skills×52 追加、ファイル数 67→152 |
| 2026-02-18 | Agent Teams セクション追加、Settings 説明を deploy-settings.sh に修正 |
| 2026-02-18 | Commands カスタムサンプル×2（create-pr, merge-pr）、Settings テンプレート×1（teammate-idle）追加 |
| 2026-02-09 | アドオン列追加（learning, multi-model, infra）、standard-learning/standard-multi プリセット追加 |
| 2026-02-09 | v2: Rules をサブディレクトリ構造に変更、Commands×7・Skills×2 追加、ファイル数 52→67 |
| 2026-01-28 | 初回作成 |
