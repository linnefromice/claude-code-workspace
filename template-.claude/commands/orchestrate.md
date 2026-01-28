# Orchestrateコマンド

複雑なタスクのための順次エージェントワークフロー。

## 使用方法

`/orchestrate [workflow-type] [task-description]`

## ワークフロー種別

### feature
完全な機能実装ワークフロー:
```
planner -> tdd-guide -> code-reviewer -> security-reviewer
```

### bugfix
バグ調査と修正ワークフロー:
```
explorer -> tdd-guide -> code-reviewer
```

### refactor
安全なリファクタリングワークフロー:
```
architect -> code-reviewer -> tdd-guide
```

### security
セキュリティ重視のレビュー:
```
security-reviewer -> code-reviewer -> architect
```

## 実行パターン

ワークフロー内の各エージェントについて:

1. **エージェントを呼び出し**（前のエージェントからのコンテキストと共に）
2. **出力を収集**（構造化されたハンドオフドキュメントとして）
3. **次のエージェントに渡す**（チェーン内で）
4. **結果を集約**（最終レポートへ）

## ハンドオフドキュメントフォーマット

エージェント間でハンドオフドキュメントを作成:

```markdown
## HANDOFF: [前のエージェント] -> [次のエージェント]

### コンテキスト
[行われたことの要約]

### 発見
[主要な発見または決定]

### 変更ファイル
[触れたファイルのリスト]

### 未解決の質問
[次のエージェントのための未解決項目]

### 推奨事項
[推奨される次のステップ]
```

## 最終レポートフォーマット

```
ORCHESTRATION REPORT
====================
ワークフロー: feature
タスク: ユーザー認証を追加
エージェント: planner -> tdd-guide -> code-reviewer -> security-reviewer

サマリー
-------
[1段落の要約]

エージェント出力
-------------
Planner: [要約]
TDD Guide: [要約]
Code Reviewer: [要約]
Security Reviewer: [要約]

変更ファイル
-------------
[すべての変更ファイルをリスト]

テスト結果
------------
[テスト合格/失敗サマリー]

セキュリティステータス
---------------
[セキュリティの発見]

推奨
--------------
[SHIP / 要作業 / ブロック]
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

## 引数

$ARGUMENTS:
- `feature <description>` - 完全な機能ワークフロー
- `bugfix <description>` - バグ修正ワークフロー
- `refactor <description>` - リファクタリングワークフロー
- `security <description>` - セキュリティレビューワークフロー
- `custom <agents> <description>` - カスタムエージェントシーケンス

## ヒント

1. **複雑な機能はplannerから始める**
2. **マージ前には常にcode-reviewerを含める**
3. **認証/決済/PIIにはsecurity-reviewerを使用**
4. **ハンドオフは簡潔に** - 次のエージェントに必要なことに焦点
5. **必要に応じてエージェント間で検証を実行**
