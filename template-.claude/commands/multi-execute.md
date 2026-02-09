# Execute - マルチモデル協調実行

マルチモデル協調実行 - 計画からプロトタイプを取得 → Claudeがリファクタリング・実装 → マルチモデル監査・納品。

$ARGUMENTS

---

## コアプロトコル

- **言語プロトコル**: ツール/モデルとのやり取りには**英語**を使用し、ユーザーとはユーザーの言語で対話
- **コード主権**: 外部モデルは**ファイルシステムへの書き込みアクセス権なし**、すべての変更はClaudeが実行
- **ダーティプロトタイプのリファクタリング**: Codex/GeminiのUnified Diffを「ダーティプロトタイプ」として扱い、本番品質のコードにリファクタリング必須
- **損切りメカニズム**: 現在のフェーズの出力が検証されるまで次のフェーズに進まない
- **前提条件**: ユーザーが `/ccg:plan` の出力に明示的に「Y」と返信した後にのみ実行（未確認の場合、まず確認が必要）

---

## マルチモデル呼び出し仕様

**呼び出し構文**（並列: `run_in_background: true` を使用）:

```
# セッション再開呼び出し（推奨）- 実装プロトタイプ
Bash({
  command: "~/.claude/bin/codeagent-wrapper {{LITE_MODE_FLAG}}--backend <codex|gemini> {{GEMINI_MODEL_FLAG}}resume <SESSION_ID> - \"$PWD\" <<'EOF'
ROLE_FILE: <role prompt path>
<TASK>
Requirement: <task description>
Context: <plan content + target files>
</TASK>
OUTPUT: Unified Diff Patch ONLY. Strictly prohibit any actual modifications.
EOF",
  run_in_background: true,
  timeout: 3600000,
  description: "Brief description"
})

# 新規セッション呼び出し - 実装プロトタイプ
Bash({
  command: "~/.claude/bin/codeagent-wrapper {{LITE_MODE_FLAG}}--backend <codex|gemini> {{GEMINI_MODEL_FLAG}}- \"$PWD\" <<'EOF'
ROLE_FILE: <role prompt path>
<TASK>
Requirement: <task description>
Context: <plan content + target files>
</TASK>
OUTPUT: Unified Diff Patch ONLY. Strictly prohibit any actual modifications.
EOF",
  run_in_background: true,
  timeout: 3600000,
  description: "Brief description"
})
```

**監査呼び出し構文**（コードレビュー / 監査）:

```
Bash({
  command: "~/.claude/bin/codeagent-wrapper {{LITE_MODE_FLAG}}--backend <codex|gemini> {{GEMINI_MODEL_FLAG}}resume <SESSION_ID> - \"$PWD\" <<'EOF'
ROLE_FILE: <role prompt path>
<TASK>
Scope: Audit the final code changes.
Inputs:
- The applied patch (git diff / final unified diff)
- The touched files (relevant excerpts if needed)
Constraints:
- Do NOT modify any files.
- Do NOT output tool commands that assume filesystem access.
</TASK>
OUTPUT:
1) A prioritized list of issues (severity, file, rationale)
2) Concrete fixes; if code changes are needed, include a Unified Diff Patch in a fenced code block.
EOF",
  run_in_background: true,
  timeout: 3600000,
  description: "Brief description"
})
```

**モデルパラメータ注意事項**:
- `{{GEMINI_MODEL_FLAG}}`: `--backend gemini` 使用時は `--gemini-model gemini-3-pro-preview ` に置換（末尾のスペースに注意）。codexの場合は空文字列

**ロールプロンプト**:

| フェーズ | Codex | Gemini |
|---------|-------|--------|
| 実装 | `~/.claude/.ccg/prompts/codex/architect.md` | `~/.claude/.ccg/prompts/gemini/frontend.md` |
| レビュー | `~/.claude/.ccg/prompts/codex/reviewer.md` | `~/.claude/.ccg/prompts/gemini/reviewer.md` |

**セッション再利用**: `/ccg:plan` が SESSION_ID を提供した場合、`resume <SESSION_ID>` でコンテキストを再利用。

**バックグラウンドタスクの待機**（最大タイムアウト 600000ms = 10分）:

```
TaskOutput({ task_id: "<task_id>", block: true, timeout: 600000 })
```

