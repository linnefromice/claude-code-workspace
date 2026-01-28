# フックシステム

## フックタイプ

- **PreToolUse**: ツール実行前（バリデーション、パラメータ修正）
- **PostToolUse**: ツール実行後（自動フォーマット、チェック）
- **Stop**: セッション終了時（最終検証）

## 現在のフック（~/.claude/settings.json 内）

### PreToolUse
- **tmuxリマインダー**: 長時間実行コマンド（npm, pnpm, yarn, cargo等）にtmuxを提案
- **git pushレビュー**: プッシュ前にZedでレビューを開く
- **ドキュメントブロッカー**: 不要な .md/.txt ファイルの作成をブロック

### PostToolUse
- **PR作成**: PR URLとGitHub Actionsステータスをログ出力
- **Prettier**: JS/TSファイルを編集後に自動フォーマット
- **TypeScriptチェック**: .ts/.tsx ファイル編集後にtscを実行
- **console.log警告**: 編集されたファイル内のconsole.logを警告

### Stop
- **console.log監査**: セッション終了前にすべての変更ファイルでconsole.logをチェック

## 自動承認パーミッション

慎重に使用:
- 信頼できる、明確に定義されたプランに対して有効化
- 探索的な作業では無効化
- dangerously-skip-permissionsフラグは絶対に使用しない
- 代わりに `~/.claude.json` で `allowedTools` を設定

## TodoWrite ベストプラクティス

TodoWriteツールの使用目的:
- マルチステップタスクの進捗を追跡
- 指示の理解を検証
- リアルタイムでの方向修正を可能に
- 詳細な実装ステップを表示

Todoリストで明らかになること:
- 順序が違うステップ
- 欠けている項目
- 余分な不要な項目
- 間違った粒度
- 誤解された要件
