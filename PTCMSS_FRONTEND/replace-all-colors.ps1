# PowerShell script to replace ALL emerald colors with amber/yellow
# This will process all .jsx files in src/components

Write-Host "Starting color replacement..." -ForegroundColor Yellow

$componentsPath = "src/components"
$files = Get-ChildItem -Path $componentsPath -Filter "*.jsx" -Recurse -File

$totalFiles = 0
$totalReplacements = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $changed = $false
    
    # Replace all emerald variants
    $content = $content -replace 'text-emerald-600', 'text-amber-600'
    $content = $content -replace 'text-emerald-700', 'text-amber-700'
    $content = $content -replace 'text-emerald-500', 'text-amber-500'
    $content = $content -replace 'text-emerald-800', 'text-amber-800'
    $content = $content -replace 'text-emerald-900', 'text-amber-900'
    $content = $content -replace 'text-emerald-400', 'text-amber-400'
    $content = $content -replace 'text-emerald-300', 'text-amber-300'
    
    $content = $content -replace 'bg-emerald-50', 'bg-amber-50'
    $content = $content -replace 'bg-emerald-100', 'bg-amber-100'
    $content = $content -replace 'bg-emerald-600', 'bg-[#EDC531]'
    $content = $content -replace 'bg-emerald-500', 'bg-[#EDC531]'
    $content = $content -replace 'bg-emerald-700', 'bg-[#D4AF28]'
    $content = $content -replace 'bg-emerald-400', 'bg-amber-400'
    $content = $content -replace 'bg-emerald-200', 'bg-amber-200'
    
    $content = $content -replace 'border-emerald-200', 'border-amber-200'
    $content = $content -replace 'border-emerald-300', 'border-amber-300'
    $content = $content -replace 'border-emerald-500', 'border-[#EDC531]'
    $content = $content -replace 'border-emerald-600', 'border-[#EDC531]'
    $content = $content -replace 'border-emerald-400', 'border-amber-400'
    
    $content = $content -replace 'from-emerald-50', 'from-amber-50'
    $content = $content -replace 'from-emerald-100', 'from-amber-100'
    $content = $content -replace 'from-emerald-600', 'from-[#EDC531]'
    $content = $content -replace 'to-emerald-100', 'to-amber-100'
    $content = $content -replace 'to-emerald-200', 'to-amber-200'
    $content = $content -replace 'to-emerald-50', 'to-amber-50'
    
    $content = $content -replace 'hover:bg-emerald-500', 'hover:bg-[#D4AF28]'
    $content = $content -replace 'hover:bg-emerald-600', 'hover:bg-[#D4AF28]'
    $content = $content -replace 'hover:bg-emerald-700', 'hover:bg-[#B8941F]'
    
    $content = $content -replace 'ring-emerald-500', 'ring-amber-500'
    $content = $content -replace 'focus:ring-emerald-500', 'focus:ring-amber-500'
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        $totalFiles++
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "Updated: $relativePath" -ForegroundColor Green
        $changed = $true
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "Files updated: $totalFiles" -ForegroundColor White
Write-Host "`nColor replacement completed!" -ForegroundColor Green
