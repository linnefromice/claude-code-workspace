# Claude Code テンプレート収集・翻訳プロンプト

## 概要

`affaan-m/everything-claude-code` リポジトリから Claude Code の設定ファイルを収集し、日本語訳するためのプロンプト。

---

## ソースリポジトリ

```
https://github.com/affaan-m/everything-claude-code
```

### 収集対象

| カテゴリ | パス | ファイル数 |
|----------|------|------------|
| Agents | `agents/*.md` | 12 |
| Commands | `commands/*.md` | 23 |
| Rules | `rules/*.md` | 8 |
| Skills | `skills/*/SKILL.md` | 16 |
| Contexts | `contexts/*.md` | 3 |
| README | `README.md` | 1 |

---

## 実行手順

### Step 1: 作業ディレクトリの準備

```bash
# 作業用ディレクトリを作成
mkdir -p .claude-templates-work
cd .claude-templates-work

# リポジトリをクローン（shallow clone で軽量化）
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git source
```

### Step 2: 翻訳対象ファイルの確認

```bash
cd source

# 対象ファイル一覧
echo "=== Agents ===" && ls agents/*.md | grep -v "CLAUDE.md"
echo "=== Commands ===" && ls commands/*.md | grep -v "CLAUDE.md"
echo "=== Rules ===" && ls rules/*.md | grep -v "CLAUDE.md"
echo "=== Skills ===" && ls skills/*/SKILL.md 2>/dev/null
echo "=== Contexts ===" && ls contexts/*.md | grep -v "CLAUDE.md"
echo "=== README ===" && ls README.md
```

### Step 3: 日本語訳の実行

以下のプロンプトを Claude Code に入力して翻訳を実行:

```
@translate-to-ja.md の指示に従って、以下のファイルを日本語訳してください。

翻訳対象:
1. README.md → README.ja.md
2. agents/*.md → agents/*.ja.md
3. commands/*.md → commands/*.ja.md
4. rules/*.md → rules/*.ja.md
5. skills/*/SKILL.md → skills/*.ja.md
6. contexts/*.md → contexts/*.ja.md

除外:
- CLAUDE.md（設定ファイルのため）
- 既存の *.ja.md ファイル
```

### Step 4: 翻訳結果の収集

```bash
# 翻訳済みファイルを出力ディレクトリにコピー
mkdir -p ../translated/{agents,commands,rules,skills,contexts}

cp README.ja.md ../translated/
cp agents/*.ja.md ../translated/agents/
cp commands/*.ja.md ../translated/commands/
cp rules/*.ja.md ../translated/rules/
cp skills/*.ja.md ../translated/skills/
cp contexts/*.ja.md ../translated/contexts/
```

---

## 翻訳ガイドライン

### Frontmatter (YAML)

```yaml
# 翻訳する
description: "..." → 日本語に翻訳

# 翻訳しない（英語のまま）
name: agent-name
tools: [Read, Grep, Glob]
model: opus
```

### 本文

| 項目 | 対応 |
|------|------|
| 見出し | 日本語に翻訳 |
| 説明文 | 日本語に翻訳 |
| コード内コメント | 日本語に翻訳 |
| 技術用語 | 英語のまま（Redis, API, CDN 等） |
| コマンド例 | 英語のまま |
| 変数名 | 英語のまま |

### 文体

- です/ます調（丁寧語）
- Markdown構造を維持
- リンク・参照を維持

---

## 出力ファイル命名規則

| ソース | 出力 |
|--------|------|
| `filename.md` | `filename.ja.md` |
| `skills/<name>/SKILL.md` | `skills/<name>.ja.md` |

---

## 翻訳後のファイル一覧（期待値）

```
translated/
├── README.ja.md
├── agents/
│   ├── architect.ja.md
│   ├── build-error-resolver.ja.md
│   ├── code-reviewer.ja.md
│   ├── database-reviewer.ja.md
│   ├── doc-updater.ja.md
│   ├── e2e-runner.ja.md
│   ├── go-build-resolver.ja.md
│   ├── go-reviewer.ja.md
│   ├── planner.ja.md
│   ├── refactor-cleaner.ja.md
│   ├── security-reviewer.ja.md
│   └── tdd-guide.ja.md
├── commands/
│   ├── build-fix.ja.md
│   ├── checkpoint.ja.md
│   ├── code-review.ja.md
│   ├── e2e.ja.md
│   ├── eval.ja.md
│   ├── evolve.ja.md
│   ├── go-build.ja.md
│   ├── go-review.ja.md
│   ├── go-test.ja.md
│   ├── instinct-export.ja.md
│   ├── instinct-import.ja.md
│   ├── instinct-status.ja.md
│   ├── learn.ja.md
│   ├── orchestrate.ja.md
│   ├── plan.ja.md
│   ├── refactor-clean.ja.md
│   ├── setup-pm.ja.md
│   ├── skill-create.ja.md
│   ├── tdd.ja.md
│   ├── test-coverage.ja.md
│   ├── update-codemaps.ja.md
│   ├── update-docs.ja.md
│   └── verify.ja.md
├── rules/
│   ├── agents.ja.md
│   ├── coding-style.ja.md
│   ├── git-workflow.ja.md
│   ├── hooks.ja.md
│   ├── patterns.ja.md
│   ├── performance.ja.md
│   ├── security.ja.md
│   └── testing.ja.md
├── skills/
│   ├── backend-patterns.ja.md
│   ├── clickhouse-io.ja.md
│   ├── coding-standards.ja.md
│   ├── continuous-learning-v2.ja.md
│   ├── continuous-learning.ja.md
│   ├── eval-harness.ja.md
│   ├── frontend-patterns.ja.md
│   ├── golang-patterns.ja.md
│   ├── golang-testing.ja.md
│   ├── iterative-retrieval.ja.md
│   ├── postgres-patterns.ja.md
│   ├── project-guidelines-example.ja.md
│   ├── security-review.ja.md
│   ├── strategic-compact.ja.md
│   ├── tdd-workflow.ja.md
│   └── verification-loop.ja.md
└── contexts/
    ├── dev.ja.md
    ├── research.ja.md
    └── review.ja.md
```

---

## 注意事項

1. **CLAUDE.md は翻訳しない** - 設定ファイルのため
2. **Skills のサブファイルは翻訳しない** - SKILL.md のみが対象
3. **既存の .ja.md は削除してから翻訳** - 重複を防ぐ
4. **Go 関連ファイルは汎用テンプレートでは除外検討** - 言語固有のため

---

## 次のステップ

翻訳完了後、`汎用化プロンプト` を使用してプロジェクト固有の記述を除去:
- 参照: `.ai/tasks/prompts/generalize-claude-templates.md`（別途作成）
