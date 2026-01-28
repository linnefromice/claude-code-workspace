#!/bin/bash
# =============================================================================
# deploy-to-project.sh
# Claude Code テンプレートを対象プロジェクトにデプロイする
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="${WORKSPACE_DIR}/template-.claude"

# デフォルト設定
DRY_RUN=false
FORCE=false
ONLY_CATEGORIES=""

# 使用方法
usage() {
    echo "使用方法: $0 <target-project-path> [options]"
    echo ""
    echo "オプション:"
    echo "  --only <categories>  指定したカテゴリのみコピー（カンマ区切り）"
    echo "                       例: --only agents,rules"
    echo "  --force              既存ファイルを上書き"
    echo "  --dry-run            実際にはコピーしない（確認のみ）"
    echo "  -h, --help           このヘルプを表示"
    echo ""
    echo "カテゴリ: agents, commands, rules, skills, contexts"
    echo ""
    echo "例:"
    echo "  $0 /path/to/project"
    echo "  $0 /path/to/project --only agents,rules"
    echo "  $0 /path/to/project --force"
    echo "  $0 /path/to/project --dry-run"
    exit 1
}

# 引数解析
TARGET_DIR=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --only)
            ONLY_CATEGORIES="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo "エラー: 不明なオプション: $1"
            usage
            ;;
        *)
            if [ -z "$TARGET_DIR" ]; then
                TARGET_DIR="$1"
            else
                echo "エラー: 複数のターゲットディレクトリが指定されています"
                usage
            fi
            shift
            ;;
    esac
done

# ターゲットディレクトリの検証
if [ -z "$TARGET_DIR" ]; then
    echo "エラー: ターゲットプロジェクトのパスを指定してください"
    usage
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "エラー: ディレクトリが存在しません: $TARGET_DIR"
    exit 1
fi

# 絶対パスに変換
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
TARGET_CLAUDE_DIR="${TARGET_DIR}/.claude"

echo "=== Claude Code テンプレートのデプロイ ==="
echo ""
echo "ソース: ${TEMPLATE_DIR}"
echo "ターゲット: ${TARGET_CLAUDE_DIR}"
echo ""

# カテゴリの決定
ALL_CATEGORIES="agents commands rules skills contexts"
if [ -n "$ONLY_CATEGORIES" ]; then
    CATEGORIES=$(echo "$ONLY_CATEGORIES" | tr ',' ' ')
    echo "対象カテゴリ: ${CATEGORIES}"
else
    CATEGORIES="$ALL_CATEGORIES"
    echo "対象カテゴリ: 全て"
fi
echo ""

# ドライランモード
if [ "$DRY_RUN" = true ]; then
    echo "[ドライラン] 実際にはコピーしません"
    echo ""
fi

# 既存チェック
if [ -d "$TARGET_CLAUDE_DIR" ] && [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
    echo "警告: ${TARGET_CLAUDE_DIR} は既に存在します"
    echo ""
    read -p "上書きしますか？ (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "キャンセルしました"
        exit 0
    fi
    echo ""
fi

# コピー関数
copy_category() {
    local category=$1
    local src_dir="${TEMPLATE_DIR}/${category}"
    local dest_dir="${TARGET_CLAUDE_DIR}/${category}"

    if [ ! -d "$src_dir" ]; then
        echo "  [スキップ] ${category}: ソースディレクトリが存在しません"
        return
    fi

    # ファイル数をカウント（CLAUDE.md を除外）
    local file_count=$(find "$src_dir" -type f -name "*.md" ! -name "CLAUDE.md" | wc -l | tr -d ' ')

    if [ "$DRY_RUN" = true ]; then
        echo "  [ドライラン] ${category}: ${file_count} files"
        return
    fi

    # ディレクトリ作成
    mkdir -p "$dest_dir"

    # ファイルをコピー（CLAUDE.md を除外）
    if [ "$category" = "skills" ]; then
        # skills はサブディレクトリ構造
        for skill_dir in "$src_dir"/*/; do
            if [ -d "$skill_dir" ]; then
                local skill_name=$(basename "$skill_dir")
                mkdir -p "${dest_dir}/${skill_name}"

                for f in "$skill_dir"/*.md; do
                    if [ -f "$f" ] && [ "$(basename "$f")" != "CLAUDE.md" ]; then
                        cp "$f" "${dest_dir}/${skill_name}/"
                    fi
                done
            fi
        done
    else
        # その他のカテゴリはフラット構造
        for f in "$src_dir"/*.md; do
            if [ -f "$f" ] && [ "$(basename "$f")" != "CLAUDE.md" ]; then
                cp "$f" "$dest_dir/"
            fi
        done
    fi

    echo "  [完了] ${category}: ${file_count} files"
}

# メイン処理
echo "[1/2] ディレクトリを準備中..."
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$TARGET_CLAUDE_DIR"
fi
echo ""

echo "[2/2] ファイルをコピー中..."
for category in $CATEGORIES; do
    copy_category "$category"
done
echo ""

# 結果表示
if [ "$DRY_RUN" = false ]; then
    echo "=== デプロイ完了 ==="
    echo ""
    echo "配置先: ${TARGET_CLAUDE_DIR}"
    echo ""
    echo "配置されたファイル:"
    find "$TARGET_CLAUDE_DIR" -name "*.md" -type f | sort | head -20

    local total_count=$(find "$TARGET_CLAUDE_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
    if [ "$total_count" -gt 20 ]; then
        echo "  ... (他 $((total_count - 20)) files)"
    fi
    echo ""
    echo "合計: ${total_count} files"
else
    echo "=== ドライラン完了 ==="
    echo ""
    echo "--dry-run を外して実行すると実際にコピーされます"
fi
echo ""
echo "次のステップ:"
echo "  1. 配置されたファイルを確認"
echo "  2. <!-- CUSTOMIZE: ... --> コメントの箇所をプロジェクトに合わせて調整"
