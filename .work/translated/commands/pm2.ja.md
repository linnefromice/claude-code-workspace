# PM2 Init

プロジェクトを自動分析し、PM2サービスコマンドを生成します。

**コマンド**: `$ARGUMENTS`

---

## ワークフロー

1. PM2の確認（未インストールの場合は `npm install -g pm2` でインストール）
2. プロジェクトをスキャンしてサービスを識別（フロントエンド/バックエンド/データベース）
3. 設定ファイルと個別コマンドファイルを生成

---

## サービス検出

| タイプ | 検出方法 | デフォルトポート |
|--------|---------|----------------|
| Vite | vite.config.* | 5173 |
| Next.js | next.config.* | 3000 |
| Nuxt | nuxt.config.* | 3000 |
| CRA | package.json内のreact-scripts | 3000 |
| Express/Node | server/backend/apiディレクトリ + package.json | 3000 |
| FastAPI/Flask | requirements.txt / pyproject.toml | 8000 |
| Go | go.mod / main.go | 8080 |

**ポート検出優先順位**: ユーザー指定 > .env > 設定ファイル > scriptsの引数 > デフォルトポート

---

## 生成ファイル

```
project/
├── ecosystem.config.cjs              # PM2設定
├── {backend}/start.cjs               # Pythonラッパー（該当する場合）
└── .claude/
    ├── commands/
    │   ├── pm2-all.md                # 全サービス起動 + monit
    │   ├── pm2-all-stop.md           # 全サービス停止
    │   ├── pm2-all-restart.md        # 全サービス再起動
    │   ├── pm2-{port}.md             # 単一サービス起動 + ログ
    │   ├── pm2-{port}-stop.md        # 単一サービス停止
    │   ├── pm2-{port}-restart.md     # 単一サービス再起動
    │   ├── pm2-logs.md               # 全ログ表示
    │   └── pm2-status.md             # ステータス表示
    └── scripts/
        ├── pm2-logs-{port}.ps1       # 単一サービスログ
        └── pm2-monit.ps1             # PM2モニター
```

---

## Windows設定（重要）

### ecosystem.config.cjs

**`.cjs` 拡張子を必ず使用すること**

```javascript
module.exports = {
  apps: [
    // Node.js (Vite/Next/Nuxt)
    {
      name: 'project-3000',
      cwd: './packages/web',
      script: 'node_modules/vite/bin/vite.js',
      args: '--port 3000',
      interpreter: 'C:/Program Files/nodejs/node.exe',
      env: { NODE_ENV: 'development' }
    },
    // Python
    {
      name: 'project-8000',
      cwd: './backend',
      script: 'start.cjs',
      interpreter: 'C:/Program Files/nodejs/node.exe',
      env: { PYTHONUNBUFFERED: '1' }
    }
  ]
}
```

**フレームワーク別スクリプトパス:**

| フレームワーク | script | args |
|--------------|--------|------|
| Vite | `node_modules/vite/bin/vite.js` | `--port {port}` |
| Next.js | `node_modules/next/dist/bin/next` | `dev -p {port}` |
| Nuxt | `node_modules/nuxt/bin/nuxt.mjs` | `dev --port {port}` |
| Express | `src/index.js` or `server.js` | - |

### Pythonラッパースクリプト (start.cjs)

```javascript
const { spawn } = require('child_process');
const proc = spawn('python', ['-m', 'uvicorn', 'app.main:app', '--host', '0.0.0.0', '--port', '8000', '--reload'], {
  cwd: __dirname, stdio: 'inherit', windowsHide: true
});
proc.on('close', (code) => process.exit(code));
```

---

## コマンドファイルテンプレート（最小限の内容）

### pm2-all.md（全サービス起動 + monit）
```markdown
全サービスを起動し、PM2モニターを開きます。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 start ecosystem.config.cjs && start wt.exe -d "{PROJECT_ROOT}" pwsh -NoExit -c "pm2 monit"
\`\`\`
```

### pm2-all-stop.md
```markdown
全サービスを停止します。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 stop all
\`\`\`
```

### pm2-all-restart.md
```markdown
全サービスを再起動します。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 restart all
\`\`\`
```

