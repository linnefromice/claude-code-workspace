---
name: instinct-import
description: ファイルまたはURLからプロジェクト/グローバルスコープにインスティンクトをインポート
command: true
---

# インスティンクトインポートコマンド

## 実装

プラグインルートパスを使用してインスティンクトCLIを実行:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/scripts/instinct-cli.py" import <file-or-url> [--dry-run] [--force] [--min-confidence 0.7] [--scope project|global]
```

`CLAUDE_PLUGIN_ROOT` が設定されていない場合（手動インストール）:

```bash
python3 ~/.claude/skills/continuous-learning-v2/scripts/instinct-cli.py import <file-or-url>
```

ローカルファイルパスまたはHTTP(S) URLからインスティンクトをインポートします。

## 使用方法

```
/instinct-import team-instincts.yaml
/instinct-import https://github.com/org/repo/instincts.yaml
/instinct-import team-instincts.yaml --dry-run
/instinct-import team-instincts.yaml --scope global --force
```

## 処理内容

1. インスティンクトファイルを取得（ローカルパスまたはURL）
2. フォーマットを解析・検証
3. 既存インスティンクトとの重複をチェック
4. 新しいインスティンクトをマージまたは追加
5. 継承インスティンクトディレクトリに保存:
   - プロジェクトスコープ: `~/.claude/homunculus/projects/<project-id>/instincts/inherited/`
   - グローバルスコープ: `~/.claude/homunculus/instincts/inherited/`

## インポートプロセス

```
 Importing instincts from: team-instincts.yaml
================================================

Found 12 instincts to import.

Analyzing conflicts...

## 新規インスティンクト (8)
以下が追加されます:
  ✓ use-zod-validation (confidence: 0.7)
  ✓ prefer-named-exports (confidence: 0.65)
  ✓ test-async-functions (confidence: 0.8)
  ...

## 重複インスティンクト (3)
既に類似のインスティンクトがあります:
  WARNING: prefer-functional-style
     ローカル: 0.8 confidence, 12 observations
     インポート: 0.7 confidence
     → ローカルを保持（より高い信頼度）

  WARNING: test-first-workflow
     ローカル: 0.75 confidence
     インポート: 0.9 confidence
     → インポートで更新（より高い信頼度）

8件追加、1件更新しますか？
```

## マージ動作

既存IDのインスティンクトをインポートする場合:
- より高い信頼度のインポートは更新候補になる
- 同等/低い信頼度のインポートはスキップされる
- `--force` が使用されない限りユーザーの確認が必要

## ソース追跡

インポートされたインスティンクトには以下がマークされます:
```yaml
source: inherited
scope: project
imported_from: "team-instincts.yaml"
project_id: "a1b2c3d4e5f6"
project_name: "my-project"
```

## フラグ

- `--dry-run`: インポートせずにプレビュー
- `--force`: 確認プロンプトをスキップ
- `--min-confidence <n>`: 閾値以上のインスティンクトのみインポート
- `--scope <project|global>`: ターゲットスコープを選択（デフォルト: `project`）

## 出力

インポート後:
```
PASS: インポート完了!

追加: 8インスティンクト
更新: 1インスティンクト
スキップ: 3インスティンクト（同等/より高い信頼度が既に存在）

新しいインスティンクト保存先: ~/.claude/homunculus/instincts/inherited/

/instinct-status を実行してすべてのインスティンクトを確認。
```
