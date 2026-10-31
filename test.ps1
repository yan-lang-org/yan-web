# 校验 index.html 里的示例代码：
#   含 fn main 的 <pre><code> 块 —— 原样编译并运行，比对期望输出；
#   其余块（"三十秒上手"的命令）—— 检查引用的 examples\*.yan 是否存在。
# 用法：powershell -ExecutionPolicy Bypass -File test.ps1 [-Yan <yan.exe 路径>]
param([string]$Yan = '')

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Yan) { $Yan = Join-Path $root '..\yan-lang\bin\yan.exe' }
if (-not (Test-Path $Yan)) {
    Write-Host "找不到编译器：$Yan（用 -Yan 指定）" -ForegroundColor Red
    exit 2
}
$Yan = (Resolve-Path $Yan).Path

$html = Get-Content -Raw -Encoding UTF8 (Join-Path $root 'index.html')
$blocks = @([regex]::Matches($html, '(?s)<pre><code>(.*?)</code></pre>') | ForEach-Object { $_.Groups[1].Value })

# 期望输出按「含 fn main 的程序块」出现顺序排列；页面增删程序块时同步改这里
$expect = @(
    @{ name = '按位访问（寄存器字段）'; lines = @('5', '41928') },
    @{ name = 'fib + 数组求和';        lines = @('fib(20) = 6765, sum = 108') }
)

$fail = 0
$progIdx = 0
$tmp = Join-Path $env:TEMP ('yanweb-test-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory (Join-Path $tmp 'build') -Force | Out-Null

foreach ($raw in $blocks) {
    $code = [System.Net.WebUtility]::HtmlDecode(($raw -replace '<[^>]+>', '')).Trim()

    if ($code -match 'fn main') {
        $exp = $expect[$progIdx]
        $progIdx++
        $file = Join-Path $tmp ("sample$progIdx.yan")
        # 必须无 BOM：Windows PowerShell 的 -Encoding UTF8 会加 BOM，Yan 的词法器会报 E0001
        [System.IO.File]::WriteAllText($file, $code, (New-Object System.Text.UTF8Encoding $false))

        Push-Location $tmp
        $out = & $Yan run $file 2>&1
        $rc = $LASTEXITCODE
        Pop-Location

        $text = ($out | ForEach-Object { "$_" }) -join "`n"
        $stdout = @($out | ForEach-Object { "$_" } | Where-Object { $_ -notmatch '^native: ' -and $_.Trim() -ne '' })
        $broken = $text -match 'error\[|超出 M4|不支持|语义分析失败'
        $miss = @($exp.lines | Where-Object { $stdout -notcontains $_ })

        if ($rc -ne 0 -or $broken -or $miss.Count -gt 0) {
            $fail++
            Write-Host ("FAIL  {0}" -f $exp.name) -ForegroundColor Red
            if ($rc -ne 0) { Write-Host "      退出码 $rc" }
            if ($miss.Count -gt 0) { Write-Host ("      缺少输出行：{0}" -f ($miss -join ' / ')) }
            Write-Host ($text -replace '(?m)^', '      ')
        } else {
            Write-Host ("ok    {0}  →  {1}" -f $exp.name, ($stdout -join ' | ')) -ForegroundColor Green
        }
    } else {
        $files = @([regex]::Matches($code, 'examples\\[\w.\-]+\.yan') | ForEach-Object { $_.Value })
        $gone = @($files | Where-Object { -not (Test-Path (Join-Path $root ("..\yan-lang\" + $_))) })
        if ($gone.Count -gt 0) {
            $fail++
            Write-Host ("FAIL  命令块：引用了不存在的文件 {0}" -f ($gone -join ', ')) -ForegroundColor Red
        } else {
            Write-Host ("ok    命令块（{0} 个示例文件都在）" -f $files.Count) -ForegroundColor Green
        }
    }
}

if ($progIdx -ne $expect.Count) {
    $fail++
    Write-Host ("FAIL  页面上有 {0} 个程序块，断言表里是 {1} 个" -f $progIdx, $expect.Count) -ForegroundColor Red
}

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue

Write-Host ''
if ($fail -gt 0) { Write-Host "$fail 处失败" -ForegroundColor Red; exit 1 }
Write-Host '全部通过' -ForegroundColor Green
