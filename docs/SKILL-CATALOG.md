# Skill Catalog

One-page reference for all skills in everything-claude-unity.

---

## Overview

41 skills organized into 6 categories. Skills are loaded on-demand based on file glob patterns or loaded always if `alwaysApply: true`. Each skill is a Markdown file at `.claude/skills/<category>/<name>/SKILL.md` with YAML frontmatter.

---

## Always-Loaded Skills

These skills have `alwaysApply: true` and are loaded for every agent, every session. They contain critical knowledge that should never be skipped.

| Skill | Description |
|-------|-------------|
| `serialization-safety` | Unity serialization rules -- FormerlySerializedAs on renames, SerializeField vs public, SerializeReference for polymorphism, Unity null check (`== null` not `?.`). Prevents silent data loss. |
| `unity-mcp-patterns` | How to use unity-mcp tools effectively -- `batch_execute` for speed, `read_console` for verification, resource queries for project state. |
| `model-routing` | Heuristics for choosing the right model tier (haiku/sonnet/opus) when delegating to agents. Loaded by orchestrating commands. |
| `assembly-definitions` | Assembly definition management -- when to create asmdefs, reference rules, Editor/Runtime/Test separation, platform filters, compilation speed optimization. |
| `commit-trailers` | Structured commit trailers -- adds Constraint, Rejected, Scope-risk, and Not-tested metadata to commit messages. |
| `deep-interview` | Ambiguity gating -- detects vague feature requests and forces structured requirements gathering. Prevents wasted cycles on underspecified tasks. |
| `event-systems` | Event system patterns -- C# events, UnityEvent, SO event channels, static EventBus. When to use each, zero-allocation patterns. |
| `object-pooling` | Object pooling patterns -- Unity `ObjectPool<T>`, custom ComponentPool, warm-up strategies, return-to-pool lifecycle. |
| `scriptable-objects` | ScriptableObject architecture patterns -- event channels, variable references, runtime sets, factory pattern, data containers. |
| `mobile` | Mobile optimization -- tile-based GPU, ASTC textures, draw call budget (<100), thermal throttling, battery, touch input, safe areas. |

---

## Core Skills

Fundamentals loaded across many contexts.

| Skill | Description | Glob Patterns |
|-------|-------------|---------------|
| `assembly-definitions` | Assembly definition management, reference rules, Editor/Runtime/Test separation | Always loaded |
| `commit-trailers` | Structured commit trailers with architectural decision metadata | Always loaded |
| `deep-interview` | Ambiguity gating and structured requirements gathering | Always loaded |
| `event-systems` | Event system patterns -- C# events, UnityEvent, SO channels | Always loaded |
| `hud-statusline` | Configures Claude Code's statusline to display Unity workflow state | On demand |
| `learner` | Post-debugging knowledge extraction -- captures codebase-specific learnings | On demand |
| `model-routing` | Heuristics for choosing haiku/sonnet/opus model tier | Always loaded |
| `object-pooling` | Object pooling patterns -- Unity ObjectPool<T>, custom pools | Always loaded |
| `scriptable-objects` | ScriptableObject architecture -- event channels, runtime sets, factories | Always loaded |
| `serialization-safety` | FormerlySerializedAs, Unity null checks, SerializeReference | Always loaded |
| `unity-mcp-patterns` | batch_execute, read_console, resource query patterns | Always loaded |

---

## Gameplay Skills

Game system implementations loaded by file glob matching.

