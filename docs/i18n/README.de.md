[English](../../README.md) | [日本語](README.ja.md) | [中文](README.zh-CN.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Português](README.pt-BR.md) | **Deutsch** | [Français](README.fr.md) | [Türkçe](README.tr.md)

<!-- last-synced-version: 1.2.0 -->

# everything-claude-unity

**Das ultimative Claude Code Toolkit fuer Unity-Spieleentwicklung.**

Ein produktionsreifes Plug-and-Play-System, das Claude Code tiefgreifendes Unity-Fachwissen verleiht: vom Schreiben performanten C#-Codes ueber Szenenbau, Performance-Analyse bis hin zum Ausloesen von iOS/Android-Builds -- alles per natuerlicher Sprache.

Entwickelt fuer **Solo-Indie-Mobilspiel-Entwickler**. Einfach in ein beliebiges Unity-Projekt einsetzen und es funktioniert.

---

## Was du bekommst

| Komponente | Anzahl | Zweck |
|-----------|-------|---------|
| **Agents** | 18 | Spezialisierte Sub-Agenten fuer Programmierung, Verifikation, Szenenbau, Profiling und Tests |
| **Commands** | 22 | Slash-Befehle wie `/unity-workflow`, `/unity-ralph`, `/unity-team` |
| **Skills** | 41 | Wissensmodule fuer Unity-Systeme, Gameplay-Muster und Mobile-Genres |
| **Hooks** | 24 | Sicherheitsnetz, Quality Gates, Session-Persistenz, Auto-Learning |
| **Rules** | 5 | C#-Programmierstandards, Performance-Regeln, MVS-Architekturmuster |
| **Scripts** | 8 | Validierungstools fuer Meta-Dateien, Codequalitaet, Serialisierung und Architektur |
| **Templates** | 10 | C#-Vorlagen fuer das MVS-Muster (Model, View, System, LifetimeScope, Message) |
| **Tests** | 46 | Automatisierte Test-Suite fuer Hooks, Lib-Utilities und Installation |

---

## Highlights

### `/unity-workflow` — Vollstaendige Entwicklungs-Pipeline

Eine strukturierte 4-Phasen-Pipeline fuer jedes Feature: Anforderungen **klaeren (Clarify)**, Implementierung **planen (Plan)**, mit spezialisierten Agenten **ausfuehren (Execute)**, mit automatischem Review + Korrekturschleife **verifizieren (Verify)**.

```
/unity-workflow "add a combo scoring system with multipliers and visual feedback"
```

### `/unity-prototype` — Von einem Prompt zum spielbaren Prototyp

Beschreibe eine Mechanik und Claude schreibt die C#-Skripte, baut die Szene per MCP, richtet Physik-Layer ein, konfiguriert die Kamera und prueft die Kompilierung.

```
/unity-prototype "2D platformer with wall jumping and dash"
```

### `/unity-ralph` — Persistente Verifikations-Korrektur-Schleife

Fuehrt die Verifikations-Korrektur-Schleife persistent aus -- weigert sich aufzuhoeren, bis das Projekt sauber ist oder das Sicherheitslimit erreicht wird. Bis zu 30 effektive Verifikationsdurchlaeufe mit Stillstandserkennung.

```
/unity-ralph --max-iterations 10
```

### `/unity-team` — Parallele Agenten-Orchestrierung

Starte mehrere Agenten gleichzeitig -- Coder + Tester + Reviewer arbeiten parallel fuer schnellere Entwicklung.

```
/unity-team --build "add health system with damage and healing"
```

### Verifikations-Korrektur-Schleife

Der `unity-verifier`-Agent ueberprueft automatisch Codeaenderungen, behebt sichere Probleme (fehlendes `[FormerlySerializedAs]`, nicht gecachtes `GetComponent`, `?.` bei Unity-Objekten) und re-verifiziert -- bis zu 3 Iterationen, bis alles sauber ist. Eingebaut in `/unity-workflow` und als optionaler Schritt in `/unity-feature` und `/unity-prototype` verfuegbar.

### Hook-Profile

Hooks sind in drei Profile organisiert. Setze `UNITY_HOOK_PROFILE`, um zu steuern, welche Hooks ausgefuehrt werden:

