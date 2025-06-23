# SGAV-CRC — Sistema de Gestión de Acceso Vehicular

*Monorepo – NestJS (backend) · Flutter Web (frontend) · Firebase · Docker*

---

## 🗂️ Estructura de carpetas

```
sgav-crc/
├── .github/                GitHub Actions CI/CD
├── backend/                 NestJS API  (sgav-backend)
├── frontend/                Flutter Web (sgav_frontend)
├── infra/
│   ├── docker-compose.yml   stack local dev/prod
│   └── docker/
│        ├── backend.Dockerfile
│        └── frontend.Dockerfile
├── docs/                    ADR, diagramas C4, Swagger JSON...
├── setup.sh                 instalador Linux / macOS
├── setup.ps1                instalador Windows PowerShell
└── README.md
```

---

## 1. Requisitos

| Herramienta         | Versión sugerida   | macOS / Linux                                  | Windows                     |
| ------------------- | ------------------ | ---------------------------------------------- | --------------------------- |
| **Docker Desktop**  | ≥ 4.x (compose v2) | ✅                                              | ✅                           |
| **Node.js**         | 20 LTS             | `nvm install 20` ó `brew`                      | winget `OpenJS.NodeJS.LTS`  |
| **pnpm**            | ≥ 8                | `npm i -g pnpm`                                | winget `PNPM.PNPM`          |
| **Flutter SDK**     | 3.22.x             | `git clone https://github.com/flutter/flutter` | winget `Flutter.Flutter`    |
| **Firebase CLI**    | ≥ 13               | `pnpm i -g firebase-tools`                     | winget `Google.FirebaseCLI` |
| **Dart pub global** | —                  | `dart pub global activate flutterfire_cli`     | idéntico                    |

> **⚠️ No deseas instalar nada?** Salta a **Instalación vía Docker**.

---

## 2. Instalación rápida (entorno local sin Docker)

### macOS / Linux

```bash
git clone https://github.com/L1k4Root/SGAV-CRC
cd sgav-crc
./setup.sh            # instala dependencias back + front
make dev-all          # levanta backend :3000 + frontend :8080
```

### Windows 10/11

```powershell
git clone https://github.com/L1k4Root/SGAV-CRC
cd sgav-crc
powershell -ExecutionPolicy Bypass -File setup.ps1
docker compose -f infra\docker-compose.yml up   # (o vea sección 3)
```

---

## 3. Instalación vía **Docker**

> Única dependencia: **Docker Desktop** corriendo.

```bash
git clone https://github.com/L1k4Root/SGAV-CRC
cd sgav-crc
docker compose -f infra/docker-compose.yml build   # 1ª vez
docker compose -f infra/docker-compose.yml up
```

| Servicio                  | URL local                                                | Notas                                           |
| ------------------------- | -------------------------------------------------------- | ----------------------------------------------- |
| Flutter Web               | [http://localhost:8080](http://localhost:8080)           | API\_URL interno apunta a `http://backend:3000` |
| Swagger                   | [http://localhost:3000/docs](http://localhost:3000/docs) | prueba endpoints                                |
| Firestore emulator (opc.) | [http://localhost:8083](http://localhost:8083)           | activado en compose                             |

---

## 4. Variables de entorno

| Archivo            | Propósito                                       | Ejemplo                                                            |
| ------------------ | ----------------------------------------------- | ------------------------------------------------------------------ |
| **backend/.env**   | claves Nest, Firebase admin                     | `PORT=3000`<br>`GOOGLE_APPLICATION_CREDENTIALS=/app/firebase.json` |
| **frontend/build** | se inyectan con `--dart-define` o `.env` plugin | `API_URL=http://localhost:3000`                                    |

> Copia `backend/.env.example → backend/.env` y ajusta.

---

## 5. Comandos útiles (`make`)

| Comando                | Acción                             |
| ---------------------- | ---------------------------------- |
| `make dev-backend`     | NestJS con hot-reload (`backend/`) |
| `make dev-frontend`    | Flutter web en Chrome              |
| `make dev-all`         | Ambos en paralelo (*concurrently*) |
| `make build-frontend`  | `flutter build web`                |
| `make deploy-firebase` | sube build a Firebase Hosting      |

*(Windows: `make` → `mingw32-make` o ejecuta los comandos manualmente.)*

---

## 6. Primeros pasos en la app

1. **Crear cuenta** (correo + pass) → se almacena con rol `resident`.
2. **Registrar vehículo** → botón ➕.
3. **Acceso guardia**
   *En Firestore → users* cambia `role` a `guard` y vuelve a iniciar sesión → se mostrará el panel semáforo.

---

## 7. Tests

```bash
# backend
cd backend
pnpm test           # unit (Jest)
pnpm test:e2e       # Supertest + in-memory emulador

# frontend
cd ../frontend
flutter test        # widget tests
```

CI default (GitHub Actions) ejecuta lint + tests en cada PR.

---

## 8. Despliegue producción

| Paso | Docker                                             | Firebase Hosting solo front      |
| ---- | -------------------------------------------------- | -------------------------------- |
| 1    | `docker compose -f infra/docker-compose.yml build` | `flutter build web`              |
| 2    | Push a tu registry / VM / AWS ECS                  | `firebase deploy --only hosting` |
| 3    | Crea un dominio o LB hacia contenedor `frontend`   | API Nest expuesto públicamente   |

---

## 9. Preguntas frecuentes

| Problema                              | Solución                                                                         |
| ------------------------------------- | -------------------------------------------------------------------------------- |
| **“field 'inactive' does not exist”** | Agrega el campo `inactive` al documento ó comprueba `containsKey` en el widget.  |
| **CORS 404 desde Flutter**            | Verifica `API_URL` y que `app.enableCors({origin:'*'})` esté activo en Nest dev. |
| **FlutterFire CLI not found**         | Asegura `$HOME/.pub-cache/bin` está en `$PATH`.                                  |

---

## 10. Créditos & Licencia

Proyecto de título – Universidad Andrés Bello
Autor: **Andrés A. Pérez A.**
Licencia MIT (ver LICENSE).
