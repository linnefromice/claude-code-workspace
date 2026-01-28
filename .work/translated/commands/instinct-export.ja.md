---
name: instinct-export
description: チームメイトや他のプロジェクトと共有するためにインスティンクトをエクスポート
command: /instinct-export
---

# インスティンクトエクスポートコマンド

インスティンクトを共有可能なフォーマットにエクスポート。以下に最適:
- チームメイトとの共有
- 新しいマシンへの転送
- プロジェクト規約への貢献

## 使用方法

```
/instinct-export                           # すべての個人インスティンクトをエクスポート
/instinct-export --domain testing          # testingインスティンクトのみエクスポート
/instinct-export --min-confidence 0.7      # 高信頼度インスティンクトのみエクスポート
/instinct-export --output team-instincts.yaml
```

## 処理内容

1. `~/.claude/homunculus/instincts/personal/`からインスティンクトを読み取り
2. フラグに基づいてフィルタリング
3. 機密情報を除去:
   - セッションIDを削除
   - ファイルパスを削除（パターンのみ保持）
   - 「先週」より古いタイムスタンプを削除
4. エクスポートファイルを生成

## 出力フォーマット

YAMLファイルを作成:

```yaml
# インスティンクトエクスポート
# 生成日: 2025-01-22
# ソース: personal
# 数: 12インスティンクト

version: "2.0"
exported_by: "continuous-learning-v2"
export_date: "2025-01-22T10:30:00Z"

instincts:
  - id: prefer-functional-style
    trigger: "新しい関数を書く時"
    action: "クラスよりも関数型パターンを使用"
    confidence: 0.8
    domain: code-style
    observations: 8
```

## プライバシー考慮

エクスポートに含まれるもの:
- ✅ トリガーパターン
- ✅ アクション
- ✅ 信頼度スコア
- ✅ ドメイン
- ✅ 観察数

エクスポートに含まれないもの:
- ❌ 実際のコードスニペット
- ❌ ファイルパス
- ❌ セッショントランスクリプト
- ❌ 個人識別子

## フラグ

- `--domain <name>`: 指定したドメインのみエクスポート
- `--min-confidence <n>`: 最小信頼度閾値（デフォルト: 0.3）
- `--output <file>`: 出力ファイルパス（デフォルト: instincts-export-YYYYMMDD.yaml）
- `--format <yaml|json|md>`: 出力フォーマット（デフォルト: yaml）
- `--include-evidence`: 証拠テキストを含める（デフォルト: 除外）
