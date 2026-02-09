---
name: configure-ecc
description: Everything Claude Code のインタラクティブインストーラー -- スキルとルールの選択・インストールをユーザーレベルまたはプロジェクトレベルのディレクトリに対して案内し、パスを検証し、オプションでインストール済みファイルの最適化を行います。
---

# Everything Claude Code (ECC) の設定

Everything Claude Code プロジェクトのインタラクティブなステップバイステップのインストールウィザードです。`AskUserQuestion` を使用して、スキルとルールの選択的インストールをユーザーに案内し、正確性を検証し、最適化を提供します。

## 起動条件

- ユーザーが「configure ecc」、「install ecc」、「setup everything claude code」などと発言した場合
- ユーザーがこのプロジェクトからスキルやルールを選択的にインストールしたい場合
- ユーザーが既存の ECC インストールを検証または修正したい場合
- ユーザーがインストール済みのスキルやルールをプロジェクトに合わせて最適化したい場合

## 前提条件

このスキルは起動前に Claude Code からアクセス可能である必要があります。ブートストラップ方法は2つあります：
1. **プラグイン経由**: `/plugin install everything-claude-code` -- プラグインがこのスキルを自動的に読み込みます
2. **手動**: このスキルのみを `~/.claude/skills/configure-ecc/SKILL.md` にコピーし、「configure ecc」と発言して起動します

---

## ステップ 0: ECC リポジトリのクローン

インストールの前に、最新の ECC ソースを `/tmp` にクローンします：

```bash
rm -rf /tmp/everything-claude-code
git clone https://github.com/affaan-m/everything-claude-code.git /tmp/everything-claude-code
```

以降のすべてのコピー操作のソースとして `ECC_ROOT=/tmp/everything-claude-code` を設定します。

クローンに失敗した場合（ネットワークの問題など）、`AskUserQuestion` を使用して既存の ECC クローンへのローカルパスの提供をユーザーに求めます。

---

## ステップ 1: インストールレベルの選択

`AskUserQuestion` を使用してインストール先をユーザーに尋ねます：

```
Question: "ECC コンポーネントをどこにインストールしますか？"
Options:
  - "ユーザーレベル (~/.claude/)" — "すべての Claude Code プロジェクトに適用されます"
  - "プロジェクトレベル (.claude/)" — "現在のプロジェクトにのみ適用されます"
  - "両方" — "共通/共有項目はユーザーレベル、プロジェクト固有の項目はプロジェクトレベル"
```

選択を `INSTALL_LEVEL` として保存します。ターゲットディレクトリを設定します：
- ユーザーレベル: `TARGET=~/.claude`
- プロジェクトレベル: `TARGET=.claude`（現在のプロジェクトルートからの相対パス）
- 両方: `TARGET_USER=~/.claude`, `TARGET_PROJECT=.claude`

ターゲットディレクトリが存在しない場合は作成します：
```bash
mkdir -p $TARGET/skills $TARGET/rules
```

---

## ステップ 2: スキルの選択とインストール

### 2a: スキルカテゴリの選択

27 のスキルが 4 つのカテゴリに分類されています。`AskUserQuestion` を `multiSelect: true` で使用します：

```
Question: "どのスキルカテゴリをインストールしますか？"
Options:
  - "フレームワーク & 言語" — "Django、Spring Boot、Go、Python、Java、フロントエンド、バックエンドパターン"
  - "データベース" — "PostgreSQL、ClickHouse、JPA/Hibernate パターン"
  - "ワークフロー & 品質" — "TDD、検証、学習、セキュリティレビュー、コンパクション"
  - "全スキル" — "利用可能なすべてのスキルをインストール"
```

### 2b: 個別スキルの確認

選択された各カテゴリについて、以下のスキル一覧を表示し、ユーザーに特定のスキルの確認または選択解除を求めます。リストが 4 項目を超える場合は、リストをテキストとして表示し、`AskUserQuestion` で「一覧のすべてをインストール」オプションと、ユーザーが特定の名前を貼り付けるための「その他」オプションを使用します。

**カテゴリ: フレームワーク & 言語（16 スキル）**

