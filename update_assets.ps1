# ============================
#  Fin2Pay Assets Auto Builder
# ============================

$baseDir = "D:\Fin2Pay_Assets"
$logoPath = "https://assets.fin2pay.fi/LOGO.jpg"

# Helper function: escape HTML
function Escape-HTML {
    param([string]$Text)
    return $Text -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;'
}

# Generate folder index.html
function Generate-FolderIndex {
    param([string]$folderPath)
    $folderName = Split-Path $folderPath -Leaf
    $files = Get-ChildItem -Path $folderPath -File | Sort-Object Name

    $fileCount = $files.Count
    $fileLinks = ""
    $i = 1
    foreach ($f in $files) {
        $fileName = Escape-HTML $f.Name
        $fileLinks += "<li><a href='$fileName'>$i - $fileName</a></li>`n"
        $i++
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$folderName - Fin2Pay Assets</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      background: #f8f9fb url('$logoPath') no-repeat center center fixed;
      background-size: 700px;
      opacity: 0.97;
      text-align: center;
      color: #0b2c52;
      margin: 0;
      padding: 0;
    }
    h1 {
      margin-top: 100px;
      font-size: 2.2em;
      font-weight: 700;
    }
    ul {
      list-style: none;
      padding: 0;
      font-size: 1.1em;
      line-height: 1.8em;
    }
    a {
      color: #0046a6;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    footer {
      position: fixed;
      bottom: 20px;
      width: 100%;
      text-align: center;
      color: #666;
      font-size: 0.9em;
    }
  </style>
</head>
<body>
  <h1>${folderName} Folder</h1>
  <p>Total Files: $fileCount</p>
  <ul>
  $fileLinks
  </ul>
  <footer>© 2025 Fin2Pay — All rights reserved.</footer>
</body>
</html>
"@

    $html | Out-File -FilePath (Join-Path $folderPath "index.html") -Encoding utf8
}

# Generate main index.html
function Generate-MainIndex {
    $dirs = Get-ChildItem -Path $baseDir -Directory | Sort-Object Name

    $cards = ""
    foreach ($d in $dirs) {
        $name = $d.Name
        $title = switch -Regex ($name.ToLower()) {
            "logos"        { "Logos" }
            "ip_research"  { "IP & R&D Notes" }
            "letters"      { "Letters & Confirmations" }
            "letterhead"   { "Letterhead" }
            "visit_card"   { "Visit Card" }
            default        { $name }
        }

        $cards += "<a href='$($d.Name)/index.html' class='card'>$title</a>`n"
    }

    $mainHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Fin2Pay Assets Portal</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, sans-serif;
      background: #f8f9fb url('$logoPath') no-repeat center center fixed;
      background-size: 900px;
      background-blend-mode: lighten;
      color: #0b2c52;
      text-align: center;
      margin: 0;
      padding: 0;
    }
    header {
      background: rgba(255,255,255,0.9);
      padding: 40px 10px 25px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    h1 {
      margin: 0;
      font-size: 2.4em;
      font-weight: 700;
    }
    p {
      margin: 10px 0 0;
      color: #333;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 20px;
      padding: 50px;
      max-width: 900px;
      margin: 0 auto;
    }
    .card {
      background: rgba(255,255,255,0.85);
      border-radius: 16px;
      padding: 25px;
      text-decoration: none;
      color: #0b2c52;
      box-shadow: 0 4px 10px rgba(0,0,0,0.05);
      transition: transform 0.2s, box-shadow 0.2s;
      backdrop-filter: blur(6px);
      font-weight: 500;
    }
    .card:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 20px rgba(0,0,0,0.1);
    }
    footer {
      font-size: 0.9em;
      padding: 20px 0;
      color: #666;
      position: fixed;
      bottom: 10px;
      width: 100%;
      background: transparent;
    }
  </style>
</head>
<body>
  <header>
    <h1>Fin2Pay Assets Portal</h1>
    <p>Access organized brand and project materials securely</p>
  </header>
  <section class="grid">
  $cards
  </section>
  <footer>© 2025 Fin2Pay — All rights reserved.</footer>
</body>
</html>
"@

    $mainHtml | Out-File -FilePath (Join-Path $baseDir "index.html") -Encoding utf8
}

# --- Main Process ---
Write-Host "Updating Fin2Pay Assets Portal..."
$folders = Get-ChildItem -Path $baseDir -Directory
foreach ($f in $folders) {
    Generate-FolderIndex $f.FullName
}
Generate-MainIndex

# Git sync
Write-Host "Committing changes..."
Set-Location $baseDir
git add .
git commit -m "Auto update $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-Null
git pull --rebase
git push

Write-Host ""
Write-Host "----------------------------------------------"
Write-Host " Deployment complete!"
Write-Host " Your site is live at: https://assets.fin2pay.fi"
Write-Host "----------------------------------------------"
