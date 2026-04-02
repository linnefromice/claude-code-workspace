---
name: continuous-learning-v2
description: Instinct-based learning system that observes sessions via hooks, creates atomic instincts with confidence scoring, and evolves them into skills/commands/agents. v2.1 adds project-scoped instincts to prevent cross-project contamination.
origin: ECC
version: 2.1.0
---

# 継続的学習 v2.1 - インスティンクトベースアーキテクチャ

Claude Code セッションを再利用可能な知識に変換する高度な学習システムです。信頼度スコアリング付きのアトミックな「インスティンクト」（小さな学習された行動）を通じて実現します。

**v2.1** では**プロジェクトスコープのインスティンクト**を追加 -- React のパターンは React プロジェクトに、Python の規約は Python プロジェクトに留まり、ユニバーサルなパターン（「常に入力をバリデーションする」など）はグローバルに共有されます。

## 起動条件

- Claude Code セッションからの自動学習のセットアップ
- フック経由のインスティンクトベース行動抽出の設定
- 学習された行動の信頼度閾値のチューニング
- インスティンクトライブラリのレビュー、エクスポート、インポート
- インスティンクトをフルスキル、コマンド、エージェントに発展させる
- プロジェクトスコープ vs グローバルインスティンクトの管理
- プロジェクトからグローバルスコープへのインスティンクトのプロモート

## v2.1 の新機能

| 特徴 | v2.0 | v2.1 |
|---------|------|------|
| ストレージ | グローバル (~/.claude/homunculus/) | プロジェクトスコープ (projects/<hash>/) |
| スコープ | すべてのインスティンクトがどこでも適用 | プロジェクトスコープ + グローバル |
| 検出 | なし | git remote URL / リポジトリパス |
| プロモーション | N/A | 2+ プロジェクトで見られた場合にプロジェクト → グローバル |
| コマンド | 4 (status/evolve/export/import) | 6 (+promote/projects) |
| クロスプロジェクト | 汚染リスク | デフォルトで分離 |

## v2 の新機能（v1 比較）

| 特徴 | v1 | v2 |
|---------|----|----|
| 観察 | Stop フック（セッション終了時） | PreToolUse/PostToolUse（100% 確実） |
| 分析 | メインコンテキスト | バックグラウンドエージェント（Haiku） |
| 粒度 | 完全なスキル | アトミックな「インスティンクト」 |
| 信頼度 | なし | 0.3-0.9 の重み付け |
| 進化 | 直接スキルへ | インスティンクト -> クラスター -> スキル/コマンド/エージェント |
| 共有 | なし | インスティンクトのエクスポート/インポート |

## インスティンクトモデル

インスティンクトは小さな学習された行動です：

```yaml
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
domain: "code-style"
source: "session-observation"
scope: project
project_id: "a1b2c3d4e5f6"
project_name: "my-react-app"
---

# 関数型スタイルを優先

## アクション
適切な場合にクラスより関数型パターンを使用します。

## 根拠
- 関数型パターン優先の 5 つのインスタンスを観察
- 2025-01-15 にユーザーがクラスベースアプローチを関数型に修正
```

**プロパティ:**
- **アトミック** -- 1 つのトリガー、1 つのアクション
- **信頼度加重** -- 0.3 = 暫定的、0.9 = ほぼ確実
- **ドメインタグ付き** -- code-style、testing、git、debugging、workflow など
- **根拠付き** -- 作成した観察を追跡
- **スコープ対応** -- `project`（デフォルト）または `global`

## 仕組み

```
セッションアクティビティ（git リポジトリ内）
      |
      | フックがプロンプト + ツール使用をキャプチャ（100% 確実）
      | + プロジェクトコンテキストを検出（git remote / リポジトリパス）
      v
+---------------------------------------------+
|  projects/<project-hash>/observations.jsonl  |
|   （プロンプト、ツールコール、結果、プロジェクト）|
+---------------------------------------------+
      |
      | オブザーバーエージェントが読み取り（バックグラウンド、Haiku）
      v
+---------------------------------------------+
|          パターン検出                        |
|   * ユーザー修正 -> インスティンクト          |
|   * エラー解決 -> インスティンクト            |
|   * 繰り返しワークフロー -> インスティンクト  |
|   * スコープ判定: プロジェクト or グローバル？ |
+---------------------------------------------+
      |
      | 作成/更新
      v
+---------------------------------------------+
|  projects/<project-hash>/instincts/personal/ |
|   * prefer-functional.yaml (0.7) [project]   |
|   * use-react-hooks.yaml (0.9) [project]     |
+---------------------------------------------+
|  instincts/personal/  (GLOBAL)               |
|   * always-validate-input.yaml (0.85) [global]|
|   * grep-before-edit.yaml (0.6) [global]     |
+---------------------------------------------+
      |
      | /evolve がクラスタリング + /promote
      v
+---------------------------------------------+
|  projects/<hash>/evolved/ (プロジェクトスコープ)|
|  evolved/ (グローバル)                       |
|   * commands/new-feature.md                  |
|   * skills/testing-workflow.md               |
|   * agents/refactor-specialist.md            |
+---------------------------------------------+
```

