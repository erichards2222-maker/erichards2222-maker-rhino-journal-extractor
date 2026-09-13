param([string]$Journal)

# RHINO JOURNAL EXTRACTOR
# - Reads only the journal you choose.
# - Keeps only Rhino-relevant event types.
# - Keeps all SendText so survey tags, corrections, and notes are preserved.
# - Keeps only the screenshot filename, never its local folder path.
# - Makes NO network calls.

if (-not $Journal) {
    $recent = @(Get-ChildItem -File "Journal.*.log" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 10)

    if ($recent.Count -eq 0) {
        Write-Host "No Journal.*.log files found in this folder."
        exit
    }

    Write-Host ""
    Write-Host "Choose a journal:"
    for ($i = 0; $i -lt $recent.Count; $i++) {
        Write-Host ("{0,2}  {1}" -f ($i + 1), $recent[$i].Name)
    }

    do {
        $pick = Read-Host "Enter number 1-$($recent.Count)"
        $n = 0
        $valid = [int]::TryParse($pick, [ref]$n) -and $n -ge 1 -and $n -le $recent.Count
    } until ($valid)

    $Journal = $recent[$n - 1].FullName
}
else {
    $Journal = (Resolve-Path -LiteralPath $Journal).Path
}

$keep = @(
    "Fileheader","Location","FSDJump","ApproachBody","SupercruiseExit",
    "SAAScanComplete","SAASignalsFound","Scan",
    "LaunchSRV","DockSRV","Touchdown","Liftoff",
    "Screenshot","SendText","Cargo","MiningRefined","MaterialCollected"
)

$tag = [IO.Path]::GetFileNameWithoutExtension($Journal) -replace '^Journal\.', ''
$out = Join-Path (Get-Location) "Rhino_Survey_Extract_$tag.jsonl"

Remove-Item -LiteralPath $out -ErrorAction SilentlyContinue
$total = 0
$kept = 0
$lineNo = 0

Get-Content -LiteralPath $Journal | ForEach-Object {
    $lineNo++
    $total++

    try { $e = $_ | ConvertFrom-Json } catch { return }

    if ($e.event -in $keep) {
        if ($e.event -eq "Screenshot" -and $e.Filename) {
            $e.Filename = [IO.Path]::GetFileName($e.Filename)
        }

        $e | Add-Member -NotePropertyName "_source_file" -NotePropertyValue ([IO.Path]::GetFileName($Journal))
        $e | Add-Member -NotePropertyName "_source_line" -NotePropertyValue $lineNo

        $e | ConvertTo-Json -Compress -Depth 20 |
            Add-Content -LiteralPath $out -Encoding UTF8

        $kept++
    }
}

Write-Host ""
Write-Host "Created: $out"
Write-Host "Kept $kept of $total journal events."
Write-Host "No network calls were used."
