---
description: 専門エージェントを使用した包括的な PR レビュー
---

プルリクエストに対して、複数の観点から包括的なレビューを実行します。

## 使用方法

`/review-pr [PR-number-or-URL] [--focus=comments|tests|errors|types|code|simplify]`

PR が指定されていない場合は、現在のブランチの PR をレビューします。focus が指定されていない場合は、フルレビュースタックを実行します。

## 手順

1. PR を特定:
   - `gh pr view` を使用して PR の詳細、変更ファイル、diff を取得
2. プロジェクトのガイダンスを検索:
   - `CLAUDE.md`、lint 設定、TypeScript 設定、リポジトリ規約を探す
3. 専門のレビューエージェントを実行:
   - `code-reviewer`
   - `comment-analyzer`
   - `pr-test-analyzer`
   - `silent-failure-hunter`
   - `type-design-analyzer`
   - `code-simplifier`
4. 結果を集約:
   - 重複する所見を統合
   - 重要度でランク付け
5. 重要度別にグループ化して所見を報告

## 確信度ルール

確信度 80 以上の issue のみを報告します:

- Critical: バグ、セキュリティ、データ消失
- Important: テスト不足、品質問題、スタイル違反
- Advisory: 明示的にリクエストされた場合のみの提案
