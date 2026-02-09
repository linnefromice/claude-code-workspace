# Claude Code テンプレートの適用

汎用化済みの Claude Code テンプレート（エージェント、コマンド、ルール等）を対象プロジェクトに適用します。

---

## 概要

このセットアップでは `template-.claude/` の内容を対象プロジェクトの `.claude/` にコピーします。
プロジェクトの種類や習熟度に応じて、適用するテンプレートを選択できます。

---

## プリセット

| プリセット | レベル | タイプ | アドオン | ファイル数 | 推奨用途 |
|-----------|--------|--------|---------|-----------|---------|
| `minimal` | 初級 | 汎用 | - | 約16 | Claude Code 入門者 |
| `standard` | 初級・中級 | 汎用 | - | 約37 | 一般的なプロジェクト（推奨） |
| `standard-web` | 初級・中級 | 汎用・Web | - | 約42 | Web開発プロジェクト |
| `standard-learning` | 初級・中級 | 汎用 | learning | 約47 | 自己学習・進化を活用したい方 |
| `standard-multi` | 初級・中級 | 汎用 | multi-model | 約44 | マルチAI連携を活用したい方 |
| `full` | 全て | 全て | 全て | 約67 | フル活用したい方 |

### レベル

| レベル | 説明 |
|--------|------|
| `beginner` | 即座に活用可能。設定不要 |
| `intermediate` | 軽微な設定が必要。テストフレームワーク等の前提あり |
| `advanced` | カスタムセットアップが必要。学習システム等 |

### タイプ

| タイプ | 説明 |
|--------|------|
| `general` | どのプロジェクトでも使用可能 |
| `web` | Web開発固有（React, Next.js, E2E, Playwright等） |

### アドオン

上級（advanced）レベルのファイルを機能グループ単位で追加できます。
`--addon` フラグまたは複合プリセットで指定します。

| アドオン | 説明 | 主なファイル |
|---------|------|-------------|
| `learning` | 自己学習・進化 | eval, instinct-*, continuous-learning 等 |
| `multi-model` | マルチAI連携 | orchestrate, multi-* 等 |
| `infra` | 基盤・運用ツール | codemaps, pm2, sessions 等 |

---

## 前提条件

- [基本セットアップ](./01-project-setup-basic.md) が完了していること（推奨）
- 対象プロジェクトに `.claude/` ディレクトリが存在しないこと（または上書きを許可）

---

## 実行方法

### 方法A: プリセットを使用（推奨）

```bash
# 最小構成（入門者向け）
./scripts/deploy-to-project.sh /path/to/project --preset minimal

# 標準構成（推奨）
./scripts/deploy-to-project.sh /path/to/project --preset standard

# 標準構成 + Web開発向け
./scripts/deploy-to-project.sh /path/to/project --preset standard-web

# 標準構成 + 自己学習（複合プリセット）
./scripts/deploy-to-project.sh /path/to/project --preset standard-learning

# 標準構成 + マルチモデル（複合プリセット）
./scripts/deploy-to-project.sh /path/to/project --preset standard-multi

# 標準構成 + アドオン指定
./scripts/deploy-to-project.sh /path/to/project --preset standard --addon learning

# 標準構成 + 複数アドオン
./scripts/deploy-to-project.sh /path/to/project --preset standard --addon learning --addon multi-model

# フル構成
./scripts/deploy-to-project.sh /path/to/project --preset full
```

### 方法B: 対話モード

```bash
./scripts/deploy-to-project.sh /path/to/project -i
```

対話形式でプリセットを選択できます。

### 方法C: カスタム選択

```bash
# レベルとタイプを直接指定
./scripts/deploy-to-project.sh /path/to/project \
  --level beginner,intermediate \
  --type general
```

### オプション

```bash
# ドライラン（実際にはコピーしない）
./scripts/deploy-to-project.sh /path/to/project --preset minimal --dry-run

# 既存ファイルを上書き
./scripts/deploy-to-project.sh /path/to/project --preset standard --force
```

### 方法D: 手動コピー

```bash
# .claude ディレクトリを作成
mkdir -p /path/to/your/project/.claude

# テンプレートをコピー
cp -r template-.claude/* /path/to/your/project/.claude/

# CLAUDE.md を除外（プロジェクト固有のため）
rm /path/to/your/project/.claude/*/CLAUDE.md 2>/dev/null
```

---

## 適用されるテンプレート

詳細な分類は [MANIFEST.md](../template-.claude/MANIFEST.md) を参照してください。

### 初級（beginner）- すぐに使える

| カテゴリ | ファイル | 用途 |
|---------|----------|------|
| Agents | `planner.md` | 実装計画立案 |
| | `code-reviewer.md` | コードレビュー |
| | `refactor-cleaner.md` | リファクタリング |
| Commands | `plan.md` | 計画作成 |
| | `verify.md` | 検証 |
| | `code-review.md` | コードレビュー |
| | `refactor-clean.md` | リファクタリング |
| Rules | `git-workflow.md` | Git運用ルール |
| | `coding-style.md` | コーディングスタイル |
| | `security.md` | セキュリティ |
| Skills | `coding-standards/` | コーディング標準 |
| | `verification-loop/` | 検証ワークフロー |
| | `strategic-compact/` | コンテキスト管理 |
| Contexts | `dev.md`, `research.md`, `review.md` | モード切替 |

