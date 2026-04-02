---
name: browser-qa
description: Use this skill to automate visual testing and UI interaction verification using browser automation after deploying features.
origin: ECC
---

# Browser QA — 自動ビジュアルテストとインタラクション検証

## 使用タイミング

- ステージング/プレビューに機能をデプロイした後
- 複数ページにわたる UI の動作を検証する必要がある場合
- リリース前にレイアウト、フォーム、インタラクションが実際に動作するか確認する場合
- フロントエンドコードに関わる PR をレビューする場合
- アクセシビリティ監査とレスポンシブテスト

## 仕組み

ブラウザ自動化 MCP（claude-in-chrome、Playwright、または Puppeteer）を使用して、実際のユーザーのようにライブページを操作します。

### フェーズ 1: Smoke Test
```
1. ターゲット URL に遷移
2. コンソールエラーをチェック（アナリティクス、サードパーティのノイズをフィルタリング）
3. ネットワークリクエストに 4xx/5xx がないか検証
4. デスクトップ＋モバイルビューポートでファーストビューをスクリーンショット
5. Core Web Vitals をチェック: LCP < 2.5s、CLS < 0.1、INP < 200ms
```

### フェーズ 2: Interaction Test
```
1. すべてのナビゲーションリンクをクリック — デッドリンクがないか検証
2. 有効なデータでフォームを送信 — 成功状態を検証
3. 無効なデータでフォームを送信 — エラー状態を検証
4. 認証フローをテスト: ログイン → 保護ページ → ログアウト
5. 重要なユーザージャーニーをテスト（決済、オンボーディング、検索）
```

### フェーズ 3: Visual Regression
```
1. 主要ページを3つのブレークポイント（375px、768px、1440px）でスクリーンショット
2. ベースラインスクリーンショット（保存済みの場合）と比較
3. 5px以上のレイアウトシフト、欠落要素、オーバーフローをフラグ
4. 該当する場合はダークモードもチェック
```

### フェーズ 4: Accessibility
```
1. 各ページで axe-core または同等のツールを実行
2. WCAG AA 違反をフラグ（コントラスト、ラベル、フォーカス順序）
3. キーボードナビゲーションがエンドツーエンドで動作するか検証
4. スクリーンリーダーのランドマークをチェック
```

## 出力 Format

```markdown
## QA Report — [URL] — [timestamp]

### Smoke Test
- Console errors: 0 critical, 2 warnings (analytics noise)
- Network: all 200/304, no failures
- Core Web Vitals: LCP 1.2s ✓, CLS 0.02 ✓, INP 89ms ✓

### Interactions
- [✓] Nav links: 12/12 working
- [✗] Contact form: missing error state for invalid email
- [✓] Auth flow: login/logout working

### Visual
- [✗] Hero section overflows on 375px viewport
- [✓] Dark mode: all pages consistent

### Accessibility
- 2 AA violations: missing alt text on hero image, low contrast on footer links

### Verdict: SHIP WITH FIXES (2 issues, 0 blockers)
```

## 統合

任意のブラウザ MCP で動作します:
- `mChild__claude-in-chrome__*` ツール（推奨 — 実際の Chrome を使用）
- Playwright（`mcp__browserbase__*` 経由）
- 直接 Puppeteer スクリプト

デプロイ後のモニタリングには `/canary-watch` と組み合わせてください。
