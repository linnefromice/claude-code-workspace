# Plan - マルチモデル協調計画

マルチモデル協調計画 - コンテキスト検索 + デュアルモデル分析 → ステップバイステップ実装計画の生成。

$ARGUMENTS

---

## コアプロトコル

- **言語プロトコル**: ツール/モデルとのやり取りには**英語**を使用し、ユーザーとはユーザーの言語で対話
- **必須並列処理**: Codex/Geminiの呼び出しは**必ず** `run_in_background: true` を使用（単一モデルの呼び出しでも、メインスレッドのブロッキングを回避するため）
- **コード主権**: 外部モデルは**ファイルシステムへの書き込みアクセス権なし**、すべての変更はClaudeが実行
- **損切りメカニズム**: 現在のフェーズの出力が検証されるまで次のフェーズに進まない
- **計画のみ**: このコマンドはコンテキストの読み込みと `.claude/plan/*` 計画ファイルへの書き込みを許可するが、**本番コードは絶対に変更しない**

---

## マルチモデル呼び出し仕様

**呼び出し構文**（並列: `run_in_background: true` を使用）:

```
Bash({
  command: "~/.claude/bin/codeagent-wrapper {{LITE_MODE_FLAG}}--backend <codex|gemini> {{GEMINI_MODEL_FLAG}}- \"$PWD\" <<'EOF'
ROLE_FILE: <role prompt path>
<TASK>
Requirement: <enhanced requirement>
Context: <retrieved project context>
</TASK>
OUTPUT: Step-by-step implementation plan with pseudo-code. DO NOT modify any files.
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
| 分析 | `~/.claude/.ccg/prompts/codex/analyzer.md` | `~/.claude/.ccg/prompts/gemini/analyzer.md` |
| 計画 | `~/.claude/.ccg/prompts/codex/architect.md` | `~/.claude/.ccg/prompts/gemini/architect.md` |

**セッション再利用**: 各呼び出しは `SESSION_ID: xxx` を返し（通常ラッパーが出力）、後続の `/ccg:execute` 使用のために**必ず保存**すること。

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

**計画タスク**: $ARGUMENTS

### フェーズ 1: 完全なコンテキスト検索

`[Mode: Research]`

#### 1.1 プロンプト強化（最初に必ず実行）

**`mcp__ace-tool__enhance_prompt` ツールを必ず呼び出す**:

```
mcp__ace-tool__enhance_prompt({
  prompt: "$ARGUMENTS",
  conversation_history: "<last 5-10 conversation turns>",
  project_root_path: "$PWD"
})
```

強化されたプロンプトを待ち、**元の $ARGUMENTS を強化された結果で置換**して後続のすべてのフェーズで使用。

#### 1.2 コンテキスト検索

**`mcp__ace-tool__search_context` ツールを呼び出す**:

```
mcp__ace-tool__search_context({
  query: "<semantic query based on enhanced requirement>",
  project_root_path: "$PWD"
})
```

- 自然言語（Where/What/How）を使用してセマンティッククエリを構築
- **推測に基づく回答は絶対禁止**
- MCPが利用不可の場合: Glob + Grep にフォールバックしてファイル探索と重要シンボルの特定を実施

#### 1.3 完全性チェック

- 関連するクラス、関数、変数の**完全な定義とシグネチャ**を必ず取得
- コンテキストが不十分な場合、**再帰的検索**をトリガー
- 出力を優先: エントリファイル + 行番号 + 重要シンボル名。曖昧さを解消するために必要な場合のみ最小限のコードスニペットを追加

#### 1.4 要件の整合性確認

- 要件にまだ曖昧さがある場合、ユーザーに対するガイド質問を**必ず**出力
- 要件の境界が明確になるまで（漏れなし、冗長なし）

### フェーズ 2: マルチモデル協調分析

`[Mode: Analysis]`

#### 2.1 入力の配布

Codex と Gemini を**並列呼び出し**（`run_in_background: true`）:

**元の要件**（プリセットの意見なし）を両モデルに配布:

1. **Codexバックエンド分析**:
   - ROLE_FILE: `~/.claude/.ccg/prompts/codex/analyzer.md`
   - 焦点: 技術的実現可能性、アーキテクチャへの影響、パフォーマンスの考慮事項、潜在的リスク
   - OUTPUT: 多角的ソリューション + 長所/短所分析

2. **Geminiフロントエンド分析**:
   - ROLE_FILE: `~/.claude/.ccg/prompts/gemini/analyzer.md`
   - 焦点: UI/UXへの影響、ユーザー体験、ビジュアルデザイン
   - OUTPUT: 多角的ソリューション + 長所/短所分析

`TaskOutput` で両モデルの完全な結果を待機。**SESSION_ID** (`CODEX_SESSION` と `GEMINI_SESSION`) を保存。

#### 2.2 クロスバリデーション

視点を統合し、最適化のためにイテレーション:

1. **合意点の特定**（強いシグナル）
2. **相違点の特定**（重み付けが必要）
3. **補完的な強み**: バックエンドロジックはCodexに従い、フロントエンドデザインはGeminiに従う
4. **論理的推論**: ソリューションの論理的ギャップを排除

#### 2.3（オプションだが推奨）デュアルモデル計画ドラフト

Claudeの統合計画における漏れのリスクを軽減するため、両モデルに並列で「計画ドラフト」を出力させることが可能（ファイルの変更は**引き続き禁止**）:

1. **Codex計画ドラフト**（バックエンドの権威）:
   - ROLE_FILE: `~/.claude/.ccg/prompts/codex/architect.md`
   - OUTPUT: ステップバイステップ計画 + 擬似コード（焦点: データフロー/エッジケース/エラーハンドリング/テスト戦略）

2. **Gemini計画ドラフト**（フロントエンドの権威）:
   - ROLE_FILE: `~/.claude/.ccg/prompts/gemini/architect.md`
   - OUTPUT: ステップバイステップ計画 + 擬似コード（焦点: 情報アーキテクチャ/インタラクション/アクセシビリティ/視覚的一貫性）

`TaskOutput` で両モデルの完全な結果を待機し、両者の提案における主要な相違点を記録。

#### 2.4 実装計画の生成（Claude最終版）

両方の分析を統合し、**ステップバイステップ実装計画**を生成:

```markdown
## Implementation Plan: <Task Name>

