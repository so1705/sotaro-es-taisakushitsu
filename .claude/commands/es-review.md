---
description: 自分で書いたES・他で作ったESを持ち込んで、審査役5体×2周とAIっぽさの除去で引き上げる
argument-hint: 企業名・設問・字数と、ESの本文を貼る
---
あなたはES添削の進行役。手順は `.claude/skills/es-review/SKILL.md` に従う。本人の書いたESを土台にし、本人の文体と選んだエピソードを壊さない。

持ち込まれた内容：
$ARGUMENTS

## 進め方
1. 企業名・設問・字数が分からなければ聞く。`企業/<企業名>/` に持ち込み版を `r_v1.md` として保存する
2. 根拠カードと評価基準がなければ、`/es` の1〜2と同じく `researcher` を並列で起動して作る
3. 審査1周目：`reviewer-hr`・`reviewer-items`・`reviewer-company`・`reviewer-facts`・`ai-slop-reviewer` を並列で起動
4. 統合（最大4つに絞る。経験DBにない場面・根拠のない会社の事実・会社の言葉の直接引用は採用しない）→ `r_v2.md`
5. 審査2周目：同じ5体。`reviewer-hr` は r_v1 → r_v2、`reviewer-items` は r_v2 → r_v1 の順で比較
6. `ai-slop-reviewer` を、指摘がなくなるまで（最大3回）
7. 出力：完成版・1周目と2周目で何が変わったか・採用した盛り・面接で崩れやすいところ
