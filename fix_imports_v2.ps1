$srcPath = "E:\TenantMaster\src"
$folders = "services|utils|hooks|assets|api|auth|context|layout|components|pages"

$files = Get-ChildItem -Path $srcPath -Include "*.jsx", "*.js" -Recurse
foreach ($file in $files) {
    $rel = $file.FullName.Substring($srcPath.Length + 1)
    $depth = ($rel.ToCharArray() | Where-Object { $_ -eq "\" }).Count
    
    if ($depth -gt 0) {
        $prefix = "../" * $depth
        $content = [System.IO.File]::ReadAllText($file.FullName)
        
        # Remove MainLayout
        # Use simpler string replacements where possible or very specific regex
        $content = $content -replace 'import\s+MainLayout\s+from\s+["''][^"'' ]+["'']\s*;?\r?\n?', ""
        
        # Handle cases with props or variations
        $content = $content -replace '<MainLayout[^>]*>', "<>"
        $content = $content -replace '</MainLayout>', "</>"
        
        # Fix imports using the calculated prefix
        $pattern = 'from\s+([''"])\.*/*(' + $folders + ')/'
        # In the replacement string, we need to be careful with capture group notation
        # ${1} and ${2} refer to the groups
        $replacement = 'from $1' + $prefix + '$2/'
        
        $content = [regex]::Replace($content, $pattern, $replacement)
        
        [System.IO.File]::WriteAllText($file.FullName, $content)
    }
}
Write-Host "Import fix completed."
