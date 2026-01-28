# Translate Documentation to Japanese

## Objective
Translate all English documentation files to Japanese within the specified scope.

## Scope
Target the following files and directories:
- `README.md` (root level)
- `/agents/*.md` (excluding CLAUDE.md)
- `/commands/*.md` (excluding CLAUDE.md)
- `/rules/*.md` (excluding CLAUDE.md)
- `/skills/<name>/SKILL.md` (translate subdirectory SKILL.md files)

## Naming Convention

### Standard files
- English source: `filename.md`
- Japanese translation: `filename.ja.md`

### Skills directory (special pattern)
- English source: `skills/<name>/SKILL.md`
- Japanese translation: `skills/<name>.ja.md` (output to skills root level)

## Pre-Translation Steps
1. **Delete existing Japanese files**: Remove all `*.ja.md` files in the target directories before translation
2. **Identify source files**: List all English `.md` files (excluding `CLAUDE.md` and already translated `*.ja.md` files)

## Translation Guidelines

### Frontmatter (YAML)
- Translate the `description` field to Japanese
- Keep `name`, `tools`, `model` fields in English
- Maintain the YAML structure

### Content
- Translate all prose text to Japanese
- Keep technical terms in English (e.g., Redis, CDN, PostgreSQL, API, CQRS, etc.)
- Translate headings to Japanese
- Translate code comments and explanations within code blocks to Japanese
- Keep code syntax, variable names, and command examples in English

### Style
- Use polite/formal Japanese (です/ます調)
- Maintain the original markdown formatting (headers, lists, code blocks, etc.)
- Preserve all links and references

## Execution Commands

### Step 1: Delete existing Japanese files
```bash
# Preview files to be deleted
ls README.ja.md 2>/dev/null
ls agents/*.ja.md 2>/dev/null
ls commands/*.ja.md 2>/dev/null
ls rules/*.ja.md 2>/dev/null
ls skills/*.ja.md 2>/dev/null

# Delete files
rm -f README.ja.md
rm -f agents/*.ja.md
rm -f commands/*.ja.md
rm -f rules/*.ja.md
rm -f skills/*.ja.md
```

### Step 2: List source files to translate
```bash
# README
ls README.md

# agents (excluding CLAUDE.md)
ls agents/*.md | grep -v "CLAUDE.md" | grep -v ".ja.md"

# commands (excluding CLAUDE.md)
ls commands/*.md | grep -v "CLAUDE.md" | grep -v ".ja.md"

# rules (excluding CLAUDE.md)
ls rules/*.md | grep -v "CLAUDE.md" | grep -v ".ja.md"

# skills (SKILL.md in subdirectories)
ls skills/*/SKILL.md
```

### Step 3: Translate each file
For each source file:
1. Read the English source file
2. Translate according to the guidelines
3. Write to the corresponding `.ja.md` file

## Example Translation

### English (source)
```markdown
---
name: architect
description: Software architecture specialist for system design
tools: ["Read", "Grep", "Glob"]
model: opus
---

You are a senior software architect.

## Your Role
- Design system architecture for new features
- Evaluate technical trade-offs
```

### Japanese (translated)
```markdown
---
name: architect
description: システム設計を専門とするソフトウェアアーキテクチャスペシャリスト
tools: ["Read", "Grep", "Glob"]
model: opus
---

あなたはシニアソフトウェアアーキテクトです。

## あなたの役割
- 新機能のシステムアーキテクチャを設計する
- 技術的なトレードオフを評価する
```

## Notes
- For skills, the source is `skills/<name>/SKILL.md` and output is `skills/<name>.ja.md`
- `CLAUDE.md` files are NOT translated (they are configuration files)
- If a source file has no corresponding English version, skip it
- Subdirectory files within skills (e.g., `skills/security-review/cloud-infrastructure-security.md`) are NOT translated
