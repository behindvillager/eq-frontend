# Equicrew Frontend Add-on - Installation und Test-Anleitung

## Übersicht
Dieses Add-on stellt eine angepasste Home Assistant Frontend-Version mit Equicrew-Branding bereit.

## Voraussetzungen
- Home Assistant OS auf Odroid M1S (oder anderem System)
- Zugriff auf die Home Assistant Web-Oberfläche
- GitHub-Repository: https://github.com/behindvillager/eq-frontend

## Schritt 1: Add-on-Repository hinzufügen

1. Öffne **Home Assistant** im Browser
2. Navigiere zu: **Settings** → **Add-ons** → **Add-on Store**
3. Klicke auf **⋮** (drei Punkte) oben rechts
4. Wähle **Repositories**
5. Füge die URL hinzu: `https://github.com/behindvillager/eq-frontend`
6. Klicke **Add**

## Schritt 2: Add-on installieren

1. **Aktualisiere** die Add-on-Liste (falls das neue Repository nicht sofort erscheint)
2. Suche nach **"Equicrew Frontend"** im Store
3. Klicke auf das Add-on
4. Klicke **Install**
5. Warte, bis das Image heruntergeladen und installiert ist

## Schritt 3: Add-on starten

1. Klicke auf **Start**
2. Aktiviere **"Start on boot"** (optional, aber empfohlen)
3. Aktiviere **"Watchdog"** (optional, startet Add-on neu bei Absturz)
4. Prüfe die **Logs**, um sicherzustellen, dass nginx erfolgreich startet:
   ```
   Starting Equicrew Frontend...
   ```

## Schritt 4: Add-on testen

Das Add-on läuft jetzt auf Port 8099. Du kannst es testen:

### Option A: Direkter Zugriff im Browser
```
http://<DEINE-HA-IP>:8099
```

Du solltest das Equicrew-Frontend sehen (mit eq cube Logo und grünem Theme).

### Option B: Als Ingress nutzen
Das Add-on sollte in der Add-on-Übersicht einen **"Open Web UI"** Button haben (wenn Ingress konfiguriert ist).

## Schritt 5: Home Assistant für externes Frontend konfigurieren (Optional)

**Hinweis**: Dieser Schritt ist nur nötig, wenn du möchtest, dass Home Assistant das Equicrew-Frontend **anstelle** des Standard-Frontends verwendet.

Bearbeite deine `configuration.yaml`:

```yaml
frontend:
  extra_module_url:
    - http://localhost:8099/frontend_latest/entrypoints/core.js
  themes: !include_dir_merge_named themes
```

**ACHTUNG**: Dies ist eine experimentelle Konfiguration. Es ist besser, das Add-on separat zu nutzen.

## Schritt 6: Testen und Verifizieren

1. **Logs prüfen**:
   - Gehe zu Add-ons → Equicrew Frontend → Log
   - Stelle sicher, dass keine Fehler auftreten

2. **Funktionalität testen**:
   - Öffne `http://<DEINE-HA-IP>:8099`
   - Prüfe, ob das eq cube Logo sichtbar ist
   - Prüfe, ob das grüne Theme (#23935E) aktiv ist
   - Teste die Navigation

3. **Multi-Arch verifizieren**:
   - Das Image sollte automatisch für deine Architektur (aarch64 für Odroid M1S) geladen werden
   - Prüfe in den Logs: `Starting Equicrew Frontend...`

## Troubleshooting

### Add-on startet nicht
- Prüfe die Logs auf Fehlermeldungen
- Stelle sicher, dass Port 8099 nicht bereits verwendet wird
- Prüfe, ob das Image korrekt heruntergeladen wurde

### Frontend zeigt Fehler
- Stelle sicher, dass der Build erfolgreich war (GitHub Actions)
- Prüfe die nginx-Konfiguration im Container
- Teste mit `http://<IP>:8099/index.html` direkt

### Image nicht gefunden
- Stelle sicher, dass das GitHub Actions Build erfolgreich war
- Prüfe, ob das Image auf GHCR gepusht wurde: https://github.com/behindvillager/eq-frontend/pkgs/container/eq-frontend-aarch64
- Das Image muss öffentlich sein oder du brauchst GitHub-Token

## Automatische Updates

Um das Add-on automatisch zu aktualisieren:

1. Gehe zu **Settings** → **Add-ons** → **Equicrew Frontend**
2. Klicke auf **"Check for updates"**
3. Wenn eine neue Version verfügbar ist, klicke **Update**

## Entwicklung

Wenn du Änderungen am Frontend vornimmst:

1. Commit und pushe deine Änderungen
2. GitHub Actions baut automatisch ein neues Image
3. Warte ~10-20 Minuten bis der Build fertig ist
4. Aktualisiere das Add-on in Home Assistant
5. Starte das Add-on neu

## Nächste Schritte

- [ ] Teste das Add-on auf dem Odroid M1S
- [ ] Verifiziere, dass das Equicrew-Branding korrekt angezeigt wird
- [ ] Konfiguriere automatische Updates (optional)
- [ ] Dokumentiere weitere Anpassungen

## Support

Bei Problemen:
- Prüfe die GitHub Actions Logs
- Prüfe die Add-on Logs in Home Assistant
- Öffne ein Issue auf GitHub
