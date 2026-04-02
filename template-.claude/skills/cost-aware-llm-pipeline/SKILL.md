---
name: cost-aware-llm-pipeline
description: Cost optimization patterns for LLM API usage — model routing by task complexity, budget tracking, retry logic, and prompt caching.
origin: ECC
---

# Cost-Aware LLM Pipeline

品質を維持しながら LLM API コストを制御するためのパターンです。モデルルーティング、予算追跡、リトライロジック、プロンプトキャッシングを組み合わせ可能なパイプラインにまとめます。

## 起動条件

- LLM API（Claude、GPT など）を呼び出すアプリケーションを構築する場合
- 複雑さが異なるアイテムのバッチを処理する場合
- API 支出の予算内に収める必要がある場合
- 複雑なタスクの品質を犠牲にせずにコストを最適化する場合

## コアコンセプト

### 1. タスクの複雑さによるモデルルーティング

シンプルなタスクには安価なモデルを自動選択し、複雑なタスクには高価なモデルを確保します。

```python
MODEL_SONNET = "claude-sonnet-4-6"
MODEL_HAIKU = "claude-haiku-4-5-20251001"

_SONNET_TEXT_THRESHOLD = 10_000  # chars
_SONNET_ITEM_THRESHOLD = 30     # items

def select_model(
    text_length: int,
    item_count: int,
    force_model: str | None = None,
) -> str:
    """Select model based on task complexity."""
    if force_model is not None:
        return force_model
    if text_length >= _SONNET_TEXT_THRESHOLD or item_count >= _SONNET_ITEM_THRESHOLD:
        return MODEL_SONNET  # Complex task
    return MODEL_HAIKU  # Simple task (3-4x cheaper)
```

### 2. イミュータブルなコスト追跡

frozen dataclass を使用して累積支出を追跡します。各 API 呼び出しは新しいトラッカーを返し、状態を変更しません。

```python
from dataclasses import dataclass

@dataclass(frozen=True, slots=True)
class CostRecord:
    model: str
    input_tokens: int
    output_tokens: int
    cost_usd: float

@dataclass(frozen=True, slots=True)
class CostTracker:
    budget_limit: float = 1.00
    records: tuple[CostRecord, ...] = ()

    def add(self, record: CostRecord) -> "CostTracker":
        """Return new tracker with added record (never mutates self)."""
        return CostTracker(
            budget_limit=self.budget_limit,
            records=(*self.records, record),
        )

    @property
    def total_cost(self) -> float:
        return sum(r.cost_usd for r in self.records)

    @property
    def over_budget(self) -> bool:
        return self.total_cost > self.budget_limit
```

### 3. 限定的なリトライロジック

一時的なエラーのみリトライします。認証エラーやバッドリクエストエラーでは即座に失敗します。

```python
from anthropic import (
    APIConnectionError,
    InternalServerError,
    RateLimitError,
)

_RETRYABLE_ERRORS = (APIConnectionError, RateLimitError, InternalServerError)
_MAX_RETRIES = 3

def call_with_retry(func, *, max_retries: int = _MAX_RETRIES):
    """Retry only on transient errors, fail fast on others."""
    for attempt in range(max_retries):
        try:
            return func()
        except _RETRYABLE_ERRORS:
            if attempt == max_retries - 1:
                raise
            time.sleep(2 ** attempt)  # Exponential backoff
    # AuthenticationError, BadRequestError etc. → raise immediately
```

### 4. Prompt Caching

長いシステムプロンプトをキャッシュして、リクエストごとの再送信を回避します。

```python
messages = [
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": system_prompt,
                "cache_control": {"type": "ephemeral"},  # Cache this
            },
            {
                "type": "text",
                "text": user_input,  # Variable part
            },
        ],
    }
]
```

## コンポジション

4つのテクニックすべてを1つのパイプライン関数に統合します：

```python
def process(text: str, config: Config, tracker: CostTracker) -> tuple[Result, CostTracker]:
    # 1. Route model
    model = select_model(len(text), estimated_items, config.force_model)

    # 2. Check budget
    if tracker.over_budget:
        raise BudgetExceededError(tracker.total_cost, tracker.budget_limit)

    # 3. Call with retry + caching
    response = call_with_retry(lambda: client.messages.create(
        model=model,
        messages=build_cached_messages(system_prompt, text),
    ))

    # 4. Track cost (immutable)
    record = CostRecord(model=model, input_tokens=..., output_tokens=..., cost_usd=...)
    tracker = tracker.add(record)

    return parse_result(response), tracker
```

## 料金リファレンス（2025-2026）

| モデル | 入力（$/1M トークン） | 出力（$/1M トークン） | 相対コスト |
|-------|---------------------|----------------------|---------------|
| Haiku 4.5 | $0.80 | $4.00 | 1x |
| Sonnet 4.6 | $3.00 | $15.00 | 約4x |
| Opus 4.5 | $15.00 | $75.00 | 約19x |

## ベストプラクティス

- **最も安いモデルから始める** — 複雑さの閾値を満たした場合のみ高価なモデルにルーティングします
- **バッチ処理の前に明示的な予算制限を設定する** — 過剰支出よりも早期に失敗させます
- **モデル選択の判断をログに記録する** — 実データに基づいて閾値を調整できるようにします
- **1024トークン以上のシステムプロンプトには Prompt Caching を使用する** — コストとレイテンシーの両方を削減します
- **認証エラーやバリデーションエラーではリトライしない** — 一時的な障害（ネットワーク、レートリミット、サーバーエラー）のみリトライします

## 避けるべきアンチパターン

- 複雑さに関係なくすべてのリクエストに最も高価なモデルを使用すること
- すべてのエラーでリトライすること（永続的な障害で予算を浪費）
- コスト追跡の状態を変更すること（デバッグと監査が困難になる）
- コードベース全体にモデル名をハードコードすること（定数または設定を使用）
- 繰り返しのシステムプロンプトで Prompt Caching を無視すること

## 使用タイミング

- Claude、OpenAI、または同様の LLM API を呼び出す任意のアプリケーション
- コストがすぐに蓄積するバッチ処理パイプライン
- インテリジェントなルーティングが必要なマルチモデルアーキテクチャ
- 予算ガードレールが必要な本番システム
