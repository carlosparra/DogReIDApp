# PetNavID — app Flutter

App **Flutter** de re-identificación visual de perros perdidos/encontrados
(backend: [DogReID](../DogReID)). El usuario sube **de 1 a 5 imágenes** (mín. 1)
para **buscar** coincidencias o **reportar** un perro, y **siempre recibe una
respuesta** con los perros candidatos y una decisión.

- 📸 1–5 imágenes (galería múltiple o **cámara** en dispositivo real)
- 🗺️ **Ubicación en mapa** (no se escribe lat/long; se elige tocando el mapa)
- 🐶 Resultados con **imagen** del candidato + score + decisión por bandas:
  **≥90%** alta confianza · **82–89%** revisión · **50–81%** incierto (solo el #1) · **<50%** oculto
- 🎨 Splash + identidad **PetNavID** (tema azul, ícono de app)
- ⚙️ Ajustes para cambiar de backend (Local / ngrok / GCP)

---

## Requisitos

- **Flutter 3.35+** (`flutter doctor` sin errores en el target que uses).
- Para **iOS**: Xcode + CocoaPods (`brew install cocoapods`).
- El **backend corriendo** (ver [`../DogReID`](../DogReID) → `scripts/run_backend.sh`).

```bash
flutter pub get        # instala dependencias
```

---

## Elegir el backend (importante)

La app trae 3 entornos (`lib/config/environment.dart`); el activo se ve en el
chip de la pantalla principal y se cambia en **Ajustes**:

| Entorno | Cuándo usarlo | URL |
|---|---|---|
| **Local** | web o iOS **simulador** (misma máquina) | `http://localhost:8080` |
| **Remoto (ngrok)** | **iPhone físico** (o compartir) — default | URL pública de ngrok |
| **GCP** | despliegue en la nube | URLs de Cloud Run |

> El **default es ngrok** para que el teléfono conecte sin configurar nada.
> En **simulador/web** cambia a **Local** en Ajustes (más rápido, sin túnel).
> La URL de cualquier entorno es **editable en Ajustes** en vivo.

---

## Correr en Web (Chrome) — preview rápido

```bash
flutter run -d chrome --web-port 5005
```
- En Ajustes elige **Local** (`http://localhost:8080`).
- El **mapa interactivo no se renderiza en web** (limitación de flutter_map en
  Chrome); muestra una nota de preview. El mapa funciona en móvil.

## Correr en el Simulador de iOS

```bash
open -a Simulator                      # o: flutter emulators
flutter run -d <id-del-simulador>      # flutter devices para ver el id
```
- En Ajustes elige **Local**.
- El simulador **no tiene cámara** → usa **Galería**. Para meter fotos: arrástralas
  a la ventana del Simulador, o `xcrun simctl addmedia booted <imagen.jpg>`.

## Instalar en un iPhone físico

1. **Firma** (una vez): abre `ios/Runner.xcworkspace` en Xcode → target **Runner**
   → *Signing & Capabilities* → **Automatically manage signing** + tu **Team**
   (Apple ID; gratis sirve, la app dura ~7 días). Si el bundle id choca, cámbialo
   (p. ej. `com.carlosparra.petnavid`).
2. Conecta el iPhone por cable, desbloquéalo, **Confiar**, y activa
   **Ajustes → Privacidad y seguridad → Modo desarrollador** (iOS 16+).
3. Instala:
   ```bash
   flutter devices                       # copia el id de tu iPhone
   flutter run -d <id-del-iphone> --release
   ```
4. Primer arranque en el iPhone: si dice *"Desarrollador no confiable"* →
   **Ajustes → General → VPN y gestión de dispositivos** → confía tu perfil.
5. Como el teléfono no está en `localhost`, usa el entorno **Remoto (ngrok)**
   (es el default). El backend + ngrok deben estar corriendo en la Mac
   (ver [`../DogReID/README.md`](../DogReID/README.md)).

En dispositivo real **sí** funcionan la **cámara** y el **mapa interactivo**.

---

## Estructura

```
lib/
├── config/      environment.dart (Local/ngrok/GCP) · app_settings.dart
├── models/      picked_image · report_metadata · candidate · image_result · report_result
├── services/    api_client.dart        # search() + report() (header ngrok incluido)
├── screens/     splash · home · capture · results · candidate_detail · map_picker · settings
├── widgets/     image_picker_grid · metadata_form · candidate_card
└── theme/       app_theme.dart         # Material 3, paleta azul PetNavID, claro/oscuro
assets/images/   petnavid_logo.png · petnavid_icon*.png
```

## Contrato con el backend

- Búsqueda: `POST /v1/search { report_type, images_b64[1..5], metadata }` → `ReportResult`.
- Reporte (local/ngrok): `POST /v1/reports` (persiste el perro y devuelve coincidencias previas).
- Imagen del candidato: `GET /v1/crop?path=...`.
- Las peticiones envían el header `ngrok-skip-browser-warning` para el túnel.

## Verificación

```bash
flutter analyze        # No issues found
flutter test           # All tests passed
```
