# claude-code-workspace

Claude Code の設定テンプレートとセットアップツールを提供するリポジトリです。

---

## 概要

| プロセス | 目的 | 詳細 |
|----------|------|------|
| **[1] プロジェクトへの適用** | テンプレートを任意のプロジェクトに適用 | [A. 基本セットアップ](#1-a-基本セットアップ) / [B. テンプレート適用](#1-b-テンプレート適用) |
| **[2] テンプレート更新** | ソースリポジトリから最新テンプレートを取得・翻訳・汎用化 | [詳細ドキュメント](./docs/03-template-maintenance.md) |

---

## ディレクトリ構成

```
claude-code-workspace/
│
├── README.md                      # このファイル
├── docs/                          # ドキュメント
│   ├── 01-project-setup-basic.md  # 基本セットアップ
│   ├── 02-project-setup-templates.md  # テンプレート適用
│   └── 03-template-maintenance.md # テンプレート更新
│
├── template-.claude/              # ★ 汎用化済みテンプレート
│   ├── agents/                    # カスタムエージェント
│   ├── commands/                  # コマンド定義
│   ├── rules/                     # 自動適用ルール
│   ├── skills/                    # スキル定義
│   └── contexts/                  # 起動モード切り替え用
│
├── initialize-project/            # 基本セットアップリソース
├── scripts/                       # スクリプト群
├── prompts/                       # 更新プロセス用プロンプト
└── .work/                         # 作業ディレクトリ
```

---

# [1] プロジェクトへの適用

## [1-A] 基本セットアップ

CLAUDE.md と .ai ディレクトリなどの基本設定を配置します。

```bash
./initialize-project/setup.sh /path/to/your/project
```

→ [詳細ドキュメント](./docs/01-project-setup-basic.md)

## [1-B] テンプレート適用

Claude Code テンプレート（エージェント、コマンド、ルール等）を配置します。

```bash
./scripts/deploy-to-project.sh /path/to/your/project
```

**オプション:**

```bash
# 特定のカテゴリのみ
./scripts/deploy-to-project.sh /path/to/project --only agents,rules

# ドライラン
./scripts/deploy-to-project.sh /path/to/project --dry-run
```

→ [詳細ドキュメント](./docs/02-project-setup-templates.md)

---

## 適用されるテンプレート

| カテゴリ | 内容 | ファイル数 |
|---------|------|-----------|
| `agents/` | planner, code-reviewer, architect 等 | 9 |
| `commands/` | plan, verify, code-review 等 | 20 |
| `rules/` | git-workflow, coding-style, security 等 | 8 |
| `skills/` | tdd-workflow, verification-loop 等 | 12 |
| `contexts/` | dev, research, review | 3 |

---

# [2] テンプレート更新（メンテナー向け）

ソースリポジトリ（[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)）の更新に追従するためのプロセスです。

```bash
# 1. 準備
./scripts/setup-templates.sh

# 2. 翻訳
do @prompts/collect-and-translate-claude-templates.md

# 3. 汎用化
do @prompts/generalize-claude-templates.md

# 4. 配置
./scripts/deploy-templates.sh

# 5. コミット
git add template-.claude/ .work/translated/ .work/VERSION.md
git commit -m "chore: Update claude code templates"
```

→ [詳細ドキュメント](./docs/03-template-maintenance.md)

---

## 推奨プラグイン

[recommended-plugins.csv](./recommended-plugins.csv) に Claude Code の推奨プラグイン一覧があります。

---

## ライセンス

MIT
