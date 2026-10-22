#!/bin/bash
# 起動時に呼ばれる。前回の確認から3日以上たっていたら、GitHubの更新を確認して取り込む。
cd "$(dirname "$0")/.." || exit 0
# はじめての人（経験DBがまだ空で、/start もまだ）には、/start を勧める
if ! ls 経験DB/_inbox/*_start.md >/dev/null 2>&1 && [ -z "$(ls 経験DB | grep -v -e '^_' -e '.gitkeep')" ]; then
  echo "【ES対策室】はじめての人です。最初の返事で、あいさつと一緒に「まず /start と打ってください（10分で、あなたの話がESの1文になるところを体験できます）」と短く伝えてください。"
fi
stamp=.update_last_check
now=$(date +%s)
last=$(cat "$stamp" 2>/dev/null || echo 0)
[ $((now - last)) -lt $((3 * 86400)) ] && exit 0
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
