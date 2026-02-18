# カスタムスキル・コマンドの作成・追加

テンプレートを適用した後に、プロジェクト固有のスキルやコマンドを追加・カスタマイズするためのガイドです。

---

## 概要

テンプレートは汎用的なベストプラクティスを提供しますが、実際のプロジェクトではさらに固有のスキルが必要になることがあります。

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│ テンプレート適用  │────▶│ プロジェクト適合 │────▶│ カスタムスキル追加│
│ (deploy-to-project)│    │ (adapt-external) │     │ (独自スキル)     │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

---

## 推奨カスタムスキル

以下は多くのプロジェクトで有用なカスタムスキルです。

### adapt-external-docs

**目的:** 汎用的なエージェント・スキル・ルールをプロジェクト固有の形式に適合

**使用タイミング:**
- テンプレートを適用した直後
- 外部からドキュメントを導入するとき
- 他プロジェクトからファイルを移植するとき

**主な機能:**
- フロントマター形式の統一
- 言語の統一（日本語化）
- 参照パスのプロジェクト固有化
- コマンド形式の統一（npm → pnpm 等）

### カスタムコマンド

スキルに加えて、以下のカスタムコマンドも提供されています。

#### create-pr

**目的:** ローカルの未コミット変更から新規ブランチを作成し、PRを一括作成

**主な機能:**
- 変更内容を分析して `<type>/<short-desc>` 形式のブランチ名を自動生成
- センシティブファイル（.env 等）のステージング防止
- Conventional Commits 形式のコミットメッセージ
- PR タイトル・本文を自動生成

#### merge-pr

**目的:** PRのCI確認からマージ、ブランチクリーンアップまでを一括実行

**主な機能:**
- PR 番号の引数指定 or カレントブランチから自動検出
- CI pending 時は完了まで待機
- CI 失敗時はマージせず停止
- マージ後にデフォルトブランチ名を動的取得して切り替え

---

### merge-reference-docs

**目的:** 外部のベストプラクティスをプロジェクトファイルに統合

**使用タイミング:**
- 既存のエージェント・ルールを拡張するとき
- 複数の参考文書を1つに統合するとき
- セキュリティ・パフォーマンス観点を追加するとき

**主な機能:**
- プロジェクト固有設定を維持しながらマージ
- 優先順位に基づく内容統合
- 重複内容の整理

---

## スキルの追加方法

### 方法A: デプロイスクリプトを使用（推奨）

```bash
# 全てのカスタムスキル・コマンドをデプロイ
./scripts/deploy-custom-skills.sh /path/to/project --all

# 対話モードで選択
./scripts/deploy-custom-skills.sh /path/to/project -i

# 特定のスキルのみ
./scripts/deploy-custom-skills.sh /path/to/project --skill adapt-external-docs

# 特定のコマンドのみ
./scripts/deploy-custom-skills.sh /path/to/project --command create-pr --command merge-pr

# スキルとコマンドを組み合わせ
./scripts/deploy-custom-skills.sh /path/to/project --skill adapt-external-docs --command create-pr

# 利用可能なスキル・コマンド一覧を表示
./scripts/deploy-custom-skills.sh --list

# ドライラン（確認のみ）
./scripts/deploy-custom-skills.sh /path/to/project --all --dry-run
```

### 方法B: 手動コピー

```bash
# サンプルスキルをコピー
cp -r template-.claude/skills/custom-samples/adapt-external-docs/ /path/to/project/.claude/skills/
cp -r template-.claude/skills/custom-samples/merge-reference-docs/ /path/to/project/.claude/skills/

# プロジェクト固有にカスタマイズ
# → SKILL.md 内の <!-- CUSTOMIZE: --> コメント箇所を編集
```

### 方法C: 新規作成

1. ディレクトリを作成
   ```bash
   mkdir -p .claude/skills/your-skill-name/
   ```

2. SKILL.md を作成
   ```markdown
   ---
   name: your-skill-name
   description: "スキルの説明"
   invocable: true  # /コマンドで呼び出す場合
   ---

   # スキル名

   概要説明

   ---

   ## 使用タイミング

   - タイミング1
   - タイミング2

   ---

   ## 実行手順

   ### 1. ステップ1
   ...
   ```

---

## カスタムスキルのプロジェクト適合

### 適合が必要な項目

| 項目 | 適合内容 |
|------|----------|
| パッケージマネージャー | `npm` → `pnpm`, `yarn` 等 |
| ディレクトリ構成 | プロジェクト固有のパス |
| 参照ドキュメント | プロジェクト固有のドキュメントパス |
| 連携エージェント | 実在するエージェント名 |
| フロントマター | プロジェクトの形式に統一 |
| 言語 | 日本語 or 英語 |

### 適合例

**Before（汎用）:**
```markdown
## 参照ドキュメント
- 機能仕様書
- アーキテクチャ文書
```

**After（プロジェクト固有）:**
```markdown
## 参照ドキュメント

| ドキュメント | パス |
|-------------|------|
| 機能仕様書 | `docs/specs/FEATURE.md` |
| アーキテクチャ | `docs/ARCHITECTURE.md` |
```

---

## ディレクトリ構成

```
.claude/
├── agents/          # エージェント定義
├── commands/        # コマンド定義
│   ├── plan.md              # テンプレートから
│   ├── create-pr.md         # ★ カスタム追加
│   └── merge-pr.md          # ★ カスタム追加
├── rules/           # ルール定義
├── contexts/        # コンテキスト定義
└── skills/          # スキル定義
    ├── coding-standards/      # テンプレートから
    ├── verification-loop/     # テンプレートから
    ├── adapt-external-docs/   # ★ カスタム追加
    │   └── SKILL.md
    └── merge-reference-docs/  # ★ カスタム追加
        └── SKILL.md
```

---

## チェックリスト

カスタムスキル追加時の確認事項:

- [ ] SKILL.md にフロントマターがある
- [ ] `invocable: true` が設定されている（コマンドとして呼び出す場合）
- [ ] 使用タイミングが明記されている
- [ ] 実行手順が具体的である
- [ ] 参照パスがプロジェクト固有になっている
- [ ] 連携エージェントが実在する
- [ ] コマンド形式が統一されている

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [基本セットアップ](./01-project-setup-basic.md) | CLAUDE.md, .ai の配置 |
| [テンプレート適用](./02-project-setup-templates.md) | テンプレートのプロジェクト適用 |
| [テンプレート更新](./03-template-maintenance.md) | テンプレートのメンテナンス |
