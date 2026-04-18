# Model Routing Guide

## Overview

Agents use different Claude models based on task complexity. **Opus** handles creative, multi-step reasoning. **Sonnet** handles structured analysis and simpler implementations. **Haiku** handles fast, read-only exploration and validation. This optimizes cost and latency without sacrificing quality where it matters.

The `model-routing` skill (always loaded) provides complexity heuristics that orchestrating commands use to select the right agent tier automatically.

## Agent Model Assignments

### Haiku Tier — Fast, Cheap, Read-Only

| Agent | Rationale |
|-------|-----------|
| **unity-scout** | Fast codebase exploration and file discovery |
| **unity-linter** | Quick validation pass against Unity rules |

### Sonnet Tier — Balanced Speed/Quality

| Agent | Rationale |
|-------|-----------|
| **unity-coder-lite** | Simple additions (fields, methods, single components) |
| **unity-fixer-lite** | Obvious fixes (typos, missing imports, simple errors) |
| **unity-reviewer** | Checklist-based review is structured, not creative |
| **unity-test-runner** | Test writing follows patterns, not deep reasoning |
| **unity-build-runner** | Build config is procedural, not creative |
| **unity-migrator** | Migration follows documented upgrade paths |
| **unity-security-reviewer** | Security audit follows a checklist |
| **unity-git-master** | Git operations are procedural |

### Opus Tier — Deep Reasoning

| Agent | Rationale |
|-------|-----------|
| **unity-coder** | Multi-system features need architectural reasoning |
| **unity-prototyper** | End-to-end prototyping requires creativity + planning |
| **unity-fixer** | Complex bugs need deep investigation and reasoning |
| **unity-verifier** | Verify-fix loop needs judgment about what's safe to fix |
| **unity-optimizer** | Performance analysis requires understanding trade-offs |
| **unity-ui-builder** | UI layout + responsive design needs creative decisions |
| **unity-shader-dev** | Shader math and HLSL need precision and creativity |
| **unity-network-dev** | Networking architecture is inherently complex |
| **unity-scene-builder** | Scene composition needs spatial reasoning |
| **unity-critic** | Challenging plans requires deep reasoning about trade-offs |

## Command Flags

### `--quick` (faster, cheaper)

Routes to the sonnet-tier lite agent instead of the default opus agent.

```bash
/unity-feature --quick "add a health field to PlayerModel"
/unity-fix --quick "missing using statement in GameManager"
```

**Use when:**
- The task is straightforward with an obvious solution
- You're making a small, localized change
- Speed matters more than depth of reasoning

### `--thorough` (deeper analysis)

Routes to opus for tasks that normally use sonnet.

```bash
/unity-review --thorough "review the entire combat system"
```

**Use when:**
- You want deeper architectural analysis
- The review covers complex, interconnected systems
- You're preparing for a major release

## Complexity Heuristics

The `model-routing` skill provides these signals for automatic tier selection:

| Signal | Simple (haiku/sonnet) | Moderate (sonnet) | Complex (opus) |
|--------|----------------------|-------------------|----------------|
| File count | 1-2 files | 3-8 files | 9+ files |
| Scope | Single class/method | Single system | Multiple systems |
| Keywords | "add field", "rename" | "implement", "refactor" | "architect", "migrate" |
| Risk level | No serialization | Serialization involved | Networking, threading |

## Cost/Latency Trade-offs

| Model | Relative Cost | Relative Speed | Best For |
|-------|--------------|----------------|----------|
| **Haiku** | 1x | Fastest | Read-only exploration, quick validation |
| **Sonnet** | 5x | Fast | Structured tasks, reviews, simple implementations |
| **Opus** | 25x | Slower | Creative work, complex reasoning, multi-step tasks |

For iterative workflows (verify-fix loops), consider using sonnet for early passes and opus for the final judgment pass to reduce costs by 50%+.

## Guidelines for New Agents

When creating a new agent:
1. **Default to sonnet** — upgrade to opus only if the task requires multi-step reasoning or creative generation
2. **Use haiku** for read-only agents that don't need deep reasoning (exploration, lint-style checks)
3. **Create a lite variant** only if the command is frequently used for both simple and complex tasks
4. **Document the routing** in the command file with clear "good fit" / "not good fit" lists
5. **Haiku agents must be read-only** — tools limited to Read, Glob, Grep (no Write, Edit, Bash)
