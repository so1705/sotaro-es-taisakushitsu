# ES対策室 かんたんセットアップ（Windows・試験版）
# 使い方：PowerShell に次の1行を貼って Enter
#   irm https://raw.githubusercontent.com/so1705/sotaro-es-taisakushitsu/main/scripts/install.ps1 | iex
# やること：Git を入れる → Claude Code を入れる → ES対策室をダウンロード → デスクトップに「ES対策室」のアイコンを作る
# すでに入っているものは、飛ばします。何度実行しても大丈夫です。

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Say($text) { Write-Host ""; Write-Host "▶ $text" -ForegroundColor Cyan }
function Ok($text) { Write-Host "  ✓ $text" -ForegroundColor Green }
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User") + ";" + (Join-Path $HOME ".local\bin")
}

Write-Host "ES対策室のセットアップを始めます。5〜10分ほどかかります。途中で閉じないでください。" -ForegroundColor Yellow

# 1. Git
Say "1/4 Git（ES対策室を受け取り、最新に保つ道具）"
Refresh-Path
if (Get-Command git -ErrorAction SilentlyContinue) {
  Ok "Git はもう入っています"
} else {
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "  winget が見つかりませんでした。https://git-scm.com/downloads/win から Git を入れてから、もう一度この1行を実行してください。" -ForegroundColor Red
    return
  }
  Write-Host "  Git を入れています。「変更を許可しますか？」と出たら「はい」を押してください。"
  winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
  Refresh-Path
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "  Git を入れましたが、まだ見つかりません。PowerShell を閉じて開き直し、もう一度この1行を実行してください。" -ForegroundColor Red
    return
  }
  Ok "Git を入れました"
}

# 2. Claude Code
Say "2/4 Claude Code（パソコンの中で動く、Claude の作業係）"
if (Get-Command claude -ErrorAction SilentlyContinue) {
  Ok "Claude Code はもう入っています"
} else {
  Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
  Refresh-Path
  if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "  Claude Code を入れましたが、まだ見つかりません。PowerShell を閉じて開き直し、もう一度この1行を実行してください。" -ForegroundColor Red
    return
  }
  Ok "Claude Code を入れました"
}

# 3. ES対策室
Say "3/4 ES対策室をダウンロード"
$dir = Join-Path $HOME "sotaro-es-taisakushitsu"
if (Test-Path (Join-Path $dir ".git")) {
  git -C $dir pull --quiet --ff-only
  Ok "ES対策室はもうあるので、最新にしました"
} else {
  git clone --quiet https://github.com/so1705/sotaro-es-taisakushitsu.git $dir
  Ok "ES対策室をダウンロードしました（$dir）"
}

# 4. デスクトップのアイコン
Say "4/4 デスクトップに「ES対策室」のアイコンを作る"
$desktop = [Environment]::GetFolderPath("Desktop")
$link = Join-Path $desktop "ES対策室.lnk"
$shell = New-Object -ComObject WScript.Shell
$sc = $shell.CreateShortcut($link)
$sc.TargetPath = "powershell.exe"
$sc.Arguments = "-NoExit -Command `"Set-Location -LiteralPath '$dir'; claude`""
$sc.WorkingDirectory = $dir
$sc.Description = "ES対策室を起動する"
$sc.Save()
Ok "デスクトップに「ES対策室」のアイコンを作りました"

Write-Host ""
Write-Host "セットアップが終わりました！" -ForegroundColor Green
Write-Host "次は、デスクトップの「ES対策室」のアイコンをダブルクリックして起動してください。"
Write-Host "初めての時は、ブラウザで Claude にログインします。起動したら /start と打ってください。"
