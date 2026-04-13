# everything-claude-unity

**The ultimate Claude Code toolkit for Unity game development.**

A production-ready, plug-and-play system that gives Claude Code deep Unity expertise — from writing performant C# to building scenes, profiling performance, and triggering iOS/Android builds — all through natural language.

Built for **solo indie mobile game developers**. Drop it into any Unity project and it works.

---

## What You Get

| Component | Count | Purpose |
|-----------|-------|---------|
| **Agents** | 15 | Specialized sub-agents for coding, verification, scene building, profiling, testing |
| **Commands** | 17 | Slash commands like `/unity-workflow`, `/unity-prototype`, `/unity-doctor` |
| **Skills** | 35 | Knowledge modules for Unity systems, gameplay patterns, and mobile genres |
| **Hooks** | 20 | Safety net, quality gates, session persistence, cost tracking, auto-learning |
| **Rules** | 5 | C# coding standards, performance rules, MVS architecture patterns |
| **Scripts** | 8 | Validation tools for meta files, code quality, serialization, architecture |
| **Templates** | 10 | C# templates for MVS pattern (Model, View, System, LifetimeScope, Message) |

---

## Highlights

### `/unity-workflow` — Full Development Pipeline

A structured 4-phase pipeline for any feature: **Clarify** requirements, **Plan** the implementation, **Execute** with specialized agents, **Verify** with automated review + fix loop.

```
/unity-workflow "add a combo scoring system with multipliers and visual feedback"
```

### `/unity-prototype` — One Prompt to Playable

Describe a mechanic, and Claude writes the C# scripts, builds the scene via MCP, sets up physics layers, configures the camera, and verifies it compiles.

```
/unity-prototype "2D platformer with wall jumping and dash"
```

### Verify-Fix Loop

The `unity-verifier` agent automatically reviews your code changes, fixes safe issues (missing `[FormerlySerializedAs]`, uncached `GetComponent`, `?.` on Unity objects), and re-verifies — up to 3 iterations until clean. Built into `/unity-workflow` and available as an optional step in `/unity-feature` and `/unity-prototype`.

### Hook Profiles

Hooks are organized into three profiles. Set `UNITY_HOOK_PROFILE` to control which hooks run:

| Profile | What's Active | Best For |
|---------|--------------|----------|
| `minimal` | Safety hooks only (block scene/meta corruption, editor guards, pre-compact) | CI pipelines, experienced developers |
| `standard` | Safety + quality warnings + session persistence + stop validation (default) | Daily development |
| `strict` | Everything: GateGuard, cost tracking, auto-learning, build analysis | New projects, learning, auditing |

```bash
UNITY_HOOK_PROFILE=strict          # Enable all hooks including GateGuard
UNITY_HOOK_PROFILE=minimal         # Only critical safety hooks
DISABLE_UNITY_HOOKS=1              # Bypass all hooks entirely
UNITY_HOOK_MODE=warn               # Downgrade blocks to warnings
DISABLE_HOOK_BLOCK_SCENE_EDIT=1    # Disable a specific hook
```

---

## Quick Start

