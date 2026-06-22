# DogReIDApp

App **Flutter** del sistema [DogReID](../DogReID) (re-identificación visual de
perros perdidos/encontrados). El usuario sube **de 1 a 5 imágenes** (mínimo 1)
para **buscar** coincidencias o **reportar** un perro, y **siempre recibe una
respuesta** con los perros candidatos y una decisión (alta confianza / revisar /
no confirmado).

Funciona contra **dos backends** seleccionables en Ajustes:
- **Local** — `local/app.py` del repo DogReID (FastAPI + índice NumPy).
- **GCP** — Cloud Run (`inference` para `/v1/search`, `api` para `/v1/reports`).

## Características

- 📸 Subida de **1–5 imágenes** (galería múltiple o cámara), con miniaturas y borrado.
- 🔎 **Buscar** (síncrono) y 📝 **Reportar** (con *polling* hasta tener respuesta en GCP).
- 🧭 Metadata contextual opcional: color, tamaño, collar, descripción, lat/lon, fecha.
- 🐶 Resultados con score visual + contextual y decisión legible (NB-13).
- ⚙️ Ajustes para cambiar de entorno (Local/GCP) y editar URLs en vivo.

## Correr

```bash
flutter pub get
flutter run            # elige iOS / Android / web
```

### Backend local
En el repo `../DogReID` (con la galería ya importada):
```bash
source .venv/bin/activate
GALLERY_DIR=local/data/gallery_found uvicorn local.app:app --port 8080
```
En la app → **Ajustes** → entorno **Local**:
- iOS / web: `http://localhost:8080`
- Emulador Android: `http://10.0.2.2:8080`

### Backend GCP
Despliega los servicios (ver `../DogReID/gcp/`) y pon sus URLs de Cloud Run en
**Ajustes** (o en `lib/config/environment.dart`, preset `gcp`).

## Estructura

```
lib/
├── config/      environment.dart · app_settings.dart
├── models/      picked_image · report_metadata · candidate · image_result · report_result
├── services/    api_client.dart        # search() + report() (local y GCP)
├── screens/     home · capture · results · settings
└── widgets/     image_picker_grid · metadata_form · candidate_card
```

## Contrato con el backend

- Búsqueda: `POST /v1/search { report_type, images_b64[1..5], metadata }` → `ReportResult`.
- Reporte GCP: `POST /v1/reports` → signed URLs → `PUT` imágenes → polling `GET /v1/reports/{id}`.

Detalle y endpoints pendientes en el backend: ver `claude/BACKEND_CONTRACT.md`
(carpeta local, no versionada).

## Verificación

```bash
flutter analyze        # No issues found
flutter test           # All tests passed
```
