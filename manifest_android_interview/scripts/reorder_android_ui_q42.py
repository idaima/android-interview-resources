"""Move the already translated Question 42 before Question 43 without altering text."""

from pathlib import Path


PATH = Path(__file__).resolve().parents[1] / "others" / "manifest_android_interview_zh" / "01-Android面试题" / "01-Android UI-View.md"
Q42 = "## 问题 42："
Q43 = "## 问题 43："


def main() -> None:
    text = PATH.read_text(encoding="utf-8")
    q42 = text.find(Q42)
    q43 = text.find(Q43)
    if q42 < 0 or q43 < 0 or q42 < q43:
        raise ValueError("问题 42/43 的位置不符合预期；已停止，避免改动译文。")
    q42_separator = text.rfind("\n---\n", 0, q42)
    q43_separator = text.rfind("\n---\n", 0, q43)
    if q42_separator < 0 or q43_separator < 0:
        raise ValueError("未找到章节分隔符；已停止，避免改动译文。")
    q42_block = text[q42_separator:]
    remaining = text[:q42_separator]
    insertion = remaining[:q43_separator] + q42_block + remaining[q43_separator:]
    PATH.write_text(insertion, encoding="utf-8")


if __name__ == "__main__":
    main()
