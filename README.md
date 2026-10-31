# 砚 Yan 官网（yan-web）

Yan 语言的门面站点。**纯静态**：没有构建步骤、没有外部依赖、没有外部字体，
双击 `index.html` 就能看。

## 文件

```
index.html        整页（语义化 HTML，内联无脚本）
assets/style.css  墨 / 宣纸 / 朱砂 三色，系统字体
assets/yan-logo.svg      主图标（与 yan-web、yan-lang 用同一份）
assets/yan-mark-mono.svg 单色版（favicon 备用）
_headers          站点响应头（安全头）
serve.bat         本地预览（python -m http.server 8080）
test.ps1          示例代码校验（抽出页面代码块，编译运行并比对输出）
```

## 本地预览

```bat
serve.bat          :: 然后打开 http://localhost:8080
```

## 示例代码校验

页面里的代码块不是装饰：`test.ps1` 把 `index.html` 的每个 `<pre><code>` 抽出来，
含 `fn main` 的**原样编译运行并比对期望输出**，命令块则检查它引用的 `examples\*.yan` 确实存在。

```bat
powershell -ExecutionPolicy Bypass -File test.ps1
```

改了页面代码块就要同步 `test.ps1` 顶部的 `$expect` 断言表 —— 否则脚本会报「块数与断言表不符」。

## 部署

线上：**https://yan-lang.org**

| 项 | 值 |
| --- | --- |
| 框架预设 | None（纯静态） |
| 根目录 | 本目录 |
| 构建命令 | **留空** |
| 输出目录 | `.` |
| 生产分支 | `main` |

把仓库连到静态托管平台，按上表填即可；推送到 `main` 自动发布。
也可以直接上传本目录，`_headers` 会一起生效。

`_headers` 只放安全头，缓存用平台默认值。

## 改内容时的三条约束

1. **三色封顶**：`#1a1a1a` 墨 / `#f5f1e6` 宣纸 / `#c8322b` 朱砂。加第四色就是设计走偏。
2. **不引外部资源**：不引 CDN、不引 Google Fonts（大陆访问会卡，且破坏"零依赖"的一致性）。
3. **文案以 `yan-lang` 公开仓为准**：`docs/SPEC.md` 是语法权威，`TUTORIAL.md` 是教程；
   本页只做"三十秒说清它是什么"，不复制规范细节（复制必然漂移）。
