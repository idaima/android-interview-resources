#!/usr/bin/env zsh
# Rebuild the consolidated design-pattern guide and its self-contained assets.
set -euo pipefail

root=${0:A:h:h}
output="$root/android_design_patterns_analysis.md"
assets="$root/assets/design-patterns"
temporary="$output.tmp"

typeset -a patterns
patterns=(
  '创建型模式|singleton|单例模式|singleton/mr.simple/readme.md|singleton/mr.simple/images'
  '创建型模式|builder|Builder 模式|builder/mr.simple/readme.md|builder/mr.simple/images'
  '创建型模式|prototype|原型模式|prototype/mr.simple/readme.md|prototype/mr.simple/images'
  '结构型模式|facade|外观模式（Facade）|facade/elsdnwn/readme.md|facade/elsdnwn/images'
  '结构型模式|proxy|代理模式|proxy/singwhatiwanna/README.md|proxy/singwhatiwanna/images'
  '结构型模式|bridge|桥接模式|bridge/shen0834/readme.md|'
  '行为型模式|template-method|模板方法模式|template-method/mr.simple/readme.md|template-method/mr.simple/images'
  '行为型模式|strategy|策略模式|strategy/gkerison/README.md|strategy/gkerison/images'
  '行为型模式|iterator|迭代器模式|iterator/haoxiqiang/readme.md|iterator/haoxiqiang/images'
  '行为型模式|chain-of-responsibility|责任链模式|chain-of-responsibility/AigeStudio/readme.md|chain-of-responsibility/AigeStudio/images'
  '行为型模式|command|命令模式|command/lijunhuayc/readme.md|command/lijunhuayc/images'
)

mkdir -p "$assets"

for entry in "${patterns[@]}"; do
  IFS='|' read -r category key title source image_dir <<< "$entry"
  if [[ -n "$image_dir" && -d "$root/$image_dir" ]]; then
    mkdir -p "$assets/$key"
    find "$root/$image_dir" -type f ! -name '.*' -exec cp {} "$assets/$key/" \;
  fi
done

print -r -- '# Android 源码设计模式解析' > "$temporary"
print >> "$temporary"
print -r -- '本文件汇总了任务表中已完成的 11 篇设计模式解析，并按 GoF 的创建型、结构型和行为型模式分类。各篇原文仅调整了标题层级及本地图片路径；图片已统一放入 [`assets/design-patterns`](assets/design-patterns/) 目录。' >> "$temporary"
print >> "$temporary"
print -r -- '## 目录' >> "$temporary"
print >> "$temporary"
print -r -- '- 创建型模式：[单例](#singleton)、[Builder](#builder)、[原型](#prototype)' >> "$temporary"
print -r -- '- 结构型模式：[外观](#facade)、[代理](#proxy)、[桥接](#bridge)' >> "$temporary"
print -r -- '- 行为型模式：[模板方法](#template-method)、[策略](#strategy)、[迭代器](#iterator)、[责任链](#chain-of-responsibility)、[命令](#command)' >> "$temporary"
print >> "$temporary"

last_category=''
for entry in "${patterns[@]}"; do
  IFS='|' read -r category key title source image_dir <<< "$entry"
  if [[ "$category" != "$last_category" ]]; then
    print "## $category" >> "$temporary"
    print >> "$temporary"
    last_category="$category"
  fi

  print "<a id=\"$key\"></a>" >> "$temporary"
  print >> "$temporary"

  if [[ "$key" == 'bridge' ]]; then
    print -r -- '> 注：原文引用的两张 CSDN UML 图片现已无法取得（原链接返回 404）。为保证汇总文档可离线阅读，以下两图按原文描述重绘并本地化。' >> "$temporary"
    print >> "$temporary"
  fi

  # The first two source lines are its Setext title. Replace them with a
  # nested heading, then point image references at consolidated assets.
  print "### $title" >> "$temporary"
  tail -n +3 "$root/$source" | sed -E \
    -e 's/^(#{1,4})(.*)$/##\1\2/' \
    -e "s#https://github.com/simple-android-framework-exchange/android_design_patterns_analysis/blob/master/chain-of-responsibility/AigeStudio/images/chain-of-responsibility.jpg\\?raw=true#assets/design-patterns/chain-of-responsibility/chain-of-responsibility.jpg#g" \
    -e 's#http://img.blog.csdn.net/20150322120730408#assets/design-patterns/bridge/bridge-gof-uml.svg#g' \
    -e 's#http://img.blog.csdn.net/20150322120809221#assets/design-patterns/bridge/bridge-android-uml.svg#g' \
    -e "s#images/#assets/design-patterns/$key/#g" \
    >> "$temporary"
  print >> "$temporary"
done

mv "$temporary" "$output"
