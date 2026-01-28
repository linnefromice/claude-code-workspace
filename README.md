# claude-code-workspace

Claude Code の設定テンプレートとセットアップツールを提供するリポジトリです。

## 概要

このリポジトリは2つの目的を持っています：

1. **プロジェクト初期化** - 任意のプロジェクトに Claude Code の設定を適用する
2. **テンプレート管理** - Claude Code の Agents/Rules/Skills/Contexts のテンプレートを管理する

---

## ディレクトリ構成

```
claude-code-workspace/
├── README.md                    # このファイル
├── recommended-plugins.csv      # 推奨プラグイン一覧
│
├── initialize-project/          # プロジェクト初期化用リソース
│   ├── setup.sh                 # セットアップスクリプト
│   ├── CLAUDE_ADDITION.md       # CLAUDE.md 追記用テンプレート
│   ├── .gitignore_ADDTION       # .gitignore 追記用テンプレート
│   └── README.md                # 初期化の詳細説明
│
├── prompts/                     # 汎用プロンプト
│   ├── collect-and-translate-claude-templates.md
│   └── generalize-claude-templates.md
│
├── scripts/                     # 自動化スクリプト
│   ├── setup-templates.sh       # テンプレート収集準備
│   └── deploy-templates.sh      # テンプレート配置
│
├── setup-claude-code-config/    # 生成されたテンプレート（※後述のワークフローで生成）
│   ├── agents/
│   ├── commands/
│   ├── rules/
│   ├── skills/
│   └── contexts/
│
└── .ai/tasks/                   # ローカルタスク管理（git除外）
```

---

## クイックスタート

### 1. プロジェクトに Claude Code 設定を適用する

```bash
# このリポジトリをクローン
git clone https://github.com/_linnefromice/linnefromice/claude-code-workspace.git

# 対象プロジェクトにセットアップ
./initialize-project/setup.sh /path/to/your/project
```

詳細は [initialize-project/README.md](./initialize-project/README.md) を参照。

---

## テンプレート管理ワークフロー

[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) から Claude Code の設定ファイルを収集し、日本語訳・汎用化して管理します。

### ワークフロー概要

```
┌─────────────────────────────────────────────────────────────────┐
│  Step 1: セットアップ (自動)                                     │
│  ./scripts/setup-templates.sh                                   │
├─────────────────────────────────────────────────────────────────┤
│  - ソースリポジトリをクローン                                    │
│  - 作業ディレクトリ (.work/) を準備                              │
│  - 翻訳対象ファイルを一覧表示                                    │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 2: 日本語訳 (Claude Code)                                  │
│  do @prompts/collect-and-translate-claude-templates.md          │
├─────────────────────────────────────────────────────────────────┤
│  - .work/source/ から英語ファイルを読み込み                      │
│  - 日本語に翻訳                                                  │
│  - .work/translated/ に出力                                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 3: 汎用化 (Claude Code)                                    │
│  do @prompts/generalize-claude-templates.md                     │
├─────────────────────────────────────────────────────────────────┤
│  - プロジェクト固有の記述を除去                                  │
│  - プレースホルダーに置換                                        │
│  - 言語/DB固有ファイルを除外判断                                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  Step 4: 配置 (自動)                                             │
│  ./scripts/deploy-templates.sh                                  │
├─────────────────────────────────────────────────────────────────┤
│  - .work/translated/ から setup-claude-code-config/ へ配置      │
│  - .ja.md を .md にリネーム                                      │
└─────────────────────────────────────────────────────────────────┘
```

### 実行手順

#### Step 1: セットアップスクリプトを実行

```bash
./scripts/setup-templates.sh
```

出力:
- `.work/source/` - クローンされたソースリポジトリ
- `.work/translated/` - 翻訳出力用ディレクトリ（空）

#### Step 2: 日本語訳を実行

Claude Code で以下を実行:

```
do @prompts/collect-and-translate-claude-templates.md
```

プロンプトの指示に従って、`.work/source/` 内のファイルを日本語訳し、`.work/translated/` に出力します。

#### Step 3: 汎用化を実行

Claude Code で以下を実行:

```
do @prompts/generalize-claude-templates.md
```

プロンプトの指示に従って、翻訳済みファイルからプロジェクト固有の記述を除去します。

#### Step 4: 配置スクリプトを実行

```bash
./scripts/deploy-templates.sh
```

出力:
- `setup-claude-code-config/` - 汎用化されたテンプレート

---

## テンプレート構成（ソースリポジトリ）

| カテゴリ | ファイル数 | 内容 |
|----------|------------|------|
| **Agents** | 12 | planner, code-reviewer, architect 等 |
| **Commands** | 23 | plan, code-review, tdd, verify 等 |
| **Rules** | 8 | git-workflow, coding-style, security 等 |
| **Skills** | 16 | backend-patterns, frontend-patterns 等 |
| **Contexts** | 3 | dev, research, review |

### 汎用化時の除外対象

以下は言語/DB固有のため、汎用テンプレートから除外を検討:

- `go-*.md` - Go言語固有
- `golang-*.md` - Go言語固有
- `clickhouse-*.md` - ClickHouse固有
- `postgres-*.md` - PostgreSQL固有

---

## 推奨プラグイン

[recommended-plugins.csv](./recommended-plugins.csv) に Claude Code の推奨プラグイン一覧があります。

---

## 関連ファイル

| ファイル | 用途 |
|----------|------|
| `prompts/collect-and-translate-claude-templates.md` | 翻訳プロセスの詳細手順 |
| `prompts/generalize-claude-templates.md` | 汎用化プロセスの詳細手順 |
| `.ai/tasks/design/20260128151900-claude-code-config-structure.md` | 設計ドキュメント |

---

## ライセンス

MIT
