"""Split the translated Manifest Android Interview draft by the book TOC.

This is intentionally a one-off, mechanical migration: it preserves all translated
body text while replacing the former monolithic draft with a small navigation file.
"""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DRAFT = ROOT / "others" / "manifest_android_interview_zh_draft.md"
PARTS = ROOT / "others" / "manifest_android_interview_zh"
ANDROID = PARTS / "01-Android面试题"
COMPOSE = PARTS / "02-Jetpack Compose面试题"
SPLIT_MARKER = "# 0. Android 面试题\n"


def write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content.rstrip() + "\n", encoding="utf-8")


def placeholder(title: str, original_pages: str) -> str:
    return f"""# {title}

> 原书页码：{original_pages}  
> 翻译状态：未开始

<!-- 后续翻译直接补充在此文件。代码、API 名称、链接和原有章节层级应保持不变。 -->
"""


def main() -> None:
    draft = DRAFT.read_text(encoding="utf-8")
    if SPLIT_MARKER not in draft:
        raise ValueError("找不到 Android 面试题章节标记；已停止，避免覆盖译稿。")
    front_matter, framework = draft.split(SPLIT_MARKER, maxsplit=1)

    # Existing translated prose is retained verbatim in the two appropriate files.
    write(
        PARTS / "00-前置内容.md",
        """# 前置内容

> 原书页码：1–7  
> 翻译状态：已完成

""" + front_matter,
    )
    write(
        ANDROID / "00-Android框架.md",
        """# 0. Android 面试题

## 类别 0：Android 框架

> 原书页码：8–117  
> 翻译状态：进行中（已完成问题 0–4）

""" + framework.replace("# 类别 0：Android 框架\n", "", 1),
    )

    write(ANDROID / "01-Android UI-View.md", placeholder("类别 1：Android UI — View", "118–184"))
    write(ANDROID / "02-Jetpack库.md", placeholder("类别 2：Jetpack 库", "185–234"))
    write(ANDROID / "03-业务逻辑.md", placeholder("类别 3：业务逻辑", "235–269"))
    write(COMPOSE / "00-Compose基础.md", placeholder("类别 0：Compose 基础", "270–319"))
    write(COMPOSE / "01-Compose Runtime.md", placeholder("类别 1：Compose Runtime", "320–378"))
    write(COMPOSE / "02-Compose UI.md", placeholder("类别 2：Compose UI", "379 起"))

    index = """# Manifest Android 面试：简体中文译稿

本译稿按原书目录拆分维护。括号中的数字为原书印刷页码；代码、API 名称、类名、链接均保持原样。

## 目录

- [前置内容](manifest_android_interview_zh/00-前置内容.md)（原书 1–7 页；已完成）
- 0. Android 面试题
  - [类别 0：Android 框架](manifest_android_interview_zh/01-Android面试题/00-Android框架.md)（8–117 页；进行中）
  - [类别 1：Android UI — View](manifest_android_interview_zh/01-Android面试题/01-Android%20UI-View.md)（118–184 页；未开始）
  - [类别 2：Jetpack 库](manifest_android_interview_zh/01-Android面试题/02-Jetpack库.md)（185–234 页；未开始）
  - [类别 3：业务逻辑](manifest_android_interview_zh/01-Android面试题/03-业务逻辑.md)（235–269 页；未开始）
- 1. Jetpack Compose 面试题
  - [类别 0：Compose 基础](manifest_android_interview_zh/02-Jetpack%20Compose面试题/00-Compose基础.md)（270–319 页；未开始）
  - [类别 1：Compose Runtime](manifest_android_interview_zh/02-Jetpack%20Compose面试题/01-Compose%20Runtime.md)（320–378 页；未开始）
  - [类别 2：Compose UI](manifest_android_interview_zh/02-Jetpack%20Compose面试题/02-Compose%20UI.md)（379 页起；未开始）

## 翻译约定

- 保留 Kotlin、Java、XML、Gradle 与命令示例的原文。
- 保留 Android API、类名、方法名、注解和链接；仅翻译说明性文字。
- 每完成一个分类，就在相应文件的“翻译状态”处更新进度。
"""
    write(PARTS / "目录.md", index)
    write(
        DRAFT,
        """# Manifest Android 面试：简体中文译稿

译稿已按原书目录拆分维护，请从 [目录](manifest_android_interview_zh/目录.md) 进入对应分类。

当前续译位置：[类别 0：Android 框架](manifest_android_interview_zh/01-Android面试题/00-Android框架.md)（已完成问题 0–4）。
""",
    )


if __name__ == "__main__":
    main()
