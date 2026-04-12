---
name: jira-integration
description: Jira チケットの取得、要件の分析、チケットステータスの更新、コメント追加、issue の遷移を行う際にこのスキルを使用します。MCP または直接の REST コールによる Jira API パターンを提供します。
origin: ECC
---

# Jira Integration Skill

AI コーディングワークフローから直接 Jira チケットを取得、分析、更新します。**MCP ベース**（推奨）と**直接 REST API** の両方のアプローチをサポートします。

## 有効化タイミング

- 要件を理解するために Jira チケットを取得する場合
- チケットからテスト可能な受け入れ基準を抽出する場合
- Jira issue に進捗コメントを追加する場合
- チケットステータスを遷移させる場合（To Do → In Progress → Done）
- マージリクエストやブランチを Jira issue にリンクする場合
- JQL クエリで issue を検索する場合

## 前提条件

### オプション A: MCP サーバー（推奨）

`mcp-atlassian` MCP サーバーをインストールします。これにより、Jira ツールが AI エージェントに直接公開されます。

**要件:**
- Python 3.10+
- `uvx`（`uv` に含まれる）。パッケージマネージャーまたは公式の `uv` インストールドキュメントからインストール

**MCP 設定に追加**（例: `~/.claude.json` → `mcpServers`）:

```json
{
  "jira": {
    "command": "uvx",
    "args": ["mcp-atlassian==0.21.0"],
    "env": {
      "JIRA_URL": "https://YOUR_ORG.atlassian.net",
      "JIRA_EMAIL": "your.email@example.com",
      "JIRA_API_TOKEN": "your-api-token"
    },
    "description": "Jira issue tracking — search, create, update, comment, transition"
  }
}
```

> **セキュリティ:** シークレットをハードコードしないでください。`JIRA_URL`、`JIRA_EMAIL`、`JIRA_API_TOKEN` はシステム環境変数（またはシークレットマネージャー）に設定するのが望ましいです。MCP の `env` ブロックは、ローカルでコミットされない設定ファイルにのみ使用してください。

**Jira API トークンの取得方法:**
1. <https://id.atlassian.com/manage-profile/security/api-tokens> にアクセス
2. **Create API token** をクリック
3. トークンをコピーし、環境変数に保管します。ソースコードには絶対に保存しないでください

### オプション B: 直接 REST API

MCP が利用できない場合は、`curl` またはヘルパースクリプトを介して Jira REST API v3 を直接使用します。

**必須環境変数:**

| 変数 | 説明 |
|----------|-------------|
| `JIRA_URL` | Jira インスタンス URL（例: `https://yourorg.atlassian.net`） |
| `JIRA_EMAIL` | Atlassian アカウントメール |
| `JIRA_API_TOKEN` | id.atlassian.com からの API トークン |

これらはシェル環境、シークレットマネージャー、または追跡対象外のローカル env ファイルに保存します。リポジトリにコミットしないでください。

## MCP ツールリファレンス

`mcp-atlassian` MCP サーバーが設定されている場合、以下のツールが利用可能です:

| ツール | 用途 | 例 |
|------|---------|---------|
| `jira_search` | JQL クエリ | `project = PROJ AND status = "In Progress"` |
| `jira_get_issue` | キーで issue 詳細を取得 | `PROJ-1234` |
| `jira_create_issue` | issue の作成（Task、Bug、Story、Epic） | 新規バグレポート |
| `jira_update_issue` | フィールド更新（summary、description、assignee） | 担当者の変更 |
| `jira_transition_issue` | ステータス変更 | "In Review" に移動 |
| `jira_add_comment` | コメント追加 | 進捗更新 |
| `jira_get_sprint_issues` | スプリント内の issue 一覧 | アクティブスプリントのレビュー |
| `jira_create_issue_link` | issue のリンク（Blocks、Relates to） | 依存関係の追跡 |
| `jira_get_issue_development_info` | リンクされた PR、ブランチ、コミットを表示 | 開発コンテキスト |

> **ヒント:** 遷移の前に必ず `jira_get_transitions` を呼び出してください。遷移 ID はプロジェクトのワークフローごとに異なります。

## 直接 REST API リファレンス

### チケットの取得

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  "$JIRA_URL/rest/api/3/issue/PROJ-1234" | jq '{
    key: .key,
    summary: .fields.summary,
    status: .fields.status.name,
    priority: .fields.priority.name,
    type: .fields.issuetype.name,
    assignee: .fields.assignee.displayName,
    labels: .fields.labels,
    description: .fields.description
  }'
```

### コメントの取得

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  "$JIRA_URL/rest/api/3/issue/PROJ-1234?fields=comment" | jq '.fields.comment.comments[] | {
    author: .author.displayName,
    created: .created[:10],
    body: .body
  }'
```

### コメントの追加

```bash
curl -s -X POST -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "version": 1,
      "type": "doc",
      "content": [{
        "type": "paragraph",
        "content": [{"type": "text", "text": "Your comment here"}]
      }]
    }
  }' \
  "$JIRA_URL/rest/api/3/issue/PROJ-1234/comment"
```

### チケットの遷移

