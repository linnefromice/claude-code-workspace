---
name: prompt-optimizer
description: >-
  Analyze raw prompts, identify intent and gaps, match ECC components
  (skills/commands/agents/hooks), and output a ready-to-paste optimized
  prompt. Advisory role only — never executes the task itself.
  TRIGGER when: user says "optimize prompt", "improve my prompt",
  "how to write a prompt for", "help me prompt", "rewrite this prompt",
  or explicitly asks to enhance prompt quality. Also triggers on Chinese
  equivalents: "优化prompt", "改进prompt", "怎么写prompt", "帮我优化这个指令".
  DO NOT TRIGGER when: user wants the task executed directly, or says
  "just do it" / "直接做". DO NOT TRIGGER when user says "优化代码",
  "优化性能", "optimize performance", "optimize this code" — those are
  refactoring/performance tasks, not prompt optimization.
origin: community
metadata:
  author: YannJY02
  version: "1.0.0"
---

# Prompt Optimizer

ドラフトプロンプトを分析し、批評し、ECC エコシステムのコンポーネントとマッチングし、
ユーザーがそのまま貼り付けて実行できる最適化されたプロンプトを出力します。

## 使用タイミング

- ユーザーが「optimize this prompt」「improve my prompt」「rewrite this prompt」と言った場合
- ユーザーが「help me write a better prompt for...」と言った場合
- ユーザーが「what's the best way to ask Claude Code to...」と言った場合
- ユーザーが「优化prompt」「改进prompt」「怎么写prompt」「帮我优化这个指令」と言った場合
- ユーザーがドラフトプロンプトを貼り付けてフィードバックや改善を求めた場合
- ユーザーが「I don't know how to prompt for this」と言った場合
- ユーザーが「how should I use ECC for...」と言った場合
- ユーザーが明示的に `/prompt-optimize` を呼び出した場合

### 使用しない場合

- ユーザーがタスクを直接実行してほしい場合（そのまま実行する）
- ユーザーが「优化代码」「优化性能」「optimize this code」「optimize performance」と言った場合 — これらはプロンプト最適化ではなくリファクタリングタスクです
- ユーザーが ECC の設定について質問している場合（代わりに `configure-ecc` を使用）
- ユーザーがスキル一覧を求めている場合（代わりに `skill-stocktake` を使用）
- ユーザーが「just do it」または「直接做」と言った場合

## 仕組み

**アドバイザリーのみ — ユーザーのタスクを実行しないでください。**

コードの記述、ファイルの作成、コマンドの実行、その他の実装アクションは一切行わないでください。
出力は分析と最適化されたプロンプトのみです。

ユーザーが「just do it」「直接做」「don't optimize, just execute」と言った場合、
このスキル内で実装モードに切り替えないでください。このスキルは最適化されたプロンプトの生成のみを行うことを伝え、
実行が必要な場合は通常のタスクリクエストを行うよう案内してください。

以下の6フェーズのパイプラインを順番に実行します。結果は下記の出力フォーマットで提示します。

### 分析パイプライン

### フェーズ 0: プロジェクト検出

プロンプトを分析する前に、現在のプロジェクトコンテキストを検出します:

1. 作業ディレクトリに `CLAUDE.md` が存在するか確認 — プロジェクト規約を読み取ります
2. プロジェクトファイルから技術スタックを検出:
   - `package.json` → Node.js / TypeScript / React / Next.js
   - `go.mod` → Go
   - `pyproject.toml` / `requirements.txt` → Python
   - `Cargo.toml` → Rust
   - `build.gradle` / `pom.xml` → Java / Kotlin / Spring Boot
   - `Package.swift` → Swift
   - `Gemfile` → Ruby
   - `composer.json` → PHP
   - `*.csproj` / `*.sln` → .NET
   - `Makefile` / `CMakeLists.txt` → C / C++
   - `cpanfile` / `Makefile.PL` → Perl
3. 検出された技術スタックをフェーズ 3 とフェーズ 4 で使用するために記録します

プロジェクトファイルが見つからない場合（例: プロンプトが抽象的または新規プロジェクト向けの場合）、
検出をスキップし、フェーズ 4 で「tech stack unknown」とフラグを立てます。

### フェーズ 1: 意図検出

ユーザーのタスクを1つ以上のカテゴリに分類します:

