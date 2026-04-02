---
name: canary-watch
description: Use this skill to monitor a deployed URL for regressions after deploys, merges, or dependency upgrades.
origin: ECC
---

# Canary Watch — デプロイ後モニタリング

## 使用タイミング

- 本番環境またはステージングへのデプロイ後
- リスクの高い PR をマージした後
- 修正が実際に問題を解決したか検証する場合
- ローンチウィンドウ中の継続的なモニタリング
- 依存関係のアップグレード後

## 仕組み

デプロイ済み URL のリグレッションを監視します。停止されるか、監視ウィンドウが期限切れになるまでループで実行されます。

### 監視対象

```
1. HTTP ステータス — ページが 200 を返しているか？
2. コンソールエラー — 以前はなかった新しいエラーが出ていないか？
3. ネットワーク障害 — 失敗した API コール、5xx レスポンスはないか？
4. パフォーマンス — ベースラインと比較して LCP/CLS/INP のリグレッションはないか？
5. コンテンツ — 主要な要素が消えていないか？（h1、nav、footer、CTA）
6. API ヘルス — 重要なエンドポイントが SLA 内で応答しているか？
```

### 監視モード

**Quick check**（デフォルト）: 1回のパスで結果をレポート
```
/canary-watch https://myapp.com
```

**Sustained watch**: N 分ごとに M 時間チェック
```
/canary-watch https://myapp.com --interval 5m --duration 2h
```

**Diff mode**: ステージングと本番を比較
```
/canary-watch --compare https://staging.myapp.com https://myapp.com
```

### Alert Thresholds

```yaml
critical:  # 即時アラート
  - HTTP status != 200
  - コンソールエラー数 > 5（新規エラーのみ）
  - LCP > 4s
  - API エンドポイントが 5xx を返す

warning:   # レポートでフラグ
  - ベースラインから LCP が 500ms 以上増加
  - CLS > 0.1
  - 新しいコンソール警告
  - レスポンスタイムがベースラインの 2 倍以上

info:      # ログのみ
  - 軽微なパフォーマンスの変動
  - 新しいネットワークリクエスト（サードパーティスクリプトが追加された？）
```

### Notifications

クリティカルな閾値を超えた場合:
- デスクトップ通知（macOS/Linux）
- オプション: Slack/Discord webhook
- `~/.claude/canary-watch.log` にログ記録

## 出力

```markdown
## Canary Report — myapp.com — 2026-03-23 03:15 PST

### Status: HEALTHY ✓

| Check | Result | Baseline | Delta |
|-------|--------|----------|-------|
| HTTP | 200 ✓ | 200 | — |
| Console errors | 0 ✓ | 0 | — |
| LCP | 1.8s ✓ | 1.6s | +200ms |
| CLS | 0.01 ✓ | 0.01 | — |
| API /health | 145ms ✓ | 120ms | +25ms |

### No regressions detected. Deploy is clean.
```

## 統合

以下と組み合わせて使用できます:
- `/browser-qa` でデプロイ前の検証
- Hooks: `git push` の PostToolUse フックとして追加し、デプロイ後に自動チェック
- CI: デプロイステップ後に GitHub Actions で実行
