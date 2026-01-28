# Evalコマンド

Eval駆動開発ワークフローを管理。

## 使用方法

`/eval [define|check|report|list] [feature-name]`

## Evalの定義

`/eval define feature-name`

新しいeval定義を作成:

1. `.claude/evals/feature-name.md`をテンプレートで作成:

```markdown
## EVAL: feature-name
作成日: $(date)

### 機能Eval
- [ ] [機能1の説明]
- [ ] [機能2の説明]

### リグレッションEval
- [ ] [既存動作1がまだ動作する]
- [ ] [既存動作2がまだ動作する]

### 成功基準
- 機能evalでpass@3 > 90%
- リグレッションevalでpass^3 = 100%
```

2. ユーザーに具体的な基準を入力するよう促す

## Evalのチェック

`/eval check feature-name`

機能のevalを実行:

1. `.claude/evals/feature-name.md`からeval定義を読み取り
2. 各機能evalについて:
   - 基準を検証しようとする
   - PASS/FAILを記録
   - `.claude/evals/feature-name.log`に試行をログ
3. 各リグレッションevalについて:
   - 関連テストを実行
   - ベースラインと比較
   - PASS/FAILを記録
4. 現在のステータスを報告:

```
EVAL CHECK: feature-name
========================
機能: X/Y 合格
リグレッション: X/Y 合格
ステータス: 進行中 / 準備完了
```

## Evalのレポート

`/eval report feature-name`

包括的なevalレポートを生成:

```
EVAL REPORT: feature-name
=========================
生成日: $(date)

機能EVAL
----------------
[eval-1]: PASS (pass@1)
[eval-2]: PASS (pass@2) - リトライ必要
[eval-3]: FAIL - ノート参照

リグレッションEVAL
----------------
[test-1]: PASS
[test-2]: PASS
[test-3]: PASS

メトリクス
-------
機能 pass@1: 67%
機能 pass@3: 100%
リグレッション pass^3: 100%

ノート
-----
[問題、エッジケース、観察]

推奨
--------------
[SHIP / 要作業 / ブロック]
```

## Evalのリスト

`/eval list`

すべてのeval定義を表示:

```
EVAL DEFINITIONS
================
feature-auth      [3/5 合格] 進行中
feature-search    [5/5 合格] 準備完了
feature-export    [0/4 合格] 未開始
```

## 引数

$ARGUMENTS:
- `define <name>` - 新しいeval定義を作成
- `check <name>` - evalを実行・チェック
- `report <name>` - 完全レポートを生成
- `list` - すべてのevalを表示
- `clean` - 古いevalログを削除（最後の10回を保持）
