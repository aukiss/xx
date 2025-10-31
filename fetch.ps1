\
# PowerShell version for local testing (not used on Netlify builds by default)
$ErrorActionPreference = "Stop"

$dist = "dist"
if (Test-Path $dist) { Remove-Item -Recurse -Force $dist }
New-Item -ItemType Directory -Force -Path $dist | Out-Null

Write-Host "Downloading latest NCE-Flow (main branch) zip..."
$zipUrl = "https://codeload.github.com/luzhenhua/NCE-Flow/zip/refs/heads/main"
$zipPath = "$env:TEMP\nce-flow.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

Write-Host "Unzipping..."
$extract = "$env:TEMP\NCE-Flow-main"
if (Test-Path $extract) { Remove-Item -Recurse -Force $extract }
Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force

# Copy files to dist
Copy-Item -Path "$extract\*" -Destination $dist -Recurse -Force

# Remove CNAME
$cname = Join-Path $dist "CNAME"
if (Test-Path $cname) { Remove-Item $cname -Force }

# Copy our headers and 404
Copy-Item "_headers" (Join-Path $dist "_headers") -Force
Copy-Item "404.html" (Join-Path $dist "404.html") -Force

Write-Host "Build finished. dist/ is ready."
