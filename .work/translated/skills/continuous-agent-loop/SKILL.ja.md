---
name: continuous-agent-loop
description: Patterns for continuous autonomous agent loops with quality gates, evals, and recovery controls.
origin: ECC
---

# 連続エージェントループ

v1.8+ の正規ループスキル名です。`autonomous-loops` を後継しつつ、1 リリース分の互換性を維持します。

## ループ選択フロー

```text
Start
  |
  +-- 厳格な CI/PR 制御が必要？ -- yes --> continuous-pr
  |
  +-- RFC 分解が必要？ -- yes --> rfc-dag
  |
  +-- 探索的な並列生成が必要？ -- yes --> infinite
  |
  +-- default --> sequential
```

## 統合パターン

推奨プロダクションスタック：
1. RFC 分解 (`ralphinho-rfc-pipeline`)
2. 品質ゲート (`plankton-code-quality` + `/quality-gate`)
3. eval ループ (`eval-harness`)
4. セッション永続化 (`nanoclaw-repl`)

## 障害モード

- 測定可能な進捗なしのループチャーン
- 同じ根本原因での繰り返しリトライ
- マージキューの停滞
- 無制限のエスカレーションによるコストドリフト

## リカバリー

- ループを凍結
- `/harness-audit` を実行
- 失敗しているユニットにスコープを縮小
- 明示的な受け入れ基準でリプレイ
