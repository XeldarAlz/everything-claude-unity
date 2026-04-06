---
name: learner
description: "Post-debugging knowledge extraction — captures non-obvious, codebase-specific learnings that pass quality gates. Invoke after resolving tricky bugs or discovering surprising behavior."
alwaysApply: false
---

# Learner — Knowledge Extraction

After resolving a non-trivial bug or discovering surprising behavior, use this skill to extract and preserve the learning. Not every fix is worth saving — apply the quality gates strictly.

## When to Invoke

Consider extraction when:
- A debugging session took more than 3 back-and-forth exchanges
- The root cause was surprising or counterintuitive
- The fix required understanding a project-specific convention or quirk
- You discovered an undocumented interaction between systems

## Quality Gates

ALL three gates must pass. If any fails, do not save the learning.

### Gate 1: Not Googleable
Could someone find this answer with a 5-minute web search?

- **Fails:** "Use CompareTag instead of == for tag comparison" (standard Unity knowledge)
- **Fails:** "Cache GetComponent in Awake for performance" (well-documented best practice)
- **Passes:** "Our EventChannel ScriptableObjects must be in a Resources/ folder or they get stripped in IL2CPP builds because nothing in code holds a direct reference"
- **Passes:** "The CombatSystem processes damage in LateUpdate, not Update, so any health modification in Update will be overwritten"

### Gate 2: Codebase-Specific
Is this specific to THIS project's architecture, conventions, or quirks?

- **Fails:** "UniTask is better than coroutines" (generic advice)
- **Fails:** "VContainer uses constructor injection" (library documentation)
- **Passes:** "The InventorySystem expects item IDs to be registered in ItemRegistry before any InventoryModel is created — initialization order matters"
- **Passes:** "Scene transitions must go through SceneSystem.LoadAsync, not SceneManager directly, because SceneSystem handles LifetimeScope cleanup"

### Gate 3: Required Real Effort
Did this take actual debugging effort to discover?

- **Fails:** Missing semicolon, typo in field name, wrong import
- **Fails:** Obvious null reference from unassigned SerializeField
- **Passes:** Subtle race condition between async scene load and VContainer injection
- **Passes:** Serialization depth limit causing data truncation in nested inventory structure

## Classification

Categorize each learning as one of:

**Expertise** — Domain knowledge about WHY something works a certain way.
> "The damage formula in CombatSystem uses a lookup table because the designer wanted non-linear scaling curves that couldn't be expressed as a simple formula."

**Workflow** — Procedural knowledge about HOW to do something in this project.
> "To add a new enemy type: 1) Create SO in Assets/Data/Enemies from EnemyDefinition template, 2) Add entry to EnemyRegistry SO, 3) Create prefab variant from EnemyBase prefab, 4) Register in WaveSystem spawn table."

## Output Format

```markdown
### [Concise Title]
**Type:** expertise | workflow
**Context:** [what triggered the discovery — the bug, task, or question]
**Learning:** [the non-obvious knowledge, 1-3 sentences]
**Files:** [relevant file paths]
```

## Storage

Append the learning to the project's `CLAUDE.md` file under a `## Project Learnings` section. If that section does not exist, create it at the end of the file.

Each entry is appended chronologically. Never overwrite or edit previous entries — they form a timeline of discoveries.

## Anti-Patterns — Do NOT Save

- Generic Unity best practices (already covered by `.claude/rules/`)
- Standard library/package usage (read the docs instead)
- Temporary workarounds (these should be tracked as TODOs, not learnings)
- Obvious things ("MonoBehaviours must be attached to GameObjects")
- Preferences or style choices (already covered by `.claude/rules/csharp-unity.md`)