| Skill | Description | Glob Patterns |
|-------|-------------|---------------|
| `character-controller` | 2D/3D character controllers -- coyote time, input buffering, variable jump, wall slide, dash, slopes | `**/Player*.cs`, `**/Character*.cs`, `**/Movement*.cs`, `**/Controller*.cs` |
| `dialogue-system` | Dialogue tree patterns -- SO graph, node types, typewriter effect, localization-ready | `**/Dialogue*.cs`, `**/Conversation*.cs`, `**/NPC*.cs` |
| `inventory-system` | Inventory, equipment, crafting -- SO item definitions, slot-based inventory, UI binding | `**/Inventory*.cs`, `**/Item*.cs`, `**/Equipment*.cs`, `**/Craft*.cs` |
| `procedural-generation` | Perlin/Simplex noise, BSP dungeons, random walk, loot tables, wave function collapse | `**/Procedural*.cs`, `**/Generate*.cs`, `**/Dungeon*.cs`, `**/Noise*.cs`, `**/Loot*.cs` |
| `save-system` | Save/load patterns -- ISaveable interface, JSON serialization, scene persistence, cloud sync | `**/Save*.cs`, `**/Load*.cs`, `**/Persist*.cs`, `**/Serializ*.cs` |
| `state-machine` | Generic state machine -- IState interface, StateMachine<T>, game states, enemy AI, hierarchical FSM | `**/State*.cs`, `**/FSM*.cs`, `**/*Machine*.cs` |

---

## Genre Skills

Genre-specific architecture and patterns loaded by file glob matching.

| Skill | Description | Glob Patterns |
|-------|-------------|---------------|
| `endless-runner` | Procedural chunk spawning, lane-based movement, obstacle patterns, speed ramping, distance scoring | `**/Runner*.cs`, `**/Endless*.cs`, `**/Chunk*.cs`, `**/Obstacle*.cs`, `**/Lane*.cs` |
| `hyper-casual` | One-tap/swipe controls, instant onboarding, short sessions, ad monetization, minimalist visuals | `**/HyperCasual*.cs`, `**/Level*.cs`, `**/GameManager*.cs` |
| `idle-clicker` | Big number math, offline progress, prestige/rebirth, upgrade trees, automation, currency systems | `**/Idle*.cs`, `**/Clicker*.cs`, `**/Currency*.cs`, `**/Upgrade*.cs`, `**/Prestige*.cs` |
| `match3` | Grid system, tile matching, cascade/gravity, special tiles, combo chains, level objectives | `**/Match*.cs`, `**/Grid*.cs`, `**/Tile*.cs`, `**/Board*.cs`, `**/Puzzle*.cs` |
| `platformer-2d` | Tight controls, level design patterns, collectibles, checkpoints, hazards, boss patterns | `**/Platform*.cs`, `**/Player*.cs`, `**/Level*.cs` |
| `puzzle` | Grid/board logic, undo system, hint system, level packs, star ratings, touch drag-and-drop | `**/Puzzle*.cs`, `**/Board*.cs`, `**/Grid*.cs`, `**/Hint*.cs`, `**/Undo*.cs` |
| `rpg` | Stat system (base + modifiers), level/XP, skill trees, quest system, turn-based and real-time combat | `**/RPG*.cs`, `**/Stat*.cs`, `**/Quest*.cs`, `**/Skill*.cs`, `**/Level*.cs` |
| `topdown` | Virtual joystick/tap-to-move/twin-stick, room transitions, fog of war, spawner patterns, wave systems | `**/TopDown*.cs`, `**/Room*.cs`, `**/Wave*.cs`, `**/Spawn*.cs` |

---

## Platform Skills

Platform-specific optimization and configuration.

| Skill | Description | Glob Patterns |
|-------|-------------|---------------|
| `mobile` | Mobile optimization -- tile-based GPU, ASTC textures, draw call budget, thermal throttling, touch input, safe areas | Always loaded (`**/*.cs`) |

---

## Systems Skills

Unity subsystem knowledge loaded by file glob matching.

