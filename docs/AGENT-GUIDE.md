# Agent Guide

How to use, customize, and create agents for everything-claude-unity.

---

## All 20 Agents at a Glance

| Agent | Model | Description |
|-------|-------|-------------|
| `unity-coder` | opus | Implements gameplay systems, components, and managers with correct asmdef placement |
| `unity-coder-lite` | sonnet | Lightweight coding agent for simpler implementation tasks |
| `unity-prototyper` | opus | End-to-end rapid prototyping -- one prompt to playable prototype |
| `unity-scene-builder` | opus | Builds scenes from natural language descriptions entirely via MCP |
| `unity-fixer` | opus | Diagnoses and fixes bugs using console errors and live API inspection |
| `unity-fixer-lite` | sonnet | Lightweight bug fixing for straightforward issues |
| `unity-optimizer` | opus | Profiles performance and fixes CPU/GPU bottlenecks, GC spikes, draw calls |
| `unity-shader-dev` | opus | Creates HLSL/ShaderLab shaders, ShaderGraph nodes, compute shaders |
| `unity-network-dev` | opus | Implements multiplayer networking (Netcode, Mirror, Photon, Fish-Net) |
| `unity-ui-builder` | opus | Builds UI with UGUI Canvas or UI Toolkit, handles safe areas and responsive layouts |
| `unity-reviewer` | sonnet | Reviews code for correctness, performance, serialization safety, and Unity pitfalls |
| `unity-test-runner` | sonnet | Writes and runs EditMode/PlayMode tests, reports results |
| `unity-build-runner` | sonnet | Configures builds, platform switching, player settings, Addressables |
| `unity-migrator` | sonnet | Handles Unity version upgrades, render pipeline migration, deprecated API updates |
| `unity-verifier` | opus | Automated verify-fix loop -- reviews changes, classifies issues, auto-fixes safe issues |
| `unity-scout` | haiku | Fast codebase exploration -- scans project structure, finds files, maps dependencies |
| `unity-linter` | haiku | Quick validation pass -- checks code against Unity rules without deep reasoning |
| `unity-security-reviewer` | sonnet | Security audit -- PlayerPrefs secrets, hardcoded keys, insecure network calls, debug builds |
| `unity-git-master` | sonnet | Unity-aware git operations -- LFS, merge strategies, .meta hygiene, .gitattributes |
| `unity-critic` | opus | Challenges implementation plans -- identifies risks, missed edge cases, over-engineering |

---

## When to Use Each Agent

```
What do you need?
|
+-- Write new gameplay code?
|     +-- From scratch with a scene? ---------> unity-prototyper
|     +-- Just the C# scripts? ---------------> unity-coder
|     +-- Multiplayer/networking? -------------> unity-network-dev
|     +-- UI screens? -------------------------> unity-ui-builder
|     +-- Shaders? ----------------------------> unity-shader-dev
|
+-- Build or modify a scene?
|     +-- Scene layout from description? ------> unity-scene-builder
|
+-- Fix or improve existing code?
|     +-- Bug / error in console? -------------> unity-fixer
|     +-- Performance issue? ------------------> unity-optimizer
|     +-- Code review? ------------------------> unity-reviewer
|
+-- Test or build?
|     +-- Write and run tests? ----------------> unity-test-runner
|     +-- Build for a platform? ---------------> unity-build-runner
|
+-- Upgrade or migrate?
|     +-- Unity version, pipeline, APIs? ------> unity-migrator
|
+-- Explore or validate?
|     +-- Find files, map dependencies? -------> unity-scout
|     +-- Quick lint pass on code? ------------> unity-linter
|     +-- Security audit? ---------------------> unity-security-reviewer
|
+-- Git operations?
|     +-- LFS, .gitattributes, .meta hygiene? -> unity-git-master
|
+-- Challenge a plan?
      +-- Find risks before execution? --------> unity-critic
```

---

### unity-scout (haiku)

Fast, read-only codebase explorer. Scans project structure, finds relevant files, maps dependencies, and reports findings.

**When to Use:**
- You need to find where something lives in the codebase quickly
- You want a project overview (script count, scene list, package inventory)
- You need to trace symbol usage or dependency chains
- Another agent needs codebase context before starting work

**When NOT to Use:**
- You need deep analysis or reasoning about code quality (use `unity-reviewer`)
- You need to modify files (scout is read-only)
- The task requires understanding subtle Unity behavior (haiku may miss nuance)

