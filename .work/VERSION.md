# テンプレート翻訳バージョン管理

このファイルは翻訳・汎用化作業のバージョンを追跡します。

---

## 現在のバージョン

| 項目 | コミットハッシュ | 日時 | 備考 |
|------|----------------|------|------|
| **参照元リポジトリ** | `77bb669dc5fb21ac9767548ee5077c1eb6a305d2` | 2026-02-09 | affaan-m/everything-claude-code |
| **翻訳実施時** | `530ea30c` | 2026-02-09 | このリポジトリの翻訳作業時点 |
| **汎用化実施時** | `530ea30c` | 2026-02-09 | このリポジトリの汎用化作業時点 |

---

## バージョン履歴

### v2 (2026-02-09) - 差分更新

| 項目 | 値 |
|------|-----|
| 作業日 | 2026-02-09 |
| 参照元コミット | `77bb669dc5fb21ac9767548ee5077c1eb6a305d2` |
| 前回参照元コミット | `8894e1bced998d2e73e591c84130823b63c9ac7f` |
| 変更ファイル数 | 57 |
| 追加 | 41 files (翻訳対象: 16, 除外: 25) |
| 更新 | 7 files (翻訳対象: 6, 除外: 1) |
| 削除 | 5 files |
| リネーム | 7 files |
| 除外カテゴリ | Go, Python, Django, Java, Spring Boot, ClickHouse, Postgres, database-reviewer |
| 追加カテゴリ | TypeScript固有ルール (新規含む) |
| 汎用化後ファイル数 | 67 (agents:9, commands:27, rules:14, skills:14, contexts:3) |

---

### v1 (初回翻訳)

| 項目 | 値 |
|------|-----|
| 作業日 | 2026-01-28 |
| 参照元コミット | `8894e1bced998d2e73e591c84130823b63c9ac7f` |
| 翻訳対象ファイル数 | 62 |
| 汎用化後ファイル数 | 52 (database-reviewer除外後) |
| 除外カテゴリ | Go, ClickHouse, Postgres, database-reviewer |

---

## 更新手順

### 参照元リポジトリの更新確認

```bash
# 1. 参照元の最新を取得
cd .work/source
git fetch origin
git log --oneline HEAD..origin/main

# 2. 変更ファイルを確認
git diff HEAD origin/main --name-only

# 3. 差分を確認（翻訳対象のみ）
git diff HEAD origin/main -- agents/ commands/ rules/ skills/ contexts/
```

### 差分翻訳の実行

1. 新規/変更ファイルを特定
2. 対応する `.work/translated/` のファイルを更新
3. このファイルのバージョン情報を更新
4. `./scripts/deploy-templates.sh` を実行

---

## 参照元リポジトリ情報

- **リポジトリ**: https://github.com/affaan-m/everything-claude-code
- **クローン先**: `.work/source/` (gitignore対象)