| Skill | Description | Glob Patterns |
|-------|-------------|---------------|
| `addressables` | Addressables asset loading -- LoadAssetAsync, handle lifecycle, labels, remote catalogs, memory management | `**/Addressable*.cs`, `**/*Address*` |
| `animation` | Animator controllers, layers, blend trees, state machine behaviors, root motion, animation events, Timeline | `**/*.controller`, `**/*Anim*.cs`, `**/*.anim` |
| `audio` | AudioMixer groups, snapshots, spatial audio, audio source pooling, compression per platform | `**/*.mixer`, `**/*Audio*.cs`, `**/*Sound*.cs`, `**/*Music*.cs` |
| `cinemachine` | Virtual cameras, FreeLook, blending, noise profiles, state-driven cameras, confiner | `**/*Cinemachine*`, `**/*Camera*.cs`, `**/*Cam*.cs` |
| `input-system` | New Input System -- action maps, PlayerInput, generated C# classes, runtime rebinding, multi-device | `**/*.inputactions`, `**/Input*.cs`, `**/PlayerInput*` |
| `navmesh` | NavMeshAgent configuration, NavMeshSurface, off-mesh links, dynamic obstacles, pathfinding | `**/*Nav*.cs`, `**/*Pathfind*.cs`, `**/*Agent*.cs` |
| `physics` | Non-allocating queries, collision layers, FixedUpdate discipline, continuous collision detection, joints | `**/*Physics*.cs`, `**/*Collider*.cs`, `**/*Rigidbody*.cs`, `**/*Trigger*.cs` |
| `shader-graph` | Custom function nodes, sub-graphs, keyword-driven variants, master stack outputs, URP effects | `**/*.shadergraph`, `**/*.shadersubgraph` |
| `ui-toolkit` | UXML document structure, USS styling, UQuery, data binding, ListView virtualization, custom elements | `**/*.uxml`, `**/*.uss`, `**/UIDocument*` |
| `urp-pipeline` | URP asset configuration, renderer features, 2D renderer, lighting, shadows, post-processing, SRP Batcher | `**/URP*.asset`, `**/*Renderer*.asset`, `**/*Volume*.cs` |

---

## Third-Party Skills

Integration patterns for popular Unity packages.

| Skill | Description | Glob Patterns |
|-------|-------------|---------------|
| `dotween` | DOTween animation library -- sequence composition, tween lifecycle, easing, kill strategies. Always kill tweens in OnDestroy. | `**/DOTween*`, `**/*Tween*.cs`, `**/*Animation*.cs` |
| `odin-inspector` | Odin Inspector and Serializer -- SerializedMonoBehaviour, validation attributes, custom drawers, editor windows | `**/Odin*`, `**/Sirenix*`, `**/*Inspector*.cs` |
| `textmeshpro` | TextMeshPro -- font asset creation, material presets, rich text tags, dynamic font fallback, sprite assets | `**/TMP_*.cs`, `**/TextMesh*.cs`, `**/*Text*.cs`, `**/*.asset` |
| `unitask` | UniTask zero-allocation async/await -- cancellation tokens, PlayerLoop integration, async LINQ. Replaces coroutines. | `**/UniTask*`, `**/*Async*.cs`, `**/Cysharp*` |
| `vcontainer` | VContainer DI -- LifetimeScope hierarchy, registration patterns, constructor injection, `[Inject]` for MonoBehaviours | `**/VContainer*`, `**/*LifetimeScope*.cs`, `**/*Installer*.cs`, `**/Container*.cs` |

---

## How Skills Are Loaded

1. **Always-apply skills** (`alwaysApply: true`) are loaded for every agent in every session.
2. **Glob-matched skills** are loaded when the agent works with files matching the skill's `globs` patterns.
3. **Agent-referenced skills** can be explicitly loaded by agents or commands that reference them by name.

Skills are additive -- multiple skills can be loaded simultaneously. They do not conflict because each covers a distinct domain.

---

## Creating a New Skill

Create a new directory and `SKILL.md` file:

```
.claude/skills/<category>/<skill-name>/SKILL.md
```

Frontmatter:

```yaml
---
name: skill-name
description: "When to load this skill -- be specific about the use case"
alwaysApply: false
globs: ["**/Pattern*.cs", "**/Match*.cs"]
---
```

The Markdown body contains the skill's knowledge: patterns, code examples, rules, and anti-patterns. Keep skills focused on one domain. If a skill grows beyond 200 lines, consider splitting it.
