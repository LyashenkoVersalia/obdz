# Перевірка комплектності лабораторної роботи №4.
# Виконувати з кореня репозиторію. Команди лише читають файли та стан Git.
& {
    $ErrorActionPreference = 'Stop'
    $lab04Root = (Get-Location).Path
    $lab04Folder = Join-Path $lab04Root 'lab-04'
    $lab04Required = @(
        'compose-nosql.yaml',
        'lab-04/README.md',
        'lab-04/load-documents.js',
        'lab-04/operations.js',
        'lab-04/repeat-write.js',
        'lab-04/aggregate.js',
        'lab-04/aggregate-check.sql',
        'lab-04/schema-on-read.js',
        'lab-04/redis-commands.txt',
        'lab-04/cache-source.sql',
        'lab-04/source-check.sql',
        'lab-04/verify-lab04.ps1'
    )
    foreach ($lab04Relative in $lab04Required) {
        $lab04Path = Join-Path $lab04Root $lab04Relative
        if (-not (Test-Path -LiteralPath $lab04Path -PathType Leaf)) {
            throw "Відсутній файл: $lab04Relative"
        }
        $lab04StrictUtf8 = [Text.UTF8Encoding]::new($false, $true)
        $null = $lab04StrictUtf8.GetString([IO.File]::ReadAllBytes($lab04Path))
    }
    Write-Output "OK: обов'язкові та додаткові файли на місці, кодування UTF-8."

    $lab04Readme = [IO.File]::ReadAllText((Join-Path $lab04Folder 'README.md'))
    $lab04Numbers = @(
        [regex]::Matches($lab04Readme, '(?m)^## (\d+)\. ') |
        ForEach-Object { [int]$_.Groups[1].Value }
    )
    if (($lab04Numbers -join ',') -ne '1,2,3,4,5,6,7,8,9,10,11,12') {
        throw 'Порушено послідовність 12 розділів README.'
    }
    if ([regex]::IsMatch($lab04Readme, '(?m)^\s*\.\.\.\s*$|\|\s*\.\.\.\s*\|')) {
        throw 'У README залишився окремий заповнювач шаблону.'
    }
    if (([regex]::Matches($lab04Readme, '(?m)^```').Count % 2) -ne 0) {
        throw 'У README є незакритий блок коду.'
    }
    if ([regex]::IsMatch($lab04Readme, '(?m)[ \t]+\r?$')) {
        throw 'У README є пробіли наприкінці рядків.'
    }
    Write-Output 'OK: 12 розділів, немає окремих заповнювачів, блоки коду закриті.'

    $lab04LinkCount = 0
    foreach ($lab04Link in [regex]::Matches($lab04Readme, '!?\[[^\]]*\]\(([^)]+)\)')) {
        $lab04Target = $lab04Link.Groups[1].Value
        if ($lab04Target -match '^(https?://|#)') { continue }
        $lab04Target = ($lab04Target -split '#', 2)[0]
        if (-not (Test-Path -LiteralPath (Join-Path $lab04Folder $lab04Target) -PathType Leaf)) {
            throw "Посилання веде на відсутній файл: $lab04Target"
        }
        $lab04LinkCount++
    }
    Write-Output "OK: перевірено локальні посилання та зображення: $lab04LinkCount."

    git diff --check -- lab-04 compose-nosql.yaml
    if ($LASTEXITCODE -ne 0) { throw 'git diff --check знайшов помилки.' }
    git diff --cached --check -- lab-04 compose-nosql.yaml
    if ($LASTEXITCODE -ne 0) { throw 'git diff --cached --check знайшов помилки.' }
    Write-Output 'OK: перевірки Git пройдено.'
    Write-Output 'Перевірку файлів завершено. Цей скрипт не запускає досліди баз даних повторно.'
}
