#!/bin/bash
# ファイルを読む・書く道具が、ES対策室のフォルダの外を触ろうとしたら止める（PreToolUse のフック）。
# 例外：Claude Code 自身が使う場所（~/.claude の作業ファイル、一時フォルダ）。
export LC_ALL=C  # 日本語のパスでも sed が止まらないように、バイト単位で扱う
input=$(cat)

# file_path / path / notebook_path の値を取り出す（jq が無い Windows でも動くよう、sed で取る）
target=$(printf '%s' "$input" | sed -n -E 's/.*"(file_path|notebook_path|path)"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\2/p' | head -1)
[ -z "$target" ] && exit 0   # 行き先の指定がない（Glob・Grep の既定＝今のフォルダ）

norm() {
  # \\ と \ を / に、C:/ を /c/ に、大文字小文字をそろえ、/./ と末尾の / を消す
  printf '%s' "$1" | sed -e 's#\\\\#/#g' -e 's#\\#/#g' -e 's#^\([A-Za-z]\):/#/\1/#' -e 's#/\./#/#g' -e 's#/$##' | tr '[:upper:]' '[:lower:]'
}

root=$(norm "${CLAUDE_PROJECT_DIR:-$PWD}")
case "$target" in
  /*|[A-Za-z]:*|\\*) abs="$target" ;;
  "~"*) abs="$HOME${target#\~}" ;;
  *) abs="${CLAUDE_PROJECT_DIR:-$PWD}/$target" ;;
esac
abs=$(norm "$abs")

# .. を含む行き先は、外に出る可能性があるので止める
case "$abs" in *"/../"*|*"/..") reason="「..」を含む行き先" ;; esac

if [ -z "$reason" ]; then
  case "$abs" in
    "$root"|"$root"/*) exit 0 ;;
    "$(norm "$HOME")/.claude/projects/"*) exit 0 ;;   # Claude Code 自身の作業ファイル
    */tmp/claude-*|*/temp/claude-*) exit 0 ;;           # Claude Code の一時フォルダ
  esac
  reason="ES対策室のフォルダの外（$target）"
fi

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s は触らない決まりです。必要なファイルは、ES対策室のフォルダの中に入れてから頼んでください。"}}\n' "$(printf '%s' "$reason" | sed 's/"/\\"/g')"
exit 0
