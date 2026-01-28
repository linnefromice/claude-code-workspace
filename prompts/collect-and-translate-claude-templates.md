# Claude Code テンプレート 日本語訳プロンプト

## 概要

`.work/source/` にクローンされたソースファイルを日本語訳し、`.work/translated/` に出力する。

**前提条件:** `./scripts/setup-templates.sh` が実行済みであること

---

## ディレクトリ構成

```
.work/
├── source/           # 入力（ソースリポジトリ）
│   ├── agents/
│   ├── commands/
│   ├── rules/
│   ├── skills/
│   └── contexts/
└── translated/       # 出力（翻訳結果）
    ├── agents/
    ├── commands/
    ├── rules/
    ├── skills/
    └── contexts/
```

---

## 翻訳対象

| カテゴリ | 入力 | 出力 |
|----------|------|------|
| Agents | `.work/source/agents/*.md` | `.work/translated/agents/*.ja.md` |
| Commands | `.work/source/commands/*.md` | `.work/translated/commands/*.ja.md` |
| Rules | `.work/source/rules/*.md` | `.work/translated/rules/*.ja.md` |
| Skills | `.work/source/skills/*/SKILL.md` | `.work/translated/skills/<name>.ja.md` |
| Contexts | `.work/source/contexts/*.md` | `.work/translated/contexts/*.ja.md` |
| README | `.work/source/README.md` | `.work/translated/README.ja.md` |

**除外:**
- `CLAUDE.md`（設定ファイル）
- 既存の `*.ja.md` ファイル

---

## 実行指示

以下の手順で翻訳を実行してください：

### 0. バージョン情報の記録（重要）

翻訳開始前に、参照元リポジトリのコミットハッシュを記録してください：

```bash
# 参照元リポジトリのコミットハッシュを取得
cd .work/source && git rev-parse HEAD && cd ../..

# 現在のリポジトリのコミットハッシュを取得
git rev-parse HEAD
```

取得した情報を `.work/VERSION.md` の「現在のバージョン」セクションに記録：
- **参照元リポジトリ**: 参照元のコミットハッシュ
- **翻訳実施時**: 現在のリポジトリのコミットハッシュ

### 1. 翻訳対象ファイルの確認

```bash
ls .work/source/agents/*.md | grep -v CLAUDE.md
ls .work/source/commands/*.md | grep -v CLAUDE.md
ls .work/source/rules/*.md | grep -v CLAUDE.md
ls .work/source/skills/*/SKILL.md
ls .work/source/contexts/*.md | grep -v CLAUDE.md
```

### 2. 各ファイルを日本語訳

各ソースファイルを読み込み、`@prompts/translate-to-ja.md` のガイドラインに従って日本語訳し、対応する出力パスに書き込んでください。

**翻訳ガイドライン:**

| 項目 | 対応 |
|------|------|
| Frontmatter の `description` | 日本語に翻訳 |
| Frontmatter の `name`, `tools`, `model` | 英語のまま |
| 見出し・説明文 | 日本語に翻訳 |
| コード内コメント | 日本語に翻訳 |
| 技術用語（Redis, API, CDN 等） | 英語のまま |
| コマンド例・変数名 | 英語のまま |

**文体:** です/ます調（丁寧語）

### 3. 翻訳結果の確認

```bash
ls .work/translated/agents/
ls .work/translated/commands/
ls .work/translated/rules/
ls .work/translated/skills/
ls .work/translated/contexts/
```

---

## 翻訳例

### 入力: `.work/source/contexts/dev.md`

```markdown
# Development Context

Mode: Active development
Focus: Implementation, coding, feature building

## Behavior

- Write code first, explain later
- Prefer working solutions over perfect ones
```

### 出力: `.work/translated/contexts/dev.ja.md`

```markdown
# 開発コンテキスト

モード: アクティブ開発
フォーカス: 実装、コーディング、機能構築

## 振る舞い

- まずコードを書き、後から説明
- 完璧な解決策より動く解決策を優先
```

---

## 完了後

翻訳完了後、次のステップへ進んでください：

```
do @prompts/generalize-claude-templates.md
```
