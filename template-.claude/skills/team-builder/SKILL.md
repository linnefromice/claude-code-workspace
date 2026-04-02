---
name: team-builder
description: Interactive agent picker for composing and dispatching parallel teams
origin: community
---

# Team Builder

エージェントチームをオンデマンドで閲覧・構成するためのインタラクティブメニューです。フラットまたはドメインサブディレクトリ構成のエージェントコレクションに対応しています。

## 使用タイミング

- 複数のエージェントペルソナ（markdown ファイル）があり、タスクにどれを使用するか選びたい場合
- 異なるドメインからアドホックチームを構成したい場合（例: セキュリティ + SEO + アーキテクチャ）
- 決定する前にどのエージェントが利用可能か閲覧したい場合

## 前提条件

エージェントファイルはペルソナプロンプト（アイデンティティ、ルール、ワークフロー、成果物）を含む markdown ファイルである必要があります。最初の `# Heading` がエージェント名として使用され、最初の段落が説明として使用されます。

フラット構成とサブディレクトリ構成の両方がサポートされています:

**サブディレクトリ構成** — ドメインはフォルダ名から推定されます:

```
agents/
├── engineering/
│   ├── security-engineer.md
│   └── software-architect.md
├── marketing/
│   └── seo-specialist.md
└── sales/
    └── discovery-coach.md
```

**フラット構成** — ドメインは共有ファイル名プレフィックスから推定されます。プレフィックスは2つ以上のファイルで共有される場合にドメインとしてカウントされます。固有のプレフィックスを持つファイルは「General」に分類されます。注意: アルゴリズムは最初の `-` で分割するため、複数語のドメイン（例: `product-management`）はサブディレクトリ構成を使用してください:

```
agents/
├── engineering-security-engineer.md
├── engineering-software-architect.md
├── marketing-seo-specialist.md
├── marketing-content-strategist.md
├── sales-discovery-coach.md
└── sales-outbound-strategist.md
```

## 設定

エージェントは2つの方法で検出され、エージェント名でマージおよび重複排除されます:

1. **`claude agents` コマンド**（プライマリ） — `claude agents` を実行して、ユーザーエージェント、プラグインエージェント（例: `everything-claude-code:architect`）、ビルトインエージェントを含む CLI が認識するすべてのエージェントを取得します。これにより、パス設定なしで ECC マーケットプレイスのインストールが自動的にカバーされます。
2. **ファイル glob**（フォールバック、エージェントコンテンツの読み取り用） — エージェント markdown ファイルは以下から読み取られます:
   - `./agents/**/*.md` + `./agents/*.md` — プロジェクトローカルのエージェント
   - `~/.claude/agents/**/*.md` + `~/.claude/agents/*.md` — グローバルユーザーエージェント

名前が衝突した場合、前のソースが優先されます: ユーザーエージェント > プラグインエージェント > ビルトインエージェント。ユーザーが指定した場合はカスタムパスも使用できます。

## 仕組み

### ステップ 1: 利用可能なエージェントを検出する

`claude agents` を実行して完全なエージェントリストを取得します。各行を解析します:
- **プラグインエージェント**は `plugin-name:` のプレフィックスが付いています（例: `everything-claude-code:security-reviewer`）。`:` の後の部分をエージェント名として、プラグイン名をドメインとして使用します。
- **ユーザーエージェント**はプレフィックスなしです。`~/.claude/agents/` または `./agents/` から対応する markdown ファイルを読み取り、名前と説明を抽出します。
- **ビルトインエージェント**（例: `Explore`、`Plan`）は、ユーザーが明示的に含めるよう要求しない限りスキップされます。

markdown ファイルから読み込まれたユーザーエージェントの場合:
- **サブディレクトリ構成:** 親フォルダ名からドメインを抽出
- **フラット構成:** すべてのファイル名プレフィックス（最初の `-` の前のテキスト）を収集します。プレフィックスは2つ以上のファイル名に出現する場合にのみドメインとして認定されます（例: `engineering-security-engineer.md` と `engineering-software-architect.md` は両方とも `engineering` で始まる → Engineering ドメイン）。固有のプレフィックスを持つファイル（例: `code-reviewer.md`、`tdd-guide.md`）は「General」に分類されます
- 最初の `# Heading` からエージェント名を抽出します。見出しがない場合は、ファイル名から名前を導出します（`.md` を除去、ハイフンをスペースに置換、タイトルケース化）
- 見出しの後の最初の段落から1行の概要を抽出します

