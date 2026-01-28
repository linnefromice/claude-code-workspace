# Claude Code テンプレート 汎用化プロンプト

## 概要

`.work/translated/` にある日本語訳済みファイルから、プロジェクト固有の記述を除去し、汎用テンプレートとして使用可能な形式に変換する。

**前提条件:** `do @prompts/collect-and-translate-claude-templates.md` が完了していること

---

## ディレクトリ構成

```
.work/translated/     # 入力 & 出力（その場で編集）
├── agents/*.ja.md
├── commands/*.ja.md
├── rules/*.ja.md
├── skills/*.ja.md
└── contexts/*.ja.md
        ↓
template-.claude/     # 最終配置先（deploy-templates.sh で配置）
├── agents/*.md
├── commands/*.md
├── rules/*.md
├── skills/*.md
└── contexts/*.md
```

---

## 汎用化の手順

### 1. 除外対象ファイルの削除

以下は言語/DB固有のため、`.work/translated/` から削除してください：

```bash
# Go言語固有
rm -f .work/translated/agents/go-*.ja.md
rm -f .work/translated/commands/go-*.ja.md
rm -f .work/translated/skills/golang-*.ja.md

# DB固有
rm -f .work/translated/skills/clickhouse-*.ja.md
rm -f .work/translated/skills/postgres-*.ja.md
```

### 2. プロジェクト固有の記述を置換

各ファイルを読み込み、以下の置換ルールを適用してください：

| 元の記述 | 汎用化後 |
|----------|----------|
| `pnpm run ...` | `npm run ...` |
| `pnpm install` | `npm install` |
| 特定のパッケージ名（`@dipsy/ui` 等） | `@your-org/...` または削除 |
| 特定のファイルパス（`docs/specs/SPONSOR.md` 等） | `docs/specs/{機能名}.md` |
| 特定のポート番号 | 削除または `{PORT}` |
| 特定のドメイン/URL | `example.com` または削除 |

### 3. プレースホルダーの追加

カスタマイズが必要な箇所にはコメントを追加：

```markdown
<!-- CUSTOMIZE: プロジェクトに合わせて変更してください -->
```

### 4. 汎用化結果の確認

```bash
# 残っているファイル数を確認
ls .work/translated/agents/ | wc -l
ls .work/translated/commands/ | wc -l
ls .work/translated/rules/ | wc -l
ls .work/translated/skills/ | wc -l
ls .work/translated/contexts/ | wc -l
```

---

## 汎用化の優先度

### 高優先度（必須で汎用化）

| ファイル | 理由 |
|----------|------|
| `rules/git-workflow.ja.md` | どのプロジェクトでも使用 |
| `rules/agents.ja.md` | エージェント活用の基盤 |
| `contexts/dev.ja.md` | 開発モードは必須 |
| `contexts/review.ja.md` | レビューモードは必須 |
| `agents/planner.ja.md` | 計画立案は汎用的 |
| `agents/code-reviewer.ja.md` | レビューは汎用的 |

### 中優先度（推奨）

| ファイル | 理由 |
|----------|------|
| `rules/coding-style.ja.md` | スタイルガイドは有用 |
| `rules/security.ja.md` | セキュリティは重要 |
| `agents/refactor-cleaner.ja.md` | リファクタリングは汎用的 |

### 低優先度（オプション）

| ファイル | 理由 |
|----------|------|
| `commands/*.ja.md` | コマンドは好みが分かれる |
| `skills/*.ja.md` | プロジェクト固有度が高い |

---

## 汎用化例

### Before（プロジェクト固有）

```markdown
## 参照すべきドキュメント

| ドキュメント | パス |
|--------------|------|
| 機能仕様書 | `docs/specs/SPONSOR.md` |
| UIコンポーネント | `@dipsy/ui` |
```

### After（汎用化後）

```markdown
## 参照すべきドキュメント

<!-- CUSTOMIZE: プロジェクトのドキュメントパスに置き換えてください -->

| ドキュメント | パス |
|--------------|------|
| 機能仕様書 | `docs/specs/{機能名}.md` |
| UIコンポーネント | `@your-org/ui` |
```

---

## チェックリスト

汎用化完了時に確認：

- [ ] Go/DB固有ファイルが削除されている
- [ ] 特定のパッケージ名が除去/置換されている
- [ ] 固有のファイルパスがプレースホルダーになっている
- [ ] コマンドが `npm` に統一されている
- [ ] カスタマイズポイントがコメントで明示されている

---

## 完了後

汎用化完了後、配置スクリプトを実行してください：

```bash
./scripts/deploy-templates.sh
```

これにより `.work/translated/` の内容が `template-.claude/` に配置されます（`.ja.md` → `.md` にリネーム）。
