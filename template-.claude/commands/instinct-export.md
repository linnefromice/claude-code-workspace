---
name: instinct-export
description: プロジェクト/グローバルスコープからインスティンクトをファイルにエクスポート
command: /instinct-export
---

# インスティンクトエクスポートコマンド

インスティンクトを共有可能なフォーマットにエクスポートします。以下に最適:
- チームメイトとの共有
- 新しいマシンへの転送
- プロジェクト規約への貢献

## 使用方法

```
/instinct-export                           # すべての個人インスティンクトをエクスポート
/instinct-export --domain testing          # testingインスティンクトのみエクスポート
/instinct-export --min-confidence 0.7      # 高信頼度インスティンクトのみエクスポート
/instinct-export --output team-instincts.yaml
/instinct-export --scope project --output project-instincts.yaml
```

## 処理内容

1. 現在のプロジェクトコンテキストを検出
2. 選択されたスコープでインスティンクトを読み込み:
   - `project`: 現在のプロジェクトのみ
   - `global`: グローバルのみ
   - `all`: プロジェクト + グローバルのマージ（デフォルト）
3. フィルターを適用（`--domain`、`--min-confidence`）
4. YAMLスタイルのエクスポートをファイルに書き込み（出力パスが指定されていない場合はstdout）

## 出力フォーマット

YAMLファイルを作成:

```yaml
# インスティンクトエクスポート
# 生成日: 2025-01-22
# ソース: personal
# 数: 12インスティンクト

---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.8
domain: code-style
source: session-observation
scope: project
project_id: a1b2c3d4e5f6
project_name: my-app
---

# Prefer Functional Style

## Action
クラスよりも関数型パターンを使用。
```

## フラグ

- `--domain <name>`: 指定したドメインのみエクスポート
- `--min-confidence <n>`: 最小信頼度閾値
- `--output <file>`: 出力ファイルパス（省略時はstdoutに出力）
- `--scope <project|global|all>`: エクスポートスコープ（デフォルト: `all`）
