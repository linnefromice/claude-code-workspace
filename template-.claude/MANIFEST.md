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

---

## Agents

| ファイル | レベル | タイプ | 説明 |
|----------|--------|--------|------|
| `planner.md` | beginner | general | 実装計画立案 |
| `code-reviewer.md` | beginner | general | コードレビュー |
| `refactor-cleaner.md` | beginner | general | リファクタリング |
| `architect.md` | intermediate | general | アーキテクチャ設計 |
| `doc-updater.md` | intermediate | general | ドキュメント更新 |
| `tdd-guide.md` | intermediate | general | TDDガイド |
| `build-error-resolver.md` | intermediate | general | ビルドエラー解決 |
| `security-reviewer.md` | intermediate | general | セキュリティレビュー |
| `e2e-runner.md` | intermediate | web | E2Eテスト実行 |

---

## Commands

| ファイル | レベル | タイプ | 説明 |
|----------|--------|--------|------|
| `plan.md` | beginner | general | 計画作成 |
| `verify.md` | beginner | general | 検証 |
| `code-review.md` | beginner | general | コードレビュー |
| `refactor-clean.md` | beginner | general | リファクタリング |
| `tdd.md` | intermediate | general | TDD実行 |
| `build-fix.md` | intermediate | general | ビルド修正 |
| `test-coverage.md` | intermediate | general | テストカバレッジ |
| `checkpoint.md` | intermediate | general | チェックポイント |
| `update-docs.md` | intermediate | general | ドキュメント更新 |
| `e2e.md` | intermediate | web | E2Eテスト |
| `eval.md` | advanced | general | 評価 |
| `evolve.md` | advanced | general | 進化 |
| `learn.md` | advanced | general | 学習 |
| `skill-create.md` | advanced | general | スキル作成 |
| `orchestrate.md` | advanced | general | オーケストレーション |
| `update-codemaps.md` | advanced | general | コードマップ更新 |
| `setup-pm.md` | advanced | general | パッケージマネージャー設定 |
| `instinct-export.md` | advanced | general | インスティンクトエクスポート |
| `instinct-import.md` | advanced | general | インスティンクトインポート |
| `instinct-status.md` | advanced | general | インスティンクトステータス |
| `multi-plan.md` | advanced | general | マルチモデル計画（Codex+Gemini+Claude） |
| `multi-execute.md` | advanced | general | マルチモデル実行 |
| `multi-backend.md` | advanced | general | マルチモデルバックエンド |
| `multi-frontend.md` | advanced | general | マルチモデルフロントエンド |
| `multi-workflow.md` | advanced | general | マルチモデルワークフロー |
| `pm2.md` | advanced | general | PM2プロセス管理 |
| `sessions.md` | advanced | general | セッション管理 |

---

## Rules

v2 よりサブディレクトリ構造（`common/` + `typescript/`）に変更。

### common/（共通ルール）

| ファイル | レベル | タイプ | 説明 |
|----------|--------|--------|------|
| `common/git-workflow.md` | beginner | general | Git運用ルール |
| `common/coding-style.md` | beginner | general | コーディングスタイル |
| `common/security.md` | beginner | general | セキュリティ |
| `common/agents.md` | intermediate | general | エージェント活用 |
| `common/hooks.md` | intermediate | general | フック設定 |
| `common/testing.md` | intermediate | general | テスト |
| `common/performance.md` | intermediate | general | パフォーマンス |
| `common/patterns.md` | intermediate | general | 共通パターン |

### typescript/（TypeScript固有ルール）

| ファイル | レベル | タイプ | 説明 |
|----------|--------|--------|------|
| `typescript/coding-style.md` | intermediate | general | TypeScriptコーディングスタイル |
| `typescript/hooks.md` | intermediate | general | TypeScriptフック設定 |
| `typescript/testing.md` | intermediate | general | TypeScriptテスト |
| `typescript/security.md` | intermediate | general | TypeScriptセキュリティ |
| `typescript/patterns.md` | intermediate | web | TypeScriptパターン（React/Next.js等） |

### その他

| ファイル | レベル | タイプ | 説明 |
|----------|--------|--------|------|
| `README.md` | — | — | ルールディレクトリの説明 |

---

## Skills

| ディレクトリ | レベル | タイプ | 説明 |
|-------------|--------|--------|------|
| `coding-standards/` | beginner | general | コーディング標準 |
| `verification-loop/` | beginner | general | 検証ワークフロー |
| `strategic-compact/` | beginner | general | コンテキスト管理 |
| `tdd-workflow/` | intermediate | general | TDDワークフロー |
| `security-review/` | intermediate | general | セキュリティレビュー |
| `frontend-patterns/` | intermediate | web | フロントエンドパターン |
| `backend-patterns/` | intermediate | web | バックエンドパターン |
| `continuous-learning/` | advanced | general | 継続学習 |
| `continuous-learning-v2/` | advanced | general | 継続学習v2 |
| `eval-harness/` | advanced | general | 評価ハーネス |
| `iterative-retrieval/` | advanced | general | 反復取得 |
| `project-guidelines-example/` | advanced | general | プロジェクトガイドライン例 |
| `configure-ecc/` | advanced | general | Everything Claude Code設定 |
| `nutrient-document-processing/` | advanced | general | Nutrientドキュメント処理 |

### カスタムサンプル（custom-samples/）

以下はプロジェクト固有のカスタマイズ用サンプルです。デプロイ対象外ですが、手動でコピーして使用できます。

| ディレクトリ | 説明 |
|-------------|------|
| `custom-samples/adapt-external-docs/` | 外部ドキュメントをプロジェクト形式に適合 |
| `custom-samples/merge-reference-docs/` | 参考ドキュメントをマージして拡張 |

---

## Contexts

| ファイル | レベル | タイプ | 説明 |
|----------|--------|--------|------|
| `dev.md` | beginner | general | 開発モード |
| `research.md` | beginner | general | 調査モード |
| `review.md` | beginner | general | レビューモード |

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

### full（フル構成）

- レベル: 全て
- タイプ: general + web
- ファイル数: 約67

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2026-02-09 | v2: Rules をサブディレクトリ構造に変更、Commands×7・Skills×2 追加、ファイル数 52→67 |
| 2026-01-28 | 初回作成 |
