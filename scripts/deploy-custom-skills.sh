#!/bin/bash
# =============================================================================
# deploy-custom-skills.sh
# カスタムスキル・カスタムコマンドを対象プロジェクトにデプロイする
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
CUSTOM_SKILLS_DIR="${WORKSPACE_DIR}/template-.claude/skills/custom-samples"
CUSTOM_COMMANDS_DIR="${WORKSPACE_DIR}/template-.claude/commands/custom-samples"

# デフォルト設定
DRY_RUN=false
FORCE=false
INTERACTIVE=false
SELECTED_SKILLS=()
SELECTED_COMMANDS=()

# 使用方法
usage() {
    echo "使用方法: $0 <target-project-path> [options]"
    echo ""
    echo "オプション:"
    echo "  --skill <name>       デプロイするスキル（複数指定可）"
    echo "                       adapt-external-docs, merge-reference-docs"
    echo "  --command <name>     デプロイするコマンド（複数指定可）"
    echo "                       create-pr, merge-pr"
    echo "  --all                全てのカスタムスキル・コマンドをデプロイ"
    echo "  --interactive, -i    対話モードで選択"
    echo "  --force              既存ファイルを上書き"
    echo "  --dry-run            実際にはコピーしない（確認のみ）"
    echo "  --list               利用可能なスキル・コマンド一覧を表示"
    echo "  -h, --help           このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 /path/to/project --all"
    echo "  $0 /path/to/project --skill adapt-external-docs"
    echo "  $0 /path/to/project --command create-pr --command merge-pr"
    echo "  $0 /path/to/project --skill adapt-external-docs --command create-pr"
    echo "  $0 /path/to/project -i"
    exit 1
}

# 利用可能なスキル・コマンド一覧を表示
list_items() {
    echo "利用可能なカスタムスキル:"
    echo ""
    for skill_dir in "${CUSTOM_SKILLS_DIR}"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            if [ -f "${skill_dir}/SKILL.md" ]; then
                description=$(grep -A1 "^description:" "${skill_dir}/SKILL.md" | head -1 | sed 's/description: *//' | tr -d '"')
                echo "  ${skill_name}"
                echo "    ${description}"
                echo ""
            fi
        fi
    done

    echo "利用可能なカスタムコマンド:"
    echo ""
    for cmd_file in "${CUSTOM_COMMANDS_DIR}"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file" .md)
            description=$(grep "^description:" "$cmd_file" | head -1 | sed 's/description: *//' | tr -d '"')
            echo "  ${cmd_name}"
            echo "    ${description}"
            echo ""
        fi
    done
    exit 0
}

# 引数解析
TARGET_DIR=""
ALL_ITEMS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skill)
            SELECTED_SKILLS+=("$2")
            shift 2
            ;;
        --command)
            SELECTED_COMMANDS+=("$2")
            shift 2
            ;;
        --all)
            ALL_ITEMS=true
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
        --list)
            list_items
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
TARGET_SKILLS_DIR="${TARGET_DIR}/.claude/skills"
TARGET_COMMANDS_DIR="${TARGET_DIR}/.claude/commands"

# 対話モード
if [ "$INTERACTIVE" = true ]; then
    echo "=== カスタムデプロイウィザード ==="
    echo ""

    # --- スキル選択 ---
    echo "[スキル] デプロイするスキルを選択してください:"
    echo ""

    skill_list=()
    i=1
    for skill_dir in "${CUSTOM_SKILLS_DIR}"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            skill_list+=("$skill_name")
            description=$(grep -A1 "^description:" "${skill_dir}/SKILL.md" 2>/dev/null | head -1 | sed 's/description: *//' | tr -d '"')
            echo "  $i) ${skill_name}"
            echo "     ${description}"
            echo ""
            ((i++))
        fi
    done
    echo "  a) 全て選択  n) スキップ"
    echo ""

    read -p "選択 (カンマ区切りで複数可, 例: 1,2 または a): " skill_choice

    if [ "$skill_choice" = "a" ] || [ "$skill_choice" = "A" ]; then
        for s in "${skill_list[@]}"; do
            SELECTED_SKILLS+=("$s")
        done
    elif [ "$skill_choice" != "n" ] && [ "$skill_choice" != "N" ] && [ -n "$skill_choice" ]; then
        IFS=',' read -ra selections <<< "$skill_choice"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | tr -d ' ')
            if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#skill_list[@]}" ]; then
                SELECTED_SKILLS+=("${skill_list[$((sel-1))]}")
            fi
        done
    fi
    echo ""

    # --- コマンド選択 ---
    echo "[コマンド] デプロイするコマンドを選択してください:"
    echo ""

    cmd_list=()
    i=1
    for cmd_file in "${CUSTOM_COMMANDS_DIR}"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file" .md)
            cmd_list+=("$cmd_name")
            description=$(grep "^description:" "$cmd_file" | head -1 | sed 's/description: *//' | tr -d '"')
            echo "  $i) ${cmd_name}"
            echo "     ${description}"
            echo ""
            ((i++))
        fi
    done
    echo "  a) 全て選択  n) スキップ"
    echo ""

    read -p "選択 (カンマ区切りで複数可, 例: 1,2 または a): " cmd_choice

    if [ "$cmd_choice" = "a" ] || [ "$cmd_choice" = "A" ]; then
        for c in "${cmd_list[@]}"; do
            SELECTED_COMMANDS+=("$c")
        done
    elif [ "$cmd_choice" != "n" ] && [ "$cmd_choice" != "N" ] && [ -n "$cmd_choice" ]; then
        IFS=',' read -ra selections <<< "$cmd_choice"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | tr -d ' ')
            if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#cmd_list[@]}" ]; then
                SELECTED_COMMANDS+=("${cmd_list[$((sel-1))]}")
            fi
        done
    fi
    echo ""
