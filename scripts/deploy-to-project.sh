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
ADDON=""
ADDON_ONLY=false
SHOW_STATUS=false
INTERACTIVE=false

# 使用方法
usage() {
    echo "使用方法: $0 <target-project-path> [options]"
    echo ""
    echo "オプション:"
    echo "  --preset <name>      プリセットを使用"
    echo "                       minimal, standard, standard-web,"
    echo "                       standard-learning, standard-multi, full"
    echo "  --addon <name>       アドオンを追加（複数回指定可）"
    echo "                       learning, multi-model, infra"
    echo "  --addon-only         アドオンのみデプロイ（ベースファイルをスキップ）"
    echo "  --status             デプロイ状態を表示"
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
    echo "  minimal           初級 + 汎用のみ（約16ファイル）"
    echo "  standard          初級・中級 + 汎用（約37ファイル）"
    echo "  standard-web      初級・中級 + 汎用・Web（約42ファイル）"
    echo "  standard-learning 初級・中級 + 汎用 + 自己学習（約47ファイル）"
    echo "  standard-multi    初級・中級 + 汎用 + マルチモデル（約44ファイル）"
    echo "  full              全て（約67ファイル）"
    echo ""
    echo "アドオン:"
    echo "  learning     自己学習・進化（eval, instinct, continuous-learning 等）"
    echo "  multi-model  マルチAI連携（orchestrate, multi-* 等）"
    echo "  infra        基盤・運用ツール（codemaps, pm2, sessions 等）"
    echo ""
    echo "例:"
    echo "  $0 /path/to/project --preset minimal"
    echo "  $0 /path/to/project --preset standard-web"
    echo "  $0 /path/to/project --preset standard --addon learning"
    echo "  $0 /path/to/project --preset standard --addon learning --addon multi-model"
    echo "  $0 /path/to/project --preset standard-learning"
    echo "  $0 /path/to/project --addon learning --addon-only"
    echo "  $0 /path/to/project --addon learning --addon multi-model --addon-only"
    echo "  $0 /path/to/project --status"
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
        --addon)
            if [ -n "$ADDON" ]; then
                ADDON="${ADDON},${2}"
            else
                ADDON="$2"
            fi
            shift 2
            ;;
        --addon-only)
            ADDON_ONLY=true
            shift
            ;;
        --status)
            SHOW_STATUS=true
            shift
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

# デプロイ状態を表示
show_status() {
    local state_file="${TARGET_CLAUDE_DIR}/.deploy-state"

    if [ ! -f "$state_file" ]; then
        echo "デプロイ状態ファイルが見つかりません: ${state_file}"
        echo ""
        echo "このプロジェクトにはまだデプロイされていないか、"
        echo "状態追跡導入前にデプロイされたプロジェクトです。"
        exit 0
    fi

    echo "=== デプロイ状況 ==="
    echo ""
    echo "プロジェクト: ${TARGET_DIR}"
    echo ""

    # デプロイ履歴を表示
    local deploy_count=0
    local current_section=""
    local file_count=0

    while IFS= read -r line; do
        if [[ "$line" =~ ^\[deploy:(.+)\]$ ]]; then
            # 前のセクションのファイル数を出力
            if [ "$current_section" = "files" ]; then
                echo "  ファイル数: ${file_count}"
                echo ""
            fi
            deploy_count=$((deploy_count + 1))
            current_section="header"
            echo "--- デプロイ #${deploy_count} (${BASH_REMATCH[1]}) ---"
        elif [ "$current_section" = "header" ]; then
            case "$line" in
                preset=*) [ -n "${line#preset=}" ] && echo "  プリセット: ${line#preset=}" ;;
                addons=*) [ -n "${line#addons=}" ] && echo "  アドオン: ${line#addons=}" ;;
                addon_only=true) echo "  モード: addon-only" ;;
                force=true) echo "  オプション: --force" ;;
                files:)
                    current_section="files"
                    file_count=0
                    ;;
            esac
        elif [ "$current_section" = "files" ]; then
            if [ -n "$line" ] && [[ ! "$line" =~ ^\[|^# ]]; then
                file_count=$((file_count + 1))
            fi
        fi
    done < "$state_file"

    # 最後のセクションのファイル数
    if [ "$current_section" = "files" ]; then
        echo "  ファイル数: ${file_count}"
        echo ""
    fi

    # 合計ファイル数
    local total
    total=$(grep -v '^\[deploy:' "$state_file" | grep -v '^preset=' | grep -v '^level=' | \
        grep -v '^type=' | grep -v '^addons=' | grep -v '^addon_only=' | \
        grep -v '^force=' | grep -v '^files:' | grep -v '^#' | grep -v '^$' | \
        sort -u | wc -l | tr -d ' ')
    echo "デプロイ済みファイル合計（ユニーク）: ${total}"

    exit 0
}

# 状態ファイルに書き込み
write_state_file() {
    local state_file="${TARGET_CLAUDE_DIR}/.deploy-state"
    local timestamp
    timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')

    # 初回は header を書き込み
    if [ ! -f "$state_file" ]; then
        {
            echo "# Claude Code Template Deploy State"
            echo "# このファイルはデプロイ状態を追跡します。手動編集しないでください。"
            echo "# version=1"
        } > "$state_file"
    fi

    # デプロイエントリを追記
    {
        echo ""
        echo "[deploy:${timestamp}]"
        echo "preset=${PRESET}"
        echo "level=${LEVEL}"
        echo "type=${TYPE}"
        echo "addons=${ADDON}"
        echo "addon_only=${ADDON_ONLY}"
        echo "force=${FORCE}"
        echo "files:"
        for f in "${DEPLOYED_FILES[@]}"; do
            echo "$f"
        done
    } >> "$state_file"
}

# 対話モード
if [ "$INTERACTIVE" = true ]; then
    echo "=== Claude Code テンプレート デプロイウィザード ==="
    echo ""
    echo "プリセットを選択してください:"
    echo ""
    echo "  1) minimal           - 初級のみ（すぐに使える基本セット）"
    echo "  2) standard          - 初級・中級（推奨）"
    echo "  3) standard-web      - 初級・中級 + Web開発向け"
    echo "  4) standard-learning - 初級・中級 + 自己学習"
    echo "  5) standard-multi    - 初級・中級 + マルチモデル"
    echo "  6) full              - 全て"
    echo "  7) custom            - カスタム選択"
    echo "  8) addon-only        - 既存プロジェクトにアドオンのみ追加"
    echo ""
    read -p "選択 [1-8]: " choice

    case $choice in
        1) PRESET="minimal" ;;
        2) PRESET="standard" ;;
        3) PRESET="standard-web" ;;
        4) PRESET="standard-learning" ;;
        5) PRESET="standard-multi" ;;
        6) PRESET="full" ;;
        8)
            ADDON_ONLY=true
            echo ""
            echo "追加するアドオンを選択（複数可、カンマ区切り）:"
            echo "  learning, multi-model, infra"
            read -p "アドオン: " ADDON
            if [ -z "$ADDON" ]; then
                echo "エラー: アドオンを指定してください"
                exit 1
            fi
            ;;
        7)
            echo ""
            echo "レベルを選択（複数可、カンマ区切り）:"
            echo "  beginner, intermediate, advanced"
            read -p "レベル: " LEVEL
            echo ""
            echo "タイプを選択（複数可、カンマ区切り）:"
            echo "  general, web"
            read -p "タイプ: " TYPE
            echo ""
            echo "アドオンを選択（複数可、カンマ区切り。不要なら空Enter）:"
            echo "  learning, multi-model, infra"
            read -p "アドオン: " ADDON
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
    standard-learning)
        LEVEL="beginner,intermediate"
        TYPE="general"
        ADDON="learning"
        ;;
    standard-multi)
        LEVEL="beginner,intermediate"
        TYPE="general"
        ADDON="multi-model"
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

