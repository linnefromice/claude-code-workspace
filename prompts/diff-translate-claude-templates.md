# Claude Code テンプレート 差分翻訳プロンプト

## 概要

参照元リポジトリの更新を検出し、変更されたファイルのみを翻訳・更新する。

**前提条件:**
- 初回翻訳（`collect-and-translate-claude-templates.md`）が完了していること
- `.work/VERSION.md` にバージョン情報が記録されていること

---

## ワークフロー

```
1. 参照元の変更を検出
       ↓
2. 変更ファイルを特定
       ↓
3. 差分翻訳を実行
       ↓
4. バージョン情報を更新
       ↓
5. 汎用化 & デプロイ
```

---

## 実行手順

### 1. 参照元リポジトリの最新化

```bash
cd .work/source
git fetch origin

# 現在のHEAD（前回翻訳時点）を確認
git rev-parse HEAD

# リモートの最新を確認
git rev-parse origin/main

# 差分コミット数を確認
git log --oneline HEAD..origin/main | wc -l
```

### 2. 変更ファイルの特定

```bash
# 変更されたファイル一覧
git diff HEAD origin/main --name-only

# 翻訳対象ディレクトリの変更のみ
git diff HEAD origin/main --name-only -- agents/ commands/ rules/ skills/ contexts/

# 変更内容の詳細（各ファイル）
git diff HEAD origin/main -- agents/
git diff HEAD origin/main -- commands/
git diff HEAD origin/main -- rules/
git diff HEAD origin/main -- skills/
git diff HEAD origin/main -- contexts/
```

### 3. 変更タイプの分類

| タイプ | 対応 |
|--------|------|
| **新規追加** (A) | 新規に翻訳して `.work/translated/` に追加 |
| **変更** (M) | 既存の翻訳を更新（差分を反映） |
| **削除** (D) | `.work/translated/` から対応ファイルを削除 |
| **リネーム** (R) | 翻訳ファイルもリネーム |

```bash
# 変更タイプ付きで表示
git diff HEAD origin/main --name-status -- agents/ commands/ rules/ skills/ contexts/
```

### 4. 差分翻訳の実行

#### 4.1 新規ファイルの翻訳

新規追加されたファイルは、`collect-and-translate-claude-templates.md` のガイドラインに従って翻訳。

#### 4.2 変更ファイルの更新

変更されたファイルは、以下の手順で更新：

1. **変更箇所の特定**
   ```bash
   git diff HEAD origin/main -- agents/planner.md
   ```

2. **既存翻訳の読み込み**
   - `.work/translated/agents/planner.ja.md` を読む

3. **差分の反映**
   - 追加された行 → 翻訳して追加
   - 削除された行 → 対応する翻訳を削除
   - 変更された行 → 翻訳を更新

4. **文脈の整合性確認**
   - 前後の文脈と整合性が取れているか確認

#### 4.3 削除ファイルの処理

```bash
rm .work/translated/{対応するファイル}.ja.md
```

### 5. 参照元を最新化

```bash
cd .work/source
git pull origin main
cd ../..
```

### 6. バージョン情報の更新

`.work/VERSION.md` を更新：

```bash
# 新しい参照元コミットハッシュ
cd .work/source && git rev-parse HEAD && cd ../..

# 現在のリポジトリコミットハッシュ
git rev-parse HEAD
```

**更新内容:**
- 参照元リポジトリ: 新しいコミットハッシュ
- 翻訳実施時: 現在のコミットハッシュ

**バージョン履歴に追記:**
```markdown
### vX (YYYY-MM-DD) - 差分更新

| 項目 | 値 |
|------|-----|
| 作業日 | YYYY-MM-DD |
| 参照元コミット | `新しいハッシュ` |
| 前回参照元コミット | `前回のハッシュ` |
| 変更ファイル数 | X |
| 追加 | X files |
| 更新 | X files |
| 削除 | X files |
```

### 7. 汎用化 & デプロイ

```
do @prompts/generalize-claude-templates.md
```

---

## 差分翻訳のコツ

### 小さな変更（タイポ修正等）

原文の変更をそのまま翻訳に反映。

### 大きな変更（セクション追加等）

1. 追加セクションを独立して翻訳
2. 既存の翻訳スタイル（用語、文体）に合わせる
3. 前後の文脈との整合性を確認

### 構造変更（リファクタリング等）

1. 変更の意図を理解
2. 翻訳ファイルの構造も同様に変更
3. 内容の翻訳は既存を可能な限り再利用

---

## チェックリスト

- [ ] 参照元の変更を全て特定した
- [ ] 新規ファイルを翻訳した
- [ ] 変更ファイルを更新した
- [ ] 削除ファイルを処理した
- [ ] `.work/VERSION.md` を更新した
- [ ] バージョン履歴に追記した
- [ ] 汎用化プロンプトを実行した
- [ ] デプロイスクリプトを実行した