**重要**:
- `timeout: 600000` を必ず指定すること。指定しないとデフォルトの30秒で早期タイムアウトが発生
- 10分後もまだ完了していない場合、`TaskOutput` でポーリングを続行し、**プロセスを絶対にkillしないこと**
- タイムアウトにより待機がスキップされた場合、**`AskUserQuestion` を必ず呼び出してユーザーに待機を続けるかタスクをkillするか確認すること**

---

## 実行ワークフロー

**実行タスク**: $ARGUMENTS

### フェーズ 0: 計画の読み込み

`[Mode: Prepare]`

1. **入力タイプの識別**:
   - 計画ファイルパス（例: `.claude/plan/xxx.md`）
   - 直接のタスク説明

2. **計画内容の読み込み**:
   - 計画ファイルパスが提供された場合、読み込んでパース
   - 抽出: タスクタイプ、実装ステップ、主要ファイル、SESSION_ID

3. **実行前確認**:
   - 入力が「直接のタスク説明」、または計画に `SESSION_ID` / 主要ファイルが欠けている場合: まずユーザーに確認
   - ユーザーが計画に「Y」と返信したことが確認できない場合: 続行前に再度確認が必要

4. **タスクタイプルーティング**:

   | タスクタイプ | 検出条件 | ルート |
   |------------|---------|--------|
   | **フロントエンド** | ページ、コンポーネント、UI、スタイル、レイアウト | Gemini |
   | **バックエンド** | API、インターフェース、データベース、ロジック、アルゴリズム | Codex |
   | **フルスタック** | フロントエンドとバックエンドの両方を含む | Codex と Gemini の並列 |

---

### フェーズ 1: クイックコンテキスト検索

`[Mode: Retrieval]`

**MCPツールによるクイックコンテキスト検索を必ず使用し、ファイルを手動で一つずつ読み込まないこと**

計画の「主要ファイル」リストに基づき、`mcp__ace-tool__search_context` を呼び出す:

```
mcp__ace-tool__search_context({
  query: "<semantic query based on plan content, including key files, modules, function names>",
  project_root_path: "$PWD"
})
```

**検索戦略**:
- 計画の「主要ファイル」テーブルからターゲットパスを抽出
- エントリファイル、依存モジュール、関連する型定義をカバーするセマンティッククエリを構築
- 結果が不十分な場合、1-2回の再帰的検索を追加
- **Bash + find/ls でプロジェクト構造を手動で探索することは絶対禁止**

**検索後**:
- 取得したコードスニペットを整理
- 実装に必要な完全なコンテキストがあることを確認
- フェーズ3に進む

---

### フェーズ 3: プロトタイプ取得

`[Mode: Prototype]`

**タスクタイプに基づくルーティング**:

#### ルートA: フロントエンド/UI/スタイル → Gemini

**制限**: コンテキスト < 32kトークン

1. Geminiを呼び出し（`~/.claude/.ccg/prompts/gemini/frontend.md` を使用）
2. 入力: 計画内容 + 取得したコンテキスト + 対象ファイル
3. OUTPUT: `Unified Diff Patch ONLY. Strictly prohibit any actual modifications.`
4. **Geminiはフロントエンドデザインの権威であり、そのCSS/React/Vueプロトタイプが最終的な視覚ベースライン**
5. **警告**: Geminiのバックエンドロジック提案は無視すること
6. 計画に `GEMINI_SESSION` が含まれる場合: `resume <GEMINI_SESSION>` を優先

#### ルートB: バックエンド/ロジック/アルゴリズム → Codex

1. Codexを呼び出し（`~/.claude/.ccg/prompts/codex/architect.md` を使用）
2. 入力: 計画内容 + 取得したコンテキスト + 対象ファイル
3. OUTPUT: `Unified Diff Patch ONLY. Strictly prohibit any actual modifications.`
4. **Codexはバックエンドロジックの権威であり、その論理推論とデバッグ能力を活用**
5. 計画に `CODEX_SESSION` が含まれる場合: `resume <CODEX_SESSION>` を優先

#### ルートC: フルスタック → 並列呼び出し

1. **並列呼び出し**（`run_in_background: true`）:
   - Gemini: フロントエンド部分を担当
   - Codex: バックエンド部分を担当
2. `TaskOutput` で両モデルの完全な結果を待機
3. 各モデルは計画の対応する `SESSION_ID` を `resume` に使用（なければ新規セッションを作成）

