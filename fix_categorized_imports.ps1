$srcPath = "E:\TenantMaster\src"

# Master Files
$masterPaths = @("$srcPath\pages\master", "$srcPath\components\master")
foreach ($path in $masterPaths) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Recurse | Where-Object { $_.Extension -eq ".jsx" -or $_.Extension -eq ".js" }
        foreach ($file in $files) {
            $content = [System.IO.File]::ReadAllText($file.FullName)
            $newContent = $content -replace "from\s+(['""])([\.\./]+)components/(?!master/|tenant/)", "from `$1`$2components/master/"
            $newContent = $newContent -replace "from\s+(['""])([\.\./]+)pages/(?!master/|tenant/)", "from `$1`$2pages/master/"
            if ($content -ne $newContent) {
                [System.IO.File]::WriteAllText($file.FullName, $newContent)
                Write-Host "Fixed Master: $($file.FullName)"
            }
        }
    }
}

# Tenant Files
$tenantPaths = @("$srcPath\pages\tenant", "$srcPath\components\tenant")
foreach ($path in $tenantPaths) {
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Recurse | Where-Object { $_.Extension -eq ".jsx" -or $_.Extension -eq ".js" }
        foreach ($file in $files) {
            $content = [System.IO.File]::ReadAllText($file.FullName)
            $newContent = $content -replace "from\s+(['""])([\.\./]+)components/(?!master/|tenant/)", "from `$1`$2components/tenant/"
            $newContent = $newContent -replace "from\s+(['""])([\.\./]+)pages/(?!master/|tenant/)", "from `$1`$2pages/tenant/"
            if ($content -ne $newContent) {
                [System.IO.File]::WriteAllText($file.FullName, $newContent)
                Write-Host "Fixed Tenant: $($file.FullName)"
            }
        }
    }
}
Write-Host "Done."
