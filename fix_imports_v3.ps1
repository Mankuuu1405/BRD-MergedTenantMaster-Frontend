$srcPath = "E:\TenantMaster\src"
$folders = "services|utils|hooks|assets|api|auth|context|layout|components|pages"

$files = Get-ChildItem -Path $srcPath -Include "*.jsx", "*.js" -Recurse
foreach ($file in $files) {
    try {
        $rel = $file.FullName.Substring($srcPath.Length + 1)
        $depth = ($rel.ToCharArray() | Where-Object { $_ -eq "\" }).Count
        
        if ($depth -gt 0) {
            $prefix = "../" * $depth
            $content = [System.IO.File]::ReadAllText($file.FullName)
            $originalContent = $content
            
            # 1. Remove MainLayout if present
            $content = $content -replace 'import\s+MainLayout\s+from\s+["''][^"'' ]+["'']\s*;?\r?\n?', ""
            $content = $content -replace '<MainLayout[^>]*>', "<>"
            $content = $content -replace '</MainLayout>', "</>"
            
            # 2. Fix imports
            # We want to match: from "../services/" or from "../../utils/" or from "./services/"
            # and replace with from "../../../services/" (depending on depth)
            
            # Using a simplified match to avoid regex escaping headaches in PS strings
            $pattern = "from\s+(['""])\.*/*($folders)/"
            $replacement = "from `$1$prefix`$2/"
            
            $content = [regex]::Replace($content, $pattern, $replacement)
            
            if ($content -ne $originalContent) {
                [System.IO.File]::WriteAllText($file.FullName, $content)
                Write-Host "FIXED: $rel (Depth: $depth)"
            }
        }
    } catch {
        Write-Warning "Failed to process $($file.FullName): $($_.Exception.Message)"
    }
}
Write-Host "Done."
