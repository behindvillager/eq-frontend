# Equicrew Frontend Container Build Guide

## Ziel

Erstelle einen Multi-Arch Docker Container mit dem eq-frontend (angepasstes Home Assistant Frontend) und pushe ihn nach GHCR (GitHub Container Registry) für die spätere Verwendung beim Home Assistant OS Build.

## Struktur

```
eq-frontend/
├── addon/
│   ├── Dockerfile          # Multi-stage build (Node.js build + Alpine runtime)
│   ├── config.yaml         # Add-on Konfiguration
│   ├── build.yaml          # Multi-Arch Base Images
│   └── README.md           # Add-on Dokumentation
├── .github/
│   └── workflows/
│       └── build-container.yml  # Automatischer Build via GitHub Actions
└── ... (restliche Frontend-Dateien)
```

## Wie es funktioniert

### 1. Dockerfile (Multi-Stage Build)

**Stage 1: Builder**

- Nutzt `node:20-alpine` Image
- Installiert Build-Dependencies (python3, make, g++, git)
- Kopiert package.json und yarn.lock
- Führt `yarn install --frozen-lockfile` aus
- Kopiert gesamten Source-Code
- Führt `yarn build` aus → Output in `/build/hass_frontend`

**Stage 2: Runtime**

- Nutzt HA Base Image (z.B. `ghcr.io/home-assistant/amd64-base:3.20`)
- Installiert nginx
- Kopiert gebautes Frontend von Stage 1 nach `/usr/share/nginx/html`
- Konfiguriert nginx auf Port 8099
- CMD: `nginx -g "daemon off;"`

### 2. GitHub Actions Workflow

Der Workflow baut automatisch für alle Architekturen:

**Trigger:**

- Push zu `eq-dev` oder `eq-main`
- Tags `v*`
- Manuell via workflow_dispatch

**Matrix Build:**

- aarch64 (ARM64, z.B. Odroid M1S)
- amd64 (x86_64)
- armv7 (ARM 32-bit v7)
- armhf (ARM 32-bit v6)
- i386 (x86 32-bit)

**Steps:**

1. Checkout Repository
2. Setup QEMU (für Cross-Platform Builds)
3. Setup Docker Buildx
4. Login zu GHCR
5. Bestimme Base Image für Architektur
6. Bestimme Docker Platform für Architektur
7. Extrahiere Version aus `addon/config.yaml`
8. Build und Push zu GHCR mit Tags:
   - `latest`
   - `<version>` (z.B. `2024.12.0-eq1`)

**Resultierende Images:**

```
ghcr.io/behindvillager/eq-frontend-aarch64:latest
ghcr.io/behindvillager/eq-frontend-aarch64:2024.12.0-eq1
ghcr.io/behindvillager/eq-frontend-amd64:latest
ghcr.io/behindvillager/eq-frontend-amd64:2024.12.0-eq1
... (usw. für alle Architekturen)
```

### 3. config.yaml

```yaml
name: "Equicrew Frontend"
version: "2024.12.0-eq1"
slug: eq-frontend
description: "Custom Equicrew Home Assistant Frontend"
arch:
  - aarch64
  - amd64
  - armv7
  - armhf
  - i386
image: ghcr.io/behindvillager/eq-frontend-{arch}
```

**Wichtig:**

- `version` muss bei jedem Release erhöht werden
- `{arch}` wird automatisch durch die jeweilige Architektur ersetzt
- `image` zeigt auf GHCR, sodass der OS-Build die Container pullen kann

### 4. build.yaml

Definiert die HA Base Images für jede Architektur:

```yaml
build_from:
  aarch64: ghcr.io/home-assistant/aarch64-base:3.20
  amd64: ghcr.io/home-assistant/amd64-base:3.20
  ...
```

Diese Images enthalten Alpine Linux 3.20 mit allen HA-spezifischen Tools.

## Workflow

### Lokaler Test (Optional)

```bash
# Wechsle ins Frontend-Repo
cd /workspaces/frontend

# Test-Build für AMD64
docker build \
  -f addon/Dockerfile \
  --build-arg BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.20 \
  -t eq-frontend:test \
  .

# Test-Run
docker run -d -p 8099:8099 --name eq-frontend-test eq-frontend:test

# Test im Browser
curl http://localhost:8099

# Cleanup
docker stop eq-frontend-test
docker rm eq-frontend-test
```

