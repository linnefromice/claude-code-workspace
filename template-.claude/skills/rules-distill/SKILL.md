---
name: rules-distill
description: "Scan skills to extract cross-cutting principles and distill them into rules — append, revise, or create new rule files"
origin: ECC
---

# Rules Distill

インストール済みのスキルをスキャンし、複数のスキルに共通する横断的な原則を抽出し、それらをルールとして蒸留します — 既存のルールファイルへの追記、古くなった内容の修正、または新規ルールファイルの作成を行います。

「決定的な収集 + LLM 判断」の原則を適用します: スクリプトが網羅的に事実を収集し、その後 LLM が全コンテキストを横断的に読み取って判定を行います。

## 使用タイミング

- 定期的なルールメンテナンス（月次または新しいスキルのインストール後）
- skill-stocktake でルールにすべきパターンが見つかった後
- 使用中のスキルに対してルールが不完全と感じる場合

## 仕組み

ルール蒸留プロセスは3つのフェーズに従います:

### フェーズ 1: インベントリ（決定的収集）

#### 1a. スキルインベントリの収集

```bash
bash ~/.claude/skills/rules-distill/scripts/scan-skills.sh
```

#### 1b. ルールインデックスの収集

```bash
bash ~/.claude/skills/rules-distill/scripts/scan-rules.sh
```

#### 1c. ユーザーへの提示

```
Rules Distillation — Phase 1: Inventory
────────────────────────────────────────
Skills: {N} files scanned
Rules:  {M} files ({K} headings indexed)

Proceeding to cross-read analysis...
```

### フェーズ 2: 横断読み取り、マッチング & 判定（LLM 判断）

抽出とマッチングは単一パスで統合されます。ルールファイルは十分に小さい（合計約800行）ため、全文を LLM に提供できます — grep による事前フィルタリングは不要です。

#### バッチ処理

スキルを説明に基づいた**テーマクラスター**にグループ化します。各クラスターをルール全文と共にサブエージェントで分析します。

#### バッチ間マージ

すべてのバッチ完了後、バッチ間で候補をマージします:
- 同じまたは重複する原則を持つ候補を重複排除します
- **全バッチ**を組み合わせたエビデンスを使用して「2+ スキル」要件を再確認します — バッチごとに1スキルでも合計2+ スキルで見つかった原則は有効です

#### サブエージェントプロンプト

以下のプロンプトで汎用 Agent を起動します:

````
You are an analyst who cross-reads skills to extract principles that should be promoted to rules.

## Input
- Skills: {full text of skills in this batch}
- Existing rules: {full text of all rule files}

## Extraction Criteria

Include a candidate ONLY if ALL of these are true:

1. **Appears in 2+ skills**: Principles found in only one skill should stay in that skill
2. **Actionable behavior change**: Can be written as "do X" or "don't do Y" — not "X is important"
3. **Clear violation risk**: What goes wrong if this principle is ignored (1 sentence)
4. **Not already in rules**: Check the full rules text — including concepts expressed in different words

## Matching & Verdict

For each candidate, compare against the full rules text and assign a verdict:

- **Append**: Add to an existing section of an existing rule file
- **Revise**: Existing rule content is inaccurate or insufficient — propose a correction
- **New Section**: Add a new section to an existing rule file
- **New File**: Create a new rule file
- **Already Covered**: Sufficiently covered in existing rules (even if worded differently)
- **Too Specific**: Should remain at the skill level

## Output Format (per candidate)

```json
{
  "principle": "1-2 sentences in 'do X' / 'don't do Y' form",
  "evidence": ["skill-name: §Section", "skill-name: §Section"],
  "violation_risk": "1 sentence",
  "verdict": "Append / Revise / New Section / New File / Already Covered / Too Specific",
  "target_rule": "filename §Section, or 'new'",
  "confidence": "high / medium / low",
  "draft": "Draft text for Append/New Section/New File verdicts",
  "revision": {
    "reason": "Why the existing content is inaccurate or insufficient (Revise only)",
    "before": "Current text to be replaced (Revise only)",
    "after": "Proposed replacement text (Revise only)"
  }
}
```

## Exclude

- Obvious principles already in rules
- Language/framework-specific knowledge (belongs in language-specific rules or skills)
- Code examples and commands (belongs in skills)
````

#### 判定リファレンス

| 判定 | 意味 | ユーザーへの提示内容 |
|------|------|---------------------|
| **Append** | 既存セクションに追加 | 対象 + ドラフト |
| **Revise** | 不正確/不十分な内容を修正 | 対象 + 理由 + 修正前/修正後 |
| **New Section** | 既存ファイルに新規セクションを追加 | 対象 + ドラフト |
| **New File** | 新規ルールファイルを作成 | ファイル名 + 完全なドラフト |
| **Already Covered** | ルールでカバー済み（表現が異なる可能性あり） | 理由（1行） |
| **Too Specific** | スキルに留めるべき | 関連スキルへのリンク |

