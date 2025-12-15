# Script để thay thế print() bằng debugPrint() trong tất cả files
# Chạy: .\fix_prints.ps1

$files = Get-ChildItem -Path lib -Recurse -Filter "*.dart" | Where-Object { $_.FullName -notmatch "\\build\\" }

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Thay print( bằng debugPrint(
    $content = $content -replace '\bprint\(', 'debugPrint('
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "Done! Don't forget to add: import 'package:flutter/foundation.dart' show debugPrint;"

