---
description: "Use when auditing Claude skills and commands for quality. Supports Quick Scan (changed skills only) and Full Stocktake modes with sequential subagent batch evaluation."
origin: ECC
---

# skill-stocktake

品質チェックリスト＋AI の総合判断を使用して、すべての Claude スキルとコマンドを監査するスラッシュコマンド（`/skill-stocktake`）です。2つのモードをサポートします: 最近変更されたスキルのみの Quick Scan と、完全レビューの Full Stocktake です。

## スコープ

このコマンドは **実行ディレクトリを基準** として以下のパスを対象とします:

| パス | 説明 |
|------|-------------|
| `~/.claude/skills/` | グローバルスキル（全プロジェクト共通） |
| `{cwd}/.claude/skills/` | プロジェクトレベルのスキル（ディレクトリが存在する場合） |

**Phase 1 の開始時に、コマンドは検出・スキャンされたパスを明示的にリストします。**

### 特定プロジェクトを対象にする

プロジェクトレベルのスキルを含めるには、そのプロジェクトのルートディレクトリから実行してください:

```bash
cd ~/path/to/my-project
/skill-stocktake
```

プロジェクトに `.claude/skills/` ディレクトリがない場合は、グローバルスキルとコマンドのみが評価されます。

## Modes

| モード | トリガー | 所要時間 |
|------|---------|---------|
| Quick Scan | `results.json` が存在する場合（デフォルト） | 5-10分 |
| Full Stocktake | `results.json` が存在しない場合、または `/skill-stocktake full` | 20-30分 |

**結果キャッシュ:** `~/.claude/skills/skill-stocktake/results.json`

## Quick Scan Flow

前回の実行以降に変更されたスキルのみを再評価します（5-10分）。

1. `~/.claude/skills/skill-stocktake/results.json` を読み込む
2. 実行: `bash ~/.claude/skills/skill-stocktake/scripts/quick-diff.sh \
         ~/.claude/skills/skill-stocktake/results.json`
   （プロジェクトディレクトリは `$PWD/.claude/skills` から自動検出されます。必要な場合のみ明示的に指定してください）
3. 出力が `[]` の場合: 「前回の実行以降、変更はありません。」と報告して終了
4. 変更されたファイルのみを同じ Phase 2 基準で再評価
5. 変更のないスキルは前回の結果を引き継ぐ
6. 差分のみ出力
7. 実行: `bash ~/.claude/skills/skill-stocktake/scripts/save-results.sh \
         ~/.claude/skills/skill-stocktake/results.json <<< "$EVAL_RESULTS"`

## Full Stocktake Flow

### Phase 1 — インベントリ

実行: `bash ~/.claude/skills/skill-stocktake/scripts/scan.sh`

このスクリプトはスキルファイルを列挙し、frontmatter を抽出し、UTC の mtime を収集します。
プロジェクトディレクトリは `$PWD/.claude/skills` から自動検出されます。必要な場合のみ明示的に指定してください。
スクリプト出力からスキャンサマリーとインベントリテーブルを表示します:

```
Scanning:
  ✓ ~/.claude/skills/         (17 files)
  ✗ {cwd}/.claude/skills/    (not found — global skills only)
```

| Skill | 7d use | 30d use | Description |
|-------|--------|---------|-------------|

### Phase 2 — 品質評価

Agent ツールのサブエージェント（**汎用エージェント**）に完全なインベントリとチェックリストを渡して起動します:

```text
Agent(
  subagent_type="general-purpose",
  prompt="
以下のスキルインベントリをチェックリストに対して評価してください。

[INVENTORY]

[CHECKLIST]

各スキルについて JSON を返してください:
{ \"verdict\": \"Keep\"|\"Improve\"|\"Update\"|\"Retire\"|\"Merge into [X]\", \"reason\": \"...\" }
"
)
```

サブエージェントは各スキルを読み取り、チェックリストを適用し、スキルごとの JSON を返します:

`{ "verdict": "Keep"|"Improve"|"Update"|"Retire"|"Merge into [X]", "reason": "..." }`

**チャンクガイダンス:** コンテキストを管理しやすくするため、サブエージェント呼び出しごとに約20スキルを処理してください。各チャンクの後に中間結果を `results.json`（`status: "in_progress"`）に保存してください。

すべてのスキルの評価完了後: `status: "completed"` に設定し、Phase 3 に進みます。

**レジューム検出:** 起動時に `status: "in_progress"` が見つかった場合、最初の未評価スキルから再開します。

各スキルは以下のチェックリストに対して評価されます:

