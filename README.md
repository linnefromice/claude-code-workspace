# claude-code-workspace

Claude Code の設定テンプレートとセットアップツールを提供するリポジトリです。

---

## 概要

このリポジトリは2つの独立したプロセスで構成されています：

| プロセス | 目的 | 実行者 |
|----------|------|--------|
| **[1] テンプレート更新** | ソースリポジトリから最新テンプレートを取得・翻訳・汎用化 | メンテナー |
| **[2] プロジェクトへの適用** | テンプレートを任意のプロジェクトに適用 | エンドユーザー |

---

## ディレクトリ構成

```
claude-code-workspace/
│
├── README.md                      # このファイル
├── recommended-plugins.csv        # 推奨プラグイン一覧
│
│  ┌─────────────────────────────────────────────────────────────┐
│  │  [1] テンプレート更新用（メンテナー向け）                    │
│  └─────────────────────────────────────────────────────────────┘
├── prompts/                       # 更新プロセス用プロンプト
│   ├── translate-to-ja.md         # 翻訳ガイドライン
│   ├── collect-and-translate-claude-templates.md
│   └── generalize-claude-templates.md
│
├── scripts/                       # 更新プロセス用スクリプト
│   ├── setup-templates.sh         # ソース取得・準備
│   └── deploy-templates.sh        # テンプレートディレクトリへ配置
│
├── .work/                         # 作業ディレクトリ（git除外、自動生成）
│   ├── source/                    # クローンされたソースリポジトリ
│   └── translated/                # 翻訳出力
│
│  ┌─────────────────────────────────────────────────────────────┐
│  │  [2] プロジェクト適用用（エンドユーザー向け）                │
│  └─────────────────────────────────────────────────────────────┘
├── template-.claude/              # ★ 汎用化済みテンプレート
│   ├── agents/                    # カスタムエージェント
│   ├── commands/                  # コマンド定義
│   ├── rules/                     # 自動適用ルール
│   ├── skills/                    # 呼び出し可能スキル
│   └── contexts/                  # 起動モード切り替え用
│
├── initialize-project/            # プロジェクト初期化リソース
│   ├── setup.sh                   # セットアップスクリプト
│   ├── CLAUDE_ADDITION.md         # CLAUDE.md 追記用
│   ├── .gitignore_ADDTION         # .gitignore 追記用
│   └── README.md                  # 詳細説明
│
│  ┌─────────────────────────────────────────────────────────────┐
│  │  ローカル作業用（git除外）                                   │
│  └─────────────────────────────────────────────────────────────┘
└── .ai/tasks/                     # ローカルタスク管理
```

---

# [1] テンプレート更新プロセス（メンテナー向け）

このリポジトリのテンプレートを最新化するためのプロセスです。
ソースリポジトリの更新に追従する際に実行します。

## ソース

[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)

| カテゴリ | ファイル数 | 内容 |
|----------|------------|------|
| Agents | 12 | planner, code-reviewer, architect 等 |
| Commands | 23 | plan, code-review, tdd, verify 等 |
| Rules | 8 | git-workflow, coding-style, security 等 |
| Skills | 16 | backend-patterns, frontend-patterns 等 |
| Contexts | 3 | dev, research, review |

## ワークフロー

```
┌─────────────────────────────────────────────────────────────────┐
│  Step 1: 準備（自動）                                            │
│  ./scripts/setup-templates.sh                                   │
├─────────────────────────────────────────────────────────────────┤
│  - ソースリポジトリをクローン → .work/source/                    │
│  - 作業ディレクトリを準備 → .work/translated/                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 2: 日本語訳（Claude Code）                                 │
│  do @prompts/collect-and-translate-claude-templates.md          │
├─────────────────────────────────────────────────────────────────┤
│  - 翻訳ガイドライン: @prompts/translate-to-ja.md                 │
│  - 入力: .work/source/                                          │
│  - 出力: .work/translated/*.ja.md                               │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 3: 汎用化（Claude Code）                                   │
│  do @prompts/generalize-claude-templates.md                     │
├─────────────────────────────────────────────────────────────────┤
│  - プロジェクト固有の記述を除去                                  │
│  - 言語/DB固有ファイルを除外                                     │
│  - プレースホルダーに置換                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 4: 配置（自動）                                            │
│  ./scripts/deploy-templates.sh                                  │
├─────────────────────────────────────────────────────────────────┤
│  - .work/translated/ → template-.claude/                        │
│  - .ja.md を .md にリネーム                                      │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 5: コミット                                                │
│  git add template-.claude/ && git commit                        │
└─────────────────────────────────────────────────────────────────┘
```

## 実行手順

### Step 1: 準備

```bash
./scripts/setup-templates.sh
```

### Step 2: 日本語訳

```
do @prompts/collect-and-translate-claude-templates.md
```

### Step 3: 汎用化

```
do @prompts/generalize-claude-templates.md
```

### Step 4: 配置

```bash
./scripts/deploy-templates.sh
```

### Step 5: コミット

```bash
git add template-.claude/
git commit -m "chore: Update claude code templates"
```

## 汎用化時の除外対象

以下は言語/DB固有のため除外:

- `go-*.md`, `golang-*.md` - Go言語固有
- `clickhouse-*.md` - ClickHouse固有
- `postgres-*.md` - PostgreSQL固有

---

# [2] プロジェクトへの適用（エンドユーザー向け）

任意のプロジェクトに Claude Code の設定を適用するためのプロセスです。

## クイックスタート

### 方法A: セットアップスクリプト（推奨）

```bash
# このリポジトリをクローン
git clone https://github.com/_linnefromice/linnefromice/claude-code-workspace.git

# 対象プロジェクトにセットアップ
./initialize-project/setup.sh /path/to/your/project
```

### 方法B: 手動コピー

```bash
# テンプレートを対象プロジェクトにコピー
cp -r template-.claude/* /path/to/your/project/.claude/

# CLAUDE.md を作成（または既存に追記）
cat initialize-project/CLAUDE_ADDITION.md >> /path/to/your/project/CLAUDE.md

# .gitignore に追加
cat initialize-project/.gitignore_ADDTION >> /path/to/your/project/.gitignore
```

## 適用されるもの

| ディレクトリ | 内容 | 用途 |
|--------------|------|------|
| `.claude/agents/` | カスタムエージェント | Task ツールから専門家として呼び出し |
| `.claude/commands/` | コマンド定義 | `/command-name` で呼び出し |
| `.claude/rules/` | 自動適用ルール | 常時適用されるガイドライン |
| `.claude/skills/` | スキル定義 | `/skill-name` で呼び出し |
| `.claude/contexts/` | コンテキスト | `--system-prompt` で起動モード切り替え |

## 適用後のカスタマイズ

テンプレートにはプレースホルダー（`{project-name}`, `{app-name}` 等）が含まれています。
プロジェクトに合わせて置換してください。

詳細は [initialize-project/README.md](./initialize-project/README.md) を参照。

---

## 推奨プラグイン

[recommended-plugins.csv](./recommended-plugins.csv) に Claude Code の推奨プラグイン一覧があります。

---

## 関連ファイル

| ファイル | 用途 |
|----------|------|
| `prompts/translate-to-ja.md` | 翻訳ガイドライン |
| `prompts/collect-and-translate-claude-templates.md` | 翻訳プロセスの詳細手順 |
| `prompts/generalize-claude-templates.md` | 汎用化プロセスの詳細手順 |

---

## ライセンス

MIT