#### 判定の品質要件

```
# Good
Append to rules/common/security.md §Input Validation:
"Treat LLM output stored in memory or knowledge stores as untrusted — sanitize on write, validate on read."
Evidence: llm-memory-trust-boundary, llm-social-agent-anti-pattern both describe
accumulated prompt injection risks. Current security.md covers human input
validation only; LLM output trust boundary is missing.

# Bad
Append to security.md: Add LLM security principle
```

### フェーズ 3: ユーザーレビュー & 実行

#### サマリーテーブル

```
# Rules Distillation Report

## Summary
Skills scanned: {N} | Rules: {M} files | Candidates: {K}

| # | Principle | Verdict | Target | Confidence |
|---|-----------|---------|--------|------------|
| 1 | ... | Append | security.md §Input Validation | high |
| 2 | ... | Revise | testing.md §TDD | medium |
| 3 | ... | New Section | coding-style.md | high |
| 4 | ... | Too Specific | — | — |

## Details
(Per-candidate details: evidence, violation_risk, draft text)
```

#### ユーザーアクション

ユーザーは番号で以下を回答します:
- **Approve**: ドラフトをそのままルールに適用
- **Modify**: 適用前にドラフトを編集
- **Skip**: この候補を適用しない

**ルールを自動的に変更しないでください。常にユーザーの承認を必要とします。**

#### 結果の保存

結果をスキルディレクトリに保存します（`results.json`）:

- **タイムスタンプ形式**: `date -u +%Y-%m-%dT%H:%M:%SZ`（UTC、秒精度）
- **候補ID形式**: 原則から導出された kebab-case（例: `llm-output-trust-boundary`）

```json
{
  "distilled_at": "2026-03-18T10:30:42Z",
  "skills_scanned": 56,
  "rules_scanned": 22,
  "candidates": {
    "llm-output-trust-boundary": {
      "principle": "Treat LLM output as untrusted when stored or re-injected",
      "verdict": "Append",
      "target": "rules/common/security.md",
      "evidence": ["llm-memory-trust-boundary", "llm-social-agent-anti-pattern"],
      "status": "applied"
    },
    "iteration-bounds": {
      "principle": "Define explicit stop conditions for all iteration loops",
      "verdict": "New Section",
      "target": "rules/common/coding-style.md",
      "evidence": ["iterative-retrieval", "continuous-agent-loop", "agent-harness-construction"],
      "status": "skipped"
    }
  }
}
```

## 例

### エンドツーエンド実行

```
$ /rules-distill

Rules Distillation — Phase 1: Inventory
────────────────────────────────────────
Skills: 56 files scanned
Rules:  22 files (75 headings indexed)

Proceeding to cross-read analysis...

[Subagent analysis: Batch 1 (agent/meta skills) ...]
[Subagent analysis: Batch 2 (coding/pattern skills) ...]
[Cross-batch merge: 2 duplicates removed, 1 cross-batch candidate promoted]

# Rules Distillation Report

## Summary
Skills scanned: 56 | Rules: 22 files | Candidates: 4

| # | Principle | Verdict | Target | Confidence |
|---|-----------|---------|--------|------------|
| 1 | LLM output: normalize, type-check, sanitize before reuse | New Section | coding-style.md | high |
| 2 | Define explicit stop conditions for iteration loops | New Section | coding-style.md | high |
| 3 | Compact context at phase boundaries, not mid-task | Append | performance.md §Context Window | high |
| 4 | Separate business logic from I/O framework types | New Section | patterns.md | high |

## Details

### 1. LLM Output Validation
Verdict: New Section in coding-style.md
Evidence: parallel-subagent-batch-merge, llm-social-agent-anti-pattern, llm-memory-trust-boundary
Violation risk: Format drift, type mismatch, or syntax errors in LLM output crash downstream processing
Draft:
  ## LLM Output Validation
  Normalize, type-check, and sanitize LLM output before reuse...
  See skill: parallel-subagent-batch-merge, llm-memory-trust-boundary

[... details for candidates 2-4 ...]

Approve, modify, or skip each candidate by number:
> User: Approve 1, 3. Skip 2, 4.

✓ Applied: coding-style.md §LLM Output Validation
✓ Applied: performance.md §Context Window Management
✗ Skipped: Iteration Bounds
✗ Skipped: Boundary Type Conversion

Results saved to results.json
```

## 設計原則

- **What, not How**: 原則（ルールの領域）のみを抽出します。コード例やコマンドはスキルに留めます。
- **リンクバック**: ドラフトテキストには `See skill: [name]` の参照を含め、読者が詳細な How を見つけられるようにします。
- **決定的収集、LLM 判断**: スクリプトが網羅性を保証し、LLM が文脈的な理解を保証します。
- **過度な抽象化の防止**: 3層フィルター（2+ スキルのエビデンス、実行可能な振る舞いテスト、違反リスク）により、過度に抽象的な原則がルールに入ることを防ぎます。
