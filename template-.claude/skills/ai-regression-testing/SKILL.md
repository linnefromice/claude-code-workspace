---
name: ai-regression-testing
description: Regression testing strategies for AI-assisted development. Sandbox-mode API testing without database dependencies, automated bug-check workflows, and patterns to catch AI blind spots where the same model writes and reviews code.
origin: ECC
---

# AI Regression Testing

AI 支援開発のために特別に設計されたテストパターンです。同じモデルがコードを書いてレビューする場合、自動テストでしか検出できない体系的な盲点が生まれます。

## 起動条件

- AI エージェント（Claude Code、Cursor、Codex）が API ルートやバックエンドロジックを変更した場合
- バグが発見・修正され、再発を防止する必要がある場合
- プロジェクトに DB 不要のテストに活用できる sandbox/mock モードがある場合
- コード変更後に `/bug-check` や類似のレビューコマンドを実行する場合
- 複数のコードパスが存在する場合（sandbox vs 本番、フィーチャーフラグなど）

## 根本的な問題

AI がコードを書き、その後自分の作業をレビューする場合、両方のステップに同じ前提が持ち込まれます。これにより予測可能な失敗パターンが生まれます:

```
AI が修正を書く → AI が修正をレビュー → AI が「正しく見える」と判断 → バグは残ったまま
```

**実際の事例**（本番環境で観察）:

```
修正1: API レスポンスに notification_settings を追加
  → SELECT クエリへの追加を忘れた
  → AI がレビューしたが見逃した（同じ盲点）

修正2: SELECT クエリに追加
  → TypeScript ビルドエラー（生成された型にカラムがない）
  → AI が修正1をレビューしたが SELECT の問題を見逃した

修正3: SELECT * に変更
  → 本番パスは修正、sandbox パスを忘れた
  → AI がレビューしたが再び見逃した（4回目の発生）

修正4: テストが最初の実行で即座に検出 PASS:
```

このパターン: **sandbox/本番パスの不一致** が AI が導入するリグレッションの第1位です。

## Sandbox モード API テスト

AI フレンドリーなアーキテクチャを持つほとんどのプロジェクトには sandbox/mock モードがあります。これが高速で DB 不要の API テストの鍵です。

### セットアップ (Vitest + Next.js App Router)

```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config";
import path from "path";

export default defineConfig({
  test: {
    environment: "node",
    globals: true,
    include: ["__tests__/**/*.test.ts"],
    setupFiles: ["__tests__/setup.ts"],
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "."),
    },
  },
});
```

```typescript
// __tests__/setup.ts
// Sandbox モードを強制 — データベース不要
process.env.SANDBOX_MODE = "true";
process.env.NEXT_PUBLIC_SUPABASE_URL = "";
process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "";
```

### Next.js API ルート用テストヘルパー

```typescript
// __tests__/helpers.ts
import { NextRequest } from "next/server";

export function createTestRequest(
  url: string,
  options?: {
    method?: string;
    body?: Record<string, unknown>;
    headers?: Record<string, string>;
    sandboxUserId?: string;
  },
): NextRequest {
  const { method = "GET", body, headers = {}, sandboxUserId } = options || {};
  const fullUrl = url.startsWith("http") ? url : `http://localhost:3000${url}`;
  const reqHeaders: Record<string, string> = { ...headers };

  if (sandboxUserId) {
    reqHeaders["x-sandbox-user-id"] = sandboxUserId;
  }

  const init: { method: string; headers: Record<string, string>; body?: string } = {
    method,
    headers: reqHeaders,
  };

  if (body) {
    init.body = JSON.stringify(body);
    reqHeaders["content-type"] = "application/json";
  }

  return new NextRequest(fullUrl, init);
}

export async function parseResponse(response: Response) {
  const json = await response.json();
  return { status: response.status, json };
}
```

### リグレッションテストの書き方

重要な原則: **動作するコードではなく、バグが見つかったコードに対してテストを書きます**。

```typescript
// __tests__/api/user/profile.test.ts
import { describe, it, expect } from "vitest";
import { createTestRequest, parseResponse } from "../../helpers";
import { GET, PATCH } from "@/app/api/user/profile/route";