```
- [ ] 他のスキルとのコンテンツ重複をチェック
- [ ] MEMORY.md / CLAUDE.md との重複をチェック
- [ ] 技術的な参照の鮮度を検証（ツール名 / CLI フラグ / API が存在する場合は WebSearch を使用）
- [ ] 使用頻度を考慮
```

判定基準:

| 判定 | 意味 |
|---------|---------|
| Keep | 有用かつ最新 |
| Improve | 保持する価値はあるが、特定の改善が必要 |
| Update | 参照されている技術が古い（WebSearch で検証） |
| Retire | 品質が低い、古い、またはコスト非対称 |
| Merge into [X] | 別のスキルと大幅に重複している。マージ先を指定 |

評価は **AI の総合判断** であり、数値ルーブリックではありません。ガイドとなる指標:
- **実行可能性**: すぐに行動できるコード例、コマンド、またはステップがあるか
- **スコープの適合性**: 名前、トリガー、コンテンツが整合しており、広すぎず狭すぎないか
- **独自性**: MEMORY.md / CLAUDE.md / 他のスキルでは代替できない価値があるか
- **鮮度**: 技術的な参照が現在の環境で動作するか

**理由の品質要件** — `reason` フィールドは自己完結的で意思決定を可能にするものでなければなりません:
- 「変更なし」だけでは不可 — 常に根拠となる証拠を再記述してください
- **Retire** の場合: (1) 具体的にどのような問題が見つかったか、(2) 同じニーズをカバーする代替は何かを記述
  - 悪い例: `"Superseded"`
  - 良い例: `"disable-model-invocation: true already set; superseded by continuous-learning-v2 which covers all the same patterns plus confidence scoring. No unique content remains."`
- **Merge** の場合: 対象を指定し、どのコンテンツを統合するか説明
  - 悪い例: `"Overlaps with X"`
  - 良い例: `"42-line thin content; Step 4 of chatlog-to-article already covers the same workflow. Integrate the 'article angle' tip as a note in that skill."`
- **Improve** の場合: 必要な具体的変更を説明（どのセクション、どのアクション、関連する場合は目標サイズ）
  - 悪い例: `"Too long"`
  - 良い例: `"276 lines; Section 'Framework Comparison' (L80–140) duplicates ai-era-architecture-principles; delete it to reach ~150 lines."`
- **Keep**（Quick Scan で mtime のみ変更の場合）: 元の判定根拠を再記述し、「変更なし」とは書かない
  - 悪い例: `"Unchanged"`
  - 良い例: `"mtime updated but content unchanged. Unique Python reference explicitly imported by rules/python/; no overlap found."`

### Phase 3 — サマリーテーブル

| Skill | 7d use | Verdict | Reason |
|-------|--------|---------|--------|

### Phase 4 — 統合

1. **Retire / Merge**: ユーザーに確認する前に、ファイルごとに詳細な根拠を提示:
   - 具体的にどのような問題が見つかったか（重複、古さ、壊れた参照など）
   - 同じ機能をカバーする代替（Retire の場合: 既存のどのスキル/ルール。Merge の場合: 対象ファイルと統合するコンテンツ）
   - 削除の影響（依存するスキル、MEMORY.md の参照、影響を受けるワークフロー）
2. **Improve**: 根拠付きの具体的な改善提案を提示:
   - 何を変更するか、なぜか（例: 「セクション X/Y が python-patterns と重複しているため、430→200行にトリム」）
   - 実行するかどうかはユーザーが判断
3. **Update**: ソースを確認した上で更新済みコンテンツを提示
4. MEMORY.md の行数をチェックし、100行を超える場合は圧縮を提案

## Results File Schema

`~/.claude/skills/skill-stocktake/results.json`:

**`evaluated_at`**: 実際の評価完了時の UTC 時間を設定する必要があります。
Bash 経由で取得: `date -u +%Y-%m-%dT%H:%M:%SZ`。`T00:00:00Z` のような日付のみの近似値は使用しないでください。

```json
{
  "evaluated_at": "2026-02-21T10:00:00Z",
  "mode": "full",
  "batch_progress": {
    "total": 80,
    "evaluated": 80,
    "status": "completed"
  },
  "skills": {
    "skill-name": {
      "path": "~/.claude/skills/skill-name/SKILL.md",
      "verdict": "Keep",
      "reason": "Concrete, actionable, unique value for X workflow",
      "mtime": "2026-01-15T08:30:00Z"
    }
  }
}
```

## Notes

- 評価はブラインドです: 同じチェックリストがオリジン（ECC、自作、自動抽出）に関係なくすべてのスキルに適用されます
- アーカイブ/削除操作には常にユーザーの明示的な確認が必要です
- スキルのオリジンによる判定の分岐はありません
