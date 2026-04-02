# コードマップ更新

コードベース構造を分析し、トークン効率の良いアーキテクチャドキュメントを生成します。

## ステップ 1: プロジェクト構造のスキャン

1. プロジェクトタイプを特定（モノレポ、単一アプリ、ライブラリ、マイクロサービス）
2. すべてのソースディレクトリを検索（src/、lib/、app/、packages/）
3. エントリーポイントをマッピング（main.ts、index.ts、app.py、main.goなど）

## ステップ 2: コードマップの生成

`docs/CODEMAPS/`（または `.reports/codemaps/`）にコードマップを作成または更新:

| ファイル | 内容 |
|---------|------|
| `architecture.md` | 高レベルシステム図、サービス境界、データフロー |
| `backend.md` | APIルート、ミドルウェアチェーン、サービス → リポジトリマッピング |
| `frontend.md` | ページツリー、コンポーネント階層、状態管理フロー |
| `data.md` | データベーステーブル、リレーションシップ、マイグレーション履歴 |
| `dependencies.md` | 外部サービス、サードパーティ統合、共有ライブラリ |

### コードマップフォーマット

各コードマップはトークン効率が良いもの — AIコンテキスト消費に最適化:

```markdown
# Backend Architecture

## Routes
POST /api/users → UserController.create → UserService.create → UserRepo.insert
GET  /api/users/:id → UserController.get → UserService.findById → UserRepo.findById

## Key Files
src/services/user.ts (business logic, 120 lines)
src/repos/user.ts (database access, 80 lines)

## Dependencies
- PostgreSQL (primary data store)
- Redis (session cache, rate limiting)
- Stripe (payment processing)
```

## ステップ 3: 差分検出

1. 以前のコードマップが存在する場合、差分率を計算
2. 変更が30%超の場合、差分を表示し上書き前にユーザー承認を要求
3. 変更が30%以下の場合、その場で更新

## ステップ 4: メタデータの追加

各コードマップに鮮度ヘッダーを追加:

```markdown
<!-- Generated: 2026-02-11 | Files scanned: 142 | Token estimate: ~800 -->
```

## ステップ 5: 分析レポートの保存

`.reports/codemap-diff.txt` にサマリーを書き込み:
- 前回スキャン以降に追加/削除/変更されたファイル
- 新しく検出された依存関係
- アーキテクチャの変更（新しいルート、新しいサービスなど）
- 90日以上更新されていないドキュメントの古さ警告

## ヒント

- 実装詳細ではなく**高レベル構造**に焦点
- 完全なコードブロックよりも**ファイルパスと関数シグネチャ**を優先
- 効率的なコンテキスト読み込みのために各コードマップを**1000トークン以下**に抑える
- 冗長な説明の代わりにASCII図をデータフローに使用
- 主要な機能追加やリファクタリングセッションの後に実行