## プロジェクト検出

システムは自動的に現在のプロジェクトを検出します：

1. **`CLAUDE_PROJECT_DIR` 環境変数**（最高優先度）
2. **`git remote get-url origin`** -- ポータブルなプロジェクト ID を作成するためにハッシュ化（異なるマシンの同じリポジトリは同じ ID を取得）
3. **`git rev-parse --show-toplevel`** -- リポジトリパスを使用するフォールバック（マシン固有）
4. **グローバルフォールバック** -- プロジェクトが検出されない場合、インスティンクトはグローバルスコープへ

各プロジェクトは 12 文字のハッシュ ID を取得します（例: `a1b2c3d4e5f6`）。`~/.claude/homunculus/projects.json` のレジストリファイルが ID を人間が読める名前にマッピングします。

## クイックスタート

### 1. 観察フックを有効化

`~/.claude/settings.json` に追加します。

**プラグインとしてインストールした場合**（推奨）：

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/hooks/observe.sh"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/hooks/observe.sh"
      }]
    }]
  }
}
```

**手動で `~/.claude/skills` にインストールした場合**：

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/continuous-learning-v2/hooks/observe.sh"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/continuous-learning-v2/hooks/observe.sh"
      }]
    }]
  }
}
```

### 2. ディレクトリ構造を初期化

システムは初回使用時に自動的にディレクトリを作成しますが、手動で作成することも可能です：

```bash
# グローバルディレクトリ
mkdir -p ~/.claude/homunculus/{instincts/{personal,inherited},evolved/{agents,skills,commands},projects}

# プロジェクトディレクトリはフックが git リポジトリ内で初めて実行されたときに自動作成されます
```

### 3. インスティンクトコマンドを使用

```bash
/instinct-status     # 学習したインスティンクトを表示（プロジェクト + グローバル）
/evolve              # 関連インスティンクトをスキル/コマンドにクラスタリング
/instinct-export     # インスティンクトをエクスポート
/instinct-import     # 他者からインスティンクトをインポート
/promote             # プロジェクトインスティンクトをグローバルスコープにプロモート
/projects            # 既知のすべてのプロジェクトとインスティンクト数を一覧表示
```

## コマンド

| コマンド | 説明 |
|---------|-------------|
| `/instinct-status` | すべてのインスティンクト（プロジェクトスコープ + グローバル）を信頼度付きで表示 |
| `/evolve` | 関連インスティンクトをスキル/コマンドにクラスタリング、プロモーション候補を提案 |
| `/instinct-export` | インスティンクトをエクスポート（スコープ/ドメインでフィルタ可能） |
| `/instinct-import <file>` | スコープ制御付きでインスティンクトをインポート |
| `/promote [id]` | プロジェクトインスティンクトをグローバルスコープにプロモート |
| `/projects` | 既知のすべてのプロジェクトとインスティンクト数を一覧表示 |

## 設定

`config.json` を編集してバックグラウンドオブザーバーを制御します：

```json
{
  "version": "2.1",
  "observer": {
    "enabled": false,
    "run_interval_minutes": 5,
    "min_observations_to_analyze": 20
  }
}
```

| キー | デフォルト | 説明 |
|-----|---------|-------------|
| `observer.enabled` | `false` | バックグラウンドオブザーバーエージェントを有効にする |
| `observer.run_interval_minutes` | `5` | オブザーバーが観察を分析する頻度 |
| `observer.min_observations_to_analyze` | `20` | 分析実行前の最小観察数 |

その他の動作（観察キャプチャ、インスティンクト閾値、プロジェクトスコーピング、プロモーション基準）は `instinct-cli.py` と `observe.sh` のコードデフォルトで設定されます。

## ファイル構造

