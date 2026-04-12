> このファイルは [common/hooks.md](../common/hooks.md) を Web 固有のフック推奨事項で拡張します。

# Web フック

## 推奨される PostToolUse フック

プロジェクトローカルのツールを優先してください。リモートの単発パッケージ実行にフックを配線しないでください。

### 保存時のフォーマット

編集後にプロジェクト既存のフォーマッタエントリーポイントを使用してください：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "pnpm prettier --write \"$FILE_PATH\"",
        "description": "Format edited frontend files"
      }
    ]
  }
}
```

`yarn prettier` や `npm exec prettier --` 経由の同等のローカルコマンドも、リポジトリ所有の依存関係を使う限りは問題ありません。

### Lint チェック

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "pnpm eslint --fix \"$FILE_PATH\"",
        "description": "Run ESLint on edited frontend files"
      }
    ]
  }
}
```

### 型チェック

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "pnpm tsc --noEmit --pretty false",
        "description": "Type-check after frontend edits"
      }
    ]
  }
}
```

### CSS Lint

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "pnpm stylelint --fix \"$FILE_PATH\"",
        "description": "Lint edited stylesheets"
      }
    ]
  }
}
```

## PreToolUse フック

### ファイルサイズのガード

まだ存在しないかもしれないファイルではなく、ツール入力の content から過大な書き込みをブロックしてください：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "command": "node -e \"let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const i=JSON.parse(d);const c=i.tool_input?.content||'';const lines=c.split('\\n').length;if(lines>800){console.error('[Hook] BLOCKED: File exceeds 800 lines ('+lines+' lines)');console.error('[Hook] Split into smaller modules');process.exit(2)}console.log(d)})\"",
        "description": "Block writes that exceed 800 lines"
      }
    ]
  }
}
```

## Stop フック

### 最終ビルド検証

```json
{
  "hooks": {
    "Stop": [
      {
        "command": "pnpm build",
        "description": "Verify the production build at session end"
      }
    ]
  }
}
```

## 実行順序

推奨される順序：
1. format
2. lint
3. 型チェック
4. ビルド検証
