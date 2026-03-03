$srcPath = "E:\TenantMaster\src"

$files = Get-ChildItem -Path $srcPath -Recurse | Where-Object { $_.Extension -eq ".jsx" -or $_.Extension -eq ".js" }
$brokenCount = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    # Match relative imports
    $matches = [regex]::Matches($content, 'from\s+([''"])([\./][^''"]+)([''"])')
    foreach ($match in $matches) {
        $importPath = $match.Groups[2].Value
        if ($importPath.StartsWith(".")) {
            # It's a relative path
            $dir = [System.IO.Path]::GetDirectoryName($file.FullName)
            $targetPath = [System.IO.Path]::Combine($dir, $importPath)
            
            # Check for common extensions if not provided
            $found = $false
            $extensions = @("", ".jsx", ".js", "/index.jsx", "/index.js", ".css", ".png", ".jpg", ".svg")
            foreach ($ext in $extensions) {
                if (Test-Path ($targetPath + $ext)) {
                    $found = $true
                    break
                }
            }
            
            if (-not $found) {
                Write-Host "BROKEN: $($file.FullName) -> $importPath"
                $brokenCount++
            }
        }
    }
}

Write-Host "Total broken relative imports: $brokenCount"
