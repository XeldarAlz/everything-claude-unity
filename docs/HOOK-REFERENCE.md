# Hook Reference

Complete catalog of hooks in everything-claude-unity.

---

## Overview

everything-claude-unity includes 22 hooks that provide safety enforcement, quality gates, session management, and learning. Hooks are bash scripts in `.claude/hooks/` configured in `.claude/settings.json`. All hooks source a shared library (`_lib.sh`) that provides kill switches, profile filtering, state paths, and utility functions.

---

## Hook Profiles

| Profile | Level | Active Hooks | Best For |
|---------|-------|-------------|----------|
| `minimal` | 1 | Safety hooks only (5) | Maximum speed, minimal interference |
| `standard` | 2 | Safety + quality + session (18) | Default -- recommended for most work |
| `strict` | 3 | Everything including learning + cost (22) | Full observability, data collection |

Set via: `UNITY_HOOK_PROFILE=standard` in environment or `settings.local.json`.

The `standard` profile is the default. Each profile includes all hooks from lower levels plus its own. The `strict` profile activates every hook.

---

## Kill Switches

| Variable | Effect |
|----------|--------|
| `DISABLE_UNITY_HOOKS=1` | Bypass ALL hooks |
| `DISABLE_HOOK_<NAME>=1` | Bypass specific hook (name uppercased, hyphens to underscores) |
| `UNITY_HOOK_MODE=warn` | Downgrade blocking hooks to warnings |

Examples:
```bash
# Disable all hooks temporarily
DISABLE_UNITY_HOOKS=1

# Disable only the gateguard hook
DISABLE_HOOK_GATEGUARD=1

# Downgrade blocks to warnings (hooks still run but exit 0)
UNITY_HOOK_MODE=warn
```

Configure overrides in `.claude/settings.local.json` (git-ignored) so they do not affect the team.

---

## Hooks by Event

### PreToolUse -- Edit|Write

These hooks run before any Edit or Write tool invocation. Blocking hooks (exit 2) prevent the operation from executing.

#### block-scene-edit

- **File:** `block-scene-edit.sh`
- **Profile:** minimal
- **Type:** Blocking (exit 2)
- **What it does:** Prevents direct editing of `.unity`, `.prefab`, and `.asset` YAML files. These files contain serialized references that break when text-edited. Use unity-mcp tools (`manage_scene`, `manage_gameobject`, `manage_prefabs`) instead.
- **Environment variables:** None (uses standard `_lib.sh` kill switches)

#### block-meta-edit

- **File:** `block-meta-edit.sh`
- **Profile:** minimal
- **Type:** Blocking (exit 2)
- **What it does:** Prevents editing `.meta` files. Meta files contain GUIDs that Unity uses to reference assets. Editing them breaks every reference to that asset across all scenes, prefabs, and scripts.
- **Environment variables:** None

#### guard-editor-runtime

- **File:** `guard-editor-runtime.sh`
- **Profile:** minimal
- **Type:** Blocking (exit 2)
- **What it does:** Blocks usage of the `UnityEditor` namespace in runtime code (files outside `Editor/` folders) without `#if UNITY_EDITOR` guards. Code using `UnityEditor` compiles in the Editor but fails on player build.
- **Environment variables:** None

#### guard-project-config

- **File:** `guard-project-config.sh`
- **Profile:** standard
- **Type:** Blocking (exit 2)
- **What it does:** Prevents modification of project configuration files that enforce code quality rules (`.editorconfig`, `*.ruleset`, `*.globalconfig`, `Directory.Build.props` analyzer sections). Forces the agent to fix code to meet existing rules rather than weakening the rules.
- **Environment variables:** None

#### gateguard

- **File:** `gateguard.sh`
- **Profile:** strict
- **Type:** Blocking (exit 2)
- **What it does:** Fact-forcing gate that blocks the first Edit/Write on a C# file until the agent has Read it first. Prevents hallucinated changes to unexamined files. For MVS pattern files (Model/View/System), also checks that related counterparts have been read.
- **Environment variables:** Reads `UNITY_READS_FILE` (populated by `track-reads.sh`)

---

### PreToolUse -- Bash

#### block-projectsettings

- **File:** `block-projectsettings.sh`
- **Profile:** minimal
- **Type:** Blocking (exit 2)
- **What it does:** Prevents staging `ProjectSettings/` and `Packages/` files via `git add`. These are Unity-managed YAML configs. Manual edits cause merge conflicts and subtle build issues. Use unity-mcp tools instead.
- **Environment variables:** None

---

### PostToolUse -- Read

#### track-reads

