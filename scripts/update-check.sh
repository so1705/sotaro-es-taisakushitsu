#!/bin/bash
# 起動時に呼ばれる。前回の確認から14日以上たっていたら、GitHubの更新を確認して取り込む。
cd "$(dirname "$0")/.." || exit 0
stamp=.update_last_check
now=$(date +%s)
last=$(cat "$stamp" 2>/dev/null || echo 0)
[ $((now - last)) -lt $((14 * 86400)) ] && exit 0
echo "$now" > "$stamp"

git fetch --quiet --tags origin 2>/dev/null || exit 0
local_ver=$(cat VERSION)
remote_ver=$(git show origin/main:VERSION 2>/dev/null)
[ -z "$remote_ver" ] || [ "$local_ver" = "$remote_ver" ] && exit 0

if git pull --quiet --ff-only origin main 2>/dev/null; then
  echo "【ES対策室】更新を取り込みました（$local_ver → $remote_ver）。本人に、更新内容を一言で伝えてください："
  git diff "$local_ver".."$remote_ver" -- CHANGELOG.md 2>/dev/null | grep '^+-' | sed 's/^+//' | head -10
else
  echo "【ES対策室】新しい版（$remote_ver）がありますが、自動で取り込めませんでした。本人に、手動での更新が必要だと伝えてください。"
fi
