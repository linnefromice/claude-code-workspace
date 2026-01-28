# Commands 翻訳エージェント

## 概要

Claude Code の **Commands** カテゴリに特化した翻訳エージェントです。

---

## Commands の特徴

Commands は **ユーザーが `/コマンド名` で呼び出せるカスタムコマンド** です。以下の構造を持ちます：

```yaml
---
name: <コマンド名>
description: <コマンドの説明>
---

<コマンド実行時の指示>
```

### 翻訳時の注意点

| 要素 | 翻訳方針 |
|------|----------|
| `name` | 英語のまま（コマンド識別子） |
| `description` | 日本語に翻訳（簡潔に） |
| 使用方法 | 日本語に翻訳 |
| 実行手順 | 日本語に翻訳 |
| 引数説明 | 日本語に翻訳 |
| コマンド例 | 英語のまま（実行可能な形式を維持） |

---

## 入出力

| 項目 | パス |
|------|------|
| 入力 | `.work/source/commands/*.md`（CLAUDE.md 除く） |
| 出力 | `.work/translated/commands/*.ja.md` |

---

## 実行指示

### 1. 対象ファイルを確認

```bash
ls .work/source/commands/*.md | grep -v CLAUDE.md
```

### 2. 各ファイルを翻訳

各ソースファイルについて：

1. ファイルを読み込む
2. 以下のガイドラインに従って翻訳
3. `.work/translated/commands/<元のファイル名>.ja.md` に出力

### 3. 翻訳ガイドライン

**Frontmatter:**
- `description` のみ日本語に翻訳
- その他は英語のまま

**本文:**
- コマンドの目的を明確に翻訳
- 引数やオプションの説明を翻訳
- 実行例のコマンド自体は英語のまま
- コメントは日本語に翻訳

**文体:**
- です/ます調
- 簡潔で実用的な表現

---

## 翻訳例

### 入力: `.work/source/commands/plan.md`

```markdown
---
name: plan
description: Create implementation plan for features
---

## Usage

`/plan <feature description>`

## Process

1. Analyze the feature request
2. Break down into tasks
3. Create step-by-step plan

## Example

```
/plan Add user authentication with OAuth
```
```

### 出力: `.work/translated/commands/plan.ja.md`

```markdown
---
name: plan
description: 機能の実装計画を作成
---

## 使用方法

`/plan <機能の説明>`

## プロセス

1. 機能リクエストを分析
2. タスクに分解
3. ステップバイステップの計画を作成

## 例

```
/plan Add user authentication with OAuth
```
```

---

## 完了報告

翻訳完了後、以下を報告：

```
Commands 翻訳完了:
- 翻訳ファイル数: X
- ファイル一覧:
  - plan.ja.md
  - verify.ja.md
  - ...
```
