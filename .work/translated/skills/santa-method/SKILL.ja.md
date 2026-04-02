---
name: santa-method
description: "Multi-agent adversarial verification with convergence loop. Two independent review agents must both pass before output ships."
origin: "Ronald Skelton - Founder, RapportScore.ai"
---

# Santa Method

マルチエージェント敵対的検証フレームワーク。リストを作り、2回チェックする。問題があれば、良くなるまで修正する。

核心的な洞察: 単一のエージェントが自身の出力をレビューすると、その出力を生成したのと同じバイアス、知識のギャップ、体系的なエラーを共有します。共有コンテキストを持たない2人の独立したレビュアーが、この障害モードを打破します。

## 起動条件

以下の場合にこのスキルを呼び出します:
- 出力が公開、デプロイ、またはエンドユーザーに利用される場合
- コンプライアンス、規制、またはブランドの制約を適用する必要がある場合
- 人間のレビューなしにコードが本番環境にデプロイされる場合
- コンテンツの正確性が重要な場合（技術ドキュメント、教育資料、顧客向けコピー）
- スポットチェックでは体系的なパターンを見逃すような大規模バッチ生成の場合
- ハルシネーションのリスクが高い場合（主張、統計、API リファレンス、法的文言）

内部ドラフト、探索的リサーチ、または決定的な検証が可能なタスク（それらにはビルド/テスト/lint パイプラインを使用）には使用しないでください。

## アーキテクチャ

```
┌─────────────┐
│  GENERATOR   │  Phase 1: Make a List
│  (Agent A)   │  成果物を生成
└──────┬───────┘
       │ output
       ▼
┌──────────────────────────────┐
│     DUAL INDEPENDENT REVIEW   │  Phase 2: Check It Twice
│                                │
│  ┌───────────┐ ┌───────────┐  │  2つのエージェント、同一ルーブリック、
│  │ Reviewer B │ │ Reviewer C │  │  共有コンテキストなし
│  └─────┬─────┘ └─────┬─────┘  │
│        │              │        │
└────────┼──────────────┼────────┘
         │              │
         ▼              ▼
┌──────────────────────────────┐
│        VERDICT GATE           │  Phase 3: Naughty or Nice
│                                │
│  B passes AND C passes → NICE  │  両方がパスする必要あり。
│  Otherwise → NAUGHTY           │  例外なし。
└──────┬──────────────┬─────────┘
       │              │
    NICE           NAUGHTY
       │              │
       ▼              ▼
   [ SHIP ]    ┌─────────────┐
               │  FIX CYCLE   │  Phase 4: Fix Until Nice
               │              │
               │ iteration++  │  全フラグを収集。
               │ if i > MAX:  │  全問題を修正。
               │   escalate   │  両レビュアーを再実行。
               │ else:        │  収束するまでループ。
               │   goto Ph.2  │
               └──────────────┘
```

## フェーズ詳細

### フェーズ 1: Make a List（生成）

主要タスクを実行します。通常の生成ワークフローに変更はありません。Santa Method は生成戦略ではなく、生成後の検証レイヤーです。

```python
# ジェネレーターは通常通り実行
output = generate(task_spec)
```

### フェーズ 2: Check It Twice（独立デュアルレビュー）

2つのレビューエージェントを並列にスポーンします。重要な不変条件:

1. **コンテキスト分離** — どちらのレビュアーも相手の評価を見ない
2. **同一ルーブリック** — 両方が同じ評価基準を受け取る
3. **同一入力** — 両方が元の仕様書と生成された出力を受け取る
4. **構造化出力** — 各レビュアーは散文ではなく型付きの判定を返す

```python
REVIEWER_PROMPT = """
You are an independent quality reviewer. You have NOT seen any other review of this output.

## Task Specification
{task_spec}

## Output Under Review
{output}

## Evaluation Rubric
{rubric}

## Instructions
Evaluate the output against EACH rubric criterion. For each:
- PASS: criterion fully met, no issues
- FAIL: specific issue found (cite the exact problem)

Return your assessment as structured JSON:
{
  "verdict": "PASS" | "FAIL",
  "checks": [
    {"criterion": "...", "result": "PASS|FAIL", "detail": "..."}
  ],
  "critical_issues": ["..."],   // blockers that must be fixed
  "suggestions": ["..."]         // non-blocking improvements
}

Be rigorous. Your job is to find problems, not to approve.
"""
```

```python
# レビュアーを並列にスポーン（Claude Code サブエージェント）
review_b = Agent(prompt=REVIEWER_PROMPT.format(...), description="Santa Reviewer B")
review_c = Agent(prompt=REVIEWER_PROMPT.format(...), description="Santa Reviewer C")

# 両方が同時に実行 — どちらも相手を見ない
```

