---
name: skill-health
description: チャートと分析を含むスキルポートフォリオのヘルスダッシュボードを表示
command: true
---

# スキルヘルスダッシュボード

ポートフォリオ内のすべてのスキルの包括的なヘルスダッシュボードを表示します。成功率のスパークライン、失敗パターンのクラスタリング、保留中の修正提案、バージョン履歴を含みます。

## 実装

ダッシュボードモードでスキルヘルスCLIを実行:

```bash
ECC_ROOT="${CLAUDE_PLUGIN_ROOT:-$(node -e "var p=require('path'),f=require('fs'),h=require('os').homedir(),d=p.join(h,'.claude'),q=p.join('scripts','lib','utils.js');if(!f.existsSync(p.join(d,q))){try{var b=p.join(d,'plugins','cache','everything-claude-code');for(var o of f.readdirSync(b))for(var v of f.readdirSync(p.join(b,o))){var c=p.join(b,o,v);if(f.existsSync(p.join(c,q))){d=c;break}}}catch(x){}}console.log(d)")}"
node "$ECC_ROOT/scripts/skills-health.js" --dashboard
```

特定のパネルのみ:

```bash
node "$ECC_ROOT/scripts/skills-health.js" --dashboard --panel failures
```

機械読み取り可能な出力:

```bash
node "$ECC_ROOT/scripts/skills-health.js" --dashboard --json
```

## 使用方法

```
/skill-health                    # フルダッシュボードビュー
/skill-health --panel failures   # 失敗クラスタリングパネルのみ
/skill-health --json             # 機械読み取り可能なJSON出力
```

## 処理内容

1. --dashboardフラグ付きでskills-health.jsスクリプトを実行
2. 出力をユーザーに表示
3. 下降傾向のスキルがある場合はハイライトし、/evolveの実行を提案
4. 保留中の修正提案がある場合はレビューを提案

## パネル

- **成功率（30日）** — スキルごとの日次成功率のスパークラインチャート
- **失敗パターン** — クラスタリングされた失敗理由の水平バーチャート
- **保留中の修正提案** — レビュー待ちの修正提案
- **バージョン履歴** — スキルごとのバージョンスナップショットのタイムライン
