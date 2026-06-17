---
description: dmux-workflowsとautonomous-agent-harnessのレガシースラッシュエントリーシム。スキルを直接使用することを推奨します。
---

# Orchestrateコマンド（レガシーシム）

`/orchestrate` をまだ呼び出している場合のみ使用してください。メンテナンスされているオーケストレーションガイダンスは `skills/dmux-workflows/SKILL.md` と `skills/autonomous-agent-harness/SKILL.md` にあります。

## 正規サーフェス

- 並列ペイン、ワークツリー、マルチエージェント分割には `dmux-workflows` を推奨。
- 長時間実行ループ、ガバナンス、スケジューリング、コントロールプレーンスタイルの実行には `autonomous-agent-harness` を推奨。
- このファイルは互換性のエントリーポイントとしてのみ保持してください。

## 引数

`$ARGUMENTS`

## 委譲

ここで2つ目のワークフロー仕様を維持する代わりに、オーケストレーションスキルを適用します。
- 分割/並列実行には `dmux-workflows` から開始。
- ユーザーが永続ループ、ガバナンス、またはオペレーターレイヤーの動作を求めている場合は `autonomous-agent-harness` を導入。
- ハンドオフは構造化しつつ、メンテナンスされているシーケンスルールはスキルに定義を委ねます。
Security Reviewer: [summary]

### FILES CHANGED

[変更されたすべてのファイルをリスト]

### TEST RESULTS

[テストの合否サマリー]

### SECURITY STATUS

[セキュリティの所見]

### RECOMMENDATION

[SHIP / NEEDS WORK / BLOCKED]
```

## 並列実行

独立したチェックにはエージェントを並列実行:

```markdown
### 並列フェーズ
同時に実行:
- code-reviewer（品質）
- security-reviewer（セキュリティ）
- architect（設計）

### 結果のマージ
出力を1つのレポートに統合
```

外部のtmuxペインワーカーと別々のgitワークツリーを使用する場合は `node scripts/orchestrate-worktrees.js plan.json --execute` を使用します。組み込みのオーケストレーションパターンはインプロセスのまま維持されます。ヘルパーは長時間実行またはクロスハーネスのセッション用です。

ワーカーがメインチェックアウトのダーティまたはアントラックなローカルファイルを参照する必要がある場合、プランファイルに `seedPaths` を追加します。ECCは `git worktree add` の後に選択されたパスのみを各ワーカーワークツリーにオーバーレイし、ブランチを分離しつつ進行中のローカルスクリプト、プラン、ドキュメントを公開します。

```json
{
  "sessionName": "workflow-e2e",
  "seedPaths": [
    "scripts/orchestrate-worktrees.js",
    "scripts/lib/tmux-worktree-orchestrator.js",
    ".claude/plan/workflow-e2e-test.json"
  ],
  "workers": [
    { "name": "docs", "task": "Update orchestration docs." }
  ]
}
```

ライブtmux/ワークツリーセッションのコントロールプレーンスナップショットをエクスポートするには:

```bash
node scripts/orchestration-status.js .claude/plan/workflow-visual-proof.json
```

スナップショットにはセッションアクティビティ、tmuxペインメタデータ、ワーカー状態、目標、シードされたオーバーレイ、最近のハンドオフサマリーがJSON形式で含まれます。

## オペレーターコマンドセンターのハンドオフ

ワークフローが複数のセッション、ワークツリー、またはtmuxペインにまたがる場合、最終ハンドオフにコントロールプレーンブロックを追加:

```markdown
CONTROL PLANE
-------------
Sessions:
- アクティブなセッションIDまたはエイリアス
- 各アクティブワーカーのブランチ + ワークツリーパス
- 該当する場合のtmuxペインまたはデタッチされたセッション名

Diffs:
- git statusサマリー
- 変更ファイルのgit diff --stat
- マージ/競合リスクの注記

Approvals:
- 保留中のユーザー承認
- 確認待ちのブロックされたステップ

Telemetry:
- 最終アクティビティタイムスタンプまたはアイドルシグナル
- 推定トークンまたはコストドリフト
- フックまたはレビューアーが発生させたポリシーイベント
```

これにより、プランナー、実装者、レビューアー、ループワーカーがオペレーターサーフェスから判読可能になります。

## ワークフロー引数

$ARGUMENTS:
- `feature <description>` - 完全な機能ワークフロー
- `bugfix <description>` - バグ修正ワークフロー
- `refactor <description>` - リファクタリングワークフロー
- `security <description>` - セキュリティレビューワークフロー
- `custom <agents> <description>` - カスタムエージェントシーケンス

## カスタムワークフロー例

```
/orchestrate custom "architect,tdd-guide,code-reviewer" "Redesign caching layer"
```

## ヒント

1. **複雑な機能はplannerから始める**
2. **マージ前には常にcode-reviewerを含める**
3. **認証/決済/PIIにはsecurity-reviewerを使用**
4. **ハンドオフは簡潔に** - 次のエージェントに必要なことに焦点
5. **必要に応じてエージェント間で検証を実行**
