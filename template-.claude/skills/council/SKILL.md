---
name: council
description: 曖昧な判断、トレードオフ、go/no-go のコールのために 4 声の評議会を招集します。複数の有効なパスが存在し、選択する前に構造化された不一致が必要な場合に使用します。
origin: ECC
---

# Council

曖昧な判断のために 4 人のアドバイザーを招集します:
- in-context の Claude の声
- Skeptic サブエージェント
- Pragmatist サブエージェント
- Critic サブエージェント

これは**曖昧性の下での意思決定**のためのものであり、コードレビュー、実装計画、またはアーキテクチャ設計のためではありません。

## 使用タイミング

以下の場合に council を使用します:
- 判断に複数のクレディブルなパスがあり、明白な勝者がない
- トレードオフの明示的な表面化が必要
- ユーザーがセカンドオピニオン、反対意見、または複数の視点を求める
- 会話的アンカリングが真のリスク
- go / no-go のコールが敵対的チャレンジの恩恵を受ける

例:
- monorepo vs polyrepo
- 今 ship vs ポリッシュのために保留
- feature flag vs 完全なロールアウト
- スコープの簡素化 vs 戦略的な広さの維持

## 使用しないタイミング

| council の代わりに | 使用するもの |
| --- | --- |
| 出力が正しいかどうかの検証 | `santa-method` |
| 機能を実装ステップに分解 | `planner` |
| システムアーキテクチャの設計 | `architect` |
| バグやセキュリティのコードレビュー | `code-reviewer` または `santa-method` |
| 単純な事実質問 | 直接回答 |
| 明白な実行タスク | そのまま実施 |

## ロール

| 声 | レンズ |
| --- | --- |
| Architect | 正確性、保守性、長期的な影響 |
| Skeptic | 前提への挑戦、簡素化、仮定の打破 |
| Pragmatist | shipping スピード、ユーザーインパクト、運用上の現実 |
| Critic | エッジケース、下振れリスク、失敗モード |

3 つの外部の声は**質問と関連するコンテキストのみ**で新鮮なサブエージェントとして起動されるべきであり、進行中の完全な会話は渡しません。それがアンチアンカリングメカニズムです。

## ワークフロー

### 1. 本当の質問を抽出する

判断を 1 つの明示的なプロンプトに還元します:
- 何を決めているのか?
- どの制約が重要か?
- 何が成功としてカウントされるか?

質問が曖昧であれば、council を招集する前に 1 つの明確化質問をします。

### 2. 必要なコンテキストのみを集める

判断がコードベース固有の場合:
- 関連するファイル、スニペット、issue テキスト、またはメトリクスを集める
- コンパクトに保つ
- 判断に必要なコンテキストのみを含む

判断が戦略的/一般的な場合:
- 答えを実質的に変えない限り、リポジトリスニペットをスキップ

### 3. まず Architect のポジションを形成する

他の声を読む前に、以下を書き下します:
- 初期ポジション
- それを支持する 3 つの最も強い理由
- 優先パスにおける主要リスク

合成が外部の声を単に反映しないように、最初にこれを行います。

### 4. 3 つの独立した声を並列で起動する

各サブエージェントが受け取るもの:
- 判断質問
- 必要な場合コンパクトなコンテキスト
- 厳密なロール
- 不要な会話履歴なし

プロンプト形式:

```text
You are the [ROLE] on a four-voice decision council.

Question:
[decision question]

Context:
[only the relevant snippets or constraints]

Respond with:
1. Position — 1-2 sentences
2. Reasoning — 3 concise bullets
3. Risk — biggest risk in your recommendation
4. Surprise — one thing the other voices may miss

Be direct. No hedging. Keep it under 300 words.
```

ロールの強調:
- Skeptic: フレーミングに挑戦し、仮定を疑問視し、最もシンプルなクレディブルな代替案を提案
- Pragmatist: スピード、シンプルさ、現実世界の実行を最適化
- Critic: 下振れリスク、エッジケース、プランが失敗する理由を表面化

### 5. バイアスガードレール付きで合成する

あなたは参加者であり合成者でもあるため、以下のルールを使用します:
- 理由を説明せずに外部ビューを却下しない
- 外部の声が推奨を変えた場合、明示的にそう言う
- 却下する場合でも、常に最も強い反対意見を含める
- 2 つの声が初期ポジションに反して一致する場合、それを真のシグナルとして扱う
- 判決前に生のポジションを可視化する

### 6. コンパクトな判決を提示する

以下の出力形式を使用します:

```markdown
## Council: [short decision title]

**Architect:** [1-2 sentence position]
[1 line on why]

**Skeptic:** [1-2 sentence position]
[1 line on why]

**Pragmatist:** [1-2 sentence position]
[1 line on why]

**Critic:** [1-2 sentence position]
[1 line on why]

### Verdict
- **Consensus:** [where they align]
- **Strongest dissent:** [most important disagreement]
- **Premise check:** [did the Skeptic challenge the question itself?]
- **Recommendation:** [the synthesized path]
```

携帯電話画面でスキャン可能に保ちます。

## 永続化ルール

このスキルから `~/.claude/notes` その他の shadow パスにアドホックなノートを書き込ま**ない**でください。

council が推奨を実質的に変更した場合:
- `knowledge-ops` を使用して、適切な永続的な場所にレッスンを保存する
- または結果がセッションメモリに属する場合は `/save-session` を使用する
- または判断がアクティブな実行の真実を変更する場合は、関連する GitHub / Linear issue を直接更新する

判断が実際に何かを変える場合にのみ永続化します。

## マルチラウンドフォローアップ

デフォルトは 1 ラウンドです。

ユーザーが別のラウンドを望む場合:
- 新しい質問をフォーカスした状態に保つ
- 必要な場合のみ前回の判決を含める
- アンチアンカリング価値を保つため、Skeptic をできるだけクリーンに保つ

## アンチパターン

- council をコードレビューに使用する
- タスクが単なる実装作業である場合に council を使用する
- サブエージェントに会話トランスクリプト全体を渡す
- 最終判決で不一致を隠す
- 重要性に関係なく、すべての判断をノートとして永続化する

## 関連スキル

- `santa-method` — 敵対的検証
- `knowledge-ops` — 永続的な判断差分を正しく保存
- `search-first` — 必要に応じて council 前に外部参考資料を集める
- `architecture-decision-records` — 判断が長期的なシステムポリシーになる場合に結果を形式化

## 例

質問:

```text
Should we ship ECC 2.0 as alpha now, or hold until the control-plane UI is more complete?
```

考えられる council の形:
- Architect は構造的完全性と混乱したサーフェスの回避を押し進める
- Skeptic は UI が実際にゲーティング要因かどうかを疑問視する
- Pragmatist は信頼を損なわずに今何が ship できるかを問う
- Critic はサポート負担、期待負債、ロールアウトの混乱に焦点を当てる

価値は全会一致ではありません。価値は、選択する前に不一致を可視化することです。
