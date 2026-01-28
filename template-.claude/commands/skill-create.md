---
name: skill-create
description: ローカルgit履歴を分析してコーディングパターンを抽出し、SKILL.mdファイルを生成。Skill Creator GitHub Appのローカル版。
allowed_tools: ["Bash", "Read", "Write", "Grep", "Glob"]
---

# /skill-create - ローカルスキル生成

リポジトリのgit履歴を分析してコーディングパターンを抽出し、チームのプラクティスをClaudeに教えるSKILL.mdファイルを生成。

## 使用方法

```bash
/skill-create                    # 現在のリポジトリを分析
/skill-create --commits 100      # 最後の100コミットを分析
/skill-create --output ./skills  # カスタム出力ディレクトリ
/skill-create --instincts        # continuous-learning-v2用のインスティンクトも生成
```

## 機能

1. **Git履歴を解析** - コミット、ファイル変更、パターンを分析
2. **パターンを検出** - 繰り返しのワークフローと規約を特定
3. **SKILL.mdを生成** - 有効なClaude Codeスキルファイルを作成
4. **オプションでインスティンクトを作成** - continuous-learning-v2システム用

## 分析ステップ

### ステップ1: Gitデータを収集

```bash
# ファイル変更を含む最近のコミットを取得
git log --oneline -n ${COMMITS:-200} --name-only --pretty=format:"%H|%s|%ad" --date=short

# ファイル別コミット頻度を取得
git log --oneline -n 200 --name-only | grep -v "^$" | grep -v "^[a-f0-9]" | sort | uniq -c | sort -rn | head -20

# コミットメッセージパターンを取得
git log --oneline -n 200 | cut -d' ' -f2- | head -50
```

### ステップ2: パターンを検出

以下のパターン種別を探す:

| パターン | 検出方法 |
|---------|-----------------|
| **コミット規約** | コミットメッセージの正規表現（feat:、fix:、chore:） |
| **ファイル共変更** | 常に一緒に変更されるファイル |
| **ワークフローシーケンス** | 繰り返されるファイル変更パターン |
| **アーキテクチャ** | フォルダ構造と命名規約 |
| **テストパターン** | テストファイルの場所、命名、カバレッジ |

### ステップ3: SKILL.mdを生成

出力フォーマット:

```markdown
---
name: {repo-name}-patterns
description: {repo-name}から抽出されたコーディングパターン
version: 1.0.0
source: local-git-analysis
analyzed_commits: {count}
---

# {リポジトリ名}パターン

## コミット規約
{検出されたコミットメッセージパターン}

## コードアーキテクチャ
{検出されたフォルダ構造と構成}

## ワークフロー
{検出された繰り返しファイル変更パターン}

## テストパターン
{検出されたテスト規約}
```

## 関連コマンド

- `/instinct-import` - 生成されたインスティンクトをインポート
- `/instinct-status` - 学習したインスティンクトを表示
- `/evolve` - インスティンクトをスキル/エージェントにクラスタリング

---

*[Everything Claude Code](https://github.com/affaan-m/everything-claude-code)の一部*
