---
name: unity-skillify
description: "Generate a new skill from accumulated session learnings. Analyzes patterns, drafts SKILL.md, validates structure."
user-invocable: true
args: topic_or_options
---

# /unity-skillify — Generate Skills from Learnings

Generate a new skill from accumulated session data: **$ARGUMENTS**

Parse `$ARGUMENTS`:
- If it starts with `--install`, the generated skill will be auto-placed in the correct directory
- The remaining text is the topic to generate a skill for

## Workflow

### Step 1: Load Learnings

Read `.claude/state/learnings.jsonl` (or `.claude/learnings.jsonl` as fallback for pre-v1.3.0 projects).

If the file doesn't exist or is empty, report that no learnings are available and suggest running sessions with `UNITY_HOOK_PROFILE=strict` to start collecting data.

### Step 2: Filter by Topic

Filter learning entries where:
- The `category` field matches the topic
- File paths in `patterns` relate to the topic
- The `branch` name contains the topic keyword
- Tool usage patterns suggest the topic area

### Step 3: Cross-Reference Existing Skills

Read all existing skills in `.claude/skills/` to avoid generating a duplicate. If a skill already covers this topic, report it and suggest updating the existing skill instead.

### Step 4: Synthesize Skill

Generate a complete SKILL.md with:

```yaml
---
name: [topic-kebab-case]
description: "[synthesized from learning patterns]"
globs: ["[derived from file patterns in learnings]"]
---
```

Content sections:
- **Overview** — what this skill covers (derived from learning patterns)
- **Patterns** — code patterns observed across sessions (with C# examples)
- **Common Mistakes** — issues that triggered hook warnings (from warnings data)
- **Best Practices** — patterns that appeared in successful sessions

### Step 5: Output

If `--install` flag:
1. Determine category (core/gameplay/systems/platform/genre/third-party) based on topic
2. Create directory `.claude/skills/[category]/[name]/`
3. Write SKILL.md there
4. Report: "Skill installed at .claude/skills/[category]/[name]/SKILL.md"

If no `--install` flag:
1. Output the complete SKILL.md content
2. Report: "Draft skill generated. To install, run: /unity-skillify --install [topic]"

## Rules

- Generated skills MUST have valid YAML frontmatter
- Generated skills MUST include at least one fenced code block example
- Generated skills MUST include a "Common Mistakes" or equivalent section
- Do NOT generate skills that duplicate existing skill coverage
- Keep generated skills focused and specific — one topic per skill
