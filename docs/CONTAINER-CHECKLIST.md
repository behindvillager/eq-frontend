# eq-frontend Container Build - Checkliste

## ✅ Fertig

- [x] Add-on Struktur erstellt (`addon/`)
- [x] Multi-stage Dockerfile (Node.js build + Alpine runtime)
- [x] config.yaml mit allen Architekturen
- [x] build.yaml mit HA Base Images
- [x] GitHub Actions Workflow für Multi-Arch Build
- [x] .gitignore aktualisiert
- [x] Dokumentation erstellt (CONTAINER-BUILD.md)
- [x] Push-Script erstellt

## ⏳ Nächste Schritte

### 1. GitHub Repository Settings prüfen

- [ ] Gehe zu: https://github.com/behindvillager/eq-frontend/settings/actions
- [ ] Unter "Workflow permissions": **"Read and write permissions"** auswählen
- [ ] Speichern

### 2. Commit und Push

```bash
./script/push-container-setup.sh
```

Oder manuell:

```bash
git add addon/ .github/workflows/build-container.yml .gitignore docs/CONTAINER-BUILD.md
git commit -m "Add eq-frontend container build setup"
git push origin eq-dev
```

### 3. Build beobachten

- [ ] Gehe zu: https://github.com/behindvillager/eq-frontend/actions
- [ ] Workflow "Build Equicrew Frontend Container" sollte automatisch starten
- [ ] Warte auf erfolgreichen Build (~30-45 Minuten)

### 4. Images verifizieren

```bash
# Prüfe ob Images auf GHCR verfügbar sind
docker pull ghcr.io/behindvillager/eq-frontend-aarch64:latest
docker pull ghcr.io/behindvillager/eq-frontend-amd64:latest
```

### 5. Lokaler Test

```bash
# AMD64 Image testen
docker run -d -p 8099:8099 --name eq-frontend-test \
  ghcr.io/behindvillager/eq-frontend-amd64:latest

# Browser öffnen: http://localhost:8099
# Sollte eq cube Frontend zeigen (grünes Logo, equicrew.com Links)

# Cleanup
docker stop eq-frontend-test
docker rm eq-frontend-test
```

### 6. OS-Build vorbereiten

**Wichtig:** Du musst im `operating-system` Repo die Frontend-Referenz ersetzen!

Suche in `/home/vboxuser/operating-system` nach:

- `buildroot-external/package/homeassistant-frontend/`
- Oder ähnliche Frontend-Package-Definitionen

Ersetze die Image-Referenz durch:

```
ghcr.io/behindvillager/eq-frontend-{arch}:latest
```

**Dann OS bauen:**

```bash
cd /home/vboxuser/operating-system
scripts/enter.sh make odroid_m1s
```

## Troubleshooting

### Build schlägt fehl

- [ ] Prüfe GitHub Actions Logs
- [ ] Workflow permissions korrekt gesetzt?
- [ ] Dockerfile Syntax korrekt?

### GHCR Push schlägt fehl

- [ ] Workflow permissions: "Read and write"
- [ ] `packages: write` Permission gesetzt?

### Images nicht verfügbar

- [ ] Build erfolgreich abgeschlossen?
- [ ] Packages auf https://github.com/behindvillager?tab=packages sichtbar?
- [ ] Package visibility auf "public" gesetzt?

### OS-Build findet Image nicht

- [ ] Image-Referenz im OS-Build korrekt?
- [ ] Image auf GHCR public?
- [ ] Netzwerkverbindung während OS-Build OK?

## Wichtige Links

- Frontend Repo: https://github.com/behindvillager/eq-frontend
- GitHub Actions: https://github.com/behindvillager/eq-frontend/actions
- GHCR Packages: https://github.com/behindvillager?tab=packages
- Dokumentation: `/workspaces/frontend/docs/CONTAINER-BUILD.md`

## Version Management

Aktuelle Version: `2024.12.0-eq1`

Bei Updates:

1. Version in `addon/config.yaml` erhöhen
2. Commit und Push
3. GitHub Actions baut automatisch neue Version
4. Neue Version testen
5. Tag erstellen: `git tag v2024.12.0-eq2 && git push origin v2024.12.0-eq2`
