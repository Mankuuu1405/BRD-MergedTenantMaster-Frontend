$srcPath = "E:\TenantMaster\src"
$folders = "services|utils|hooks|assets|api|auth|context|layout|components|pages"

# Get all files recursively
$files = Get-ChildItem -Path $srcPath -Recurse | Where-Object { $_.Extension -eq ".jsx" -or $_.Extension -eq ".js" }

Write-Host "Found $($files.Count) files. Starting processing..."

foreach ($file in $files) {
    try {
        $rel = $file.FullName.Substring($srcPath.Length + 1)
        # Count directory separators to determine depth
        $depth = ($rel.ToCharArray() | Where-Object { $_ -eq "\" }).Count
        
        if ($depth -gt 0) {
            $prefix = "../" * $depth
            $content = [System.IO.File]::ReadAllText($file.FullName)
            $originalContent = $content
            
            # 1. Remove MainLayout if present (now global in App.jsx)
            if ($content -match 'import\s+MainLayout') {
               $content = $content -replace 'import\s+MainLayout\s+from\s+["''][^"'' ]+["'']\s*;?\r?\n?', ""
               $content = $content -replace '<MainLayout[^>]*>', "<React.Fragment>"
               $content = $content -replace '</MainLayout>', "</React.Fragment>"
               # Ensure React is imported if we add Fragment
               if ($content -notmatch 'import\s+React' -and $content -match '<React\.Fragment>') {
                   $content = "import React from 'react';`n" + $content
               }
            }
            
            # 2. Fix imports to top-level folders
            # Match any import that looks like it's trying to reach services/utils/etc. via relative paths
            # We target "from '../services/" or "from '../../utils/" etc.
            $pattern = "from\s+(['""])\.*/*($folders)/"
            $replacement = "from `$1$prefix`$2/"
            
            $content = [regex]::Replace($content, $pattern, $replacement)
            
            if ($content -ne $originalContent) {
                [System.IO.File]::WriteAllText($file.FullName, $content)
                Write-Host "FIXED: $rel (Depth: $depth)"
            }
        }
    } catch {
        Write-Warning "Error processing $($file.FullName): $($_.Exception.Message)"
    }
}
Write-Host "Completed."
