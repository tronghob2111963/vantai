# PowerShell script to replace emerald colors with amber/yellow
# Run this in PTCMSS_FRONTEND directory

Write-Host "Replacing emerald colors with amber/yellow theme..." -ForegroundColor Yellow

$replacements = @(
    @{Old = "text-emerald-600"; New = "text-amber-600"},
    @{Old = "text-emerald-700"; New = "text-amber-700"},
    @{Old = "text-emerald-500"; New = "text-amber-500"},
    @{Old = "text-emerald-800"; New = "text-amber-800"},
    @{Old = "text-emerald-900"; New = "text-amber-900"},
    
    @{Old = "bg-emerald-50"; New = "bg-amber-50"},
    @{Old = "bg-emerald-100"; New = "bg-amber-100"},
    @{Old = "bg-emerald-600"; New = "bg-[#EDC531]"},
    @{Old = "bg-emerald-500"; New = "bg-[#EDC531]"},
    @{Old = "bg-emerald-700"; New = "bg-[#D4AF28]"},
    
    @{Old = "border-emerald-200"; New = "border-amber-200"},
    @{Old = "border-emerald-300"; New = "border-amber-300"},
    @{Old = "border-emerald-500"; New = "border-[#EDC531]"},
    @{Old = "border-emerald-600"; New = "border-[#EDC531]"},
    
    @{Old = "from-emerald-50"; New = "from-amber-50"},
    @{Old = "from-emerald-100"; New = "from-amber-100"},
    @{Old = "to-emerald-100"; New = "to-amber-100"},
    @{Old = "to-emerald-200"; New = "to-amber-200"},
    
    @{Old = "hover:bg-emerald-500"; New = "hover:bg-[#D4AF28]"},
    @{Old = "hover:bg-emerald-600"; New = "hover:bg-[#D4AF28]"}
)

$files = Get-ChildItem -Path "src/components" -Filter "*.jsx" -Recurse

$totalFiles = 0
$totalReplacements = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileReplacements = 0
    
    foreach ($replacement in $replacements) {
        if ($content -match [regex]::Escape($replacement.Old)) {
            $content = $content -replace [regex]::Escape($replacement.Old), $replacement.New
            $fileReplacements++
        }
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $totalFiles++
        $totalReplacements += $fileReplacements
        Write-Host "✅ Updated: $($file.Name) ($fileReplacements replacements)" -ForegroundColor Green
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "   Files updated: $totalFiles" -ForegroundColor White
Write-Host "   Total replacements: $totalReplacements" -ForegroundColor White
Write-Host "`nTheme change completed!" -ForegroundColor Green
