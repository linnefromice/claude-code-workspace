---
name: instinct-status
description: 信頼度レベルとともにすべての学習したインスティンクトを表示
command: /instinct-status
implementation: python3 ~/.claude/skills/continuous-learning-v2/scripts/instinct-cli.py status
---

# インスティンクトステータスコマンド

信頼度スコアとともにすべての学習したインスティンクトをドメイン別にグループ化して表示。

## 実装

```bash
python3 ~/.claude/skills/continuous-learning-v2/scripts/instinct-cli.py status
```

## 使用方法

```
/instinct-status
/instinct-status --domain code-style
/instinct-status --low-confidence
```

## 処理内容

1. `~/.claude/homunculus/instincts/personal/`からすべてのインスティンクトファイルを読み取り
2. `~/.claude/homunculus/instincts/inherited/`から継承インスティンクトを読み取り
3. ドメイン別にグループ化し信頼度バーで表示

## 出力フォーマット

```
📊 インスティンクトステータス
==================

## コードスタイル（4インスティンクト）

### prefer-functional-style
トリガー: 新しい関数を書く時
アクション: クラスよりも関数型パターンを使用
信頼度: ████████░░ 80%
ソース: session-observation | 最終更新: 2025-01-22

### use-path-aliases
トリガー: モジュールをインポートする時
アクション: 相対インポートの代わりに@/パスエイリアスを使用
信頼度: ██████░░░░ 60%
ソース: repo-analysis (github.com/acme/webapp)

## テスト（2インスティンクト）

### test-first-workflow
トリガー: 新しい機能を追加する時
アクション: 最初にテストを書き、次に実装
信頼度: █████████░ 90%
ソース: session-observation

## ワークフロー（3インスティンクト）

### grep-before-edit
トリガー: コードを修正する時
アクション: Grepで検索、Readで確認、次にEdit
信頼度: ███████░░░ 70%
ソース: session-observation

---
合計: 9インスティンクト（4個人、5継承）
オブザーバー: 実行中（最終分析: 5分前）
```

## フラグ

- `--domain <name>`: ドメインでフィルタ（code-style、testing、gitなど）
- `--low-confidence`: 信頼度 < 0.5のインスティンクトのみ表示
- `--high-confidence`: 信頼度 >= 0.7のインスティンクトのみ表示
- `--source <type>`: ソースでフィルタ（session-observation、repo-analysis、inherited）
- `--json`: プログラム使用のためJSONで出力
