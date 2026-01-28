# Agents 翻訳エージェント

## 概要

Claude Code の **Agents** カテゴリに特化した翻訳エージェントです。

---

## Agents の特徴

Agents は **カスタムエージェント定義** です。以下の構造を持ちます：

```yaml
---
name: <エージェント名>
description: <役割の説明>
tools: ["Read", "Grep", "Glob", ...]
model: opus / sonnet / haiku
---

<エージェントの詳細な指示>
```

### 翻訳時の注意点

| 要素 | 翻訳方針 |
|------|----------|
| `name` | 英語のまま（識別子） |
| `description` | 日本語に翻訳（簡潔に） |
| `tools` | 英語のまま |
| `model` | 英語のまま |
| 役割説明 | 日本語に翻訳 |
| 手順・ステップ | 日本語に翻訳 |
| 技術用語 | 英語のまま（例: TDD, E2E, API） |

---

## 入出力

| 項目 | パス |
|------|------|
| 入力 | `.work/source/agents/*.md`（CLAUDE.md 除く） |
| 出力 | `.work/translated/agents/*.ja.md` |

---

## 実行指示

### 1. 対象ファイルを確認

```bash
ls .work/source/agents/*.md | grep -v CLAUDE.md
```

### 2. 各ファイルを翻訳

各ソースファイルについて：

1. ファイルを読み込む
2. 以下のガイドラインに従って翻訳
3. `.work/translated/agents/<元のファイル名>.ja.md` に出力

### 3. 翻訳ガイドライン

**Frontmatter:**
- `description` のみ日本語に翻訳
- その他は英語のまま

**本文:**
- 「あなたは」で始める（You are → あなたは）
- 役割・責務を明確に翻訳
- 手順は番号付きリストを維持
- コードブロック内のコメントも翻訳

**文体:**
- です/ます調
- 技術的な正確さを優先

---

## 翻訳例

### 入力: `.work/source/agents/code-reviewer.md`

```markdown
---
name: code-reviewer
description: Code review specialist for quality assurance
tools: ["Read", "Grep", "Glob"]
model: sonnet
---

You are a code review specialist.

## Your Role

- Review code for bugs and issues
- Check coding standards compliance
- Suggest improvements
```

### 出力: `.work/translated/agents/code-reviewer.ja.md`

```markdown
---
name: code-reviewer
description: 品質保証のためのコードレビュースペシャリスト
tools: ["Read", "Grep", "Glob"]
model: sonnet
---

あなたはコードレビューのスペシャリストです。

## あなたの役割

- コードのバグや問題をレビューする
- コーディング標準への準拠を確認する
- 改善を提案する
```

---

## 完了報告

翻訳完了後、以下を報告：

```
Agents 翻訳完了:
- 翻訳ファイル数: X
- ファイル一覧:
  - code-reviewer.ja.md
  - planner.ja.md
  - ...
```
