---
name: nextjs-turbopack
description: Next.js 16+ and Turbopack — incremental bundling, FS caching, dev speed, and when to use Turbopack vs webpack.
origin: ECC
---

# Next.js と Turbopack

Next.js 16+ はローカル開発でデフォルトで Turbopack を使用します。Rust で書かれたインクリメンタルバンドラーで、dev の起動とホットアップデートを大幅に高速化します。

## 使用タイミング

- **Turbopack（デフォルト dev）**: 日常の開発に使用します。特に大規模アプリでのコールドスタートと HMR が高速です。
- **Webpack（レガシー dev）**: Turbopack のバグに当たった場合や、dev で webpack 専用プラグインに依存する場合のみ使用します。`--webpack`（または Next.js バージョンによっては `--no-turbopack`）で無効化します。
- **プロダクション**: プロダクションビルドの動作（`next build`）は Next.js バージョンにより Turbopack または webpack を使用する場合があります。

使用シーン: Next.js 16+ アプリの開発やデバッグ、dev 起動や HMR の遅さの診断、プロダクションバンドルの最適化。

## 仕組み

- **Turbopack**: Next.js dev 用インクリメンタルバンドラー。ファイルシステムキャッシュにより再起動が大幅に高速化します（大規模プロジェクトで 5-14 倍）。
- **dev でのデフォルト**: Next.js 16 から、`next dev` は無効化しない限り Turbopack で実行されます。
- **ファイルシステムキャッシュ**: 再起動時に前回の作業を再利用。キャッシュは通常 `.next` 配下。基本的な使用には追加設定不要です。
- **Bundle Analyzer（Next.js 16.1+）**: 出力を検査し重い依存関係を見つけるための実験的な Bundle Analyzer。設定または実験的フラグで有効化します。

## 例

### コマンド

```bash
next dev
next build
next start
```

### 使い方

ローカル開発には `next dev` を Turbopack で実行します。Bundle Analyzer（Next.js ドキュメント参照）を使用してコード分割を最適化し、大きな依存関係を削減します。可能な場合は App Router と Server Components を優先してください。

## ベストプラクティス

- 安定した Turbopack とキャッシュ動作のため、最新の Next.js 16.x を使用してください。
- dev が遅い場合、Turbopack（デフォルト）が有効であり、キャッシュが不必要にクリアされていないことを確認してください。
- プロダクションバンドルサイズの問題には、お使いのバージョンの公式 Next.js バンドル分析ツールを使用してください。
