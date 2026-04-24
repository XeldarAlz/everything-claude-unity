# Changelog

All notable changes to everything-claude-unity will be documented in this file.

## [1.5.0] — 2026-04-24

### Changed

**Rules set re-synced from helm upstream**
- `architecture.md` — new "NO GameContext / ServiceLocator" anti-pattern
  section forbidding god-container injectables; new "Input System
  Architecture" section that establishes the `InputView` adapter as the
  sole owner of `PlayerControls`. Systems become input-agnostic and expose
  `SetMoveInput(Vector2)`, `Jump()`, `Attack()`-style methods.
- `performance.md` — new NON-NEGOTIABLE "Rendering & Draw Calls" section:
  mandatory sprite atlasing for 2D, material sharing via `sharedMaterial` /
  `MaterialPropertyBlock`, SRP Batcher + GPU Instancing guidance, UI canvas
  split by update frequency, overdraw/culling rules, architect-owned
  rendering strategy in the TDD, and a developer-action-items protocol for
  assets agents cannot create (atlases, material presets, LOD groups, etc.).
- `unity-specifics.md` — Input System section upgraded to NON-NEGOTIABLE.
  Mandates the generated `PlayerControls` C# class, strict Enable/Disable
  and subscribe/unsubscribe symmetry in OnEnable/OnDisable, continuous
  input reading in Update, and explicit action-map switching order.
- `serialization.md` — clarifying note on public field naming.

**Skill and agent examples aligned with the new rules**
- `skills/genre/platformer-2d` — controller exposes `SetMoveInput` /
  `OnJumpPressed` / `OnJumpReleased`; removes `Input.GetButtonDown`,
  `Input.GetButtonUp`, `Input.GetAxisRaw`.
- `skills/systems/physics` — FixedUpdate-discipline example shows
  `InputView` reading input in Update and forwarding to a System that
  caches the value and applies forces in FixedUpdate.
- `skills/gameplay/dialogue-system` — NPC interact trigger now uses an
  `OnInteractPressed` callback driven by `InputView`.
- `skills/gameplay/state-machine` — pause state exposes `OnPausePressed`
  instead of reading `Input.GetKeyDown(KeyCode.Escape)`.
- `skills/third-party/dotween` — material tween uses DOTween.To with a
  cached `MaterialPropertyBlock` instead of `renderer.material.DOColor`
  (which clones the material and breaks batching).
- `agents/unity-network-dev` — Netcode owner movement example consumes a
  cached Vector2 set by `InputView.SetMoveInput` rather than calling
  `Input.GetAxis` inside Update.

## [1.4.1] — 2026-04-24

### Fixed

**CI (shellcheck) — first green build since v1.2.x**
- New `.shellcheckrc` teaches shellcheck how to resolve the `${SCRIPT_DIR}/_lib.sh`
  source pattern (`external-sources=true`, `source-path=SCRIPTDIR`) and disables
  SC2034 globally because `HOOK_PROFILE_LEVEL` and the `UNITY_*` path variables
  are used via deliberate cross-file indirection shellcheck cannot see.
- `instinct-capture.sh` — replaced SC2254-flagged case pattern `.$FILE` with an
  explicit `if` check for the no-extension case.
- `instinct-distill.sh` — removed unused `DELTA` and `TOTAL` locals.
- `pre-compact.sh` — `grep ... | wc -l` → `grep -c ...`.
- `session-restore.sh` — `echo "$(date +%s)"` → `date +%s`.

## [1.4.0] — 2026-04-24

### Added

**Fact-Gate GateGuard (three-stage)**
- `gateguard.sh` upgraded from simple Read-before-Edit to DENY → FORCE → ALLOW
- First Edit/Write on a C# file now emits Unity-specific fact demands:
  - GUID-based scene/prefab reference check via `.meta` file grep
  - `[FormerlySerializedAs]` plan requirement when renaming serialized fields
  - Public-API caller audit across the Assets tree
  - Asmdef membership check for new files
  - Verbatim quote of the user's instruction
