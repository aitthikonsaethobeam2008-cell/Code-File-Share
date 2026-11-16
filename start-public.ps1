# Starts the site AND a public Cloudflare tunnel. Others can use it only while this is running.
Set-Location $PSScriptRoot
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Write-Host 'Node.js not found. Install it from https://nodejs.org' -ForegroundColor Red; Read-Host 'Press Enter'; exit }
if (-not (Get-Command cloudflared -ErrorAction SilentlyContinue)) { Write-Host 'cloudflared not found. Run: winget install --id Cloudflare.cloudflared  (then close and reopen this)' -ForegroundColor Red; Read-Host 'Press Enter'; exit }
if (-not (Test-Path 'node_modules')) { Write-Host 'Installing packages (first time only)...'; npm.cmd install }

$srv = Start-Process node -ArgumentList 'server/index.js' -WindowStyle Minimized -PassThru
Start-Sleep -Seconds 2
$log = Join-Path $env:TEMP 'cfs-tunnel.log'
Remove-Item $log -ErrorAction SilentlyContinue
$tun = Start-Process cloudflared -ArgumentList 'tunnel','--url','http://localhost:3000' -RedirectStandardError $log -WindowStyle Hidden -PassThru

Write-Host 'Opening public link, please wait...'
$url = $null
for ($i = 0; $i -lt 60 -and -not $url; $i++) {
  Start-Sleep -Seconds 1
  $txt = Get-Content $log -Raw -ErrorAction SilentlyContinue
  # skip api.trycloudflare.com (Cloudflare's own API address, shows up in the log when the tunnel fails)
  if ($txt -match 'https://(?!api\.)[a-z0-9-]+\.trycloudflare\.com') { $url = $Matches[0] }
  if ($tun.HasExited) { break }
}
if ($url) {
  Set-Clipboard -Value $url
  Write-Host ''
  Write-Host 'PUBLIC LINK (already copied - just paste it to anyone):' -ForegroundColor Green
  Write-Host $url -ForegroundColor Cyan
  Start-Process $url
} else {
  Write-Host 'Could not get a public link. Turn off any VPN/proxy, check your internet and try again.' -ForegroundColor Red
  Write-Host "Cloudflare log: $log" -ForegroundColor DarkGray
  Get-Content $log -Tail 6 -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_ -ForegroundColor DarkGray }
}
Write-Host ''
Write-Host 'The site is ONLINE only while this window stays open.' -ForegroundColor Yellow
Read-Host 'Press Enter here to CLOSE the site'
Stop-Process -Id $tun.Id -Force -ErrorAction SilentlyContinue
Stop-Process -Id $srv.Id -Force -ErrorAction SilentlyContinue