### ルーブリック設計

ルーブリックは最も重要な入力です。曖昧なルーブリックは曖昧なレビューを生みます。すべての基準には客観的な合格/不合格条件が必要です。

| 基準 | 合格条件 | 不合格シグナル |
|------|---------|--------------|
| 事実の正確性 | すべての主張がソース資料または常識で検証可能 | 捏造された統計、間違ったバージョン番号、存在しない API |
| ハルシネーションなし | 捏造されたエンティティ、引用、URL、参照がない | 存在しないページへのリンク、出典のない引用 |
| 完全性 | 仕様のすべての要件が対応されている | 欠落セクション、スキップされたエッジケース、不完全なカバレッジ |
| コンプライアンス | すべてのプロジェクト固有の制約をパス | 禁止用語の使用、トーン違反、規制非準拠 |
| 内部一貫性 | 出力内に矛盾がない | セクション A が X と言い、セクション B が X でないと言う |
| 技術的正確性 | コードがコンパイル/実行される、アルゴリズムが健全 | 構文エラー、ロジックバグ、間違った計算量の主張 |

#### ドメイン固有のルーブリック拡張

**コンテンツ/マーケティング:**
- ブランドボイスへの準拠
- SEO 要件の充足（キーワード密度、メタタグ、構造）
- 競合他社の商標の誤用なし
- CTA が存在し正しくリンクされている

**コード:**
- 型安全性（`any` のリークなし、適切な null ハンドリング）
- エラーハンドリングのカバレッジ
- セキュリティ（コード内にシークレットなし、入力バリデーション、インジェクション防止）
- 新しいパスのテストカバレッジ

**コンプライアンスが求められる場合（規制、法務、金融）:**
- 結果の保証や根拠のない主張がない
- 必要な免責事項が存在する
- 承認された用語のみ使用
- 管轄区域に適した言語

### フェーズ 3: Naughty or Nice（判定ゲート）

```python
def santa_verdict(review_b, review_c):
    """両方のレビュアーがパスする必要あり。部分的な合格なし。"""
    if review_b.verdict == "PASS" and review_c.verdict == "PASS":
        return "NICE"  # Ship it

    # 両レビュアーからフラグをマージ、重複排除
    all_issues = dedupe(review_b.critical_issues + review_c.critical_issues)
    all_suggestions = dedupe(review_b.suggestions + review_c.suggestions)

    return "NAUGHTY", all_issues, all_suggestions
```

なぜ両方がパスする必要があるのか: 1人のレビュアーだけが問題を発見した場合、その問題は実在します。もう1人のレビュアーの死角こそが、Santa Method が排除するために存在する障害モードそのものです。

### フェーズ 4: Fix Until Nice（収束ループ）

```python
MAX_ITERATIONS = 3

for iteration in range(MAX_ITERATIONS):
    verdict, issues, suggestions = santa_verdict(review_b, review_c)

    if verdict == "NICE":
        log_santa_result(output, iteration, "passed")
        return ship(output)

    # すべてのクリティカルな問題を修正（提案はオプション）
    output = fix_agent.execute(
        output=output,
        issues=issues,
        instruction="Fix ONLY the flagged issues. Do not refactor or add unrequested changes."
    )

    # 修正された出力に対して両方のレビュアーを再実行（前のラウンドの記憶を持たない新しいエージェント）
    review_b = Agent(prompt=REVIEWER_PROMPT.format(output=output, ...))
    review_c = Agent(prompt=REVIEWER_PROMPT.format(output=output, ...))

# イテレーション上限に達した — エスカレーション
log_santa_result(output, MAX_ITERATIONS, "escalated")
escalate_to_human(output, issues)
```

重要: 各レビューラウンドは**新しいエージェント**を使用します。レビュアーは前のラウンドの記憶を持ってはいけません。以前のコンテキストがアンカリングバイアスを生み出すためです。

## 実装パターン

### パターン A: Claude Code サブエージェント（推奨）

サブエージェントは真のコンテキスト分離を提供します。各レビュアーは共有状態を持たない別プロセスです。

```bash
# Claude Code セッションで、Agent ツールを使用してレビュアーをスポーン
# 両方のエージェントが高速化のために並列実行
```

```python
# Agent ツール呼び出しの擬似コード
reviewer_b = Agent(
    description="Santa Review B",
    prompt=f"Review this output for quality...\n\nRUBRIC:\n{rubric}\n\nOUTPUT:\n{output}"
)
reviewer_c = Agent(
    description="Santa Review C",
    prompt=f"Review this output for quality...\n\nRUBRIC:\n{rubric}\n\nOUTPUT:\n{output}"
)
```

### パターン B: シーケンシャルインライン（フォールバック）

サブエージェントが利用できない場合、明示的なコンテキストリセットで分離をシミュレートします:

