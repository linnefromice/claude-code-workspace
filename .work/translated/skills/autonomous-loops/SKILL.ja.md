---
name: autonomous-loops
description: "Patterns and architectures for autonomous Claude Code loops — from simple sequential pipelines to RFC-driven multi-agent DAG systems."
origin: ECC
---

# Autonomous Loops Skill

> 互換性に関する注意（v1.8.0）: `autonomous-loops` は1リリース分保持されます。
> 正規のスキル名は `continuous-agent-loop` になりました。新しいループガイダンスは
> そちらで作成してください。既存のワークフローを壊さないよう、このスキルは引き続き
> 利用可能です。

Claude Code を自律的にループで実行するためのパターン、アーキテクチャ、リファレンス実装です。シンプルな `claude -p` パイプラインから、RFC 駆動のマルチエージェント DAG オーケストレーションまでをカバーします。

## 使用タイミング

- 人間の介入なしに動作する自律的な開発ワークフローをセットアップする場合
- 問題に適したループアーキテクチャの選択（シンプル vs 複雑）
- CI/CD スタイルの継続的開発パイプラインの構築
- マージ調整付きの並列エージェントの実行
- ループのイテレーション間でのコンテキスト永続化の実装
- 自律ワークフローへの品質ゲートとクリーンアップパスの追加

## Loop Pattern Spectrum

最もシンプルなものから最も高度なものまで:

