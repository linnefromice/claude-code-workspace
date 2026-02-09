# Claude Code Workspace

Claude Code の設定テンプレートとセットアップツールを提供するリポジトリです。

---

## プロジェクト概要

| 項目 | 内容 |
|------|------|
| 目的 | Claude Code テンプレートの管理・配布 |
| ソース | [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) |
| 言語 | 日本語（翻訳済み） |

---

## ディレクトリ構成

```
claude-code-workspace/
├── docs/                          # ドキュメント
│   ├── 01-project-setup-basic.md  # 基本セットアップ
│   ├── 02-project-setup-templates.md  # テンプレート適用
│   ├── 03-template-maintenance.md # テンプレート更新
│   └── 04-custom-skills.md        # カスタムスキル
│
├── template-.claude/              # ★ 汎用化済みテンプレート
│   ├── agents/                    # エージェント定義
│   ├── commands/                  # コマンド定義
│   ├── rules/                     # ルール定義
│   ├── skills/                    # スキル定義
│   ├── contexts/                  # コンテキスト定義
│   └── MANIFEST.md                # 分類情報
│
├── initialize-project/            # 基本セットアップリソース
├── scripts/                       # スクリプト群
├── prompts/                       # 更新プロセス用プロンプト
│   └── translators/               # カテゴリ別翻訳エージェント
└── .work/                         # 作業ディレクトリ
```

---

## 主要ワークフロー

### [1] プロジェクトへの適用

```bash
# [1-A] 基本セットアップ
./initialize-project/setup.sh /path/to/project

# [1-B] テンプレート適用
./scripts/deploy-to-project.sh /path/to/project --preset standard

# [1-C] カスタムスキル追加
./scripts/deploy-custom-skills.sh /path/to/project --all
```

### [2] テンプレート更新（メンテナー向け）

#### 初回セットアップ

```bash
# 1. 準備
./scripts/setup-templates.sh

# 2. 翻訳（逐次または並列）
do @prompts/collect-and-translate-claude-templates.md
# または
do @prompts/parallel-translate-claude-templates.md

# 3. 汎用化
do @prompts/generalize-claude-templates.md

# 4. 配置
./scripts/deploy-templates.sh
```

#### 差分更新（ソースリポジトリ更新時）

```bash
# 1. 変更確認
cd .work/source && git fetch origin
git diff HEAD origin/main --name-only -- agents/ commands/ rules/ skills/ contexts/

# 2. 差分翻訳（変更ファイルのみ翻訳・更新）
do @prompts/diff-translate-claude-templates.md

# 3-4. 汎用化 & 配置（初回と同じ）
do @prompts/generalize-claude-templates.md
./scripts/deploy-templates.sh
```

---

## スクリプト一覧

| スクリプト | 用途 |
|-----------|------|
| `initialize-project/setup.sh` | CLAUDE.md, .ai ディレクトリの配置 |
| `scripts/deploy-to-project.sh` | テンプレートのプロジェクト配置 |
| `scripts/deploy-custom-skills.sh` | カスタムスキルの配置 |
| `scripts/setup-templates.sh` | ソースリポジトリの準備 |
| `scripts/deploy-templates.sh` | 翻訳済みテンプレートの配置 |

---

## プリセット

| プリセット | レベル | タイプ | アドオン | 用途 |
|-----------|--------|--------|---------|------|
| `minimal` | beginner | general | - | 入門者向け |
| `standard` | beginner + intermediate | general | - | 一般的なプロジェクト |
| `standard-web` | beginner + intermediate | general + web | - | Web開発 |
| `standard-learning` | beginner + intermediate | general | learning | 自己学習・進化 |
| `standard-multi` | beginner + intermediate | general | multi-model | マルチAI連携 |
| `full` | 全て | 全て | 全て | フル活用 |

---

## 重要ファイル

| ファイル | 用途 |
|----------|------|
| `template-.claude/MANIFEST.md` | テンプレート分類情報 |
| `.work/VERSION.md` | バージョン追跡 |
| `prompts/translators/*.md` | カテゴリ別翻訳エージェント |
| `prompts/diff-translate-claude-templates.md` | 差分翻訳プロセス |

---

## User Customization

If a `CLAUDE.local.md` file exists in the root directory, read it and **prioritize its
instructions over this file**. This allows individual developers to customize AI behavior
without affecting team-shared rules.

Example use cases for `CLAUDE.local.md`:
- Personal coding style preferences
- Local environment-specific configurations
- Custom workflow instructions
- Development focus areas