fi

# --all の場合、全スキル・コマンドを選択
if [ "$ALL_ITEMS" = true ]; then
    SELECTED_SKILLS=()
    for skill_dir in "${CUSTOM_SKILLS_DIR}"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            SELECTED_SKILLS+=("$skill_name")
        fi
    done
    SELECTED_COMMANDS=()
    for cmd_file in "${CUSTOM_COMMANDS_DIR}"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file" .md)
            SELECTED_COMMANDS+=("$cmd_name")
        fi
    done
fi

# スキルもコマンドも選択されていない場合
if [ ${#SELECTED_SKILLS[@]} -eq 0 ] && [ ${#SELECTED_COMMANDS[@]} -eq 0 ]; then
    echo "エラー: デプロイするスキルまたはコマンドを指定してください"
    echo "  --skill <name> / --command <name> / --all / -i を使用してください"
    exit 1
fi

echo "=== カスタムデプロイ ==="
echo ""
if [ ${#SELECTED_SKILLS[@]} -gt 0 ]; then
    echo "スキル（ソース: ${CUSTOM_SKILLS_DIR}）"
    for skill in "${SELECTED_SKILLS[@]}"; do
        echo "  - ${skill}"
    done
fi
if [ ${#SELECTED_COMMANDS[@]} -gt 0 ]; then
    echo "コマンド（ソース: ${CUSTOM_COMMANDS_DIR}）"
    for cmd in "${SELECTED_COMMANDS[@]}"; do
        echo "  - ${cmd}"
    done
fi
echo ""

# ドライランモード
if [ "$DRY_RUN" = true ]; then
    echo "[ドライラン] 実際にはコピーしません"
    echo ""
fi

# 既存チェック
existing_items=()
for skill in "${SELECTED_SKILLS[@]}"; do
    if [ -d "${TARGET_SKILLS_DIR}/${skill}" ]; then
        existing_items+=("skills/${skill}")
    fi
done
for cmd in "${SELECTED_COMMANDS[@]}"; do
    if [ -f "${TARGET_COMMANDS_DIR}/${cmd}.md" ]; then
        existing_items+=("commands/${cmd}.md")
    fi
done

if [ ${#existing_items[@]} -gt 0 ] && [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
    echo "警告: 以下は既に存在します:"
    for item in "${existing_items[@]}"; do
        echo "  - ${item}"
    done
    echo ""
    read -p "上書きしますか？ (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "キャンセルしました"
        exit 0
    fi
    echo ""
fi

# メイン処理
total_steps=0
[ ${#SELECTED_SKILLS[@]} -gt 0 ] && ((total_steps++))
[ ${#SELECTED_COMMANDS[@]} -gt 0 ] && ((total_steps++))
current_step=0

echo "[1/$((total_steps + 1))] ディレクトリを準備中..."
if [ "$DRY_RUN" = false ]; then
    [ ${#SELECTED_SKILLS[@]} -gt 0 ] && mkdir -p "$TARGET_SKILLS_DIR"
    [ ${#SELECTED_COMMANDS[@]} -gt 0 ] && mkdir -p "$TARGET_COMMANDS_DIR"
fi
echo ""

copied_count=0

# スキルのコピー
if [ ${#SELECTED_SKILLS[@]} -gt 0 ]; then
    ((current_step++))
    echo "[$((current_step + 1))/$((total_steps + 1))] スキルをコピー中..."
    for skill in "${SELECTED_SKILLS[@]}"; do
        src_dir="${CUSTOM_SKILLS_DIR}/${skill}"
        dest_dir="${TARGET_SKILLS_DIR}/${skill}"

        if [ -d "$src_dir" ]; then
            if [ "$DRY_RUN" = false ]; then
                mkdir -p "$dest_dir"
                cp -r "${src_dir}/"* "$dest_dir/"
                echo "  [完了] skills/${skill}"
            else
                echo "  [ドライラン] skills/${skill}"
            fi
            ((copied_count++))
        else
            echo "  [スキップ] ${skill}: 存在しません"
        fi
    done
    echo ""
fi

# コマンドのコピー
if [ ${#SELECTED_COMMANDS[@]} -gt 0 ]; then
    ((current_step++))
    echo "[$((current_step + 1))/$((total_steps + 1))] コマンドをコピー中..."
    for cmd in "${SELECTED_COMMANDS[@]}"; do
        src_file="${CUSTOM_COMMANDS_DIR}/${cmd}.md"
        dest_file="${TARGET_COMMANDS_DIR}/${cmd}.md"

        if [ -f "$src_file" ]; then
            if [ "$DRY_RUN" = false ]; then
                cp "$src_file" "$dest_file"
                echo "  [完了] commands/${cmd}.md"
            else
                echo "  [ドライラン] commands/${cmd}.md"
            fi
            ((copied_count++))
        else
            echo "  [スキップ] ${cmd}: 存在しません"
        fi
    done
    echo ""
fi

# 結果表示
if [ "$DRY_RUN" = false ]; then
    echo "=== デプロイ完了 ==="
    echo ""
    echo "配置先: ${TARGET_DIR}/.claude/"
    echo "コピーしたアイテム: ${copied_count}"
    echo ""
    echo "次のステップ:"
    echo "  1. 配置されたファイルを確認"
    echo "  2. <!-- CUSTOMIZE: --> コメントの箇所をプロジェクトに合わせて調整"
else
    echo "=== ドライラン完了 ==="
    echo ""
    echo "--dry-run を外して実行すると実際にコピーされます"
fi