**上記の `マルチモデル呼び出し仕様` の `重要` 指示に従うこと**

---

### フェーズ 4: コード実装

`[Mode: Implement]`

**Claudeがコード主権者として以下のステップを実行**:

1. **Diff読み取り**: Codex/Geminiが返したUnified Diff Patchをパース

2. **メンタルサンドボックス**:
   - Diffを対象ファイルに適用するシミュレーション
   - 論理的一貫性を確認
   - 潜在的な競合や副作用を特定

3. **リファクタリングとクリーンアップ**:
   - 「ダーティプロトタイプ」を**高可読性、保守性、エンタープライズグレードのコード**にリファクタリング
   - 冗長なコードを削除
   - プロジェクトの既存コード規約への準拠を確保
   - **必要でない限りコメント/ドキュメントを生成しない**、コードは自己説明的であるべき

4. **最小スコープ**:
   - 変更は要件の範囲のみに限定
   - 副作用の**レビュー必須**
   - 的確な修正を実施

5. **変更の適用**:
   - Edit/Writeツールを使用して実際の変更を実行
   - **必要なコードのみを変更**し、ユーザーの他の既存機能に絶対影響を与えない

6. **自己検証**（強く推奨）:
   - プロジェクトの既存のlint / typecheck / テストを実行（関連する最小スコープを優先）
   - 失敗した場合: まずリグレッションを修正してからフェーズ5に進む

---

### フェーズ 5: 監査と納品

`[Mode: Audit]`

#### 5.1 自動監査

**変更が反映された後、直ちにCodexとGeminiを並列呼び出し**してコードレビューを実施:

1. **Codexレビュー**（`run_in_background: true`）:
   - ROLE_FILE: `~/.claude/.ccg/prompts/codex/reviewer.md`
   - 入力: 変更されたDiff + 対象ファイル
   - 焦点: セキュリティ、パフォーマンス、エラーハンドリング、ロジックの正確性

2. **Geminiレビュー**（`run_in_background: true`）:
   - ROLE_FILE: `~/.claude/.ccg/prompts/gemini/reviewer.md`
   - 入力: 変更されたDiff + 対象ファイル
   - 焦点: アクセシビリティ、デザイン一貫性、ユーザー体験

`TaskOutput` で両モデルの完全なレビュー結果を待機。コンテキストの一貫性のためにフェーズ3のセッションの再利用を優先（`resume <SESSION_ID>`）。

#### 5.2 統合と修正

1. Codex + Geminiのレビューフィードバックを統合
2. 信頼ルールに基づく重み付け: バックエンドはCodexに従い、フロントエンドはGeminiに従う
3. 必要な修正を実行
4. 必要に応じてフェーズ5.1を繰り返す（リスクが許容レベルになるまで）

#### 5.3 納品確認

監査通過後、ユーザーに報告:

```markdown
## 実行完了

### 変更サマリー
| ファイル | 操作 | 説明 |
|---------|------|------|
| path/to/file.ts | 変更 | 説明 |

### 監査結果
- Codex: <合格/N件の問題検出>
- Gemini: <合格/N件の問題検出>

### 推奨事項
1. [ ] <推奨テスト手順>
2. [ ] <推奨検証手順>
```

---

## 重要ルール

1. **コード主権** -- すべてのファイル変更はClaudeが実行、外部モデルは書き込みアクセス権なし
2. **ダーティプロトタイプのリファクタリング** -- Codex/Geminiの出力はドラフトとして扱い、リファクタリング必須
3. **信頼ルール** -- バックエンドはCodexに従い、フロントエンドはGeminiに従う
4. **最小限の変更** -- 必要なコードのみを変更し、副作用なし
5. **監査必須** -- 変更後にマルチモデルコードレビューを必ず実施

---

## 使用方法

```bash
# 計画ファイルを実行
/ccg:execute .claude/plan/feature-name.md

# タスクを直接実行（コンテキスト内で既に議論された計画の場合）
/ccg:execute implement user authentication based on previous plan
```

---

## /ccg:plan との関係

1. `/ccg:plan` が計画 + SESSION_ID を生成
2. ユーザーが「Y」で確認
3. `/ccg:execute` が計画を読み込み、SESSION_IDを再利用して実装を実行
