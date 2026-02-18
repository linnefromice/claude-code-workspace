#!/bin/bash
# =============================================================================
# setup-agent-teams.sh
# Agent Teams の設定一式を対象プロジェクトにセットアップする
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
AGENT_TEAMS_DIR="${WORKSPACE_DIR}/agent-teams"

# デフォルト設定
DRY_RUN=false
FORCE=false
SKIP_HOOKS=false
SKIP_SETTINGS=false
SKIP_CLAUDE_MD=false
SKIP_COMMANDS=false

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_info()    { echo -e "${CYAN}→${NC} $1"; }

# 使用方法
usage() {
    echo "使用方法: $0 <target-project-path> [options]"
    echo ""
    echo "Agent Teams の設定一式を対象プロジェクトにセットアップします。"
    echo ""
    echo "セットアップ内容:"
    echo "  - .claude/settings.json    環境変数・フックの設定"
    echo "  - .claude/hooks/           TeammateIdle フックスクリプト"
    echo "  - .claude/commands/        team-start, team-review コマンド"
    echo "  - .claude/agents/          team-orchestrator エージェント"
    echo "  - .claude/rules/           Agent Teams 自動起動ルール"
    echo "  - CLAUDE.md                Agent Team ルールの追記"
    echo ""
    echo "オプション:"
    echo "  --force              既存ファイルを強制上書き"
    echo "  --dry-run            実際には変更しない（確認のみ）"
    echo "  --skip-hooks         フック設定をスキップ"
    echo "  --skip-settings      settings.json の変更をスキップ"
    echo "  --skip-claude-md     CLAUDE.md への追記をスキップ"
    echo "  --skip-commands      コマンド配置をスキップ"
    echo "  -h, --help           このヘルプを表示"
    echo ""
    echo "例:"
    echo "  $0 /path/to/project"
    echo "  $0 /path/to/project --dry-run"
    echo "  $0 /path/to/project --force"
    echo "  $0 /path/to/project --skip-hooks"
    echo "  $0 /path/to/project --skip-commands"
    exit 1
}

# 引数解析
TARGET_DIR=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-hooks)
            SKIP_HOOKS=true
            shift
            ;;
        --skip-settings)
            SKIP_SETTINGS=true
            shift
            ;;
        --skip-claude-md)
            SKIP_CLAUDE_MD=true
            shift
            ;;
        --skip-commands)
            SKIP_COMMANDS=true
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
    print_error "ディレクトリが存在しません: $TARGET_DIR"
    exit 1
fi

# 絶対パスに変換
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
TARGET_CLAUDE_DIR="${TARGET_DIR}/.claude"

echo ""
echo "=== Agent Teams セットアップ ==="
echo ""
echo "ソース:     ${AGENT_TEAMS_DIR}"
echo "ターゲット: ${TARGET_DIR}"
echo ""

if [ "$DRY_RUN" = true ]; then
    print_info "[ドライラン] 実際には変更しません"
    echo ""
fi

# カウンター
CREATED_COUNT=0
UPDATED_COUNT=0
SKIPPED_COUNT=0

# -----------------------------------------------------------------------------
# ファイルコピー関数
# 引数: $1=ソースファイル $2=デスティネーションパス
# -----------------------------------------------------------------------------
copy_file() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir=$(dirname "$dest")
    local filename
    filename=$(basename "$dest")

    if [ "$DRY_RUN" = true ]; then
        if [ -f "$dest" ]; then
            if [ "$FORCE" = true ]; then
                print_info "[ドライラン] 上書き: ${dest#"$TARGET_DIR"/}"
            else
                print_warning "[ドライラン] スキップ（既存）: ${dest#"$TARGET_DIR"/}"
            fi
        else
            print_info "[ドライラン] 作成: ${dest#"$TARGET_DIR"/}"
        fi
        return 0
    fi

    mkdir -p "$dest_dir"

    if [ -f "$dest" ]; then
        if [ "$FORCE" = true ]; then
            cp "$src" "$dest"
            print_success "上書き: ${dest#"$TARGET_DIR"/}"
            UPDATED_COUNT=$((UPDATED_COUNT + 1))
        else
            print_warning "スキップ（既存）: ${dest#"$TARGET_DIR"/}"
            SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        fi
    else
        cp "$src" "$dest"
        print_success "作成: ${dest#"$TARGET_DIR"/}"
        CREATED_COUNT=$((CREATED_COUNT + 1))
    fi
}

