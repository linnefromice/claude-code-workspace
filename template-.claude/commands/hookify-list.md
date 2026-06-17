---
description: 設定済みのすべての hookify ルールを一覧表示
---

すべての hookify ルールを検索し、フォーマットされたテーブルで表示します。

## 手順

1. すべての `.claude/hookify.*.local.md` ファイルを検索
2. 各ファイルの frontmatter を読み取る:
   - `name`
   - `enabled`
   - `event`
   - `action`
   - `pattern`
3. テーブルとして表示:

| Rule | Enabled | Event | Pattern | File |
|------|---------|-------|---------|------|

4. ルール数を表示し、`/hookify-configure` で後から状態を変更できることをユーザーにリマインドします。
