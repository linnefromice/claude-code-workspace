#!/bin/bash
# =============================================================================
# deploy-templates.sh
# 翻訳・汎用化済みファイルをテンプレートディレクトリに配置する
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="${WORKSPACE_DIR}/.work"
TEMPLATE_DIR="${WORKSPACE_DIR}/setup-claude-code-config"

echo "=== テンプレート配置 ==="
echo ""

# 作業ディレクトリの確認
if [ ! -d "${WORK_DIR}/translated" ]; then
    echo "エラー: 翻訳済みファイルが見つかりません"
    echo "先に ./scripts/setup-templates.sh を実行し、翻訳を完了してください"
    exit 1
fi

# テンプレートディレクトリの作成
echo "[1/3] テンプレートディレクトリを準備中..."
mkdir -p "${TEMPLATE_DIR}"/{agents,commands,rules,skills,contexts}

# ファイルのコピー（.ja.md を .md にリネーム）
echo "[2/3] ファイルを配置中..."

copy_and_rename() {
    local src_dir=$1
    local dest_dir=$2
    local count=0

    for f in "${src_dir}"/*.ja.md 2>/dev/null; do
        if [ -f "$f" ]; then
            local basename=$(basename "$f" .ja.md)
            cp "$f" "${dest_dir}/${basename}.md"
            ((count++))
        fi
    done
    echo "  ${dest_dir##*/}: ${count} files"
}

copy_and_rename "${WORK_DIR}/translated/agents" "${TEMPLATE_DIR}/agents"
copy_and_rename "${WORK_DIR}/translated/commands" "${TEMPLATE_DIR}/commands"
copy_and_rename "${WORK_DIR}/translated/rules" "${TEMPLATE_DIR}/rules"
copy_and_rename "${WORK_DIR}/translated/skills" "${TEMPLATE_DIR}/skills"
copy_and_rename "${WORK_DIR}/translated/contexts" "${TEMPLATE_DIR}/contexts"

# README のコピー
if [ -f "${WORK_DIR}/translated/README.ja.md" ]; then
    cp "${WORK_DIR}/translated/README.ja.md" "${TEMPLATE_DIR}/README.md"
    echo "  README: 1 file"
fi

# 配置結果の表示
echo ""
echo "[3/3] 配置結果を確認中..."
echo ""
echo "=== 配置済みファイル ==="
find "${TEMPLATE_DIR}" -name "*.md" -type f | sort

echo ""
echo "=== 配置完了 ==="
echo ""
echo "テンプレートディレクトリ: ${TEMPLATE_DIR}"
echo ""
echo "次のステップ:"
echo "  1. 配置されたファイルを確認・調整"
echo "  2. 不要なファイル（Go固有等）を削除"
echo "  3. git add && git commit"
