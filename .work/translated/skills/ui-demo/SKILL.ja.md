---
name: ui-demo
description: Record polished UI demo videos using Playwright. Use when the user asks to create a demo, walkthrough, screen recording, or tutorial video of a web application. Produces WebM videos with visible cursor, natural pacing, and professional feel.
origin: ECC
---

# UI Demo Video Recorder

Playwright のビデオ録画機能を使用して、注入されたカーソルオーバーレイ、自然なペーシング、ストーリーテリングフローを備えた洗練されたデモビデオを Web アプリケーションから録画します。

## 使用タイミング

- ユーザーが「demo video」「screen recording」「walkthrough」「tutorial」を求めた場合
- ユーザーが機能やワークフローを視覚的にショーケースしたい場合
- ユーザーがドキュメント、オンボーディング、またはステークホルダープレゼンテーション用のビデオが必要な場合

## 3フェーズプロセス

すべてのデモは3つのフェーズを経ます: **Discover -> Rehearse -> Record**。録画に直接進まないでください。

---

## フェーズ 1: Discover

スクリプトを書く前に、ターゲットページを探索して実際に何があるかを理解します。

### なぜ

見ていないものをスクリプト化することはできません。フィールドが `<textarea>` ではなく `<input>` かもしれませんし、ドロップダウンが `<select>` ではなくカスタムコンポーネントかもしれませんし、コメントボックスが `@mentions` や `#tags` をサポートしているかもしれません。仮定は録画をサイレントに壊します。

### 方法

フロー内の各ページに移動し、インタラクティブ要素をダンプします:

```javascript
// デモスクリプトを書く前に、フロー内の各ページでこれを実行
const fields = await page.evaluate(() => {
  const els = [];
  document.querySelectorAll('input, select, textarea, button, [contenteditable]').forEach(el => {
    if (el.offsetParent !== null) {
      els.push({
        tag: el.tagName,
        type: el.type || '',
        name: el.name || '',
        placeholder: el.placeholder || '',
        text: el.textContent?.trim().substring(0, 40) || '',
        contentEditable: el.contentEditable === 'true',
        role: el.getAttribute('role') || '',
      });
    }
  });
  return els;
});
console.log(JSON.stringify(fields, null, 2));
```

### 確認すべきこと

- **フォームフィールド**: `<select>`、`<input>`、カスタムドロップダウン、コンボボックスのどれか？
- **セレクトオプション**: オプションの値とテキストの両方をダンプします。プレースホルダーは `value="0"` や `value=""` を持つことが多く、空でないように見えます。`Array.from(el.options).map(o => ({ value: o.value, text: o.text }))` を使用します。テキストに「Select」が含まれるか、値が `"0"` のオプションはスキップします。
- **リッチテキスト**: コメントボックスは `@mentions`、`#tags`、markdown、絵文字をサポートしていますか？プレースホルダーテキストを確認します。
- **必須フィールド**: どのフィールドがフォーム送信をブロックするか？`required`、ラベル内の `*`、空で送信してバリデーションエラーを確認します。
- **動的コンテンツ**: 他のフィールドが入力された後にフィールドが表示されるか？
- **ボタンラベル**: `"Submit"`、`"Submit Request"`、`"Send"` などの正確なテキスト。
- **テーブルカラムヘッダー**: テーブル駆動のモーダルの場合、すべての数値入力が同じ意味だと仮定せず、各 `input[type="number"]` をカラムヘッダーにマッピングします。

### 出力

各ページのフィールドマップ。スクリプト内で正しいセレクターを書くために使用します。例:

```text
/purchase-requests/new:
  - Budget Code: <select> (first select on page, 4 options)
  - Desired Delivery: <input type="date">
  - Context: <textarea> (not input)
  - BOM table: inline-editable cells with span.cursor-pointer -> input pattern
  - Submit: <button> text="Submit"

/purchase-requests/N (detail):
  - Comment: <input placeholder="Type a message..."> supports @user and #PR tags
  - Send: <button> text="Send" (disabled until input has content)
```

---

## フェーズ 2: Rehearse

録画せずにすべてのステップを実行します。すべてのセレクターが解決されることを確認します。

### なぜ

サイレントなセレクター失敗が、デモ録画が壊れる主な原因です。リハーサルにより、録画を無駄にする前にそれらを検出できます。