---

### unity-linter (haiku)

Fast validation pass that checks Unity C# code against the project's rules and reports violations. Read-only -- never modifies files.

**When to Use:**
- Quick pre-commit sanity check on changed files
- Scanning a batch of files for common Unity pitfalls
- Validating that generated code follows project conventions
- You want speed over depth -- a fast pass before deeper review

**When NOT to Use:**
- You need fixes applied automatically (use `unity-fixer` or `unity-reviewer` with write access)
- You need architectural analysis (use `unity-critic`)
- The code has complex, context-dependent issues that require deep reasoning

---

### unity-security-reviewer (sonnet)

Security auditor for Unity projects. Reviews code for vulnerabilities, data exposure, and insecure practices. Strictly read-only.

**When to Use:**
- Before releasing a build -- audit for hardcoded secrets, insecure saves, debug code
- Reviewing network code for TLS issues, certificate pinning, insecure URLs
- Checking PlayerPrefs usage for sensitive data exposure
- Auditing deserialization patterns for code execution risks

**When NOT to Use:**
- General code review (use `unity-reviewer`)
- Performance optimization (use `unity-optimizer`)
- You need the issues fixed, not just reported (pair with `unity-fixer` for remediation)

---

### unity-git-master (sonnet)

Unity-specialized git operations agent. Handles LFS configuration, merge strategies for binary assets, .meta file hygiene, branch naming, and .gitattributes maintenance.

**When to Use:**
- Setting up Git LFS for a new Unity project
- Configuring `.gitattributes` with Unity merge strategies
- Validating `.meta` file integrity (orphaned metas, missing metas, duplicate GUIDs)
- Resolving Unity-specific merge conflicts (`.unity`, `.prefab`, `.meta` files)
- Cleaning up branches or enforcing naming conventions

**When NOT to Use:**
- General git operations that are not Unity-specific
- You need to modify C# code (git-master only runs git commands)
- Complex rebasing or history rewriting (do this manually)

---

### unity-critic (opus)

Senior Unity architect that challenges implementation plans before execution. Identifies risks, missed edge cases, over-engineering, and Unity-specific gotchas. Used by `/unity-workflow` in the Plan phase.

**When to Use:**
- Before executing a complex implementation plan -- get a second opinion
- You suspect a design has hidden Unity lifecycle issues (execution order, domain reload, destruction mid-async)
- You want to catch over-engineering before it happens
- Validating that a plan handles edge cases (scene transitions, disabled objects, re-entrant calls)

**When NOT to Use:**
- You need code written or modified (critic is read-only)
- The task is simple enough that review is overhead
- You need a code review of existing code (use `unity-reviewer`)

---

## How Agents Are Selected

Agents are invoked in two ways:

1. **By commands** -- when you run `/unity-prototype`, the command delegates to the `unity-prototyper` agent automatically.
2. **Manually** -- you can ask Claude to use a specific agent: "Use the unity-reviewer agent to check this file."

Most users interact through commands and never need to name agents directly. The command layer handles agent selection based on the task.

---

## Agent Frontmatter Reference

Every agent is a Markdown file in `.claude/agents/` with YAML frontmatter:

```yaml
---
name: unity-coder                    # Unique identifier
description: "Implements features"   # One-line summary
model: opus                          # opus | sonnet | haiku
color: green                         # Terminal display color
tools: Read, Write, Edit, Glob, Grep, Bash, mcp__unityMCP__*
---
```

### Field Details

**name** -- Must be unique across all agents. Used by commands to reference the agent.

**description** -- Displayed when listing agents. Keep it under 120 characters.

**model** -- Controls which Claude model runs the agent:
- `opus` -- best reasoning, creative implementation, complex debugging
- `sonnet` -- fast and capable, good for review, analysis, and structured tasks
- `haiku` -- fastest and cheapest, suitable for simple lookups and formatting

**color** -- Visual indicator in the terminal. Options: red, green, yellow, blue, magenta, cyan.

**tools** -- Comma-separated list of allowed tools. Common values:
- `Read, Glob, Grep` -- read-only access (reviewers, analyzers)
- `Read, Write, Edit, Glob, Grep, Bash` -- full code access
- `mcp__unityMCP__*` -- all unity-mcp tools (wildcard)
- `Agent` -- ability to spawn sub-agents

---

## Customizing Agents

### Changing the Model

If an agent is too slow or too expensive for your needs, change the `model` field:

