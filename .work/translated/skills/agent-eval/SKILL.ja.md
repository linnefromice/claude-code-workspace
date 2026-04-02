---
name: agent-eval
description: Head-to-head comparison of coding agents (Claude Code, Aider, Codex, etc.) on custom tasks with pass rate, cost, time, and consistency metrics
origin: ECC
tools: Read, Write, Edit, Bash, Grep, Glob
---

# Agent Eval Skill

コーディングエージェントを再現可能なタスクで直接比較するための軽量 CLI ツールです。「どのコーディングエージェントが最良か？」という比較はすべて感覚で行われています。このツールはそれを体系化します。

## 起動条件

- コーディングエージェント（Claude Code、Aider、Codex など）を自分のコードベースで比較する場合
- 新しいツールやモデルを採用する前にエージェントのパフォーマンスを測定する場合
- エージェントがモデルやツーリングを更新した際のリグレッションチェックを実行する場合
- チームのためにデータに基づくエージェント選定を行う場合

## インストール

> **注意:** ソースを確認した上で、リポジトリから agent-eval をインストールしてください。

## Core Concepts

### YAML タスク定義

タスクを宣言的に定義します。各タスクでは、何をするか、どのファイルに触れるか、どのように成功を判定するかを指定します:

```yaml
name: add-retry-logic
description: Add exponential backoff retry to the HTTP client
repo: ./my-project
files:
  - src/http_client.py
prompt: |
  Add retry logic with exponential backoff to all HTTP requests.
  Max 3 retries. Initial delay 1s, max delay 30s.
judge:
  - type: pytest
    command: pytest tests/test_http_client.py -v
  - type: grep
    pattern: "exponential_backoff|retry"
    files: src/http_client.py
commit: "abc1234"  # 再現性のために特定のコミットにピン留め
```

### Git Worktree による隔離

各エージェント実行は独自の git worktree を取得します。Docker は不要です。これにより再現性のための隔離が実現され、エージェント同士が干渉したり、ベースリポジトリを破損したりすることがなくなります。

### メトリクス Collected

| メトリクス | 計測内容 |
|--------|-----------------|
| Pass rate | エージェントが judge を通過するコードを生成したか？ |
| Cost | タスクあたりの API 費用（利用可能な場合） |
| Time | 完了までの実測時間（秒） |
| Consistency | 繰り返し実行時の合格率（例: 3/3 = 100%） |

## ワークフロー

### 1. タスク定義

`tasks/` ディレクトリに YAML ファイルを作成します（タスクごとに1ファイル）:

```bash
mkdir tasks
# タスク定義を記述（上記のテンプレートを参照）
```

### 2. エージェント実行

タスクに対してエージェントを実行します:

```bash
agent-eval run --task tasks/add-retry-logic.yaml --agent claude-code --agent aider --runs 3
```

各実行:
1. 指定されたコミットから新しい git worktree を作成
2. エージェントにプロンプトを渡す
3. judge 基準を実行
4. 合否、コスト、時間を記録

### 3. 結果比較

比較レポートを生成します:

```bash
agent-eval report --format table
```

```
Task: add-retry-logic (3 runs each)
┌──────────────┬───────────┬────────┬────────┬─────────────┐
│ Agent        │ Pass Rate │ Cost   │ Time   │ Consistency │
├──────────────┼───────────┼────────┼────────┼─────────────┤
│ claude-code  │ 3/3       │ $0.12  │ 45s    │ 100%        │
│ aider        │ 2/3       │ $0.08  │ 38s    │  67%        │
└──────────────┴───────────┴────────┴────────┴─────────────┘
```

## Judge Types

### コードベース（決定論的）

```yaml
judge:
  - type: pytest
    command: pytest tests/ -v
  - type: command
    command: npm run build
```

### パターンベース

```yaml
judge:
  - type: grep
    pattern: "class.*Retry"
    files: src/**/*.py
```

### モデルベース（LLM-as-judge）

```yaml
judge:
  - type: llm
    prompt: |
      Does this implementation correctly handle exponential backoff?
      Check for: max retries, increasing delays, jitter.
```

## ベストプラクティス

- 実際のワークロードを代表する **3-5個のタスク** から始めてください。おもちゃの例ではなく実タスクを使用します
- エージェントごとに **最低3回のトライアル** を実行して分散を把握してください。エージェントは非決定論的です
- タスク YAML で **コミットをピン留め** して、日/週をまたいで結果を再現可能にしてください
- タスクごとに **少なくとも1つの決定論的 judge**（テスト、ビルド）を含めてください。LLM judge はノイズを加えます
- **合格率と並行してコストも追跡** してください。95% のエージェントでもコストが10倍なら最適な選択ではないかもしれません
- **タスク定義をバージョン管理** してください。これらはテストフィクスチャであり、コードとして扱うべきです

## リンク

- Repository: [github.com/joaquinhuigomez/agent-eval](https://github.com/joaquinhuigomez/agent-eval)