`claude agents` の実行とファイルの探索の両方でエージェントが見つからない場合、ユーザーに通知します: 「No agents found. Run `claude agents` to verify your setup.」その後停止します。

### ステップ 2: ドメインメニューを表示する

```
Available agent domains:
1. Engineering — Software Architect, Security Engineer
2. Marketing — SEO Specialist
3. Sales — Discovery Coach, Outbound Strategist

Pick domains or name specific agents (e.g., "1,3" or "security + seo"):
```

- エージェントがゼロのドメイン（空のディレクトリ）はスキップ
- ドメインごとのエージェント数を表示

### ステップ 3: 選択を処理する

柔軟な入力を受け付けます:
- 番号: 「1,3」で Engineering と Sales のすべてのエージェントを選択
- 名前: 「security + seo」で検出されたエージェントに対してあいまいマッチ
- 「all from engineering」でそのドメインのすべてのエージェントを選択

5つ以上のエージェントが選択された場合、アルファベット順にリストし、ユーザーに絞り込みを依頼します: 「You selected N agents (max 5). Pick which to keep, or say 'first 5' to use the first five alphabetically.」

選択を確認します:
```
Selected: Security Engineer + SEO Specialist
What should they work on? (describe the task):
```

### ステップ 4: エージェントを並列にスポーンする

1. 選択された各エージェントの markdown ファイルを読み取ります
2. まだ提供されていない場合、タスク説明の入力を求めます
3. Agent ツールを使用してすべてのエージェントを並列にスポーンします:
   - `subagent_type: "general-purpose"`
   - `prompt: "{agent file content}\n\nTask: {task description}"`
   - 各エージェントは独立して実行 — エージェント間の通信は不要
4. エージェントが失敗した場合（エラー、タイムアウト、または空の出力）、失敗をインラインで記録し（例: 「Security Engineer: failed — [reason]」）、成功したエージェントの結果で続行します

### ステップ 5: 結果を統合する

すべての出力を収集し、統一レポートを提示します:
- エージェントごとにグループ化された結果
- 以下を強調する統合セクション:
  - エージェント間の合意点
  - 推奨事項間の矛盾や緊張
  - 推奨される次のステップ

1つのエージェントのみが選択された場合、統合をスキップして出力を直接提示します。

## ルール

- **動的検出のみ。** エージェントリストをハードコードしないでください。ディレクトリ内の新しいファイルが自動的にメニューに表示されます。
- **チームあたり最大5エージェント。** 5つ以上は収穫逓減と過剰なトークン使用量につながります。選択時に強制します。
- **並列ディスパッチ。** すべてのエージェントが同時に実行されます — Agent ツールの並列呼び出しパターンを使用します。
- **並列 Agent 呼び出し、TeamCreate ではない。** このスキルは独立した作業に並列 Agent ツール呼び出しを使用します。TeamCreate（エージェントが議論したり互いに応答したりするための Claude Code ツール）は、エージェントが討論や相互応答を必要とする場合にのみ使用します。

## 例

```
User: team builder

Claude:
Available agent domains:
1. Engineering (2) — Software Architect, Security Engineer
2. Marketing (1) — SEO Specialist
3. Sales (4) — Discovery Coach, Outbound Strategist, Proposal Strategist, Sales Engineer
4. Support (1) — Executive Summary

Pick domains or name specific agents:

User: security + seo

Claude:
Selected: Security Engineer + SEO Specialist
What should they work on?

User: Review my Next.js e-commerce site before launch

[両方のエージェントが並列にスポーンされ、各自の専門分野をコードベースに適用]

Claude:
## Security Engineer Findings
- [findings...]

## SEO Specialist Findings
- [findings...]

## Synthesis
Both agents agree on: [...]
Tension: Security recommends CSP that blocks inline styles, SEO needs inline schema markup. Resolution: [...]
Next steps: [...]
```
