---
name: evolve
description: インスティンクトを分析し、進化した構造を提案または生成
command: true
---

# Evolveコマンド

## 実装

プラグインルートパスを使用してインスティンクトCLIを実行:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/scripts/instinct-cli.py" evolve [--generate]
```

`CLAUDE_PLUGIN_ROOT` が設定されていない場合（手動インストール）:

```bash
python3 ~/.claude/skills/continuous-learning-v2/scripts/instinct-cli.py evolve [--generate]
```

インスティンクトを分析し、関連するものを上位構造にクラスタリングします:
- **コマンド**: ユーザーが呼び出すアクションを記述するインスティンクト
- **スキル**: 自動トリガーされる動作を記述するインスティンクト
- **エージェント**: 複雑なマルチステッププロセスを記述するインスティンクト

## 使用方法

```
/evolve                    # すべてのインスティンクトを分析して進化を提案
/evolve --generate         # 分析に加えて evolved/{skills,commands,agents} 配下にファイルを生成
```

## 進化ルール

### → コマンド（ユーザー呼び出し）
ユーザーが明示的に要求するアクションを記述するインスティンクト:
- 「ユーザーが...を要求した時」に関する複数のインスティンクト
- 「新しいXを作成する時」のようなトリガーを持つインスティンクト
- 繰り返し可能なシーケンスに従うインスティンクト

例:
- `new-table-step1`: 「データベーステーブルを追加する時、マイグレーションを作成」
- `new-table-step2`: 「データベーステーブルを追加する時、スキーマを更新」
- `new-table-step3`: 「データベーステーブルを追加する時、型を再生成」

→ 作成: **new-table** コマンド

### → スキル（自動トリガー）
自動的に発生すべき動作を記述するインスティンクト:
- パターンマッチングトリガー
- エラーハンドリング応答
- コードスタイル強制

例:
- `prefer-functional`: 「関数を書く時、関数型スタイルを優先」
- `use-immutable`: 「状態を変更する時、イミュータブルパターンを使用」
- `avoid-classes`: 「モジュールを設計する時、クラスベースのデザインを避ける」

→ 作成: `functional-patterns` スキル

### → エージェント（深さ/分離が必要）
分離が有益な複雑なマルチステッププロセスを記述するインスティンクト:
- デバッグワークフロー
- リファクタリングシーケンス
- 調査タスク

例:
- `debug-step1`: 「デバッグ時、まずログを確認」
- `debug-step2`: 「デバッグ時、失敗しているコンポーネントを分離」
- `debug-step3`: 「デバッグ時、最小再現を作成」
- `debug-step4`: 「デバッグ時、テストで修正を検証」

→ 作成: **debugger** エージェント

## 処理内容

1. 現在のプロジェクトコンテキストを検出
2. プロジェクト + グローバルインスティンクトを読み取り（IDの競合時はプロジェクトが優先）
3. トリガー/ドメインパターンでインスティンクトをグループ化
4. 以下を特定:
   - スキル候補（2つ以上のインスティンクトを持つトリガークラスター）
   - コマンド候補（高信頼度のワークフローインスティンクト）
   - エージェント候補（より大きな高信頼度のクラスター）
5. 該当する場合、昇格候補（プロジェクト → グローバル）を表示
6. `--generate` が渡された場合、以下にファイルを書き込み:
   - プロジェクトスコープ: `~/.claude/homunculus/projects/<project-id>/evolved/`
   - グローバルフォールバック: `~/.claude/homunculus/evolved/`

## 出力フォーマット

```
============================================================
  EVOLVE ANALYSIS - 12 instincts
  Project: my-app (a1b2c3d4e5f6)
  Project-scoped: 8 | Global: 4
============================================================

High confidence instincts (>=80%): 5

## SKILL CANDIDATES
1. Cluster: "adding tests"
   Instincts: 3
   Avg confidence: 82%
   Domains: testing
   Scopes: project

## COMMAND CANDIDATES (2)
  /adding-tests
    From: test-first-workflow [project]
    Confidence: 84%

## AGENT CANDIDATES (1)
  adding-tests-agent
    Covers 3 instincts
    Avg confidence: 82%
```

## フラグ

- `--generate`: 分析出力に加えて進化したファイルを生成

## 生成ファイルフォーマット

### コマンド
```markdown
---
name: new-table
description: マイグレーション、スキーマ更新、型生成を含む新しいデータベーステーブルを作成
command: /new-table
evolved_from:
  - new-table-migration
  - update-schema
  - regenerate-types
---

# New Table コマンド

[クラスタリングされたインスティンクトに基づいて生成されたコンテンツ]

## ステップ
1. ...
2. ...
```

### スキル
```markdown
---
name: functional-patterns
description: 関数型プログラミングパターンを強制
evolved_from:
  - prefer-functional
  - use-immutable
  - avoid-classes
---

# Functional Patterns スキル

[クラスタリングされたインスティンクトに基づいて生成されたコンテンツ]
```

### エージェント
```markdown
---
name: debugger
description: 体系的なデバッグエージェント
model: sonnet
evolved_from:
  - debug-check-logs
  - debug-isolate
  - debug-reproduce
---

# Debugger エージェント

[クラスタリングされたインスティンクトに基づいて生成されたコンテンツ]
```
