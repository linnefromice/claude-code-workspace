# ハーネス監査コマンド

決定論的なリポジトリハーネス監査を実行し、優先順位付きのスコアカードを返します。

## 使用方法

`/harness-audit [scope] [--format text|json] [--root path]`

- `scope`（オプション）: `repo`（デフォルト）、`hooks`、`skills`、`commands`、`agents`
- `--format`: 出力スタイル（`text` デフォルト、自動化用に `json`）
- `--root`: 現在の作業ディレクトリの代わりに特定のパスを監査

## 決定論的エンジン

常に以下を実行:

```bash
node scripts/harness-audit.js <scope> --format <text|json> [--root <path>]
```

このスクリプトがスコアリングとチェックの正規ソースです。追加のディメンションやアドホックなポイントを独自に考案しないでください。

ルーブリックバージョン: `2026-03-30`。

スクリプトは7つの固定カテゴリを計算します（各 `0-10` に正規化）:

1. ツールカバレッジ
2. コンテキスト効率
3. 品質ゲート
4. メモリ永続化
5. Evalカバレッジ
6. セキュリティガードレール
7. コスト効率

スコアは明示的なファイル/ルールチェックから導出され、同じコミットに対して再現可能です。
スクリプトはデフォルトで現在の作業ディレクトリを監査し、ターゲットがECCリポジトリ自体かECCを使用するコンシューマープロジェクトかを自動検出します。

## 出力契約

以下を返します:

1. `overall_score` / `max_score`（`repo` の場合70; スコープ付き監査はより小さい値）
2. カテゴリスコアと具体的な発見事項
3. 正確なファイルパスが付いた失敗チェック
4. 決定論的出力からのトップ3アクション（`top_actions`）
5. 次に適用すべき推奨ECCスキル

## チェックリスト

- スクリプト出力を直接使用し、手動で再スコアリングしないでください。
- `--format json` が要求された場合、スクリプトのJSONをそのまま返してください。
- textが要求された場合、失敗チェックとトップアクションをまとめてください。
- `checks[]` と `top_actions[]` の正確なファイルパスを含めてください。

## 結果例

```text
Harness Audit (repo): 66/70
- Tool Coverage: 10/10 (10/10 pts)
- Context Efficiency: 9/10 (9/10 pts)
- Quality Gates: 10/10 (10/10 pts)

Top 3 Actions:
1) [Security Guardrails] Add prompt/tool preflight security guards in hooks/hooks.json. (hooks/hooks.json)
2) [Tool Coverage] Sync commands/harness-audit.md and .opencode/commands/harness-audit.md. (.opencode/commands/harness-audit.md)
3) [Eval Coverage] Increase automated test coverage across scripts/hooks/lib. (tests/)
```

## 引数

$ARGUMENTS:
- `repo|hooks|skills|commands|agents`（オプションのスコープ）
- `--format text|json`（オプションの出力フォーマット）
