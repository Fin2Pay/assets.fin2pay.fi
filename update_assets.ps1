# --- Fin2Pay Assets Auto-Indexer & Tracker ---
# Generates index.html for all folders and adds Google Analytics + StatCounter
# Author: Vahid • Fin2Pay • 2025

$baseDir = "D:\Fin2Pay_Assets"
$repoUrl = "https://github.com/Fin2Pay/assets.fin2pay.fi.git"
$branch = "main"
$mainLogo = "LOGO.jpg"

# --- Google Analytics ID ---
$gaID = "G-ZLL26PB1Q5"

# --- Google Analytics Script ---
$gaScript = @"
<script async src="https://www.googletagmanager.com/gtag/js?id=$gaID"></script>
<script>
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', '$gaID');
</script>
"@

# --- StatCounter Script ---
$statCounter = @"
<!-- Default Statcounter code for assets_fin2pay https://assets.fin2pay.fi/ -->
<script type="text/javascript">
var sc_project=13173824; 
var sc_invisible=1; 
var sc_security="f472620b"; 
</script>
<script type="text/javascript" src="https://www.statcounter.com/counter/counter.js" async></script>
<noscript><div class="statcounter"><a title="Web Analytics"
href="https://statcounter.com/" target="_blank"><img class="statcounter"
src="https://c.statcounter.com/13173824/0/f472620b/1/" alt="Web Analytics"
referrerPolicy="no-referrer-when-downgrade"></a></div></noscript>
<!-- End of Statcounter Code -->
"@

# --- Combined Tracking Scripts ---
$trackingCode = "$gaScript`n$statCounter"

# --- Folder Page Generator ---
function Generate-FolderIndex {
    param ($folderPath)

    $folderName = Split-Path $folderPath -Leaf
    $files = Get-ChildItem -Path $folderPath -File | Where-Object { $_.Name -ne "index.html" }
    $fileList = ""
    $counter = 1

    foreach ($file in $files) {
        $fileList += "<li>$counter - <a href='$($file.Name)'>$($file.Name)</a></li>`n"
        $counter++
    }

    $total = $files.Count
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>$folderName - Fin2Pay Assets</title>
$trackingCode
<style>
body {
  font-family: 'Segoe UI', Tahoma, sans-serif;
  background: #f8f9fb url('../$mainLogo') no-repeat center center fixed;
  background-size: 800px;
  background-blend-mode: lighten;
  opacity: 0.95;
  text-align: center;
  margin: 0;
  padding: 0;
}
h1 {
  color: #002855;
  margin-top: 120px;
  font-size: 2.2em;
}
ul { list-style: none; padding: 0; }
a { color: #004aad; text-decoration: none; }
a:hover { text-decoration: underline; }
footer {
  font-size: 0.9em;
  padding: 30px 0;
  color: #666;
  position: fixed;
  bottom: 10px;
  width: 100%;
}
</style>
</head>
<body>
<h1>$folderName Folder</h1>
<p>Total Files: $total</p>
<ul>$fileList</ul>
<footer>© 2025 Fin2Pay — All rights reserved.</footer>
</body>
</html>
"@

    $html | Out-File -Encoding UTF8 -FilePath (Join-Path $folderPath "index.html")
}

# --- Main Portal Generator ---
function Generate-MainIndex {
    $dirs = Get-ChildItem -Path $baseDir -Directory
    $cards = ""

    foreach ($d in $dirs) {
        $cards += "<a href='$($d.Name)/index.html' class='card'>$($d.Name)</a>`n"
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<title>Fin2Pay Assets Portal</title>
$trackingCode
<style>
body {
  font-family: 'Segoe UI', Tahoma, sans-serif;
  background: #f8f9fb url('$mainLogo') no-repeat center center fixed;
  background-size: 1000px;
  background-blend-mode: lighten;
  opacity: 0.95;
  color: #1a1a1a;
  text-align: center;
  margin: 0;
  padding: 0;
}
header {
  background: rgba(255,255,255,0.9);
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  padding: 30px 10px;
}
h1 {
  margin: 0;
  font-size: 2.4em;
  color: #002855;
}
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 20px;
  padding: 40px;
  max-width: 900px;
  margin: 0 auto;
}
.card {
  background: rgba(255,255,255,0.9);
  border-radius: 16px;
  padding: 25px;
  text-decoration: none;
  color: #002855;
  box-shadow: 0 4px 10px rgba(0,0,0,0.05);
  transition: transform 0.2s, box-shadow 0.2s;
}
.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 6px 15px rgba(0,0,0,0.1);
}
footer {
  font-size: 0.9em;
  padding: 30px 0;
  color: #666;
  position: fixed;
  bottom: 10px;
  width: 100%;
}
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
<footer>© 2025 Fin2Pay — All rights reserved.</footer>
</body>
</html>
"@

    $html | Out-File -Encoding UTF8 -FilePath (Join-Path $baseDir "index.html")
}

# --- Run build ---
Write-Host "Generating folder indexes..."
$folders = Get-ChildItem -Path $baseDir -Directory
foreach ($f in $folders) { Generate-FolderIndex $f.FullName }
Generate-MainIndex

# --- Git push ---
Set-Location $baseDir
git add .
git commit -m "auto update assets"
git pull origin $branch --rebase
git push origin $branch
Write-Host "✅ Deployment complete. Visit https://assets.fin2pay.fi"
