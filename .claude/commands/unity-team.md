---
name: unity-team
description: "Parallel agent orchestration — spawns multiple specialized agents simultaneously for faster development. Supports preset teams and custom combinations."
user-invocable: true
args: team_spec
---

# /unity-team — Parallel Agent Orchestration

Spawn multiple agents in parallel to work on: **$ARGUMENTS**

This command runs 2-3 agents simultaneously instead of sequentially, significantly speeding up workflows where different concerns can be addressed independently.

## Team Presets

Parse `$ARGUMENTS` for a team flag. Everything after the flag is the task description.

| Flag | Agents | Best For |
|------|--------|----------|
| `--build` | unity-coder + unity-test-runner + unity-reviewer | New features with full quality coverage |
| `--feature` | unity-coder + unity-scene-builder + unity-test-runner | Features that need scene setup |
| `--quality` | unity-reviewer + unity-optimizer + unity-test-runner | Auditing existing code |
| `--security` | unity-security-reviewer + unity-reviewer + unity-linter | Security audit with code quality check |
| `--custom <agents>` | Comma-separated agent names | Any combination |

### Quick Mode

Add `--quick` to any preset to swap opus agents for their sonnet/haiku equivalents where available:

| Opus Agent | Quick Replacement |
|------------|-------------------|
| `unity-coder` | `unity-coder-lite` |
| `unity-fixer` | `unity-fixer-lite` |
| `unity-reviewer` (already sonnet) | No change |

Example: `/unity-team --build --quick "add health bar UI"` uses `unity-coder-lite` instead of `unity-coder`.

If no team flag is provided, default to `--build`.

### Custom Teams

```
/unity-team --custom coder,shader-dev "add a dissolve effect to enemy death"
```

Agent names can be specified with or without the `unity-` prefix. Valid: `coder`, `unity-coder`, `shader-dev`, `unity-shader-dev`.

## Execution Flow

### Step 1: Pre-Flight

1. **Validate agents** — verify each requested agent exists in `.claude/agents/`
2. **Read project context** — scan CLAUDE.md, recent git state, assembly structure
3. **Detect write conflicts** — if two agents might write to the same files, warn the user:
   ```
   WARNING: unity-coder and unity-scene-builder may both modify scene files.
   Proceed anyway? (The reconciliation pass will resolve conflicts.)
   ```
4. **Decompose the task** — generate a role-specific brief for each agent

### Step 2: Role Assignment

Each agent receives the shared task description PLUS a role-specific instruction:

**unity-coder:**
> "Implement the following feature. Focus on writing C# scripts with correct namespace, assembly placement, and architecture. Do NOT set up scene elements — another agent is handling that."

**unity-test-runner:**
> "Write EditMode and PlayMode tests for the following feature. The implementation is being written by another agent in parallel — write tests based on the expected API described in the task, not by reading the implementation."

**unity-reviewer:**
> "Review the codebase for issues related to the following feature area. Check existing code that the new feature will touch. Focus on serialization safety, performance, and architecture concerns."

**unity-scene-builder:**
> "Set up scene elements (GameObjects, components, hierarchy, physics layers) for the following feature. Script files are being written by another agent — focus only on the scene structure."

**unity-optimizer:**
> "Profile and analyze performance in the area related to the following feature. Identify bottlenecks, GC allocations, and rendering issues."

**unity-shader-dev:**
> "Create or modify shaders for the following feature. Set up materials and test objects via MCP."

### Step 3: Parallel Execution

Launch all agents simultaneously using the Agent tool with multiple parallel invocations in a single message. Each agent runs independently.

Wait for all agents to complete and collect their results.

### Step 4: Result Collection

Aggregate results from all agents into a unified report:

```markdown
## Team Results

### unity-coder
- Files created/modified: [list]
- Summary: [agent's summary]

### unity-test-runner
- Tests created: [list]
- Summary: [agent's summary]

### unity-reviewer
- Issues found: [count]
- Summary: [agent's summary]
```

### Step 5: Conflict Detection

Check for conflicts between agent outputs:

1. **File conflicts** — did two agents modify the same file? Flag and present both versions.
2. **API mismatches** — do tests reference APIs that the coder didn't create? Flag.
3. **Naming inconsistencies** — different agents used different names for the same concept? Flag.

### Step 6: Reconciliation (if needed)

If conflicts were detected:

1. Present the conflicts to the user with recommended resolutions
2. Apply resolutions (prefer the coder's implementation for API surface, the reviewer's suggestions for quality)
3. Run `unity-verifier` agent for a final consistency check

If no conflicts: skip directly to the final report.

## Final Report

```markdown
## Team Execution Complete

**Team:** [preset name or custom list]
**Task:** [task description]
**Agents:** [count] ran in parallel

### Created/Modified Files
- [file list with which agent created each]

### Test Coverage
- [test count and pass/fail status]

### Issues Found by Reviewer
- [issue list, noting which were auto-resolved]

### Conflicts Resolved
- [conflict list with resolutions, or "None"]

### Manual Steps Needed
- [any inspector assignments, scene references, etc.]
```

## Caveats

- **Parallel agents work independently** — they cannot see each other's output during execution
- **Test-first approach** — tests written in parallel may not match the exact implementation API. The reconciliation pass catches these mismatches.
- **Write conflicts are possible** — the preset teams are designed to minimize overlap (coder writes scripts, scene-builder modifies scenes, tester writes test files), but custom combinations may conflict
- **Cost** — running 3 agents in parallel uses ~3x the tokens of a single agent. Use team mode for medium-to-large features where the speedup justifies the cost.
- **MCP contention** — if multiple agents use MCP simultaneously, requests may queue. This is handled gracefully but may slow down MCP-heavy agents.
