# EQ Cube Merge Workflow Documentation

## Übersicht

Dieser Guide erklärt, wie du neue Home Assistant Releases in dein eq cube Fork mergst, ohne deine Anpassungen zu verlieren.

## Branch-Struktur

- **ha-master**: Tracked offizielle HA stable releases (nur stable tags wie 2024.12.0)
- **eq-dev**: Development branch mit eq cube Anpassungen
- **eq-main**: Production branch für stable eq cube releases

## Deine EQ Cube Anpassungen

Basis-Commit (letzter HA code): `ccc48d158` (tag: 20251105.1)

### Deine 5 Custom Commits:

```
8b0c3068c - Replace all Home Assistant links with equicrew.com
098a5f938 - Replace launch screen logos with eq branding  
ffadf7473 - Update logo to eq with green accent color (#38CE7F)
e175fc1c1 - Change default theme colors to green (#23935E primary, #38CE7F accent)
2945d33a2 - Rebrand from Home Assistant/Crush Assistant to eq cube
```

### Geänderte Dateien (33 files total):

**Branding:**
- `src/components/ha-logo-svg.ts` - eq Logo SVG
- `public/static/icons/*` - Alle Favicons (192x192, 512x512, etc.)
- `landing-page/public/static/icons/*` - Landing page icons

**Theme/Farben:**
- `src/resources/theme/color/color.globals.ts` - Green theme (#23935E, #38CE7F)
- `src/resources/theme/color/core.globals.ts` - Core color definitions
- `src/components/ha-theme-picker.ts` - Theme picker
- `src/panels/profile/ha-pick-theme-row.ts` - Theme selection

**Links/Documentation:**
- `src/util/documentation-url.ts` - Alle Links zu equicrew.com
- `src/auth/ha-auth-flow.ts` - Auth flow links
- `src/auth/ha-authorize.ts` - Authorization links
- `src/onboarding/*.ts` - Onboarding links
- `src/layouts/supervisor-error-screen.ts` - Error screen links
- `landing-page/src/ha-landing-page.ts` - Landing page links

**About Page:**
- `src/panels/config/info/ha-config-info.ts` - Logo link, OHF → equicrew, installation method

**Translations:**
- `src/translations/en.json` - "eq cube" statt "Home Assistant"
- `src/translations/en.json.backup` - Backup der originalen Übersetzungen

**HTML Templates:**
- `src/html/*.template` - index, authorize, onboarding
- `landing-page/src/html/index.html.template`

**Sidebar:**
- `src/components/ha-sidebar.ts` - eq cube title
- `src/state/panel-title-mixin.ts` - Panel titles

## Merge Workflow

### Vorbereitung: Anpassungen identifizieren

```bash
# Zeige alle deine eq Anpassungen
./script/show-eq-changes.sh

# Detaillierte Änderungen in einer Datei
git diff ccc48d158 HEAD -- src/components/ha-logo-svg.ts

# Alle Änderungen als Patch speichern (Backup!)
git diff ccc48d158 HEAD > eq-customizations-backup.patch
```

### Wenn neues HA Stable Release kommt (z.B. 2024.12.0)

```bash
# Automatischer Merge (empfohlen)
./script/merge-ha-stable.sh 2024.12.0
```

### Oder Manueller Merge:

#### 1. ha-master updaten

```bash
cd /workspaces/ha-master
git fetch upstream tag 2024.12.0
git merge 2024.12.0 --no-edit
git push origin ha-master
```

#### 2. In eq-dev mergen

```bash
cd /workspaces/frontend
git checkout eq-dev
git pull origin eq-dev

# Backup erstellen
git branch eq-dev-backup-$(date +%Y%m%d)

# Merge durchführen
git fetch ../ha-master ha-master:ha-master-temp
git merge ha-master-temp
```

#### 3. Konflikte lösen

Wenn Konflikte auftreten, zeigt Git die betroffenen Dateien:

```bash
git status  # Zeigt Dateien mit Konflikten
```

**Konflikt-Marker im Code:**
```
<<<<<<< HEAD (dein eq-dev)
// Deine eq cube Anpassung
const color = "#23935E";
=======
// Neuer HA Code  
const color = "#03a9f4";
>>>>>>> ha-master-temp
```

**Wie lösen:**
1. Öffne die Datei
2. Suche `<<<<<<<` Marker
3. **Behalte IMMER deine eq Anpassungen** (der Teil bei `HEAD`)
4. Lösche die Konflikt-Marker
5. Speichern

```bash
# Nach dem Editieren
git add <gelöste-datei>
git merge --continue
```

**Wichtig:** Bei diesen Dateien IMMER deine eq Version behalten:
- `src/components/ha-logo-svg.ts` (eq Logo!)
- `src/resources/theme/color/*.ts` (green theme!)
- `src/util/documentation-url.ts` (equicrew links!)
- `src/translations/en.json` (eq cube text!)

#### 4. Testen

```bash
# Development Server starten
script/develop

# Prüfen ob alle eq Anpassungen noch da sind
./script/show-eq-changes.sh

# Besonders testen:
# - eq Logo wird angezeigt
# - Green theme funktioniert
# - Links gehen zu equicrew.com
# - About page zeigt "eq cube" und equicrew
```

#### 5. Build und Release

```bash
# Production build
script/build_frontend

# Auf GitHub pushen
git push origin eq-dev

# Tag erstellen
git tag v1.1.0-alpha
git push origin v1.1.0-alpha

# Wenn alles stabil: merge zu eq-main
git checkout eq-main
git merge eq-dev
git push origin eq-main
```

## Konflikt-Resolution Cheatsheet

### Deine Version behalten (Standard für eq Files)
```bash
git checkout --ours <file>  # Behalte eq-dev Version
git add <file>
```

### HA Version nehmen (nur für neue Features die du willst)
```bash
git checkout --theirs <file>  # Nehme ha-master Version
git add <file>
```

### Beide mergen (manuell)
```bash
# Datei öffnen, Konflikte per Hand lösen
code <file>
git add <file>
```

## Hilfsbefehle

```bash
# Zeige was sich in HA seit deinem letzten Merge geändert hat
git log eq-dev..ha-master-temp --oneline

# Vergleiche bestimmte Datei
git diff eq-dev ha-master-temp -- <file>

# Merge abbrechen und von vorne
git merge --abort

# Zu Backup zurück
git reset --hard eq-dev-backup-20241208
```

## Tipps

1. **Immer Backup erstellen** vor dem Merge
2. **Patch-File erstellen** von deinen Anpassungen: `git diff ccc48d158 HEAD > backup.patch`
3. **Kleine Merges bevorzugen**: Nicht zu lange warten mit Updates
4. **Test everything**: Nach Merge ausgiebig testen
5. **Bei Unsicherheit**: Erst in Test-Branch mergen

## Troubleshooting

### "Ich habe aus Versehen eq Anpassungen überschrieben!"

```bash
# Zurück zum Backup
git reset --hard eq-dev-backup-20241208

# Oder spezifische Datei wiederherstellen
git checkout eq-dev-backup-20241208 -- <file>
```

### "Merge hat zu viele Konflikte"

```bash
# Abbrechen
git merge --abort

# Cherry-pick nur bestimmte HA commits die du willst
git cherry-pick <commit-hash>
```

### "Wie sehe ich was HA geändert hat vs. meine Änderungen?"

```bash
# Zeige HA Änderungen (ohne deine)
git diff ccc48d158 ha-master-temp

# Zeige deine eq Änderungen
git diff ccc48d158 eq-dev

# Zeige Unterschied zwischen beiden
git diff eq-dev ha-master-temp
```