- Second attempt on the same file passes (trust-based unlock after agent presents facts)
- Existing MVS counterpart suggestion preserved

**Destructive Bash Gate**
- New `bash-gate.sh` (PreToolUse Bash) with two-stage DENY → ALLOW flow
- Unity-specific detection: `rm -rf Library/|Temp/|Logs/|obj/`, `.meta` deletion/mass-rename,
  `ProjectSettings/*.asset` direct mutation, `Packages/manifest.json` wipes, `PlayerPrefs.DeleteAll`
- Git safety: `git reset --hard`, `git clean -fdx`, `git push --force` (heightened message for protected branches)
- DB safety: `DROP TABLE`, `TRUNCATE`, `DROP DATABASE`
- Per-command-hash state so different destructive commands don't share unlock state

**Atomic Instinct Learning System**
- New `instinct-capture.sh` (PostToolUse, ~10ms) logs lightweight observations with path-tag classification (view/system/model/sobject/mono/editor/scene/prefab/asmdef)
- New `instinct-distill.sh` (Stop, heuristic, no LLM) extracts atomic instincts from observations using three heuristics: warning-hotspot by path tag, tool-sequence affinity, hook-specific recurrence
- Project-scoped by default (`.claude/state/instincts/project/<git-remote-hash>/`); global scope available via promotion
- Confidence scoring 0.3–0.9 with evidence-count-based progression
- New `/unity-instincts` command (status, list, evolve, promote, demote, export, import, clear)
- New meta-skill `.claude/skills/core/unity-instincts/` documenting the pipeline

**Session Management Commands**
- `/unity-sessions` — list saved session snapshots with branch, phase, age, file counts
- `/unity-session-save <label>` — snapshot the current session.json to `.claude/state/sessions/<label>.json`
- `/unity-session-resume <label>` — restore a named snapshot with branch-mismatch warnings and TTL respect

**Meta-Maintenance**
- `/unity-skill-stocktake` — read-only audit of all skills/agents/commands for duplicates, stale globs, never-referenced entries, broken frontmatter, and stale code references

**Hook Library**
- `_lib.sh` honors pre-set `UNITY_HOOK_STATE_DIR` for testability in isolation
- New helper `unity_project_hash()` — stable 12-char hash of git remote URL (or repo root fallback)
- New state paths `UNITY_INSTINCTS_DIR` and `UNITY_OBSERVATIONS_FILE`

### Hooks registered in settings.json
- PreToolUse/Bash: `bash-gate.sh`
- PostToolUse/all: `instinct-capture.sh`
- Stop: `instinct-distill.sh`

## [1.3.0] — 2026-04-18

### Added

**Structured State Management**
- Session state now persists in `.claude/state/` (project-local, git-ignored) instead of `/tmp/`
- Structured `session.json` schema with `schema_version`, `plan`, `verification`, and `agent_context` fields
- Configurable session TTL via `UNITY_SESSION_TTL_HOURS` environment variable (default: 4)
- New `_lib.sh` helpers: `unity_state_read()`, `unity_state_write()`, `unity_state_plan_update()`, `unity_track_warning()`
- State survives system reboots — no more lost session data

**Smart Model Routing**
- New always-loaded `model-routing` skill with complexity heuristics for automatic agent tier selection
- Complexity signals: file count, keywords, scope indicators, risk factors
- `/unity-workflow` Plan phase now evaluates complexity to choose agent tier automatically
- `/unity-team --quick` flag swaps opus agents for sonnet/haiku equivalents
- `/unity-team --security` preset (unity-security-reviewer + unity-reviewer + unity-linter)

**New Agents (5)**
- `unity-scout` (haiku) — fast read-only codebase exploration for scanning before delegation
- `unity-linter` (haiku) — quick validation pass against Unity rules without deep reasoning
- `unity-security-reviewer` (sonnet) — Unity-specific security audit (PlayerPrefs secrets, unencrypted saves, hardcoded keys, insecure network calls)
- `unity-git-master` (sonnet) — Unity-aware git operations (LFS, .meta hygiene, merge strategies, .gitattributes)
- `unity-critic` (opus) — challenges implementation plans before execution (integrated into /unity-workflow)