| スキル | 説明 |
|-------|------|
| `backend-patterns` | バックエンドアーキテクチャ、API 設計、Node.js/Express/Next.js のサーバーサイドベストプラクティス |
| `coding-standards` | TypeScript、JavaScript、React、Node.js のユニバーサルコーディング標準 |
| `django-patterns` | Django アーキテクチャ、DRF による REST API、ORM、キャッシュ、シグナル、ミドルウェア |
| `django-security` | Django セキュリティ：認証、CSRF、SQL インジェクション、XSS 防止 |
| `django-tdd` | pytest-django、factory_boy、モッキング、カバレッジを使用した Django テスト |
| `django-verification` | Django 検証ループ：マイグレーション、リンティング、テスト、セキュリティスキャン |
| `frontend-patterns` | React、Next.js、状態管理、パフォーマンス、UI パターン |
| `golang-patterns` | Go の慣用的パターン、堅牢な Go アプリケーションのための規約 |
| `golang-testing` | Go テスト：テーブル駆動テスト、サブテスト、ベンチマーク、ファジング |
| `java-coding-standards` | Spring Boot 向け Java コーディング標準：命名、イミュータビリティ、Optional、ストリーム |
| `python-patterns` | Python のイディオム、PEP 8、型ヒント、ベストプラクティス |
| `python-testing` | pytest を使用した Python テスト、TDD、フィクスチャ、モッキング、パラメトリゼーション |
| `springboot-patterns` | Spring Boot アーキテクチャ、REST API、レイヤードサービス、キャッシュ、非同期処理 |
| `springboot-security` | Spring Security：認証/認可、バリデーション、CSRF、シークレット、レート制限 |
| `springboot-tdd` | JUnit 5、Mockito、MockMvc、Testcontainers を使用した Spring Boot TDD |
| `springboot-verification` | Spring Boot 検証：ビルド、静的解析、テスト、セキュリティスキャン |

**カテゴリ: データベース（3 スキル）**

| スキル | 説明 |
|-------|------|
| `clickhouse-io` | ClickHouse パターン、クエリ最適化、アナリティクス、データエンジニアリング |
| `jpa-patterns` | JPA/Hibernate エンティティ設計、リレーションシップ、クエリ最適化、トランザクション |
| `postgres-patterns` | PostgreSQL クエリ最適化、スキーマ設計、インデックス、セキュリティ |

**カテゴリ: ワークフロー & 品質（8 スキル）**

| スキル | 説明 |
|-------|------|
| `continuous-learning` | セッションから再利用可能なパターンを自動抽出し、学習済みスキルとして保存 |
| `continuous-learning-v2` | 信頼度スコアリング付きの直感ベース学習、スキル/コマンド/エージェントに発展 |
| `eval-harness` | 評価駆動開発（EDD）のための正式な評価フレームワーク |
| `iterative-retrieval` | サブエージェントのコンテキスト問題に対する段階的コンテキスト精緻化 |
| `security-review` | セキュリティチェックリスト：認証、入力、シークレット、API、決済機能 |
| `strategic-compact` | 論理的な区切りで手動コンテキストコンパクションを提案 |
| `tdd-workflow` | 80% 以上のカバレッジで TDD を強制：ユニット、統合、E2E |
| `verification-loop` | 検証および品質ループパターン |

**スタンドアロン**

| スキル | 説明 |
|-------|------|
| `project-guidelines-example` | プロジェクト固有のスキルを作成するためのテンプレート |

### 2c: インストールの実行

選択された各スキルについて、スキルディレクトリ全体をコピーします：
```bash
cp -r $ECC_ROOT/skills/<skill-name> $TARGET/skills/
```

注意: `continuous-learning` と `continuous-learning-v2` には追加ファイル（config.json、hooks、scripts）があります -- SKILL.md だけでなく、ディレクトリ全体がコピーされていることを確認してください。

---

## ステップ 3: ルールの選択とインストール

`AskUserQuestion` を `multiSelect: true` で使用します：

```
Question: "どのルールセットをインストールしますか？"
Options:
  - "共通ルール（推奨）" — "言語に依存しない原則：コーディングスタイル、git ワークフロー、テスト、セキュリティなど（8 ファイル）"
  - "TypeScript/JavaScript" — "TS/JS パターン、hooks、Playwright によるテスト（5 ファイル）"
  - "Python" — "Python パターン、pytest、black/ruff フォーマッティング（5 ファイル）"
  - "Go" — "Go パターン、テーブル駆動テスト、gofmt/staticcheck（5 ファイル）"
```

インストールの実行：
```bash
# 共通ルール（rules/ にフラットコピー）
cp -r $ECC_ROOT/rules/common/* $TARGET/rules/

# 言語固有ルール（rules/ にフラットコピー）
cp -r $ECC_ROOT/rules/typescript/* $TARGET/rules/   # 選択された場合
cp -r $ECC_ROOT/rules/python/* $TARGET/rules/        # 選択された場合
cp -r $ECC_ROOT/rules/golang/* $TARGET/rules/        # 選択された場合
```

**重要**: ユーザーが言語固有のルールを選択したが共通ルールを選択しなかった場合、警告を表示します：
> 「言語固有のルールは共通ルールを拡張しています。共通ルールなしでインストールすると、カバレッジが不完全になる可能性があります。共通ルールもインストールしますか？」

---

## ステップ 4: インストール後の検証

インストール後、以下の自動チェックを実行します：

### 4a: ファイル存在の検証

インストールされたすべてのファイルを一覧表示し、ターゲットの場所に存在することを確認します：
```bash
ls -la $TARGET/skills/
ls -la $TARGET/rules/
```

### 4b: パス参照のチェック

インストールされたすべての `.md` ファイルでパス参照をスキャンします：
```bash
grep -rn "~/.claude/" $TARGET/skills/ $TARGET/rules/
grep -rn "../common/" $TARGET/rules/
grep -rn "skills/" $TARGET/skills/
```

