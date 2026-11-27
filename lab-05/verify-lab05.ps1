param([string]$RepoPath = (Get-Location).Path)
$ErrorActionPreference = 'Stop'
$lab05Repo = [IO.Path]::GetFullPath($RepoPath)
Set-Location -LiteralPath $lab05Repo
$lab05StrictUtf8 = [Text.UTF8Encoding]::new($false, $true)
$lab05Required = @(
    'compose-neo4j.yaml',
    'lab-05/README.md',
    'lab-05/rules.md',
    'lab-05/graph.cypher',
    'lab-05/queries.cypher',
    'lab-05/source-facts.sql',
    'lab-05/environment-ps.txt',
    'lab-05/environment-versions.txt',
    'lab-05/verify-lab05.ps1'
)
foreach ($lab05Relative in $lab05Required) {
    $lab05Path = Join-Path $lab05Repo $lab05Relative
    if (-not (Test-Path -LiteralPath $lab05Path -PathType Leaf)) { throw "Немає файлу: $lab05Relative" }
    $null = $lab05StrictUtf8.GetString([IO.File]::ReadAllBytes($lab05Path))
}
Write-Output 'OK: обов''язкові файли на місці та читаються як UTF-8.'

$lab05ReportPath = Join-Path $lab05Repo 'lab-05/README.md'
$lab05RulesPath = Join-Path $lab05Repo 'lab-05/rules.md'
$lab05Report = [IO.File]::ReadAllText($lab05ReportPath, $lab05StrictUtf8)
$lab05Rules = [IO.File]::ReadAllText($lab05RulesPath, $lab05StrictUtf8)
$lab05Sections = @([regex]::Matches($lab05Report, '(?m)^## (\d+)\.') | ForEach-Object { $_.Groups[1].Value })
if (($lab05Sections -join ',') -ne '1,2,3,4,5,6,7,8,9,11') { throw 'Порядок обов''язкових розділів неправильний.' }
if ($lab05Report -match '(?m)^\s*\.\.\.\s*$|Розділ буде заповнено|проміжний звіт|ще не підтверджені') { throw 'У звіті лишилася заглушка або проміжний статус.' }
foreach ($lab05Text in @($lab05Report, $lab05Rules)) {
    if (([regex]::Matches($lab05Text, '(?m)^```').Count % 2) -ne 0) { throw 'Не закрито блок коду.' }
    if ($lab05Text -match '(?m)[ \t]+\r?$') { throw 'Зайві пробіли наприкінці рядків.' }
}
if ([regex]::Matches($lab05Report, '(?m)^```mermaid\s*$').Count -ne 5) { throw 'Очікуються п''ять діаграм Mermaid.' }
Write-Output 'OK: 10 обов''язкових розділів, 5 діаграм, закриті блоки коду, немає заглушок.'

$lab05Hashes = @{
    'lab-05/rules.md' = '4ffbdd1016dad3f514a1e34c31626ea02d1eda63d72a99ba7ea744256f654cd3'
    'lab-05/graph.cypher' = 'ab786ad5ac0005bb78f2eef71aa0f723a4ba86c2b3da5c4d0f72cd01d555d990'
}
foreach ($lab05Relative in $lab05Hashes.Keys) {
    $lab05Text = [IO.File]::ReadAllText((Join-Path $lab05Repo $lab05Relative), $lab05StrictUtf8).Replace("`r`n", "`n")
    $lab05Sha = [Security.Cryptography.SHA256]::Create()
    try {
        $lab05ActualHash = [BitConverter]::ToString($lab05Sha.ComputeHash($lab05StrictUtf8.GetBytes($lab05Text))).Replace('-', '').ToLowerInvariant()
    } finally { $lab05Sha.Dispose() }
    if ($lab05ActualHash -ne $lab05Hashes[$lab05Relative]) { throw "Змінилася перевірена версія: $lab05Relative" }
}
$lab05RulesBlock = [regex]::Match($lab05Rules, '(?ms)^## 1\. Правила\r?\n(.*?)(?=^## 2\.)').Groups[1].Value
$lab05RuleNumbers = @([regex]::Matches($lab05RulesBlock, '(?m)^\| П(\d+) \|') | ForEach-Object { $_.Groups[1].Value })
if (($lab05RuleNumbers -join ',') -ne '1,2,3,4,5,6,7,8,9') { throw 'Очікуються дев''ять правил П1-П9.' }
$lab05Graph = [IO.File]::ReadAllText((Join-Path $lab05Repo 'lab-05/graph.cypher'), $lab05StrictUtf8)
$lab05GraphCode = ([regex]::Replace($lab05Graph, '(?m)^\s*//.*$', ''))
if ([regex]::Matches($lab05GraphCode, '(?m)^MERGE \(\w+:\w+\s*\{').Count -ne 11) { throw 'Не збіглася кількість шаблонів вершин.' }
if ([regex]::Matches($lab05GraphCode, '(?m)^MERGE \(\w+\)-\[:').Count -ne 11) { throw 'Не збіглася кількість шаблонів зв''язків.' }
if ($lab05GraphCode -match '\b(CREATE|DELETE|SET|REMOVE)\b') { throw 'У скрипті графа є неочікувана команда зміни.' }
Write-Output 'OK: база правил 1.0 і скрипт графа незмінні; 9 правил, 11 вершин і 11 зв''язків за скриптом.'

