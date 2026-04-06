---
name: unity-workflow
description: "Full development pipeline — clarify requirements, plan implementation, execute with agents, verify with review + tests."
user-invocable: true
args: feature_description
---

# /unity-workflow — Full Development Pipeline

Orchestrate a complete development workflow for: **$ARGUMENTS**

This command runs a 4-phase pipeline: **Clarify → Plan → Execute → Verify**. Each phase requires explicit user confirmation before proceeding to the next.

## Phase 1: Clarify

Interview the user to build a complete requirements picture. Ask about:

1. **Core mechanic / feature purpose** — what does it do? What problem does it solve?
2. **Target platform** — mobile (iOS/Android), desktop, WebGL, VR?
3. **Performance constraints** — target FPS? Memory budget? Draw call limit?
4. **Unity subsystems involved** — physics? UI? animation? audio? networking?
5. **Integration points** — what existing systems does this touch?
6. **Acceptance criteria** — how do we know it's done? What should we test?

Produce a **Requirements Summary** with all answers consolidated. Ask the user to confirm before proceeding.

If the user provided a detailed description in `$ARGUMENTS` and the requirements are clear, you may present the summary directly for confirmation rather than asking each question individually.

## Phase 2: Plan

Based on confirmed requirements:

1. **Scan the project** — read CLAUDE.md, check existing scripts, understand the codebase
2. **Identify subsystems** — which Unity packages and skills are involved?
3. **Choose execution strategy**:
   - Simple feature → `unity-coder` agent
   - Rapid prototype → `unity-prototyper` agent
   - UI screen → `unity-ui-builder` agent
   - Networking → `unity-network-dev` agent
   - Shader work → `unity-shader-dev` agent
   - Multiple subsystems → sequence of agent calls
4. **Generate implementation plan**:
   - Scripts to create/modify (with file paths and assembly placement)
   - Scene changes needed (GameObjects, components, physics layers)
   - Dependencies on existing systems
   - Risk areas (serialization, platform-specific, performance)
   - Estimated complexity: simple / moderate / complex

Present the plan to the user and wait for approval before executing.

## Phase 3: Execute

Follow the approved plan:

1. **Route to the appropriate agent(s)** based on the plan
2. **Write C# code** following all rules in `.claude/rules/`
3. **Set up scene elements** via MCP if needed (`batch_execute` for speed)
4. **Check console** via `read_console` after each major step for compilation errors
5. If errors are found, fix them before proceeding

Report progress at natural milestones (e.g., "Scripts written, setting up scene now...").

## Phase 4: Verify

Run the `unity-verifier` agent to perform a verify-fix loop:

1. **Review** all changed files against the unity-reviewer checklist
2. **Auto-fix** issues that are safe to fix automatically
3. **Re-verify** if fixes were applied (max 3 iterations)
4. **Run tests** via MCP if available

### Deslop Pass

After verification succeeds with no critical issues, perform a targeted code-bloat review on all files created or modified during this workflow. Specifically target:

1. **Unnecessary abstractions** — interfaces with one implementation, factory classes that create one type, wrapper classes that add no behavior
2. **Over-commenting** — comments that restate the code, obvious doc comments, commented-out code blocks
3. **Redundant error handling** — try/catch that just rethrows, null checks on values that can never be null, defensive code with no plausible failure mode
4. **Dead code** — unused private methods, unreachable branches, unused parameters
5. **Over-engineering** — generic solutions for non-generic problems, premature optimization patterns, unnecessary design patterns

Deslop rules:
- Only simplify, never add complexity
- Preserve all runtime behavior
- Do not touch code that existed before this workflow started
- If in doubt, leave it alone — false positives are worse than missed bloat
- Apply fixes directly, then re-check console via `read_console` to confirm no regressions

### Final Summary

Present a complete summary to the user:

```
## Workflow Complete

### What was built
- [list of features implemented]

### Files created/modified
- [file paths with brief descriptions]

### Verification results
- [auto-fixed issues]
- [remaining items for human review]

### Test results
- [compilation status, test pass/fail counts]

### Manual steps needed
- [any inspector assignments, scene references, etc.]

### How to test
- [step-by-step testing instructions]
```

## Design Principles

- **Each phase gate requires user confirmation** — never skip ahead
- **Prefer existing patterns** — match the project's established conventions
- **Minimal viable implementation** — don't overbuild on the first pass
- **Verify everything** — the verify phase is not optional