# --status の早期終了
if [ "$SHOW_STATUS" = true ]; then
    show_status
fi

# --addon-only の検証
if [ "$ADDON_ONLY" = true ] && [ -z "$ADDON" ]; then
    echo "エラー: --addon-only を使用する場合は --addon を指定してください"
    exit 1
fi

# addon-only モードでは level/type を空にする（ベースファイルを除外）
if [ "$ADDON_ONLY" = true ]; then
    LEVEL=""
    TYPE=""
fi

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
if [ -n "$ADDON" ]; then
    echo "アドオン: ${ADDON}"
fi
if [ "$ADDON_ONLY" = true ]; then
    echo "モード: addon-only"
fi
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
    local addon_filter=$4

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
            # | `filename` | level | type | description | addon | の形式
            filename=$(echo "$line" | cut -d'|' -f2 | tr -d ' `')
            level=$(echo "$line" | cut -d'|' -f3 | tr -d ' ')
            type=$(echo "$line" | cut -d'|' -f4 | tr -d ' ')
            addon=$(echo "$line" | cut -d'|' -f6 | tr -d ' ')

            # フィルタチェック
            level_match=false
            type_match=false
            addon_match=false

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

            if [ -n "$addon_filter" ] && [ "$addon" != "-" ]; then
                IFS=',' read -ra ADDONS <<< "$addon_filter"
                for a in "${ADDONS[@]}"; do
                    if [ "$a" = "$addon" ]; then
                        addon_match=true
                        break
                    fi
                done
            fi

            if [ "$ADDON_ONLY" = true ]; then
                # addon-only: アドオンマッチのみ
                if [ "$addon_match" = true ]; then
                    files="$files $filename"
                fi
            else
                # 通常: (level AND type) OR addon
                if [ "$level_match" = true ] && [ "$type_match" = true ] || [ "$addon_match" = true ]; then
                    files="$files $filename"
                fi
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
    local files=$(get_files_for_category "$category" "$LEVEL" "$TYPE" "$ADDON")

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
                DEPLOYED_FILES+=("${category_lower}/${skill_name}/")
                count=$((count + 1))
            fi
        else
            # その他はファイル（サブディレクトリパスに対応）
            local src_file="${src_dir}/${filename}"
            if [ -f "$src_file" ]; then
                local file_dest_dir="$dest_dir"
                local subdir
                subdir=$(dirname "$filename")
                if [ "$subdir" != "." ]; then
                    file_dest_dir="${dest_dir}/${subdir}"
                fi
                if [ "$DRY_RUN" = false ]; then
                    mkdir -p "$file_dest_dir"
                    copy_single_file "$src_file" "$file_dest_dir"
                fi
                DEPLOYED_FILES+=("${category_lower}/${filename}")
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

# デプロイされたファイルの追跡
DEPLOYED_FILES=()

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

# 状態ファイルの書き込み
if [ "$DRY_RUN" = false ] && [ ${#DEPLOYED_FILES[@]} -gt 0 ]; then
    write_state_file
fi

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