```bash
# 1. 利用可能な遷移を取得
curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  "$JIRA_URL/rest/api/3/issue/PROJ-1234/transitions" | jq '.transitions[] | {id, name: .name}'

# 2. 遷移を実行（TRANSITION_ID を置き換える）
curl -s -X POST -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"transition": {"id": "TRANSITION_ID"}}' \
  "$JIRA_URL/rest/api/3/issue/PROJ-1234/transitions"
```

### JQL での検索

```bash
curl -s -G -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
  --data-urlencode "jql=project = PROJ AND status = 'In Progress'" \
  "$JIRA_URL/rest/api/3/search"
```

## チケットの分析

開発やテスト自動化のためにチケットを取得する際は、以下を抽出します:

### 1. テスト可能な要件
- **機能要件** — 機能が何をするか
- **受け入れ基準** — 満たすべき条件
- **テスト可能な動作** — 具体的なアクションと期待される結果
- **ユーザーロール** — 誰が使用し、どのような権限を持つか
- **データ要件** — 必要なデータ
- **統合ポイント** — 関連する API、サービス、システム

### 2. 必要なテストタイプ
- **ユニットテスト** — 個別の関数やユーティリティ
- **統合テスト** — API エンドポイントやサービス間のやり取り
- **E2E テスト** — ユーザー向け UI フロー
- **API テスト** — エンドポイント契約とエラー処理

### 3. エッジケースとエラーシナリオ
- 無効な入力（空、長すぎる、特殊文字）
- 認可されていないアクセス
- ネットワーク障害やタイムアウト
- 同時実行ユーザーや競合状態
- 境界条件
- 欠落または null のデータ
- ステート遷移（戻るナビゲーション、リフレッシュなど）

### 4. 構造化された分析出力

```
Ticket: PROJ-1234
Summary: [チケットタイトル]
Status: [現在のステータス]
Priority: [High/Medium/Low]
Test Types: Unit, Integration, E2E

Requirements:
1. [要件 1]
2. [要件 2]

Acceptance Criteria:
- [ ] [基準 1]
- [ ] [基準 2]

Test Scenarios:
- Happy Path: [説明]
- Error Case: [説明]
- Edge Case: [説明]

Test Data Needed:
- [データ項目 1]
- [データ項目 2]

Dependencies:
- [依存関係 1]
- [依存関係 2]
```

## チケットの更新

### 更新のタイミング

| ワークフローステップ | Jira 更新 |
|---|---|
| 作業開始 | "In Progress" へ遷移 |
| テスト作成 | テストカバレッジサマリーをコメント |
| ブランチ作成 | ブランチ名をコメント |
| PR/MR 作成 | リンクをコメントし、issue をリンク |
| テストがパス | 結果サマリーをコメント |
| PR/MR マージ | "Done" または "In Review" へ遷移 |

### コメントテンプレート

**作業開始時:**
```
Starting implementation for this ticket.
Branch: feat/PROJ-1234-feature-name
```

**テスト実装時:**
```
Automated tests implemented:

Unit Tests:
- [test file 1] — [カバー内容]
- [test file 2] — [カバー内容]

Integration Tests:
- [test file] — [カバーするエンドポイント/フロー]

All tests passing locally. Coverage: XX%
```

**PR 作成時:**
```
Pull request created:
[PR Title](https://github.com/org/repo/pull/XXX)

Ready for review.
```

**作業完了時:**
```
Implementation complete.

PR merged: [link]
Test results: All passing (X/Y)
Coverage: XX%
```

## セキュリティガイドライン

- **絶対にハードコードしない** Jira API トークンをソースコードやスキルファイルに
- **常に使用する** 環境変数またはシークレットマネージャーを
- **`.env` を追加する** すべてのプロジェクトの `.gitignore` に
- **トークンをローテートする** git 履歴で漏洩した場合はただちに
- **最小権限を使用する** 必要なプロジェクトにスコープを絞った API トークンを
- **検証する** API コール前に認証情報が設定されていることを。明確なメッセージで早期失敗させること

## トラブルシューティング

| エラー | 原因 | 対処 |
|---|---|---|
| `401 Unauthorized` | API トークンが無効または期限切れ | id.atlassian.com で再生成 |
| `403 Forbidden` | トークンにプロジェクト権限がない | トークンのスコープとプロジェクトアクセスを確認 |
| `404 Not Found` | チケットキーまたはベース URL が間違い | `JIRA_URL` とチケットキーを確認 |
| `spawn uvx ENOENT` | IDE が PATH 上で `uvx` を見つけられない | フルパス（例: `~/.local/bin/uvx`）を使用するか、`~/.zprofile` で PATH を設定 |
| 接続タイムアウト | ネットワーク/VPN の問題 | VPN 接続とファイアウォールルールを確認 |

## ベストプラクティス

- 最後にまとめてではなく、進捗に合わせて Jira を更新する
- コメントは簡潔かつ情報量のあるものにする
- コピーではなくリンクする。PR、テストレポート、ダッシュボードを参照する
- 他者からの入力が必要な場合は @mentions を使用する
- リンクされた issue を確認し、開始前に機能スコープ全体を理解する
- 受け入れ基準が曖昧な場合は、コードを書く前に明確化を求める
