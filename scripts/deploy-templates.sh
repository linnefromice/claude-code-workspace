#!/bin/bash
# =============================================================================
# deploy-templates.sh
# 翻訳・汎用化済みファイルをテンプレートディレクトリに配置する
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
WORK_DIR="${WORKSPACE_DIR}/.work"
TEMPLATE_DIR="${WORKSPACE_DIR}/template-.claude"

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

    shopt -s nullglob
    for f in "${src_dir}"/*.ja.md; do
        if [ -f "$f" ]; then
            local basename=$(basename "$f" .ja.md)
            cp "$f" "${dest_dir}/${basename}.md"
            count=$((count + 1))
        fi
    done
    shopt -u nullglob
    echo "  ${dest_dir##*/}: ${count} files"
}

copy_and_rename "${WORK_DIR}/translated/agents" "${TEMPLATE_DIR}/agents"
copy_and_rename "${WORK_DIR}/translated/commands" "${TEMPLATE_DIR}/commands"
copy_and_rename "${WORK_DIR}/translated/contexts" "${TEMPLATE_DIR}/contexts"

# Rules はサブディレクトリ構造（common/, typescript/ 等）に対応
echo "  rules:"
rules_count=0
shopt -s nullglob
# ルートレベルの .ja.md ファイル（README.ja.md 等）
for f in "${WORK_DIR}/translated/rules"/*.ja.md; do
    if [ -f "$f" ]; then
        local_basename=$(basename "$f" .ja.md)
        cp "$f" "${TEMPLATE_DIR}/rules/${local_basename}.md"
        rules_count=$((rules_count + 1))
    fi
done
# サブディレクトリ（common/, typescript/ 等）
for rules_subdir in "${WORK_DIR}/translated/rules"/*/; do
    if [ -d "$rules_subdir" ]; then
        subdir_name=$(basename "$rules_subdir")
        # CLAUDE.md のみのディレクトリはスキップ
        ja_files=("${rules_subdir}"*.ja.md)
        if [ ${#ja_files[@]} -eq 0 ]; then
            continue
        fi
        mkdir -p "${TEMPLATE_DIR}/rules/${subdir_name}"
        for f in "${rules_subdir}"*.ja.md; do
            if [ -f "$f" ]; then
                local_basename=$(basename "$f" .ja.md)
                cp "$f" "${TEMPLATE_DIR}/rules/${subdir_name}/${local_basename}.md"
                rules_count=$((rules_count + 1))
            fi
        done
    fi
done
shopt -u nullglob
echo "    ${rules_count} files"

# Skills は特別な処理（サブディレクトリ構造）
echo "  skills:"
skill_count=0
shopt -s nullglob
for skill_dir in "${WORK_DIR}/translated/skills"/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        mkdir -p "${TEMPLATE_DIR}/skills/${skill_name}"

        # SKILL.ja.md を SKILL.md にリネームしてコピー
        if [ -f "${skill_dir}/SKILL.ja.md" ]; then
            cp "${skill_dir}/SKILL.ja.md" "${TEMPLATE_DIR}/skills/${skill_name}/SKILL.md"
            skill_count=$((skill_count + 1))
        fi

        # その他のファイルもコピー（あれば）
        for f in "${skill_dir}"/*.ja.md; do
            if [ -f "$f" ] && [ "$(basename "$f")" != "SKILL.ja.md" ]; then
                local basename=$(basename "$f" .ja.md)
                cp "$f" "${TEMPLATE_DIR}/skills/${skill_name}/${basename}.md"
            fi
        done
    fi
done
shopt -u nullglob
echo "    ${skill_count} skill directories"

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
echo "  3. git add template-.claude/ && git commit"
