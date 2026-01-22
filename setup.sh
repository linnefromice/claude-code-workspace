#!/bin/bash

set -e

# Claude Code Workspace Setup Script
# このリポジトリの設定を対象プロジェクトに適用します

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 色付き出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

usage() {
    echo "Usage: $0 <target-project-path>"
    echo ""
    echo "対象プロジェクトに Claude Code の設定を適用します。"
    echo ""
    echo "適用される設定:"
    echo "  - CLAUDE.md           チーム共有設定（既存ファイルには追記）"
    echo "  - CLAUDE.local.md     ローカル設定テンプレート"
    echo "  - .ai/tasks/          タスク管理ディレクトリ"
    echo "  - .gitignore          CLAUDE.local.md の除外設定"
    exit 1
}

# 引数チェック
if [ $# -eq 0 ]; then
    usage
fi

TARGET_DIR="$1"

# 対象ディレクトリの存在確認
if [ ! -d "$TARGET_DIR" ]; then
    print_error "ディレクトリが存在しません: $TARGET_DIR"
    exit 1
fi

# 絶対パスに変換
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "Claude Code Workspace Setup"
echo "==========================="
echo "対象: $TARGET_DIR"
echo ""

# CLAUDE.md の処理（既存ファイルには追記）
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo "" >> "$TARGET_DIR/CLAUDE.md"
    echo "" >> "$TARGET_DIR/CLAUDE.md"
    cat "$SCRIPT_DIR/CLAUDE_ADDITION.md" >> "$TARGET_DIR/CLAUDE.md"
    print_success "CLAUDE.md に追記しました"
else
    cp "$SCRIPT_DIR/CLAUDE_ADDITION.md" "$TARGET_DIR/CLAUDE.md"
    print_success "CLAUDE.md を作成しました"
fi

# CLAUDE.local.md の処理（既存ファイルがあればスキップ）
if [ -f "$TARGET_DIR/CLAUDE.local.md" ]; then
    print_warning "CLAUDE.local.md は既に存在します。スキップします。"
else
    cp "$SCRIPT_DIR/CLAUDE.local.md" "$TARGET_DIR/CLAUDE.local.md"
    print_success "CLAUDE.local.md を作成しました"
fi

# .ai/tasks ディレクトリ構造の作成
TASK_DIRS=("records" "design" "todos" "prompts")

for dir in "${TASK_DIRS[@]}"; do
    target_path="$TARGET_DIR/.ai/tasks/$dir"
    if [ -d "$target_path" ]; then
        print_warning ".ai/tasks/$dir は既に存在します"
    else
        mkdir -p "$target_path"
        touch "$target_path/.gitkeep"
        print_success ".ai/tasks/$dir を作成しました"
    fi
done

# .gitignore の更新
GITIGNORE_ADDITION="$SCRIPT_DIR/.gitignore_ADDTION"

if [ -f "$TARGET_DIR/.gitignore" ]; then
    # 追加内容が既に含まれているかチェック
    if grep -qxF "CLAUDE.local.md" "$TARGET_DIR/.gitignore" 2>/dev/null; then
        print_warning ".gitignore は既に設定済みです"
    else
        echo "" >> "$TARGET_DIR/.gitignore"
        echo "# Claude Code local files" >> "$TARGET_DIR/.gitignore"
        cat "$GITIGNORE_ADDITION" >> "$TARGET_DIR/.gitignore"
        print_success ".gitignore を更新しました"
    fi
else
    echo "# Claude Code local files" > "$TARGET_DIR/.gitignore"
    cat "$GITIGNORE_ADDITION" >> "$TARGET_DIR/.gitignore"
    print_success ".gitignore を作成しました"
fi

echo ""
echo "==========================="
print_success "セットアップが完了しました"
echo ""
echo "次のステップ:"
echo "  1. $TARGET_DIR/CLAUDE.md をプロジェクトに合わせて編集"
echo "  2. 必要に応じて CLAUDE.local.md をカスタマイズ"
echo "  3. .gitignore の変更をコミット"