### pm2-{port}.md（単一サービス起動 + ログ）
```markdown
{name}（{port}）を起動し、ログを開きます。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 start ecosystem.config.cjs --only {name} && start wt.exe -d "{PROJECT_ROOT}" pwsh -NoExit -c "pm2 logs {name}"
\`\`\`
```

### pm2-{port}-stop.md
```markdown
{name}（{port}）を停止します。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 stop {name}
\`\`\`
```

### pm2-{port}-restart.md
```markdown
{name}（{port}）を再起動します。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 restart {name}
\`\`\`
```

### pm2-logs.md
```markdown
PM2の全ログを表示します。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 logs
\`\`\`
```

### pm2-status.md
```markdown
PM2のステータスを表示します。
\`\`\`bash
cd "{PROJECT_ROOT}" && pm2 status
\`\`\`
```

### PowerShellスクリプト (pm2-logs-{port}.ps1)
```powershell
Set-Location "{PROJECT_ROOT}"
pm2 logs {name}
```

### PowerShellスクリプト (pm2-monit.ps1)
```powershell
Set-Location "{PROJECT_ROOT}"
pm2 monit
```

---

## 重要ルール

1. **設定ファイル**: `ecosystem.config.cjs`（.jsではない）
2. **Node.js**: binパスを直接指定 + interpreter
3. **Python**: Node.jsラッパースクリプト + `windowsHide: true`
4. **新しいウィンドウを開く**: `start wt.exe -d "{path}" pwsh -NoExit -c "command"`
5. **最小限の内容**: 各コマンドファイルは1-2行の説明 + bashブロックのみ
6. **直接実行**: AI解析不要、bashコマンドを直接実行するだけ

---

## 実行

`$ARGUMENTS` に基づき、初期化を実行:

1. プロジェクトのサービスをスキャン
2. `ecosystem.config.cjs` を生成
3. Pythonサービス用の `{backend}/start.cjs` を生成（該当する場合）
4. `.claude/commands/` にコマンドファイルを生成
5. `.claude/scripts/` にスクリプトファイルを生成
6. **プロジェクトの CLAUDE.md を PM2情報で更新**（下記参照）
7. **完了サマリーを表示**（ターミナルコマンド付き）

---

## 初期化後: CLAUDE.mdの更新

ファイル生成後、プロジェクトの `CLAUDE.md` にPM2セクションを追加（存在しない場合は作成）:

```markdown
## PM2 Services

| Port | Name | Type |
|------|------|------|
| {port} | {name} | {type} |

**Terminal Commands:**
```bash
pm2 start ecosystem.config.cjs   # 初回起動
pm2 start all                    # 初回以降
pm2 stop all / pm2 restart all
pm2 start {name} / pm2 stop {name}
pm2 logs / pm2 status / pm2 monit
pm2 save                         # プロセスリストを保存
pm2 resurrect                    # 保存リストを復元
```
```

**CLAUDE.md更新ルール:**
- PM2セクションが既に存在する場合は置換
- 存在しない場合は末尾に追加
- 内容は最小限かつ必要不可欠なもののみ

---

## 初期化後: サマリー表示

全ファイル生成後、以下を出力:

```
## PM2 Init Complete

**Services:**
| Port | Name | Type |
|------|------|------|
| {port} | {name} | {type} |

**Claude Commands:** /pm2-all, /pm2-all-stop, /pm2-{port}, /pm2-{port}-stop, /pm2-logs, /pm2-status

**Terminal Commands:**
# 初回起動（設定ファイル使用）
pm2 start ecosystem.config.cjs && pm2 save

# 初回以降（簡略化）
pm2 start all          # 全サービス起動
pm2 stop all           # 全サービス停止
pm2 restart all        # 全サービス再起動
pm2 start {name}       # 単一サービス起動
pm2 stop {name}        # 単一サービス停止
pm2 logs               # ログ表示
pm2 monit              # モニターパネル
pm2 resurrect          # 保存したプロセスを復元

**ヒント:** 初回起動後に `pm2 save` を実行すると、簡略化コマンドが使用可能になります。
```
