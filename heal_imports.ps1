$srcPath = "E:\TenantMaster\src"

function Resolve-ImportPath {
    param($File, $ImportPath)
    $dir = Split-Path -Parent $File
    $target = [System.IO.Path]::Combine($dir, $ImportPath)
    
    # Extensions to check
    $exts = @("", ".jsx", ".js", "/index.jsx", "/index.js", ".css", ".png", ".jpg", ".svg")
    foreach($ext in $exts) {
        if (Test-Path ($target + $ext)) {
            return $true
        }
    }
    return $false
}

$files = Get-ChildItem -Path $srcPath -Recurse | Where-Object { $_.Extension -eq ".jsx" -or $_.Extension -eq ".js" }
$fixedCount = 0

foreach ($file in $files) {
    if ($file.FullName -match "node_modules") { continue }
    
    $content = [System.IO.File]::ReadAllText($file.FullName)
    $changed = $false
    
    # Regex to find relative imports pointing to components/ or pages/
    # Group 1: prefix (import/from etc)
    # Group 2: quote char
    # Group 3: relative dots
    # Group 4: directory (components/pages)
    # Group 5: the rest of the path
    $regex = '(?<prefix>from\s+|import\s+)(?<quote>[''"])(?<dots>\.\./+)(?<dir>components|pages)/(?!(?:master|tenant)/)(?<rest>[^''"]+)(?<endQuote>[''"])'
    
    $matches = [regex]::Matches($content, $regex)
    foreach ($match in $matches) {
        $oldPath = $match.Groups['dots'].Value + $match.Groups['dir'].Value + "/" + $match.Groups['rest'].Value
        
        # Check if the old path is valid
        if (-not (Resolve-ImportPath -File $file.FullName -ImportPath $oldPath)) {
            # Try master/
            $newPathMaster = $match.Groups['dots'].Value + $match.Groups['dir'].Value + "/master/" + $match.Groups['rest'].Value
            if (Resolve-ImportPath -File $file.FullName -ImportPath $newPathMaster) {
                Write-Host "Fixing (master): $($file.FullName) : $oldPath -> $newPathMaster"
                $content = $content.Replace($oldPath, $newPathMaster)
                $changed = $true
                $fixedCount++
                continue
            }
            
            # Try tenant/
            $newPathTenant = $match.Groups['dots'].Value + $match.Groups['dir'].Value + "/tenant/" + $match.Groups['rest'].Value
            if (Resolve-ImportPath -File $file.FullName -ImportPath $newPathTenant) {
                Write-Host "Fixing (tenant): $($file.FullName) : $oldPath -> $newPathTenant"
                $content = $content.Replace($oldPath, $newPathTenant)
                $changed = $true
                $fixedCount++
                continue
            }
        }
    }
    
    if ($changed) {
        [System.IO.File]::WriteAllText($file.FullName, $content)
    }
}

Write-Host "Done. Fixed $fixedCount imports."
