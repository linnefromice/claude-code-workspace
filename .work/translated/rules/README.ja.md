# ルール

## 構成

ルールは **共通** レイヤーと **言語固有** ディレクトリで構成されています：

```
rules/
├── common/          # 言語非依存の原則（常にインストール）
│   ├── coding-style.md
│   ├── git-workflow.md
│   ├── testing.md
│   ├── performance.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── agents.md
│   └── security.md
├── typescript/      # TypeScript/JavaScript 固有
├── python/          # Python 固有
├── golang/          # Go 固有
├── swift/           # Swift 固有
└── php/             # PHP 固有
```

- **common/** にはユニバーサルな原則が含まれます — 言語固有のコード例はありません。
- **言語ディレクトリ** は共通ルールをフレームワーク固有のパターン、ツール、コード例で拡張します。各ファイルは対応する共通ルールを参照しています。

## インストール

### オプション 1: インストールスクリプト（推奨）

```bash
# 共通 + 1つ以上の言語固有ルールセットをインストール
./install.sh typescript
./install.sh python
./install.sh golang
./install.sh swift
./install.sh php

# 複数の言語を一度にインストール
./install.sh typescript python
```

### オプション 2: 手動インストール

> **重要:** ディレクトリ全体をコピーしてください — `/*` でフラット化しないでください。
> 共通ディレクトリと言語固有ディレクトリには同名のファイルが含まれています。
> 1つのディレクトリにフラット化すると、言語固有ファイルが共通ルールを上書きし、
> 言語固有ファイルが使用している相対パス `../common/` の参照が壊れます。

```bash
# 共通ルールをインストール（全プロジェクトで必須）
cp -r rules/common ~/.claude/rules/common

# プロジェクトの技術スタックに基づいて言語固有ルールをインストール
cp -r rules/typescript ~/.claude/rules/typescript
cp -r rules/python ~/.claude/rules/python
cp -r rules/golang ~/.claude/rules/golang
cp -r rules/swift ~/.claude/rules/swift
cp -r rules/php ~/.claude/rules/php

# 注意！！！実際のプロジェクト要件に合わせて設定してください。ここでの設定は参考用です。
```

## ルール vs スキル

- **ルール** は広く適用される標準、規約、チェックリストを定義します（例: 「テストカバレッジ 80%」「ハードコードされたシークレット禁止」）。
- **スキル**（`skills/` ディレクトリ）は特定のタスクに対する詳細で実践的なリファレンス資料を提供します（例: `python-patterns`、`golang-testing`）。

言語固有のルールファイルは、適切な箇所で関連するスキルを参照します。ルールは「何をするか」を示し、スキルは「どのようにするか」を示します。

## 新しい言語の追加

新しい言語のサポートを追加するには（例: `rust/`）：

1. `rules/rust/` ディレクトリを作成
2. 共通ルールを拡張するファイルを追加：
   - `coding-style.md` — フォーマットツール、イディオム、エラーハンドリングパターン
   - `testing.md` — テストフレームワーク、カバレッジツール、テスト構成
   - `patterns.md` — 言語固有のデザインパターン
   - `hooks.md` — フォーマッタ、リンター、型チェッカー用の PostToolUse フック
   - `security.md` — シークレット管理、セキュリティスキャンツール
3. 各ファイルは以下で始めてください：
   ```
   > このファイルは [common/xxx.md](../common/xxx.md) を <言語> 固有の内容で拡張します。
   ```
4. 利用可能なスキルがあれば参照するか、`skills/` に新しいスキルを作成してください。

## ルールの優先度

言語固有のルールと共通ルールが競合する場合、**言語固有のルールが優先されます**（特定が一般を上書き）。これは標準的なレイヤー設定パターン（CSS の詳細度や `.gitignore` の優先順位と同様）に従います。

- `rules/common/` はすべてのプロジェクトに適用されるユニバーサルなデフォルトを定義します。
- `rules/golang/`、`rules/python/`、`rules/swift/`、`rules/php/`、`rules/typescript/` などは、言語のイディオムが異なる場合にそれらのデフォルトを上書きします。

### 例

`common/coding-style.md` はデフォルトの原則としてイミュータビリティを推奨しています。言語固有の `golang/coding-style.md` はこれを上書きできます：

> イディオマティックな Go では構造体のミューテーションにポインタレシーバを使用します — 一般的な原則については [common/coding-style.md](../common/coding-style.md) を参照してください。ただし、ここでは Go のイディオマティックなミューテーションが優先されます。

### 上書き注記付きの共通ルール

`rules/common/` 内のルールで、言語固有ファイルによって上書きされる可能性があるものには、以下のマークが付いています：

> **言語に関する注記**: このルールは、このパターンがイディオマティックでない言語の言語固有ルールによって上書きされる場合があります。
