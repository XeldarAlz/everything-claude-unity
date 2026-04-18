---
name: unity-learn
description: "Review accumulated session learnings, extract recurring patterns, and draft new skills from session data."
user-invocable: true
args: subcommand
---

# /unity-learn — Learning Pipeline

Manage and leverage accumulated session learnings: **$ARGUMENTS**

This command works with the data collected by the `auto-learn.sh` hook (strict profile) which records session patterns to `.claude/state/learnings.jsonl` after each session. For pre-v1.3.0 projects, the file may be at `.claude/learnings.jsonl` instead.

## Subcommands

### `review` (default)

Read `.claude/state/learnings.jsonl` and present a dashboard summarizing accumulated data:

1. **Read the learnings file** at `.claude/state/learnings.jsonl` (or `.claude/learnings.jsonl` as fallback for pre-v1.3.0 projects)
2. **Aggregate and present:**

```markdown
## Session Learning Dashboard

**Total sessions:** [count]
**Date range:** [earliest] to [latest]
**Total duration:** [hours]h [minutes]m

### File Activity
| Category | Total Edits | Sessions |
|----------|-------------|----------|
| Models   | [count]     | [count]  |
| Views    | [count]     | [count]  |
| Systems  | [count]     | [count]  |
| Tests    | [count]     | [count]  |
| Shaders  | [count]     | [count]  |
| Editor   | [count]     | [count]  |

### Session Categories
| Category     | Count | Avg Duration |
|-------------|-------|--------------|
| bug-fix     | [n]   | [m]m         |
| performance | [n]   | [m]m         |
| architecture| [n]   | [m]m         |
| workflow    | [n]   | [m]m         |
| integration | [n]   | [m]m         |

### Tool Usage
| Tool  | Total Calls | Avg per Session |
|-------|-------------|-----------------|
| Edit  | [count]     | [avg]           |
| Read  | [count]     | [avg]           |
| Bash  | [count]     | [avg]           |
| ...   | ...         | ...             |
```

### `extract`

Analyze the learnings log for recurring patterns and apply confidence scoring:

1. **Read all entries** from `.claude/state/learnings.jsonl` (or `.claude/learnings.jsonl` as fallback)
2. **Group by category** (bug-fix, performance, architecture, workflow, integration)
3. **Identify recurring patterns:**
   - Files that appear across multiple sessions → likely hotspots
   - Categories that dominate → project's current focus area
   - Tool usage patterns → workflow optimization opportunities
   - MVS balance → are Models, Views, and Systems equally maintained?
4. **Apply confidence scoring:**
   - **High confidence** (3+ sessions): Pattern is well-established, likely a real project convention
   - **Medium confidence** (2 sessions): Pattern is emerging, worth noting but may be coincidental
   - **Low confidence** (1 session): Single observation, keep but don't act on yet
5. **Present findings:**

```markdown
## Extracted Patterns

### High Confidence
- [pattern description] (seen in N sessions)

### Medium Confidence
- [pattern description] (seen in N sessions)

### Low Confidence
- [pattern description] (seen in 1 session)

### Hotspot Files
- [file path] — edited in N sessions

### Recommendations
- [actionable suggestion based on patterns]
```

### `draft-skill <topic>`

Generate a draft SKILL.md from extracted patterns:

1. **Filter learnings** relevant to `<topic>` (fuzzy match on file paths, categories, and tool patterns)
2. **Synthesize** recurring patterns into a cohesive skill document
3. **Generate** a complete SKILL.md with proper frontmatter:

```yaml
---
name: [derived-from-topic]
description: "[synthesized description from patterns]"
globs: ["[relevant file patterns]"]
---
```

4. **Output** the draft to stdout with instructions:
   ```
   Draft skill generated. To install:
     1. Create directory: .claude/skills/core/[skill-name]/
     2. Save the above content to: .claude/skills/core/[skill-name]/SKILL.md
     3. Review and refine the content before use
   ```

### `analytics`

Deep session analytics — aggregate learnings into actionable metrics and trends:

1. **Read all entries** from `.claude/state/learnings.jsonl` (or `.claude/learnings.jsonl` as fallback for pre-v1.3.0 projects)
2. **Present:**

```markdown
### Session Analytics

**Time Analysis**
| Metric | Value |
|--------|-------|
| Total sessions | [count] |
| Total time | [hours]h [minutes]m |
| Avg session | [minutes]m |
| Longest session | [minutes]m |

**Agent Usage** (from agent_context data if available)
| Agent | Sessions | Avg Duration |
|-------|----------|--------------|
| [agent] | [count] | [minutes]m |

**Warning Hotspots** (from warnings_fired data if available)
| Warning | Count | Files |
|---------|-------|-------|
| [hook:message] | [count] | [affected files] |

**File Hotspots** (files edited across multiple sessions)
| File | Sessions | Category |
|------|----------|----------|
| [path] | [count] | [category] |

**Trends**
- Average session duration: [trending up/down/stable]
- Warning frequency: [trending up/down/stable]
- Most active category: [category]
```

3. **Suggest next actions:**
   - Use `/unity-skillify <topic>` to generate a skill from these patterns.
   - Use `/unity-learn extract` to see pattern confidence levels.

## Rules

- **Read-only by default** — `review`, `extract`, and `analytics` only read and analyze, they never modify files
- **`draft-skill` outputs but does not save** — the user must review and place the file themselves
- **No data, no output** — if `.claude/state/learnings.jsonl` (or `.claude/learnings.jsonl`) doesn't exist or is empty, say so clearly
- **Privacy** — learnings are project-local and never sent anywhere