// コントラクトの定義 — レスポンスに必須のフィールド
const REQUIRED_FIELDS = [
  "id",
  "email",
  "full_name",
  "phone",
  "role",
  "created_at",
  "avatar_url",
  "notification_settings",  // ← バグで欠落していたことが発見された後に追加
];

describe("GET /api/user/profile", () => {
  it("returns all required fields", async () => {
    const req = createTestRequest("/api/user/profile");
    const res = await GET(req);
    const { status, json } = await parseResponse(res);

    expect(status).toBe(200);
    for (const field of REQUIRED_FIELDS) {
      expect(json.data).toHaveProperty(field);
    }
  });

  // リグレッションテスト — まさにこのバグが AI によって4回導入された
  it("notification_settings is not undefined (BUG-R1 regression)", async () => {
    const req = createTestRequest("/api/user/profile");
    const res = await GET(req);
    const { json } = await parseResponse(res);

    expect("notification_settings" in json.data).toBe(true);
    const ns = json.data.notification_settings;
    expect(ns === null || typeof ns === "object").toBe(true);
  });
});
```

### Sandbox/本番のパリティテスト

最も一般的な AI リグレッション: 本番パスを修正したが sandbox パスを忘れる（またはその逆）。

```typescript
// sandbox のレスポンスが期待されるコントラクトに一致することをテスト
describe("GET /api/user/messages (conversation list)", () => {
  it("includes partner_name in sandbox mode", async () => {
    const req = createTestRequest("/api/user/messages", {
      sandboxUserId: "user-001",
    });
    const res = await GET(req);
    const { json } = await parseResponse(res);

    // partner_name が本番パスには追加されたが
    // sandbox パスには追加されていなかったバグを検出
    if (json.data.length > 0) {
      for (const conv of json.data) {
        expect("partner_name" in conv).toBe(true);
      }
    }
  });
});
```

## テストをバグチェックワークフローに統合する

### カスタムコマンド定義

```markdown
<!-- .claude/commands/bug-check.md -->
# Bug Check

## Step 1: 自動テスト（必須、スキップ不可）

コードレビューの前に、まずこれらのコマンドを実行:

    npm run test       # Vitest テストスイート
    npm run build      # TypeScript 型チェック + ビルド

- テストが失敗 → 最優先バグとして報告
- ビルドが失敗 → 型エラーを最優先として報告
- 両方パスした場合のみ Step 2 に進む

## Step 2: コードレビュー（AI レビュー）

1. Sandbox / 本番パスの一貫性
2. API レスポンスの形状がフロントエンドの期待と一致しているか
3. SELECT 句の完全性
4. ロールバック付きエラーハンドリング
5. 楽観的更新の競合状態

## Step 3: 修正されたバグごとにリグレッションテストを提案
```

### ワークフロー

```
User: "バグチェックして" (or "/bug-check")
  │
  ├─ Step 1: npm run test
  │   ├─ FAIL → バグを機械的に発見（AI の判断不要）
  │   └─ PASS → 続行
  │
  ├─ Step 2: npm run build
  │   ├─ FAIL → 型エラーを機械的に発見
  │   └─ PASS → 続行
  │
  ├─ Step 3: AI コードレビュー（既知の盲点を念頭に）
  │   └─ 発見事項を報告
  │
  └─ Step 4: 各修正に対してリグレッションテストを作成
      └─ 次のバグチェックで修正が壊れたら検出
```

## AI リグレッションの一般的なパターン

### パターン 1: Sandbox/本番パスの不一致

**頻度**: 最も一般的（4件中3件のリグレッションで観察）

```typescript
// FAIL: AI が本番パスにのみフィールドを追加
if (isSandboxMode()) {
  return { data: { id, email, name } };  // 新しいフィールドが欠落
}
// 本番パス
return { data: { id, email, name, notification_settings } };

