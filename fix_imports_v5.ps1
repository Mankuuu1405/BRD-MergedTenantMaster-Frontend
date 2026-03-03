$srcPath = "E:\TenantMaster\src"
$folders = "services|utils|hooks|assets|api|auth|context|layout|components|pages"

# Get all files recursively
$files = Get-ChildItem -Path $srcPath -Recurse | Where-Object { $_.Extension -eq ".jsx" -or $_.Extension -eq ".js" }

Write-Host "Found $($files.Count) files. Starting processing..."

$fixedCount = 0

foreach ($file in $files) {
    try {
        $rel = $file.FullName.Substring($srcPath.Length + 1)
        $depth = ($rel.ToCharArray() | Where-Object { $_ -eq "\" }).Count
        
        if ($depth -gt 0) {
            $prefix = "../" * $depth
            $content = [System.IO.File]::ReadAllText($file.FullName)
            $originalContent = $content
            
            # 1. Remove MainLayout if present
            if ($content -match 'import\s+MainLayout') {
               $content = $content -replace 'import\s+MainLayout\s+from\s+["''][^"'' ]+["'']\s*;?\r?\n?', ""
               $content = $content -replace '<MainLayout[^>]*>', "<React.Fragment>"
               $content = $content -replace '</MainLayout>', "</React.Fragment>"
               if ($content -notmatch 'import\s+React' -and $content -match '<React\.Fragment>') {
                   $content = "import React from 'react';`n" + $content
               }
            }
            
            # 2. Fix imports to top-level folders
            # The regex matches: from followed by space, then quote, then any combo of . and /, then one of the folders
            $pattern = "from\s+(['""])([\.\./]+)($folders)/"
            $replacement = "from `$1$prefix`$3/"
            
            $content = [regex]::Replace($content, $pattern, $replacement)
            
            if ($content -ne $originalContent) {
                [System.IO.File]::WriteAllText($file.FullName, $content)
                $fixedCount++
                if ($fixedCount -le 20) {
                    Write-Host "FIXED: $rel (Depth: $depth)"
                }
            }
        }
    } catch {
        Write-Warning "Error processing $($file.FullName): $($_.Exception.Message)"
    }
}
Write-Host "Completed. Total fixed: $fixedCount"