**New Commands (1)**
- `/unity-skillify` — generates new skills from accumulated session learnings with `--install` flag for auto-placement

**Benchmarking Infrastructure**
- `benchmarks/` directory with runner, evaluator, and scenario framework
- 4 benchmark scenarios: simple-component, serialization-rename, performance-review, multi-system-feature
- `run-benchmarks.sh` with `--compare` flag for version-to-version quality comparison
- Fixture C# files for reproducible evaluation

**Enhanced Learning Pipeline**
- `/unity-learn analytics` subcommand with session time analysis, agent usage, warning hotspots, file hotspots, trends
- `auto-learn.sh` now captures `warnings_fired` from quality-gate and other hooks
- `quality-gate.sh` tracks warnings via `unity_track_warning()` for session analytics
- `/unity-skillify` cross-references existing skills to avoid duplicates

**Notification System Upgrade**
- Multi-channel support via `UNITY_NOTIFY_CHANNELS` JSON env var
- Event types: `session_end`, `build_complete`, `verify_fail`, `cost_threshold`
- OS-native notifications (macOS osascript, Linux notify-send) via `UNITY_NOTIFY_NATIVE=1`
- Rate limiting per channel with configurable interval
- `stop-validate.sh` and `build-analyze.sh` emit notification events
- Backward compatible with existing `UNITY_NOTIFY_WEBHOOK_URL` config

**CI Pipeline Hardening**
- Settings-to-hooks cross-validation (every hook reference verified)
- Agent tool restriction validation (haiku/reviewer agents must be read-only)
- C# template syntax validation (balanced braces)
- Skill quality checks (examples, anti-pattern guidance)
- Benchmark scenario JSON validation
- 4 new test files: test-state, test-cross-validation, test-templates, test-skills

**Documentation**
- `docs/HOOK-REFERENCE.md` — comprehensive hook catalog with profiles, kill switches, env vars
- `docs/SKILL-CATALOG.md` — one-page overview of all 41 skills by category
- `docs/BENCHMARK-GUIDE.md` — how to run and create benchmarks
- 5 new README translations: Spanish, Portuguese (BR), German, French, Turkish
- Updated AGENT-GUIDE, ARCHITECTURE, MODEL-ROUTING docs for new agents and features

### Changed

- Session state moved from `/tmp/unity-claude-hooks/` to `.claude/state/` (project-local)
- Session file renamed from `session-state.json` to `session.json` with schema versioning
- Learnings file moved from `.claude/learnings.jsonl` to `.claude/state/learnings.jsonl`
- Pre-compact state moved from `/tmp/` to `.claude/state/`
- `session-restore.sh` uses JSON `saved_at` field instead of `stat` for portable TTL checks
- `install.sh` creates `.claude/state/` directory and adds it to `.gitignore`
- `upgrade.sh` migrates state from old `/tmp/` and `.claude/learnings.jsonl` locations

### Component Counts

| Component | v1.2.0 | v1.3.0 |
|-----------|--------|--------|
| Agents | 15 | 20 |
| Commands | 21 | 22 |
| Skills | 40 | 41 |
| Hooks | 22 | 22 |
| Rules | 5 | 5 |
| Scripts | 8 | 8 |
| Templates | 10 | 10 |
| Tests | 46 | 60+ |

---

## [1.2.0] — 2026-04-14

### Added

**New Commands (4)**
- `/unity-ralph` — relentless verify-fix loop that refuses to stop until verification passes (max iterations configurable, stall detection)
- `/unity-team` — parallel agent orchestration with preset teams (build, feature, quality) or custom combinations
- `/unity-interview` — comprehensive Socratic interview flow for thorough requirements gathering before large features
- `/unity-learn` — review accumulated session learnings, extract patterns with confidence scoring, draft new skills

**New Hooks (2)**
- `notify.sh` — webhook notification on session end for Discord/Slack/generic webhooks (env: `UNITY_NOTIFY_WEBHOOK_URL`)
- `guard-project-config.sh` — blocks modification of `.editorconfig`, analyzer settings, and code quality config files