### 方法

ログ出力して大声で失敗するラッパー `ensureVisible` を使用します:

```javascript
async function ensureVisible(page, locator, label) {
  const el = typeof locator === 'string' ? page.locator(locator).first() : locator;
  const visible = await el.isVisible().catch(() => false);
  if (!visible) {
    const msg = `REHEARSAL FAIL: "${label}" not found - selector: ${typeof locator === 'string' ? locator : '(locator object)'}`;
    console.error(msg);
    const found = await page.evaluate(() => {
      return Array.from(document.querySelectorAll('button, input, select, textarea, a'))
        .filter(el => el.offsetParent !== null)
        .map(el => `${el.tagName}[${el.type || ''}] "${el.textContent?.trim().substring(0, 30)}"`)
        .join('\n  ');
    });
    console.error('  Visible elements:\n  ' + found);
    return false;
  }
  console.log(`REHEARSAL OK: "${label}"`);
  return true;
}
```

### リハーサルスクリプト構造

```javascript
const steps = [
  { label: 'Login email field', selector: '#email' },
  { label: 'Login submit', selector: 'button[type="submit"]' },
  { label: 'New Request button', selector: 'button:has-text("New Request")' },
  { label: 'Budget Code select', selector: 'select' },
  { label: 'Delivery date', selector: 'input[type="date"]:visible' },
  { label: 'Description field', selector: 'textarea:visible' },
  { label: 'Add Item button', selector: 'button:has-text("Add Item")' },
  { label: 'Submit button', selector: 'button:has-text("Submit")' },
];

let allOk = true;
for (const step of steps) {
  if (!await ensureVisible(page, step.selector, step.label)) {
    allOk = false;
  }
}
if (!allOk) {
  console.error('REHEARSAL FAILED - fix selectors before recording');
  process.exit(1);
}
console.log('REHEARSAL PASSED - all selectors verified');
```

### リハーサル失敗時

1. 表示要素のダンプを読みます。
2. 正しいセレクターを見つけます。
3. スクリプトを更新します。
4. リハーサルを再実行します。
5. すべてのセレクターがパスした場合のみ先に進みます。

---

## フェーズ 3: Record

Discovery と Rehearse がパスした後にのみ録画を作成します。

### 録画の原則

#### 1. ストーリーテリングフロー

ビデオをストーリーとして計画します。ユーザー指定の順序に従うか、以下のデフォルトを使用します:

- **Entry**: ログインまたは開始点へのナビゲーション
- **Context**: 視聴者が状況を把握できるよう周囲をパン
- **Action**: メインワークフローのステップを実行
- **Variation**: 設定、テーマ、ローカライゼーションなどのセカンダリ機能を表示
- **Result**: 結果、確認、または新しいステートを表示

#### 2. ペーシング

- ログイン後: `4s`
- ナビゲーション後: `3s`
- ボタンクリック後: `2s`
- 主要ステップ間: `1.5-2s`
- 最終アクション後: `3s`
- タイピング遅延: 1文字あたり `25-40ms`

#### 3. カーソルオーバーレイ

マウスの動きに追従する SVG 矢印カーソルを注入します:

```javascript
async function injectCursor(page) {
  await page.evaluate(() => {
    if (document.getElementById('demo-cursor')) return;
    const cursor = document.createElement('div');
    cursor.id = 'demo-cursor';
    cursor.innerHTML = `<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M5 3L19 12L12 13L9 20L5 3Z" fill="white" stroke="black" stroke-width="1.5" stroke-linejoin="round"/>
    </svg>`;
    cursor.style.cssText = `
      position: fixed; z-index: 999999; pointer-events: none;
      width: 24px; height: 24px;
      transition: left 0.1s, top 0.1s;
      filter: drop-shadow(1px 1px 2px rgba(0,0,0,0.3));
    `;
    cursor.style.left = '0px';
    cursor.style.top = '0px';
    document.body.appendChild(cursor);
    document.addEventListener('mousemove', (e) => {
      cursor.style.left = e.clientX + 'px';
      cursor.style.top = e.clientY + 'px';
    });
  });
}
```

オーバーレイはナビゲーション時に破棄されるため、ページ遷移後に毎回 `injectCursor(page)` を呼び出してください。

