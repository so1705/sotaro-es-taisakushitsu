#!/bin/bash
# ES対策室 かんたんセットアップ（Mac・試験版）
# 使い方：ターミナルに次の1行を貼って Enter
#   curl -fsSL https://raw.githubusercontent.com/so1705/sotaro-es-taisakushitsu/main/scripts/install.sh | bash
# やること：Git の確認 → Claude Code を入れる → ES対策室をダウンロード → デスクトップに「ES対策室」のアイコンを作る
# すでに入っているものは、飛ばします。何度実行しても大丈夫です。
set -e
say() { printf '\n▶ %s\n' "$1"; }
ok() { printf '  ✓ %s\n' "$1"; }
export PATH="$HOME/.local/bin:$PATH"

echo "ES対策室のセットアップを始めます。5〜10分ほどかかります。途中で閉じないでください。"

say "1/4 Git（ES対策室を受け取り、最新に保つ道具）"
if xcode-select -p >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
  ok "Git はもう入っています"
else
  echo "  「コマンドライン・デベロッパ・ツール」を入れる画面が出ます。「インストール」を押し、終わったら、もう一度この1行を実行してください。"
  xcode-select --install || true
  exit 0
fi

say "2/4 Claude Code（パソコンの中で動く、Claude の作業係）"
if command -v claude >/dev/null 2>&1; then
  ok "Claude Code はもう入っています"
else
  curl -fsSL https://claude.ai/install.sh | bash
  ok "Claude Code を入れました"
fi

say "3/4 ES対策室をダウンロード"
dir="$HOME/sotaro-es-taisakushitsu"
if [ -d "$dir/.git" ]; then
  git -C "$dir" pull --quiet --ff-only
  ok "ES対策室はもうあるので、最新にしました"
else
  git clone --quiet https://github.com/so1705/sotaro-es-taisakushitsu.git "$dir"
  ok "ES対策室をダウンロードしました（$dir）"
fi

say "4/4 デスクトップに「ES対策室」のアイコンを作る"
app="$HOME/Desktop/ES対策室.command"
cat > "$app" <<EOF
#!/bin/bash
export PATH="\$HOME/.local/bin:\$PATH"
cd "$dir" && claude
EOF
chmod +x "$app"
ok "デスクトップに「ES対策室」のアイコンを作りました"

echo ""
echo "セットアップが終わりました！"
echo "次は、デスクトップの「ES対策室」をダブルクリックして起動してください。"
echo "初めての時は、ブラウザで Claude にログインします。起動したら /start と打ってください。"