```yaml
# Make the reviewer use haiku for faster, cheaper reviews
model: haiku
```

Trade-off: cheaper models may miss subtle Unity-specific issues.

### Adding or Removing Tools

To give the reviewer write access for auto-fixing:

```yaml
# Before
tools: Read, Glob, Grep

# After
tools: Read, Write, Edit, Glob, Grep
```

To remove MCP access from an agent (if you do not use unity-mcp):

```yaml
# Before
tools: Read, Write, Edit, Glob, Grep, Bash, Agent, mcp__unityMCP__*

# After
tools: Read, Write, Edit, Glob, Grep, Bash, Agent
```

### Editing Instructions

The Markdown body below the frontmatter contains the agent's instructions. You can:

- Add project-specific conventions
- Remove checklist items that do not apply
- Add new checks relevant to your codebase
- Reference additional skills to load

---

## Creating a New Agent

### Step 1: Create the File

Create a new `.md` file in `.claude/agents/`:

```bash
touch .claude/agents/unity-localization.md
```

### Step 2: Write the Frontmatter

```yaml
---
name: unity-localization
description: "Manages localization — string tables, font assets, RTL support, locale switching, and Unity Localization package integration."
model: sonnet
color: cyan
tools: Read, Write, Edit, Glob, Grep, Bash
---
```

### Step 3: Write the Instructions

```markdown
# Unity Localization Agent

You manage localization for Unity projects using the Unity Localization package.

## Before Making Changes

1. Check if Unity Localization package is installed in Packages/manifest.json
2. Identify existing string tables in Assets/Localization/
3. Check the current locale setup in ProjectSettings

## Tasks You Handle

- Creating and populating string tables
- Setting up locale selectors (system language, player prefs, command line)
- Configuring font assets for different scripts (CJK, Arabic, Devanagari)
- RTL layout support
- Smart strings with pluralization and gender
- Addressable asset tables for localized sprites/audio

## Rules

- Always use table references, never hardcoded strings
- String table entries use snake_case keys: `menu_start_game`, `dialog_npc_greeting_01`
- Every user-facing string must go through the localization system
- Provide fallback locale (English) for every entry
```

### Step 4: Create a Command (Optional)

To make your agent accessible via a slash command, create `.claude/commands/unity-localize.md`:

```yaml
---
name: unity-localize
description: "Manage project localization"
user-invocable: true
args: task_description
---

# /unity-localize

Use the `unity-localization` agent to handle: **$ARGUMENTS**
```

---

## Model Selection Guide

| Use Case | Recommended Model | Reasoning |
|----------|-------------------|-----------|
| Implement a new gameplay system | opus | Needs to understand architecture, write correct code, wire up components |
| Build a scene from description | opus | Creative interpretation, complex MCP tool orchestration |
| Debug a subtle issue | opus | Needs deep reasoning about Unity lifecycle, serialization, threading |
| Write shaders | opus | HLSL requires precise understanding of GPU pipelines |
| Challenge a plan before execution | opus | Needs deep Unity knowledge to find subtle risks |
| Review code | sonnet | Structured checklist, pattern matching, faster turnaround |
| Write unit tests | sonnet | Test patterns are well-defined, speed matters for iteration |
| Run a build | sonnet | Mostly configuration and tool invocation |
| Migrate deprecated APIs | sonnet | Mapping old API to new API is well-documented |
| Security audit | sonnet | Pattern matching for known vulnerability classes |
| Git LFS and .meta hygiene | sonnet | Structured git operations, tool invocation |
| Quick lint pass | haiku | Fast pattern matching against known rules, no deep reasoning needed |
| Find files and map dependencies | haiku | Simple lookups and grep, speed matters more than depth |
| Format or rename files | haiku | Simple mechanical task |

---

## Tips for Effective Agent Prompts

1. **Be specific about the scope.** "Add a health system to the player" is better than "improve the player."

2. **Name the Unity subsystems involved.** "Use the Input System and Cinemachine" helps the agent load the right skills.

3. **Reference existing code.** "Follow the pattern in EnemyController.cs" gives the agent a concrete example.

4. **State constraints up front.** "Must support mobile (no compute shaders)" prevents wasted work.

5. **For prototypes, describe the feel.** "Tight, responsive controls like Celeste" conveys more than a feature list.

6. **Let the agent ask questions.** If you give a vague prompt, a good agent will ask for clarification rather than guess.