**New Skill (1)**
- `hud-statusline` — guidance for Claude Code statusline integration showing workflow phase, active agent, and session metrics

**Plugin Packaging**
- `.claude-plugin/plugin.json` — machine-readable plugin manifest for Claude Code plugin system
- `.claude-plugin/marketplace.json` — marketplace discovery metadata with highlights and keywords

**CI/CD**
- `.github/workflows/ci.yml` — shellcheck on all hooks, frontmatter validation for agents/commands/skills, JSON validation, test suite execution

**Test Suite**
- `tests/run-tests.sh` — plain bash test runner with assertion helpers (assert_eq, assert_exit_code, assert_contains)
- `tests/test-lib.sh` — tests for `_lib.sh` utilities (profile gating, kill switches, block function modes)
- `tests/test-hooks.sh` — tests for hook exit codes and behavior (15 hook tests)
- `tests/test-install.sh` — tests for `install.sh` on mock Unity projects

**Translations**
- `docs/i18n/README.zh-CN.md` — Chinese (Simplified) README
- `docs/i18n/README.ja.md` — Japanese README
- `docs/i18n/README.ko.md` — Korean README

### Changed
- Enhanced `auto-learn.sh` — now categorizes sessions (bug-fix/performance/architecture/workflow/integration) and extracts file extension patterns
- Enhanced `learner` skill — added "Pattern Categories" and "Confidence Scoring" sections, reference to `/unity-learn`
- Updated `settings.json` — registered `notify.sh` (Stop) and `guard-project-config.sh` (PreToolUse) hooks
- Updated `install.sh` — new component counts (22 hooks, 15 agents, 21 commands, 36 skills), test suite copy step
- Updated `upgrade.sh` — added `tests/` directory copy section
- Updated `README.md` — new component counts, language navigation links, new command/hook/skill sections
- Version bump to 1.2.0

## [1.1.0] — 2026-04-06

### Added

**New Commands (2)**
- `/unity-workflow` — full development pipeline: clarify → plan → execute → verify
- `/unity-doctor` — diagnostic health check (MCP connectivity, .claude/ integrity, hook registration, project structure, skill/package alignment)

**New Agents (3)**
- `unity-verifier` — verify-fix loop agent: reviews changes, auto-fixes safe issues, re-verifies up to 3 iterations
- `unity-coder-lite` — sonnet-tier lightweight coder for simple feature additions
- `unity-fixer-lite` — sonnet-tier lightweight fixer for obvious bugs

**New Hook (1)**
- `suggest-verify` — advisory hook that suggests running `/unity-review` after 5+ C# files modified

**New Templates (5)**
- `Model.cs.template` — pure C# data class with ReactiveProperty (MVS architecture)
- `System.cs.template` — plain C# class with VContainer injection and IDisposable
- `View.cs.template` — MonoBehaviour observing Model via Subscribe, VContainer method injection
- `LifetimeScope.cs.template` — VContainer composition root with Model/System/View/MessagePipe registration
- `Message.cs.template` — readonly struct for MessagePipe (zero allocation)

**New Validation Scripts (2)**
- `validate-serialization.sh` — detects serialized field renames missing `[FormerlySerializedAs]`
- `validate-architecture.sh` — checks MVS pattern compliance (dependency direction, no singletons, no coroutines, injection patterns)

**New Lifecycle Scripts (2)**
- `upgrade.sh` — upgrade existing installation with version detection, backup, and customization preservation
- `uninstall.sh` — clean removal with backup, .gitignore cleanup, and optional settings preservation

**New Documentation (1)**
- `docs/MODEL-ROUTING.md` — guide to agent model assignments, `--quick`/`--thorough` flags, and cost/latency trade-offs

**Hook Kill Switch System**
- Shared `_lib.sh` library sourced by all hooks
- `DISABLE_UNITY_HOOKS=1` — bypass all hooks
- `UNITY_HOOK_MODE=warn` — downgrade blocking hooks to warnings
- `DISABLE_HOOK_<NAME>=1` — disable individual hooks
- Version tracking via `.claude/VERSION`

