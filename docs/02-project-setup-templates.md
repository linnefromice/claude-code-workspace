# Claude Code テンプレートの適用

汎用化済みの Claude Code テンプレート（エージェント、コマンド、ルール等）を対象プロジェクトに適用します。

---

## 概要

このセットアップでは `template-.claude/` の内容を対象プロジェクトの `.claude/` にコピーします。
プロジェクトの種類や習熟度に応じて、適用するテンプレートを選択できます。

---

## プリセット

| プリセット | レベル | タイプ | ファイル数 | 推奨用途 |
|-----------|--------|--------|-----------|---------|
| `minimal` | 初級 | 汎用 | 約16 | Claude Code 入門者 |
| `standard` | 初級・中級 | 汎用 | 約37 | 一般的なプロジェクト（推奨） |
| `standard-web` | 初級・中級 | 汎用・Web | 約37 | Web開発プロジェクト |
| `full` | 全て | 全て | 約52 | フル活用したい方 |

### レベル

| レベル | 説明 |
|--------|------|
| `beginner` | 即座に活用可能。設定不要 |
| `intermediate` | 軽微な設定が必要。テストフレームワーク等の前提あり |
| `advanced` | カスタムセットアップが必要。学習システム等 |

### タイプ

| タイプ | 説明 |
|--------|------|
| `general` | どのプロジェクトでも使用可能 |
| `web` | Web開発固有（React, Next.js, E2E, Playwright等） |

---

## 前提条件

- [基本セットアップ](./01-project-setup-basic.md) が完了していること（推奨）
- 対象プロジェクトに `.claude/` ディレクトリが存在しないこと（または上書きを許可）

---

## 実行方法

### 方法A: プリセットを使用（推奨）

```bash
# 最小構成（入門者向け）
./scripts/deploy-to-project.sh /path/to/project --preset minimal

# 標準構成（推奨）
./scripts/deploy-to-project.sh /path/to/project --preset standard

# 標準構成 + Web開発向け
./scripts/deploy-to-project.sh /path/to/project --preset standard-web

# フル構成
./scripts/deploy-to-project.sh /path/to/project --preset full
```

### 方法B: 対話モード

```bash
./scripts/deploy-to-project.sh /path/to/project -i
```

対話形式でプリセットを選択できます。

### 方法C: カスタム選択

```bash
# レベルとタイプを直接指定
./scripts/deploy-to-project.sh /path/to/project \
  --level beginner,intermediate \
  --type general
```

### オプション

```bash
# ドライラン（実際にはコピーしない）
./scripts/deploy-to-project.sh /path/to/project --preset minimal --dry-run

# 既存ファイルを上書き
./scripts/deploy-to-project.sh /path/to/project --preset standard --force
```

### 方法D: 手動コピー

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

詳細な分類は [MANIFEST.md](../template-.claude/MANIFEST.md) を参照してください。

### 初級（beginner）- すぐに使える

| カテゴリ | ファイル | 用途 |
|---------|----------|------|
| Agents | `planner.md` | 実装計画立案 |
| | `code-reviewer.md` | コードレビュー |
| | `refactor-cleaner.md` | リファクタリング |
| Commands | `plan.md` | 計画作成 |
| | `verify.md` | 検証 |
| | `code-review.md` | コードレビュー |
| | `refactor-clean.md` | リファクタリング |
| Rules | `git-workflow.md` | Git運用ルール |
| | `coding-style.md` | コーディングスタイル |
| | `security.md` | セキュリティ |
| Skills | `coding-standards/` | コーディング標準 |
| | `verification-loop/` | 検証ワークフロー |
| | `strategic-compact/` | コンテキスト管理 |
| Contexts | `dev.md`, `research.md`, `review.md` | モード切替 |

### 中級（intermediate）- 設定が必要

| カテゴリ | ファイル | 用途 | タイプ |
|---------|----------|------|--------|
| Agents | `architect.md` | アーキテクチャ設計 | general |
| | `tdd-guide.md` | TDDガイド | general |
| | `security-reviewer.md` | セキュリティレビュー | general |
| | `e2e-runner.md` | E2Eテスト実行 | **web** |
| Commands | `tdd.md`, `build-fix.md` 等 | 各種コマンド | general |
| | `e2e.md` | E2Eテスト | **web** |
| Rules | `testing.md`, `performance.md` 等 | ガイドライン | general |
| | `patterns.md` | 共通パターン | **web** |
| Skills | `tdd-workflow/`, `security-review/` | ワークフロー | general |
| | `frontend-patterns/`, `backend-patterns/` | 開発パターン | **web** |

### 上級（advanced）- カスタムセットアップ必要

| カテゴリ | ファイル | 用途 |
|---------|----------|------|
| Commands | `instinct-*.md` (3件) | 学習システム |
| | `eval.md`, `evolve.md`, `learn.md` | 評価・学習 |
| | `skill-create.md`, `orchestrate.md` | 高度な機能 |
| Skills | `continuous-learning/` (2件) | 継続学習 |
| | `eval-harness/`, `iterative-retrieval/` | 評価・取得 |
| | `project-guidelines-example/` | プロジェクト例 |

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

## 推奨ワークフロー

### Step 1: 最小構成で始める

```bash
./scripts/deploy-to-project.sh /path/to/project --preset minimal
```

### Step 2: 慣れてきたら標準構成へ

```bash
./scripts/deploy-to-project.sh /path/to/project --preset standard --force
```

### Step 3: Web開発なら Web を追加

```bash
./scripts/deploy-to-project.sh /path/to/project --preset standard-web --force
```

### Step 4: フル活用

```bash
./scripts/deploy-to-project.sh /path/to/project --preset full --force
```

---

---

## 次のステップ

テンプレート適用後、プロジェクト固有のスキルを追加できます：

→ [カスタムスキルの作成・追加](./04-custom-skills.md)

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [基本セットアップ](./01-project-setup-basic.md) | CLAUDE.md, .ai の配置 |
| [カスタムスキル](./04-custom-skills.md) | プロジェクト固有スキルの追加 |
| [テンプレート更新](./03-template-maintenance.md) | テンプレートの更新・メンテナンス |
