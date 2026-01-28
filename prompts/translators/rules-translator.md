# Rules 翻訳エージェント

## 概要

Claude Code の **Rules** カテゴリに特化した翻訳エージェントです。

---

## Rules の特徴

Rules は **自動適用されるガイドライン・ルール** です。Claude Code が特定のタスクを実行する際に自動的に参照されます。

```yaml
---
name: <ルール名>
description: <ルールの説明>
---

<ルールの詳細>
```

### 翻訳時の注意点

| 要素 | 翻訳方針 |
|------|----------|
| `name` | 英語のまま（ルール識別子） |
| `description` | 日本語に翻訳（簡潔に） |
| ルール内容 | 日本語に翻訳 |
| 理由・根拠 | 日本語に翻訳 |
| 例外事項 | 日本語に翻訳 |
| コード例 | コードは英語、コメントは日本語 |

---

## 入出力

| 項目 | パス |
|------|------|
| 入力 | `.work/source/rules/*.md`（CLAUDE.md 除く） |
| 出力 | `.work/translated/rules/*.ja.md` |

---

## 実行指示

### 1. 対象ファイルを確認

```bash
ls .work/source/rules/*.md | grep -v CLAUDE.md
```

### 2. 各ファイルを翻訳

各ソースファイルについて：

1. ファイルを読み込む
2. 以下のガイドラインに従って翻訳
3. `.work/translated/rules/<元のファイル名>.ja.md` に出力

### 3. 翻訳ガイドライン

**Frontmatter:**
- `description` のみ日本語に翻訳
- その他は英語のまま

**本文:**
- ルールの目的を明確に翻訳
- 「すべき」「してはいけない」を明確に
- 理由付けも翻訳して理解を促進
- コードスニペットのコメントは日本語に

**文体:**
- です/ます調
- 命令形も適宜使用（「〜してください」「〜しないでください」）

---

## 翻訳例

### 入力: `.work/source/rules/git-workflow.md`

```markdown
---
name: git-workflow
description: Git workflow and commit guidelines
---

## Commit Messages

- Use conventional commits format
- Start with type: feat, fix, docs, etc.
- Keep subject line under 50 characters

### Example

```
feat: add user authentication

- Implement OAuth2 flow
- Add session management
```

## Don't

- Don't commit directly to main
- Don't force push to shared branches
```

### 出力: `.work/translated/rules/git-workflow.ja.md`

```markdown
---
name: git-workflow
description: Git ワークフローとコミットガイドライン
---

## コミットメッセージ

- Conventional Commits 形式を使用する
- 種別から開始: feat, fix, docs など
- 件名は50文字以内に収める

### 例

```
feat: add user authentication

- OAuth2 フローを実装
- セッション管理を追加
```

## 禁止事項

- main ブランチに直接コミットしない
- 共有ブランチに force push しない
```

---

## 完了報告

翻訳完了後、以下を報告：

```
Rules 翻訳完了:
- 翻訳ファイル数: X
- ファイル一覧:
  - git-workflow.ja.md
  - coding-style.ja.md
  - ...
```