# -----------------------------------------------------------------------------
# [1/6] コマンドのコピー
# -----------------------------------------------------------------------------
echo "[1/6] コマンドを配置中..."

if [ "$SKIP_COMMANDS" = true ]; then
    print_info "スキップ（--skip-commands）"
else
    copy_file \
        "${AGENT_TEAMS_DIR}/commands/team-start.md" \
        "${TARGET_CLAUDE_DIR}/commands/team-start.md"

    copy_file \
        "${AGENT_TEAMS_DIR}/commands/team-review.md" \
        "${TARGET_CLAUDE_DIR}/commands/team-review.md"
fi

echo ""

# -----------------------------------------------------------------------------
# [2/6] エージェントのコピー
# -----------------------------------------------------------------------------
echo "[2/6] エージェント定義を配置中..."

copy_file \
    "${AGENT_TEAMS_DIR}/agents/team-orchestrator.md" \
    "${TARGET_CLAUDE_DIR}/agents/team-orchestrator.md"

echo ""

# -----------------------------------------------------------------------------
# [3/6] フックスクリプトのコピー
# -----------------------------------------------------------------------------
echo "[3/6] フックスクリプトを配置中..."

if [ "$SKIP_HOOKS" = true ]; then
    print_info "スキップ（--skip-hooks）"
else
    copy_file \
        "${AGENT_TEAMS_DIR}/hooks/keep-teammate-busy.sh" \
        "${TARGET_CLAUDE_DIR}/hooks/keep-teammate-busy.sh"

    # 実行権限を付与
    if [ "$DRY_RUN" = false ] && [ -f "${TARGET_CLAUDE_DIR}/hooks/keep-teammate-busy.sh" ]; then
        chmod +x "${TARGET_CLAUDE_DIR}/hooks/keep-teammate-busy.sh"
    fi
fi

echo ""

# -----------------------------------------------------------------------------
# [4/6] settings.json のマージ
# -----------------------------------------------------------------------------
echo "[4/6] settings.json を設定中..."

if [ "$SKIP_SETTINGS" = true ]; then
    print_info "スキップ（--skip-settings）"
else
    SETTINGS_FILE="${TARGET_CLAUDE_DIR}/settings.json"
    FRAGMENT_FILE="${AGENT_TEAMS_DIR}/settings-fragment.json"

    if [ "$DRY_RUN" = true ]; then
        if [ -f "$SETTINGS_FILE" ]; then
            print_info "[ドライラン] settings.json にマージ"
        else
            print_info "[ドライラン] settings.json を新規作成"
        fi
    else
        mkdir -p "$TARGET_CLAUDE_DIR"

        if [ -f "$SETTINGS_FILE" ]; then
            # 既存の settings.json にマージ
            if command -v jq &> /dev/null; then
                # jq が利用可能: ディープマージ
                local_tmp=$(mktemp)
                jq -s '
                    def deep_merge:
                        reduce .[] as $item ({}; . as $base |
                            $item | to_entries | reduce .[] as $e ($base;
                                if ($e.value | type) == "object" and (.[$e.key] | type) == "object"
                                then .[$e.key] = ([$e.value, .[$e.key]] | deep_merge)
                                else .[$e.key] = $e.value
                                end
                            )
                        );
                    [.[0], .[1]] | deep_merge
                ' "$SETTINGS_FILE" "$FRAGMENT_FILE" > "$local_tmp"
                mv "$local_tmp" "$SETTINGS_FILE"
                print_success "settings.json をマージしました（jq）"
                UPDATED_COUNT=$((UPDATED_COUNT + 1))
            else
                # jq なし: バックアップを取り、手動マージを案内
                cp "$SETTINGS_FILE" "${SETTINGS_FILE}.backup"
                print_warning "jq が見つかりません。settings.json のバックアップを作成しました"
                print_warning "以下の内容を手動で settings.json にマージしてください:"
                echo ""
                echo "  --- ${FRAGMENT_FILE} の内容 ---"
                while IFS= read -r line; do
                    echo "  $line"
                done < "$FRAGMENT_FILE"
                echo "  ---"
                echo ""
                SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
            fi
        else
            # 新規作成
            cp "$FRAGMENT_FILE" "$SETTINGS_FILE"
            print_success "settings.json を作成しました"
            CREATED_COUNT=$((CREATED_COUNT + 1))
        fi
    fi
fi

echo ""

