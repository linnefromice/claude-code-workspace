> このファイルは [common/security.md](../common/security.md) を Web 固有のセキュリティ内容で拡張します。

# Web セキュリティルール

## Content Security Policy

本番では必ず CSP を設定してください。

### Nonce ベースの CSP

`'unsafe-inline'` の代わりに、スクリプトにはリクエストごとの nonce を使用してください。

```text
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{RANDOM}' https://cdn.jsdelivr.net;
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  img-src 'self' data: https:;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://*.example.com;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
```

オリジンはプロジェクトに合わせて調整してください。このブロックをそのまま流用（cargo-cult）しないでください。

## XSS 対策

- サニタイズされていない HTML を注入しない
- サニタイズしない限り `innerHTML` / `dangerouslySetInnerHTML` を避ける
- 動的なテンプレート値はエスケープする
- どうしても必要な場合は、検証済みのローカルサニタイザでユーザー HTML をサニタイズする

## サードパーティスクリプト

- 非同期でロードする
- CDN から配信する場合は SRI を使用する
- 四半期ごとに監査する
- 実用的な場合はクリティカルな依存関係をセルフホストする

## HTTPS とヘッダー

```text
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

## フォーム

- 状態を変更するフォームには CSRF 対策を行う
- サブミッションエンドポイントにはレート制限をかける
- クライアント側とサーバー側の両方で検証する
- 重たい CAPTCHA をデフォルトにするより、honeypot や軽量な anti-abuse 対策を優先する
