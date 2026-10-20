#!/usr/bin/env python3
# 有料版の知識・手順から、無料版（Claude.aiのプロジェクト）にアップロードするファイルを作る。
# 使い方：python3 scripts/build-free.py  → free/アップロード用/ に出力
import pathlib, re

root = pathlib.Path(__file__).resolve().parent.parent
k = root / "knowledge/es-pro"
out = root / "free/アップロード用"
out.mkdir(parents=True, exist_ok=True)
version = (root / "VERSION").read_text().strip()

def strip_front(text):
    return re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.S)

def bundle(name, title, parts):
    body = [f"# {title}（ES対策室 {version}）\n"]
    for label, path in parts:
        body.append(f"\n\n---\n# 【{label}】\n\n" + strip_front(path.read_text()))
    (out / name).write_text("".join(body))

def kfile(n):
    return next(k.glob(f"{n:02d}_*.md"))

bundle("知識1_ESの考え方.md", "知識1：ESの考え方",
       [(kfile(n).stem, kfile(n)) for n in (0, 1, 3, 4, 5, 13)])
bundle("知識2_型と業界.md", "知識2：型と業界",
       [(kfile(n).stem, kfile(n)) for n in (2, 6, 8, 9, 10, 11)])
bundle("知識3_文章の仕上げ.md", "知識3：文章の仕上げ",
       [(kfile(n).stem, kfile(n)) for n in (7, 12)])

skills = root / ".claude/skills"
agents = root / ".claude/agents"
cmds = root / ".claude/commands"
procedure = (root / "free/src/無料版の進め方.md").read_text()
parts = [
    ("ES作成（es-create）", skills / "es-create/SKILL.md"),
    ("/es の進め方（統合のルール）", cmds / "es.md"),
    ("ESレビュー（es-review）", skills / "es-review/SKILL.md"),
    ("ラリー（es-rally）", skills / "es-rally/SKILL.md"),
    ("深掘り（deep-dive）", skills / "deep-dive/SKILL.md"),
] + [(f"役の定義：{p.stem}", p) for p in sorted(agents.glob("*.md"))]
body = [procedure.replace("# 手順：作成と審査（無料版）", f"# 手順：作成と審査（無料版・ES対策室 {version}）", 1)]
for label, path in parts:
    body.append(f"\n\n---\n# 【{label}】\n\n" + strip_front(path.read_text()))
(out / "手順_作成と審査.md").write_text("".join(body))

(out / "プロジェクトの指示.txt").write_text((root / "free/src/プロジェクトの指示.md").read_text().replace("{{VERSION}}", version))

# ChatGPT用（無料版の自分史インタビュー）：指示＋資料2つ
gpt = root / "free/ChatGPT用"
gpt.mkdir(parents=True, exist_ok=True)
inst = (root / "interview/自分史インタビュアー_指示.md").read_text()
(gpt / "指示.txt").write_text(inst.split("\n---\n", 1)[1].strip() + "\n")
def section(text, start, end=None):
    i = text.index(start)
    j = text.index(end, i + len(start)) if end else len(text)
    return text[i:j]
k13 = kfile(13).read_text()
parts1 = [("14_自分史インタビューの設計", strip_front(kfile(14).read_text())),
          ("07_文体と盛り", strip_front(kfile(7).read_text())),
          ("13の4章 聞き方の決まり", section(k13, "## 4. 補強の質問の作り方", "## 5."))]
(gpt / "資料1_インタビューの設計.md").write_text(f"# 資料1：インタビューの設計（ES対策室 {version}）\n" + "".join(f"\n\n---\n# 【{l}】\n\n{b}" for l, b in parts1))
parts2 = [(kfile(n).stem, strip_front(kfile(n).read_text())) for n in (11, 8, 5)]
(gpt / "資料2_ESの型.md").write_text(f"# 資料2：ESの型（ES対策室 {version}）\n" + "".join(f"\n\n---\n# 【{l}】\n\n{b}" for l, b in parts2))

for p in sorted(list(out.iterdir()) + list(gpt.iterdir())):
    print(f"{p.name}\t{len(p.read_text())}字")
