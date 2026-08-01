#!/usr/bin/env pwsh

$readmePath = Resolve-Path "$PSScriptRoot\..\README.md"
$bucketPath = Resolve-Path "$PSScriptRoot\..\bucket"

$rows = Get-ChildItem "$bucketPath\*.json" | Sort-Object Name | ForEach-Object {
    $m = $_ | Get-Content -Raw | ConvertFrom-Json
    $name = $_.BaseName
    $desc = if ($m.description) { $m.description -replace '\|', '\|' } else { '' }
    $src  = if ($m.homepage) { $m.homepage -replace '\|', '\|' } else { '' }
    "| [$name]($src) | $desc |"
}

$tableLines = @(
    '## Scope'
    ''
    '| Names | Description |'
    '| ----- | ----------- |'
) + $rows

$tableBlock = $tableLines -join "`r`n"

$content = Get-Content $readmePath -Raw

$marker = '## Scope'
$idx = $content.IndexOf($marker)

if ($idx -ge 0) {
    $rest = $content.Substring($idx + $marker.Length)
    $nextHeadingIdx = $rest.IndexOf("`r`n## ")
    if ($nextHeadingIdx -ge 0) {
        $endIdx = $idx + $marker.Length + $nextHeadingIdx
        $content = $content.Substring(0, $idx) + $tableBlock + "`r`n" + $content.Substring($endIdx)
    } else {
        $content = $content.Substring(0, $idx) + $tableBlock + "`r`n"
    }
} else {
    $content = $content.TrimEnd() + "`r`n`r`n" + $tableBlock + "`r`n"
}

Set-Content -Path $readmePath -Value $content -NoNewline
