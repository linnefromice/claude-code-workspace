---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# TypeScript/JavaScript コーディングスタイル

> このファイルは [common/coding-style.md](../common/coding-style.md) を TypeScript/JavaScript 固有の内容で拡張します。

## 型とインターフェース

型を使用して、パブリック API、共有モデル、コンポーネント props を明示的、読みやすく、再利用可能にします。

### パブリック API

- エクスポートされた関数、共有ユーティリティ、パブリッククラスメソッドにはパラメータ型と戻り値の型を追加します
- 明白なローカル変数の型は TypeScript に推論させます
- 繰り返し使用されるインラインオブジェクト形状は、名前付き型またはインターフェースに抽出します

```typescript
// 誤り: 明示的な型のないエクスポート関数
export function formatUser(user) {
  return `${user.firstName} ${user.lastName}`
}

// 正解: パブリック API に明示的な型を指定
interface User {
  firstName: string
  lastName: string
}

export function formatUser(user: User): string {
  return `${user.firstName} ${user.lastName}`
}
```

### インターフェース vs 型エイリアス

- 拡張または実装される可能性のあるオブジェクト形状には `interface` を使用します
- ユニオン、インターセクション、タプル、マップ型、ユーティリティ型には `type` を使用します
- 相互運用性のために `enum` が必要でない限り、`enum` よりも文字列リテラルユニオンを優先します

```typescript
interface User {
  id: string
  email: string
}

type UserRole = 'admin' | 'member'
type UserWithRole = User & {
  role: UserRole
}
```

### `any` の回避

- アプリケーションコードでは `any` を避けます
- 外部または信頼できない入力には `unknown` を使用し、安全にナローイングします
- 値の型が呼び出し元に依存する場合はジェネリクスを使用します

```typescript
// 誤り: any は型安全性を排除する
function getErrorMessage(error: any) {
  return error.message
}

// 正解: unknown は安全なナローイングを強制する
function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }

  return 'Unexpected error'
}
```

### React Props

- コンポーネント props は名前付き `interface` または `type` で定義します
- コールバック props は明示的に型指定します
- 特別な理由がない限り `React.FC` は使用しません

```typescript
interface User {
  id: string
  email: string
}

interface UserCardProps {
  user: User
  onSelect: (id: string) => void
}

function UserCard({ user, onSelect }: UserCardProps) {
  return <button onClick={() => onSelect(user.id)}>{user.email}</button>
}
```

### JavaScript ファイル

- `.js` および `.jsx` ファイルでは、型が明確さを向上させ、TypeScript 移行が実用的でない場合に JSDoc を使用します
- JSDoc をランタイムの動作と整合させます

```javascript
/**
 * @param {{ firstName: string, lastName: string }} user
 * @returns {string}
 */
export function formatUser(user) {
  return `${user.firstName} ${user.lastName}`
}
```

## イミュータビリティ

スプレッド演算子を使用してイミュータブルな更新を行います：

```typescript
interface User {
  id: string
  name: string
}

// 誤り: ミューテーション
function updateUser(user: User, name: string): User {
  user.name = name // ミューテーション！
  return user
}

// 正解: イミュータビリティ
function updateUser(user: Readonly<User>, name: string): User {
  return {
    ...user,
    name
  }
}
```

## エラーハンドリング

async/await と try-catch を使用し、unknown エラーを安全にナローイングします：

```typescript
interface User {
  id: string
  email: string
}

declare function riskyOperation(userId: string): Promise<User>

function getErrorMessage(error: unknown): string {
  if (error instanceof Error) {
    return error.message
  }

  return 'Unexpected error'
}

const logger = {
  error: (message: string, error: unknown) => {
    // プロダクション用ロガー（例: pino や winston）に置き換えてください。
  }
}

async function loadUser(userId: string): Promise<User> {
  try {
    const result = await riskyOperation(userId)
    return result
  } catch (error: unknown) {
    logger.error('Operation failed', error)
    throw new Error(getErrorMessage(error))
  }
}
```

## 入力バリデーション

スキーマベースのバリデーションには Zod を使用し、スキーマから型を推論します：

```typescript
import { z } from 'zod'

const userSchema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

type UserInput = z.infer<typeof userSchema>

const validated: UserInput = userSchema.parse(input)
```

## Console.log

- プロダクションコードに `console.log` 文を残さない
- 代わりに適切なロギングライブラリを使用
- 自動検出についてはフックを参照