- **File:** `track-reads.sh`
- **Profile:** strict
- **Type:** Advisory (exit 0)
- **What it does:** Records files that have been Read so GateGuard can verify that the agent investigated a file before editing it. Writes to the gateguard reads tracking file.
- **Environment variables:** Writes to `UNITY_READS_FILE`

---

### PostToolUse -- Edit|Write

These hooks run after every Edit or Write tool invocation. They warn but do not block.

#### warn-serialization

- **File:** `warn-serialization.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Detects when a `[SerializeField]` field is renamed without `[FormerlySerializedAs]`. This causes silent data loss -- every configured value in every scene and prefab resets to default.
- **Environment variables:** None

#### warn-filename

- **File:** `warn-filename.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Checks that C# file name matches the primary class/struct name. Unity requires MonoBehaviour/ScriptableObject file name to equal the class name, otherwise the script cannot be attached to GameObjects.
- **Environment variables:** None

#### warn-platform-defines

- **File:** `warn-platform-defines.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Checks for `#if UNITY_ANDROID` / `UNITY_IOS` etc. without `#else` fallback. Code inside platform defines is silently excluded on other platforms.
- **Environment variables:** None

#### quality-gate

- **File:** `quality-gate.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Lightweight post-edit quality check for common Unity C# pitfalls: `GetComponent` in Update, uncached `Camera.main`, LINQ in gameplay code, `tag ==` instead of `CompareTag`, `?.` on Unity objects, `Debug.Log` without conditional compilation.
- **Environment variables:** None

#### track-edits

- **File:** `track-edits.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Records files that have been edited during the session. Used by `stop-validate.sh` (end-of-session validation), `session-save.sh` (state persistence), and session metrics.
- **Environment variables:** Writes to `UNITY_EDITS_FILE`

#### suggest-verify

- **File:** `suggest-verify.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Tracks distinct C# files modified and suggests running `/unity-review` after 5+ files have been changed. One-time suggestion per batch to avoid repeated nudging.
- **Environment variables:** None

---

### PostToolUse -- Bash

#### validate-commit

- **File:** `validate-commit.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Runs meta integrity and code quality checks when a `git commit` command is detected. Warns about missing `.meta` files, orphaned metas, and code quality issues in staged files.
- **Environment variables:** None

#### build-analyze

- **File:** `build-analyze.sh`
- **Profile:** strict
- **Type:** Advisory (exit 0)
- **What it does:** Detects Unity build commands and analyzes output for common issues: build size warnings, shader variant counts, script compilation errors, and stripping issues.
- **Environment variables:** None

---

### PostToolUse -- All Tools

#### cost-tracker

- **File:** `cost-tracker.sh`
- **Profile:** strict
- **Type:** Advisory (exit 0)
- **What it does:** Logs every tool call with timestamp and tool name as JSONL for session metrics. The `session-save.sh` Stop hook uses this data to report totals.
- **Environment variables:** Writes to `UNITY_COST_FILE`

---

### PreCompact

#### pre-compact

- **File:** `pre-compact.sh`
- **Profile:** minimal
- **Type:** Advisory (exit 0)
- **What it does:** Saves session state before context window compression so critical information survives compaction. Captures git state (branch, modified files, staged files, recent commits) and writes a markdown summary to the state directory.
- **Environment variables:** Writes to `UNITY_HOOK_STATE_DIR/precompact-state.md`

---

### SessionStart

#### session-restore

- **File:** `session-restore.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Restores prior session state on conversation start. Loads branch context, previously modified files, workflow phase, plan steps, and last agent so the agent can resume where it left off. Clears stale gateguard state from previous sessions. Respects a configurable TTL for session expiry.
- **Environment variables:** `UNITY_SESSION_TTL_HOURS` (default: 4) -- sessions older than this are discarded

---

### Stop

These hooks run when the agent stops (conversation ends or user exits).

#### stop-validate

- **File:** `stop-validate.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Runs validation checks on all C# files modified during the session. Catches issues that per-edit hooks might miss because they only see the edited fragment, not the full file.
- **Environment variables:** Reads `UNITY_EDITS_FILE`

#### session-save

