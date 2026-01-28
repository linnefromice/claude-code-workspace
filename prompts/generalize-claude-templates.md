# Claude Code テンプレート汎用化プロンプト

## 概要

日本語訳済みの Claude Code 設定ファイルから、プロジェクト固有の記述を除去し、汎用テンプレートとして利用可能な形式に変換する。

---

## 入力

日本語訳済みファイル（`*.ja.md`）

## 出力

汎用化されたテンプレートファイル

---

## 汎用化ルール

### 1. 除外対象ファイル（言語/フレームワーク固有）

以下のファイルは汎用テンプレートから**除外**:

| カテゴリ | ファイル | 理由 |
|----------|----------|------|
| Agents | `go-*.ja.md` | Go言語固有 |
| Commands | `go-*.ja.md` | Go言語固有 |
| Skills | `golang-*.ja.md` | Go言語固有 |
| Skills | `clickhouse-io.ja.md` | DB固有 |
| Skills | `postgres-patterns.ja.md` | DB固有 |

### 2. 置換ルール

| 元の記述 | 汎用化後 |
|----------|----------|
| `pnpm run ...` | `npm run ...` または `{パッケージマネージャー} run ...` |
| `@dipsy/ui`, `@dipsy/api` 等 | `@your-org/ui`, `@your-org/api` または削除 |
| `apps/admin/`, `apps/sponsor/` | `apps/{app-name}/` |
| `docs/specs/SPONSOR.md` | `docs/specs/{機能名}.md` |
| 固有のポート番号 | `{PORT}` または削除 |
| 固有のドメイン/URL | `example.com` または `{YOUR_DOMAIN}` |

### 3. セクションの調整

#### 参照ドキュメントセクション

```markdown
# Before（プロジェクト固有）
| ドキュメント | パス |
|--------------|------|
| 機能仕様書 | `docs/specs/SPONSOR.md` |
| RSCパターン | `.claude/skills/rsc-patterns/SKILL.md` |

# After（汎用化）
| ドキュメント | パス |
|--------------|------|
| 機能仕様書 | `docs/specs/{機能名}.md` |
| プロジェクトスキル | `.claude/skills/{skill-name}/SKILL.md` |
```

#### プロジェクト構成セクション

```markdown
# Before（プロジェクト固有）
dipsy-portal-web/
├── apps/
│   ├── admin/     # Admin Portal (Next.js 16, Port 3000)
│   └── sponsor/   # Sponsor Portal (Next.js 16, Port 3001)

# After（汎用化）
{project-name}/
├── apps/
│   └── {app-name}/   # アプリケーション
├── packages/
│   └── {package-name}/ # 共有パッケージ
```

### 4. フレームワーク固有の記述

以下は「例」として残すか、コメントで補足:

- Next.js App Router の記述 → `// Next.js の場合` とコメント追加
- React Server Components → フレームワーク非依存の説明に書き換え
- WorkOS AuthKit → `// 認証プロバイダーの例` とコメント追加

---

## 実行手順

### Step 1: 対象ファイルの選別

```bash
cd translated

# 除外対象を確認
ls agents/go-*.ja.md 2>/dev/null
ls commands/go-*.ja.md 2>/dev/null
ls skills/golang-*.ja.md 2>/dev/null
ls skills/clickhouse-*.ja.md 2>/dev/null
ls skills/postgres-*.ja.md 2>/dev/null

# 汎用化対象をリスト
find . -name "*.ja.md" | grep -v "go-" | grep -v "golang-" | grep -v "clickhouse-" | grep -v "postgres-"
```

### Step 2: 汎用化の実行

以下のプロンプトを Claude Code に入力:

```
以下のファイルを汎用テンプレートとして利用できるよう修正してください。

修正ルール:
1. プロジェクト固有のパス・名前をプレースホルダーに置換
2. 特定のフレームワーク/DBへの依存を軽減
3. 日本語のコメントで「カスタマイズポイント」を明示

対象ファイル:
@{ファイルパス}
```

### Step 3: 出力先への配置

```bash
# 汎用化済みファイルをテンプレートディレクトリに配置
mkdir -p ../setup-claude-code-config/{agents,commands,rules,skills,contexts}

# .ja.md を .md にリネームしてコピー（または ja サフィックスを維持）
for f in agents/*.ja.md; do
  cp "$f" "../setup-claude-code-config/agents/$(basename "$f" .ja.md).md"
done
# 他のディレクトリも同様...
```

---

## 汎用化チェックリスト

各ファイルについて以下を確認:

- [ ] プロジェクト固有のパッケージ名が除去/置換されている
- [ ] 固有のファイルパスがプレースホルダーになっている
- [ ] 特定のフレームワークへの依存が明示されている（またはコメント化）
- [ ] コマンド例が汎用的になっている（`pnpm` → `npm` または注記）
- [ ] 固有のドメイン/URLが除去されている
- [ ] カスタマイズポイントがコメントで明示されている

---

## カスタマイズポイントの記法

汎用テンプレートでは、ユーザーがカスタマイズすべき箇所を以下の形式で明示:

```markdown
<!-- CUSTOMIZE: プロジェクト固有の設定に置き換えてください -->

| 項目 | 値 |
|------|-----|
| パッケージマネージャー | `npm` / `yarn` / `pnpm` |
| UIライブラリ | `@your-org/ui` |
```

または frontmatter で:

```yaml
---
name: template-name
description: "テンプレートの説明"
# CUSTOMIZE: 以下をプロジェクトに合わせて変更
# tools: Read, Write, Edit, Bash, Grep, Glob
# model: opus
---
```

---

## 優先度別の汎用化対象

### 高優先度（必須）

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
| `rules/testing.ja.md` | テスト指針は有用 |
| `agents/refactor-cleaner.ja.md` | リファクタリングは汎用的 |
| `contexts/research.ja.md` | 調査モードは有用 |

### 低優先度（オプション）

| ファイル | 理由 |
|----------|------|
| `commands/*.ja.md` | コマンドは好みが分かれる |
| `skills/*.ja.md` | プロジェクト固有度が高い |

---

## 次のステップ

汎用化完了後:
1. `setup-claude-code-config/` に配置
2. `setup.sh` スクリプトでインストール可能にする
3. `README.md` で使い方を説明
