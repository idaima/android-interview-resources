#!/usr/bin/env zsh
# Build an offline copy of the interview guide with all image references local.
set -euo pipefail

root=${0:A:h:h}
output="$root/local-documents"
assets="$output/assets"

mkdir -p "$assets"
cp "$root/assets/android-interview-questions.png" "$assets/android-interview-questions.png"
cp "$root/assets/overloading-vs-overriding.png" "$assets/overloading-vs-overriding.png"

print -r -- '# Android 面试指南' > "$output/android-interview-guide.md"
print >> "$output/android-interview-guide.md"
print -r -- '整理自 [stormzhang/android-interview-questions-cn](https://github.com/stormzhang/android-interview-questions-cn)。文中图片均已改为本地资源；原文部分外链示意图已按其主题重绘为 SVG，以支持离线浏览。' >> "$output/android-interview-guide.md"
print >> "$output/android-interview-guide.md"
print -r -- '<p align="center">' >> "$output/android-interview-guide.md"
print -r -- '<img alt="AndroidInterviewQuestions" src="assets/android-interview-questions.png">' >> "$output/android-interview-guide.md"
print -r -- '</p>' >> "$output/android-interview-guide.md"
print >> "$output/android-interview-guide.md"

tail -n +13 "$root/README.md" | sed \
  -e 's#https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Doubly-linked-list.svg/610px-Doubly-linked-list.svg.png#assets/doubly-linked-list.svg#g' \
  -e 's#https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Data_stack.svg/250px-Data_stack.svg.png#assets/data-stack.svg#g' \
  -e 's#http://wx4.sinaimg.cn/mw690/005JrW9Kly1fip3s09u9jj30r908emxl.jpg#assets/java-type-conversion.svg#g' \
  -e 's#https://www.techsfo.com/blog/wp-content/uploads/2014/08/complete_android_fragment_lifecycle.png#assets/fragment-lifecycle.svg#g' \
  -e 's#https://github.com/stormzhang/android-interview-questions-cn/blob/master/assets/overloading-vs-overriding.png#assets/overloading-vs-overriding.png#g' \
  >> "$output/android-interview-guide.md"
