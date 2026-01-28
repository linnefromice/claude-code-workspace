#!/bin/bash
# =============================================================================
# setup-templates.sh
# Everything Claude Code リポジトリをクローンし、翻訳作業の準備を行う
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="${WORKSPACE_DIR}/.work"
SOURCE_REPO="https://github.com/affaan-m/everything-claude-code.git"

echo "=== Claude Code テンプレート セットアップ ==="
echo ""

# 作業ディレクトリの作成
echo "[1/4] 作業ディレクトリを準備中..."
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"

# リポジトリのクローン
echo "[2/4] ソースリポジトリをクローン中..."
git clone --depth 1 "${SOURCE_REPO}" "${WORK_DIR}/source"

# 翻訳出力ディレクトリの作成
echo "[3/4] 翻訳出力ディレクトリを作成中..."
mkdir -p "${WORK_DIR}/translated"/{agents,commands,rules,skills,contexts}

# 翻訳対象ファイルの一覧表示
echo "[4/4] 翻訳対象ファイルを確認中..."
echo ""
echo "=== 翻訳対象ファイル一覧 ==="
echo ""
echo "--- Agents ($(ls "${WORK_DIR}/source/agents"/*.md 2>/dev/null | wc -l | tr -d ' ') files) ---"
ls "${WORK_DIR}/source/agents"/*.md 2>/dev/null | xargs -I {} basename {}
echo ""
echo "--- Commands ($(ls "${WORK_DIR}/source/commands"/*.md 2>/dev/null | wc -l | tr -d ' ') files) ---"
ls "${WORK_DIR}/source/commands"/*.md 2>/dev/null | xargs -I {} basename {}
echo ""
echo "--- Rules ($(ls "${WORK_DIR}/source/rules"/*.md 2>/dev/null | wc -l | tr -d ' ') files) ---"
ls "${WORK_DIR}/source/rules"/*.md 2>/dev/null | xargs -I {} basename {}
echo ""
echo "--- Skills ($(ls -d "${WORK_DIR}/source/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') directories) ---"
ls -d "${WORK_DIR}/source/skills"/*/ 2>/dev/null | xargs -I {} basename {}
echo ""
echo "--- Contexts ($(ls "${WORK_DIR}/source/contexts"/*.md 2>/dev/null | wc -l | tr -d ' ') files) ---"
ls "${WORK_DIR}/source/contexts"/*.md 2>/dev/null | xargs -I {} basename {}
echo ""

echo "=== セットアップ完了 ==="
echo ""
echo "次のステップ:"
echo "  1. Claude Code で以下を実行:"
echo "     do @prompts/translate-to-ja.md"
echo ""
echo "  2. 翻訳完了後、汎用化を実行:"
echo "     do @prompts/generalize-claude-templates.md"
echo ""
echo "  3. 配置スクリプトを実行:"
echo "     ./scripts/deploy-templates.sh"
echo ""
echo "作業ディレクトリ: ${WORK_DIR}"
