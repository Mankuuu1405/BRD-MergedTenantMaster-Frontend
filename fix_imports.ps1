$srcPath = "E:\TenantMaster\src"
$folders = "services|utils|hooks|assets|api|auth|context|layout|components|pages"

Get-ChildItem -Path $srcPath -Include "*.jsx", "*.js" -Recurse | ForEach-Object {
    $file = $_
    $rel = $file.FullName.Substring($srcPath.Length + 1)
    $depth = ($rel.ToCharArray() | Where-Object { $_ -eq "\" }).Count
    
    if ($depth -gt 0) {
        $prefix = "../" * $depth
        $content = [System.IO.File]::ReadAllText($file.FullName)
        
        # Remove MainLayout imports and wrappers
        $content = $content -replace 'import\s+MainLayout\s+from\s+["''][^"'' ]+["'']\s*;?\r?\n?', ""
        $content = $content -replace '<MainLayout\s*>', "<>"
        $content = $content -replace '</MainLayout>', "</>"
        
        # Fix relative imports to top-level folders
        $regex = [regex]"from\s+(['\"])\.*/*($folders)/"
        $content = $regex.Replace($content, "from `${1}${prefix}${2}/")
        
        [System.IO.File]::WriteAllText($file.FullName, $content)
        Write-Host "Fixed: $rel (Depth: $depth)"
    }
}
