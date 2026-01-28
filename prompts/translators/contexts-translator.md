# Contexts 翻訳エージェント

## 概要

Claude Code の **Contexts** カテゴリに特化した翻訳エージェントです。

---

## Contexts の特徴

Contexts は **起動時のモード切り替え設定** です。Claude Code の動作モードを定義し、特定のタスクに最適化された振る舞いを指定します。

```markdown
# Context Name

Mode: <モード>
Focus: <フォーカス>

## Behavior

- <振る舞い1>
- <振る舞い2>
```

### 翻訳時の注意点

| 要素 | 翻訳方針 |
|------|----------|
| タイトル | 日本語に翻訳 |
| Mode/Focus | 日本語に翻訳 |
| Behavior | 日本語に翻訳 |
| 制約・ルール | 日本語に翻訳 |
| 具体的な指示 | 日本語に翻訳 |

---

## 入出力

| 項目 | パス |
|------|------|
| 入力 | `.work/source/contexts/*.md`（CLAUDE.md 除く） |
| 出力 | `.work/translated/contexts/*.ja.md` |

---

## 実行指示

### 1. 対象ファイルを確認

```bash
ls .work/source/contexts/*.md | grep -v CLAUDE.md
```

### 2. 各ファイルを翻訳

各ソースファイルについて：

1. ファイルを読み込む
2. 以下のガイドラインに従って翻訳
3. `.work/translated/contexts/<元のファイル名>.ja.md` に出力

### 3. 翻訳ガイドライン

**本文:**
- コンテキストの目的を明確に翻訳
- 振る舞いの指示を翻訳
- 制約やルールを翻訳

**文体:**
- です/ます調
- 指示形も使用（「〜します」「〜しません」）

---

## 翻訳例

### 入力: `.work/source/contexts/dev.md`

```markdown
# Development Context

Mode: Active development
Focus: Implementation, coding, feature building

## Behavior

- Write code first, explain later
- Prefer working solutions over perfect ones
- Be proactive with suggestions

## Constraints

- Don't refactor unless asked
- Keep changes minimal
```

### 出力: `.work/translated/contexts/dev.ja.md`

```markdown
# 開発コンテキスト

モード: アクティブ開発
フォーカス: 実装、コーディング、機能構築

## 振る舞い

- まずコードを書き、後から説明する
- 完璧な解決策より動く解決策を優先する
- 提案を積極的に行う

## 制約

- 依頼されない限りリファクタリングしない
- 変更は最小限に留める
```

---

## 完了報告

翻訳完了後、以下を報告：

```
Contexts 翻訳完了:
- 翻訳ファイル数: X
- ファイル一覧:
  - dev.ja.md
  - research.ja.md
  - review.ja.md
```
