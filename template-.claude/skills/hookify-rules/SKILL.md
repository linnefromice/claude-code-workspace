---
name: hookify-rules
description: ユーザーが hookify ルールの作成、hook ルールの記述、hookify の設定、hookify ルールの追加を依頼した場合、または hookify ルールの構文やパターンについてガイダンスを必要とする場合に、このスキルを使用します。
---

# Hookify ルールの記述

## 概要

Hookify ルールは、YAML frontmatter を持つ Markdown ファイルであり、監視するパターンと、それらのパターンにマッチしたときに表示するメッセージを定義します。ルールは `.claude/hookify.{rule-name}.local.md` ファイルに保存されます。

## ルールファイルフォーマット

### 基本構造

```markdown
---
name: rule-identifier
enabled: true
event: bash|file|stop|prompt|all
pattern: regex-pattern-here
---

このルールがトリガーされたときに Claude に表示するメッセージです。
Markdown フォーマット、警告、提案などを含めることができます。
```

### Frontmatter フィールド

| フィールド | 必須 | 値 | 説明 |
|-------|----------|--------|-------------|
| name | 必須 | kebab-case 文字列 | 一意な識別子（動詞先頭: warn-*、block-*、require-*） |
| enabled | 必須 | true/false | 削除せずに切り替え可能 |
| event | 必須 | bash/file/stop/prompt/all | このルールをトリガーするフックイベント |
| action | 任意 | warn/block | warn（デフォルト）はメッセージを表示、block は操作を防止 |
| pattern | 必須* | 正規表現文字列 | マッチするパターン（*複雑なルールでは conditions を使用） |

### 高度なフォーマット（複数条件）

```markdown
---
name: warn-env-api-keys
enabled: true
event: file
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.env$
  - field: new_text
    operator: contains
    pattern: API_KEY
---

.env ファイルに API キーを追加しています。このファイルが .gitignore に含まれていることを確認してください！
```

**イベント別の条件フィールド:**
- bash: `command`
- file: `file_path`, `new_text`, `old_text`, `content`
- prompt: `user_prompt`

**演算子:** `regex_match`, `contains`, `equals`, `not_contains`, `starts_with`, `ends_with`

ルールがトリガーされるには、すべての条件がマッチする必要があります。

## イベントタイプガイド

### bash イベント
Bash コマンドのパターンにマッチ:
- 危険なコマンド: `rm\s+-rf`, `dd\s+if=`, `mkfs`
- 権限昇格: `sudo\s+`, `su\s+`
- 権限の問題: `chmod\s+777`

### file イベント
Edit/Write/MultiEdit 操作にマッチ:
- デバッグコード: `console\.log\(`, `debugger`
- セキュリティリスク: `eval\(`, `innerHTML\s*=`
- 機密ファイル: `\.env$`, `credentials`, `\.pem$`

### stop イベント
完了時のチェックおよびリマインダーです。パターン `.*` は常にマッチします。

### prompt イベント
ワークフロー強制のためにユーザープロンプト内容にマッチします。

## パターン記述のコツ

### 正規表現の基本
- 特殊文字をエスケープ: `.` は `\.`、`(` は `\(`
- `\s` 空白、`\d` 数字、`\w` 単語文字
- `+` 1 回以上、`*` 0 回以上、`?` 任意
- `|` OR 演算子

### よくある落とし穴
- **範囲が広すぎる**: `log` は "login" や "dialog" にマッチします。`console\.log\(` を使用してください
- **具体的すぎる**: `rm -rf /tmp` ではなく `rm\s+-rf` を使用してください
- **YAML エスケープ**: クォートなしのパターンを使用してください。クォート付き文字列は `\\s` が必要です

### テスト
```bash
python3 -c "import re; print(re.search(r'your_pattern', 'test text'))"
```

## ファイル構成

- **場所**: プロジェクトルートの `.claude/` ディレクトリ
- **命名**: `.claude/hookify.{descriptive-name}.local.md`
- **Gitignore**: `.claude/*.local.md` を `.gitignore` に追加

## コマンド

- `/hookify [description]` - 新規ルール作成（引数なしの場合は会話を自動解析）
- `/hookify-list` - すべてのルールをテーブル形式で表示
- `/hookify-configure` - ルールのオン/オフを対話的に切り替え
- `/hookify-help` - 完全なドキュメント

## クイックリファレンス

最小限のルール:
```markdown
---
name: my-rule
enabled: true
event: bash
pattern: dangerous_command
---
ここに警告メッセージ
```
