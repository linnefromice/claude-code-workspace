#!/bin/bash
# =============================================================================
# deploy-settings.sh
# settings.json テンプレートを対象プロジェクトにデプロイ（マージ）する
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
SETTINGS_SAMPLES_DIR="${WORKSPACE_DIR}/template-.claude/settings-samples"

# デフォルト設定
DRY_RUN=false
FORCE=false
INTERACTIVE=false
SELECTED_SETTINGS=()

# 使用方法
usage() {
    echo "使用方法: $0 <target-project-path> [options]"
    echo ""
    echo "settings.json テンプレートを対象プロジェクトの .claude/settings.json に"
    echo "マージします。既存の設定は保持されます。"
    echo ""
    echo "オプション:"
    echo "  --settings <name>    マージする設定テンプレート（複数指定可）"
    echo "  --all                全ての設定テンプレートをマージ"
    echo "  --interactive, -i    対話モードで選択"
    echo "  --force              既存の settings.json を上書き（マージではなく置換）"
    echo "  --dry-run            実際には変更しない（確認のみ）"
    echo "  --list               利用可能な設定テンプレート一覧を表示"
    echo "  -h, --help           このヘルプを表示"
    echo ""
    echo "利用可能なテンプレート:"
    for settings_file in "${SETTINGS_SAMPLES_DIR}"/*.json; do
        if [ -f "$settings_file" ]; then
            echo "  $(basename "$settings_file" .json)"
        fi
    done
    echo ""
    echo "例:"
    echo "  $0 /path/to/project --settings teammate-idle"
    echo "  $0 /path/to/project --all"
    echo "  $0 /path/to/project -i"
    exit 1
}

# 利用可能な設定テンプレート一覧を表示
list_settings() {
    echo "利用可能な設定テンプレート:"
    echo ""
    for settings_file in "${SETTINGS_SAMPLES_DIR}"/*.json; do
        if [ -f "$settings_file" ]; then
            settings_name=$(basename "$settings_file" .json)
            # hooks のキー名を説明として抽出
            hooks=$(grep -o '"[A-Za-z]*"' "$settings_file" 2>/dev/null | head -5 | tr -d '"' | grep -v 'hooks\|matcher\|type\|command\|prompt' | paste -sd ', ' -)
            echo "  ${settings_name}"
            if [ -n "$hooks" ]; then
                echo "    フック: ${hooks}"
            fi
            echo ""
        fi
    done
    exit 0
}

# settings.json のマージ関数
merge_settings() {
    local src_file="$1"
    local dest_file="$2"
    local settings_name="$3"

    if [ "$DRY_RUN" = true ]; then
        if [ -f "$dest_file" ]; then
            echo "  [ドライラン] settings.json にマージ: ${settings_name}"
        else
            echo "  [ドライラン] settings.json を新規作成: ${settings_name}"
        fi
        return 0
    fi

    mkdir -p "$(dirname "$dest_file")"

    if [ -f "$dest_file" ] && [ "$FORCE" = false ]; then
        # 既存の settings.json にディープマージ
        if ! command -v jq &> /dev/null; then
            echo "  [エラー] jq が必要です: brew install jq"
            echo "         手動で以下の内容を settings.json にマージしてください:"
            echo ""
            while IFS= read -r line; do
                echo "         $line"
            done < "$src_file"
            return 1
        fi

        local tmp_file
        tmp_file=$(mktemp)
        jq -s '
            def deep_merge:
                reduce .[] as $item ({}; . as $base |
                    $item | to_entries | reduce .[] as $e ($base;
                        if ($e.value | type) == "object" and (.[$e.key] | type) == "object"
                        then .[$e.key] = ([$e.value, .[$e.key]] | deep_merge)
                        elif ($e.value | type) == "array" and (.[$e.key] | type) == "array"
                        then .[$e.key] = (.[$e.key] + $e.value | unique)
                        else .[$e.key] = $e.value
                        end
                    )
                );
            [.[0], .[1]] | deep_merge
        ' "$dest_file" "$src_file" > "$tmp_file"
        mv "$tmp_file" "$dest_file"
        echo "  [完了] settings.json にマージ: ${settings_name}"
    else
        # 新規作成 or --force で上書き
        cp "$src_file" "$dest_file"
        if [ "$FORCE" = true ] && [ -f "$dest_file" ]; then
            echo "  [完了] settings.json を上書き: ${settings_name}"
        else
            echo "  [完了] settings.json を新規作成: ${settings_name}"
        fi
    fi
}

# 引数解析
TARGET_DIR=""
ALL_SETTINGS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --settings)
            SELECTED_SETTINGS+=("$2")
            shift 2
            ;;
        --all)
            ALL_SETTINGS=true
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
            list_settings
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
TARGET_SETTINGS_FILE="${TARGET_DIR}/.claude/settings.json"

# 対話モード
if [ "$INTERACTIVE" = true ]; then
    echo "=== settings.json デプロイウィザード ==="
    echo ""
    echo "マージする設定テンプレートを選択してください:"
    echo ""

    settings_list=()
    i=1
    for settings_file in "${SETTINGS_SAMPLES_DIR}"/*.json; do
        if [ -f "$settings_file" ]; then
            settings_name=$(basename "$settings_file" .json)
            settings_list+=("$settings_name")
            hooks=$(grep -o '"[A-Za-z]*"' "$settings_file" 2>/dev/null | head -5 | tr -d '"' | grep -v 'hooks\|matcher\|type\|command\|prompt' | paste -sd ', ' -)
            echo "  $i) ${settings_name}"
            [ -n "$hooks" ] && echo "     フック: ${hooks}"
            echo ""
            ((i++))
        fi
    done
    echo "  a) 全て選択"
    echo ""

    read -p "選択 (カンマ区切りで複数可, 例: 1,2 または a): " choice

    if [ "$choice" = "a" ] || [ "$choice" = "A" ]; then
        ALL_SETTINGS=true
    else
        IFS=',' read -ra selections <<< "$choice"
        for sel in "${selections[@]}"; do
            sel=$(echo "$sel" | tr -d ' ')
            if [[ "$sel" =~ ^[0-9]+$ ]] && [ "$sel" -ge 1 ] && [ "$sel" -le "${#settings_list[@]}" ]; then
                SELECTED_SETTINGS+=("${settings_list[$((sel-1))]}")
            fi
        done
    fi
    echo ""
fi

# --all の場合
if [ "$ALL_SETTINGS" = true ]; then
    SELECTED_SETTINGS=()
    for settings_file in "${SETTINGS_SAMPLES_DIR}"/*.json; do
        if [ -f "$settings_file" ]; then
            settings_name=$(basename "$settings_file" .json)
            SELECTED_SETTINGS+=("$settings_name")
        fi
    done
fi

# 何も選択されていない場合
if [ ${#SELECTED_SETTINGS[@]} -eq 0 ]; then
    echo "エラー: マージする設定テンプレートを指定してください"
    echo "  --settings <name> / --all / -i を使用してください"
    exit 1
fi

echo "=== settings.json デプロイ ==="
echo ""
echo "ターゲット: ${TARGET_SETTINGS_FILE}"
echo "テンプレート:"
for s in "${SELECTED_SETTINGS[@]}"; do
    echo "  - ${s}"
done
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "[ドライラン] 実際には変更しません"
    echo ""
fi

# 既存ファイルの警告
if [ -f "$TARGET_SETTINGS_FILE" ] && [ "$FORCE" = false ]; then
    echo "既存の settings.json を検出しました。設定をマージします。"
    echo ""
fi

# メイン処理
merged_count=0
for s in "${SELECTED_SETTINGS[@]}"; do
    src_file="${SETTINGS_SAMPLES_DIR}/${s}.json"

    if [ -f "$src_file" ]; then
        merge_settings "$src_file" "$TARGET_SETTINGS_FILE" "$s"
        ((merged_count++))
    else
        echo "  [スキップ] ${s}: テンプレートが存在しません"
    fi
done
echo ""

# 結果表示
if [ "$DRY_RUN" = false ]; then
    echo "=== デプロイ完了 ==="
    echo ""
    echo "設定ファイル: ${TARGET_SETTINGS_FILE}"
    echo "マージ済み: ${merged_count} テンプレート"
else
    echo "=== ドライラン完了 ==="
    echo ""
    echo "--dry-run を外して実行すると実際に変更されます"
fi