#### 4. マウス移動

カーソルをテレポートさせないでください。クリック前にターゲットまで移動します:

```javascript
async function moveAndClick(page, locator, label, opts = {}) {
  const { postClickDelay = 800, ...clickOpts } = opts;
  const el = typeof locator === 'string' ? page.locator(locator).first() : locator;
  const visible = await el.isVisible().catch(() => false);
  if (!visible) {
    console.error(`WARNING: moveAndClick skipped - "${label}" not visible`);
    return false;
  }
  try {
    await el.scrollIntoViewIfNeeded();
    await page.waitForTimeout(300);
    const box = await el.boundingBox();
    if (box) {
      await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 10 });
      await page.waitForTimeout(400);
    }
    await el.click(clickOpts);
  } catch (e) {
    console.error(`WARNING: moveAndClick failed on "${label}": ${e.message}`);
    return false;
  }
  await page.waitForTimeout(postClickDelay);
  return true;
}
```

すべての呼び出しにデバッグ用の説明的な `label` を含めてください。

#### 5. タイピング

即時入力ではなく、視覚的にタイプします:

```javascript
async function typeSlowly(page, locator, text, label, charDelay = 35) {
  const el = typeof locator === 'string' ? page.locator(locator).first() : locator;
  const visible = await el.isVisible().catch(() => false);
  if (!visible) {
    console.error(`WARNING: typeSlowly skipped - "${label}" not visible`);
    return false;
  }
  await moveAndClick(page, el, label);
  await el.fill('');
  await el.pressSequentially(text, { delay: charDelay });
  await page.waitForTimeout(500);
  return true;
}
```

#### 6. スクロール

ジャンプではなくスムーズスクロールを使用します:

```javascript
await page.evaluate(() => window.scrollTo({ top: 400, behavior: 'smooth' }));
await page.waitForTimeout(1500);
```

#### 7. ダッシュボードパン

ダッシュボードや概要ページを表示する際、主要要素にカーソルを動かします:

```javascript
async function panElements(page, selector, maxCount = 6) {
  const elements = await page.locator(selector).all();
  for (let i = 0; i < Math.min(elements.length, maxCount); i++) {
    try {
      const box = await elements[i].boundingBox();
      if (box && box.y < 700) {
        await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 8 });
        await page.waitForTimeout(600);
      }
    } catch (e) {
      console.warn(`WARNING: panElements skipped element ${i} (selector: "${selector}"): ${e.message}`);
    }
  }
}
```

#### 8. 字幕

ビューポートの下部に字幕バーを注入します:

```javascript
async function injectSubtitleBar(page) {
  await page.evaluate(() => {
    if (document.getElementById('demo-subtitle')) return;
    const bar = document.createElement('div');
    bar.id = 'demo-subtitle';
    bar.style.cssText = `
      position: fixed; bottom: 0; left: 0; right: 0; z-index: 999998;
      text-align: center; padding: 12px 24px;
      background: rgba(0, 0, 0, 0.75);
      color: white; font-family: -apple-system, "Segoe UI", sans-serif;
      font-size: 16px; font-weight: 500; letter-spacing: 0.3px;
      transition: opacity 0.3s;
      pointer-events: none;
    `;
    bar.textContent = '';
    bar.style.opacity = '0';
    document.body.appendChild(bar);
  });
}

async function showSubtitle(page, text) {
  await page.evaluate((t) => {
    const bar = document.getElementById('demo-subtitle');
    if (!bar) return;
    if (t) {
      bar.textContent = t;
      bar.style.opacity = '1';
    } else {
      bar.style.opacity = '0';
    }
  }, text);
  if (text) await page.waitForTimeout(800);
}
```

ナビゲーション後に `injectCursor(page)` と合わせて `injectSubtitleBar(page)` を呼び出します。

使用パターン:

```javascript
await showSubtitle(page, 'Step 1 - Logging in');
await showSubtitle(page, 'Step 2 - Dashboard overview');
await showSubtitle(page, '');
```

ガイドライン:

- 字幕テキストは短く、できれば60文字以内にします。
- 一貫性のために `Step N - Action` フォーマットを使用します。
- UI 自体が語れる長い停止中は字幕をクリアします。

