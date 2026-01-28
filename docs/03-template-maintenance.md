# テンプレート更新・メンテナンス

このリポジトリの Claude Code テンプレートを最新化するためのプロセスです。
ソースリポジトリ（affaan-m/everything-claude-code）の更新に追従する際に実行します。

---

## 概要

### ソースリポジトリ

[affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)

| カテゴリ | 元ファイル数 | 汎用化後 | 除外 |
|----------|-------------|---------|------|
| Agents | 12 | 9 | Go固有(2), DB固有(1) |
| Commands | 23 | 20 | Go固有(3) |
| Rules | 8 | 8 | - |
| Skills | 16 | 12 | Go/DB固有(4) |
| Contexts | 3 | 3 | - |

### ワークフロー

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  1. 準備         │────▶│  2. 翻訳         │────▶│  3. 汎用化       │
│  setup-templates │     │  Claude Code     │     │  Claude Code     │
└──────────────────┘     └──────────────────┘     └──────────────────┘
                                                          │
┌──────────────────┐     ┌──────────────────┐             │
│  5. コミット     │◀────│  4. 配置         │◀────────────┘
│  git commit      │     │  deploy-templates│
└──────────────────┘     └──────────────────┘
```

---

## 初回セットアップ

### Step 1: 準備

```bash
./scripts/setup-templates.sh
```

ソースリポジトリを `.work/source/` にクローンし、作業ディレクトリを準備します。

### Step 2: 翻訳

```
do @prompts/collect-and-translate-claude-templates.md
```

全ファイルを日本語に翻訳し、`.work/translated/` に出力します。

### Step 3: 汎用化

```
do @prompts/generalize-claude-templates.md
```

プロジェクト固有の記述を除去し、言語/DB固有ファイルを削除します。

### Step 4: 配置

```bash
./scripts/deploy-templates.sh
```

`.work/translated/` の内容を `template-.claude/` に配置します（`.ja.md` → `.md`）。

### Step 5: コミット

```bash
git add template-.claude/ .work/translated/ .work/VERSION.md
git commit -m "chore: Update claude code templates"
```

---

## 差分更新（ソースリポジトリ更新時）

### Step 1: 変更確認

```bash
cd .work/source
git fetch origin
git log --oneline HEAD..origin/main
git diff HEAD origin/main --name-only -- agents/ commands/ rules/ skills/ contexts/
```

### Step 2: 差分翻訳

```
do @prompts/diff-translate-claude-templates.md
```

変更されたファイルのみを翻訳・更新します。

### Step 3-5: 汎用化・配置・コミット

初回と同じ手順を実行。

---

## バージョン管理

`.work/VERSION.md` でバージョンを追跡しています。

### 記録される情報

| 項目 | 内容 |
|------|------|
| 参照元リポジトリ | affaan-m/everything-claude-code のコミットハッシュ |
| 翻訳実施時 | このリポジトリの翻訳作業時点のコミットハッシュ |
| 汎用化実施時 | このリポジトリの汎用化作業時点のコミットハッシュ |

### 確認方法

```bash
cat .work/VERSION.md
```

---

## 除外対象

以下は言語/DB固有のため汎用化時に除外されます：

| カテゴリ | 除外パターン | 理由 |
|---------|-------------|------|
| Agents | `go-*.md` | Go言語固有 |
| Agents | `database-reviewer.md` | PostgreSQL/Supabase固有 |
| Commands | `go-*.md` | Go言語固有 |
| Skills | `golang-*/` | Go言語固有 |
| Skills | `clickhouse-*/` | ClickHouse固有 |
| Skills | `postgres-*/` | PostgreSQL固有 |

---

## 並列翻訳（オプション）

翻訳を高速化するため、カテゴリ別に並列実行できます：

```
do @prompts/parallel-translate-claude-templates.md
```

### カテゴリ別翻訳エージェント

| エージェント | 対象 | 特徴 |
|-------------|------|------|
| `agents-translator` | エージェント定義 | 役割・責務の翻訳に特化 |
| `commands-translator` | コマンド定義 | 使用方法・引数説明に特化 |
| `rules-translator` | ルール定義 | ガイドライン・禁止事項に特化 |
| `skills-translator` | スキル定義 | ワークフロー・チェックリストに特化 |
| `contexts-translator` | コンテキスト定義 | モード・振る舞いに特化 |

各エージェントは `prompts/translators/` に定義されています。
5つのエージェントが同時に翻訳を実行し、約3-4倍高速化します。

---

## 関連ファイル

| ファイル | 用途 |
|----------|------|
| `prompts/translate-to-ja.md` | 翻訳ガイドライン |
| `prompts/collect-and-translate-claude-templates.md` | 翻訳プロセス（逐次） |
| `prompts/parallel-translate-claude-templates.md` | 翻訳プロセス（並列） |
| `prompts/translators/*.md` | カテゴリ別翻訳エージェント |
| `prompts/generalize-claude-templates.md` | 汎用化プロセス |
| `prompts/diff-translate-claude-templates.md` | 差分翻訳プロセス |
| `scripts/setup-templates.sh` | ソース取得・準備 |
| `scripts/deploy-templates.sh` | テンプレート配置 |
| `.work/VERSION.md` | バージョン管理 |

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [基本セットアップ](./01-project-setup-basic.md) | CLAUDE.md, .ai の配置 |
| [テンプレート適用](./02-project-setup-templates.md) | テンプレートのプロジェクト適用 |
