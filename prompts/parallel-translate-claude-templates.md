# 並列翻訳プロンプト

## 概要

カテゴリ別の翻訳エージェントを **並列実行** して、翻訳速度と精度を向上させます。

**前提条件:** `./scripts/setup-templates.sh` が実行済みであること

---

## 並列実行の利点

| 項目 | 説明 |
|------|------|
| **速度** | 5カテゴリを同時に翻訳するため、約5倍高速 |
| **精度** | 各エージェントがカテゴリ固有のコンテキストを持つ |
| **一貫性** | 同一カテゴリ内で用語・文体が統一される |

---

## 実行手順

### Step 0: バージョン情報の記録

翻訳開始前に、参照元リポジトリのコミットハッシュを記録：

```bash
# 参照元リポジトリのコミットハッシュを取得
cd .work/source && git rev-parse HEAD && cd ../..

# 現在のリポジトリのコミットハッシュを取得
git rev-parse HEAD
```

`.work/VERSION.md` の「現在のバージョン」セクションを更新。

### Step 1: 出力ディレクトリの準備

```bash
mkdir -p .work/translated/{agents,commands,rules,skills,contexts}
```

### Step 2: カテゴリ別エージェントを並列起動

以下の **5つのエージェント** を **同時に** Task ツールで起動します：

```
1. agents-translator    → @prompts/translators/agents-translator.md
2. commands-translator  → @prompts/translators/commands-translator.md
3. rules-translator     → @prompts/translators/rules-translator.md
4. skills-translator    → @prompts/translators/skills-translator.md
5. contexts-translator  → @prompts/translators/contexts-translator.md
```

**並列起動の方法:**

Task ツールを使用し、`subagent_type: "general-purpose"` で各翻訳エージェントを起動。
1つのメッセージ内で5つの Task ツール呼び出しを行うことで並列実行されます。

**各エージェントへの指示例:**

```
以下のプロンプトに従って翻訳を実行してください:
@prompts/translators/agents-translator.md

入力: .work/source/agents/*.md
出力: .work/translated/agents/*.ja.md
```

### Step 3: 完了確認

全エージェントの完了後、翻訳結果を確認：

```bash
echo "=== Agents ===" && ls .work/translated/agents/*.ja.md 2>/dev/null | wc -l
echo "=== Commands ===" && ls .work/translated/commands/*.ja.md 2>/dev/null | wc -l
echo "=== Rules ===" && ls .work/translated/rules/*.ja.md 2>/dev/null | wc -l
echo "=== Skills ===" && ls .work/translated/skills/*/SKILL.ja.md 2>/dev/null | wc -l
echo "=== Contexts ===" && ls .work/translated/contexts/*.ja.md 2>/dev/null | wc -l
```

---

## エージェント定義サマリー

| エージェント | 対象 | 特徴 |
|-------------|------|------|
| agents-translator | エージェント定義 | 役割・責務の翻訳に特化 |
| commands-translator | コマンド定義 | 使用方法・引数説明に特化 |
| rules-translator | ルール定義 | ガイドライン・禁止事項の翻訳に特化 |
| skills-translator | スキル定義 | ワークフロー・チェックリストに特化 |
| contexts-translator | コンテキスト定義 | モード・振る舞いの翻訳に特化 |

---

## 翻訳ガイドライン（共通）

全エージェントで共通のガイドライン：

| 項目 | 対応 |
|------|------|
| Frontmatter の `description` | 日本語に翻訳 |
| Frontmatter の `name`, `tools`, `model` | 英語のまま |
| 見出し・説明文 | 日本語に翻訳 |
| コード内コメント | 日本語に翻訳 |
| 技術用語（Redis, API, CDN 等） | 英語のまま |
| コマンド例・変数名 | 英語のまま |
| 文体 | です/ます調 |

---

## 完了後

翻訳完了後、次のステップへ進んでください：

```
do @prompts/generalize-claude-templates.md
```

---

## トラブルシューティング

### 一部のエージェントが失敗した場合

失敗したカテゴリのみ個別に再実行：

```
do @prompts/translators/<カテゴリ>-translator.md
```

### ファイル数が合わない場合

ソースファイル数と翻訳ファイル数を比較：

```bash
echo "Source Agents:" && ls .work/source/agents/*.md | grep -v CLAUDE.md | wc -l
echo "Translated Agents:" && ls .work/translated/agents/*.ja.md | wc -l
```