| カテゴリ | シグナルワード | 例 |
|---------|--------------|-----|
| New Feature | build, create, add, implement, 创建, 实现, 添加 | 「Build a login page」 |
| Bug Fix | fix, broken, not working, error, 修复, 报错 | 「Fix the auth flow」 |
| Refactor | refactor, clean up, restructure, 重构, 整理 | 「Refactor the API layer」 |
| Research | how to, what is, explore, investigate, 怎么, 如何 | 「How to add SSO」 |
| Testing | test, coverage, verify, 测试, 覆盖率 | 「Add tests for the cart」 |
| Review | review, audit, check, 审查, 检查 | 「Review my PR」 |
| Documentation | document, update docs, 文档 | 「Update the API docs」 |
| Infrastructure | deploy, CI, docker, database, 部署, 数据库 | 「Set up CI/CD pipeline」 |
| Design | design, architecture, plan, 设计, 架构 | 「Design the data model」 |

### フェーズ 2: スコープ評価

フェーズ 0 でプロジェクトが検出された場合、コードベースのサイズをシグナルとして使用します。
それ以外の場合は、プロンプトの記述のみから見積もり、見積もりが不確実であることをマークします。

| スコープ | ヒューリスティック | オーケストレーション |
|---------|-------------------|---------------------|
| TRIVIAL | 単一ファイル、50行未満 | 直接実行 |
| LOW | 単一コンポーネントまたはモジュール | 単一コマンドまたはスキル |
| MEDIUM | 複数コンポーネント、同一ドメイン | コマンドチェーン + /verify |
| HIGH | クロスドメイン、5+ ファイル | まず /plan、次にフェーズ実行 |
| EPIC | マルチセッション、マルチ PR、アーキテクチャ変更 | blueprint スキルでマルチセッション計画 |

### フェーズ 3: ECC コンポーネントマッチング

意図 + スコープ + 技術スタック（フェーズ 0 から）を特定の ECC コンポーネントにマッピングします。

#### 意図タイプ別

| 意図 | コマンド | スキル | エージェント |
|------|---------|--------|-------------|
| New Feature | /plan, /tdd, /code-review, /verify | tdd-workflow, verification-loop | planner, tdd-guide, code-reviewer |
| Bug Fix | /tdd, /build-fix, /verify | tdd-workflow | tdd-guide, build-error-resolver |
| Refactor | /refactor-clean, /code-review, /verify | verification-loop | refactor-cleaner, code-reviewer |
| Research | /plan | search-first, iterative-retrieval | — |
| Testing | /tdd, /e2e, /test-coverage | tdd-workflow, e2e-testing | tdd-guide, e2e-runner |
| Review | /code-review | security-review | code-reviewer, security-reviewer |
| Documentation | /update-docs, /update-codemaps | — | doc-updater |
| Infrastructure | /plan, /verify | docker-patterns, deployment-patterns, database-migrations | architect |
| Design (MEDIUM-HIGH) | /plan | — | planner, architect |
| Design (EPIC) | — | blueprint (スキルとして呼び出し) | planner, architect |

#### 技術スタック別

| 技術スタック | 追加スキル | エージェント |
|------------|-----------|-------------|
| Python / Django | django-patterns, django-tdd, django-security, django-verification, python-patterns, python-testing | python-reviewer |
| Go | golang-patterns, golang-testing | go-reviewer, go-build-resolver |
| Spring Boot / Java | springboot-patterns, springboot-tdd, springboot-security, springboot-verification, java-coding-standards, jpa-patterns | code-reviewer |
| Kotlin / Android | kotlin-coroutines-flows, compose-multiplatform-patterns, android-clean-architecture | kotlin-reviewer |
| TypeScript / React | frontend-patterns, backend-patterns, coding-standards | code-reviewer |
| Swift / iOS | swiftui-patterns, swift-concurrency-6-2, swift-actor-persistence, swift-protocol-di-testing | code-reviewer |
| PostgreSQL | postgres-patterns, database-migrations | database-reviewer |
| Perl | perl-patterns, perl-testing, perl-security | code-reviewer |
| C++ | cpp-coding-standards, cpp-testing | code-reviewer |
| その他 / 未記載 | coding-standards (汎用) | code-reviewer |

### フェーズ 4: 欠落コンテキスト検出

プロンプトの重要な情報の欠落をスキャンします。各項目をチェックし、
フェーズ 0 で自動検出されたか、ユーザーが提供すべきかをマークします:

- [ ] **技術スタック** — フェーズ 0 で検出済みか、ユーザーの指定が必要か？
- [ ] **対象スコープ** — ファイル、ディレクトリ、またはモジュールが記載されているか？
- [ ] **受入基準** — タスク完了の判断方法は？
- [ ] **エラー処理** — エッジケースと障害モードが対処されているか？
- [ ] **セキュリティ要件** — 認証、入力バリデーション、シークレットは？
- [ ] **テスト期待値** — ユニット、統合、E2E？
- [ ] **パフォーマンス制約** — 負荷、レイテンシ、リソース制限は？
- [ ] **UI/UX 要件** — デザイン仕様、レスポンシブ、アクセシビリティ？（フロントエンドの場合）
- [ ] **データベース変更** — スキーマ、マイグレーション、インデックス？（データ層の場合）
- [ ] **既存パターン** — 参照すべきファイルや規約は？
- [ ] **スコープ境界** — やるべきでないことは？

