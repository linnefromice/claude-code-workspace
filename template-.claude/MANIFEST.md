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
| `e2e-runner.md` | intermediate | web | E2Eテスト実行 | - |

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
| `e2e.md` | intermediate | web | E2Eテスト | - |
| `eval.md` | advanced | general | 評価 | learning |
| `evolve.md` | advanced | general | 進化 | learning |
| `learn.md` | advanced | general | 学習 | learning |
| `skill-create.md` | advanced | general | スキル作成 | learning |
| `orchestrate.md` | advanced | general | オーケストレーション | multi-model |
| `update-codemaps.md` | advanced | general | コードマップ更新 | infra |
| `setup-pm.md` | advanced | general | パッケージマネージャー設定 | infra |
| `instinct-export.md` | advanced | general | インスティンクトエクスポート | learning |
| `instinct-import.md` | advanced | general | インスティンクトインポート | learning |
| `instinct-status.md` | advanced | general | インスティンクトステータス | learning |
| `multi-plan.md` | advanced | general | マルチモデル計画（Codex+Gemini+Claude） | multi-model |
| `multi-execute.md` | advanced | general | マルチモデル実行 | multi-model |
| `multi-backend.md` | advanced | general | マルチモデルバックエンド | multi-model |
| `multi-frontend.md` | advanced | general | マルチモデルフロントエンド | multi-model |
| `multi-workflow.md` | advanced | general | マルチモデルワークフロー | multi-model |
| `pm2.md` | advanced | general | PM2プロセス管理 | infra |
| `sessions.md` | advanced | general | セッション管理 | infra |

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
| `tdd-workflow/` | intermediate | general | TDDワークフロー | - |
| `security-review/` | intermediate | general | セキュリティレビュー | - |
| `frontend-patterns/` | intermediate | web | フロントエンドパターン | - |
| `backend-patterns/` | intermediate | web | バックエンドパターン | - |
| `continuous-learning/` | advanced | general | 継続学習 | learning |
| `continuous-learning-v2/` | advanced | general | 継続学習v2 | learning |
| `eval-harness/` | advanced | general | 評価ハーネス | learning |
| `iterative-retrieval/` | advanced | general | 反復取得 | multi-model |
| `project-guidelines-example/` | advanced | general | プロジェクトガイドライン例 | - |
| `configure-ecc/` | advanced | general | Everything Claude Code設定 | infra |
| `nutrient-document-processing/` | advanced | general | Nutrientドキュメント処理 | - |

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

## プリセット

### minimal（最小構成）

- レベル: beginner のみ
- タイプ: general のみ
- ファイル数: 約16

### standard（標準構成）

- レベル: beginner + intermediate
- タイプ: general のみ
- ファイル数: 約37

### standard-web（標準構成 + Web）

- レベル: beginner + intermediate
- タイプ: general + web
- ファイル数: 約42

### standard-learning（標準 + 自己学習）

- レベル: beginner + intermediate
- タイプ: general のみ
- アドオン: learning
- ファイル数: 約47

### standard-multi（標準 + マルチモデル）

- レベル: beginner + intermediate
- タイプ: general のみ
- アドオン: multi-model
- ファイル数: 約44

### full（フル構成）

- レベル: 全て
- タイプ: general + web
- ファイル数: 約67

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-02-09 | アドオン列追加（learning, multi-model, infra）、standard-learning/standard-multi プリセット追加 |
| 2026-02-09 | v2: Rules をサブディレクトリ構造に変更、Commands×7・Skills×2 追加、ファイル数 52→67 |
| 2026-01-28 | 初回作成 |