# -----------------------------------------------------------------------------
# [5/6] CLAUDE.md への追記
# -----------------------------------------------------------------------------
echo "[5/6] CLAUDE.md に Agent Team ルールを追記中..."

if [ "$SKIP_CLAUDE_MD" = true ]; then
    print_info "スキップ（--skip-claude-md）"
else
    CLAUDE_MD="${TARGET_DIR}/CLAUDE.md"
    ADDITION_FILE="${AGENT_TEAMS_DIR}/CLAUDE_ADDITION.md"

    if [ "$DRY_RUN" = true ]; then
        if [ -f "$CLAUDE_MD" ]; then
            print_info "[ドライラン] CLAUDE.md に追記"
        else
            print_info "[ドライラン] CLAUDE.md を新規作成"
        fi
    else
        if [ -f "$CLAUDE_MD" ]; then
            # 既に追記済みか確認
            if grep -q "Agent Team Operational Rules" "$CLAUDE_MD" 2>/dev/null; then
                if [ "$FORCE" = true ]; then
                    # 既存セクションを削除してから追記
                    local_tmp=$(mktemp)
                    # "## Agent Team Operational Rules" から次の "## " まで（または末尾まで）を削除
                    awk '
                        /^## Agent Team Operational Rules/ { skip=1; next }
                        /^## / && skip { skip=0 }
                        !skip { print }
                    ' "$CLAUDE_MD" > "$local_tmp"
                    mv "$local_tmp" "$CLAUDE_MD"
                    echo "" >> "$CLAUDE_MD"
                    cat "$ADDITION_FILE" >> "$CLAUDE_MD"
                    print_success "CLAUDE.md の Agent Team ルールを更新しました"
                    UPDATED_COUNT=$((UPDATED_COUNT + 1))
                else
                    print_warning "CLAUDE.md に Agent Team ルールは既に存在します（--force で上書き）"
                    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
                fi
            else
                echo "" >> "$CLAUDE_MD"
                echo "" >> "$CLAUDE_MD"
                cat "$ADDITION_FILE" >> "$CLAUDE_MD"
                print_success "CLAUDE.md に追記しました"
                UPDATED_COUNT=$((UPDATED_COUNT + 1))
            fi
        else
            cat "$ADDITION_FILE" > "$CLAUDE_MD"
            print_success "CLAUDE.md を作成しました"
            CREATED_COUNT=$((CREATED_COUNT + 1))
        fi
    fi
fi

echo ""

# -----------------------------------------------------------------------------
# [6/6] ルールの配置
# -----------------------------------------------------------------------------
echo "[6/6] ルールを配置中..."

if [ -d "${AGENT_TEAMS_DIR}/rules" ]; then
    for rule_file in "${AGENT_TEAMS_DIR}"/rules/*.md; do
        if [ -f "$rule_file" ]; then
            filename=$(basename "$rule_file")
            copy_file \
                "$rule_file" \
                "${TARGET_CLAUDE_DIR}/rules/${filename}"
        fi
    done
else
    print_warning "ルールディレクトリが見つかりません: ${AGENT_TEAMS_DIR}/rules"
fi

echo ""

# -----------------------------------------------------------------------------
# 結果サマリー
# -----------------------------------------------------------------------------
echo "=== セットアップ完了 ==="
echo ""

if [ "$DRY_RUN" = true ]; then
    echo "ドライランが完了しました。"
    echo "--dry-run を外して実行すると実際に変更されます。"
else
    echo "結果:"
    echo "  新規作成: ${CREATED_COUNT} 件"
    echo "  更新:     ${UPDATED_COUNT} 件"
    echo "  スキップ: ${SKIPPED_COUNT} 件"
    echo ""
    echo "配置先: ${TARGET_CLAUDE_DIR}"
fi

echo ""
echo "次のステップ:"
echo "  1. Claude Code で対象プロジェクトを開く"
echo "  2. 複雑なタスクを依頼すると Agent Teams が自動で起動します"
echo "  3. または /team-start feature <タスク説明> で手動起動も可能"
echo "  4. Shift+Tab で Delegate Mode を有効化"
echo "  5. /team-review status でチーム状態を確認"
echo ""

if [ "$SKIP_SETTINGS" = false ] && ! command -v jq &> /dev/null; then
    print_warning "ヒント: jq をインストールすると settings.json の自動マージが有効になります"
    echo "  brew install jq  (macOS)"
    echo ""
fi
