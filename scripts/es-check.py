#!/usr/bin/env python3
# ESの本文を、15（通過ESの文体と構成）の5章の基準で数える。
# 使い方：python3 scripts/es-check.py <ファイル> [ガクチカ|志望]
# 本文は「。」を3つ以上含む100字以上の行として取り出す
import re, sys, statistics

TIME_WORDS = r"^(\d+月|当初|初めは|最初は|すると|その後|続けるうちに)"
FEEL = r"思っ|感じ|迷|不思議|嬉し|悔し"

def max_run(xs, same):
    best = run = 1
    for x, y in zip(xs, xs[1:]):
        run = run + 1 if same(x, y) else 1
        best = max(best, run)
    return best


def tail(s):
    s = re.sub(r"[。」）]+$", "", s)
    for e in ("ました", "ている", "です", "ます", "ない", "た", "だ", "る", "い"):
        if s.endswith(e):
            return e
    return "体言"


def check(text, kind):
    ss = [s.strip() for s in re.split(r"(?<=。)", text) if s.strip()]
    ends = ["敬体" if re.search(r"(ます|です|ました|ません|でした)[。」）]*$", s) else "常体" for s in ss]
    keitai = ends.count("敬体") / len(ss)
    run = best = 0
    for s in ss:
        run = run + 1 if re.search(r"ました[。」）]*$", s) else 0
        best = max(best, run)
    nums = re.findall(r"\d+", text)
    detail = re.findall(r"\d+(時|分|月|日|年生)", text)
    lens = [len(s) for s in ss]
    feel = [i + 1 for i, s in enumerate(ss) if re.search(FEEL, s)]
    lo, hi = (2, 4) if kind == "ガクチカ" else (0, 1)
    rows = [
        ("文体", f"敬体{keitai:.0%}", keitai <= 0.1 or keitai >= 0.9, "1回答の中で90%以上同じ。既定は常体"),
        ("「ました」の連続", f"最長{best}文", best <= 2, "2文まで"),
        ("1文目", ss[0][:30], not re.search(r"こと(です|だ)?。$", ss[0]) or kind != "ガクチカ", "ガクチカは立場＋行動＋成果の見出し"),
        ("課題・原因の語", "あり" if re.search(r"課題|問題|原因|要因|壁", text) else "なし", kind != "ガクチカ" or bool(re.search(r"課題|問題|原因|要因|壁", text)), "ガクチカ・挫折は必須"),
        ("そこで／結果", f"そこで{'あり' if 'そこで' in text else 'なし'}・結果{'あり' if re.search(r'結果、|その結果', text) else 'なし'}", kind != "ガクチカ" or ("そこで" in text and bool(re.search(r"結果、|その結果", text))), "ガクチカは両方"),
        ("時の語で始まる文", f"{sum(1 for s in ss if re.search(TIME_WORDS, s))}文", sum(1 for s in ss if re.search(TIME_WORDS, s)) <= 1, "1文まで"),
        ("数字", f"{len(nums)}個（時刻・分・月日・学年{len(detail)}）", lo <= len(nums) <= hi and len(detail) <= 1, f"{lo}〜{hi}個、時刻・分・月日・学年は行動の細部として1つまで（15の1-7）"),
        ("1文の長さ", f"中央値{statistics.median(lens):.0f}字・最大{max(lens)}字", 40 <= statistics.median(lens) <= 55 and max(lens) <= 80, "中央値40〜55字、80字以下"),
        ("理由づけの連鎖", f"{len(re.findall(r'と捉え|と考え|と判断し|そのため', text))}個", True, "上限なし（16を優先）"),
        ("リズム（似た長さの連続）", f"最長{max_run([len(s) for s in ss], lambda x, y: abs(x - y) <= 0.2 * max(x, y))}文", max_run([len(s) for s in ss], lambda x, y: abs(x - y) <= 0.2 * max(x, y)) <= 3, "3文まで（17の5-2）"),
        ("リズム（同じ文末の連続）", f"最長{max_run([tail(s) for s in ss], lambda x, y: x == y)}文", max_run([tail(s) for s in ss], lambda x, y: x == y) <= 3, "3文まで（17の5-2）"),
        ("リズム（長い文）", f"70字以上 {sum(1 for s in ss if len(s) >= 70)}文", sum(1 for s in ss if len(s) >= 70) >= 1 or len(text) < 250, "250字以上なら1文以上（17の5-2）"),
        ("「そこで」の数", f"{text.count('そこで')}回", text.count("そこで") <= 1, "1回まで（17の5-2）"),
        ("気持ちの文", f"{len(feel)}文（{feel}文目）", len(feel) == 0, "0（16の1-1）。動機の節（〜という想いから、〜した）は目で確かめる"),
    ]
    for name, val, ok, rule in rows:
        print(f"{'OK ' if ok else 'NG '} {name}：{val}　（基準：{rule}）")

if __name__ == "__main__":
    kind = sys.argv[2] if len(sys.argv) > 2 else "ガクチカ"
    for line in open(sys.argv[1]).read().splitlines():
        if len(line) >= 100 and line.count("。") >= 3:
            print(f"--- {line[:20]}…（{len(line)}字）")
            check(line, kind)
