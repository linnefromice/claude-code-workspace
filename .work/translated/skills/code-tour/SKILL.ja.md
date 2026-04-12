---
name: code-tour
description: CodeTour の `.tour` ファイルを作成します。実際のファイルと行のアンカーを持つペルソナ対象のステップバイステップウォークスルーです。オンボーディングツアー、アーキテクチャウォークスルー、PR ツアー、RCA ツアー、および構造化された「これがどのように動作するか説明して」というリクエストに使用します。
origin: ECC
---

# Code Tour

実際のファイルと行範囲に直接開く、コードベースウォークスルー用の **CodeTour** `.tour` ファイルを作成します。ツアーは `.tours/` に配置され、アドホックな Markdown ノートではなく CodeTour フォーマット向けに作られています。

良いツアーは特定の読者向けのナラティブです:
- 彼らが見ているもの
- なぜそれが重要か
- 次にどの経路をたどるべきか

`.tour` JSON ファイルのみを作成します。このスキルの一部としてソースコードを変更しないでください。

## 使用タイミング

以下の場合にこのスキルを使用します:
- ユーザーがコードツアー、オンボーディングツアー、アーキテクチャウォークスルー、または PR ツアーを要求する
- ユーザーが「X がどう動作するか説明して」と言い、再利用可能なガイド付きアーティファクトを望む
- ユーザーが新しいエンジニアまたはレビュアー向けの助走経路を望む
- タスクがフラットな要約よりもガイド付きシーケンスの方が適している

例:
- 新しいメンテナーのオンボーディング
- 1 つのサービスまたはパッケージのアーキテクチャツアー
- 変更ファイルにアンカーされた PR レビューウォークスルー
- 障害経路を示す RCA ツアー
- 信頼境界と主要チェックのセキュリティレビューツアー

## 使用しないタイミング

| code-tour の代わりに | 使用するもの |
| --- | --- |
| 1 回限りのチャットでの説明で十分 | 直接回答 |
| ユーザーが `.tour` アーティファクトではなく散文ドキュメントを望む | `documentation-lookup` またはリポジトリドキュメント編集 |
| タスクが実装またはリファクタリング | 実装作業を実施 |
| ツアーアーティファクトのない広範なコードベースオンボーディング | `codebase-onboarding` |

## ワークフロー

### 1. 発見

何かを書く前にリポジトリを探索します:
- README とパッケージ/アプリのエントリーポイント
- フォルダ構造
- 関連する設定ファイル
- ツアーが PR 中心の場合、変更されたファイル

コードの形を理解する前にステップを書き始めないでください。

### 2. 読者を推測

リクエストからペルソナと深さを決定します。

| リクエスト形式 | ペルソナ | 推奨深さ |
| --- | --- | --- |
| 「オンボーディング」「新規参加者」 | `new-joiner` | 9-13 ステップ |
| 「クイックツアー」「雰囲気チェック」 | `vibecoder` | 5-8 ステップ |
| 「アーキテクチャ」 | `architect` | 14-18 ステップ |
| 「この PR をツアー」 | `pr-reviewer` | 7-11 ステップ |
| 「なぜこれが壊れたか」 | `rca-investigator` | 7-11 ステップ |
| 「セキュリティレビュー」 | `security-reviewer` | 7-11 ステップ |
| 「この機能がどう動作するか説明」 | `feature-explainer` | 7-11 ステップ |
| 「この経路をデバッグ」 | `bug-fixer` | 7-11 ステップ |

### 3. アンカーを読んで検証

すべてのファイルパスと行アンカーは実在しなければなりません:
- ファイルが存在することを確認
- 行番号が範囲内であることを確認
- selection を使用する場合、正確なブロックを検証
- ファイルが volatile な場合、パターンベースのアンカーを優先

行番号を推測しないでください。

### 4. `.tour` を書く

以下に書き込みます:

```text
.tours/<persona>-<focus>.tour
```

パスを決定論的で読みやすく保ちます。

### 5. 検証

