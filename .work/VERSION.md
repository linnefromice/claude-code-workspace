# テンプレート翻訳バージョン管理

このファイルは翻訳・汎用化作業のバージョンを追跡します。

---

## 現在のバージョン

| 項目 | コミットハッシュ | 日時 | 備考 |
|------|----------------|------|------|
| **参照元リポジトリ** | `125d5e619905d97b519a887d5bc7332dcc448a52` | 2026-04-12 | affaan-m/everything-claude-code |
| **翻訳実施時** | `b62ff6c` | 2026-04-12 | このリポジトリの翻訳作業時点 |
| **汎用化実施時** | `b62ff6c` | 2026-04-12 | このリポジトリの汎用化作業時点 |

---

## バージョン履歴

### v4 (2026-04-12) - 差分更新 (Phase A)

| 項目 | 値 |
|------|-----|
| 作業日 | 2026-04-12 |
| 参照元コミット | `125d5e619905d97b519a887d5bc7332dcc448a52` |
| 前回参照元コミット | `31525854b5fc65af72acfdaada52ece8504bb7ff` |
| 変更ファイル数 | 92 (翻訳対象ディレクトリ) |
| 追加 | 66 files (翻訳対象: 45, 除外: 21) |
| 更新 | 25 files (翻訳対象: 14, 除外: 11 = script/excluded skill) |
| 削除 | 1 file (project-guidelines-example) |
| 除外カテゴリ | Flutter, Dart, C#/.NET, Kotlin, Rust 固有ルール/スキル、healthcare, crypto/DeFi 系、vertical (finance/logistics) スキル |
| 追加カテゴリ | 汎用エージェント×9 (code-architect, code-explorer 等), コマンド×8 (hookify, jira, review-pr 等), rules/web×7, 汎用スキル×21 (github-ops, seo, email-ops 等) |
| 汎用化後ファイル数 | 213 (agents:30, commands:62, rules:26, skills:92, contexts:3) |
| 備考 | Phase A スコープ (汎用性の高いファイルのみ翻訳)。残り 21 件の A (言語/ドメイン特化) は Phase B で判断 |

---

### v3 (2026-04-02) - 差分更新

| 項目 | 値 |
|------|-----|
| 作業日 | 2026-04-02 |
| 参照元コミット | `31525854b5fc65af72acfdaada52ece8504bb7ff` |
| 前回参照元コミット | `77bb669dc5fb21ac9767548ee5077c1eb6a305d2` |
| 変更ファイル数 | 300+ |
| 追加 | 250+ files (翻訳対象: 86, 除外: 164+) |
| 更新 | 56 files (翻訳対象: 54, 除外: 2) |
| 削除 | 0 files |
| 除外カテゴリ | Go, Python, Django, Java, Spring Boot, Kotlin, Rust, C++, C#, Swift, Perl, PHP, Flutter, PyTorch, ClickHouse, Postgres, database-reviewer, healthcare, logistics, 中国語(zh/) 等 |
| 追加カテゴリ | 汎用エージェント×9, コマンド×23, ルール×2, スキル×52 |
| 汎用化後ファイル数 | 153 (agents:18, commands:50, rules:16, skills:66, contexts:3) |

---

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
