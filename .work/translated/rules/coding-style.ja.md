# コーディングスタイル

## イミュータビリティ（クリティカル）

常に新しいオブジェクトを作成し、絶対にミューテートしない:

```javascript
// 悪い例: ミューテーション
function updateUser(user, name) {
  user.name = name  // ミューテーション！
  return user
}

// 良い例: イミュータビリティ
function updateUser(user, name) {
  return {
    ...user,
    name
  }
}
```

## ファイル構成

少数の大きなファイルより、多数の小さなファイル:
- 高凝集、低結合
- 200-400行が標準、最大800行
- 大きなコンポーネントからユーティリティを抽出
- タイプ別ではなく、機能/ドメイン別に整理

## エラーハンドリング

常にエラーを包括的に処理する:

```typescript
try {
  const result = await riskyOperation()
  return result
} catch (error) {
  console.error('Operation failed:', error)
  throw new Error('詳細でユーザーフレンドリーなメッセージ')
}
```

## 入力バリデーション

常にユーザー入力をバリデートする:

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

## コード品質チェックリスト

作業完了をマークする前に:
- [ ] コードが読みやすく、適切に命名されている
- [ ] 関数が小さい（50行未満）
- [ ] ファイルが焦点を絞っている（800行未満）
- [ ] 深いネストがない（4レベル以下）
- [ ] 適切なエラーハンドリング
- [ ] console.log文がない
- [ ] ハードコードされた値がない
- [ ] ミューテーションがない（イミュータブルパターンを使用）
