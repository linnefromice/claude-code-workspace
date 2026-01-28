# Claude Code テンプレートの適用

汎用化済みの Claude Code テンプレート（エージェント、コマンド、ルール等）を対象プロジェクトに適用します。

---

## 概要

このセットアップでは `template-.claude/` の内容を対象プロジェクトの `.claude/` にコピーします：

| ディレクトリ | 内容 | ファイル数 |
|--------------|------|-----------|
| `agents/` | カスタムエージェント | 9 |
| `commands/` | コマンド定義 | 20 |
| `rules/` | 自動適用ルール | 8 |
| `skills/` | スキル定義 | 12 |
| `contexts/` | 起動モード切り替え | 3 |

---

## 前提条件

- [基本セットアップ](./01-project-setup-basic.md) が完了していること（推奨）
- 対象プロジェクトに `.claude/` ディレクトリが存在しないこと（または上書きを許可）

---

## 実行方法

### 方法A: デプロイスクリプト（推奨）

```bash
# このリポジトリのディレクトリから実行
./scripts/deploy-to-project.sh /path/to/your/project
```

**オプション:**

```bash
# 全てコピー（デフォルト）
./scripts/deploy-to-project.sh /path/to/your/project

# 特定のカテゴリのみコピー
./scripts/deploy-to-project.sh /path/to/your/project --only agents,rules

# 既存ファイルを上書き
./scripts/deploy-to-project.sh /path/to/your/project --force

# ドライラン（実際にはコピーしない）
./scripts/deploy-to-project.sh /path/to/your/project --dry-run
```

### 方法B: 手動コピー

```bash
# .claude ディレクトリを作成
mkdir -p /path/to/your/project/.claude

# テンプレートをコピー
cp -r template-.claude/* /path/to/your/project/.claude/

# CLAUDE.md を除外（プロジェクト固有のため）
rm /path/to/your/project/.claude/*/CLAUDE.md 2>/dev/null
```

---

## 適用されるテンプレート

### Agents（エージェント）

Task ツールから専門家として呼び出すエージェント定義。

| ファイル | 用途 |
|----------|------|
| `planner.md` | 実装計画の立案 |
| `code-reviewer.md` | コードレビュー |
| `architect.md` | アーキテクチャ設計 |
| `refactor-cleaner.md` | リファクタリング |
| `security-reviewer.md` | セキュリティレビュー |
| `tdd-guide.md` | TDD ガイド |
| `doc-updater.md` | ドキュメント更新 |
| `build-error-resolver.md` | ビルドエラー解決 |
| `e2e-runner.md` | E2E テスト実行 |

### Commands（コマンド）

`/command-name` で呼び出すコマンド定義。

| ファイル | 用途 |
|----------|------|
| `plan.md` | 計画作成 |
| `code-review.md` | コードレビュー |
| `tdd.md` | TDD 実行 |
| `verify.md` | 検証 |
| 他16件 | ... |

### Rules（ルール）

常時適用されるガイドライン。

| ファイル | 用途 |
|----------|------|
| `git-workflow.md` | Git運用ルール |
| `coding-style.md` | コーディングスタイル |
| `security.md` | セキュリティ |
| `testing.md` | テスト |
| 他4件 | ... |

### Skills（スキル）

`/skill-name` で呼び出すスキル定義。

| ディレクトリ | 用途 |
|-------------|------|
| `coding-standards/` | コーディング標準 |
| `verification-loop/` | 検証ワークフロー |
| `tdd-workflow/` | TDD ワークフロー |
| 他9件 | ... |

### Contexts（コンテキスト）

`--system-prompt` で起動モードを切り替え。

| ファイル | 用途 |
|----------|------|
| `dev.md` | 開発モード |
| `research.md` | 調査モード |
| `review.md` | レビューモード |

---

## 適用後のカスタマイズ

テンプレートには `<!-- CUSTOMIZE: ... -->` コメントでカスタマイズポイントが示されています。
プロジェクトに合わせて調整してください。

### 例: パッケージマネージャーの変更

```markdown
<!-- CUSTOMIZE: プロジェクトのパッケージマネージャーに合わせて変更 -->
npm run build
```

↓ pnpm を使用する場合

```markdown
pnpm build
```

---

## 難易度別ガイド

全てのテンプレートを一度に適用する必要はありません。

### 初級（まず試すべき）

- `contexts/` - 開発/レビューモード切り替え
- `rules/git-workflow.md`, `rules/coding-style.md`, `rules/security.md`
- `agents/planner.md`, `agents/code-reviewer.md`

### 中級（慣れてきたら）

- `rules/` 全て
- `agents/` 全て
- `commands/plan.md`, `commands/verify.md`, `commands/code-review.md`

### 上級（フル活用）

- `skills/` 全て
- `commands/` 全て

詳細は [テンプレート分類レポート](../.ai/tasks/records/20260128193500-template-classification.md) を参照。

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [基本セットアップ](./01-project-setup-basic.md) | CLAUDE.md, .ai の配置 |
| [テンプレート更新](./03-template-maintenance.md) | テンプレートの更新・メンテナンス |