**プロジェクトレベルのインストールの場合**、`~/.claude/` パスへの参照をフラグ付けします：
- スキルが `~/.claude/settings.json` を参照している場合 -- これは通常問題ありません（settings は常にユーザーレベル）
- スキルが `~/.claude/skills/` や `~/.claude/rules/` を参照している場合 -- プロジェクトレベルにのみインストールされている場合、壊れている可能性があります
- スキルが別のスキルを名前で参照している場合 -- 参照されたスキルもインストールされているか確認します

### 4c: スキル間の相互参照チェック

一部のスキルは他のスキルを参照しています。以下の依存関係を検証します：
- `django-tdd` は `django-patterns` を参照している可能性があります
- `springboot-tdd` は `springboot-patterns` を参照している可能性があります
- `continuous-learning-v2` は `~/.claude/homunculus/` ディレクトリを参照しています
- `python-testing` は `python-patterns` を参照している可能性があります
- `golang-testing` は `golang-patterns` を参照している可能性があります
- 言語固有のルールは `common/` の対応するルールを参照しています

### 4d: 問題の報告

見つかった各問題について、以下を報告します：
1. **ファイル**: 問題のある参照を含むファイル
2. **行**: 行番号
3. **問題**: 何が問題か（例：「~/.claude/skills/python-patterns を参照していますが、python-patterns はインストールされていません」）
4. **推奨修正**: 対処方法（例：「python-patterns スキルをインストールする」または「パスを .claude/skills/ に更新する」）

---

## ステップ 5: インストール済みファイルの最適化（オプション）

`AskUserQuestion` を使用します：

```
Question: "インストールされたファイルをプロジェクトに合わせて最適化しますか？"
Options:
  - "スキルを最適化" — "不要なセクションの削除、パスの調整、技術スタックに合わせたカスタマイズ"
  - "ルールを最適化" — "カバレッジ目標の調整、プロジェクト固有のパターン追加、ツール設定のカスタマイズ"
  - "両方を最適化" — "インストール済みの全ファイルを完全に最適化"
  - "スキップ" — "すべてそのまま保持"
```

### スキルを最適化する場合：
1. インストールされた各 SKILL.md を読み取ります
2. プロジェクトの技術スタックをユーザーに尋ねます（まだ把握していない場合）
3. 各スキルについて、不要なセクションの削除を提案します
4. インストール先の SKILL.md ファイルをインプレースで編集します（ソースリポジトリではありません）
5. ステップ 4 で見つかったパスの問題を修正します

### ルールを最適化する場合：
1. インストールされた各ルール .md ファイルを読み取ります
2. ユーザーの好みを尋ねます：
   - テストカバレッジ目標（デフォルト 80%）
   - 好みのフォーマットツール
   - Git ワークフロー規約
   - セキュリティ要件
3. インストール先のルールファイルをインプレースで編集します

**重要**: インストール先（`$TARGET/`）のファイルのみを変更します。ソース ECC リポジトリ（`$ECC_ROOT/`）のファイルは**絶対に変更しないでください**。

---

## ステップ 6: インストールサマリー

クローンしたリポジトリを `/tmp` からクリーンアップします：

```bash
rm -rf /tmp/everything-claude-code
```

その後、サマリーレポートを表示します：

```
## ECC インストール完了

### インストール先
- レベル: [ユーザーレベル / プロジェクトレベル / 両方]
- パス: [ターゲットパス]

### インストールされたスキル（[件数]）
- skill-1, skill-2, skill-3, ...

### インストールされたルール（[件数]）
- common（8 ファイル）
- typescript（5 ファイル）
- ...

### 検証結果
- [件数] 件の問題が見つかり、[件数] 件を修正済み
- [残りの問題をリスト表示]

### 適用された最適化
- [変更内容をリスト表示、または「なし」]
```

---

## トラブルシューティング

### 「スキルが Claude Code に認識されない」
- スキルディレクトリに `SKILL.md` ファイルが含まれていることを確認します（単なるルーズな .md ファイルではなく）
- ユーザーレベルの場合: `~/.claude/skills/<skill-name>/SKILL.md` が存在するか確認します
- プロジェクトレベルの場合: `.claude/skills/<skill-name>/SKILL.md` が存在するか確認します

### 「ルールが機能しない」
- ルールはサブディレクトリではなくフラットファイルです：`$TARGET/rules/coding-style.md`（正しい）vs `$TARGET/rules/common/coding-style.md`（フラットインストールでは不正）
- ルールのインストール後に Claude Code を再起動してください

### 「プロジェクトレベルインストール後のパス参照エラー」
- 一部のスキルは `~/.claude/` パスを前提としています。ステップ 4 の検証を実行してこれらを見つけて修正してください。
- `continuous-learning-v2` の場合、`~/.claude/homunculus/` ディレクトリは常にユーザーレベルです -- これは想定通りであり、エラーではありません。
