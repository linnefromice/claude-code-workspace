---
name: safety-guard
description: Use this skill to prevent destructive operations when working on production systems or running agents autonomously.
origin: ECC
---

# セーフティガード -- 破壊的操作の防止

## 使用タイミング

- 本番システムで作業する時
- エージェントが自律的に実行される時（フルオートモード）
- 編集を特定のディレクトリに制限したい時
- 機密性の高い操作中（マイグレーション、デプロイ、データ変更）

## 仕組み

3 つの保護モード：

### モード 1: Careful モード

破壊的コマンドを実行前にインターセプトして警告します：

```
監視パターン:
- rm -rf（特に /、~、プロジェクトルート）
- git push --force
- git reset --hard
- git checkout .（すべての変更を破棄）
- DROP TABLE / DROP DATABASE
- docker system prune
- kubectl delete
- chmod 777
- sudo rm
- npm publish（意図しない公開）
- --no-verify 付きの任意のコマンド
```

検出時: コマンドの内容を表示し、確認を求め、より安全な代替案を提案します。

### モード 2: Freeze モード

ファイル編集を特定のディレクトリツリーにロックします：

```
/safety-guard freeze src/components/
```

`src/components/` 外の Write/Edit はすべて説明付きでブロックされます。エージェントに無関係なコードに触れずに 1 つの領域に集中させたい場合に便利です。

### モード 3: Guard モード（Careful + Freeze の組み合わせ）

両方の保護がアクティブ。自律エージェントのための最大限の安全性。

```
/safety-guard guard --dir src/api/ --allow-read-all
```

エージェントは何でも読めますが、`src/api/` にのみ書き込めます。破壊的コマンドはどこでもブロックされます。

### ロック解除

```
/safety-guard off
```

## 実装

PreToolUse フックを使用して Bash、Write、Edit、MultiEdit ツールコールをインターセプトします。実行を許可する前に、アクティブなルールに対してコマンド/パスをチェックします。

## 統合

- `codex -a never` セッションでデフォルトで有効化
- ECC 2.0 のオブザーバビリティリスクスコアリングと連携
- すべてのブロックされたアクションを `~/.claude/safety-guard.log` にログ
