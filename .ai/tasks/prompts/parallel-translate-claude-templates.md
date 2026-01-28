# 並列翻訳プロンプト - Claude Codeテンプレート

## 概要

`affaan-m/everything-claude-code`リポジトリからClaude Code設定ファイルを**並列**で日本語に翻訳する。
5つのエージェントがカテゴリ別に同時実行し、翻訳時間を大幅に短縮する。

## 前提条件

- ソースファイル: `.work/source/` に配置済み
- 出力先: `.work/translated/`
- 翻訳ルール: 下記参照

## 翻訳ルール（全エージェント共通）

1. **Frontmatter（YAMLヘッダー）**
   - `name`, `description`, `tools`, `model` などのフィールドは**英語のまま**維持
   - 技術的な互換性を保つため

2. **本文コンテンツ**
   - Markdown本文は**日本語に翻訳**
   - コード例はそのまま（コメントは日本語化可）
   - 技術用語（API, JWT, TDD等）は適宜英語のまま

3. **ファイル命名**
   - `{original-name}.ja.md` 形式で保存
   - 例: `planner.md` → `planner.ja.md`

## 実行方法

以下の5つのTaskを**並列**で実行してください：

### Agent 1: Contexts翻訳
```
Task(subagent_type="general-purpose", prompt="""
.work/source/contexts/ 内のすべてのファイルを日本語に翻訳してください。

翻訳ルール:
- Frontmatter（name, descriptionなど）は英語のまま
- 本文は日本語に翻訳
- 出力先: .work/translated/contexts/
- ファイル名: {original}.ja.md

各ファイルを読み込み、翻訳し、書き出してください。
""")
```

### Agent 2: Rules翻訳
```
Task(subagent_type="general-purpose", prompt="""
.work/source/rules/ 内のすべてのファイルを日本語に翻訳してください。

翻訳ルール:
- Frontmatter（name, descriptionなど）は英語のまま
- 本文は日本語に翻訳
- 出力先: .work/translated/rules/
- ファイル名: {original}.ja.md

各ファイルを読み込み、翻訳し、書き出してください。
""")
```

### Agent 3: Agents翻訳
```
Task(subagent_type="general-purpose", prompt="""
.work/source/agents/ 内のすべてのファイルを日本語に翻訳してください。

翻訳ルール:
- Frontmatter（name, description, tools, modelなど）は英語のまま
- 本文は日本語に翻訳
- 出力先: .work/translated/agents/
- ファイル名: {original}.ja.md

各ファイルを読み込み、翻訳し、書き出してください。
""")
```

### Agent 4: Commands翻訳
```
Task(subagent_type="general-purpose", prompt="""
.work/source/commands/ 内のすべてのファイルを日本語に翻訳してください。

翻訳ルール:
- Frontmatter（name, description, commandなど）は英語のまま
- 本文は日本語に翻訳
- 出力先: .work/translated/commands/
- ファイル名: {original}.ja.md

各ファイルを読み込み、翻訳し、書き出してください。
""")
```

### Agent 5: Skills翻訳
```
Task(subagent_type="general-purpose", prompt="""
.work/source/skills/ 内のすべてのSKILL.mdファイルを日本語に翻訳してください。

翻訳ルール:
- Frontmatter（name, description, toolsなど）は英語のまま
- 本文は日本語に翻訳
- 出力先: .work/translated/skills/{skill-name}/
- ファイル名: SKILL.ja.md

各サブディレクトリのSKILL.mdを読み込み、翻訳し、書き出してください。
""")
```

## 期待される効果

- **逐次実行**: 約30-40分
- **並列実行**: 約8-12分（約3-4倍高速化）

## 完了確認

すべてのエージェントが完了したら、以下で翻訳結果を確認:

```bash
# 各カテゴリのファイル数を確認
find .work/translated -name "*.ja.md" | wc -l

# カテゴリ別
ls .work/translated/contexts/*.ja.md | wc -l   # 期待: 3
ls .work/translated/rules/*.ja.md | wc -l      # 期待: 8
ls .work/translated/agents/*.ja.md | wc -l     # 期待: 12
ls .work/translated/commands/*.ja.md | wc -l   # 期待: 23
find .work/translated/skills -name "SKILL.ja.md" | wc -l  # 期待: 16
```

## 使用例

```
do @.ai/tasks/prompts/parallel-translate-claude-templates.md
```

実行時、Claudeは上記5つのTaskを並列で起動し、翻訳を同時進行する。
