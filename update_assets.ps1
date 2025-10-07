# --- Fin2Pay Assets Auto-Indexer & Tracker (Gradient Edition) ---
# Author: Vahid • Fin2Pay • 2025

$baseDir   = "D:\Fin2Pay_Assets"
$repoUrl   = "https://github.com/Fin2Pay/assets.fin2pay.fi.git"
$branch    = "main"
$styleFile = "style.css"

# ---- HTML safe encoder (بدون System.Web) ----
function HtmlEncode([string]$s){
    $s = $s -replace '&','&amp;'
    $s = $s -replace '<','&lt;'
    $s = $s -replace '>','&gt;'
    $s = $s -replace '"','&quot;'
    $s = $s -replace "'",'&#39;'
    return $s
}

# ---- Google Analytics ----
$gaID = "G-ZLL26PB1Q5"
$gaScript = @"
<script async src="https://www.googletagmanager.com/gtag/js?id=$gaID"></script>
<script>
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', '$gaID');
</script>
"@

# ---- StatCounter ----
$statScript = @"
<script>var sc_project=13173824; var sc_invisible=1; var sc_security="f472620b";</script>
<script src="https://www.statcounter.com/counter/counter.js" async></script>
<noscript><div class="statcounter"><a title="Web Analytics" href="https://statcounter.com/" target="_blank">
<img class="statcounter" src="https://c.statcounter.com/13173824/0/f472620b/1/" alt="Web Analytics" referrerPolicy="no-referrer-when-downgrade"></a></div></noscript>
"@

$trackingCode = "$gaScript`n$statScript"

# ---- Folder index generator (زیرصفحات) ----
function Generate-FolderIndex {
    param ($folderPath)

    $folderName = Split-Path $folderPath -Leaf
    $files = Get-ChildItem -Path $folderPath -File |
             Where-Object { $_.Name -notmatch '^(index\.html|style\.css)$' }

    $rows = ""
    $i = 1
    foreach ($f in $files) {
        $nameEncoded = $(HtmlEncode $f.Name)
        $rows += "<tr><td>$i</td><td><a href='$nameEncoded' target='_blank'>$nameEncoded</a></td></tr>`n"
        $i++
    }

    $title = "$(HtmlEncode $folderName) Folder"

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>$title - Fin2Pay Assets</title>
<link rel="stylesheet" href="../$styleFile">
$trackingCode
</head>
<body class="with-watermark">
<header class="sub-header">$title</header>

<main class="table-area">
  <table>
    <thead><tr><th>#</th><th>File Name</th></tr></thead>
    <tbody>
$rows
    </tbody>
  </table>
</main>

<footer>&copy; 2025 Fin2Pay &mdash; All rights reserved.</footer>
</body>
</html>
"@

    $out = Join-Path $folderPath "index.html"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($out, $html, $utf8NoBom)
}

# ---- Main portal generator (صفحه اصلی) ----
function Generate-MainIndex {
    $dirs = Get-ChildItem -Path $baseDir -Directory
    $cards = ""
    foreach ($d in $dirs) {
        $nameEsc = $(HtmlEncode $d.Name)
        $cards  += "<a href='$($d.Name)/index.html' class='card'>$nameEsc</a>`n"
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Fin2Pay Assets Portal</title>
<link rel="stylesheet" href="$styleFile">
$trackingCode
</head>
<body>
<header>
  <h1>Fin2Pay Assets Portal</h1>
  <p>Access organized brand and project materials securely</p>
</header>

<section class='grid'>
$cards
</section>

<footer>&copy; 2025 Fin2Pay &mdash; All rights reserved.</footer>
</body>
</html>
"@

    $out = Join-Path $baseDir "index.html"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($out, $html, $utf8NoBom)
}

# ---- Run build ----
Write-Host "Generating folder indexes..."
Get-ChildItem -Path $baseDir -Directory | ForEach-Object { Generate-FolderIndex $_.FullName }
Generate-MainIndex

# ---- Git sync ----
Set-Location $baseDir
git add .
git commit -m "auto update assets"
git fetch origin --prune
git pull origin $branch --rebase
git push origin $branch
Write-Host "Deployment complete. Visit https://assets.fin2pay.fi"