終了前に:
- 参照されるパスすべてが存在
- すべての行または selection が有効
- 最初のステップが実在のファイルまたはディレクトリにアンカーされている
- ツアーがファイルをリストするのではなく、首尾一貫したストーリーを語る

## ステップタイプ

### Content

控えめに使用し、通常は締めのステップのみ:

```json
{ "title": "Next Steps", "description": "You can now trace the request path end to end." }
```

最初のステップを content のみにしないでください。

### Directory

読者をモジュールにオリエンテーションするために使用:

```json
{ "directory": "src/services", "title": "Service Layer", "description": "The core orchestration logic lives here." }
```

### File + line

これはデフォルトのステップタイプです:

```json
{ "file": "src/auth/middleware.ts", "line": 42, "title": "Auth Gate", "description": "Every protected request passes here first." }
```

### Selection

ファイル全体よりも 1 つのコードブロックが重要な場合に使用:

```json
{
  "file": "src/core/pipeline.ts",
  "selection": {
    "start": { "line": 15, "character": 0 },
    "end": { "line": 34, "character": 0 }
  },
  "title": "Request Pipeline",
  "description": "This block wires validation, auth, and downstream execution."
}
```

### Pattern

正確な行がドリフトするかもしれない場合に使用:

```json
{ "file": "src/app.ts", "pattern": "export default class App", "title": "Application Entry" }
```

### URI

役立つ場合、PR、issue、またはドキュメントに使用:

```json
{ "uri": "https://github.com/org/repo/pull/456", "title": "The PR" }
```

## ライティングルール: SMIG

各 description は以下に答えるべきです:
- **Situation**: 読者が何を見ているか
- **Mechanism**: どう動作するか
- **Implication**: このペルソナにとってなぜ重要か
- **Gotcha**: 賢い読者が見逃すかもしれないこと

description はコンパクトで、具体的で、実際のコードに根ざしたものに保ちます。

## ナラティブシェイプ

タスクが明確に別の何かを必要としない限り、このアーク構造を使用します:
1. オリエンテーション
2. モジュールマップ
3. コア実行経路
4. エッジケースまたは gotcha
5. クロージング / 次の動き

ツアーはインベントリではなく、経路のように感じられるべきです。

## 例

```json
{
  "$schema": "https://aka.ms/codetour-schema",
  "title": "API Service Tour",
  "description": "Walkthrough of the request path for the payments service.",
  "ref": "main",
  "steps": [
    {
      "directory": "src",
      "title": "Source Root",
      "description": "All runtime code for the service starts here."
    },
    {
      "file": "src/server.ts",
      "line": 12,
      "title": "Entry Point",
      "description": "The server boots here and wires middleware before any route is reached."
    },
    {
      "file": "src/routes/payments.ts",
      "line": 8,
      "title": "Payment Routes",
      "description": "Every payments request enters through this router before hitting service logic."
    },
    {
      "title": "Next Steps",
      "description": "You can now follow any payment request end to end with the main anchors in place."
    }
  ]
}
```

## アンチパターン

| アンチパターン | 修正 |
| --- | --- |
| フラットなファイルリスト | ステップ間の依存関係でストーリーを語る |
| 汎用的な説明 | 具体的なコードパスまたはパターンを名指し |
| 推測されたアンカー | すべてのファイルと行を先に検証 |
| クイックツアーに対してステップが多すぎる | 積極的にカット |
| 最初のステップが content のみ | 最初のステップを実在のファイルまたはディレクトリにアンカー |
| ペルソナミスマッチ | 汎用エンジニアではなく、実際の読者向けに書く |

## ベストプラクティス

- ステップ数をリポジトリサイズとペルソナ深さに比例させる
- オリエンテーションには directory ステップ、実体には file ステップを使用
- PR ツアーでは、変更されたファイルを最初にカバー
- モノレポでは、すべてをツアーするのではなく、関連するパッケージにスコープする
- 締めくくりは要約ではなく、読者が今できることで

## 関連スキル

- `codebase-onboarding`
- `coding-standards`
- `council`
- 公式の上流フォーマット: `microsoft/codetour`
