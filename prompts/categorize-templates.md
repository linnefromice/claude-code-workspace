# テンプレート分類プロンプト

## 概要

翻訳済みテンプレートを分析し、レベル・タイプで分類して `MANIFEST.md` を更新する。

**実行タイミング:**
- 初回翻訳完了後
- ソースリポジトリの大幅な更新後
- 分類基準の見直し時

---

## 分類基準

### レベル (level)

| レベル | 基準 |
|--------|------|
| `beginner` | 設定不要でそのまま使用可能。汎用的で理解しやすい |
| `intermediate` | テストフレームワーク等の前提あり。中程度の複雑さ |
| `advanced` | カスタムセットアップが必要。学習システムや高度な機能 |

### タイプ (type)

| タイプ | 基準 |
|--------|------|
| `general` | 言語・フレームワーク非依存。どのプロジェクトでも使用可能 |
| `web` | Web開発固有（React, Next.js, E2E, Playwright, フロントエンド/バックエンドパターン等） |
| `excluded` | 除外対象（Go, PostgreSQL, ClickHouse等の言語/DB固有） |

---

## 実行手順

### 1. 現在のファイル一覧を取得

```bash
echo "=== Agents ===" && ls template-.claude/agents/*.md 2>/dev/null | grep -v CLAUDE.md
echo "=== Commands ===" && ls template-.claude/commands/*.md 2>/dev/null | grep -v CLAUDE.md
echo "=== Rules ===" && ls template-.claude/rules/*.md 2>/dev/null | grep -v CLAUDE.md
echo "=== Skills ===" && ls -d template-.claude/skills/*/ 2>/dev/null
echo "=== Contexts ===" && ls template-.claude/contexts/*.md 2>/dev/null | grep -v CLAUDE.md
```

### 2. 各ファイルを分析

各ファイルを読み込み、以下の観点で分類を判断：

**beginner の判断基準:**
- 特別な設定なしで使用可能か？
- 概念が単純で理解しやすいか？
- プロジェクトの種類を問わず有用か？

**intermediate の判断基準:**
- テストフレームワーク（Jest, Playwright等）が必要か？
- ビルドツール（npm scripts等）の設定が必要か？
- ある程度の Claude Code 経験が必要か？

**advanced の判断基準:**
- カスタムのディレクトリ構造やファイルが必要か？
- 学習・評価システムの構築が必要か？
- 高度なワークフローの理解が必要か？

**web の判断基準:**
- React, Next.js, Vue 等のフレームワーク固有か？
- E2E テスト（Playwright, Cypress）関連か？
- フロントエンド/バックエンド固有のパターンか？

### 3. MANIFEST.md を更新

`template-.claude/MANIFEST.md` の各テーブルを更新。

**フォーマット:**

```markdown
| ファイル | レベル | タイプ | 説明 |
|----------|--------|--------|------|
| `filename.md` | beginner/intermediate/advanced | general/web | 簡潔な説明 |
```

### 4. プリセットのファイル数を確認

```bash
# MANIFEST.md を解析してプリセットごとのファイル数を計算
echo "minimal (beginner + general):"
grep -E "beginner.*general" template-.claude/MANIFEST.md | wc -l

echo "standard (beginner,intermediate + general):"
grep -E "(beginner|intermediate).*general" template-.claude/MANIFEST.md | wc -l

echo "standard-web (beginner,intermediate + general,web):"
grep -E "(beginner|intermediate).*(general|web)" template-.claude/MANIFEST.md | wc -l

echo "full:"
grep -E "(beginner|intermediate|advanced).*(general|web)" template-.claude/MANIFEST.md | wc -l
```

### 5. MANIFEST.md のプリセットセクションを更新

ファイル数を反映。

---

## 分類の判断例

### Agents

| ファイル | 判断理由 | 結果 |
|----------|---------|------|
| `planner.md` | 設定不要、汎用的 | beginner, general |
| `code-reviewer.md` | 設定不要、汎用的 | beginner, general |
| `tdd-guide.md` | テストフレームワーク前提 | intermediate, general |
| `e2e-runner.md` | Playwright 前提 | intermediate, web |
| `database-reviewer.md` | PostgreSQL固有 | excluded |

### Commands

| ファイル | 判断理由 | 結果 |
|----------|---------|------|
| `plan.md` | 設定不要 | beginner, general |
| `tdd.md` | テストフレームワーク前提 | intermediate, general |
| `instinct-*.md` | 学習システム構築必要 | advanced, general |

### Skills

| ディレクトリ | 判断理由 | 結果 |
|-------------|---------|------|
| `coding-standards/` | 汎用的なベストプラクティス | beginner, general |
| `frontend-patterns/` | React/Next.js 固有 | intermediate, web |
| `continuous-learning/` | カスタムセットアップ必要 | advanced, general |

---

## チェックリスト

- [ ] 全ファイルが分類されている
- [ ] 各ファイルにレベルとタイプが設定されている
- [ ] プリセットのファイル数が正確
- [ ] 除外対象（excluded）が MANIFEST に含まれていない
- [ ] 新規追加ファイルが分類されている

---

## 完了後

分類完了後、デプロイスクリプトで動作確認：

```bash
# 各プリセットでドライラン
./scripts/deploy-to-project.sh /tmp/test --preset minimal --dry-run
./scripts/deploy-to-project.sh /tmp/test --preset standard --dry-run
./scripts/deploy-to-project.sh /tmp/test --preset standard-web --dry-run
./scripts/deploy-to-project.sh /tmp/test --preset full --dry-run
```
