# Claude Code テンプレート分類レポート

**作成日**: 2026-01-28
**対象**: `template-.claude/` および `.work/translated/skills/`

---

## 概要

翻訳・汎用化済みのClaude Codeテンプレートを以下の観点で分類:

1. **除外対象**: 言語固有 / 実行環境依存
2. **汎用活用可能**: 難易度別（初級・中級・上級）

---

## 除外対象

### 言語/DB固有

| カテゴリ | ファイル | 理由 | 除外ステップ |
|---------|---------|------|------------|
| Agents | `database-reviewer.md` | PostgreSQL/Supabase固有 | 汎用化Step1 |

### 実行環境依存 (E2E/Web)

| カテゴリ | ファイル | 理由 |
|---------|---------|------|
| Agents | `e2e-runner.md` | Playwright/ブラウザ自動化 |
| Commands | `e2e.md` | E2Eテスト実行 |
| Skills | `frontend-patterns/` | React/Next.js固有 |
| Skills | `backend-patterns/` | Next.js API/Supabase固有 |
| Rules | `patterns.md` | Reactフック等Web固有パターン |

---

## 汎用活用可能: 難易度別分類

### 初級 - 即座に活用可能

どのプロジェクトでもそのまま使用可能。設定不要。

| カテゴリ | ファイル | 用途 |
|---------|---------|------|
| **Contexts** | `dev.md` | 開発モード切替 |
| | `research.md` | 調査モード |
| | `review.md` | レビューモード |
| **Rules** | `git-workflow.md` | Git運用ルール |
| | `coding-style.md` | コーディングスタイル |
| | `security.md` | セキュリティ基本 |
| **Agents** | `planner.md` | 実装計画立案 |
| | `code-reviewer.md` | コードレビュー |
| | `refactor-cleaner.md` | リファクタリング |
| **Commands** | `plan.md` | 計画コマンド |
| | `verify.md` | 検証コマンド |
| | `code-review.md` | レビューコマンド |
| | `refactor-clean.md` | 整理コマンド |
| **Skills** | `coding-standards/` | コーディング標準 |
| | `verification-loop/` | 検証ワークフロー |
| | `strategic-compact/` | コンテキスト管理 |

**合計**: 15件

### 中級 - 軽微な設定が必要

テストフレームワークやビルドツールの前提あり。

| カテゴリ | ファイル | 前提条件 |
|---------|---------|---------|
| **Rules** | `agents.md` | Claude エージェント理解 |
| | `hooks.md` | Claude フック設定 |
| | `testing.md` | テストフレームワーク |
| | `performance.md` | プロファイリングツール |
| **Agents** | `architect.md` | 設計経験 |
| | `doc-updater.md` | ドキュメント構造 |
| | `tdd-guide.md` | TDD理解 |
| | `build-error-resolver.md` | ビルドシステム |
| | `security-reviewer.md` | セキュリティ知識 |
| **Commands** | `tdd.md` | テストフレームワーク |
| | `build-fix.md` | ビルドシステム |
| | `test-coverage.md` | カバレッジツール |
| | `checkpoint.md` | Git運用 |
| | `update-docs.md` | ドキュメント構造 |
| **Skills** | `tdd-workflow/` | TDD実践 |
| | `security-review/` | セキュリティ監査 |

**合計**: 14件

### 上級 - カスタムセットアップ必要

独自システムの構築・設定が必要。

| カテゴリ | ファイル | 必要な準備 |
|---------|---------|----------|
| **Commands** | `instinct-export.md` | 学習システム構築 |
| | `instinct-import.md` | 学習システム構築 |
| | `instinct-status.md` | 学習システム構築 |
| | `eval.md` | 評価フレームワーク |
| | `evolve.md` | 進化システム |
| | `learn.md` | 学習システム |
| | `skill-create.md` | スキル定義理解 |
| | `orchestrate.md` | マルチエージェント |
| | `update-codemaps.md` | コードマップ構造 |
| | `setup-pm.md` | PM設定スクリプト |
| **Skills** | `continuous-learning/` | 学習インフラ |
| | `continuous-learning-v2/` | 学習インフラ |
| | `eval-harness/` | 評価インフラ |
| | `iterative-retrieval/` | 複雑な取得パターン |
| | `project-guidelines-example/` | プロジェクト固有設定 |

**合計**: 13件

---

## サマリー

| 分類 | ファイル数 | 推奨アクション |
|-----|----------|--------------|
| 除外（言語固有） | 1 | 削除または別管理 |
| 除外（環境依存） | 5 | Web専用ディレクトリへ分離 |
| 初級 | 15 | **コアセットとして即採用** |
| 中級 | 14 | 段階的に導入 |
| 上級 | 13 | 必要時のみ導入 |
| **合計** | **48** | |

---

## 推奨構成

### 最小構成（初級のみ）

```
.claude/
├── contexts/
│   ├── dev.md
│   ├── research.md
│   └── review.md
├── rules/
│   ├── git-workflow.md
│   ├── coding-style.md
│   └── security.md
├── agents/
│   ├── planner.md
│   ├── code-reviewer.md
│   └── refactor-cleaner.md
├── commands/
│   ├── plan.md
│   ├── verify.md
│   ├── code-review.md
│   └── refactor-clean.md
└── skills/
    ├── coding-standards/
    ├── verification-loop/
    └── strategic-compact/
```

### 標準構成（初級 + 中級）

上記に加えて:
- `rules/agents.md`, `hooks.md`, `testing.md`, `performance.md`
- `agents/architect.md`, `doc-updater.md`, `tdd-guide.md`, `build-error-resolver.md`, `security-reviewer.md`
- `commands/tdd.md`, `build-fix.md`, `test-coverage.md`, `checkpoint.md`, `update-docs.md`
- `skills/tdd-workflow/`, `security-review/`

### フル構成

標準構成 + 上級（学習・評価システム含む）

---

## 次のアクション

1. [ ] 除外対象を `template-.claude/` から分離
2. [ ] 初級ファイルを `template-.claude-core/` として整理
3. [ ] 中級・上級を `template-.claude-extended/` として整理
4. [ ] デプロイスクリプトに構成選択オプションを追加
