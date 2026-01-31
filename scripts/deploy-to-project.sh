#!/bin/bash
# =============================================================================
# deploy-to-project.sh
# Claude Code テンプレートを対象プロジェクトにデプロイする
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="${WORKSPACE_DIR}/template-.claude"
MANIFEST_FILE="${TEMPLATE_DIR}/MANIFEST.md"

# デフォルト設定
DRY_RUN=false
FORCE=false
PRESET=""
LEVEL=""
TYPE=""
INTERACTIVE=false

# 使用方法
usage() {
    echo "使用方法: $0 <target-project-path> [options]"
    echo ""
    echo "オプション:"
    echo "  --preset <name>      プリセットを使用"
    echo "                       minimal, standard, standard-web, full"
    echo "  --level <levels>     レベルでフィルタ（カンマ区切り）"
    echo "                       beginner, intermediate, advanced"
    echo "  --type <types>       タイプでフィルタ（カンマ区切り）"
    echo "                       general, web"
    echo "  --interactive, -i    対話モードで選択"
    echo "  --force              既存ファイルを強制上書き（-migrated なし）"
    echo "  --dry-run            実際にはコピーしない（確認のみ）"
    echo "  -h, --help           このヘルプを表示"
    echo ""
    echo "プリセット:"
    echo "  minimal       初級 + 汎用のみ（約15ファイル）"
    echo "  standard      初級・中級 + 汎用（約35ファイル）"
    echo "  standard-web  初級・中級 + 汎用・Web（約40ファイル）"
    echo "  full          全て（約52ファイル）"
    echo ""
    echo "例:"
    echo "  $0 /path/to/project --preset minimal"
    echo "  $0 /path/to/project --preset standard-web"
    echo "  $0 /path/to/project --level beginner,intermediate --type general"
    echo "  $0 /path/to/project -i"
    exit 1
}

# 引数解析
TARGET_DIR=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --preset)
            PRESET="$2"
            shift 2
            ;;
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --type)
            TYPE="$2"
            shift 2
            ;;
        --interactive|-i)
            INTERACTIVE=true
            shift
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

# 対話モード
if [ "$INTERACTIVE" = true ]; then
    echo "=== Claude Code テンプレート デプロイウィザード ==="
    echo ""
    echo "プリセットを選択してください:"
    echo ""
    echo "  1) minimal       - 初級のみ（すぐに使える基本セット）"
    echo "  2) standard      - 初級・中級（推奨）"
    echo "  3) standard-web  - 初級・中級 + Web開発向け"
    echo "  4) full          - 全て"
    echo "  5) custom        - カスタム選択"
    echo ""
    read -p "選択 [1-5]: " choice

    case $choice in
        1) PRESET="minimal" ;;
        2) PRESET="standard" ;;
        3) PRESET="standard-web" ;;
        4) PRESET="full" ;;
        5)
            echo ""
            echo "レベルを選択（複数可、カンマ区切り）:"
            echo "  beginner, intermediate, advanced"
            read -p "レベル: " LEVEL
            echo ""
            echo "タイプを選択（複数可、カンマ区切り）:"
            echo "  general, web"
            read -p "タイプ: " TYPE
            ;;
        *)
            echo "無効な選択です"
            exit 1
            ;;
    esac
    echo ""
fi

# プリセットの展開
case $PRESET in
    minimal)
        LEVEL="beginner"
        TYPE="general"
        ;;
    standard)
        LEVEL="beginner,intermediate"
        TYPE="general"
        ;;
    standard-web)
        LEVEL="beginner,intermediate"
        TYPE="general,web"
        ;;
    full)
        LEVEL="beginner,intermediate,advanced"
        TYPE="general,web"
        ;;
    "")
        # プリセットなし - デフォルトは全て
        if [ -z "$LEVEL" ]; then
            LEVEL="beginner,intermediate,advanced"
        fi
        if [ -z "$TYPE" ]; then
            TYPE="general,web"
        fi
        ;;
    *)
        echo "エラー: 不明なプリセット: $PRESET"
        usage
        ;;
esac

echo "=== Claude Code テンプレートのデプロイ ==="
echo ""
echo "ソース: ${TEMPLATE_DIR}"
echo "ターゲット: ${TARGET_CLAUDE_DIR}"
echo ""
if [ -n "$PRESET" ]; then
    echo "プリセット: ${PRESET}"
fi
echo "レベル: ${LEVEL}"
echo "タイプ: ${TYPE}"
echo ""

# ドライランモード
if [ "$DRY_RUN" = true ]; then
    echo "[ドライラン] 実際にはコピーしません"
    echo ""
fi

# 単一ファイルのコピー（衝突処理付き）
# 戻り値: 0=コピー成功, 1=スキップ, 2=migrated としてコピー
SKIP_COUNT=0
MIGRATED_COUNT=0