## スクリプトテンプレート

```javascript
'use strict';
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const BASE_URL = process.env.QA_BASE_URL || 'http://localhost:3000';
const VIDEO_DIR = path.join(__dirname, 'screenshots');
const OUTPUT_NAME = 'demo-FEATURE.webm';
const REHEARSAL = process.argv.includes('--rehearse');

// injectCursor、injectSubtitleBar、showSubtitle、moveAndClick、
// typeSlowly、ensureVisible、panElements をここに貼り付けます。

(async () => {
  const browser = await chromium.launch({ headless: true });

  if (REHEARSAL) {
    const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
    const page = await context.newPage();
    // フローを通してナビゲートし、各セレクターに対して ensureVisible を実行します。
    await browser.close();
    return;
  }

  const context = await browser.newContext({
    recordVideo: { dir: VIDEO_DIR, size: { width: 1280, height: 720 } },
    viewport: { width: 1280, height: 720 }
  });
  const page = await context.newPage();

  try {
    await injectCursor(page);
    await injectSubtitleBar(page);

    await showSubtitle(page, 'Step 1 - Logging in');
    // ログインアクション

    await page.goto(`${BASE_URL}/dashboard`);
    await injectCursor(page);
    await injectSubtitleBar(page);
    await showSubtitle(page, 'Step 2 - Dashboard overview');
    // ダッシュボードパン

    await showSubtitle(page, 'Step 3 - Main workflow');
    // アクションシーケンス

    await showSubtitle(page, 'Step 4 - Result');
    // 最終結果の表示
    await showSubtitle(page, '');
  } catch (err) {
    console.error('DEMO ERROR:', err.message);
  } finally {
    await context.close();
    const video = page.video();
    if (video) {
      const src = await video.path();
      const dest = path.join(VIDEO_DIR, OUTPUT_NAME);
      try {
        fs.copyFileSync(src, dest);
        console.log('Video saved:', dest);
      } catch (e) {
        console.error('ERROR: Failed to copy video:', e.message);
        console.error('  Source:', src);
        console.error('  Destination:', dest);
      }
    }
    await browser.close();
  }
})();
```

使い方:

```bash
# フェーズ 2: リハーサル
node demo-script.cjs --rehearse

# フェーズ 3: 録画
node demo-script.cjs
```

## 録画前チェックリスト

- [ ] Discovery フェーズ完了
- [ ] リハーサルがすべてのセレクター OK でパス
- [ ] ヘッドレスモードが有効
- [ ] 解像度が `1280x720` に設定
- [ ] カーソルと字幕オーバーレイがナビゲーション後に毎回再注入されている
- [ ] 主要な遷移で `showSubtitle(page, 'Step N - ...')` が使用されている
- [ ] すべてのクリックに説明的なラベル付きの `moveAndClick` が使用されている
- [ ] 可視入力に `typeSlowly` が使用されている
- [ ] サイレントキャッチなし; ヘルパーが警告をログ出力
- [ ] コンテンツ表示にスムーズスクロールが使用されている
- [ ] キーとなる停止が人間の視聴者に見える
- [ ] フローがリクエストされたストーリー順序に一致
- [ ] スクリプトがフェーズ 1 で発見された実際の UI を反映

## よくある落とし穴

1. ナビゲーション後にカーソルが消える - 再注入してください。
2. ビデオが速すぎる - 停止を追加してください。
3. カーソルが矢印ではなくドットになる - SVG オーバーレイを使用してください。
4. カーソルがテレポートする - クリック前に移動してください。
5. セレクトドロップダウンの見た目がおかしい - 移動を見せてからオプションを選択してください。
6. モーダルが唐突に感じる - 確認前に読み取り停止を追加してください。
7. ビデオファイルパスがランダム - 安定した出力名にコピーしてください。
8. セレクター失敗が握りつぶされる - サイレントキャッチブロックは使用しないでください。
9. フィールドタイプが仮定されている - まず Discovery してください。
10. 機能が仮定されている - スクリプト作成前に実際の UI を調査してください。
11. プレースホルダーのセレクト値が本物に見える - `"0"` や `"Select..."` に注意してください。
12. ポップアップが別のビデオを作成する - ポップアップページを明示的にキャプチャし、必要に応じて後でマージしてください。