```
~/.claude/homunculus/
+-- identity.json           # プロファイル、技術レベル
+-- projects.json           # レジストリ: プロジェクトハッシュ -> 名前/パス/リモート
+-- observations.jsonl      # グローバル観察（フォールバック）
+-- instincts/
|   +-- personal/           # グローバル自動学習インスティンクト
|   +-- inherited/          # グローバルインポートインスティンクト
+-- evolved/
|   +-- agents/             # グローバル生成エージェント
|   +-- skills/             # グローバル生成スキル
|   +-- commands/           # グローバル生成コマンド
+-- projects/
    +-- a1b2c3d4e5f6/       # プロジェクトハッシュ（git remote URL から）
    |   +-- project.json    # プロジェクトごとのメタデータミラー (id/name/root/remote)
    |   +-- observations.jsonl
    |   +-- observations.archive/
    |   +-- instincts/
    |   |   +-- personal/   # プロジェクト固有の自動学習
    |   |   +-- inherited/  # プロジェクト固有のインポート
    |   +-- evolved/
    |       +-- skills/
    |       +-- commands/
    |       +-- agents/
    +-- f6e5d4c3b2a1/       # 別のプロジェクト
        +-- ...
```

## スコープ判定ガイド

| パターンタイプ | スコープ | 例 |
|-------------|-------|---------|
| 言語/フレームワーク規約 | **project** | 「React hooks を使用」、「Django REST パターンに従う」 |
| ファイル構造の好み | **project** | 「テストは `__tests__`/ に」、「コンポーネントは src/components/ に」 |
| コードスタイル | **project** | 「関数型スタイルを使用」、「dataclasses を優先」 |
| エラーハンドリング戦略 | **project** | 「エラーには Result 型を使用」 |
| セキュリティプラクティス | **global** | 「ユーザー入力をバリデーション」、「SQL をサニタイズ」 |
| 一般的なベストプラクティス | **global** | 「テストを先に書く」、「常にエラーをハンドリング」 |
| ツールワークフローの好み | **global** | 「Edit 前に Grep」、「Write 前に Read」 |
| Git プラクティス | **global** | 「Conventional commits」、「小さく焦点の合ったコミット」 |

## インスティンクトのプロモーション（プロジェクト -> グローバル）

同じインスティンクトが高い信頼度で複数のプロジェクトに出現した場合、グローバルスコープへのプロモーション候補となります。

**自動プロモーション基準:**
- 2+ プロジェクトで同じインスティンクト ID
- 平均信頼度 >= 0.8

**プロモーション方法:**

```bash
# 特定のインスティンクトをプロモート
python3 instinct-cli.py promote prefer-explicit-errors

# 条件を満たすすべてのインスティンクトを自動プロモート
python3 instinct-cli.py promote

# 変更なしでプレビュー
python3 instinct-cli.py promote --dry-run
```

`/evolve` コマンドもプロモーション候補を提案します。

## 信頼度スコアリング

信頼度は時間とともに変化します：

| スコア | 意味 | 動作 |
|-------|---------|----------|
| 0.3 | 暫定的 | 提案されるが強制されない |
| 0.5 | 中程度 | 関連する時に適用 |
| 0.7 | 強い | 適用が自動承認 |
| 0.9 | ほぼ確実 | コア動作 |

**信頼度が上がる**場合：
- パターンが繰り返し観察される
- ユーザーが提案された動作を修正しない
- 他のソースからの類似インスティンクトが一致

**信頼度が下がる**場合：
- ユーザーが明示的に動作を修正
- パターンが長期間観察されない
- 矛盾する根拠が現れる

## 観察にスキルではなくフックを使う理由

> 「v1 は観察にスキルを使用していた。スキルは確率的で、Claude の判断に基づいて ~50-80% の確率で発火する。」

フックは**100% の確率**で、決定論的に発火します。これにより：
- すべてのツールコールが観察される
- パターンが見逃されない
- 学習が包括的

## 後方互換性

v2.1 は v2.0 および v1 と完全に互換です：
- `~/.claude/homunculus/instincts/` の既存グローバルインスティンクトは引き続きグローバルインスティンクトとして動作
- v1 の既存 `~/.claude/skills/learned/` スキルは引き続き動作
- Stop フックは引き続き実行（ただし v2 にもフィード）
- 段階的移行: 両方を並行実行

## プライバシー

- 観察はマシン上に**ローカル**で保存
- プロジェクトスコープのインスティンクトはプロジェクトごとに分離
- **インスティンクト**（パターン）のみエクスポート可能 -- 生の観察ではない
- 実際のコードや会話内容は共有されない
- エクスポートおよびプロモートするものは自分で制御

## 関連

- [ECC-Tools GitHub App](https://github.com/apps/ecc-tools) - リポジトリ履歴からインスティンクトを生成
- Homunculus - v2 インスティンクトベースアーキテクチャにインスピレーションを与えたコミュニティプロジェクト（アトミック観察、信頼度スコアリング、インスティンクト進化パイプライン）
- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) - 継続的学習セクション

---

*インスティンクトベース学習: Claude にあなたのパターンを教える、一つのプロジェクトずつ。*