### Changed

- `/unity-feature` — added optional verification phase (Phase 4) and `--quick` routing to `unity-coder-lite`
- `/unity-fix` — added `--quick` routing to `unity-fixer-lite`
- `/unity-review` — added `--thorough` routing to opus model
- `/unity-prototype` — added optional verification phase (Step 6)
- `block-meta-edit.sh` — uncommented and activated (was disabled in v1.0.0)
- All 8 hooks now source `_lib.sh` for kill switch support
- `settings.local.json.template` — added kill switch environment variable documentation
- `settings.json` — registered `suggest-verify.sh` hook

---

## [1.0.0] — 2026-04-01

### Added

**Agents (12)**
- `unity-coder` — general feature implementation with Unity subsystem awareness
- `unity-fixer` — bug diagnosis with Unity-specific patterns
- `unity-reviewer` — code review with serialization, performance, and architecture checks
- `unity-shader-dev` — HLSL/ShaderGraph development with live MCP testing
- `unity-scene-builder` — scene construction entirely via MCP
- `unity-test-runner` — test writing and execution via MCP
- `unity-build-runner` — build configuration and execution via MCP
- `unity-optimizer` — profiling and performance optimization via MCP
- `unity-prototyper` — rapid end-to-end prototyping (code + scene + physics + camera)
- `unity-ui-builder` — UI screen building with code and visual setup
- `unity-network-dev` — multiplayer implementation (Netcode/Mirror/Photon/Fish-Net)
- `unity-migrator` — Unity version and render pipeline migration

**Commands (15)**
- `/unity-init` — project setup and CLAUDE.md generation
- `/unity-feature` — plan and implement features
- `/unity-fix` — diagnose and fix bugs
- `/unity-prototype` — one prompt to playable prototype
- `/unity-review` — full Unity-aware code review
- `/unity-test` — write and run tests via MCP
- `/unity-build` — configure and trigger builds
- `/unity-scene` — build scenes via MCP
- `/unity-shader` — create shaders with live preview
- `/unity-ui` — build UI screens
- `/unity-network` — set up multiplayer
- `/unity-optimize` — profile and fix performance
- `/unity-audit` — full project health check
- `/unity-profile` — deep profiling session
- `/unity-migrate` — version and pipeline migration

**Skills (35)**
- 6 core (always-on): serialization-safety, scriptable-objects, event-systems, object-pooling, assembly-definitions, unity-mcp-patterns
- 11 systems: urp-pipeline, input-system, addressables, cinemachine, animation, audio, physics, navmesh, ui-toolkit, shader-graph, vfx-graph
- 6 gameplay: character-controller, inventory-system, dialogue-system, save-system, state-machine, procedural-generation
- 4 genre: fps, rpg, platformer-2d, topdown
- 5 third-party: dotween, unitask, vcontainer, textmeshpro, odin-inspector
- 3 platform: mobile, webgl, console

**Hooks (8)**
- 4 blocking: block-scene-edit, block-meta-edit, block-projectsettings, guard-editor-runtime
- 4 warning: warn-serialization, warn-filename, warn-platform-defines, validate-commit

**Rules (5)**
- csharp-unity, performance, serialization, architecture, unity-specifics

**Scripts (6)**
- generate-claude-md, validate-meta-integrity, validate-code-quality, validate-asmdefs, detect-missing-refs, analyze-build-size

**Templates (5)**
- MonoBehaviour, ScriptableObject, EditModeTest, PlayModeTest, AssemblyDefinition

**Examples (5)**
- CLAUDE.md templates for: 2D platformer, FPS, RPG, mobile casual, VR experience

**Infrastructure**
- One-command installer (`install.sh`)
- Unity MCP integration (CoplayDev/unity-mcp)
- Settings.json with full hook + MCP configuration
- Comprehensive documentation (Getting Started, Architecture, Agent Guide, MCP Setup)
