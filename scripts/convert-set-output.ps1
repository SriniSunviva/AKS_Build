param(
    [switch]$Apply,
    [switch]$IncludeIgnored
)

function Show-Usage {
    Write-Host "Usage: .\convert-set-output.ps1 [-Apply] [-IncludeIgnored]"
    exit 1
}

if ($PSBoundParameters.ContainsKey('Help')) { Show-Usage }

# Use git grep if available for reliable searching
try {
    if ($IncludeIgnored) {
        $files = & git grep -l --no-color "::set-output" 2>$null
    } else {
        $files = & git grep -l --no-color "::set-output" 2>$null
    }
} catch {
    $files = @()
}

if (-not $files -or $files.Count -eq 0) {
    Write-Host "No files using ::set-output found."
    exit 0
}

Write-Host "Found ::set-output in these files:" -ForegroundColor Cyan
$files | ForEach-Object { Write-Host " - $_" }

foreach ($f in $files) {
    Write-Host "Processing $f" -ForegroundColor Yellow
    if (-not $Apply) {
        Select-String -Path $f -Pattern '::set-output' -SimpleMatch | ForEach-Object { $_.Line }
        Write-Host "Dry run: no changes made. To apply, re-run with -Apply.`n"
        continue
    }

    Copy-Item -Path $f -Destination "$f.bak" -Force
    $content = Get-Content -Raw -Path $f -ErrorAction Stop

    # Replace inline ::set-output occurrences used in shell steps
    # Replace PowerShell Write-Host style usages
        # Replace any ::set-output occurrences with the environment-file style
        $content = $content -replace '::set-output name=([^:]+)::([^\r\n]+)', 'echo "$1=$2" >> $GITHUB_OUTPUT'

    Set-Content -Path $f -Value $content -Force
    Write-Host "Updated $f (backup at $f.bak)" -ForegroundColor Green
}

Write-Host "Done."
