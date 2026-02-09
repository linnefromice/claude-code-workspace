---
name: instinct-import
description: チームメイト、Skill Creator、他のソースからインスティンクトをインポート
command: true
---

# インスティンクトインポートコマンド

## 実装

プラグインルートパスを使用してインスティンクトCLIを実行:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/scripts/instinct-cli.py" import <file-or-url> [--dry-run] [--force] [--min-confidence 0.7]
```

`CLAUDE_PLUGIN_ROOT` が設定されていない場合（手動インストール）:

```bash
python3 ~/.claude/skills/continuous-learning-v2/scripts/instinct-cli.py import <file-or-url>
```

以下からインスティンクトをインポート:
- チームメイトのエクスポート
- Skill Creator（リポジトリ分析）
- コミュニティコレクション
- 以前のマシンバックアップ

## 使用方法

```
/instinct-import team-instincts.yaml
/instinct-import https://github.com/org/repo/instincts.yaml
/instinct-import --from-skill-creator acme/webapp
```

## 処理内容

1. インスティンクトファイルを取得（ローカルパスまたはURL）
2. フォーマットを解析・検証
3. 既存インスティンクトとの重複をチェック
4. 新しいインスティンクトをマージまたは追加
5. `~/.claude/homunculus/instincts/inherited/`に保存

## マージ戦略

### 重複の場合
既存のものと一致するインスティンクトをインポートする際:
- **高い信頼度が優先**: 高い信頼度のものを保持
- **証拠をマージ**: 観察数を結合
- **タイムスタンプを更新**: 最近検証済みとしてマーク

### 競合の場合
既存のものと矛盾するインスティンクトをインポートする際:
- **デフォルトでスキップ**: 競合するインスティンクトをインポートしない
- **レビュー用にフラグ**: 両方に注意が必要とマーク
- **手動解決**: ユーザーがどちらを保持するか決定

## ソース追跡

インポートされたインスティンクトには以下がマーク:
```yaml
source: "inherited"
imported_from: "team-instincts.yaml"
imported_at: "2025-01-22T10:30:00Z"
original_source: "session-observation"  # または "repo-analysis"
```

## フラグ

- `--dry-run`: インポートせずにプレビュー
- `--force`: 競合があってもインポート
- `--merge-strategy <higher|local|import>`: 重複の処理方法
- `--from-skill-creator <owner/repo>`: Skill Creator分析からインポート
- `--min-confidence <n>`: 閾値以上のインスティンクトのみインポート

## 出力

インポート後:
```
✅ インポート完了!

追加: 8インスティンクト
更新: 1インスティンクト
スキップ: 3インスティンクト（2重複、1競合）

新しいインスティンクト保存先: ~/.claude/homunculus/instincts/inherited/

/instinct-statusを実行してすべてのインスティンクトを確認。
```
