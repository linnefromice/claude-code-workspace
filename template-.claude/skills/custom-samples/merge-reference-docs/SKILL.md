---
name: merge-reference-docs
description: 汎用的な参考Markdownファイルを基に、プロジェクト固有のファイルを拡張・更新するスキル
invocable: true
---

# 参考ドキュメントマージスキル

外部の汎用的なMarkdownファイル（ベストプラクティス、パターン集など）を参考に、プロジェクト固有のエージェント・スキル・ルールファイルを拡張・更新するスキルです。

---

## 使用タイミング

- 汎用的なガイドラインをプロジェクト固有の基準に統合したい
- 外部のベストプラクティス文書をプロジェクトルールに反映したい
- 他のプロジェクトで作成したエージェント定義を現プロジェクトに適合させたい

---

## 呼び出し方法

```
/merge-reference-docs @{基準ファイル} @{参考ファイル1} [@{参考ファイル2}...] type={agent|skill|rule}
```

### 例

```bash
# 単一リファレンス
/merge-reference-docs @.claude/agents/code-reviewer.md @.claude/agents/generic-reviewer.md type=agent

# 複数リファレンス
/merge-reference-docs @.claude/agents/code-reviewer.md @security-checklist.md @performance-guide.md type=agent
```

---

## 必要な入力

| パラメータ | 説明 | 例 |
|-----------|------|-----|
| `target` | 更新対象のファイル（基準） | `.claude/agents/code-reviewer.md` |
| `type` | ファイルの種類 | `agent` / `skill` / `rule` |
| `references` | 参考にするファイル（複数可） | `generic-reviewer.md` |

---

## 実行手順

### 1. ファイルの読み込みと分析

```
1. target（基準ファイル）を読み込む
   - プロジェクト固有の設定・パターンを把握
   - 維持すべき構造・セクションを特定

2. references（参考ファイル群）を順番に読み込む
   - 各ファイルから追加すべき観点・チェック項目を特定
   - 汎用的なベストプラクティスを抽出
```

### 2. マージ方針

```
維持するもの:
- target のフロントマター
- target のプロジェクト固有パターン
- target の参照ドキュメントリスト
- target の連携エージェント情報

追加・拡張するもの:
- references から抽出した汎用的なチェック項目
- 定量的な基準（閾値、計測指標）
- 追加のセキュリティ/パフォーマンス観点
```

### 3. 優先順位

```
高 ← target（プロジェクト固有）
   ← references[0]（1番目の参考ファイル）
   ← references[1]（2番目の参考ファイル）
低 ← ...以降同様
```

### 4. 検証

```
- フロントマターが正しいか確認
- Markdownの構文エラーがないか確認
- 内部リンク・参照が有効か確認
```

---

## ファイル種別ごとのマージルール

### Agent（エージェント）

| セクション | マージルール |
|-----------|-------------|
| フロントマター | target を維持 |
| ワークフロー | reference から追加可 |
| 専門領域 | reference から追加可 |
| 参照ドキュメント | target を維持 |
| チェックリスト | 両方をマージ（target優先） |
| 連携エージェント | target を維持 |

### Skill（スキル）

| セクション | マージルール |
|-----------|-------------|
| フロントマター | target を維持 |
| 使用例 | 両方をマージ（target優先） |
| 重要なルール | reference から追加可 |
| コード例 | target を維持 |

### Rule（ルール）

| セクション | マージルール |
|-----------|-------------|
| 適用条件 | target を維持 |
| パターン例 | 両方をマージ（target優先） |
| チェック項目 | reference から追加可 |
| 例外ケース | target を維持 |

---

## 使用例

### コードレビューエージェントの拡張

```
入力:
- target: .claude/agents/code-reviewer.md
- type: agent
- references:
  - security-checklist.md（セキュリティ観点）
  - performance-guide.md（パフォーマンス観点）

実行:
1. code-reviewer.md のプロジェクト固有パターンを維持
2. security-checklist.md からセキュリティチェック項目を追加
3. performance-guide.md からパフォーマンス観点を追加
4. 重複する内容は優先度の高いファイルを採用
```

---

## 注意事項

1. **プロジェクト固有性を維持**: references の内容がプロジェクトに適合しない場合はスキップ
2. **重複の回避**: 同じ内容が複数ファイルにある場合は優先順位に従う
3. **一貫性の確保**: マージ後の文書全体で用語・スタイルが統一されているか確認
4. **リファレンス数の目安**: 3〜5ファイル程度を推奨

---

## @記法の順序

| 順序 | 役割 | 説明 |
|-----|------|------|
| 1番目 | target | 更新対象（基準ファイル） |
| 2番目〜 | references | 参考にするファイル（複数可） |

```
/merge-reference-docs @{target} @{ref1} @{ref2} type={agent|skill|rule}
```

---

## 関連スキル

- **adapt-external-docs**: 汎用ドキュメントをプロジェクト形式に適合
