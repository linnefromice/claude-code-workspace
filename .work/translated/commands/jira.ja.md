---
description: Jira チケットの取得、要件分析、ステータス更新、コメント追加を行います。jira-integration スキルと MCP または REST API を使用します。
---

# Jira コマンド

Jira チケットをワークフローから直接操作します — チケットの取得、要件の分析、コメントの追加、ステータスの遷移などを行えます。

## 使用方法

```
/jira get <TICKET-KEY>          # チケットを取得して分析
/jira comment <TICKET-KEY>      # 進捗コメントを追加
/jira transition <TICKET-KEY>   # チケットのステータスを変更
/jira search <JQL>              # JQL で issue を検索
```

## このコマンドが行うこと

1. **取得と分析** — Jira チケットを取得し、要件、受け入れ基準、テストシナリオ、依存関係を抽出
2. **コメント** — 構造化された進捗アップデートをチケットに追加
3. **遷移** — チケットをワークフローの状態間で移動（To Do → In Progress → Done）
4. **検索** — JQL クエリを使って issue を検索

## 動作の仕組み

### `/jira get <TICKET-KEY>`

1. Jira からチケットを取得（MCP の `jira_get_issue` または REST API 経由）
2. すべてのフィールドを抽出: summary、description、acceptance criteria、priority、labels、linked issues
3. 必要に応じて追加コンテキスト用にコメントを取得
4. 構造化された分析を生成:

```
Ticket: PROJ-1234
Summary: [title]
Status: [status]
Priority: [priority]
Type: [Story/Bug/Task]

Requirements:
1. [extracted requirement]
2. [extracted requirement]

Acceptance Criteria:
- [ ] [criterion from ticket]

Test Scenarios:
- Happy Path: [description]
- Error Case: [description]
- Edge Case: [description]

Dependencies:
- [linked issues, APIs, services]

Recommended Next Steps:
- /plan to create implementation plan
- /tdd to implement with tests first
```

### `/jira comment <TICKET-KEY>`

1. 現在のセッションの進捗（構築、テスト、コミット）を要約
2. 構造化されたコメントとしてフォーマット
3. Jira チケットに投稿

### `/jira transition <TICKET-KEY>`

1. チケットで利用可能な transitions を取得
2. 選択肢をユーザーに表示
3. 選択された transition を実行

### `/jira search <JQL>`

1. JQL クエリを Jira に対して実行
2. 一致する issue のサマリーテーブルを返す

## 前提条件

このコマンドには Jira の認証情報が必要です。次のいずれかを選択してください:

**オプション A — MCP サーバー（推奨）:**
`mcpServers` の設定に `jira` を追加します（テンプレートは `mcp-configs/mcp-servers.json` を参照）。

**オプション B — 環境変数:**
```bash
export JIRA_URL="https://yourorg.atlassian.net"
export JIRA_EMAIL="your.email@example.com"
export JIRA_API_TOKEN="your-api-token"
```

認証情報が欠落している場合は処理を停止し、ユーザーに設定方法を案内します。

## 他のコマンドとの統合

チケットを分析した後:
- 要件から実装計画を作成するには `/plan` を使用
- テスト駆動開発で実装するには `/tdd` を使用
- 実装後のレビューには `/code-review` を使用
- 進捗をチケットに戻すには `/jira comment` を使用
- 作業完了時にチケットを移動するには `/jira transition` を使用

## 関連

- **スキル:** `skills/jira-integration/`
- **MCP 設定:** `mcp-configs/mcp-servers.json` → `jira`