$lab05Queries = [IO.File]::ReadAllText((Join-Path $lab05Repo 'lab-05/queries.cypher'), $lab05StrictUtf8)
if ([regex]::Matches($lab05Queries, '(?m)^// Запит [123]\.').Count -ne 3) { throw 'У файлі має бути три пронумеровані запити.' }
if ([regex]::Matches($lab05Queries, '(?m)^// Фактичний результат:').Count -ne 3) { throw 'Бракує фактичних відповідей у коментарях.' }
$lab05QueryCode = [regex]::Replace($lab05Queries, '(?m)^\s*//.*$', '')
if ($lab05QueryCode -match '\b(CREATE|MERGE|DELETE|SET|REMOVE)\b') { throw 'Запити читання містять неочікувану команду зміни.' }
if ($lab05QueryCode -notmatch 'SIMILAR_TO\*1\.\.2' -or $lab05QueryCode -notmatch 'WHERE i\.unit_price >= 3000' -or $lab05QueryCode -notmatch 'WITH o, count\(i\) AS flacon_positions') { throw 'Не знайдено всі три потрібні типи запитів.' }
Write-Output 'OK: три запити читання з питаннями та фактичними відповідями.'

$lab05ImageNames = @(
    'neo4j-startup.png', 'neo4j-connection-empty.png',
    'source-order-facts.png', 'source-sample-facts.png',
    'graph-first-counts.png', 'graph-second-counts.png', 'graph-view.png',
    'query-1-relationship-condition.png', 'query-2-similarity-path.png', 'query-3-rule-condition.png'
)
foreach ($lab05Name in $lab05ImageNames) {
    $lab05Path = Join-Path $lab05Repo "lab-05/screenshots/$lab05Name"
    if (-not (Test-Path -LiteralPath $lab05Path -PathType Leaf)) { throw "Немає скриншота: $lab05Name" }
    $lab05Bytes = [IO.File]::ReadAllBytes($lab05Path)
    if ($lab05Bytes.Length -lt 8 -or [BitConverter]::ToString($lab05Bytes, 0, 8) -ne '89-50-4E-47-0D-0A-1A-0A') { throw "Некоректний PNG: $lab05Name" }
}
$lab05LinkCount = 0
foreach ($lab05MdPath in @($lab05ReportPath, $lab05RulesPath)) {
    $lab05Text = [IO.File]::ReadAllText($lab05MdPath, $lab05StrictUtf8)
    foreach ($lab05Link in [regex]::Matches($lab05Text, '!?\[[^\]]*\]\(([^)]+)\)')) {
        $lab05Target = $lab05Link.Groups[1].Value
        if ($lab05Target -match '^(https?://|#)') { continue }
        $lab05Resolved = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $lab05MdPath) $lab05Target))
        if (-not (Test-Path -LiteralPath $lab05Resolved)) { throw "Не працює локальне посилання: $lab05Target" }
        $lab05LinkCount++
    }
}
Write-Output "OK: 10 скриншотів і $lab05LinkCount локальних посилань перевірено."

& git diff --check -- lab-05 compose-neo4j.yaml
if ($LASTEXITCODE -ne 0) { throw 'Не пройдено git diff --check.' }
& git diff --cached --check -- lab-05 compose-neo4j.yaml
if ($LASTEXITCODE -ne 0) { throw 'Не пройдено git diff --cached --check.' }
$lab05Commits = @(& git log --format=%h -- lab-05/README.md compose-neo4j.yaml)
if ($LASTEXITCODE -ne 0 -or $lab05Commits.Count -lt 5) { throw 'Не знайдено щонайменше п''ять попередніх етапів перед фінальним комітом.' }
Write-Output "OK: перевірки Git пройдено; наявних комітів звіту: $($lab05Commits.Count)."
Write-Output 'Перевірку файлів завершено. Бази даних не змінювалися; експерименти повторно не запускалися.'
