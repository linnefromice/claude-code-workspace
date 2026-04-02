# Loop Startコマンド

安全なデフォルト設定で管理された自律ループパターンを開始します。

## 使用方法

`/loop-start [pattern] [--mode safe|fast]`

- `pattern`: `sequential`、`continuous-pr`、`rfc-dag`、`infinite`
- `--mode`:
  - `safe`（デフォルト）: 厳密な品質ゲートとチェックポイント
  - `fast`: 速度のためにゲートを削減

## フロー

1. リポジトリの状態とブランチ戦略を確認。
2. ループパターンとモデルティア戦略を選択。
3. 選択されたモードに必要なフック/プロファイルを有効化。
4. ループプランを作成し、`.claude/plans/` 配下にランブックを書き込み。
5. ループの開始と監視のためのコマンドを出力。

## 必須安全チェック

- 最初のループイテレーション前にテストが通ることを確認。
- `ECC_HOOK_PROFILE` がグローバルに無効化されていないことを確認。
- ループに明示的な停止条件があることを確認。

## 引数

$ARGUMENTS:
- `<pattern>` オプション（`sequential|continuous-pr|rfc-dag|infinite`）
- `--mode safe|fast` オプション
