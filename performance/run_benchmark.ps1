param(
    [ValidateRange(1, 1000000000)]
    [int]$Iterations = 5000000
)

$ErrorActionPreference = 'Stop'
$benchmarkDirectory = $PSScriptRoot
$projectDirectory = Split-Path -Parent $benchmarkDirectory
$buildDirectory = Join-Path $benchmarkDirectory 'build'
$haskellBuild = Join-Path $buildDirectory 'haskell'
$javaBuild = Join-Path $buildDirectory 'java'
$haskellExecutable = Join-Path $haskellBuild 'haskell-benchmark.exe'

New-Item -ItemType Directory -Force -Path $haskellBuild, $javaBuild | Out-Null

Write-Host 'Compiling Haskell benchmark with -O2...'
& ghc -O2 -Wall `
    -i"$projectDirectory" `
    -outputdir "$haskellBuild" `
    -o "$haskellExecutable" `
    (Join-Path $benchmarkDirectory 'HaskellBenchmark.hs') `
    (Join-Path $projectDirectory 'Expr.hs')
if ($LASTEXITCODE -ne 0) { throw 'GHC compilation failed.' }

Write-Host 'Compiling Java benchmark...'
& javac -d "$javaBuild" (Join-Path $benchmarkDirectory 'ImperativeBenchmark.java')
if ($LASTEXITCODE -ne 0) { throw 'Java compilation failed.' }

Write-Host "`nRunning $Iterations evaluations in each implementation..."
$haskellOutput = & $haskellExecutable $Iterations
if ($LASTEXITCODE -ne 0) { throw 'Haskell benchmark failed.' }
$javaOutput = & java -cp "$javaBuild" ImperativeBenchmark $Iterations
if ($LASTEXITCODE -ne 0) { throw 'Java benchmark failed.' }

Write-Host "`n--- Haskell ---"
$haskellOutput | Where-Object { $_ -notmatch '^(TIME_SECONDS|CHECKSUM)=' }
Write-Host "`n--- Imperative Java ---"
$javaOutput | Where-Object { $_ -notmatch '^(TIME_SECONDS|CHECKSUM)=' }

$haskellTime = [double](($haskellOutput | Where-Object { $_ -match '^TIME_SECONDS=' }) -replace '^TIME_SECONDS=', '')
$javaTime = [double](($javaOutput | Where-Object { $_ -match '^TIME_SECONDS=' }) -replace '^TIME_SECONDS=', '')
$haskellChecksum = [double](($haskellOutput | Where-Object { $_ -match '^CHECKSUM=' }) -replace '^CHECKSUM=', '')
$javaChecksum = [double](($javaOutput | Where-Object { $_ -match '^CHECKSUM=' }) -replace '^CHECKSUM=', '')

if ([math]::Abs($haskellChecksum - $javaChecksum) -gt 0.000001) {
    throw "Checksums differ: Haskell=$haskellChecksum, Java=$javaChecksum"
}

$fasterName = if ($haskellTime -le $javaTime) { 'Haskell' } else { 'Imperative Java' }
$slowerTime = [math]::Max($haskellTime, $javaTime)
$fasterTime = [math]::Min($haskellTime, $javaTime)
$ratio = $slowerTime / $fasterTime

Write-Host "`n--- Comparison ---"
Write-Host 'Checksums match: both implementations calculated the same results.'
Write-Host ("Faster in this run: {0} ({1:N2}x)" -f $fasterName, $ratio)
Write-Host 'Run the benchmark several times and report a range or median, not one result.'
