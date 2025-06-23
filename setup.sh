#!/usr/bin/env bash
set -e  # falla ante el primer error
BLUE='\033[1;34m'; NC='\033[0m'

header() { echo -e "\n${BLUE}==> $1${NC}"; }

# ---------- 0. PRE-REQUISITOS ----------
need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "❌ Requiere '$1' pero no está instalado. Aborta." >&2
    exit 1
  }
}
header "Comprobando prerequisitos"
need_cmd node
need_cmd npm
need_cmd dart
need_cmd flutter

if ! command -v pnpm &>/dev/null; then
  header "Instalando pnpm (gestor de paquetes)"
  npm i -g pnpm
fi

if ! command -v nest &>/dev/null; then
  header "Instalando Nest CLI"
  pnpm i -g @nestjs/cli
fi

if ! command -v firebase &>/dev/null; then
  header "Instalando Firebase CLI"
  pnpm i -g firebase-tools
fi

if ! command -v flutterfire &>/dev/null; then
  header "Instalando FlutterFire CLI"
  dart pub global activate flutterfire_cli
  export PATH="$PATH:$HOME/.pub-cache/bin"
fi

# ---------- 1. BACKEND ----------
header "Instalando dependencias BACKEND"
cd backend
pnpm install

if [ ! -f .env ]; then
  header "Creando backend/.env"
  cp .env.example .env
fi
cd ..

# ---------- 2. FRONTEND ----------
header "Instalando dependencias FRONTEND"
cd frontend
flutter pub get
cd ..

# ---------- 3. MAKEFILE DE COMODIDAD ----------
header "Creando Makefile auxiliar"

cat <<'EOF' > Makefile
dev-backend:
	@cd backend && npm run start:dev

dev-frontend:
	@cd frontend && flutter run -d chrome

dev-all:
	@concurrently "make dev-backend" "make dev-frontend"

build-frontend:
	@cd frontend && flutter build web

deploy-firebase:
	@firebase deploy --only hosting
EOF
# ---------- 4. DOCKER ----------
header "Configurando Docker"
need_cmd docker
need_cmd docker-compose || need_cmd docker compose   # ambas sintaxis válidas

header "Construyendo imágenes Docker"
docker compose -f infra/docker-compose.yml build

echo "✅  Ejecuta 'docker compose -f infra/docker-compose.yml up' para arrancar stack."

# ---------- FIN ----------
echo -e "\n✅ Setup completo. Comandos útiles:"
echo "   make dev-backend      # Nest en modo dev"
echo "   make dev-frontend     # Flutter en Chrome"
echo "   make dev-all          # ambos (requiere 'concurrently')"
echo "   make build-frontend   # genera frontend/build/web"
echo "   make deploy-firebase  # sube front a Firebase Hosting"