### Task Type
- [ ] Frontend (→ Gemini)
- [ ] Backend (→ Codex)
- [ ] Fullstack (→ Parallel)

### Technical Solution
<Optimal solution synthesized from Codex + Gemini analysis>

### Implementation Steps
1. <Step 1> - Expected deliverable
2. <Step 2> - Expected deliverable
...

### Key Files
| File | Operation | Description |
|------|-----------|-------------|
| path/to/file.ts:L10-L50 | Modify | Description |

### Risks and Mitigation
| Risk | Mitigation |
|------|------------|

### SESSION_ID (for /ccg:execute use)
- CODEX_SESSION: <session_id>
- GEMINI_SESSION: <session_id>
```

### フェーズ 2 終了: 計画の提示（実行ではない）

**`/ccg:plan` の責務はここで終了、以下のアクションを必ず実行**:

1. 完全な実装計画をユーザーに提示（擬似コード含む）
2. 計画を `.claude/plan/<feature-name>.md` に保存（要件からフィーチャー名を抽出、例: `user-auth`, `payment-module`）
3. **太字テキスト**でプロンプトを出力（実際の保存先ファイルパスを必ず使用）:

   ---
   **計画を生成し `.claude/plan/actual-feature-name.md` に保存しました**

   **上記の計画をレビューしてください。以下の操作が可能です:**
   - **計画の修正**: 調整が必要な箇所をお伝えください。計画を更新します
   - **計画の実行**: 以下のコマンドを新しいセッションにコピーしてください

   ```
   /ccg:execute .claude/plan/actual-feature-name.md
   ```
   ---

   **注意**: 上記の `actual-feature-name.md` は実際に保存されたファイル名に必ず置換すること！

4. **現在の応答を直ちに終了**（ここで停止。これ以上のツール呼び出しは禁止。）

**絶対禁止事項**:
- ユーザーに「Y/N」を聞いてから自動実行（実行は `/ccg:execute` の責務）
- 本番コードへのいかなる書き込み操作
- `/ccg:execute` や実装アクションの自動呼び出し
- ユーザーが明示的に修正を要求していないのにモデル呼び出しを続けること

---

## 計画の保存

計画策定完了後、計画を以下に保存:

- **初回計画**: `.claude/plan/<feature-name>.md`
- **イテレーション版**: `.claude/plan/<feature-name>-v2.md`, `.claude/plan/<feature-name>-v3.md`...

計画ファイルの書き込みは、ユーザーへの計画提示前に完了すること。

---

## 計画修正フロー

ユーザーが計画の修正を要求した場合:

1. ユーザーのフィードバックに基づいて計画内容を調整
2. `.claude/plan/<feature-name>.md` ファイルを更新
3. 修正された計画を再提示
4. ユーザーにレビューまたは実行を再度促す

---

## 次のステップ

ユーザー承認後、**手動で**実行:

```bash
/ccg:execute .claude/plan/<feature-name>.md
```

---

## 重要ルール

1. **計画のみ、実装なし** -- このコマンドはいかなるコード変更も実行しない
2. **Y/Nプロンプトなし** -- 計画を提示するのみ、次のステップはユーザーに委ねる
3. **信頼ルール** -- バックエンドはCodexに従い、フロントエンドはGeminiに従う
4. 外部モデルは**ファイルシステムへの書き込みアクセス権なし**
5. **SESSION_IDの引き継ぎ** -- 計画の末尾に `CODEX_SESSION` / `GEMINI_SESSION` を必ず含める（`/ccg:execute resume <SESSION_ID>` 使用のため）
