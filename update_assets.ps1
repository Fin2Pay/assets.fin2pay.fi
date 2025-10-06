# --- Fin2Pay Assets Auto-Updater (Safe PS Version) ---
$baseDir = "D:\Fin2Pay_Assets"
$domain  = "https://assets.fin2pay.fi"

Set-Location $baseDir

# --- Helper: Generate index for each folder ---
function Generate-Index($folder) {
    $files = Get-ChildItem -Path $folder -File | Where-Object { $_.Name -ne "index.html" }
    $htmlPath = Join-Path $folder "index.html"
    $folderName = Split-Path $folder -Leaf

    $links = ""
    foreach ($f in $files) {
        $links += "<li><a href='$($f.Name)' target='_blank'>$($f.Name)</a></li>`n"
    }

    $parent = Split-Path $folder -Parent
    $backLink = ""
    if ($parent -ne $baseDir) {
        $backLink = "<li><a href='../'>Back to Home</a></li>"
    }

    $html = @"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <title>$folderName - Fin2Pay Assets</title>
  <style>
    body { font-family: Segoe UI, sans-serif; background:#f8f9fb; padding:30px; }
    h1 { color:#002855; }
    ul { line-height:2; list-style:none; padding:0; }
    a { color:#004aad; text-decoration:none; }
    a:hover { text-decoration:underline; }
  </style>
</head>
<body>
  <h1>$folderName</h1>
  <ul>
  $links
  $backLink
  </ul>
</body>
</html>
"@
    $html | Out-File -FilePath $htmlPath -Encoding UTF8
}

# --- Helper: Generate main index ---
function Generate-MainIndex {
    $dirs = Get-ChildItem -Path $baseDir -Directory
    $cards = ""
    foreach ($d in $dirs) {
        $title = switch -Regex ($d.Name.ToLower()) {
            "logo" { "Logos" }
            "ip" { "IP & R&D Notes" }
            "letterhead" { "Letterhead" }
            "letters" { "Letters & Confirmations" }
            "visit" { "Visit Card" }
            default { $d.Name }
        }
        $cards += "<a href='$($d.Name)/index.html' class='card'>$title</a>`n"
    }

    $mainHtml = @"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <title>Fin2Pay Assets Portal</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      background: #f8f9fb url('$domain/LOGO.jpg') no-repeat center center fixed;
      background-size: 400px;
      text-align: center;
    }
    header { background: rgba(255,255,255,0.85); box-shadow:0 2px 8px rgba(0,0,0,0.1); padding:30px; }
    h1 { color:#002855; }
    .grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:20px; padding:40px; max-width:900px; margin:0 auto; }
    .card {
      background: rgba(255,255,255,0.85);
      border-radius:16px;
      padding:25px;
      text-decoration:none;
      color:#002855;
      box-shadow:0 4px 10px rgba(0,0,0,0.05);
      transition:transform .2s, box-shadow .2s;
    }
    .card:hover { transform:translateY(-4px); box-shadow:0 6px 15px rgba(0,0,0,0.1); }
  </style>
</head>
<body>
  <header>
    <h1>Fin2Pay Assets Portal</h1>
    <p>Access organized brand and project materials securely</p>
  </header>

  <section class='grid'>
    $cards
  </section>

  <footer style='padding:20px;color:#666;'>© 2025 Fin2Pay — All rights reserved.</footer>
</body>
</html>
"@

    $mainHtml | Out-File -FilePath "$baseDir\index.html" -Encoding UTF8
}

Write-Host "🔄 Generating indexes..."
# Build all subfolder indexes
$folders = Get-ChildItem -Path $baseDir -Directory
foreach ($f in $folders) { Generate-Index $f.FullName }

# Build main index
Generate-MainIndex

Write-Host "✅ HTML indexes generated."

# Git sync and deploy
git add .
git commit -m "auto update assets $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git pull --rebase
git push

Write-Host "🚀 Deployment complete. Check https://assets.fin2pay.fi"
