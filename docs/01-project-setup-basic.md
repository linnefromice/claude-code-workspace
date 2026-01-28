# プロジェクト基本セットアップ

CLAUDE.md と .ai ディレクトリなどの基本的なClaude Code設定を対象プロジェクトに適用します。

---

## 概要

このセットアップでは以下を対象プロジェクトに配置します：

| ファイル/ディレクトリ | 用途 |
|---------------------|------|
| `CLAUDE.md` | プロジェクト固有の指示（追記用テンプレート） |
| `.ai/tasks/` | ローカルタスク管理ディレクトリ |
| `.gitignore` への追記 | CLAUDE.md等の除外設定 |

---

## 実行方法

### 方法A: セットアップスクリプト（推奨）

```bash
# このリポジトリのディレクトリから実行
./initialize-project/setup.sh /path/to/your/project
```

### 方法B: 手動コピー

```bash
# 1. CLAUDE.md を作成（または既存に追記）
cat initialize-project/CLAUDE_ADDITION.md >> /path/to/your/project/CLAUDE.md

# 2. .ai ディレクトリを作成
mkdir -p /path/to/your/project/.ai/tasks/{records,design,todos,prompts}

# 3. .gitignore に追加
cat initialize-project/.gitignore_ADDTION >> /path/to/your/project/.gitignore
```

---

## 配置されるファイルの詳細

### CLAUDE.md

プロジェクト固有の指示を記述するファイルです。以下のセクションが含まれます：

- ユーザーカスタマイズ設定（`CLAUDE.local.md` の参照）
- タスクファイル実行ルール（`do @filepath` 形式）
- ドキュメント配置ルール
- Git操作時の除外ルール

### .ai/tasks/

ローカルタスク管理用のディレクトリ構造：

```
.ai/tasks/
├── records/   # 調査結果のダンプ（デフォルト）
├── design/    # 設計ドキュメント
├── todos/     # タスクリスト
└── prompts/   # 再利用可能なプロンプト
```

### .gitignore への追記

```gitignore
# Claude Code ローカル設定
CLAUDE.local.md
.ai/
```

---

## セットアップ後

基本セットアップ完了後、Claude Code テンプレート（エージェント、コマンド等）を適用する場合は：

→ [Claude Code テンプレートの適用](./02-project-setup-templates.md)

---

## 関連ファイル

| ファイル | 用途 |
|----------|------|
| `initialize-project/setup.sh` | セットアップスクリプト |
| `initialize-project/CLAUDE_ADDITION.md` | CLAUDE.md 追記用テンプレート |
| `initialize-project/.gitignore_ADDTION` | .gitignore 追記用 |
