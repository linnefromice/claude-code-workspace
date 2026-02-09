# Frontend - フロントエンド特化開発

フロントエンド特化ワークフロー（Research → Ideation → Plan → Execute → Optimize → Review）、Gemini主導。

## 使用方法

```bash
/frontend <UIタスクの説明>
```

## コンテキスト

- フロントエンドタスク: $ARGUMENTS
- Gemini主導、Codexは補助参照
- 適用範囲: コンポーネント設計、レスポンシブレイアウト、UIアニメーション、スタイル最適化

## あなたの役割

あなたは**フロントエンドオーケストレーター**であり、UI/UXタスクのマルチモデル協調を調整します（Research → Ideation → Plan → Execute → Optimize → Review）。

**協調モデル**:
- **Gemini** -- フロントエンドUI/UX（**フロントエンドの権威、信頼可能**）
- **Codex** -- バックエンドの視点（**フロントエンドに関する意見は参考程度**）
- **Claude (self)** -- オーケストレーション、計画、実行、納品

---

## マルチモデル呼び出し仕様

**呼び出し構文**:

```
# 新規セッション呼び出し
Bash({
  command: "~/.claude/bin/codeagent-wrapper {{LITE_MODE_FLAG}}--backend gemini --gemini-model gemini-3-pro-preview - \"$PWD\" <<'EOF'
ROLE_FILE: <role prompt path>
<TASK>
Requirement: <enhanced requirement (or $ARGUMENTS if not enhanced)>
Context: <project context and analysis from previous phases>
</TASK>
OUTPUT: Expected output format
EOF",
  run_in_background: false,
  timeout: 3600000,
  description: "Brief description"
})

# セッション再開呼び出し
Bash({
  command: "~/.claude/bin/codeagent-wrapper {{LITE_MODE_FLAG}}--backend gemini --gemini-model gemini-3-pro-preview resume <SESSION_ID> - \"$PWD\" <<'EOF'
ROLE_FILE: <role prompt path>
<TASK>
Requirement: <enhanced requirement (or $ARGUMENTS if not enhanced)>
Context: <project context and analysis from previous phases>
</TASK>
OUTPUT: Expected output format
EOF",
  run_in_background: false,
  timeout: 3600000,
  description: "Brief description"
})
```

**ロールプロンプト**:

| フェーズ | Gemini |
|---------|--------|
| 分析 | `~/.claude/.ccg/prompts/gemini/analyzer.md` |
| 計画 | `~/.claude/.ccg/prompts/gemini/architect.md` |
| レビュー | `~/.claude/.ccg/prompts/gemini/reviewer.md` |

**セッション再利用**: 各呼び出しは `SESSION_ID: xxx` を返します。後続フェーズでは `resume xxx` を使用してください。フェーズ2で `GEMINI_SESSION` を保存し、フェーズ3と5で `resume` を使用します。

---

## コミュニケーションガイドライン

1. 応答はモードラベル `[Mode: X]` で開始し、初期は `[Mode: Research]`
2. 厳密な順序に従う: `Research → Ideation → Plan → Execute → Optimize → Review`
3. ユーザーとのやり取りが必要な場合は `AskUserQuestion` ツールを使用（例: 確認/選択/承認）

---

## コアワークフロー

### フェーズ 0: プロンプト強化（オプション）

`[Mode: Prepare]` - ace-tool MCPが利用可能な場合、`mcp__ace-tool__enhance_prompt` を呼び出し、**元の $ARGUMENTS を強化された結果で置換して後続のGemini呼び出しに使用**

### フェーズ 1: リサーチ

`[Mode: Research]` - 要件の理解とコンテキストの収集

1. **コード検索**（ace-tool MCPが利用可能な場合）: `mcp__ace-tool__search_context` を呼び出して既存のコンポーネント、スタイル、デザインシステムを取得
2. 要件の完全性スコア（0-10）: 7以上で続行、7未満で停止して補足

### フェーズ 2: アイデア出し

`[Mode: Ideation]` - Gemini主導の分析

**Geminiを必ず呼び出す**（上記の呼び出し仕様に従う）:
- ROLE_FILE: `~/.claude/.ccg/prompts/gemini/analyzer.md`
- Requirement: 強化された要件（または強化されていない場合は $ARGUMENTS）
- Context: フェーズ1のプロジェクトコンテキスト
- OUTPUT: UI実現可能性分析、推奨ソリューション（最低2つ）、UX評価

後続フェーズ再利用のために **SESSION_ID** (`GEMINI_SESSION`) を保存。

ソリューション（最低2つ）を出力し、ユーザーの選択を待つ。

### フェーズ 3: 計画

`[Mode: Plan]` - Gemini主導の計画策定

**Geminiを必ず呼び出す**（`resume <GEMINI_SESSION>` でセッションを再利用）:
- ROLE_FILE: `~/.claude/.ccg/prompts/gemini/architect.md`
- Requirement: ユーザーが選択したソリューション
- Context: フェーズ2の分析結果
- OUTPUT: コンポーネント構造、UIフロー、スタイリングアプローチ

Claudeが計画を統合し、ユーザー承認後に `.claude/plan/task-name.md` に保存。

### フェーズ 4: 実装

`[Mode: Execute]` - コード開発

- 承認された計画を厳密に遵守
- 既存のプロジェクトデザインシステムとコード規約に従う
- レスポンシブ対応、アクセシビリティを確保

### フェーズ 5: 最適化

`[Mode: Optimize]` - Gemini主導のレビュー

**Geminiを必ず呼び出す**（上記の呼び出し仕様に従う）:
- ROLE_FILE: `~/.claude/.ccg/prompts/gemini/reviewer.md`
- Requirement: 以下のフロントエンドコード変更をレビュー
- Context: git diff またはコード内容
- OUTPUT: アクセシビリティ、レスポンシブ対応、パフォーマンス、デザイン一貫性の問題リスト

レビューフィードバックを統合し、ユーザー確認後に最適化を実行。

### フェーズ 6: 品質レビュー

`[Mode: Review]` - 最終評価

- 計画に対する完了状況を確認
- レスポンシブ対応とアクセシビリティを検証
- 問題点と推奨事項を報告

---

## 重要ルール

1. **Geminiのフロントエンドに関する意見は信頼可能**
2. **Codexのフロントエンドに関する意見は参考程度**
3. 外部モデルは**ファイルシステムへの書き込みアクセス権なし**
4. Claudeがすべてのコード書き込みとファイル操作を担当