### Production Build via GitHub Actions

1. **Commit und Push**

   ```bash
   git add addon/ .github/workflows/build-container.yml .gitignore
   git commit -m "Add eq-frontend container build setup"
   git push origin eq-dev
   ```

2. **Workflow beobachten**
   - Gehe zu: https://github.com/behindvillager/eq-frontend/actions
   - Der Build dauert ca. 30-45 Minuten (alle Architekturen parallel)

3. **Images verifizieren**

   ```bash
   # Prüfe ob Images verfügbar sind
   docker pull ghcr.io/behindvillager/eq-frontend-aarch64:latest
   docker pull ghcr.io/behindvillager/eq-frontend-amd64:latest
   ```

4. **Test lokal**

   ```bash
   docker run -d -p 8099:8099 --name eq-frontend-test \
     ghcr.io/behindvillager/eq-frontend-amd64:latest

   # Browser öffnen: http://localhost:8099
   ```

### Integration in Home Assistant OS Build

Sobald die Images auf GHCR verfügbar sind:

1. **In operating-system Repo:**

   ```bash
   cd /home/vboxuser/operating-system
   ```

2. **Buildroot Konfiguration anpassen:**
   - Ersetze die offizielle HA Frontend-Image-Referenz durch deine:

   ```
   ghcr.io/behindvillager/eq-frontend-{arch}:latest
   ```

   **Wo genau?**
   - Suche nach Frontend-Referenzen in:
     - `buildroot-external/package/*/`
     - `buildroot-external/board/*/rootfs-overlay/`
   - Beispiel-Pfade (können variieren):
     ```
     buildroot-external/package/homeassistant/homeassistant.mk
     buildroot-external/package/homeassistant-frontend/homeassistant-frontend.mk
     ```

3. **OS Build starten:**

   ```bash
   scripts/enter.sh make odroid_m1s
   ```

   Der Build wird nun dein eq-frontend Image von GHCR pullen.

## Versionierung

**Semantic Versioning:**

- `2024.12.0-eq1` = Basiert auf HA 2024.12.0, erste eq-Version
- `2024.12.0-eq2` = Zweite eq-Version (mit Fixes/Änderungen)
- `2024.12.1-eq1` = Nach HA Update auf 2024.12.1

**Bei neuem HA Release:**

1. Merge HA stable in eq-dev (siehe `docs/EQ-MERGE-WORKFLOW.md`)
2. Erhöhe Version in `addon/config.yaml`
3. Push zu eq-dev
4. GitHub Actions baut automatisch
5. Teste die neuen Images
6. Wenn OK: Tag erstellen und zu eq-main mergen

## Troubleshooting

### Build schlägt fehl: "yarn: command not found"

→ `corepack enable` fehlt im Dockerfile (bereits enthalten)

### Build schlägt fehl: "hass_frontend not found"

→ `yarn build` Output-Pfad prüfen, evtl. ist es `build/` statt `hass_frontend/`

### GHCR Push schlägt fehl: 403 Forbidden

→ GitHub Repo Settings → Actions → Workflow permissions → "Read and write permissions"

### Image zu groß (>2GB)

→ Normal für Frontend mit allen Assets, GHCR unterstützt große Images

### nginx startet nicht

→ Logs prüfen: `docker logs <container-id>`
→ Port 8099 bereits belegt? `netstat -tuln | grep 8099`

### OS Build findet Image nicht

→ Image-Referenz in OS-Build-Konfiguration prüfen
→ Images müssen public sein oder OS-Build muss GHCR Token haben

## Nächste Schritte

1. ✅ Add-on Struktur erstellt
2. ✅ Dockerfile mit Multi-Stage Build
3. ✅ GitHub Actions Workflow
4. ⏳ **Jetzt:** Push zu GitHub und Build starten
5. ⏳ Images auf GHCR verifizieren
6. ⏳ Lokalen Test durchführen
7. ⏳ OS-Build Konfiguration anpassen
8. ⏳ Equicrew Cube OS mit eq-frontend bauen

## Referenzen

- HA Add-on Docs: https://developers.home-assistant.io/docs/add-ons/
- HA Add-ons Repo: https://github.com/home-assistant/addons
- Docker Multi-Platform: https://docs.docker.com/build/building/multi-platform/
- GHCR Docs: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
