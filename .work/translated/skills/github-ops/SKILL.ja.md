---
name: github-ops
description: GitHub リポジトリの運用、自動化、管理を行います。gh CLI を使用した issue トリアージ、PR 管理、CI/CD 運用、リリース管理、セキュリティモニタリング。ユーザーが GitHub の issue、PR、CI ステータス、リリース、コントリビュータ、stale アイテム、または単純な git コマンドを超える GitHub 運用タスクを管理したい場合に使用します。
origin: ECC
---

# GitHub Operations

コミュニティの健全性、CI の信頼性、コントリビュータ体験に焦点を当てて GitHub リポジトリを管理します。

## 発動タイミング

- Issue のトリアージ (分類、ラベル付け、応答、重複排除)
- PR の管理 (レビューステータス、CI チェック、stale PR、マージ準備)
- CI/CD 失敗のデバッグ
- リリースと changelog の準備
- Dependabot とセキュリティアラートのモニタリング
- OSS プロジェクトでのコントリビュータ体験の管理
- ユーザーが「GitHub を確認」「issue をトリアージ」「PR をレビュー」「マージ」「リリース」「CI が壊れている」と言う

## ツール要件

- すべての GitHub API 操作に **gh CLI**
- `gh auth login` を介して設定されたリポジトリアクセス

## Issue トリアージ

各 issue をタイプと優先度で分類します:

**タイプ:** bug, feature-request, question, documentation, enhancement, duplicate, invalid, good-first-issue

**優先度:** critical (破壊的/セキュリティ), high (重大な影響), medium (あると良い), low (見た目)

### トリアージワークフロー

1. issue のタイトル、本文、コメントを読む
2. 既存 issue と重複するか確認 (キーワードで検索)
3. `gh issue edit --add-label` で適切なラベルを適用
4. 質問の場合: 有用な応答をドラフトして投稿
5. 追加情報が必要なバグの場合: 再現手順を依頼
6. good first issue の場合: `good-first-issue` ラベルを追加
7. 重複の場合: オリジナルへのリンクでコメント、`duplicate` ラベルを追加

```bash
# 重複候補を検索
gh issue list --search "keyword" --state all --limit 20

# ラベルを追加
gh issue edit <number> --add-label "bug,high-priority"

# issue にコメント
gh issue comment <number> --body "Thanks for reporting. Could you share reproduction steps?"
```

## PR 管理

### レビューチェックリスト

1. CI ステータスを確認: `gh pr checks <number>`
2. マージ可能か確認: `gh pr view <number> --json mergeable`
3. 年齢と最終アクティビティを確認
4. レビューなしで 5 日を超える PR にフラグ
5. コミュニティ PR の場合: テストがあり規約に従うことを確認

### Stale ポリシー

- 14 日以上アクティビティがない issue: `stale` ラベル追加、更新を求めるコメント
- 7 日以上アクティビティがない PR: まだアクティブかコメントで確認
- 応答のない stale issue を 30 日後に自動クローズ (`closed-stale` ラベルを追加)

```bash
# stale な issue を検索 (14 日以上アクティビティなし)
gh issue list --label "stale" --state open

# 最近アクティビティがない PR を検索
gh pr list --json number,title,updatedAt --jq '.[] | select(.updatedAt < "2026-03-01")'
```

## CI/CD 運用

CI が失敗したとき:

1. ワークフロー実行を確認: `gh run view <run-id> --log-failed`
2. 失敗したステップを特定
3. flaky テストか真の失敗かを確認
4. 真の失敗の場合: 根本原因を特定して修正を提案
5. flaky テストの場合: 後の調査のためにパターンを記録

```bash
# 最近の失敗実行を一覧
gh run list --status failure --limit 10

# 失敗実行ログを表示
gh run view <run-id> --log-failed

# 失敗ワークフローを再実行
gh run rerun <run-id> --failed
```

## リリース管理

リリースを準備するとき:

1. main 上のすべての CI がグリーンであることを確認
2. 未リリースの変更をレビュー: `gh pr list --state merged --base main`
3. PR タイトルから changelog を生成
4. リリースを作成: `gh release create`

```bash
# 最終リリース以降にマージされた PR を一覧
gh pr list --state merged --base main --search "merged:>2026-03-01"

# リリースを作成
gh release create v1.2.0 --title "v1.2.0" --generate-notes

# pre-release を作成
gh release create v1.3.0-rc1 --prerelease --title "v1.3.0 Release Candidate 1"
```

## セキュリティモニタリング

```bash
# Dependabot アラートを確認
gh api repos/{owner}/{repo}/dependabot/alerts --jq '.[].security_advisory.summary'

# secret scanning アラートを確認
gh api repos/{owner}/{repo}/secret-scanning/alerts --jq '.[].state'

# 安全な依存関係バンプをレビューして自動マージ
gh pr list --label "dependencies" --json number,title
```

- 安全な依存関係バンプをレビューして自動マージ
- critical/high 深刻度のアラートを即座にフラグ
- 最低でも週次で新しい Dependabot アラートを確認

## 品質ゲート

GitHub 運用タスクを完了する前に:
- トリアージされたすべての issue が適切なラベルを持つ
- レビューまたはコメントなしで 7 日を超える PR がない
- CI 失敗が調査されている (単に再実行されただけではない)
- リリースに正確な changelog が含まれる
- セキュリティアラートが確認され追跡されている
