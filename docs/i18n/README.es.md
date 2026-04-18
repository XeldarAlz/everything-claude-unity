[English](../../README.md) | [日本語](README.ja.md) | [中文](README.zh-CN.md) | [한국어](README.ko.md) | **Español** | [Português](README.pt-BR.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | [Türkçe](README.tr.md)

<!-- last-synced-version: 1.2.0 -->

# everything-claude-unity

**El kit de herramientas definitivo de Claude Code para el desarrollo de juegos con Unity.**

Un sistema listo para produccion, plug-and-play, que otorga a Claude Code un profundo conocimiento de Unity: desde escribir C# de alto rendimiento hasta construir escenas, analizar rendimiento y ejecutar builds para iOS/Android, todo mediante lenguaje natural.

Creado para **desarrolladores indie de juegos moviles en solitario**. Colocalo en cualquier proyecto Unity y funciona.

---

## Lo que obtienes

| Componente | Cantidad | Proposito |
|-----------|-------|---------|
| **Agents** | 18 | Sub-agentes especializados para programacion, verificacion, construccion de escenas, profiling y testing |
| **Commands** | 22 | Comandos slash como `/unity-workflow`, `/unity-ralph`, `/unity-team` |
| **Skills** | 41 | Modulos de conocimiento sobre sistemas de Unity, patrones de gameplay y generos moviles |
| **Hooks** | 24 | Red de seguridad, quality gates, persistencia de sesion, auto-aprendizaje |
| **Rules** | 5 | Estandares de codigo C#, reglas de rendimiento, patrones de arquitectura MVS |
| **Scripts** | 8 | Herramientas de validacion para archivos meta, calidad de codigo, serializacion y arquitectura |
| **Templates** | 10 | Plantillas C# para el patron MVS (Model, View, System, LifetimeScope, Message) |
| **Tests** | 46 | Suite de tests automatizados para hooks, utilidades de lib e instalacion |

---

## Destacados

### `/unity-workflow` — Pipeline de desarrollo completo

Un pipeline estructurado de 4 fases para cualquier funcionalidad: **Clarificar** requisitos, **Planificar** la implementacion, **Ejecutar** con agentes especializados, **Verificar** con revision automatica + bucle de correccion.

```
/unity-workflow "add a combo scoring system with multipliers and visual feedback"
```

### `/unity-prototype` — De un prompt a jugable

Describe una mecanica y Claude escribe los scripts C#, construye la escena via MCP, configura las capas de fisica, ajusta la camara y verifica que compile.

```
/unity-prototype "2D platformer with wall jumping and dash"
```

### `/unity-ralph` — Bucle persistente de verificacion y correccion

Ejecuta el bucle de verificacion-correccion de forma persistente: se niega a detenerse hasta que el proyecto este limpio o alcance el limite de seguridad. Hasta 30 pasadas de verificacion efectivas con deteccion de estancamiento.

```
/unity-ralph --max-iterations 10
```

### `/unity-team` — Orquestacion paralela de agentes

Lanza multiples agentes simultaneamente: coder + tester + reviewer trabajando en paralelo para un desarrollo mas rapido.

```
/unity-team --build "add health system with damage and healing"
```

### Bucle de verificacion y correccion

El agente `unity-verifier` revisa automaticamente los cambios de codigo, corrige problemas seguros (`[FormerlySerializedAs]` faltante, `GetComponent` sin cachear, `?.` en objetos Unity) y re-verifica, hasta 3 iteraciones hasta quedar limpio. Integrado en `/unity-workflow` y disponible como paso opcional en `/unity-feature` y `/unity-prototype`.

### Perfiles de hooks

Los hooks estan organizados en tres perfiles. Configura `UNITY_HOOK_PROFILE` para controlar cuales se ejecutan:

| Perfil | Que esta activo | Mejor para |
|---------|--------------|----------|
| `minimal` | Solo hooks de seguridad (bloquear corrupcion de escena/meta, guardas de editor, pre-compact) | Pipelines CI, desarrolladores experimentados |
| `standard` | Seguridad + advertencias de calidad + persistencia de sesion + validacion al detener (por defecto) | Desarrollo diario |
| `strict` | Todo: GateGuard, seguimiento de costos, auto-aprendizaje, analisis de builds | Proyectos nuevos, aprendizaje, auditorias |

```bash
UNITY_HOOK_PROFILE=strict          # Habilitar todos los hooks incluyendo GateGuard
UNITY_HOOK_PROFILE=minimal         # Solo hooks criticos de seguridad
DISABLE_UNITY_HOOKS=1              # Desactivar todos los hooks por completo
UNITY_HOOK_MODE=warn               # Degradar bloqueos a advertencias
DISABLE_HOOK_BLOCK_SCENE_EDIT=1    # Desactivar un hook especifico
```

---

## Inicio rapido

### Requisitos previos
- [Claude Code](https://claude.ai/claude-code) instalado
- Unity 2021.3 LTS o posterior
- [unity-mcp](https://github.com/CoplayDev/unity-mcp) (opcional pero recomendado para el pipeline completo)

### Instalacion

```bash
# Desde la raiz de tu proyecto Unity:
git clone https://github.com/XeldarAlz/everything-claude-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

O manualmente:
```bash
git clone https://github.com/XeldarAlz/everything-claude-unity.git
cp -r everything-claude-unity/.claude your-unity-project/.claude
chmod +x your-unity-project/.claude/hooks/*.sh
```

### Actualizar / Desinstalar

```bash
# Actualizar a la ultima version (preserva tus personalizaciones, crea backup)
./upgrade.sh --project-dir .

# Previsualizar cambios antes de actualizar
./upgrade.sh --project-dir . --dry-run

# Desinstalacion limpia (con backup)
./uninstall.sh --project-dir .
```

### Configurar Unity MCP (Recomendado)

El puente MCP otorga a Claude control directo sobre el Editor de Unity: construccion de escenas, profiling, builds y mas.

1. En Unity: `Window > Package Manager > + > Add package from git URL`
2. Pegar: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. Abrir `Window > MCP for Unity` y hacer clic en **Start Server**
4. Claude Code se conecta automaticamente via `.claude/settings.json`

### Primera ejecucion

```bash
cd your-unity-project
claude

# Verificar la instalacion:
/unity-doctor         # Comprobar MCP, hooks, estructura del proyecto

# Empezar a trabajar:
/unity-audit          # Revision completa de salud del proyecto
/unity-workflow       # Pipeline completo: clarificar -> planificar -> ejecutar -> verificar
/unity-prototype      # Prototipado rapido de una mecanica de juego
```

---

## Agentes

### Agentes de codigo
| Agente | Modelo | Que hace |
|-------|-------|-------------|
| `unity-coder` | opus | Implementa funcionalidades con conocimiento de subsistemas Unity, carga skills relevantes |
| `unity-coder-lite` | sonnet | Variante ligera para adiciones simples (campos, metodos, componentes sencillos) |
| `unity-fixer` | opus | Diagnostica bugs usando patrones especificos de Unity (referencias faltantes, orden de ejecucion, ciclo de vida de coroutines) |
| `unity-fixer-lite` | sonnet | Correcciones rapidas para problemas obvios (typos, imports faltantes, errores simples) |
| `unity-reviewer` | sonnet | Revision de codigo verificando seguridad de serializacion, GC en rutas criticas, orden de ciclo de vida |
| `unity-shader-dev` | opus | Desarrollo HLSL/ShaderGraph optimizado para GPUs moviles, testing en vivo via MCP |

### Agentes de orquestacion
| Agente | Modelo | Que hace |
|-------|-------|-------------|
| `unity-verifier` | opus | Bucle de verificacion-correccion: revisa cambios, auto-corrige problemas seguros, re-verifica (max 3 iteraciones) |
| `unity-prototyper` | opus | Prototipado de extremo a extremo: escribe codigo + construye escena + fisica + camara |

### Agentes con MCP
| Agente | Modelo | Que hace | Herramientas MCP clave |
|-------|-------|-------------|---------------|
| `unity-scene-builder` | opus | Construye escenas a partir de descripciones | `manage_scene`, `batch_execute` |
| `unity-test-runner` | sonnet | Escribe + ejecuta tests, reporta resultados | `run_tests`, `read_console` |
| `unity-build-runner` | sonnet | Configura y ejecuta builds | `manage_build`, `manage_packages` |
| `unity-optimizer` | opus | Analiza y corrige problemas de rendimiento | `manage_profiler`, `manage_graphics` |

### Agentes hibridos
| Agente | Modelo | Que hace |
|-------|-------|-------------|
| `unity-ui-builder` | opus | Construye pantallas UI con codigo + configuracion visual via MCP |
| `unity-network-dev` | opus | Implementa multijugador con Netcode/Mirror/Photon/Fish-Net |
| `unity-migrator` | sonnet | Migracion de version de Unity y render pipeline |

Los comandos soportan flags `--quick` (dirige al agente sonnet lite) y `--thorough` (dirige a opus). Consulta [docs/MODEL-ROUTING.md](docs/MODEL-ROUTING.md) para la tabla completa de enrutamiento.

---

## Comandos

### Pipeline completo
```
/unity-workflow <descripcion>   Clarificar -> Planificar -> Ejecutar -> Verificar (flujo recomendado)
```

### Flujo de trabajo diario
```
/unity-feature <descripcion>    Planificar + implementar una funcionalidad (--quick para tareas simples)
/unity-fix <bug o error>        Diagnosticar y corregir un bug (--quick para correcciones obvias)
/unity-prototype <mecanica>     De un prompt a prototipo jugable
/unity-scene <descripcion>      Construir una escena via MCP
/unity-shader <descripcion>     Crear shaders con previsualizacion en vivo
/unity-ui <descripcion pantalla>  Construir UI con configuracion visual
/unity-network <framework>      Configurar multijugador
```

### Quality gates
```
/unity-review [alcance]         Revision de codigo (--thorough para analisis profundo)
/unity-optimize                 Profiling via MCP + corregir cuellos de botella
/unity-test                     Escribir + ejecutar tests via MCP
/unity-audit                    Revision completa de salud del proyecto
/unity-profile                  Sesion de profiling profundo
```

### Orquestacion
```
/unity-ralph [opciones]         Bucle persistente de verificacion-correccion (no para hasta quedar limpio)
/unity-team <--preset|--custom> Agentes en paralelo (coder + tester + reviewer simultaneamente)
/unity-interview <tema>         Entrevista socratica profunda de requisitos antes de programar
/unity-learn [subcomando]       Analitica de sesion: revisar, extraer patrones, redactar skills
```

### Ciclo de vida del proyecto
```
/unity-init                     Escanear proyecto + generar CLAUDE.md
/unity-build                    Configurar + ejecutar builds
/unity-migrate                  Planificar migracion de version/pipeline
/unity-doctor                   Revision de diagnostico (MCP, hooks, estructura del proyecto)
```

---

## Hooks

22 hooks en 5 eventos de ciclo de vida, organizados por nivel de perfil.

### Hooks de bloqueo — PreToolUse (perfil minimal)
| Hook | Que previene |
|------|-----------------|
| `block-scene-edit` | Edicion directa de texto en YAML .unity/.prefab (corrompe referencias) |
| `block-meta-edit` | Edicion de archivos .meta (rompe GUIDs de assets) |
| `block-projectsettings` | Staging de ProjectSettings/ via git (usar MCP en su lugar) |
| `guard-editor-runtime` | Namespace `UnityEditor` en codigo runtime sin `#if UNITY_EDITOR` |
| `guard-project-config` | Debilitamiento de reglas de calidad de codigo (.editorconfig, configuracion de analyzers, .csproj NoWarn) |

### GateGuard — PreToolUse (perfil strict)
| Hook | Que hace |
|------|-------------|
| `gateguard` | Bloquea Edit/Write en archivos C# hasta que el agente los haya leido (Read) primero. Previene cambios alucinados. Para archivos MVS, sugiere leer las contrapartes Model/System. |

### Hooks de calidad — PostToolUse (perfil standard)
| Hook | Que detecta |
|------|----------------|
| `warn-serialization` | Campo renombrado sin `[FormerlySerializedAs]` (perdida silenciosa de datos) |
| `warn-filename` | Nombre de archivo C# no coincide con nombre de clase (el script no se adjunta) |
| `warn-platform-defines` | `#if UNITY_ANDROID` sin fallback `#else` |
| `quality-gate` | GetComponent en Update, LINQ en gameplay, `?.` en objetos Unity, Camera.main sin cachear, SendMessage |
| `validate-commit` | Archivos .meta faltantes, problemas de calidad de codigo al hacer commit |
| `suggest-verify` | Sugiere `/unity-review` despues de modificar 5+ archivos C# |
| `build-analyze` | Post-build: conteo de variantes de shader, tamano, problemas de stripping, APIs obsoletas |

### Hooks de seguimiento — PostToolUse (perfil standard/strict)
| Hook | Que registra |
|------|----------------|
| `track-edits` | Archivos modificados durante la sesion (standard) |
| `track-reads` | Archivos leidos durante la sesion — alimenta GateGuard (strict) |
| `cost-tracker` | Cada llamada a herramienta con timestamp para metricas de sesion (strict) |

### Hooks de sesion — SessionStart / Stop
| Hook | Ciclo de vida | Que hace |
|------|-----------|-------------|
| `session-restore` | SessionStart | Restaura la rama anterior, fase de workflow, lista de archivos modificados |
| `session-save` | Stop | Guarda el estado de sesion para la siguiente conversacion (rama, ediciones, duracion) |
| `stop-validate` | Stop | Ejecuta validacion completa en todos los archivos C# modificados durante la sesion |
| `auto-learn` | Stop | Captura patrones de sesion (desglose MVS, uso de herramientas, categoria) en el log de aprendizaje |
| `notify` | Stop | Envia notificacion por webhook (Discord/Slack) cuando la sesion excede la duracion minima |

### Hooks de aviso — PreCompact
| Hook | Que hace |
|------|-------------|
| `pre-compact` | Guarda el estado de git antes de la compactacion de contexto |

Todos los hooks soportan interruptores de desactivacion via variables de entorno. Consulta [Perfiles de hooks](#perfiles-de-hooks) mas arriba.

---

## Plantillas de arquitectura MVS

Plantillas para el patron **Model-View-System** con VContainer, MessagePipe y UniTask:

| Plantilla | Proposito |
|----------|---------|
| `Model.cs.template` | Clase C# pura de datos con `ReactiveProperty<T>` — sin dependencias de Unity |
| `System.cs.template` | Clase C# pura con inyeccion de constructor VContainer, `IDisposable` |
| `View.cs.template` | MonoBehaviour que observa el Model via `Subscribe()`, inyeccion de metodo |
| `LifetimeScope.cs.template` | Raiz de composicion VContainer con registro de Model/System/View/MessagePipe |
| `Message.cs.template` | `readonly struct` para MessagePipe — cero allocacion en heap |

Ademas de las plantillas originales: `MonoBehaviour.cs`, `ScriptableObject.cs`, `EditModeTest.cs`, `PlayModeTest.cs`, `AssemblyDefinition.asmdef`.

---

## Skills

### Core siempre activo (8)
- **serialization-safety** — `[FormerlySerializedAs]`, `[SerializeField]`, verificaciones de null en Unity
- **scriptable-objects** — Canales de eventos SO, referencias de variables, runtime sets, patron factory
- **event-systems** — Eventos C#, UnityEvent, canales SO, EventBus sin allocaciones
- **object-pooling** — `ObjectPool<T>`, precalentamiento, ciclo de vida de retorno al pool
- **assembly-definitions** — Cuando separar, reglas de referencia, separacion Editor/Runtime
- **unity-mcp-patterns** — Como usar las herramientas MCP eficazmente (`batch_execute`, `read_console`)
- **learner** — Extraccion de conocimiento post-depuracion con quality gates y puntuacion de confianza
- **hud-statusline** — Integracion con la linea de estado de Claude Code mostrando fase de workflow y metricas de sesion

### Sistemas de Unity (10)
URP pipeline, Input System, Addressables, Cinemachine, Animation, Audio, Physics, NavMesh, UI Toolkit, ShaderGraph

### Patrones de gameplay (6)
Controlador de personaje (2D/3D), sistema de inventario, sistema de dialogo, sistema de guardado, maquina de estados, generacion procedural

### Blueprints de genero (8) — Enfocados en movil
Hyper-casual, Match-3, Idle/Clicker, Endless Runner, Puzzle, RPG, 2D Platformer, Top-down

### Terceros (5)
DOTween, UniTask, VContainer, TextMeshPro, Odin Inspector

### Plataforma (1)
Optimizacion movil (iOS + Android) — entrada tactil, areas seguras, texturas ASTC, thermal throttling, gestion de bateria

---

## Reglas de programacion

El toolkit aplica las mejores practicas de Unity a traves de 5 archivos de reglas siempre cargados:

- **csharp-unity** — `[SerializeField] private` con prefijo `_lowerCamelCase`, sealed por defecto, tipos explicitos
- **performance** — Cero allocaciones en Update, cachear GetComponent, pool de objetos, sin LINQ en gameplay
- **serialization** — `[FormerlySerializedAs]` al renombrar, `obj == null` en vez de `obj?.`
- **architecture** — Patron MVS, VContainer para DI, MessagePipe para eventos, UniTask para async
- **unity-specifics** — Separacion Editor/Runtime, threading, ciclo de vida de coroutines, peligro de `?.`

---

## Scripts de validacion

Ejecuta estos para verificar la salud del proyecto:

```bash
./scripts/validate-meta-integrity.sh --all    # Archivos .meta faltantes/huerfanos, GUIDs duplicados
./scripts/validate-code-quality.sh            # Problemas de rendimiento en codigo C#
./scripts/validate-asmdefs.sh                 # Dependencias circulares en assembly definitions
./scripts/detect-missing-refs.sh              # Referencias rotas en escenas/prefabs
./scripts/analyze-build-size.sh               # Analisis de tamano de build desde Editor.log
./scripts/validate-serialization.sh           # Campos renombrados sin FormerlySerializedAs
./scripts/validate-architecture.sh            # Verificaciones de cumplimiento del patron MVS
./scripts/generate-claude-md.sh > CLAUDE.md   # Auto-generar CLAUDE.md del proyecto
```

---

## Archivos CLAUDE.md de ejemplo

Configuraciones pre-construidas para tipos de juegos moviles:

- `examples/CLAUDE.md.hyper-casual` — Controles de un toque, visuales minimos, monetizacion con anuncios
- `examples/CLAUDE.md.match3` — Sistema de cuadricula, cascadas, tiles especiales, vidas/energia
- `examples/CLAUDE.md.idle-clicker` — Numeros grandes, progreso offline, sistema de prestigio
- `examples/CLAUDE.md.mobile-casual` — Entrada tactil, build pequeno, integracion de anuncios
- `examples/CLAUDE.md.2d-platformer` — Tilemap, joystick virtual, optimizado para movil
- `examples/CLAUDE.md.rpg` — Estadisticas, inventario, dialogos, controles tactiles

---

## Arquitectura

### Pipeline de workflow

```
/unity-workflow "add combo scoring"
    |
    +-- Phase 1: Clarify   -- Entrevista sobre requisitos, restricciones, plataforma
    +-- Phase 2: Plan      -- Escanear proyecto, elegir agentes, presentar plan de implementacion
    +-- Phase 3: Execute   -- Enrutar a unity-coder / unity-prototyper / unity-ui-builder
    +-- Phase 4: Verify    -- unity-verifier ejecuta revision -> auto-correccion -> re-verificacion
```

### Interaccion entre agentes

```
Prompt del usuario
    |
    v
Command (orquesta el workflow)
    |
    +-->  Code Agent (escribe scripts C#, carga skills relevantes)
    |       |
    |       +--> MCP Tools (crea GameObjects, configura componentes)
    |
    +-->  Verifier Agent (revisa cambios, auto-corrige, re-verifica)
    |
    +-->  Test Agent (escribe + ejecuta tests via MCP)
    |
    +-->  Optimizer Agent (profiling via MCP, corrige cuellos de botella)
```

### Red de seguridad de hooks

```
Claude intenta editar PlayerView.cs
    |
    +-->  _lib.sh: verificar nivel de perfil, interruptores de desactivacion
    +-->  PreToolUse: guard-editor-runtime.sh -- Guarda de UnityEditor
    +-->  PreToolUse: gateguard.sh -- se leyo este archivo primero? [strict]
    |                               sugiere leer tambien PlayerModel.cs
    |
    +-->  [La edicion ocurre]
    |
    +-->  PostToolUse: warn-serialization.sh -- verificacion de renombrado de campo
    |                  quality-gate.sh -- GetComponent en Update? LINQ? ?.?
    |                  track-edits.sh -- registrar para metricas de sesion
    |
    +-->  [La sesion termina]
         +-->  stop-validate.sh -- verificacion completa de todos los C# modificados
         +-->  session-save.sh -- persistir estado para la siguiente conversacion
         +-->  auto-learn.sh -- registrar patrones de sesion
```

### Ciclo de vida de la sesion

```
SessionStart
    +-->  session-restore.sh -- cargar estado anterior (rama, fase, archivos)

[... trabajo en curso, rastreado por hooks ...]

Stop
    +-->  stop-validate.sh -- validacion por lotes de todos los archivos modificados
    +-->  session-save.sh -- guardar estado en /tmp/unity-claude-hooks/
    +-->  auto-learn.sh -- agregar metricas de sesion a learnings.jsonl
```

---

## Documentacion

| Guia | Proposito |
|-------|---------|
| [Getting Started](docs/GETTING-STARTED.md) | Instalacion, primera ejecucion, solucion de problemas |
| [Architecture](docs/ARCHITECTURE.md) | Filosofia de diseno, vision general de componentes, sistema de hooks, pipeline de workflow |
| [Agent Guide](docs/AGENT-GUIDE.md) | Los 18 agentes, cuando usar cada uno, personalizacion |
| [Model Routing](docs/MODEL-ROUTING.md) | Asignacion de modelos a agentes, flags `--quick`/`--thorough`, trade-offs de costo |
| [MCP Setup](docs/MCP-SETUP.md) | Instalacion de unity-mcp, verificacion, solucion de problemas |

---

## Contribuir

Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para las guias.

Areas clave donde las contribuciones son bienvenidas:
- Nuevos skills de generos moviles (tower defense, carreras, cartas/gacha, simulacion)
- Nuevos skills de sistemas (ProBuilder, Spline, 2D Animation)
- Skills de plataforma movil (ARKit/ARCore, notificaciones, deep links)
- Skills de frameworks de networking para movil (FishNet, Dark Rift)
- Reportes de bugs y mejoras de hooks

---

## Licencia

MIT License. Consulta [LICENSE](LICENSE) para mas detalles.
