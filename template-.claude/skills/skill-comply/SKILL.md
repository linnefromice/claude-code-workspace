---
name: skill-comply
description: Visualize whether skills, rules, and agent definitions are actually followed — auto-generates scenarios at 3 prompt strictness levels, runs agents, classifies behavioral sequences, and reports compliance rates with full tool call timelines
origin: ECC
tools: Read, Bash
---

# skill-comply: 自動コンプライアンス計測

コーディングエージェントがスキル、ルール、またはエージェント定義に実際に従っているかどうかを以下の方法で計測します:
1. 任意の .md ファイルから期待される行動シーケンス（仕様）を自動生成
2. プロンプトの厳密度を段階的に下げたシナリオを自動生成（supportive → neutral → competing）
3. `claude -p` を実行し、stream-json 経由でツールコールのトレースをキャプチャ
4. ツールコールを仕様のステップに対して LLM で分類（正規表現ではなく）
5. 時間的順序を決定論的にチェック
6. 仕様、プロンプト、タイムラインを含む自己完結型レポートを生成

## サポート対象

- **Skills** (`skills/*/SKILL.md`): search-first や TDD ガイドなどのワークフロースキル
- **Rules** (`rules/common/*.md`): testing.md、security.md、git-workflow.md などの必須ルール
- **Agent definitions** (`agents/*.md`): エージェントが期待通りに呼び出されるかどうか（内部ワークフローの検証はまだサポートされていません）

## 起動条件

- ユーザーが `/skill-comply <path>` を実行した場合
- ユーザーが「このルールは実際に守られている？」と質問した場合
- 新しいルール/スキルを追加した後、エージェントのコンプライアンスを検証する場合
- 品質メンテナンスの一環として定期的に実行する場合

## 使い方

```bash
# フル実行
uv run python -m scripts.run ~/.claude/rules/common/testing.md

# ドライラン（コストなし、仕様＋シナリオのみ）
uv run python -m scripts.run --dry-run ~/.claude/skills/search-first/SKILL.md

# カスタムモデル
uv run python -m scripts.run --gen-model haiku --model sonnet <path>
```

## 重要な概念: プロンプト独立性

プロンプトが明示的にサポートしていない場合でも、スキル/ルールが守られるかどうかを計測します。

## レポート内容

レポートは自己完結型で、以下を含みます:
1. 期待される行動シーケンス（自動生成された仕様）
2. シナリオプロンプト（各厳密度レベルで何を質問したか）
3. シナリオごとのコンプライアンススコア
4. LLM 分類ラベル付きのツールコールタイムライン

### 上級者向け（オプション）

Hooks に馴染みのあるユーザー向けに、レポートにはコンプライアンスが低いステップに対するフックプロモーションの推奨も含まれます。これは情報提供目的であり、主な価値はコンプライアンスの可視化そのものにあります。