// PASS: 両方のパスが同じ形状を返す必要がある
if (isSandboxMode()) {
  return { data: { id, email, name, notification_settings: null } };
}
return { data: { id, email, name, notification_settings } };
```

**検出するテスト**:

```typescript
it("sandbox and production return same fields", async () => {
  // テスト環境では sandbox モードが強制的に ON
  const res = await GET(createTestRequest("/api/user/profile"));
  const { json } = await parseResponse(res);

  for (const field of REQUIRED_FIELDS) {
    expect(json.data).toHaveProperty(field);
  }
});
```

### パターン 2: SELECT 句の省略

**頻度**: Supabase/Prisma で新しいカラムを追加する際によくある

```typescript
// FAIL: レスポンスに新しいカラムが追加されたが SELECT には含まれていない
const { data } = await supabase
  .from("users")
  .select("id, email, name")  // notification_settings がない
  .single();

return { data: { ...data, notification_settings: data.notification_settings } };
// → notification_settings は常に undefined

// PASS: SELECT * を使用するか、新しいカラムを明示的に含める
const { data } = await supabase
  .from("users")
  .select("*")
  .single();
```

### パターン 3: エラー状態の漏洩

**頻度**: 中程度 — 既存コンポーネントにエラーハンドリングを追加する場合

```typescript
// FAIL: エラー状態が設定されるが古いデータがクリアされない
catch (err) {
  setError("Failed to load");
  // reservations は前のタブのデータを表示したまま！
}

// PASS: エラー時に関連する状態をクリア
catch (err) {
  setReservations([]);  // 古いデータをクリア
  setError("Failed to load");
}
```

### パターン 4: 適切なロールバックのない楽観的更新

```typescript
// FAIL: 失敗時のロールバックがない
const handleRemove = async (id: string) => {
  setItems(prev => prev.filter(i => i.id !== id));
  await fetch(`/api/items/${id}`, { method: "DELETE" });
  // API が失敗した場合、UI からは消えているが DB にはまだ存在
};

// PASS: 以前の状態を保持し、失敗時にロールバック
const handleRemove = async (id: string) => {
  const prevItems = [...items];
  setItems(prev => prev.filter(i => i.id !== id));
  try {
    const res = await fetch(`/api/items/${id}`, { method: "DELETE" });
    if (!res.ok) throw new Error("API error");
  } catch {
    setItems(prevItems);  // ロールバック
    alert("削除に失敗しました");
  }
};
```

## 戦略: バグが見つかった場所にテストを書く

100% カバレッジを目指すのではなく、以下のようにします:

```
/api/user/profile でバグ発見     → profile API のテストを作成
/api/user/messages でバグ発見    → messages API のテストを作成
/api/user/favorites でバグ発見   → favorites API のテストを作成
/api/user/notifications はバグなし  → テストは書かない（まだ）
```

**AI 開発でこれが有効な理由:**

1. AI は **同じカテゴリの間違い** を繰り返し犯す傾向がある
2. バグは複雑な領域（認証、マルチパスロジック、状態管理）に集中する
3. テストされれば、その正確なリグレッションは **二度と発生しない**
4. テスト数はバグ修正に伴い自然に増加する — 無駄な労力がない

## クイックリファレンス

| AI リグレッションパターン | テスト戦略 | 優先度 |
|---|---|---|
| Sandbox/本番の不一致 | sandbox モードで同じレスポンス形状をアサート | 高 |
| SELECT 句の省略 | レスポンスの必須フィールドをすべてアサート | 高 |
| エラー状態の漏洩 | エラー時の状態クリーンアップをアサート | 中 |
| ロールバックの欠如 | API 失敗時の状態復元をアサート | 中 |
| 型キャストによる null マスキング | フィールドが undefined でないことをアサート | 中 |

## DO / DON'T

**DO:**
- バグ発見後すぐにテストを書く（可能であれば修正前に）
- 実装ではなく API レスポンスの形状をテストする
- すべてのバグチェックの最初のステップとしてテストを実行する
- テストを高速に保つ（sandbox モードで合計1秒未満）
- テストに防止するバグの名前を付ける（例: "BUG-R1 regression"）

**DON'T:**
- バグが一度も発生していないコードのテストを書く
- 自動テストの代わりに AI のセルフレビューを信頼する
- 「ただのモックデータだから」と sandbox パスのテストをスキップする
- ユニットテストで十分な場合にインテグレーションテストを書く
- カバレッジ率を目指す — リグレッション防止を目指す
