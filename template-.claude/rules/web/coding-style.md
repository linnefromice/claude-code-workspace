> このファイルは [common/coding-style.md](../common/coding-style.md) を Web 固有のフロントエンド内容で拡張します。

# Web コーディングスタイル

## ファイル構成

ファイル種別ではなく、機能や領域（surface area）ごとに整理してください：

```text
src/
├── components/
│   ├── hero/
│   │   ├── Hero.tsx
│   │   ├── HeroVisual.tsx
│   │   └── hero.css
│   ├── scrolly-section/
│   │   ├── ScrollySection.tsx
│   │   ├── StickyVisual.tsx
│   │   └── scrolly.css
│   └── ui/
│       ├── Button.tsx
│       ├── SurfaceCard.tsx
│       └── AnimatedText.tsx
├── hooks/
│   ├── useReducedMotion.ts
│   └── useScrollProgress.ts
├── lib/
│   ├── animation.ts
│   └── color.ts
└── styles/
    ├── tokens.css
    ├── typography.css
    └── global.css
```

## CSS カスタムプロパティ

デザイントークンは変数として定義してください。パレット、タイポグラフィ、スペーシングを繰り返しハードコードしないでください：

```css
:root {
  --color-surface: oklch(98% 0 0);
  --color-text: oklch(18% 0 0);
  --color-accent: oklch(68% 0.21 250);

  --text-base: clamp(1rem, 0.92rem + 0.4vw, 1.125rem);
  --text-hero: clamp(3rem, 1rem + 7vw, 8rem);

  --space-section: clamp(4rem, 3rem + 5vw, 10rem);

  --duration-fast: 150ms;
  --duration-normal: 300ms;
  --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
}
```

## アニメーション専用プロパティ

コンポジタフレンドリーな動きを優先してください：
- `transform`
- `opacity`
- `clip-path`
- `filter`（控えめに）

レイアウトに関わるプロパティのアニメーションは避けてください：
- `width`
- `height`
- `top`
- `left`
- `margin`
- `padding`
- `border`
- `font-size`

## セマンティック HTML ファースト

```html
<header>
  <nav aria-label="Main navigation">...</nav>
</header>
<main>
  <section aria-labelledby="hero-heading">
    <h1 id="hero-heading">...</h1>
  </section>
</main>
<footer>...</footer>
```

セマンティック要素が存在する場面では、汎用ラッパーの `div` を積み重ねないでください。

## 命名

- コンポーネント: PascalCase（`ScrollySection`、`SurfaceCard`）
- フック: `use` プレフィックス（`useReducedMotion`）
- CSS クラス: kebab-case またはユーティリティクラス
- アニメーションタイムライン: 意図を表す camelCase（`heroRevealTl`）
