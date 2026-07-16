#!/usr/bin/env zsh
# Build self-contained local copies of the five requested study categories.
set -euo pipefail

root=${0:A:h:h}
output="$root/local-documents"
assets="$output/assets"

typeset -A titles
titles=(
  android-interview 'Android 面试常考知识点归纳'
  source-analysis '源码分析：OkHttp'
  data-structures '数据结构与算法知识点'
  java-interview 'Java 常考知识点'
  design-patterns '设计模式'
)

copy_images() {
  local category=$1
  shift
  local destination="$assets/$category"
  local image relative target
  mkdir -p "$destination"

  while IFS= read -r image; do
    relative=${image#/}
    [[ -f "$root/$relative" ]] || {
      print -u2 -- "Missing image resource: $relative"
      return 1
    }
    target="$destination/${relative#images/}"
    mkdir -p "${target:h}"
    cp "$root/$relative" "$target"
  done < <(rg --no-filename -o '/?images/[^)[:space:]]+' "$@" | sed 's#^/##' | sort -u)
}

append_source() {
  local category=$1
  local source=$2
  # Strip the source document's H1; its content remains otherwise unchanged.
  tail -n +2 "$root/$source" | sed -E "s#/?images/#assets/$category/#g"
}

mkdir -p "$output" "$assets"

print -r -- '# 本地学习资料' > "$output/README.md"
print >> "$output/README.md"
print -r -- '以下文档整理自 [lisongting/preparation](https://github.com/lisongting/preparation)，按主题分类保存。每篇正文所引用的图片均已复制至同级 `assets` 目录，可离线浏览。' >> "$output/README.md"
print >> "$output/README.md"
print -r -- '- [Android 面试常考知识点归纳](android-interview.md)' >> "$output/README.md"
print -r -- '- [源码分析：OkHttp](source-analysis.md)' >> "$output/README.md"
print -r -- '- [数据结构与算法知识点](data-structures.md)' >> "$output/README.md"
print -r -- '- [Java 常考知识点](java-interview.md)' >> "$output/README.md"
print -r -- '- [设计模式](design-patterns.md)' >> "$output/README.md"

copy_images android-interview "$root/Android-1.md" "$root/Android-2.md"
print -r -- '# Android 面试常考知识点归纳' > "$output/android-interview.md"
print >> "$output/android-interview.md"
print -r -- '整理自原仓库的 Android-1 与 Android-2 文档。' >> "$output/android-interview.md"
print >> "$output/android-interview.md"
print -r -- '## 第一部分' >> "$output/android-interview.md"
append_source android-interview Android-1.md >> "$output/android-interview.md"
print >> "$output/android-interview.md"
print -r -- '## 第二部分' >> "$output/android-interview.md"
append_source android-interview Android-2.md >> "$output/android-interview.md"

copy_images source-analysis "$root/OkHttpSourceCode.md"
print -r -- '# 源码分析：OkHttp' > "$output/source-analysis.md"
append_source source-analysis OkHttpSourceCode.md >> "$output/source-analysis.md"

copy_images data-structures "$root/Algorithm.md"
print -r -- '# 数据结构与算法知识点' > "$output/data-structures.md"
append_source data-structures Algorithm.md >> "$output/data-structures.md"

copy_images java-interview "$root/Java.md"
print -r -- '# Java 常考知识点' > "$output/java-interview.md"
append_source java-interview Java.md >> "$output/java-interview.md"

copy_images design-patterns "$root/DesignPatterns.md"
print -r -- '# 设计模式' > "$output/design-patterns.md"
append_source design-patterns DesignPatterns.md >> "$output/design-patterns.md"
