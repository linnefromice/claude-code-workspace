# Claude Code 初期構成設計

## 概要

`setup-claude-code-config` として提供する Claude Code の初期設定構成の方針。
参考: [dipsy-portal-web PR #42](https://github.com/dev-bloom-so/dipsy-portal-web/pull/42)

---

## ディレクトリ構成

```
.claude/
├── agents/           # カスタムエージェント定義
│   └── *.md
├── rules/            # 自動適用ルール
│   └── *.md
├── skills/           # 呼び出し可能スキル
│   └── */SKILL.md
├── contexts/         # 起動モード切り替え用コンテキスト
│   └── *.md
└── settings.local.template.json  # フック設定テンプレート
```

---

## 1. Agents（エージェント）

カスタムエージェントは `Task` ツールで呼び出される専門家。プロジェクト固有のコンテキストを持つ。

### 初期作成リスト

| 優先度 | エージェント名 | 専門領域 | model | 使用タイミング |
|--------|----------------|----------|-------|----------------|
| 高 | `planner` | 実装計画 | opus | 複雑な機能実装、リファクタリング計画 |
| 高 | `code-reviewer` | コードレビュー | opus | 実装完了後、PR作成前 |
| 中 | `documentation-maintainer` | ドキュメント整合性 | opus | ファイル構成変更後、新パターン確立後 |
| 中 | `refactor-cleaner` | デッドコードクリーンアップ | opus | 未使用コード削除、重複排除 |

### エージェント定義のフォーマット

```yaml
---
name: agent-name
description: "日本語で簡潔な説明。使用タイミングを含める。"
tools: Read, Write, Edit, Bash, Grep, Glob
model: opus  # 必要に応じて
---

# Agent Name

概要説明（1-2文）

---

## 専門領域

- 項目1
- 項目2

---

## 参照すべきドキュメント

| ドキュメント | パス |
|--------------|------|
| 名前 | `path/to/doc.md` |

---

## ワークフロー / チェックリスト

...

---

## 連携エージェント

- **agent-name**: 役割
```

---

## 2. Rules（ルール）

ルールは自動的に適用される指針。ファイル操作やワークフローの標準化に使用。

### 初期作成リスト

| 優先度 | ルール名 | 目的 | 適用場面 |
|--------|----------|------|----------|
| 高 | `agent` | エージェントオーケストレーション | 複雑なタスク実行時 |
| 高 | `git-workflow` | Gitワークフロー標準化 | コミット、PR作成時 |
| 中 | `development-performance` | モデル選択・コンテキスト管理 | 開発中常時 |

### 各ルールの概要

#### agent.md
- 利用可能エージェント一覧
- 自動的にエージェントを使用すべきタイミング
- 並列タスク実行のパターン
- エージェント連携フロー（新機能実装、バグ修正、リファクタリング）

#### git-workflow.md
- コミットメッセージ形式（Conventional Commits）
- PRワークフロー（log確認 → diff確認 → summary作成 → push）
- ブランチ命名規則（feature/, fix/, refactor/, topic/）
- 禁止事項（force push, main直接push等）

#### development-performance.md
- モデル選択戦略（Haiku / Sonnet / Opus の使い分け）
- コンテキスト残量に応じたタスク選択
- ビルドトラブルシューティング手順

---

## 3. Skills（スキル）

スキルは `/skill-name` で呼び出せるコマンド。

### 初期作成リスト

| 優先度 | スキル名 | 目的 | 呼び出し方法 |
|--------|----------|------|--------------|
| 中 | `adapt-external-docs` | 外部ドキュメントをプロジェクト形式に適合 | `/adapt-external-docs @file type=agent` |
| 低 | `merge-reference-docs` | 参考ドキュメントのマージ | `/merge-reference-docs @target @ref type=agent` |

### スキル定義のフォーマット

```yaml
---
name: skill-name
description: "日本語で簡潔な説明"
invocable: true  # スキルとして呼び出し可能
---

# スキル名

概要説明

---

## 使用タイミング

- 条件1
- 条件2

---

## 呼び出し方法

```
/skill-name @{file} param=value
```

---

## 実行手順

1. ステップ1
2. ステップ2

---

## チェックリスト

- [ ] 確認項目
```

---

## 4. Contexts（コンテキスト）

起動時のモード切り替え用。`--system-prompt` フラグで動的にロード。

### 初期作成リスト

| コンテキスト | モード | フォーカス |
|--------------|--------|------------|
| `dev.md` | 開発モード | 実装・コーディング・機能構築 |
| `research.md` | リサーチモード | 探索・調査・学習 |
| `review.md` | レビューモード | PRレビュー・コード分析 |

### コンテキストの構成要素

```markdown
# コンテキスト名

モード: XXX
フォーカス: YYY

## 振る舞い

- 行動指針1
- 行動指針2

## 優先順位 / プロセス

1. ステップ1
2. ステップ2

## 優先するツール

- Tool1 - 用途
- Tool2 - 用途
```

### シェルエイリアス（推奨設定）

```bash
# ~/.zshrc or ~/.bashrc
alias claude-dev='claude --system-prompt "$(cat .claude/contexts/dev.md)"'
alias claude-review='claude --system-prompt "$(cat .claude/contexts/review.md)"'
alias claude-research='claude --system-prompt "$(cat .claude/contexts/research.md)"'
```

---

## 5. Settings（フック設定）

`settings.local.template.json` として提供し、ユーザーがコピーして使用。

### 推奨フック

| タイミング | 目的 | 内容 |
|------------|------|------|
| PreToolUse | ファイル制限 | 不適切な場所への.md作成をブロック |
| PostToolUse | 自動フォーマット | JS/TS編集後にPrettier実行 |
| PostToolUse | 型チェック | .ts/.tsx編集後にtsc実行 |
| PostToolUse | console.log警告 | console.logの残存を警告 |
| PostToolUse | PR情報表示 | PR作成後にURLとレビューコマンド表示 |

---

## 実装優先順位

### Phase 1: 基盤（必須）

1. **Rules**
   - `git-workflow.md` - Gitワークフロー標準化
   - `agent.md` - エージェントオーケストレーション

2. **Contexts**
   - `dev.md` - 開発モード
   - `review.md` - レビューモード

3. **Settings**
   - `settings.local.template.json` - 基本フック

### Phase 2: エージェント

1. `planner.md` - 実装計画
2. `code-reviewer.md` - コードレビュー

### Phase 3: 拡張

1. `documentation-maintainer.md` - ドキュメント整合性
2. `refactor-cleaner.md` - クリーンアップ
3. `research.md` - リサーチモード
4. `development-performance.md` - パフォーマンス最適化

### Phase 4: スキル

1. `adapt-external-docs/SKILL.md`
2. `merge-reference-docs/SKILL.md`

---

## プロジェクト非依存化のポイント

PRはdipsy-portal-web固有の設定を含んでいるため、汎用テンプレート化する際は以下を除去/抽象化:

| 固有要素 | 対応 |
|----------|------|
| `@dipsy/ui`, `@dipsy/api` 等 | プレースホルダーに置換 |
| `docs/specs/SPONSOR.md` 等 | 「プロジェクト仕様書」として抽象化 |
| `apps/admin/`, `apps/sponsor/` | 「アプリケーション」として抽象化 |
| pnpm コマンド | npm/yarn/pnpm 対応の注記追加 |
| Next.js 16, React 19 固有 | フレームワーク非依存に |

---

## 次のアクション

1. [ ] `setup-claude-code-config/` ディレクトリ作成
2. [ ] Phase 1 のファイル作成
3. [ ] セットアップスクリプト作成
4. [ ] README.md 作成