**重要項目が3つ以上欠落している場合**、最適化されたプロンプトを生成する前に
ユーザーに最大3つの明確化の質問をします。回答を最適化されたプロンプトに組み込みます。

### フェーズ 5: ワークフロー & モデル推奨

このプロンプトが開発ライフサイクルのどこに位置するかを判断します:

```
Research → Plan → Implement (TDD) → Review → Verify → Commit
```

MEDIUM+ のタスクでは常に /plan から開始します。EPIC タスクでは blueprint スキルを使用します。

**モデル推奨**（出力に含める）:

| スコープ | 推奨モデル | 理由 |
|---------|-----------|------|
| TRIVIAL-LOW | Sonnet 4.6 | シンプルなタスクに高速でコスト効率が良い |
| MEDIUM | Sonnet 4.6 | 標準的な作業に最適なコーディングモデル |
| HIGH | Sonnet 4.6（メイン）+ Opus 4.6（プランニング） | アーキテクチャに Opus、実装に Sonnet |
| EPIC | Opus 4.6（blueprint）+ Sonnet 4.6（実行） | マルチセッション計画に深い推論 |

**マルチプロンプト分割**（HIGH/EPIC スコープ向け）:

単一セッションを超えるタスクの場合、順次プロンプトに分割します:
- プロンプト 1: リサーチ + プラン（search-first スキルを使用、次に /plan）
- プロンプト 2-N: プロンプトごとに1フェーズを実装（各フェーズは /verify で終了）
- 最終プロンプト: 統合テスト + 全フェーズにわたる /code-review
- セッション間のコンテキスト保持に /save-session と /resume-session を使用

---

## 出力フォーマット

この正確な構造で分析を提示します。ユーザーの入力と同じ言語で回答してください。

### セクション 1: プロンプト診断

**強み:** 元のプロンプトの良い点を列挙します。

**問題点:**

| 問題 | 影響 | 修正案 |
|------|------|--------|
| （問題） | （結果） | （修正方法） |

**要明確化:** ユーザーが回答すべき質問の番号付きリスト。
フェーズ 0 で自動検出された場合は、質問する代わりにその内容を記載します。

### セクション 2: 推奨 ECC コンポーネント

| タイプ | コンポーネント | 目的 |
|--------|-------------|------|
| Command | /plan | コーディング前にアーキテクチャを計画 |
| Skill | tdd-workflow | TDD 方法論のガイダンス |
| Agent | code-reviewer | 実装後のレビュー |
| Model | Sonnet 4.6 | このスコープに推奨 |

### セクション 3: 最適化プロンプト — フルバージョン

完全な最適化プロンプトを単一のフェンスドコードブロック内に提示します。
プロンプトはそのままコピー＆ペーストできる自己完結型である必要があります。以下を含めます:
- コンテキスト付きの明確なタスク説明
- 技術スタック（検出済みまたは指定済み）
- 適切なワークフロー段階での /command の呼び出し
- 受入基準
- 検証ステップ
- スコープ境界（やるべきでないこと）

blueprint を参照する項目には、「Use the blueprint skill to...」と記述します
（blueprint はコマンドではなくスキルなので、`/blueprint` ではありません）。

### セクション 4: 最適化プロンプト — クイックバージョン

経験豊富な ECC ユーザー向けのコンパクトバージョン。意図タイプに応じて変化させます:

| 意図 | クイックパターン |
|------|----------------|
| New Feature | `/plan [feature]. /tdd to implement. /code-review. /verify.` |
| Bug Fix | `/tdd — write failing test for [bug]. Fix to green. /verify.` |
| Refactor | `/refactor-clean [scope]. /code-review. /verify.` |
| Research | `Use search-first skill for [topic]. /plan based on findings.` |
| Testing | `/tdd [module]. /e2e for critical flows. /test-coverage.` |
| Review | `/code-review. Then use security-reviewer agent.` |
| Docs | `/update-docs. /update-codemaps.` |
| EPIC | `Use blueprint skill for "[objective]". Execute phases with /verify gates.` |

### セクション 5: 改善の根拠

| 改善点 | 理由 |
|--------|------|
| （追加されたもの） | （なぜ重要か） |

### フッター

> 必要なものと違いますか？何を調整すべきか教えてください。プロンプト最適化ではなく
> 実行を希望する場合は、通常のタスクリクエストを行ってください。