| パターン | 複雑度 | 最適な用途 |
|---------|-----------|----------|
| [Sequential Pipeline](#1-sequential-pipeline-claude--p) | 低 | 日次開発ステップ、スクリプト化されたワークフロー |
| [NanoClaw REPL](#2-nanoclaw-repl) | 低 | インタラクティブな永続セッション |
| [Infinite Agentic Loop](#3-infinite-agentic-loop) | 中 | 並列コンテンツ生成、仕様駆動の作業 |
| [Continuous Claude PR Loop](#4-continuous-claude-pr-loop) | 中 | CI ゲート付きの複数日にわたる反復プロジェクト |
| [De-Sloppify Pattern](#5-the-de-sloppify-pattern) | アドオン | Implementer ステップ後の品質クリーンアップ |
| [Ralphinho / RFC-Driven DAG](#6-ralphinho--rfc-driven-dag-orchestration) | 高 | 大規模機能、マージキュー付きのマルチユニット並列作業 |

---

## 1. Sequential Pipeline (`claude -p`)

**最もシンプルなループです。** 日常の開発をノンインタラクティブな `claude -p` コールのシーケンスに分解します。各コールは明確なプロンプトを持つ集中したステップです。

### Core Insight

> このようなループを構築できないなら、インタラクティブモードでも LLM にコードを修正させることすらできないということです。

`claude -p` フラグはプロンプト付きでノンインタラクティブに Claude Code を実行し、完了時に終了します。コールをチェインしてパイプラインを構築します:

```bash
#!/bin/bash
# daily-dev.sh — フィーチャーブランチ用の Sequential Pipeline

set -e

# Step 1: 機能の実装
claude -p "Read the spec in docs/auth-spec.md. Implement OAuth2 login in src/auth/. Write tests first (TDD). Do NOT create any new documentation files."

# Step 2: De-sloppify（クリーンアップパス）
claude -p "Review all files changed by the previous commit. Remove any unnecessary type tests, overly defensive checks, or testing of language features (e.g., testing that TypeScript generics work). Keep real business logic tests. Run the test suite after cleanup."

# Step 3: 検証
claude -p "Run the full build, lint, type check, and test suite. Fix any failures. Do not add new features."

# Step 4: コミット
claude -p "Create a conventional commit for all staged changes. Use 'feat: add OAuth2 login flow' as the message."
```

### 主要な設計原則

1. **各ステップは独立** — `claude -p` コールごとに新しいコンテキストウィンドウが開始されるため、ステップ間でコンテキストの漏洩がありません。
2. **順序が重要** — ステップは順次実行されます。各ステップは前のステップが残したファイルシステムの状態に基づいて動作します。
3. **否定的な指示は危険** — 「型システムをテストしないで」とは言わないでください。代わりに、別のクリーンアップステップを追加してください（[De-Sloppify Pattern](#5-the-de-sloppify-pattern) を参照）。
4. **終了コードの伝搬** — `set -e` により、失敗時にパイプラインが停止します。

### バリエーション

**モデルルーティング付き:**
```bash
# Opus で調査（深い推論）
claude -p --model opus "Analyze the codebase architecture and write a plan for adding caching..."

# Sonnet で実装（高速、高性能）
claude -p "Implement the caching layer according to the plan in docs/caching-plan.md..."

# Opus でレビュー（徹底的）
claude -p --model opus "Review all changes for security issues, race conditions, and edge cases..."
```

**環境コンテキスト付き:**
```bash
# プロンプトの長さではなく、ファイル経由でコンテキストを渡す
echo "Focus areas: auth module, API rate limiting" > .claude-context.md
claude -p "Read .claude-context.md for priorities. Work through them in order."
rm .claude-context.md
```

**`--allowedTools` 制限付き:**
```bash
# 読み取り専用の分析パス
claude -p --allowedTools "Read,Grep,Glob" "Audit this codebase for security vulnerabilities..."

# 書き込み専用の実装パス
claude -p --allowedTools "Read,Write,Edit,Bash" "Implement the fixes from security-audit.md..."
```

---

## 2. NanoClaw REPL

**ECC 組み込みの永続ループです。** 完全な会話履歴付きで `claude -p` を同期的に呼び出すセッション対応 REPL です。

```bash
# デフォルトセッションを開始
node scripts/claw.js

# スキルコンテキスト付きの名前付きセッション
CLAW_SESSION=my-project CLAW_SKILLS=tdd-workflow,security-review node scripts/claw.js
```

### 仕組み

1. `~/.claude/claw/{session}.md` から会話履歴を読み込みます
2. 各ユーザーメッセージは完全な履歴をコンテキストとして `claude -p` に送信されます
3. レスポンスはセッションファイルに追記されます（Markdown をデータベースとして利用）
4. セッションは再起動後も永続化されます

### NanoClaw vs Sequential Pipeline の使い分け

| ユースケース | NanoClaw | Sequential Pipeline |
|----------|----------|-------------------|
| インタラクティブな探索 | はい | いいえ |
| スクリプト化された自動化 | いいえ | はい |
| セッション永続化 | 組み込み | 手動 |
| コンテキスト蓄積 | ターンごとに増加 | 各ステップで新規 |
| CI/CD 統合 | 不向き | 最適 |

詳細は `/claw` コマンドのドキュメントを参照してください。

---

## 3. Infinite Agentic Loop

**2つのプロンプトからなるシステム** で、仕様駆動の生成のために並列サブエージェントを調整します。disler が開発（credit: @disler）。

### アーキテクチャ: Two-Prompt System

```
PROMPT 1 (Orchestrator)              PROMPT 2 (Sub-Agents)
┌─────────────────────┐             ┌──────────────────────┐
│ 仕様ファイルをパース  │             │ フルコンテキストを受信 │
│ 出力ディレクトリをスキャン │  deploys   │ 割り当て番号を読み取り │
│ イテレーションを計画   │────────────│ 仕様に正確に従う      │
│ クリエイティブな方向を割当│  N agents  │ ユニークな出力を生成   │
│ ウェーブを管理       │             │ 出力ディレクトリに保存  │
└─────────────────────┘             └──────────────────────┘
```

### パターン

1. **仕様分析** — オーケストレーターが何を生成するかを定義する仕様ファイル（Markdown）を読み取ります
2. **ディレクトリ偵察** — 既存の出力をスキャンして最大のイテレーション番号を見つけます
3. **並列デプロイ** — N 個のサブエージェントを起動し、それぞれに以下を付与:
   - 完全な仕様
   - ユニークなクリエイティブの方向性
   - 特定のイテレーション番号（競合なし）
   - 既存イテレーションのスナップショット（ユニーク性の確保のため）
4. **ウェーブ管理** — 無限モードでは、コンテキストが尽きるまで3-5エージェントのウェーブをデプロイ

### 実装 via Claude Code Commands

`.claude/commands/infinite.md` を作成:

```markdown
Parse the following arguments from $ARGUMENTS:
1. spec_file — path to the specification markdown
2. output_dir — where iterations are saved
3. count — integer 1-N or "infinite"

PHASE 1: Read and deeply understand the specification.
PHASE 2: List output_dir, find highest iteration number. Start at N+1.
PHASE 3: Plan creative directions — each agent gets a DIFFERENT theme/approach.
PHASE 4: Deploy sub-agents in parallel (Task tool). Each receives:
  - Full spec text
  - Current directory snapshot
  - Their assigned iteration number
  - Their unique creative direction
PHASE 5 (infinite mode): Loop in waves of 3-5 until context is low.
```

**呼び出し:**
```bash
/project:infinite specs/component-spec.md src/ 5
/project:infinite specs/component-spec.md src/ infinite
```

### バッチ戦略

| カウント | 戦略 |
|-------|----------|
| 1-5 | 全エージェントを同時実行 |
| 6-20 | 5個ずつのバッチ |
| infinite | 3-5のウェーブ、段階的に洗練度を向上 |

### 重要な洞察: 割り当てによるユニーク性

エージェント自身に差別化を任せないでください。オーケストレーターが各エージェントに特定のクリエイティブの方向性とイテレーション番号を **割り当て** ます。これにより、並列エージェント間でコンセプトの重複が防止されます。

---

## 4. Continuous Claude PR Loop

**本番品質のシェルスクリプト** で、Claude Code を継続ループで実行し、PR を作成し、CI を待ち、自動的にマージします。AnandChowdhary が作成（credit: @AnandChowdhary）。

### Core Loop

```
┌─────────────────────────────────────────────────────┐
│  CONTINUOUS CLAUDE ITERATION                        │
│                                                     │
│  1. ブランチを作成 (continuous-claude/iteration-N)    │
│  2. 拡張プロンプト付きで claude -p を実行              │
│  3. (オプション) レビューパス — 別の claude -p          │
│  4. 変更をコミット（claude がメッセージを生成）         │
│  5. プッシュ＋PR 作成 (gh pr create)                  │
│  6. CI チェックを待機（gh pr checks をポーリング）     │
│  7. CI 失敗？→ 自動修正パス (claude -p)               │
│  8. PR をマージ (squash/merge/rebase)                 │
│  9. main に戻る → 繰り返し                            │
│                                                     │
│  制限: --max-runs N | --max-cost $X                  │
│        --max-duration 2h | completion signal          │
└─────────────────────────────────────────────────────┘
```

### インストール

> **警告:** コードを確認した上で、リポジトリから continuous-claude をインストールしてください。外部スクリプトを直接 bash にパイプしないでください。

### 使い方

```bash
# 基本: 10イテレーション
continuous-claude --prompt "Add unit tests for all untested functions" --max-runs 10

# コスト制限付き
continuous-claude --prompt "Fix all linter errors" --max-cost 5.00

# 時間制限付き
continuous-claude --prompt "Improve test coverage" --max-duration 8h

# コードレビューパス付き
continuous-claude \
  --prompt "Add authentication feature" \
  --max-runs 10 \
  --review-prompt "Run npm test && npm run lint, fix any failures"

# worktree 経由の並列実行
continuous-claude --prompt "Add tests" --max-runs 5 --worktree tests-worker &
continuous-claude --prompt "Refactor code" --max-runs 5 --worktree refactor-worker &
wait
```

### イテレーション間のコンテキスト: SHARED_TASK_NOTES.md

重要なイノベーション: `SHARED_TASK_NOTES.md` ファイルがイテレーション間で永続化されます:

```markdown
## Progress
- [x] Added tests for auth module (iteration 1)
- [x] Fixed edge case in token refresh (iteration 2)
- [ ] Still need: rate limiting tests, error boundary tests

## Next Steps
- Focus on rate limiting module next
- The mock setup in tests/helpers.ts can be reused
```

Claude はイテレーション開始時にこのファイルを読み取り、イテレーション終了時に更新します。これにより、独立した `claude -p` 呼び出し間のコンテキストギャップが橋渡しされます。

### CI 失敗からの回復

PR チェックが失敗した場合、Continuous Claude は自動的に以下を行います:
1. `gh run list` 経由で失敗したラン ID を取得
2. CI 修正コンテキスト付きで新しい `claude -p` を起動
3. Claude が `gh run view` 経由でログを確認し、コードを修正、コミット、プッシュ
4. チェックを再待機（最大 `--ci-retry-max` 回の試行）

### Completion Signal

Claude は「完了」をマジックフレーズの出力でシグナルできます:

```bash
continuous-claude \
  --prompt "Fix all bugs in the issue tracker" \
  --completion-signal "CONTINUOUS_CLAUDE_PROJECT_COMPLETE" \
  --completion-threshold 3  # 3回連続のシグナル後に停止
```

3回連続で完了シグナルを送信するとループが停止し、完了した作業に対する無駄な実行を防ぎます。

### 主要な設定

| フラグ | 目的 |
|------|---------|
| `--max-runs N` | N 回の成功イテレーション後に停止 |
| `--max-cost $X` | $X の支出後に停止 |
| `--max-duration 2h` | 経過時間後に停止 |
| `--merge-strategy squash` | squash、merge、または rebase |
| `--worktree <name>` | git worktree 経由の並列実行 |
| `--disable-commits` | ドライランモード（git 操作なし） |
| `--review-prompt "..."` | イテレーションごとにレビューパスを追加 |
| `--ci-retry-max N` | CI 失敗の自動修正（デフォルト: 1） |

---

## 5. The De-Sloppify Pattern

**任意のループのアドオンパターンです。** Implementer ステップの後に専用のクリーンアップ/リファクタリングステップを追加します。

### 問題

LLM に TDD で実装を依頼すると、「テストを書く」を文字通りに解釈しすぎます:
- TypeScript の型システムが動作することを検証するテスト（`typeof x === 'string'` のテスト）
- 型システムが既に保証しているものに対する過度に防御的なランタイムチェック
- ビジネスロジックではなくフレームワークの動作をテスト
- 実際のコードを曖昧にする過剰なエラーハンドリング

### なぜ否定的な指示ではダメか？

Implementer プロンプトに「型システムをテストしないで」や「不要なチェックを追加しないで」を追加すると、下流に影響が出ます:
- モデルがすべてのテストに対して消極的になる
- 正当なエッジケーステストをスキップする
- 品質が予測不能に低下する

### 解決策: 別のパス

Implementer を制約する代わりに、徹底的に作業させます。その後、集中したクリーンアップエージェントを追加します:

```bash
# Step 1: 実装（徹底的に）
claude -p "Implement the feature with full TDD. Be thorough with tests."

# Step 2: De-sloppify（別のコンテキスト、集中したクリーンアップ）
claude -p "Review all changes in the working tree. Remove:
- Tests that verify language/framework behavior rather than business logic
- Redundant type checks that the type system already enforces
- Over-defensive error handling for impossible states
- Console.log statements
- Commented-out code

Keep all business logic tests. Run the test suite after cleanup to ensure nothing breaks."
```

### ループコンテキストでの使用

```bash
for feature in "${features[@]}"; do
  # 実装
  claude -p "Implement $feature with TDD."

  # De-sloppify
  claude -p "Cleanup pass: review changes, remove test/code slop, run tests."

  # 検証
  claude -p "Run build + lint + tests. Fix any failures."

  # コミット
  claude -p "Commit with message: feat: add $feature"
done
```

### 重要な洞察

> 下流の品質に影響を与える否定的な指示を追加する代わりに、別の de-sloppify パスを追加してください。集中した2つのエージェントは、制約された1つのエージェントよりも優れています。

---

## 6. Ralphinho / RFC-Driven DAG Orchestration

**最も高度なパターンです。** RFC 駆動のマルチエージェントパイプラインで、仕様を依存関係 DAG に分解し、各ユニットを階層的な品質パイプラインを通して実行し、エージェント駆動のマージキューを介してランディングします。enitrat が作成（credit: @enitrat）。

### アーキテクチャ Overview

```
RFC/PRD Document
       │
       ▼
  DECOMPOSITION (AI)
  RFC をワークユニットと依存関係 DAG に分解
       │
       ▼
┌──────────────────────────────────────────────────────┐
│  RALPH LOOP (最大3パス)                               │
│                                                      │
│  各 DAG レイヤーについて（依存関係順に逐次）:           │
│                                                      │
│  ┌── Quality Pipelines（ユニットごとに並列）────────┐  │
│  │  各ユニットは独自の worktree 内:                │  │
│  │  Research → Plan → Implement → Test → Review   │  │
│  │  （深度は複雑度ティアにより変動）              │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ┌── Merge Queue ─────────────────────────────────┐  │
│  │  main にリベース → テスト実行 → ランドまたは追放│  │
│  │  追放されたユニットはコンフリクトコンテキスト付きで│  │
│  │  再投入                                        │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### RFC 分解

AI が RFC を読み取り、ワークユニットを生成します:

```typescript
interface WorkUnit {
  id: string;              // kebab-case の識別子
  name: string;            // 人間が読める名前
  rfcSections: string[];   // この作業が対応する RFC セクション
  description: string;     // 詳細な説明
  deps: string[];          // 依存関係（他のユニット ID）
  acceptance: string[];    // 具体的な受け入れ基準
  tier: "trivial" | "small" | "medium" | "large";
}
```

**分解ルール:**
- 少数の凝集性のあるユニットを優先（マージリスクの最小化）
- ユニット間のファイル重複を最小化（コンフリクト回避）
- テストは実装と一緒に保持（「X を実装」と「X をテスト」を分離しない）
- 実際のコード依存関係がある場合のみ依存関係を設定

依存関係 DAG が実行順序を決定します:
```
Layer 0: [unit-a, unit-b]     ← 依存関係なし、並列実行
Layer 1: [unit-c]             ← unit-a に依存
Layer 2: [unit-d, unit-e]     ← unit-c に依存
```

### 複雑度ティア

異なるティアに異なるパイプライン深度が適用されます:

| ティア | パイプラインステージ |
|------|----------------|
| **trivial** | implement → test |
| **small** | implement → test → code-review |
| **medium** | research → plan → implement → test → PRD-review + code-review → review-fix |
| **large** | research → plan → implement → test → PRD-review + code-review → review-fix → final-review |

これにより、シンプルな変更に対する高コストな操作を防ぎつつ、アーキテクチャの変更には徹底的な精査が行われます。

### 独立したコンテキストウィンドウ（著者バイアスの排除）

各ステージは独自のエージェントプロセスと独自のコンテキストウィンドウで実行されます:

| ステージ | モデル | 目的 |
|-------|-------|---------|
| Research | Sonnet | コードベース＋RFC を読み取り、コンテキストドキュメントを生成 |
| Plan | Opus | 実装ステップを設計 |
| Implement | Codex | プランに従ってコードを書く |
| Test | Sonnet | ビルド＋テストスイートを実行 |
| PRD Review | Sonnet | 仕様準拠チェック |
| Code Review | Opus | 品質＋セキュリティチェック |
| Review Fix | Codex | レビュー指摘への対応 |
| Final Review | Opus | 品質ゲート（large ティアのみ） |

**重要な設計:** レビューアーがレビューするコードを書いたことはありません。これにより著者バイアスが排除されます。これはセルフレビューで見逃される問題の最も一般的な原因です。

### 追放付きマージキュー

品質パイプライン完了後、ユニットはマージキューに入ります:

```
Unit branch
    │
    ├─ main にリベース
    │   └─ コンフリクト？→ 追放（コンフリクトコンテキストをキャプチャ）
    │
    ├─ ビルド＋テスト実行
    │   └─ 失敗？→ 追放（テスト出力をキャプチャ）
    │
    └─ パス → main を fast-forward、プッシュ、ブランチ削除
```

**ファイル重複のインテリジェンス:**
- 重複のないユニットは投機的に並列でランディング
- 重複のあるユニットは1つずつ、毎回リベースしながらランディング

**追放からの回復:**
追放時、完全なコンテキスト（コンフリクトファイル、diff、テスト出力）がキャプチャされ、次の Ralph パスで実装者にフィードバックされます:

```markdown
## MERGE CONFLICT — RESOLVE BEFORE NEXT LANDING

あなたの前の実装は、先にランディングした別のユニットとコンフリクトしました。
以下のコンフリクトしているファイル/行を回避するよう、変更を再構築してください。

{full eviction context with diffs}
```

### ステージ間のデータフロー

```
research.contextFilePath ──────────────────→ plan
plan.implementationSteps ──────────────────→ implement
implement.{filesCreated, whatWasDone} ─────→ test, reviews
test.failingSummary ───────────────────────→ reviews, implement (next pass)
reviews.{feedback, issues} ────────────────→ review-fix → implement (next pass)
final-review.reasoning ────────────────────→ implement (next pass)
evictionContext ───────────────────────────→ implement (after merge conflict)
```

### Worktree による隔離

すべてのユニットは隔離された worktree で実行されます（git ではなく jj/Jujutsu を使用）:
```
/tmp/workflow-wt-{unit-id}/
```

同じユニットのパイプラインステージは worktree を **共有** し、research → plan → implement → test → review にわたって状態（コンテキストファイル、プランファイル、コード変更）を保持します。

### 主要な設計原則

1. **決定論的な実行** — 事前の分解により並列性と順序が確定
2. **レバレッジポイントでの人間レビュー** — 作業計画が唯一最大のレバレッジとなる介入ポイント
3. **関心の分離** — 各ステージは別のコンテキストウィンドウで別のエージェントとして実行
4. **コンテキスト付きのコンフリクト回復** — 完全な追放コンテキストにより、盲目的なリトライではなくインテリジェントな再実行が可能
5. **ティア駆動の深度** — 些細な変更は research/review をスキップ、大規模な変更は最大の精査
6. **再開可能なワークフロー** — 完全な状態が SQLite に永続化、任意のポイントから再開可能

### 使用タイミング Ralphinho vs Simpler Patterns

| シグナル | Ralphinho を使用 | シンプルなパターンを使用 |
|--------|--------------|-------------------|
| 複数の相互依存するワークユニット | はい | いいえ |
| 並列実装が必要 | はい | いいえ |
| マージコンフリクトの可能性 | はい | いいえ（逐次で十分） |
| 単一ファイルの変更 | いいえ | はい（sequential pipeline） |
| 複数日のプロジェクト | はい | 場合による（continuous-claude） |
| 仕様/RFC が既に書かれている | はい | 場合による |
| 1つのことに対する素早いイテレーション | いいえ | はい（NanoClaw またはパイプライン） |

---

## 適切なパターンの選択

### 決定 Matrix

```
タスクは単一の集中した変更か？
├─ はい → Sequential Pipeline または NanoClaw
└─ いいえ → 書かれた仕様/RFC があるか？
         ├─ はい → 並列実装が必要か？
         │        ├─ はい → Ralphinho（DAG オーケストレーション）
         │        └─ いいえ → Continuous Claude（反復 PR ループ）
         └─ いいえ → 同じもののバリエーションが多数必要か？
                  ├─ はい → Infinite Agentic Loop（仕様駆動の生成）
                  └─ いいえ → Sequential Pipeline + de-sloppify
```

### パターンの組み合わせ

これらのパターンはうまく組み合わせられます:

1. **Sequential Pipeline + De-Sloppify** — 最も一般的な組み合わせです。すべての実装ステップにクリーンアップパスが付きます。

2. **Continuous Claude + De-Sloppify** — 各イテレーションに de-sloppify ディレクティブ付きの `--review-prompt` を追加します。

3. **任意のループ + Verification** — コミット前のゲートとして ECC の `/verify` コマンドまたは `verification-loop` スキルを使用します。

4. **Ralphinho のティアアプローチをシンプルなループで** — sequential pipeline でも、シンプルなタスクを Haiku に、複雑なタスクを Opus にルーティングできます:
   ```bash
   # シンプルなフォーマット修正
   claude -p --model haiku "Fix the import ordering in src/utils.ts"

   # 複雑なアーキテクチャ変更
   claude -p --model opus "Refactor the auth module to use the strategy pattern"
   ```

---

## アンチパターン

### よくある間違い

1. **終了条件のない無限ループ** — 常に max-runs、max-cost、max-duration、または completion signal を設定してください。

2. **イテレーション間のコンテキスト橋渡しなし** — 各 `claude -p` コールは新規で始まります。`SHARED_TASK_NOTES.md` やファイルシステムの状態を使ってコンテキストを橋渡ししてください。

3. **同じ失敗のリトライ** — イテレーションが失敗した場合、単にリトライしないでください。エラーコンテキストをキャプチャして次の試行にフィードしてください。

4. **クリーンアップパスの代わりに否定的な指示** — 「X をしないで」と言わないでください。X を除去する別のパスを追加してください。

5. **すべてのエージェントを1つのコンテキストウィンドウに** — 複雑なワークフローでは、関心を異なるエージェントプロセスに分離してください。レビューアーは著者であってはなりません。

6. **並列作業でのファイル重複の無視** — 2つの並列エージェントが同じファイルを編集する可能性がある場合、マージ戦略（逐次ランディング、リベース、またはコンフリクト解決）が必要です。

---

## References

| プロジェクト | 作者 | リンク |
|---------|--------|------|
| Ralphinho | enitrat | credit: @enitrat |
| Infinite Agentic Loop | disler | credit: @disler |
| Continuous Claude | AnandChowdhary | credit: @AnandChowdhary |
| NanoClaw | ECC | このリポジトリの `/claw` コマンド |
| Verification Loop | ECC | このリポジトリの `skills/verification-loop/` |