| Profil | Was aktiv ist | Am besten fuer |
|---------|--------------|----------|
| `minimal` | Nur Sicherheits-Hooks (Szenen-/Meta-Korruption blockieren, Editor-Guards, Pre-Compact) | CI-Pipelines, erfahrene Entwickler |
| `standard` | Sicherheit + Qualitaetswarnungen + Session-Persistenz + Stop-Validierung (Standard) | Taegliche Entwicklung |
| `strict` | Alles: GateGuard, Kosten-Tracking, Auto-Learning, Build-Analyse | Neue Projekte, Lernen, Auditing |

```bash
UNITY_HOOK_PROFILE=strict          # Alle Hooks aktivieren, einschliesslich GateGuard
UNITY_HOOK_PROFILE=minimal         # Nur kritische Sicherheits-Hooks
DISABLE_UNITY_HOOKS=1              # Alle Hooks vollstaendig umgehen
UNITY_HOOK_MODE=warn               # Blockierungen zu Warnungen herabstufen
DISABLE_HOOK_BLOCK_SCENE_EDIT=1    # Einen bestimmten Hook deaktivieren
```

---

## Schnellstart

### Voraussetzungen
- [Claude Code](https://claude.ai/claude-code) installiert
- Unity 2021.3 LTS oder neuer
- [unity-mcp](https://github.com/CoplayDev/unity-mcp) (optional, aber empfohlen fuer die vollstaendige Pipeline)

### Installation

```bash
# Vom Stammverzeichnis deines Unity-Projekts:
git clone https://github.com/XeldarAlz/everything-claude-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

Oder manuell:
```bash
git clone https://github.com/XeldarAlz/everything-claude-unity.git
cp -r everything-claude-unity/.claude your-unity-project/.claude
chmod +x your-unity-project/.claude/hooks/*.sh
```

### Aktualisieren / Deinstallieren

```bash
# Auf die neueste Version aktualisieren (bewahrt Anpassungen, erstellt Backup)
./upgrade.sh --project-dir .

# Aenderungen vor dem Upgrade vorab ansehen
./upgrade.sh --project-dir . --dry-run

# Saubere Deinstallation (mit Backup)
./uninstall.sh --project-dir .
```

### Unity MCP einrichten (Empfohlen)

Die MCP-Bruecke gibt Claude direkte Kontrolle ueber den Unity Editor -- Szenenbau, Profiling, Builds und mehr.

1. In Unity: `Window > Package Manager > + > Add package from git URL`
2. Einfuegen: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. `Window > MCP for Unity` oeffnen und **Start Server** klicken
4. Claude Code verbindet sich automatisch ueber `.claude/settings.json`

### Erster Start

```bash
cd your-unity-project
claude

# Installation ueberpruefen:
/unity-doctor         # MCP, Hooks, Projektstruktur pruefen

# Loslegen:
/unity-audit          # Vollstaendiger Projekt-Gesundheitscheck
/unity-workflow       # Vollstaendige Pipeline: Klaeren -> Planen -> Ausfuehren -> Verifizieren
/unity-prototype      # Schnelles Prototyping einer Spielmechanik
```

---

## Agenten

### Code-Agenten
| Agent | Modell | Was er tut |
|-------|-------|-------------|
| `unity-coder` | opus | Implementiert Features mit Unity-Subsystem-Bewusstsein, laedt relevante Skills |
| `unity-coder-lite` | sonnet | Leichtgewichtige Variante fuer einfache Ergaenzungen (Felder, Methoden, unkomplizierte Komponenten) |
| `unity-fixer` | opus | Diagnostiziert Bugs anhand Unity-spezifischer Muster (fehlende Referenzen, Ausfuehrungsreihenfolge, Coroutine-Lebenszyklus) |
| `unity-fixer-lite` | sonnet | Schnelle Fixes fuer offensichtliche Probleme (Tippfehler, fehlende Imports, einfache Fehler) |
| `unity-reviewer` | sonnet | Code-Review: Serialisierungssicherheit, GC in Hot Paths, Lebenszyklus-Reihenfolge |
| `unity-shader-dev` | opus | HLSL/ShaderGraph-Entwicklung optimiert fuer mobile GPUs, Live-Tests per MCP |

### Orchestrierungs-Agenten
| Agent | Modell | Was er tut |
|-------|-------|-------------|
| `unity-verifier` | opus | Verifikations-Korrektur-Schleife: prueft Aenderungen, behebt sichere Probleme automatisch, re-verifiziert (max. 3 Iterationen) |
| `unity-prototyper` | opus | End-to-End-Prototyping: schreibt Code + baut Szene + Physik + Kamera |

### MCP-gestuetzte Agenten
| Agent | Modell | Was er tut | Wichtige MCP-Tools |
|-------|-------|-------------|---------------|
| `unity-scene-builder` | opus | Baut Szenen nach Beschreibungen | `manage_scene`, `batch_execute` |
| `unity-test-runner` | sonnet | Schreibt + fuehrt Tests aus, berichtet Ergebnisse | `run_tests`, `read_console` |
| `unity-build-runner` | sonnet | Konfiguriert und loest Builds aus | `manage_build`, `manage_packages` |
| `unity-optimizer` | opus | Profiliert und behebt Performance-Probleme | `manage_profiler`, `manage_graphics` |

### Hybrid-Agenten
| Agent | Modell | Was er tut |
|-------|-------|-------------|
| `unity-ui-builder` | opus | Baut UI-Bildschirme mit Code + visuellem Setup per MCP |
| `unity-network-dev` | opus | Implementiert Multiplayer mit Netcode/Mirror/Photon/Fish-Net |
| `unity-migrator` | sonnet | Unity-Versions- und Render-Pipeline-Migration |

Befehle unterstuetzen `--quick` (leitet an Sonnet-Lite-Agent) und `--thorough` (leitet an Opus) Flags. Siehe [docs/MODEL-ROUTING.md](docs/MODEL-ROUTING.md) fuer die vollstaendige Routing-Tabelle.

---

## Befehle

### Vollstaendige Pipeline
```
/unity-workflow <Beschreibung>   Klaeren -> Planen -> Ausfuehren -> Verifizieren (empfohlener Workflow)
```

### Taeglicher Workflow
```
/unity-feature <Beschreibung>    Feature planen + implementieren (--quick fuer einfache Aufgaben)
/unity-fix <Bug oder Fehler>     Bug diagnostizieren und beheben (--quick fuer offensichtliche Fixes)
/unity-prototype <Mechanik>      Von einem Prompt zum spielbaren Prototyp
/unity-scene <Beschreibung>      Szene per MCP bauen
/unity-shader <Beschreibung>     Shader mit Live-Vorschau erstellen
/unity-ui <Bildschirmbeschreibung>  UI mit visuellem Setup bauen
/unity-network <Framework>       Multiplayer einrichten
```

### Quality Gates
```
/unity-review [Bereich]          Code-Review (--thorough fuer tiefgehende Analyse)
/unity-optimize                  Profiling per MCP + Engpaesse beheben
/unity-test                      Tests schreiben + per MCP ausfuehren
/unity-audit                     Vollstaendiger Projekt-Gesundheitscheck
/unity-profile                   Tiefgehende Profiling-Sitzung
```

### Orchestrierung
```
/unity-ralph [Optionen]          Persistente Verifikations-Korrektur-Schleife (stoppt nicht bis sauber)
/unity-team <--preset|--custom>  Parallele Agenten (Coder + Tester + Reviewer gleichzeitig)
/unity-interview <Thema>         Tiefgehende sokratische Anforderungsanalyse vor dem Programmieren
/unity-learn [Unterbefehl]       Session-Analytik: ueberpruefen, Muster extrahieren, Skills entwerfen
```

### Projektlebenszyklus
```
/unity-init                      Projekt scannen + CLAUDE.md generieren
/unity-build                     Builds konfigurieren + ausloesen
/unity-migrate                   Versions-/Pipeline-Migration planen
/unity-doctor                    Diagnose-Gesundheitscheck (MCP, Hooks, Projektstruktur)
```

---

## Hooks

24 Hooks ueber 5 Lebenszyklus-Events, organisiert nach Profilebene.

### Blockierende Hooks — PreToolUse (Profil minimal)
| Hook | Was er verhindert |
|------|-----------------|
| `block-scene-edit` | Direkte Textbearbeitung von .unity/.prefab-YAML (beschaedigt Referenzen) |
| `block-meta-edit` | Bearbeitung von .meta-Dateien (bricht Asset-GUIDs) |
| `block-projectsettings` | Staging von ProjectSettings/ per Git (stattdessen MCP verwenden) |
| `guard-editor-runtime` | `UnityEditor`-Namespace in Runtime-Code ohne `#if UNITY_EDITOR` |
| `guard-project-config` | Abschwaechung von Codequalitaetsregeln (.editorconfig, Analyzer-Einstellungen, .csproj NoWarn) |

### GateGuard — PreToolUse (Profil strict)
| Hook | Was er tut |
|------|-------------|
| `gateguard` | Blockiert Edit/Write auf C#-Dateien, bis der Agent sie zuerst gelesen (Read) hat. Verhindert halluzinierte Aenderungen. Bei MVS-Dateien schlaegt er vor, auch die Model/System-Gegenstuecke zu lesen. |

### Qualitaets-Hooks — PostToolUse (Profil standard)
| Hook | Was er erkennt |
|------|----------------|
| `warn-serialization` | Feld umbenannt ohne `[FormerlySerializedAs]` (stiller Datenverlust) |
| `warn-filename` | C#-Dateiname stimmt nicht mit Klassenname ueberein (Skript laesst sich nicht anfuegen) |
| `warn-platform-defines` | `#if UNITY_ANDROID` ohne `#else`-Fallback |
| `quality-gate` | GetComponent in Update, LINQ in Gameplay, `?.` bei Unity-Objekten, nicht gecachtes Camera.main, SendMessage |
| `validate-commit` | Fehlende .meta-Dateien, Codequalitaetsprobleme beim Commit |
| `suggest-verify` | Schlaegt `/unity-review` nach 5+ geaenderten C#-Dateien vor |
| `build-analyze` | Post-Build: Shader-Varianten-Anzahl, Groesse, Stripping-Probleme, veraltete APIs |

### Tracking-Hooks — PostToolUse (Profil standard/strict)
| Hook | Was er aufzeichnet |
|------|----------------|
| `track-edits` | Waehrend der Session geaenderte Dateien (standard) |
| `track-reads` | Waehrend der Session gelesene Dateien -- speist GateGuard (strict) |
| `cost-tracker` | Jeder Tool-Aufruf mit Zeitstempel fuer Session-Metriken (strict) |

### Session-Hooks — SessionStart / Stop
| Hook | Lebenszyklus | Was er tut |
|------|-----------|-------------|
| `session-restore` | SessionStart | Stellt vorherigen Branch, Workflow-Phase, Liste geaenderter Dateien wieder her |
| `session-save` | Stop | Speichert Session-Zustand fuer die naechste Konversation (Branch, Aenderungen, Dauer) |
| `stop-validate` | Stop | Fuehrt vollstaendige Validierung aller waehrend der Session geaenderten C#-Dateien durch |
| `auto-learn` | Stop | Erfasst Session-Muster (MVS-Aufteilung, Tool-Nutzung, Kategorie) im Learning-Log |
| `notify` | Stop | Sendet Webhook-Benachrichtigung (Discord/Slack) wenn die Session die Mindestdauer ueberschreitet |

### Hinweis-Hooks — PreCompact
| Hook | Was er tut |
|------|-------------|
| `pre-compact` | Speichert den Git-Zustand vor der Kontext-Kompaktierung |

Alle Hooks unterstuetzen Deaktivierungsschalter per Umgebungsvariablen. Siehe [Hook-Profile](#hook-profile) oben.

---

## MVS-Architektur-Vorlagen

Vorlagen fuer das **Model-View-System**-Muster mit VContainer, MessagePipe und UniTask:

| Vorlage | Zweck |
|----------|---------|
| `Model.cs.template` | Reine C#-Datenklasse mit `ReactiveProperty<T>` -- keine Unity-Abhaengigkeiten |
| `System.cs.template` | Reine C#-Klasse mit VContainer-Konstruktor-Injektion, `IDisposable` |
| `View.cs.template` | MonoBehaviour, das Model per `Subscribe()` beobachtet, Methoden-Injektion |
| `LifetimeScope.cs.template` | VContainer-Kompositionswurzel mit Model/System/View/MessagePipe-Registrierung |
| `Message.cs.template` | `readonly struct` fuer MessagePipe -- null Heap-Allokation |

Plus die Original-Vorlagen: `MonoBehaviour.cs`, `ScriptableObject.cs`, `EditModeTest.cs`, `PlayModeTest.cs`, `AssemblyDefinition.asmdef`.

---

## Skills

### Immer aktiver Kern (8)
- **serialization-safety** — `[FormerlySerializedAs]`, `[SerializeField]`, Unity-Null-Pruefungen
- **scriptable-objects** — SO-Event-Kanaele, Variablen-Referenzen, Runtime-Sets, Factory-Muster
- **event-systems** — C#-Events, UnityEvent, SO-Kanaele, allokationsfreier EventBus
- **object-pooling** — `ObjectPool<T>`, Vorwaermen, Rueckgabe-an-Pool-Lebenszyklus
- **assembly-definitions** — Wann aufteilen, Referenzregeln, Editor/Runtime-Trennung
- **unity-mcp-patterns** — Effektive Nutzung der MCP-Tools (`batch_execute`, `read_console`)
- **learner** — Post-Debugging-Wissensextraktion mit Quality Gates und Konfidenzbewertung
- **hud-statusline** — Claude Code Statuszeilen-Integration mit Workflow-Phase und Session-Metriken

### Unity-Systeme (10)
URP-Pipeline, Input System, Addressables, Cinemachine, Animation, Audio, Physics, NavMesh, UI Toolkit, ShaderGraph

### Gameplay-Muster (6)
Charaktersteuerung (2D/3D), Inventarsystem, Dialogsystem, Speichersystem, Zustandsmaschine, prozedurale Generierung

### Genre-Blueprints (8) — Mobilfokus
Hyper-Casual, Match-3, Idle/Clicker, Endless Runner, Puzzle, RPG, 2D-Platformer, Top-Down

### Drittanbieter (5)
DOTween, UniTask, VContainer, TextMeshPro, Odin Inspector

### Plattform (1)
Mobile Optimierung (iOS + Android) -- Touch-Eingabe, sichere Bereiche, ASTC-Texturen, Thermal Throttling, Akkuverwaltung

---

## Programmierregeln

Das Toolkit erzwingt Unity-Best-Practices durch 5 stets geladene Regeldateien:

- **csharp-unity** — `[SerializeField] private` mit `_lowerCamelCase`-Praefix, standardmaessig sealed, explizite Typen
- **performance** — Null Allokationen in Update, GetComponent cachen, Objekt-Pooling, kein LINQ in Gameplay
- **serialization** — `[FormerlySerializedAs]` bei Umbenennungen, `obj == null` statt `obj?.`
- **architecture** — MVS-Muster, VContainer fuer DI, MessagePipe fuer Events, UniTask fuer Async
- **unity-specifics** — Editor/Runtime-Trennung, Threading, Coroutine-Lebenszyklus, `?.`-Gefahr

---

## Validierungsskripte

Fuehre diese aus, um die Projektgesundheit zu pruefen:

```bash
./scripts/validate-meta-integrity.sh --all    # Fehlende/verwaiste .meta-Dateien, doppelte GUIDs
./scripts/validate-code-quality.sh            # Performance-Fallstricke in C#-Code
./scripts/validate-asmdefs.sh                 # Zirkulaere Assembly-Definition-Abhaengigkeiten
./scripts/detect-missing-refs.sh              # Defekte Referenzen in Szenen/Prefabs
./scripts/analyze-build-size.sh               # Build-Groessen-Analyse aus Editor.log
./scripts/validate-serialization.sh           # Feld-Umbenennungen ohne FormerlySerializedAs
./scripts/validate-architecture.sh            # MVS-Muster-Konformitaetspruefungen
./scripts/generate-claude-md.sh > CLAUDE.md   # Projekt-CLAUDE.md automatisch generieren
```

---

## Beispiel-CLAUDE.md-Dateien

Vorgefertigte Konfigurationen fuer Mobile-Spieltypen:

- `examples/CLAUDE.md.hyper-casual` — Ein-Finger-Steuerung, minimale Grafik, Werbe-Monetarisierung
- `examples/CLAUDE.md.match3` — Rastersystem, Kaskaden, Spezial-Tiles, Leben/Energie
- `examples/CLAUDE.md.idle-clicker` — Grosse Zahlen, Offline-Fortschritt, Prestige-System
- `examples/CLAUDE.md.mobile-casual` — Touch-Eingabe, kleiner Build, Werbe-Integration
- `examples/CLAUDE.md.2d-platformer` — Tilemap, virtueller Joystick, mobiloptimiert
- `examples/CLAUDE.md.rpg` — Werte, Inventar, Dialoge, Touch-Steuerung

---

## Architektur

### Workflow-Pipeline

```
/unity-workflow "add combo scoring"
    |
    +-- Phase 1: Clarify   -- Anforderungen, Einschraenkungen, Plattform besprechen
    +-- Phase 2: Plan      -- Projekt scannen, Agenten waehlen, Implementierungsplan praesentieren
    +-- Phase 3: Execute   -- An unity-coder / unity-prototyper / unity-ui-builder weiterleiten
    +-- Phase 4: Verify    -- unity-verifier fuehrt Review -> Auto-Fix -> Re-Verifikation aus
```

### Agenten-Interaktion

```
Benutzer-Prompt
    |
    v
Command (orchestriert den Workflow)
    |
    +-->  Code Agent (schreibt C#-Skripte, laedt relevante Skills)
    |       |
    |       +--> MCP Tools (erstellt GameObjects, konfiguriert Komponenten)
    |
    +-->  Verifier Agent (prueft Aenderungen, behebt automatisch, re-verifiziert)
    |
    +-->  Test Agent (schreibt + fuehrt Tests per MCP aus)
    |
    +-->  Optimizer Agent (Profiling per MCP, behebt Engpaesse)
```

### Hook-Sicherheitsnetz

```
Claude versucht PlayerView.cs zu bearbeiten
    |
    +-->  _lib.sh: Profilebene, Deaktivierungsschalter pruefen
    +-->  PreToolUse: guard-editor-runtime.sh -- UnityEditor-Guard
    +-->  PreToolUse: gateguard.sh -- Wurde diese Datei zuerst gelesen? [strict]
    |                               Schlaegt vor, auch PlayerModel.cs zu lesen
    |
    +-->  [Bearbeitung findet statt]
    |
    +-->  PostToolUse: warn-serialization.sh -- Feld-Umbenennungs-Pruefung
    |                  quality-gate.sh -- GetComponent in Update? LINQ? ?.?
    |                  track-edits.sh -- Fuer Session-Metriken aufzeichnen
    |
    +-->  [Session endet]
         +-->  stop-validate.sh -- Vollstaendige Pruefung aller geaenderten C#-Dateien
         +-->  session-save.sh -- Zustand fuer naechste Konversation speichern
         +-->  auto-learn.sh -- Session-Muster protokollieren
```

### Session-Lebenszyklus

```
SessionStart
    +-->  session-restore.sh -- Vorherigen Zustand laden (Branch, Phase, Dateien)

[... Arbeit geschieht, durch Hooks verfolgt ...]

Stop
    +-->  stop-validate.sh -- Batch-Validierung aller geaenderten Dateien
    +-->  session-save.sh -- Zustand in /tmp/unity-claude-hooks/ speichern
    +-->  auto-learn.sh -- Session-Metriken an learnings.jsonl anhaengen
```

---

## Dokumentation

| Anleitung | Zweck |
|-------|---------|
| [Getting Started](docs/GETTING-STARTED.md) | Installation, erster Start, Fehlerbehebung |
| [Architecture](docs/ARCHITECTURE.md) | Design-Philosophie, Komponenten-Uebersicht, Hook-System, Workflow-Pipeline |
| [Agent Guide](docs/AGENT-GUIDE.md) | Alle 18 Agenten, wann welchen verwenden, Anpassung |
| [Model Routing](docs/MODEL-ROUTING.md) | Agenten-Modell-Zuordnung, `--quick`/`--thorough`-Flags, Kosten-Abwaegungen |
| [MCP Setup](docs/MCP-SETUP.md) | unity-mcp-Installation, Verifikation, Fehlerbehebung |

---

## Mitwirken

Siehe [CONTRIBUTING.md](CONTRIBUTING.md) fuer Richtlinien.

Wichtige Bereiche, in denen Beitraege willkommen sind:
- Neue Mobile-Genre-Skills (Tower Defense, Racing, Karten/Gacha, Simulation)
- Neue System-Skills (ProBuilder, Spline, 2D Animation)
- Mobile-Plattform-Skills (ARKit/ARCore, Benachrichtigungen, Deep Links)
- Networking-Framework-Skills fuer Mobile (FishNet, Dark Rift)
- Fehlermeldungen und Hook-Verbesserungen

---

## Lizenz

MIT-Lizenz. Siehe [LICENSE](LICENSE) fuer Details.