### 中級（intermediate）- 設定が必要

| カテゴリ | ファイル | 用途 | タイプ |
|---------|----------|------|--------|
| Agents | `architect.md` | アーキテクチャ設計 | general |
| | `tdd-guide.md` | TDDガイド | general |
| | `security-reviewer.md` | セキュリティレビュー | general |
| | `e2e-runner.md` | E2Eテスト実行 | **web** |
| Commands | `tdd.md`, `build-fix.md` 等 | 各種コマンド | general |
| | `e2e.md` | E2Eテスト | **web** |
| Rules | `testing.md`, `performance.md` 等 | ガイドライン | general |
| | `patterns.md` | 共通パターン | **web** |
| Skills | `tdd-workflow/`, `security-review/` | ワークフロー | general |
| | `frontend-patterns/`, `backend-patterns/` | 開発パターン | **web** |

### 上級（advanced）- アドオンで追加

#### learning（自己学習・進化）

| カテゴリ | ファイル | 用途 |
|---------|----------|------|
| Commands | `eval.md`, `evolve.md`, `learn.md`, `skill-create.md` | 評価・学習・進化 |
| | `instinct-export.md`, `instinct-import.md`, `instinct-status.md` | インスティンクト管理 |
| Skills | `continuous-learning/`, `continuous-learning-v2/` | 継続学習 |
| | `eval-harness/` | 評価ハーネス |

#### multi-model（マルチAI連携）

| カテゴリ | ファイル | 用途 |
|---------|----------|------|
| Commands | `orchestrate.md` | オーケストレーション |
| | `multi-plan.md`, `multi-execute.md` | マルチモデル計画・実行 |
| | `multi-backend.md`, `multi-frontend.md`, `multi-workflow.md` | マルチモデルワークフロー |
| Skills | `iterative-retrieval/` | 反復取得 |

#### infra（基盤・運用ツール）

| カテゴリ | ファイル | 用途 |
|---------|----------|------|
| Commands | `update-codemaps.md` | コードマップ更新 |
| | `setup-pm.md`, `pm2.md` | パッケージ管理・プロセス管理 |
| | `sessions.md` | セッション管理 |
| Skills | `configure-ecc/` | Everything Claude Code設定 |

#### その他（アドオンなし）

| カテゴリ | ファイル | 用途 |
|---------|----------|------|
| Skills | `project-guidelines-example/` | プロジェクトガイドライン例 |
| | `nutrient-document-processing/` | Nutrientドキュメント処理 |

---

## 適用後のカスタマイズ

テンプレートには `<!-- CUSTOMIZE: ... -->` コメントでカスタマイズポイントが示されています。
プロジェクトに合わせて調整してください。

### 例: パッケージマネージャーの変更

```markdown
<!-- CUSTOMIZE: プロジェクトのパッケージマネージャーに合わせて変更 -->
npm run build
```

↓ pnpm を使用する場合

```markdown
pnpm build
```

---

## 推奨ワークフロー

### Step 1: 最小構成で始める

```bash
./scripts/deploy-to-project.sh /path/to/project --preset minimal
```

### Step 2: 慣れてきたら標準構成へ

```bash
./scripts/deploy-to-project.sh /path/to/project --preset standard --force
```

### Step 3: 必要なアドオンを追加

```bash
# 自己学習・進化機能を追加（アドオンのみ）
./scripts/deploy-to-project.sh /path/to/project --addon learning --addon-only

# マルチAI連携を追加（アドオンのみ）
./scripts/deploy-to-project.sh /path/to/project --addon multi-model --addon-only

# 複数アドオンを同時追加
./scripts/deploy-to-project.sh /path/to/project --addon learning --addon multi-model --addon-only
```

### Step 4: Web開発なら Web を追加

```bash
./scripts/deploy-to-project.sh /path/to/project --preset standard-web --force
```

### Step 5: フル活用

```bash
./scripts/deploy-to-project.sh /path/to/project --preset full --force
```

---

## アドオンの追加（既存プロジェクト）

テンプレートが適用済みのプロジェクトにアドオンだけを追加できます。
既存ファイルには影響しません。

### アドオンのみ追加

```bash
# learning アドオンを追加
./scripts/deploy-to-project.sh /path/to/project --addon learning --addon-only

# 複数アドオンを同時追加
./scripts/deploy-to-project.sh /path/to/project --addon learning --addon multi-model --addon-only

# ドライランで確認
./scripts/deploy-to-project.sh /path/to/project --addon learning --addon-only --dry-run
```

### デプロイ状態の確認

```bash
./scripts/deploy-to-project.sh /path/to/project --status
```

### 注意事項

- `--addon-only` は `--addon` と組み合わせて使用します
- 状態ファイル (`.claude/.deploy-state`) が自動作成されデプロイ履歴が記録されます

---

## 次のステップ

テンプレート適用後、プロジェクト固有のスキルを追加できます：

→ [カスタムスキルの作成・追加](./04-custom-skills.md)

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [基本セットアップ](./01-project-setup-basic.md) | CLAUDE.md, .ai の配置 |
| [カスタムスキル](./04-custom-skills.md) | プロジェクト固有スキルの追加 |
| [テンプレート更新](./03-template-maintenance.md) | テンプレートの更新・メンテナンス |
