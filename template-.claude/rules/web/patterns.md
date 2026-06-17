> このファイルは [common/patterns.md](../common/patterns.md) を Web 固有のパターンで拡張します。

# Web パターン

## コンポーネントコンポジション

### Compound Components

関連する UI で状態とインタラクションのセマンティクスを共有する場合は、compound components を使用してください：

```tsx
<Tabs defaultValue="overview">
  <Tabs.List>
    <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
    <Tabs.Trigger value="settings">Settings</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="overview">...</Tabs.Content>
  <Tabs.Content value="settings">...</Tabs.Content>
</Tabs>
```

- 親が状態を所有する
- 子は context 経由で状態を参照する
- 複雑なウィジェットでは prop drilling よりこのパターンを優先する

### Render Props / Slots

- 振る舞いは共通だがマークアップが異なる場合は、render props や slot パターンを使用する
- キーボードハンドリング、ARIA、フォーカスロジックは headless レイヤーに保持する

### Container / Presentational 分離

- Container コンポーネントはデータロードと副作用を所有する
- Presentational コンポーネントは props を受け取って UI を描画する
- Presentational コンポーネントは純粋であり続けるべき

## 状態管理

以下を別々に扱ってください：

| 関心事 | ツール |
|---------|---------|
| サーバー状態 | TanStack Query、SWR、tRPC |
| クライアント状態 | Zustand、Jotai、signals |
| URL 状態 | search params、route segments |
| フォーム状態 | React Hook Form または同等のもの |

- サーバー状態をクライアントストアに複製しない
- 冗長な計算済み状態を保持するのではなく、派生値として算出する

## URL を状態として扱う

共有可能な状態は URL に永続化してください：
- フィルタ
- ソート順
- ページネーション
- アクティブタブ
- 検索クエリ

## データフェッチング

### Stale-While-Revalidate

- キャッシュされたデータを即座に返す
- バックグラウンドで revalidate する
- 手作りではなく、既存ライブラリを優先する

### Optimistic Updates

- 現在の状態をスナップショットする
- optimistic な更新を適用する
- 失敗時にロールバックする
- ロールバック時は目に見えるエラーフィードバックを出す

### 並列ロード

- 独立したデータは並列にフェッチする
- 親子のリクエストウォーターフォールを避ける
- 正当化できる場合は、次に訪れそうなルートや状態をプリフェッチする
