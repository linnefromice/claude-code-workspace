---
name: token-budget-advisor
description: >-
  Offers the user an informed choice about how much response depth to
  consume before answering. Use this skill when the user explicitly
  wants to control response length, depth, or token budget.
  TRIGGER when: "token budget", "token count", "token usage", "token limit",
  "response length", "answer depth", "short version", "brief answer",
  "detailed answer", "exhaustive answer", "respuesta corta vs larga",
  "cuántos tokens", "ahorrar tokens", "responde al 50%", "dame la versión
  corta", "quiero controlar cuánto usas", or clear variants where the
  user is explicitly asking to control answer size or depth.
  DO NOT TRIGGER when: user has already specified a level in the current
  session (maintain it), the request is clearly a one-word answer, or
  "token" refers to auth/session/payment tokens rather than response size.
origin: community
---

# Token Budget Advisor (TBA)

Claude が回答する**前に**、レスポンスの深さについてユーザーに選択肢を提示してレスポンスフローに介入します。

## 使用タイミング

- ユーザーがレスポンスの長さや詳細度を制御したい場合
- ユーザーがトークン、バジェット、深さ、またはレスポンスの長さに言及した場合
- ユーザーが「short version」「tldr」「brief」「al 25%」「exhaustive」などと言った場合
- ユーザーが事前に深さ/詳細レベルを選択したい場合全般

**トリガーしない場合**: ユーザーがこのセッションで既にレベルを設定済みの場合（サイレントに維持）、または回答が自明に1行の場合。

## 仕組み

### ステップ 1 — 入力トークンの推定

リポジトリの標準的なコンテキストバジェットヒューリスティックを使用して、プロンプトのトークン数をメンタルに推定します。

[context-budget](../context-budget/SKILL.md) と同じキャリブレーションガイダンスを使用します:

- 散文: `words × 1.3`
- コード中心またはコードブロックを含む混合コンテンツ: `chars / 4`

混合コンテンツの場合、主要なコンテンツタイプを使用し、推定ヒューリスティックを維持します。

### ステップ 2 — 複雑度によるレスポンスサイズの推定

プロンプトを分類し、乗数範囲を適用して完全なレスポンスウィンドウを取得します:

| 複雑度 | 乗数範囲 | プロンプト例 |
|--------|---------|-------------|
| Simple | 3× – 8× | 「What is X?」、はい/いいえ、単一の事実 |
| Medium | 8× – 20× | 「How does X work?」 |
| Medium-High | 10× – 25× | コンテキスト付きのコードリクエスト |
| Complex | 15× – 40× | 複数パートの分析、比較、アーキテクチャ |
| Creative | 10× – 30× | ストーリー、エッセイ、ナラティブライティング |

レスポンスウィンドウ = `input_tokens × mult_min` から `input_tokens × mult_max`（ただしモデルの設定済み出力トークン制限を超えない）。

### ステップ 3 — 深さオプションを提示する

回答する**前に**、実際の推定数値を使用して以下のブロックを提示します:

```
Analyzing your prompt...

Input: ~[N] tokens  |  Type: [type]  |  Complexity: [level]  |  Language: [lang]

Choose your depth level:

[1] Essential   (25%)  ->  ~[tokens]   Direct answer only, no preamble
[2] Moderate    (50%)  ->  ~[tokens]   Answer + context + 1 example
[3] Detailed    (75%)  ->  ~[tokens]   Full answer with alternatives
[4] Exhaustive (100%)  ->  ~[tokens]   Everything, no limits

Which level? (1-4 or say "25% depth", "50% depth", "75% depth", "100% depth")

Precision: heuristic estimate ~85-90% accuracy (±15%).
```

レベルごとのトークン推定（レスポンスウィンドウ内）:
- 25%  → `min + (max - min) × 0.25`
- 50%  → `min + (max - min) × 0.50`
- 75%  → `min + (max - min) × 0.75`
- 100% → `max`

### ステップ 4 — 選択されたレベルで回答する

| レベル | 目標長 | 含める | 省略する |
|--------|--------|--------|---------|
| 25% Essential | 最大2-4文 | 直接的な回答、主要な結論 | コンテキスト、例、ニュアンス、代替案 |
| 50% Moderate | 1-3段落 | 回答 + 必要なコンテキスト + 1例 | 深い分析、エッジケース、参考文献 |
| 75% Detailed | 構造化されたレスポンス | 複数の例、メリット/デメリット、代替案 | 極端なエッジケース、網羅的な参考文献 |
| 100% Exhaustive | 制限なし | すべて — 完全な分析、全コード、全視点 | なし |

## ショートカット — 質問をスキップする

ユーザーが既にレベルを示している場合、質問せずにそのレベルで即座に回答します:

| ユーザーの発言 | レベル |
|-------------|--------|
| 「1」/「25% depth」/「short version」/「brief answer」/「tldr」 | 25% |
| 「2」/「50% depth」/「moderate depth」/「balanced answer」 | 50% |
| 「3」/「75% depth」/「detailed answer」/「thorough answer」 | 75% |
| 「4」/「100% depth」/「exhaustive answer」/「full deep dive」 | 100% |

ユーザーがセッション中に以前レベルを設定した場合、変更するまで後続のレスポンスでそのレベルを**サイレントに維持**します。

## 精度に関する注記

このスキルはヒューリスティック推定を使用しています — 実際のトークナイザーは使用していません。精度は約85-90%、分散は±15%です。常に免責事項を表示してください。

## 例

### トリガー例

- 「Give me the short version first.」
- 「How many tokens will your answer use?」
- 「Respond at 50% depth.」
- 「I want the exhaustive answer, not the summary.」
- 「Dame la version corta y luego la detallada.」

### トリガーしない例

- 「What is a JWT token?」
- 「The checkout flow uses a payment token.」
- 「Is this normal?」
- 「Complete the refactor.」
- ユーザーがセッションで既に深さを選択した後のフォローアップ質問

## ソース

[TBA — Token Budget Advisor for Claude Code](https://github.com/Xabilimon1/Token-Budget-Advisor-Claude-Code-) のスタンドアロンスキルです。
オリジナルプロジェクトは Python 推定スクリプトも提供していますが、このリポジトリではスキルを自己完結型のヒューリスティックのみとして保持しています。
