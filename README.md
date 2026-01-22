# claude-code-workspace

Claude Code のプロジェクト設定テンプレートです。このリポジトリをクローンまたはスクリプトを実行することで、任意のプロジェクトに Claude Code の設定を適用できます。

## 概要

このリポジトリは以下の機能を提供します：

- **CLAUDE.md** - チーム共有の Claude Code 設定ファイル
- **CLAUDE.local.md** - 個人カスタマイズ用の設定テンプレート
- **.ai/tasks/** - AI タスク管理ディレクトリ構造

## ディレクトリ構成

```
.
├── CLAUDE.md           # チーム共有設定（Git管理対象）
├── CLAUDE.local.md     # ローカル設定テンプレート
└── .ai/
    └── tasks/
        ├── records/    # 一時的な調査結果（デフォルト）
        ├── design/     # 設計ドキュメント
        ├── todos/      # タスクリスト
        └── prompts/    # 再利用可能なプロンプト
```

## セットアップ

### 方法1: スクリプトによるセットアップ

```bash
# このリポジトリをクローン
git clone https://github.com/_linnefromice/linnefromice/claude-code-workspace.git

# セットアップスクリプトを実行（対象プロジェクトを指定）
./setup.sh /path/to/your/project
```

### 方法2: 手動セットアップ

1. `CLAUDE.md` を対象プロジェクトのルートにコピー
2. `CLAUDE.local.md` を参考に、必要に応じてローカル設定を作成
3. `.ai/tasks/` ディレクトリ構造を作成

```bash
# 対象プロジェクトで実行
mkdir -p .ai/tasks/{records,design,todos,prompts}
touch .ai/tasks/{records,design,todos,prompts}/.gitkeep
```

## 設定ファイルの役割

### CLAUDE.md（チーム共有）

Git にコミットしてチーム全体で共有する Claude Code の設定です。

- プロジェクト固有のコーディング規約
- アーキテクチャガイドライン
- 共通のワークフロー指示

### CLAUDE.local.md（個人設定）

`.gitignore` に追加し、各開発者がローカルでカスタマイズする設定です。

- 個人のコーディングスタイル
- ローカル環境固有の設定
- カスタムワークフロー
- `CLAUDE.md` より優先される

## タスク管理

`.ai/tasks/` ディレクトリで AI との作業を整理できます。

| ディレクトリ | 用途 |
|-------------|------|
| `records/` | 一時的な調査結果のダンプ（デフォルト） |
| `design/` | 複数セッションを跨ぐ設計・要件定義 |
| `todos/` | タスクリスト |
| `prompts/` | 再利用可能なプロンプトテンプレート |

### ファイル命名規則

```
YYYYMMDDHHmmss-(task-name).md

例: 20260122143052-api-investigation.md
```

### タスクファイルの実行

```
do @.ai/tasks/prompts/code-review.md
```

## 注意事項

- `.ai/` ディレクトリはローカル専用です。`.gitignore` に追加してください
- `CLAUDE.local.md` もローカル専用として `.gitignore` に追加することを推奨します

```gitignore
# Claude Code local files
.ai/
CLAUDE.local.md
```

## ライセンス

MIT
