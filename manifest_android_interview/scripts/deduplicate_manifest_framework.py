"""Remove the first of two adjacent Question 5 blocks created by a concurrent edit."""

from pathlib import Path


PATH = Path(__file__).resolve().parents[1] / "others" / "manifest_android_interview_zh" / "01-Android面试题" / "00-Android框架.md"
MARKER = "## 问题 5：什么是 Application 类？"


def main() -> None:
    text = PATH.read_text(encoding="utf-8")
    first = text.find(MARKER)
    second = text.find(MARKER, first + len(MARKER))
    if first < 0 or second < 0 or text.find(MARKER, second + len(MARKER)) >= 0:
        raise ValueError("预期应恰好存在两个问题 5 标题；已停止，避免误删。")
    first_separator = text.rfind("\n---\n", 0, first)
    second_separator = text.rfind("\n---\n", 0, second)
    if first_separator < 0 or second_separator < 0:
        raise ValueError("未找到章节分隔符；已停止，避免误删。")
    PATH.write_text(text[:first_separator] + text[second_separator:], encoding="utf-8")


if __name__ == "__main__":
    main()