- **File:** `session-save.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Saves session state when the agent stops so subsequent conversations can resume context. Captures branch, modified files, workflow phase, plan state, verification state, duration, tool call count, and warning count.
- **Environment variables:** Reads `UNITY_EDITS_FILE`, `UNITY_COST_FILE`, `UNITY_WARNINGS_FILE`. Writes `UNITY_SESSION_FILE`

#### auto-learn

- **File:** `auto-learn.sh`
- **Profile:** strict
- **Type:** Advisory (exit 0)
- **What it does:** Extracts session patterns when the agent stops. Records which hooks fired and how often, what types of files were edited, and which commands/skills were invoked. Writes session learnings to a persistent JSONL log for later review.
- **Environment variables:** Reads `UNITY_EDITS_FILE`, `UNITY_WARNINGS_FILE`. Writes to `UNITY_LEARNING_FILE`

#### notify

- **File:** `notify.sh`
- **Profile:** standard
- **Type:** Advisory (exit 0)
- **What it does:** Multi-channel notification system for session events. Supports Discord webhooks, Slack webhooks, and OS-native notifications.
- **Environment variables:**
  - `UNITY_NOTIFY_ENABLED=1` -- enable notifications (disabled by default)
  - `UNITY_NOTIFY_CHANNELS='[...]'` -- JSON array of channel configs
  - `UNITY_NOTIFY_RATE_LIMIT=60` -- minimum seconds between notifications per channel
  - `UNITY_NOTIFY_MIN_DURATION=300` -- minimum session seconds for session_end (default: 5 min)
  - `UNITY_NOTIFY_WEBHOOK_URL` -- single webhook URL (legacy)
  - `UNITY_NOTIFY_FORMAT` -- auto | discord | slack (legacy)

---

## Summary Table

| Hook | Event | Matcher | Profile | Type | Purpose |
|------|-------|---------|---------|------|---------|
| block-scene-edit | PreToolUse | Edit\|Write | minimal | Blocking | Block .unity/.prefab/.asset edits |
| block-meta-edit | PreToolUse | Edit\|Write | minimal | Blocking | Block .meta edits |
| guard-editor-runtime | PreToolUse | Edit\|Write | minimal | Blocking | Block UnityEditor without #if guard |
| guard-project-config | PreToolUse | Edit\|Write | standard | Blocking | Block quality config weakening |
| gateguard | PreToolUse | Edit\|Write | strict | Blocking | Require Read before Edit |
| block-projectsettings | PreToolUse | Bash | minimal | Blocking | Block git add ProjectSettings/ |
| track-reads | PostToolUse | Read | strict | Advisory | Track reads for GateGuard |
| warn-serialization | PostToolUse | Edit\|Write | standard | Advisory | Warn on renamed SerializeField |
| warn-filename | PostToolUse | Edit\|Write | standard | Advisory | Warn on file/class name mismatch |
| warn-platform-defines | PostToolUse | Edit\|Write | standard | Advisory | Warn on platform #if without #else |
| quality-gate | PostToolUse | Edit\|Write | standard | Advisory | Warn on common Unity C# pitfalls |
| track-edits | PostToolUse | Edit\|Write | standard | Advisory | Track edited files for session |
| suggest-verify | PostToolUse | Edit\|Write | standard | Advisory | Suggest review after 5+ edits |
| validate-commit | PostToolUse | Bash | standard | Advisory | Validate git commits |
| build-analyze | PostToolUse | Bash | strict | Advisory | Analyze Unity build output |
| cost-tracker | PostToolUse | (all) | strict | Advisory | Log tool calls for metrics |
| pre-compact | PreCompact | (all) | minimal | Advisory | Save state before compaction |
| session-restore | SessionStart | (all) | standard | Advisory | Restore session state |
| stop-validate | Stop | (all) | standard | Advisory | Validate all modified C# files |
| session-save | Stop | (all) | standard | Advisory | Persist session state |
| auto-learn | Stop | (all) | strict | Advisory | Extract session patterns |
| notify | Stop | (all) | standard | Advisory | Send notifications |

---

## Shared Library: _lib.sh

All hooks source `.claude/hooks/_lib.sh` after setting `HOOK_PROFILE_LEVEL`. The library provides:

- **Profile filtering** -- compares the hook's declared level against the active profile and exits silently if the hook should not run
- **Kill switch checks** -- `DISABLE_UNITY_HOOKS` and per-hook `DISABLE_HOOK_<NAME>`
- **State directory resolution** -- finds `.claude/state/` or falls back to `/tmp/unity-claude-hooks`
- **Shared file paths** -- `UNITY_SESSION_FILE`, `UNITY_READS_FILE`, `UNITY_EDITS_FILE`, `UNITY_COST_FILE`, `UNITY_LEARNING_FILE`, `UNITY_WARNINGS_FILE`
- **`unity_hook_block()`** -- replaces direct `exit 2` in blocking hooks; respects `UNITY_HOOK_MODE=warn`
- **`unity_track_edit()`** / **`unity_track_read()`** -- append to tracking files
- **`unity_was_read()`** -- check if a file was previously read (used by GateGuard)
- **`unity_state_read()`** / **`unity_state_write()`** -- read/write keys in `session.json`
- **`unity_track_warning()`** -- record a hook warning for session analytics
