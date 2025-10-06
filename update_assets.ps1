# --- Fin2Pay Assets Auto Updater ---
# Clean version (no emojis, no Unicode issues)

$baseDir = "D:\Fin2Pay_Assets"

# Function to generate index for each folder
function Generate-FolderIndex {
    param([string]$folderPath)

    $folderName = Split-Path $folderPath -Leaf
    $files = Get-ChildItem -Path $folderPath -File

    $html = @"
<!DOCTYPE html>
<html lang='en'>
<head>
  <meta charset='UTF-8'>
  <title>$folderName - Fin2Pay Assets</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: #f8f9fb;
      text-align: center;
      padding: 40px;
      color: #1a1a1a;
    }
    h1 {
      font-size: 2em;
      color: #002855;
      margin-bottom: 10px;
    }
    p {
      color: #555;
    }
    ul {
      list-style: none;
      padding: 0;
    }
    li {
      margin: 8px 0;
      font-size: 1.1em;
    }
    a {
      color: #004aad;
      text-decoration: none;
    }
    a:hover {
      text-decoration: underline;
    }
    footer {
      margin-top: 40px;
      color: #666;
      font-size: 0.9em;
    }
  </style>
</head>
<body>
  <h1>$folderName Folder</h1>
  <p>Total Files: $($files.Count)</p>
  <ul>
"@

    foreach ($f in $files) {
        $html += "    <li><a href='$($f.Name)'>$($f.Name)</a></li>`n"
    }

    $html += @"
  </ul>
  <footer>
    &copy; 2025 Fin2Pay — All rights reserved.
  </footer>
</body>
</html>
"@

    $html | Out-File -Encoding utf8 -FilePath (Join-Path $folderPath "index.html")
}

# Function to generate main index page
function Generate-MainIndex {
    $dirs = Get-ChildItem -Path $baseDir -Directory

    $cards = ""
    foreach ($d in $dirs) {
        $title = switch -Regex ($d.Name.ToLower()) {
            "logos" { "Logos" }
            "ip_research" { "IP & R&D Notes" }
            "letters" { "Letters & Confirmations" }
            "letterhead" { "Letterhead" }
            "visit_card" { "Visit Card" }
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
      font-family: 'Segoe UI', sans-serif;
      background: #f8f9fb url('https://assets.fin2pay.fi/LOGO.jpg') no-repeat center 120px;
      background-size: 250px;
      margin: 0;
      padding-top: 320px;
      color: #1a1a1a;
      text-align: center;
    }
    header {
      margin-bottom: 40px;
    }
    h1 {
      color: #002855;
      font-size: 2.4em;
      margin: 0;
    }
    p {
      color: #555;
      margin-top: 6px;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 25px;
      padding: 20px 40px;
      max-width: 900px;
      margin: 0 auto;
    }
    .card {
      background: white;
      border-radius: 14px;
      padding: 25px;
      text-decoration: none;
      color: #002855;
      box-shadow: 0 4px 8px rgba(0,0,0,0.05);
      transition: all 0.2s ease;
      font-weight: 500;
    }
    .card:hover {
      transform: translateY(-3px);
      box-shadow: 0 6px 15px rgba(0,0,0,0.1);
    }
    footer {
      padding: 30px;
      margin-top: 60px;
      color: #666;
      font-size: 0.9em;
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

  <footer>
    &copy; 2025 Fin2Pay — All rights reserved.
  </footer>
</body>
</html>
"@

    $mainHtml | Out-File -Encoding utf8 -FilePath (Join-Path $baseDir "index.html")
}

# --- Main Execution ---
Write-Host "Generating indexes..."
$folders = Get-ChildItem -Path $baseDir -Directory

foreach ($folder in $folders) {
    Generate-FolderIndex -folderPath $folder.FullName
}

Generate-MainIndex

Write-Host "Updating Git repository..."
git add .
git commit -m "Auto update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git pull --rebase
git push

Write-Host ""
Write-Host "----------------------------------------------"
Write-Host " Deployment complete!"
Write-Host " Your site is live at: https://assets.fin2pay.fi"
Write-Host "----------------------------------------------"
