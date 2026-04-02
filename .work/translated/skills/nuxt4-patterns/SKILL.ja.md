---
name: nuxt4-patterns
description: Nuxt 4 app patterns for hydration safety, performance, route rules, lazy loading, and SSR-safe data fetching with useFetch and useAsyncData.
origin: ECC
---

# Nuxt 4 Patterns

SSR、ハイブリッドレンダリング、ルートルール、またはページレベルのデータフェッチングを使用する Nuxt 4 アプリの構築やデバッグ時に使用します。

## 起動条件

- サーバー HTML とクライアントステートの間のハイドレーションミスマッチ
- prerender、SWR、ISR、またはクライアントオンリーセクションなどのルートレベルのレンダリング判断
- 遅延読み込み、遅延ハイドレーション、またはペイロードサイズに関するパフォーマンス作業
- `useFetch`、`useAsyncData`、または `$fetch` によるページまたはコンポーネントのデータフェッチング
- ルートパラメータ、ミドルウェア、またはSSR/クライアント間の差異に関連する Nuxt ルーティングの問題

## ハイドレーションの安全性

- 最初のレンダリングを決定的に保ちます。`Date.now()`、`Math.random()`、ブラウザ専用 API、またはストレージの読み取りを SSR レンダリングのテンプレートステートに直接配置しないでください。
- サーバーが同じマークアップを生成できない場合、ブラウザ専用のロジックは `onMounted()`、`import.meta.client`、`ClientOnly`、または `.client.vue` コンポーネントの背後に移動します。
- `vue-router` のものではなく、Nuxt の `useRoute()` コンポーザブルを使用してください。
- SSR レンダリングされたマークアップを駆動するために `route.fullPath` を使用しないでください。URL フラグメントはクライアント専用であり、ハイドレーションミスマッチを引き起こす可能性があります。
- `ssr: false` はミスマッチのデフォルトの修正手段ではなく、真にブラウザ専用のエリアのためのエスケープハッチとして扱ってください。

## データフェッチング

- ページとコンポーネントでの SSR セーフな API 読み取りには `await useFetch()` を推奨します。サーバーでフェッチしたデータを Nuxt ペイロードに転送し、ハイドレーション時の2回目のフェッチを回避します。
- フェッチャーが単純な `$fetch()` 呼び出しでない場合、カスタムキーが必要な場合、または複数の非同期ソースを組み合わせる場合は `useAsyncData()` を使用します。
- キャッシュの再利用と予測可能なリフレッシュ動作のために、`useAsyncData()` に安定したキーを指定します。
- `useAsyncData()` のハンドラーは副作用のないものにします。SSR 時とハイドレーション時に実行される可能性があります。
- `$fetch()` はユーザーがトリガーする書き込みやクライアント専用のアクションに使用し、SSR からハイドレーションされるべきトップレベルのページデータには使用しません。
- ナビゲーションをブロックすべきでない非重要データには `lazy: true`、`useLazyFetch()`、または `useLazyAsyncData()` を使用します。UI で `status === 'pending'` を処理してください。
- SEO や初回描画に不要なデータにのみ `server: false` を使用します。
- `pick` でペイロードサイズを削減し、深いリアクティビティが不要な場合はより浅いペイロードを推奨します。

```ts
const route = useRoute()

const { data: article, status, error, refresh } = await useAsyncData(
  () => `article:${route.params.slug}`,
  () => $fetch(`/api/articles/${route.params.slug}`),
)

const { data: comments } = await useFetch(`/api/articles/${route.params.slug}/comments`, {
  lazy: true,
  server: false,
})
```

## ルートルール

レンダリングとキャッシング戦略には `nuxt.config.ts` の `routeRules` を推奨します:

```ts
export default defineNuxtConfig({
  routeRules: {
    '/': { prerender: true },
    '/products/**': { swr: 3600 },
    '/blog/**': { isr: true },
    '/admin/**': { ssr: false },
    '/api/**': { cache: { maxAge: 60 * 60 } },
  },
})
```

- `prerender`: ビルド時の静的 HTML
- `swr`: キャッシュされたコンテンツを配信し、バックグラウンドで再検証
- `isr`: 対応プラットフォームでのインクリメンタル静的再生成
- `ssr: false`: クライアントレンダリングルート
- `cache` または `redirect`: Nitro レベルのレスポンス制御

ルートルールはグローバルではなく、ルートグループごとに選択します。マーケティングページ、カタログ、ダッシュボード、API は通常それぞれ異なる戦略が必要です。

## 遅延読み込みとパフォーマンス

- Nuxt はすでにルートごとにページをコード分割しています。コンポーネント分割のマイクロ最適化の前に、ルート境界を意味のあるものに保ちます。
- `Lazy` プレフィックスを使用して非重要コンポーネントを動的にインポートします。
- UI が実際に必要になるまでチャンクが読み込まれないよう、`v-if` で遅延コンポーネントを条件付きレンダリングします。
- ファーストビュー外や非重要なインタラクティブ UI には遅延ハイドレーションを使用します。

```vue
<template>
  <LazyRecommendations v-if="showRecommendations" />
  <LazyProductGallery hydrate-on-visible />
</template>
```

- カスタム戦略には、visibility または idle 戦略を持つ `defineLazyHydrationComponent()` を使用します。
- Nuxt の遅延ハイドレーションはシングルファイルコンポーネントで動作します。遅延ハイドレーションされたコンポーネントに新しい props を渡すと、すぐにハイドレーションがトリガーされます。
- 内部ナビゲーションには `NuxtLink` を使用して、Nuxt がルートコンポーネントと生成されたペイロードをプリフェッチできるようにします。

## レビューチェックリスト

- 最初の SSR レンダリングとハイドレーション後のクライアントレンダリングが同じマークアップを生成すること
- ページデータがトップレベルの `$fetch` ではなく `useFetch` または `useAsyncData` を使用していること
- 非重要データが遅延読み込みされ、明示的なローディング UI があること
- ルートルールがページの SEO と鮮度要件に合致していること
- 重いインタラクティブアイランドが遅延読み込みまたは遅延ハイドレーションされていること
