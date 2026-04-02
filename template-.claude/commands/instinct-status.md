---
name: instinct-status
description: 信頼度付きで学習したインスティンクト（プロジェクト + グローバル）を表示
command: true
---

# インスティンクトステータスコマンド

現在のプロジェクトの学習したインスティンクトとグローバルインスティンクトを、ドメイン別にグループ化して表示します。

## 実装

プラグインルートパスを使用してインスティンクトCLIを実行:

```bash
python3 "${CLAUDE_PLUGIN_ROOT}/skills/continuous-learning-v2/scripts/instinct-cli.py" status
```

`CLAUDE_PLUGIN_ROOT` が設定されていない場合（手動インストール）:

```bash
python3 ~/.claude/skills/continuous-learning-v2/scripts/instinct-cli.py status
```

## 使用方法

```
/instinct-status
```

## 処理内容

1. 現在のプロジェクトコンテキストを検出（gitリモート/パスハッシュ）
2. `~/.claude/homunculus/projects/<project-id>/instincts/` からプロジェクトインスティンクトを読み取り
3. `~/.claude/homunculus/instincts/` からグローバルインスティンクトを読み取り
4. 優先順位ルールでマージ（IDが競合する場合はプロジェクトがグローバルをオーバーライド）
5. 信頼度バーと観察統計でドメイン別にグループ化して表示

## 出力フォーマット

```
============================================================
  INSTINCT STATUS - 12 total
============================================================

  Project: my-app (a1b2c3d4e5f6)
  Project instincts: 8
  Global instincts:  4

## PROJECT-SCOPED (my-app)
  ### WORKFLOW (3)
    ███████░░░  70%  grep-before-edit [project]
              trigger: when modifying code

## GLOBAL (apply to all projects)
  ### SECURITY (2)
    █████████░  85%  validate-user-input [global]
              trigger: when handling user input
```
