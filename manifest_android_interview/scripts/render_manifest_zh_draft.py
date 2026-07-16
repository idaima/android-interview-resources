"""Render the manually translated Markdown draft as a Chinese PDF.

Run with:
PYTHONPATH=/private/tmp/pdf_tools python3 scripts/render_manifest_zh_draft.py
"""

from pathlib import Path
import re

from fpdf import FPDF


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "others" / "manifest_android_interview_zh_draft.md"
OUTPUT = ROOT / "others" / "Manifest Android 面试（简体中文）-草稿（前言至第3题）.pdf"
FONT = "/System/Library/Fonts/STHeiti Medium.ttc"
PAGE_WIDTH = 504
PAGE_HEIGHT = 655.2
MARGIN_X = 54
MARGIN_TOP = 50
MARGIN_BOTTOM = 48


class ChineseDraftPdf(FPDF):
    def header(self):
        if self.page_no() == 1:
            return
        self.set_draw_color(210, 210, 210)
        self.line(MARGIN_X, 31, PAGE_WIDTH - MARGIN_X, 31)
        self.set_font("heiti", size=7.2)
        self.set_text_color(100, 100, 100)
        self.set_xy(MARGIN_X, 18)
        self.cell(0, 10, "Manifest Android 面试", align="L")
        self.set_text_color(0, 0, 0)

    def footer(self):
        if self.page_no() == 1:
            return
        self.set_font("heiti", size=7.2)
        self.set_text_color(100, 100, 100)
        self.set_y(-28)
        self.cell(0, 10, str(self.page_no()), align="C")
        self.set_text_color(0, 0, 0)


def clean_inline(text: str) -> str:
    text = re.sub(r"\*\*(.*?)\*\*", r"\1", text)
    text = text.replace("`", "").replace("‑", "-")
    text = text.translate(str.maketrans("⁰¹²³⁴⁵⁶⁷⁸⁹", "0123456789"))
    return text


def need_space(pdf: FPDF, height: float):
    if pdf.get_y() + height > PAGE_HEIGHT - MARGIN_BOTTOM:
        pdf.add_page()


def write_heading(pdf: FPDF, text: str, level: int):
    sizes = {1: 21, 2: 14.5, 3: 11.5}
    before = {1: 12, 2: 9, 3: 7}[level]
    need_space(pdf, before + sizes[level] * 2.0)
    pdf.ln(before)
    pdf.set_font("heiti", size=sizes[level])
    pdf.multi_cell(0, sizes[level] * 1.25, clean_inline(text), new_x="LMARGIN", new_y="NEXT")
    pdf.ln(2.5)


def write_paragraph(pdf: FPDF, text: str):
    text = clean_inline(text)
    if not text:
        pdf.ln(5)
        return
    if text.startswith("- "):
        text = "- " + text[2:]
    if re.match(r"^\d+\. ", text):
        pass
    pdf.set_font("heiti", size=9.5)
    # The source contains very long URL query strings.  Split only such tokens;
    # regular Chinese paragraphs retain normal CJK line breaking.
    text = re.sub(r"[A-Za-z0-9:/?&=._-]{29,}", lambda m: " ".join(
        m.group(0)[i:i + 26] for i in range(0, len(m.group(0)), 26)
    ), text)
    # Avoid entering MultiCell with less than one line remaining at the bottom of
    # a page; this is a known edge case for some TTC-backed CJK fonts in fpdf2.
    need_space(pdf, 16)
    pdf.set_x(MARGIN_X)
    try:
        pdf.multi_cell(0, 14.1, text, new_x="LMARGIN", new_y="NEXT")
    except Exception as exc:
        raise RuntimeError(f"Unable to lay out paragraph: {text[:180]!r}") from exc
    pdf.ln(2.2)


def main():
    pdf = ChineseDraftPdf(orientation="P", unit="pt", format=(PAGE_WIDTH, PAGE_HEIGHT))
    pdf.set_auto_page_break(auto=True, margin=MARGIN_BOTTOM)
    pdf.set_margins(MARGIN_X, MARGIN_TOP, MARGIN_X)
    pdf.add_font("heiti", "", FONT)
    pdf.set_title("Manifest Android 面试（简体中文）")
    pdf.set_author("Jaewoong Eum；简体中文翻译稿")
    pdf.add_page()

    lines = SOURCE.read_text(encoding="utf-8").splitlines()
    paragraph = []

    def flush():
        nonlocal paragraph
        if paragraph:
            write_paragraph(pdf, " ".join(piece.strip() for piece in paragraph))
            paragraph = []

    for raw in lines:
        line = raw.strip()
        if line == "---":
            flush()
            pdf.add_page()
        elif line.startswith("### "):
            flush()
            write_heading(pdf, line[4:], 3)
        elif line.startswith("## "):
            flush()
            write_heading(pdf, line[3:], 2)
        elif line.startswith("# "):
            flush()
            write_heading(pdf, line[2:], 1)
        elif line.startswith("- ") or re.match(r"^\d+\. ", line):
            # Keep list items independent; combining many items into one MultiCell
            # can trigger a page-break bug in fpdf2's TTC layout engine.
            flush()
            write_paragraph(pdf, line)
        elif not line:
            flush()
        else:
            paragraph.append(line.rstrip("  "))
    flush()
    pdf.output(str(OUTPUT))
    print(OUTPUT)


if __name__ == "__main__":
    main()
