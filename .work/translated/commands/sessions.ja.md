---
description: Claude Codeのセッション履歴、エイリアス、セッションメタデータを管理。
---

# Sessions コマンド

Claude Codeのセッション履歴を管理します -- `~/.claude/session-data/` に保存されたセッションの一覧表示、読み込み、エイリアス設定、情報表示。レガシーの `~/.claude/sessions/` からも読み取ります。

## 使用方法

`/sessions [list|load|alias|info|help] [options]`

## アクション

### セッション一覧表示

メタデータ、フィルタリング、ページネーション付きで全セッションを表示します。

スウォームのオペレーターサーフェスコンテキスト（ブランチ、ワークツリーパス、セッションの新しさ）が必要な場合は `/sessions info` を使用してください。

```bash
/sessions                              # 全セッション一覧（デフォルト）
/sessions list                         # 上記と同じ
/sessions list --limit 10              # 10セッションを表示
/sessions list --date 2026-02-01       # 日付でフィルタリング
/sessions list --search abc            # セッションIDで検索
```

### セッション読み込み

セッションの内容を読み込んで表示します（IDまたはエイリアスで指定）。

```bash
/sessions load <id|alias>             # セッションを読み込み
/sessions load 2026-02-01             # 日付で指定（IDなしセッション用）
/sessions load a1b2c3d4               # 短縮IDで指定
/sessions load my-alias               # エイリアス名で指定
```

### エイリアス作成

セッションに覚えやすいエイリアスを作成します。

```bash
/sessions alias <id> <name>           # エイリアスを作成
/sessions alias 2026-02-01 today-work # "today-work"という名前のエイリアスを作成
```

### エイリアス削除

既存のエイリアスを削除します。

```bash
/sessions alias --remove <name>        # エイリアスを削除
/sessions unalias <name>               # 上記と同じ
```

### セッション情報

セッションの詳細情報を表示します。

```bash
/sessions info <id|alias>              # セッション詳細を表示
```

### エイリアス一覧

全セッションエイリアスを表示します。

```bash
/sessions aliases                      # 全エイリアスを一覧表示
```

## オペレーター注記

- セッションファイルはヘッダーに `Project`、`Branch`、`Worktree` を保持するため、`/sessions info` で並列tmux/ワークツリー実行を区別できます。
- コマンドセンタースタイルのモニタリングには、`/sessions info`、`git diff --stat`、`scripts/hooks/cost-tracker.js` が出力するコストメトリクスを組み合わせてください。

## 引数

$ARGUMENTS:
- `list [options]` - セッション一覧表示
  - `--limit <n>` - 表示する最大セッション数（デフォルト: 50）
  - `--date <YYYY-MM-DD>` - 日付でフィルタリング
  - `--search <pattern>` - セッションIDで検索
- `load <id|alias>` - セッション内容を読み込み
- `alias <id> <name>` - セッションにエイリアスを作成
- `alias --remove <name>` - エイリアスを削除
- `unalias <name>` - `--remove` と同じ
- `info <id|alias>` - セッション統計情報を表示
- `aliases` - 全エイリアスを一覧表示
- `help` - このヘルプを表示

## 使用例

```bash
# 全セッション一覧
/sessions list

# 今日のセッションにエイリアスを作成
/sessions alias 2026-02-01 today

# エイリアスでセッションを読み込み
/sessions load today

# セッション情報を表示
/sessions info today

# エイリアスを削除
/sessions alias --remove today

# 全エイリアスを一覧表示
/sessions aliases
```

## 注意事項

- セッションはマークダウンファイルとして `~/.claude/session-data/` に保存され、レガシーの `~/.claude/sessions/` からも読み取ります
- エイリアスは `~/.claude/session-aliases.json` に保存されます
- セッションIDは短縮可能です（最初の4-8文字で通常は一意に識別可能）
- 頻繁に参照するセッションにはエイリアスを使用してください
