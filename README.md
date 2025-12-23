# Equicrew Assistant Frontend

Das offizielle Frontend für den **EQcube** - powered by [Equicrew](https://equicrew.de).

Dieses Projekt ist ein Fork des [Home Assistant Frontend](https://github.com/home-assistant/frontend) und wurde speziell für die Equicrew Smart Home Lösung angepasst.

## Features

### Equicrew Anpassungen (v1.0.0)

- 🎨 **Equicrew Branding** - Eigene Logos, Favicons und App-Icons
- 📱 **Android Companion App Fix** - Logout-Funktion funktioniert korrekt
- 🧩 **HACS Integration** - Vollständige Unterstützung für HACS Panel und Ressourcen
- 🌍 **66 Sprachen** - Alle Home Assistant Übersetzungen integriert
- 🏠 **Panel-Lokalisierung** - Korrekte Übersetzung aller Menüpunkte (Übersicht, etc.)
- 🔧 **Panel-Filterung** - Nur relevante Panels für EQcube Nutzer

### Technische Änderungen

| Version | Beschreibung                         |
| ------- | ------------------------------------ |
| eq16    | Android Companion App Logout Fix     |
| eq17    | Equicrew Branding Integration        |
| eq18    | HACS Resources Proxy                 |
| eq19    | Panel Filtering (default_visible)    |
| eq20    | nginx Frontend File Serving          |
| eq21    | Übersetzungen & Titel-Normalisierung |
| eq22    | Default Panel Lokalisierung          |
| eq23    | HACS Fallback Icon                   |

## Installation

### Docker Image

```bash
docker pull ghcr.io/behindvillager/eq-frontend:v1.0.0
```

### Als Home Assistant Add-on

Das eq-frontend Add-on ist im EQcube vorinstalliert und läuft auf Port 8099.

## Development

- Initial Setup: `script/setup`
- Development Server: `script/develop`
- Production Build: `script/build_frontend`
- Übersetzungen laden: `gulp fetch-nightly-translations` (benötigt GITHUB_TOKEN)

## Upstream

Dieses Projekt basiert auf dem [Home Assistant Frontend](https://github.com/home-assistant/frontend) und wird regelmäßig mit dem Upstream synchronisiert.

## Lizenz

Apache 2.0 License - basierend auf dem Home Assistant Projekt.

---

**EQcube** - Smart Home made in Germany 🇩🇪

[![Equicrew](https://equicrew.de/logo.png)](https://equicrew.de)