copy_single_file() {
    local src_file=$1
    local dest_dir=$2
    local filename=$(basename "$src_file")
    local dest_file="${dest_dir}/${filename}"

    if [ -f "$dest_file" ]; then
        if [ "$FORCE" = true ]; then
            cp "$src_file" "$dest_file"
            return 0
        fi
        # 拡張子の前に -migrated を付与
        local base="${filename%.*}"
        local ext="${filename##*.}"
        local migrated_file="${dest_dir}/${base}-migrated.${ext}"

        if [ -f "$migrated_file" ]; then
            echo "    [スキップ] ${filename} (既存 + migrated 両方存在)"
            SKIP_COUNT=$((SKIP_COUNT + 1))
            return 1
        fi

        cp "$src_file" "$migrated_file"
        echo "    [migrated] ${filename} → ${base}-migrated.${ext}"
        MIGRATED_COUNT=$((MIGRATED_COUNT + 1))
        return 0
    fi

    cp "$src_file" "$dest_file"
    return 0
}

# MANIFESTからファイルリストを取得
get_files_for_category() {
    local category=$1
    local level_filter=$2
    local type_filter=$3

    # MANIFESTを解析してファイルリストを取得
    local in_section=false
    local files=""

    while IFS= read -r line; do
        # セクション開始を検出
        if [[ "$line" =~ ^##[[:space:]]+(Agents|Commands|Rules|Skills|Contexts) ]]; then
            section_name=$(echo "$line" | sed 's/^## //')
            if [ "$section_name" = "$category" ]; then
                in_section=true
            else
                in_section=false
            fi
            continue
        fi

        # セクション内のテーブル行を解析
        if [ "$in_section" = true ] && [[ "$line" =~ ^\|[[:space:]]*\` ]]; then
            # | `filename` | level | type | description | の形式
            filename=$(echo "$line" | cut -d'|' -f2 | tr -d ' `')
            level=$(echo "$line" | cut -d'|' -f3 | tr -d ' ')
            type=$(echo "$line" | cut -d'|' -f4 | tr -d ' ')

            # フィルタチェック
            level_match=false
            type_match=false

            IFS=',' read -ra LEVELS <<< "$level_filter"
            for l in "${LEVELS[@]}"; do
                if [ "$l" = "$level" ]; then
                    level_match=true
                    break
                fi
            done

            IFS=',' read -ra TYPES <<< "$type_filter"
            for t in "${TYPES[@]}"; do
                if [ "$t" = "$type" ]; then
                    type_match=true
                    break
                fi
            done

            if [ "$level_match" = true ] && [ "$type_match" = true ]; then
                files="$files $filename"
            fi
        fi
    done < "$MANIFEST_FILE"

    echo "$files"
}

# コピー関数
copy_files() {
    local category=$1
    local category_lower=$(echo "$category" | tr '[:upper:]' '[:lower:]')
    local src_dir="${TEMPLATE_DIR}/${category_lower}"
    local dest_dir="${TARGET_CLAUDE_DIR}/${category_lower}"
    local files=$(get_files_for_category "$category" "$LEVEL" "$TYPE")

    if [ -z "$files" ]; then
        echo "  [スキップ] ${category}: 該当ファイルなし"
        return
    fi

    local count=0

    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$dest_dir"
    fi

    for filename in $files; do
        if [ "$category" = "Skills" ]; then
            # Skills はディレクトリ
            local skill_name="${filename%/}"
            local src_skill_dir="${src_dir}/${skill_name}"
            local dest_skill_dir="${dest_dir}/${skill_name}"

            if [ -d "$src_skill_dir" ]; then
                if [ "$DRY_RUN" = false ]; then
                    mkdir -p "$dest_skill_dir"
                    for f in "$src_skill_dir"/*.md; do
                        if [ -f "$f" ] && [ "$(basename "$f")" != "CLAUDE.md" ]; then
                            copy_single_file "$f" "$dest_skill_dir"
                        fi
                    done
                fi
                count=$((count + 1))
            fi
        else
            # その他はファイル
            local src_file="${src_dir}/${filename}"
            if [ -f "$src_file" ]; then
                if [ "$DRY_RUN" = false ]; then
                    copy_single_file "$src_file" "$dest_dir"
                fi
                count=$((count + 1))
            fi
        fi
    done

    if [ "$DRY_RUN" = true ]; then
        echo "  [ドライラン] ${category}: ${count} items"
    else
        echo "  [完了] ${category}: ${count} items"
    fi
}

# メイン処理
echo "[1/2] ディレクトリを準備中..."
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$TARGET_CLAUDE_DIR"
fi
echo ""

echo "[2/2] ファイルをコピー中..."
copy_files "Agents"
copy_files "Commands"
copy_files "Rules"
copy_files "Skills"
copy_files "Contexts"
echo ""

# 結果表示
if [ "$DRY_RUN" = false ]; then
    echo "=== デプロイ完了 ==="
    echo ""
    echo "配置先: ${TARGET_CLAUDE_DIR}"
    echo ""

    total_count=$(find "$TARGET_CLAUDE_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "合計: ${total_count} files"
    if [ "$MIGRATED_COUNT" -gt 0 ]; then
        echo "  -migrated 付与: ${MIGRATED_COUNT} files"
    fi
    if [ "$SKIP_COUNT" -gt 0 ]; then
        echo "  スキップ: ${SKIP_COUNT} files"
    fi
else
    echo "=== ドライラン完了 ==="
    echo ""
    echo "--dry-run を外して実行すると実際にコピーされます"
fi
echo ""
echo "次のステップ:"
echo "  1. 配置されたファイルを確認"
echo "  2. <!-- CUSTOMIZE: ... --> コメントの箇所をプロジェクトに合わせて調整"
