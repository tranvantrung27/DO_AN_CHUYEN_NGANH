# Script để thay thế tất cả print() bằng debugPrint() và thêm import
# Chạy: .\fix_all_prints.ps1

$files = Get-ChildItem -Path lib -Recurse -Filter "*.dart" | Where-Object { 
    $_.FullName -notmatch "\\build\\" -and 
    (Get-Content $_.FullName -Raw) -match 'print\(' 
}

$fixedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    if ($content -match 'print\(') {
        # Thay print( bằng debugPrint(
        $content = $content -replace 'print\(', 'debugPrint('
        
        # Kiểm tra và thêm import nếu chưa có
        if ($content -notmatch "import.*foundation\.dart") {
            # Tìm dòng import đầu tiên
            if ($content -match "(import\s+[^;]+;)") {
                # Thêm import sau dòng import đầu tiên
                $firstImport = [regex]::Match($content, "(import\s+[^;]+;)")
                $content = $content.Insert($firstImport.Index + $firstImport.Length, "`nimport 'package:flutter/foundation.dart' show debugPrint;")
            } else {
                # Nếu không có import nào, thêm ở đầu file
                $content = "import 'package:flutter/foundation.dart' show debugPrint;`n" + $content
            }
        } else {
            # Nếu đã có import foundation, thêm debugPrint vào show clause
            if ($content -match "import\s+['\"]package:flutter/foundation\.dart['\"]\s+show\s+([^;]+);") {
                $existingImports = $matches[1]
                if ($existingImports -notmatch "debugPrint") {
                    $content = $content -replace "(import\s+['\"]package:flutter/foundation\.dart['\"]\s+show\s+)([^;]+)(;)", "`$1`$2, debugPrint;"
                }
            } elseif ($content -match "import\s+['\"]package:flutter/foundation\.dart['\"];") {
                # Chỉ có import không có show
                $content = $content -replace "(import\s+['\"]package:flutter/foundation\.dart['\"]);", "import 'package:flutter/foundation.dart' show debugPrint;"
            }
        }
        
        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
            Write-Host "Fixed: $($file.Name)"
            $fixedCount++
        }
    }
}

Write-Host "`nDone! Fixed $fixedCount files."
