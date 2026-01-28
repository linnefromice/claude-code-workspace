---
name: eval-harness
description: Formal evaluation framework for Claude Code sessions implementing eval-driven development (EDD) principles
tools: Read, Write, Edit, Bash, Grep, Glob
---

# Evalハーネススキル

eval駆動開発（EDD）原則を実装するClaude Codeセッション用の正式な評価フレームワーク。

## 哲学

Eval駆動開発はevalを「AI開発のユニットテスト」として扱う:
- 実装前に期待される動作を定義
- 開発中にevalを継続的に実行
- 各変更でリグレッションを追跡
- 信頼性測定にpass@kメトリクスを使用

## Evalタイプ

### Capability Eval
Claudeが以前できなかったことができるようになったかテスト:
```markdown
[CAPABILITY EVAL: feature-name]
タスク: Claudeが達成すべきことの説明
成功基準:
  - [ ] 基準1
  - [ ] 基準2
  - [ ] 基準3
期待出力: 期待される結果の説明
```

### Regression Eval
変更が既存機能を壊さないことを確認:
```markdown
[REGRESSION EVAL: feature-name]
ベースライン: SHAまたはチェックポイント名
テスト:
  - existing-test-1: PASS/FAIL
  - existing-test-2: PASS/FAIL
  - existing-test-3: PASS/FAIL
結果: X/Y 合格（以前はY/Y）
```

## Graderタイプ

### 1. コードベースGrader
コードを使用した決定論的チェック:
```bash
# ファイルに期待されるパターンが含まれているかチェック
grep -q "export function handleAuth" src/auth.ts && echo "PASS" || echo "FAIL"

# テストが通るかチェック
npm test -- --testPathPattern="auth" && echo "PASS" || echo "FAIL"

# ビルドが成功するかチェック
npm run build && echo "PASS" || echo "FAIL"
```

### 2. モデルベースGrader
オープンエンドな出力を評価するためにClaudeを使用:
```markdown
[MODEL GRADER PROMPT]
以下のコード変更を評価:
1. 記載された問題を解決しているか？
2. 構造は適切か？
3. エッジケースは処理されているか？
4. エラーハンドリングは適切か？

スコア: 1-5（1=悪い、5=優秀）
理由: [説明]
```

### 3. Human Grader
手動レビュー用にフラグ:
```markdown
[HUMAN REVIEW REQUIRED]
変更: 変更内容の説明
理由: 人間のレビューが必要な理由
リスクレベル: LOW/MEDIUM/HIGH
```

## メトリクス

### pass@k
「k回の試行で少なくとも1回成功」
- pass@1: 初回試行成功率
- pass@3: 3回以内の成功
- 一般的な目標: pass@3 > 90%

### pass^k
「k回すべての試行が成功」
- 信頼性のより高いバー
- pass^3: 3回連続成功
- クリティカルパスに使用

## Evalワークフロー

### 1. 定義（コーディング前）
```markdown
## EVAL DEFINITION: feature-xyz

### Capability Eval
1. 新規ユーザーアカウントを作成できる
2. メールフォーマットを検証できる
3. パスワードを安全にハッシュできる

### Regression Eval
1. 既存のログインは引き続き動作
2. セッション管理は変更なし
3. ログアウトフローは維持

### 成功メトリクス
- capability evalでpass@3 > 90%
- regression evalでpass^3 = 100%
```

### 2. 実装
定義されたevalを通過するコードを書く。

### 3. 評価
```bash
# capability evalを実行
[各capability evalを実行、PASS/FAILを記録]

# regression evalを実行
npm test -- --testPathPattern="existing"

# レポートを生成
```

### 4. レポート
```markdown
EVAL REPORT: feature-xyz
========================

Capability Eval:
  create-user:     PASS (pass@1)
  validate-email:  PASS (pass@2)
  hash-password:   PASS (pass@1)
  全体:            3/3 合格

Regression Eval:
  login-flow:      PASS
  session-mgmt:    PASS
  logout-flow:     PASS
  全体:            3/3 合格

メトリクス:
  pass@1: 67% (2/3)
  pass@3: 100% (3/3)

ステータス: レビュー準備完了
```

## 統合パターン

### 実装前
```
/eval define feature-name
```
`.claude/evals/feature-name.md`にeval定義ファイルを作成

### 実装中
```
/eval check feature-name
```
現在のevalを実行しステータスをレポート

### 実装後
```
/eval report feature-name
```
完全なevalレポートを生成

## Evalストレージ

プロジェクトにevalを保存:
```
.claude/
  evals/
    feature-xyz.md      # Eval定義
    feature-xyz.log     # Eval実行履歴
    baseline.json       # Regressionベースライン
```

## ベストプラクティス

1. **コーディング前にevalを定義** - 成功基準についての明確な思考を強制
2. **evalを頻繁に実行** - リグレッションを早期に検出
3. **pass@kを経時追跡** - 信頼性のトレンドを監視
4. **可能な限りcode graderを使用** - 決定論的 > 確率的
5. **セキュリティには人間のレビュー** - セキュリティチェックを完全に自動化しない
6. **evalを高速に保つ** - 遅いevalは実行されない
7. **evalをコードと一緒にバージョン管理** - evalはファーストクラスの成果物

## 例: 認証の追加

```markdown
## EVAL: add-authentication

### Phase 1: 定義（10分）
Capability Eval:
- [ ] ユーザーはメール/パスワードで登録できる
- [ ] ユーザーは有効な資格情報でログインできる
- [ ] 無効な資格情報は適切なエラーで拒否される
- [ ] セッションはページリロードで持続する
- [ ] ログアウトでセッションがクリアされる

Regression Eval:
- [ ] パブリックルートは引き続きアクセス可能
- [ ] APIレスポンスは変更なし
- [ ] データベーススキーマは互換性あり

### Phase 2: 実装（可変）
[コードを書く]

### Phase 3: 評価
実行: /eval check add-authentication

### Phase 4: レポート
EVAL REPORT: add-authentication
==============================
Capability: 5/5 合格（pass@3: 100%）
Regression: 3/3 合格（pass^3: 100%）
ステータス: SHIP IT
```