1. 出力を生成
2. 新しいコンテキスト: 「あなたは Reviewer 1 です。このルーブリックに対してのみ評価してください。問題を見つけてください。」
3. 結果をそのまま記録
4. コンテキストを完全にクリア
5. 新しいコンテキスト: 「あなたは Reviewer 2 です。このルーブリックに対してのみ評価してください。問題を見つけてください。」
6. 両方のレビューを比較し、修正し、繰り返す

サブエージェントパターンの方が厳密に優れています — インラインシミュレーションはレビュアー間のコンテキスト汚染のリスクがあります。

### パターン C: バッチサンプリング

大規模バッチ（100+ アイテム）の場合、すべてのアイテムに完全な Santa を実行するのはコスト的に非現実的です。層別サンプリングを使用します:

1. ランダムサンプル（バッチの10-15%、最小5アイテム）に対して Santa を実行
2. 障害をタイプ別に分類（ハルシネーション、コンプライアンス、完全性など）
3. 体系的なパターンが見つかった場合、バッチ全体にターゲットを絞った修正を適用
4. 修正されたバッチを再サンプリングして再検証
5. クリーンなサンプルがパスするまで継続

```python
import random

def santa_batch(items, rubric, sample_rate=0.15):
    sample = random.sample(items, max(5, int(len(items) * sample_rate)))

    for item in sample:
        result = santa_full(item, rubric)
        if result.verdict == "NAUGHTY":
            pattern = classify_failure(result.issues)
            items = batch_fix(items, pattern)  # パターンに一致するすべてのアイテムを修正
            return santa_batch(items, rubric)   # 再サンプリング

    return items  # クリーンサンプル → バッチを出荷
```

## 障害モードと緩和策

| 障害モード | 症状 | 緩和策 |
|-----------|------|--------|
| 無限ループ | レビュアーが修正後も新しい問題を見つけ続ける | 最大イテレーション上限（3）。エスカレーション。 |
| ラバースタンプ | 両方のレビュアーがすべてを合格させる | 敵対的プロンプト: 「あなたの仕事は問題を見つけることであり、承認することではない。」 |
| 主観的ドリフト | レビュアーがエラーではなくスタイルの好みにフラグを立てる | 客観的な合格/不合格基準のみの厳密なルーブリック |
| 修正による退行 | 問題 A の修正が問題 B を引き起こす | 各ラウンドの新しいレビュアーが退行を検出 |
| レビュアーの一致バイアス | 両方のレビュアーが同じものを見逃す | 独立性により緩和されるが、排除されない。重要な出力の場合、3人目のレビュアーまたは人間のスポットチェックを追加。 |
| コスト爆発 | 大きな出力に対する過多なイテレーション | バッチサンプリングパターン。検証サイクルごとの予算上限。 |

## 他のスキルとの統合

| スキル | 関係 |
|--------|------|
| Verification Loop | 決定的チェック（ビルド、lint、テスト）に使用。Santa はセマンティックチェック（正確性、ハルシネーション）に使用。verification-loop を最初に実行し、Santa を2番目に実行。 |
| Eval Harness | Santa Method の結果が eval メトリクスにフィードされる。Santa 実行全体の pass@k を追跡し、ジェネレーター品質を経時的に測定。 |
| Continuous Learning v2 | Santa の発見がインスティンクトになる。同じ基準での繰り返しの失敗 → そのパターンを回避する学習された振る舞い。 |
| Strategic Compact | コンパクト化の前に Santa を実行。検証中にレビューコンテキストを失わない。 |

## メトリクス

Santa Method の効果を測定するために以下を追跡します:

- **初回パス率**: ラウンド1で Santa をパスする出力の割合（目標: >70%）
- **平均収束イテレーション数**: NICE までの平均ラウンド数（目標: <1.5）
- **問題分類**: 障害タイプの分布（ハルシネーション vs 完全性 vs コンプライアンス）
- **レビュアー一致率**: 両方のレビュアーがフラグを立てた問題 vs 1人だけがフラグを立てた問題の割合（低い一致率 = ルーブリックの厳格化が必要）
- **漏洩率**: 出荷後に見つかった、Santa が検出すべきだった問題（目標: 0）

## コスト分析

Santa Method は検証サイクルごとに生成のみのトークンコストの約2-3倍かかります。ほとんどの高リスク出力にとって、これは安い投資です:

```
Santa のコスト = (生成トークン) + 2×(ラウンドごとのレビュートークン) × (平均ラウンド数)
Santa なしのコスト = (評判のダメージ) + (修正工数) + (信頼の毀損)
```

バッチ操作の場合、サンプリングパターンにより体系的な問題の90%以上を検出しながらコストを完全検証の約15-20%に削減します。
