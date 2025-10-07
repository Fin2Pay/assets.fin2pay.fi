# --- Fin2Pay Assets Auto-Indexer & Tracker (Gradient Edition) ---
# Generates index.html files for all folders with Analytics + StatCounter
# Author: Fin2Pay • 2025

$baseDir   = "D:\Fin2Pay_Assets"
$repoUrl   = "https://github.com/Fin2Pay/assets.fin2pay.fi.git"
$branch    = "main"
$styleFile = "style.css"

# --- Google Analytics ---
$gaScript = @'
<script async src="https://www.googletagmanager.com/gtag/js?id=G-ZLL26PB1Q5"></script>
<script>
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', 'G-ZLL26PB1Q5');
</script>
'@

# --- StatCounter ---
$statScript = @'
<script type="text/javascript">
var sc_project=13173824;
var sc_invisible=1;
var sc_security="f472620b";
</script>
<script type="text/javascript" src="https://www.statcounter.com/counter/counter.js" async></script>
<noscript><div class="statcounter"><a title="Web Analytics" href="https://statcounter.com/" target="_blank"><img class="statcounter" src="https://c.statcounter.com/13173824/0/f472620b/1/" alt="Web Analytics" referrerPolicy="no-referrer-when-downgrade"></a></div></noscript>
'@

$trackingCode = "$gaScript`n$statScript"

# Helper: HTML-encode (سازگار با PS 5/7)
function HtmlEncode([string]$text) {
    return [System.Net.WebUtility]::HtmlEncode($text)
}

# --- Generate folder index ---
function Generate-FolderIndex {
    param ($folderPath)

    $folderName = Split-Path $folderPath -Leaf
    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Name -notmatch '^(index\.html|style\.css)$' }

    $rows = ""
    $i = 1
    foreach ($f in $files) {
        $rows += "<tr><td>$i</td><td><a href='$($f.Name)' target='_blank'>$($f.Name)</a></td></tr>`n"
        $i++
    }

    $html = @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>__TITLE__ - Fin2Pay Assets</title>
<link rel="stylesheet" href="../__STYLE__">
__TRACKING__
</head>
<body class="with-watermark">
<header class="sub-header">__TITLE__ Folder</header>

<main class="table-area">
  <table>
    <thead><tr><th>#</th><th>File Name</th></tr></thead>
    <tbody>
__ROWS__
    </tbody>
  </table>
</main>

<div class="logo-section">
  <img src="https://assets.fin2pay.fi/LOGO.jpg" alt="Fin2Pay logo">
</div>

<footer>&copy; 2025 Fin2Pay &mdash; All rights reserved.</footer>
</body>
</html>
'@

    $html = $html.Replace("__TITLE__", (HtmlEncode $folderName)).
                  Replace("__STYLE__", $styleFile).
                  Replace("__TRACKING__", $trackingCode).
                  Replace("__ROWS__", $rows)

    $outFile = Join-Path $folderPath "index.html"
    $html | Out-File -Encoding UTF8 -FilePath $outFile
}

# --- Generate main index ---
function Generate-MainIndex {
    $dirs = Get-ChildItem -Path $baseDir -Directory
    $cards = ""
    foreach ($d in $dirs) {
        $cards += "<a href='$($d.Name)/index.html' class='card'>$($d.Name)</a>`n"
    }

    $html = @'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Fin2Pay Assets Portal</title>
<link rel="stylesheet" href="__STYLE__">
__TRACKING__
</head>
<body class="no-watermark">
<header>
  <h1>Fin2Pay Assets Portal</h1>
  <p>Access organized brand and project materials securely</p>
</header>

<section class="grid">
__CARDS__
</section>

<div class="logo-section">
  <img src="https://assets.fin2pay.fi/LOGO.jpg" alt="Fin2Pay logo">
</div>

<footer>&copy; 2025 Fin2Pay &mdash; All rights reserved.</footer>
</body>
</html>
'@

    $html = $html.Replace("__STYLE__", $styleFile).
                  Replace("__TRACKING__", $trackingCode).
                  Replace("__CARDS__", $cards)

    $html | Out-File -Encoding UTF8 -FilePath (Join-Path $baseDir "index.html")
}

Write-Host "Generating folder indexes..."
Get-ChildItem -Path $baseDir -Directory | ForEach-Object { Generate-FolderIndex $_.FullName }
Generate-MainIndex

Set-Location $baseDir
git add .
git commit -m "auto update assets"
git pull origin $branch --rebase
git push origin $branch
Write-Host "Deployment complete. Visit https://assets.fin2pay.fi"
