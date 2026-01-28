#!/bin/bash
# =============================================================================
# deploy-custom-skills.sh
# カスタムスキルを対象プロジェクトにデプロイする
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
CUSTOM_SAMPLES_DIR="${WORKSPACE_DIR}/template-.claude/skills/custom-samples"

# デフォルト設定
DRY_RUN=false
FORCE=false
INTERACTIVE=false
SELECTED_SKILLS=()

# 使用方法
usage() {
    echo "使用方法: $0 <target-project-path> [options]"
    echo ""
    echo "オプション:"
    echo "  --skill <name>       デプロイするスキル（複数指定可）"
    echo "                       adapt-external-docs, merge-reference-docs"
    echo "  --all                全てのカスタムスキルをデプロイ"
    echo "  --interactive, -i    対話モードで選択"
    echo "  --force              既存ファイルを上書き"
    echo "  --dry-run            実際にはコピーしない（確認のみ）"
    echo "  --list               利用可能なスキル一覧を表示"
    echo "  -h, --help           このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 /path/to/project --all"
    echo "  $0 /path/to/project --skill adapt-external-docs"
    echo "  $0 /path/to/project --skill adapt-external-docs --skill merge-reference-docs"
    echo "  $0 /path/to/project -i"
    exit 1
}

# 利用可能なスキル一覧を表示
list_skills() {
    echo "利用可能なカスタムスキル:"
    echo ""
    for skill_dir in "${CUSTOM_SAMPLES_DIR}"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            if [ -f "${skill_dir}/SKILL.md" ]; then
                # SKILL.md から description を抽出
                description=$(grep -A1 "^description:" "${skill_dir}/SKILL.md" | head -1 | sed 's/description: *//' | tr -d '"')
                echo "  ${skill_name}"
                echo "    ${description}"
                echo ""
            fi
        fi
    done
    exit 0
}

# 引数解析
TARGET_DIR=""
ALL_SKILLS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --skill)
            SELECTED_SKILLS+=("$2")
            shift 2
            ;;
        --all)
            ALL_SKILLS=true
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
            list_skills
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

# 対話モード
if [ "$INTERACTIVE" = true ]; then
    echo "=== カスタムスキル デプロイウィザード ==="
    echo ""
    echo "デプロイするスキルを選択してください:"
    echo ""

    # 利用可能なスキルを列挙
    skill_list=()
    i=1
    for skill_dir in "${CUSTOM_SAMPLES_DIR}"/*/; do
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
    echo "  a) 全て選択"
    echo ""

    read -p "選択 (カンマ区切りで複数可, 例: 1,2 または a): " choice

    if [ "$choice" = "a" ] || [ "$choice" = "A" ]; then
        ALL_SKILLS=true
    else
        IFS=',' read -ra selections <<< "$choice"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | tr -d ' ')
            if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#skill_list[@]}" ]; then
                SELECTED_SKILLS+=("${skill_list[$((sel-1))]}")
            fi
        done
    fi
    echo ""
fi

# --all の場合、全スキルを選択
if [ "$ALL_SKILLS" = true ]; then
    SELECTED_SKILLS=()
    for skill_dir in "${CUSTOM_SAMPLES_DIR}"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            SELECTED_SKILLS+=("$skill_name")
        fi
    done
fi

# スキルが選択されていない場合
if [ ${#SELECTED_SKILLS[@]} -eq 0 ]; then
    echo "エラー: デプロイするスキルを指定してください"
    echo "  --skill <name> または --all または -i を使用してください"
    exit 1
fi

echo "=== カスタムスキルのデプロイ ==="
echo ""
echo "ソース: ${CUSTOM_SAMPLES_DIR}"
echo "ターゲット: ${TARGET_SKILLS_DIR}"
echo ""
echo "選択されたスキル:"
for skill in "${SELECTED_SKILLS[@]}"; do
    echo "  - ${skill}"
done
echo ""

# ドライランモード
if [ "$DRY_RUN" = true ]; then
    echo "[ドライラン] 実際にはコピーしません"
    echo ""
fi

# 既存チェック
existing_skills=()
for skill in "${SELECTED_SKILLS[@]}"; do
    if [ -d "${TARGET_SKILLS_DIR}/${skill}" ]; then
        existing_skills+=("$skill")
    fi
done

if [ ${#existing_skills[@]} -gt 0 ] && [ "$FORCE" = false ] && [ "$DRY_RUN" = false ]; then
    echo "警告: 以下のスキルは既に存在します:"
    for skill in "${existing_skills[@]}"; do
        echo "  - ${skill}"
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
echo "[1/2] ディレクトリを準備中..."
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$TARGET_SKILLS_DIR"
fi
echo ""

echo "[2/2] スキルをコピー中..."
copied_count=0
for skill in "${SELECTED_SKILLS[@]}"; do
    src_dir="${CUSTOM_SAMPLES_DIR}/${skill}"
    dest_dir="${TARGET_SKILLS_DIR}/${skill}"

    if [ -d "$src_dir" ]; then
        if [ "$DRY_RUN" = false ]; then
            mkdir -p "$dest_dir"
            cp -r "${src_dir}/"* "$dest_dir/"
            echo "  [完了] ${skill}"
        else
            echo "  [ドライラン] ${skill}"
        fi
        ((copied_count++))
    else
        echo "  [スキップ] ${skill}: 存在しません"
    fi
done
echo ""

# 結果表示
if [ "$DRY_RUN" = false ]; then
    echo "=== デプロイ完了 ==="
    echo ""
    echo "配置先: ${TARGET_SKILLS_DIR}"
    echo "コピーしたスキル: ${copied_count}"
    echo ""
    echo "次のステップ:"
    echo "  1. 各スキルの SKILL.md を開く"
    echo "  2. <!-- CUSTOMIZE: --> コメントの箇所をプロジェクトに合わせて調整"
    echo "  3. プロジェクト固有のパス、コマンド、エージェント名を更新"
else
    echo "=== ドライラン完了 ==="
    echo ""
    echo "--dry-run を外して実行すると実際にコピーされます"
fi
