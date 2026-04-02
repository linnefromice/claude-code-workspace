---
name: bun-runtime
description: Bun as runtime, package manager, bundler, and test runner. When to choose Bun vs Node, migration notes, and Vercel support.
origin: ECC
---

# Bun Runtime

Bun は高速なオールインワン JavaScript ランタイム兼ツールキットです。ランタイム、パッケージマネージャー、バンドラー、テストランナーを一体化しています。

## 使用タイミング

- **Bun を推奨**: 新規 JS/TS プロジェクト、インストール/実行速度が重要なスクリプト、Bun ランタイムでの Vercel デプロイ、単一ツールチェーン（実行＋インストール＋テスト＋ビルド）が必要な場合。
- **Node を推奨**: 最大限のエコシステム互換性、Node を前提としたレガシーツーリング、依存関係に既知の Bun 問題がある場合。

Bun の採用時、Node からの移行時、Bun スクリプト/テストの作成・デバッグ時、Vercel やその他のプラットフォームでの Bun 設定時に使用してください。

## 仕組み

- **ランタイム**: Node 互換のドロップインランタイム（JavaScriptCore 上に構築、Zig で実装）。
- **パッケージマネージャー**: `bun install` は npm/yarn よりも大幅に高速です。ロックファイルは現在の Bun ではデフォルトで `bun.lock`（テキスト形式）です。古いバージョンでは `bun.lockb`（バイナリ形式）が使用されていました。
- **バンドラー**: アプリとライブラリ向けの組み込みバンドラーおよびトランスパイラ。
- **テストランナー**: Jest ライクな API を持つ組み込みの `bun test`。

**Node からの移行**: `node script.js` を `bun run script.js` または `bun script.js` に置き換えます。`npm install` の代わりに `bun install` を実行します。ほとんどのパッケージは動作します。npm スクリプトには `bun run` を、npx スタイルの一回限りの実行には `bun x` を使用します。Node の組み込みモジュールはサポートされています。パフォーマンス向上のため、Bun API が存在する場合はそちらを優先してください。

**Vercel**: プロジェクト設定でランタイムを Bun に設定します。ビルド: `bun run build` または `bun build ./src/index.ts --outdir=dist`。インストール: 再現可能なデプロイのために `bun install --frozen-lockfile` を使用します。

## 例

### 実行とインストール

```bash
# 依存関係のインストール（bun.lock または bun.lockb を作成/更新）
bun install

# スクリプトまたはファイルの実行
bun run dev
bun run src/index.ts
bun src/index.ts
```

### スクリプトと環境変数

```bash
bun run --env-file=.env dev
FOO=bar bun run script.ts
```

### テスト

```bash
bun test
bun test --watch
```

```typescript
// test/example.test.ts
import { expect, test } from "bun:test";

test("add", () => {
  expect(1 + 2).toBe(3);
});
```

### Runtime API

```typescript
const file = Bun.file("package.json");
const json = await file.json();

Bun.serve({
  port: 3000,
  fetch(req) {
    return new Response("Hello");
  },
});
```

## ベストプラクティス

- 再現可能なインストールのためにロックファイル（`bun.lock` または `bun.lockb`）をコミットしてください。
- スクリプトには `bun run` を使用してください。TypeScript の場合、Bun は `.ts` をネイティブに実行します。
- 依存関係を最新に保ってください。Bun とエコシステムは急速に進化しています。