### Prerequisites
- [Claude Code](https://claude.ai/claude-code) installed
- Unity 2021.3 LTS or later
- [unity-mcp](https://github.com/CoplayDev/unity-mcp) (optional but recommended for full pipeline)

### Install

```bash
# From your Unity project root:
git clone https://github.com/XeldarAlz/everything-claude-unity.git /tmp/ecu
/tmp/ecu/install.sh --project-dir .
rm -rf /tmp/ecu
```

Or manually:
```bash
git clone https://github.com/XeldarAlz/everything-claude-unity.git
cp -r everything-claude-unity/.claude your-unity-project/.claude
chmod +x your-unity-project/.claude/hooks/*.sh
```

### Upgrade / Uninstall

```bash
# Upgrade to latest (preserves your customizations, creates backup)
./upgrade.sh --project-dir .

# Preview changes before upgrading
./upgrade.sh --project-dir . --dry-run

# Clean removal (with backup)
./uninstall.sh --project-dir .
```

### Setup Unity MCP (Recommended)

The MCP bridge gives Claude direct control over the Unity Editor — scene building, profiling, builds, and more.

1. In Unity: `Window > Package Manager > + > Add package from git URL`
2. Paste: `https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main`
3. Open `Window > MCP for Unity` and click **Start Server**
4. Claude Code auto-connects via `.claude/settings.json`

### First Run

```bash
cd your-unity-project
claude

# Verify installation:
/unity-doctor         # Check MCP, hooks, project structure

# Start working:
/unity-audit          # Full project health check
/unity-workflow       # Full pipeline: clarify → plan → execute → verify
/unity-prototype      # Rapid prototype a game mechanic
```

---

## Agents

### Code Agents
| Agent | Model | What It Does |
|-------|-------|-------------|
| `unity-coder` | opus | Implements features with Unity subsystem awareness, loads relevant skills |
| `unity-coder-lite` | sonnet | Lightweight variant for simple additions (fields, methods, straightforward components) |
| `unity-fixer` | opus | Diagnoses bugs using Unity-specific patterns (missing refs, execution order, coroutine lifecycle) |
| `unity-fixer-lite` | sonnet | Quick fixes for obvious issues (typos, missing imports, simple errors) |
| `unity-reviewer` | sonnet | Code review checking serialization safety, GC in hot paths, lifecycle ordering |
| `unity-shader-dev` | opus | HLSL/ShaderGraph development optimized for mobile GPUs, live testing via MCP |

### Orchestration Agents
| Agent | Model | What It Does |
|-------|-------|-------------|
| `unity-verifier` | opus | Verify-fix loop: reviews changes, auto-fixes safe issues, re-verifies (max 3 iterations) |
| `unity-prototyper` | opus | End-to-end prototyping: writes code + builds scene + physics + camera |

### MCP-Powered Agents
| Agent | Model | What It Does | Key MCP Tools |
|-------|-------|-------------|---------------|
| `unity-scene-builder` | opus | Builds scenes from descriptions | `manage_scene`, `batch_execute` |
| `unity-test-runner` | sonnet | Writes + runs tests, reports results | `run_tests`, `read_console` |
| `unity-build-runner` | sonnet | Configures and triggers builds | `manage_build`, `manage_packages` |
| `unity-optimizer` | opus | Profiles and fixes performance issues | `manage_profiler`, `manage_graphics` |

### Hybrid Agents
| Agent | Model | What It Does |
|-------|-------|-------------|
| `unity-ui-builder` | opus | Builds UI screens with code + visual setup via MCP |
| `unity-network-dev` | opus | Implements multiplayer with Netcode/Mirror/Photon/Fish-Net |
| `unity-migrator` | sonnet | Unity version and render pipeline migration |

Commands support `--quick` (routes to sonnet lite agent) and `--thorough` (routes to opus) flags. See [docs/MODEL-ROUTING.md](docs/MODEL-ROUTING.md) for the full routing table.

---

## Commands

### Full Pipeline
```
/unity-workflow <description>   Clarify → Plan → Execute → Verify (the recommended workflow)
```

### Daily Workflow
```
/unity-feature <description>    Plan + implement a feature (--quick for simple tasks)
/unity-fix <bug or error>       Diagnose and fix a bug (--quick for obvious fixes)
/unity-prototype <mechanic>     One prompt to playable prototype
/unity-scene <description>      Build a scene via MCP
/unity-shader <description>     Create shaders with live preview
/unity-ui <screen description>  Build UI with visual setup
/unity-network <framework>      Set up multiplayer
```

### Quality Gates
```
/unity-review [scope]           Code review (--thorough for deep analysis)
/unity-optimize                 Profile via MCP + fix bottlenecks
/unity-test                     Write + run tests via MCP
/unity-audit                    Full project health check
/unity-profile                  Deep profiling session
```

### Project Lifecycle
```
/unity-init                     Scan project + generate CLAUDE.md
/unity-build                    Configure + trigger builds
/unity-migrate                  Plan version/pipeline migration
/unity-doctor                   Diagnostic health check (MCP, hooks, project structure)
```

---

## Hooks

20 hooks across 5 lifecycle events, organized by profile level.

### Blocking Hooks — PreToolUse (minimal profile)
| Hook | What It Prevents |
|------|-----------------|
| `block-scene-edit` | Direct text editing of .unity/.prefab YAML (corrupts references) |
| `block-meta-edit` | Editing .meta files (breaks asset GUIDs) |
| `block-projectsettings` | Staging ProjectSettings/ via git (use MCP instead) |
| `guard-editor-runtime` | `UnityEditor` namespace in runtime code without `#if UNITY_EDITOR` |

### GateGuard — PreToolUse (strict profile)
| Hook | What It Does |
|------|-------------|
| `gateguard` | Blocks Edit/Write on C# files until the agent has Read them first. Prevents hallucinated changes. For MVS files, suggests reading Model/System counterparts. |

### Quality Hooks — PostToolUse (standard profile)
| Hook | What It Catches |
|------|----------------|
| `warn-serialization` | Field renamed without `[FormerlySerializedAs]` (silent data loss) |
| `warn-filename` | C# file name doesn't match class name (script won't attach) |
| `warn-platform-defines` | `#if UNITY_ANDROID` without `#else` fallback |
| `quality-gate` | GetComponent in Update, LINQ in gameplay, `?.` on Unity objects, uncached Camera.main, SendMessage |
| `validate-commit` | Missing .meta files, code quality issues on commit |
| `suggest-verify` | Suggests `/unity-review` after 5+ C# files modified |
| `build-analyze` | Post-build: shader variant counts, size, stripping issues, deprecated APIs |

### Tracking Hooks — PostToolUse (standard/strict profile)
| Hook | What It Records |
|------|----------------|
| `track-edits` | Files modified during session (standard) |
| `track-reads` | Files read during session — feeds GateGuard (strict) |
| `cost-tracker` | Every tool call with timestamp for session metrics (strict) |

### Session Hooks — SessionStart / Stop
| Hook | Lifecycle | What It Does |
|------|-----------|-------------|
| `session-restore` | SessionStart | Restores prior branch, workflow phase, modified files list |
| `session-save` | Stop | Saves session state for next conversation (branch, edits, duration) |
| `stop-validate` | Stop | Runs full-file validation on all C# files modified during session |
| `auto-learn` | Stop | Captures session patterns (MVS breakdown, tool usage) to learnings log |

### Advisory Hooks — PreCompact
| Hook | What It Does |
|------|-------------|
| `pre-compact` | Saves git state before context compaction |

All hooks support kill switches via environment variables. See [Hook Profiles](#hook-profiles) above.

---

## MVS Architecture Templates

Templates for the **Model-View-System** pattern with VContainer, MessagePipe, and UniTask:

| Template | Purpose |
|----------|---------|
| `Model.cs.template` | Pure C# data class with `ReactiveProperty<T>` — no Unity dependencies |
| `System.cs.template` | Plain C# class with VContainer constructor injection, `IDisposable` |
| `View.cs.template` | MonoBehaviour observing Model via `Subscribe()`, method injection |
| `LifetimeScope.cs.template` | VContainer composition root with Model/System/View/MessagePipe registration |
| `Message.cs.template` | `readonly struct` for MessagePipe — zero heap allocation |

Plus the original templates: `MonoBehaviour.cs`, `ScriptableObject.cs`, `EditModeTest.cs`, `PlayModeTest.cs`, `AssemblyDefinition.asmdef`.

---

## Skills

### Always-On Core (6)
- **serialization-safety** — `[FormerlySerializedAs]`, `[SerializeField]`, Unity null checks
- **scriptable-objects** — SO event channels, variable refs, runtime sets, factory pattern
- **event-systems** — C# events, UnityEvent, SO channels, zero-alloc EventBus
- **object-pooling** — `ObjectPool<T>`, warm-up, return-to-pool lifecycle
- **assembly-definitions** — When to split, reference rules, Editor/Runtime separation
- **unity-mcp-patterns** — How to use MCP tools effectively (`batch_execute`, `read_console`)

### Unity Systems (10)
URP pipeline, Input System, Addressables, Cinemachine, Animation, Audio, Physics, NavMesh, UI Toolkit, ShaderGraph

### Gameplay Patterns (6)
Character controller (2D/3D), inventory system, dialogue system, save system, state machine, procedural generation

### Genre Blueprints (8) — Mobile-Focused
Hyper-casual, Match-3, Idle/Clicker, Endless Runner, Puzzle, RPG, 2D Platformer, Top-down

### Third-Party (5)
DOTween, UniTask, VContainer, TextMeshPro, Odin Inspector

### Platform (1)
Mobile optimization (iOS + Android) — touch input, safe areas, ASTC textures, thermal throttling, battery management

---

## Coding Rules

The toolkit enforces Unity best practices through 5 always-loaded rule files:

- **csharp-unity** — `[SerializeField] private` with `m_` prefix, sealed by default, explicit types
- **performance** — Zero-alloc Update, cache GetComponent, pool objects, no LINQ in gameplay
- **serialization** — `[FormerlySerializedAs]` on renames, `obj == null` not `obj?.`
- **architecture** — MVS pattern, VContainer for DI, MessagePipe for events, UniTask for async
- **unity-specifics** — Editor/Runtime separation, threading, coroutine lifecycle, `?.` danger

---

## Validation Scripts

Run these to check project health:

```bash
./scripts/validate-meta-integrity.sh --all    # Missing/orphaned .meta files, duplicate GUIDs
./scripts/validate-code-quality.sh            # Performance pitfalls in C# code
./scripts/validate-asmdefs.sh                 # Circular assembly definition dependencies
./scripts/detect-missing-refs.sh              # Broken references in scenes/prefabs
./scripts/analyze-build-size.sh               # Build size analysis from Editor.log
./scripts/validate-serialization.sh           # Field renames missing FormerlySerializedAs
./scripts/validate-architecture.sh            # MVS pattern compliance checks
./scripts/generate-claude-md.sh > CLAUDE.md   # Auto-generate project CLAUDE.md
```

---

## Example CLAUDE.md Files

Pre-built configurations for mobile game types:

- `examples/CLAUDE.md.hyper-casual` — One-tap controls, minimal visuals, ad monetization
- `examples/CLAUDE.md.match3` — Grid system, cascades, special tiles, lives/energy
- `examples/CLAUDE.md.idle-clicker` — Big numbers, offline progress, prestige system
- `examples/CLAUDE.md.mobile-casual` — Touch input, small build, ad integration
- `examples/CLAUDE.md.2d-platformer` — Tilemap, virtual joystick, mobile-optimized
- `examples/CLAUDE.md.rpg` — Stats, inventory, dialogue, touch controls

---

## Architecture

### Workflow Pipeline

```
/unity-workflow "add combo scoring"
    │
    ├─ Phase 1: Clarify   ── interview about requirements, constraints, platform
    ├─ Phase 2: Plan      ── scan project, choose agents, present implementation plan
    ├─ Phase 3: Execute   ── route to unity-coder / unity-prototyper / unity-ui-builder
    └─ Phase 4: Verify    ── unity-verifier runs review → auto-fix → re-verify loop
```

### Agent Interaction

```
User prompt
    │
    ▼
Command (orchestrates the workflow)
    │
    ├──▶ Code Agent (writes C# scripts, loads relevant skills)
    │       │
    │       └──▶ MCP Tools (creates GameObjects, configures components)
    │
    ├──▶ Verifier Agent (reviews changes, auto-fixes, re-verifies)
    │
    ├──▶ Test Agent (writes + runs tests via MCP)
    │
    └──▶ Optimizer Agent (profiles via MCP, fixes bottlenecks)
```

### Hook Safety Net

```
Claude attempts to edit PlayerView.cs
    │
    ├──▶ _lib.sh: check profile level, kill switches
    ├──▶ PreToolUse: guard-editor-runtime.sh — UnityEditor guard
    ├──▶ PreToolUse: gateguard.sh — was this file Read first? [strict]
    │                               suggest reading PlayerModel.cs too
    │
    ├──▶ [Edit happens]
    │
    ├──▶ PostToolUse: warn-serialization.sh — field rename check
    │                  quality-gate.sh — GetComponent in Update? LINQ? ?.?
    │                  track-edits.sh — record for session metrics
    │
    └──▶ [Session ends]
         ├──▶ stop-validate.sh — full-file checks on all modified C#
         ├──▶ session-save.sh — persist state for next conversation
         └──▶ auto-learn.sh — log session patterns
```

### Session Lifecycle

```
SessionStart
    └──▶ session-restore.sh — load prior state (branch, phase, files)

[... work happens, tracked by hooks ...]

Stop
    ├──▶ stop-validate.sh — batch validation on all modified files
    ├──▶ session-save.sh — save state to /tmp/unity-claude-hooks/
    └──▶ auto-learn.sh — append session metrics to learnings.jsonl
```

---

## Documentation

| Guide | Purpose |
|-------|---------|
| [Getting Started](docs/GETTING-STARTED.md) | Installation, first run, troubleshooting |
| [Architecture](docs/ARCHITECTURE.md) | Design philosophy, component overview, hook system, workflow pipeline |
| [Agent Guide](docs/AGENT-GUIDE.md) | All 15 agents, when to use each, customization |
| [Model Routing](docs/MODEL-ROUTING.md) | Agent model assignments, `--quick`/`--thorough` flags, cost trade-offs |
| [MCP Setup](docs/MCP-SETUP.md) | unity-mcp installation, verification, troubleshooting |

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Key areas where contributions are welcome:
- New mobile genre skills (tower defense, racing, card/gacha, simulation)
- New system skills (ProBuilder, Spline, 2D Animation)
- Mobile platform skills (ARKit/ARCore, notifications, deep links)
- Networking framework skills for mobile (FishNet, Dark Rift)
- Bug reports and hook improvements

---

## License

MIT License. See [LICENSE](LICENSE) for details.
