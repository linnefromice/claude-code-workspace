---
description: hookify システムのヘルプを表示
---

包括的な hookify ドキュメントを表示します。

## フックシステムの概要

Hookify は、望ましくない動作を防止するために Claude Code のフックシステムと統合するルールファイルを作成します。

### イベントタイプ

- `bash`: Bash ツール使用時にトリガーされ、コマンドパターンにマッチします
- `file`: Write / Edit ツール使用時にトリガーされ、ファイルパスにマッチします
- `stop`: セッション終了時にトリガーされます
- `prompt`: ユーザーメッセージ送信時にトリガーされ、入力パターンにマッチします
- `all`: すべてのイベントでトリガーされます

### ルールファイルフォーマット

ファイルは `.claude/hookify.{name}.local.md` として保存されます:

```yaml
---
name: descriptive-name
enabled: true
event: bash|file|stop|prompt|all
action: block|warn
pattern: "regex pattern to match"
---
ルールがトリガーされたときに表示するメッセージ。
複数行をサポート。
```

### コマンド

- `/hookify [description]` は新しいルールを作成し、説明が与えられない場合は会話を自動分析します
- `/hookify-list` は設定済みルールをリストします
- `/hookify-configure` はルールのオン / オフをトグルします

### パターンのヒント

- regex 構文を使用します
- `bash` の場合はコマンド文字列全体にマッチさせます
- `file` の場合はファイルパスにマッチさせます
- デプロイする前にパターンをテストします
