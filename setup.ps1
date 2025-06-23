<#
.SYNOPSIS
  Prepara entorno en Windows: Node, pnpm, Flutter, Docker Desktop
  (usa winget; requiere Windows 10/11 actualizados)
#>

function Ensure-Binary ($name, $wingetId) {
  if (Get-Command $name -ErrorAction SilentlyContinue) { return }
  Write-Host "Installing $name..."
  winget install --id $wingetId -e --silent
}

Write-Host "`n==> Checking prerequisites"
Ensure-Binary nodejs "OpenJS.NodeJS.LTS"
Ensure-Binary pnpm  "PNPM.PNPM"
Ensure-Binary flutter "Flutter.Flutter"
Ensure-Binary git    "Git.Git"
Ensure-Binary docker  "Docker.DockerDesktop"
Ensure-Binary firebase "Google.FirebaseCLI"

# FlutterFire CLI (Dart pub)
if (-not (Get-Command flutterfire -ErrorAction SilentlyContinue)) {
  dart pub global activate flutterfire_cli
  $env:Path += ";$($env:USERPROFILE)\AppData\Local\Pub\Cache\bin"
}

Write-Host "`n==> Installing dependencies"
Push-Location backend
pnpm install
Pop-Location

Push-Location frontend
flutter pub get
Pop-Location

Write-Host "`n==> Building Docker images (may take a while)"
docker compose -f infra\docker-compose.yml build

Write-Host "`n✅  Setup finished."
Write-Host "   Run: docker compose -f infra\docker-compose.yml up"