---

## 例

### トリガー例

- 「Optimize this prompt for ECC」
- 「Rewrite this prompt so Claude Code uses the right commands」
- 「帮我优化这个指令」
- 「How should I prompt ECC for this task?」

### 例 1: 曖昧な中国語プロンプト（プロジェクト検出あり）

**ユーザー入力:**
```
帮我写一个用户登录页面
```

**フェーズ 0 の検出結果:** `package.json` に Next.js 15、TypeScript、Tailwind CSS

**最適化プロンプト（フル）:**
```
使用项目现有技术栈（Next.js 15 + TypeScript + Tailwind CSS）实现用户登录页面。

技术要求：
- 沿用项目现有的组件结构和路由约定
- 表单验证使用项目中已有的验证方案（检查是否已用 Zod/Yup/其他）
- 认证方式：沿用项目现有认证方案（如无，默认 JWT）
- 包含：邮箱/密码登录表单、表单验证、错误提示、加载状态、响应式布局

工作流：
1. /plan 先规划组件结构和认证流程，参考现有页面的模式
2. /tdd 测试先行：编写登录表单的单元测试和认证流程的集成测试
3. 实现登录页面和认证逻辑
4. /code-review 审查实现
5. /verify 验证所有测试通过且页面正常渲染

安全要求：
- 密码不明文传输
- 防止暴力破解（rate limiting）
- XSS 防护
- CSRF token

验收标准：
- 所有测试通过，覆盖率 80%+
- 页面在移动端和桌面端正常渲染
- 登录成功跳转到 dashboard，失败显示错误信息

不要做：
- 不要实现注册页面
- 不要实现忘记密码功能
- 不要修改现有的路由结构
```

### 例 2: 中程度の英語プロンプト

**ユーザー入力:**
```
Add a REST API endpoint for user profile updates with validation
```

**フェーズ 0 の検出結果:** `go.mod` に Go 1.22、Chi router

**最適化プロンプト（フル）:**
```
Add a REST API endpoint for user profile updates (PATCH /api/users/:id).

Tech stack: Go 1.22 + Chi router (detected from project)

Requirements:
- PATCH /api/users/:id — partial update of user profile
- Input validation for fields: name, email, avatar_url, bio
- Auth: require valid token, users can only update own profile
- Return 200 with updated user on success
- Return 400 with validation errors on invalid input
- Return 401/403 for auth failures
- Follow existing API patterns in the codebase

Workflow:
1. /plan the endpoint structure, middleware chain, and validation logic
2. /tdd — write table-driven tests for success, validation failure, auth failure, not-found
3. Implement following existing handler patterns
4. /go-review
5. /verify — run full test suite, confirm no regressions

Do not:
- Modify existing endpoints
- Change the database schema (use existing user table)
- Add new dependencies without checking existing ones first (use search-first skill)
```

### 例 3: EPIC プロジェクト

**ユーザー入力:**
```
Migrate our monolith to microservices
```

**最適化プロンプト（フル）:**
```
Use the blueprint skill to plan: "Migrate monolith to microservices architecture"

Before executing, answer these questions in the blueprint:
1. Which domain boundaries exist in the current monolith?
2. Which service should be extracted first (lowest coupling)?
3. Communication pattern: REST APIs, gRPC, or event-driven (Kafka/RabbitMQ)?
4. Database strategy: shared DB initially or database-per-service from start?
5. Deployment target: Kubernetes, Docker Compose, or serverless?

The blueprint should produce phases like:
- Phase 1: Identify service boundaries and create domain map
- Phase 2: Set up infrastructure (API gateway, service mesh, CI/CD per service)
- Phase 3: Extract first service (strangler fig pattern)
- Phase 4: Verify with integration tests, then extract next service
- Phase N: Decommission monolith

Each phase = 1 PR, with /verify gates between phases.
Use /save-session between phases. Use /resume-session to continue.
Use git worktrees for parallel service extraction when dependencies allow.

Recommended: Opus 4.6 for blueprint planning, Sonnet 4.6 for phase execution.
```

---

## 関連コンポーネント

| コンポーネント | 参照タイミング |
|-------------|---------------|
| `configure-ecc` | ユーザーがまだ ECC をセットアップしていない場合 |
| `skill-stocktake` | インストール済みコンポーネントの監査（ハードコードされたカタログの代わりに使用） |
| `search-first` | 最適化プロンプトのリサーチフェーズ |
| `blueprint` | EPIC スコープの最適化プロンプト（コマンドではなくスキルとして呼び出し） |
| `strategic-compact` | 長時間セッションのコンテキスト管理 |
| `cost-aware-llm-pipeline` | トークン最適化の推奨 |
