---
name: unity-skill-stocktake
description: "Audit all skills and agents in .claude/ for duplicates, stale references, never-loaded entries, broken globs, and frontmatter issues. Produces a cleanup report without modifying anything."
user-invocable: true
args: none
---

# /unity-skill-stocktake — Meta-Maintenance Audit

Scan `.claude/skills/` and `.claude/agents/` for hygiene issues. This is a read-only audit — the output is a report the user can act on.

## Steps

### 1. Enumerate entries

- Skills: `.claude/skills/**/SKILL.md` (recursive; categorized by parent directory).
- Agents: `.claude/agents/*.md`.
- Commands: `.claude/commands/*.md` (for cross-reference when checking whether skills are referenced).

For each file, parse the YAML frontmatter via a line scan (everything between the first pair of `---` lines).

### 2. Frontmatter validation

Flag any skill/agent/command missing required fields:

- Skill: `name`, `description`. `alwaysApply` and `globs` are optional but `globs` is recommended.
- Agent: `name`, `description`, `model`, `tools`. `color` optional.
- Command: `name`, `description`.

Flag any `name` that doesn't match the filename stem.

### 3. Duplicate / near-duplicate detection

Two-pass:

1. Exact duplicate `name` across entries → hard error.
2. Description similarity — compute token overlap (lowercase, split on non-word) between every pair of descriptions in the same category. Flag pairs with >=60% overlap or the first sentence starting identically.

Example to call out:
> `skills/gameplay/object-pooling` and `skills/gameplay/pool-allocator` — descriptions share 14/18 tokens; consider merging.

### 4. Glob reachability

For every `globs:` entry in every skill, check whether *any* matching file exists under the project root that is NOT inside `.claude/`.

- Glob with zero matches → "stale glob" warning.
- Glob that matches only `.claude/` itself → probably a meta-skill; not a warning, but note.

### 5. Reference audit

- For every skill, check whether its `name` is referenced by any agent (`skills:` field) or command (markdown body). A skill never referenced AND with no `globs:` that match real files is a candidate for removal.
- For every agent, check whether it's referenced from any command. Orphaned agents are acceptable (users invoke directly) but worth listing.

### 6. Load-history audit (best effort)

If `.claude/state/learnings.jsonl` or `.claude/state/instincts/observations.jsonl` exist, check whether each skill has been mentioned or auto-loaded in the past N sessions (N = 10 by default). Skills with zero recent loads are candidates for demotion or deletion.

If the learnings file doesn't exist, skip this step and note it.

### 7. Stale code references

For each skill/agent, scan its body for:
- File paths (`.claude/...` or `Assets/...`) that no longer exist.
- API references (Unity namespaces) that may have been deprecated (flag only if the pattern `[Obsolete]` appears in local code).

Non-blocking; surface as "needs manual review".

## Report format

```markdown
# Skill Stocktake — <date>

**Scanned:** <n> skills, <n> agents, <n> commands

## Frontmatter issues (<count>)
- `skills/<path>/SKILL.md` — missing `description`
- `agents/<name>.md` — `model` is `haiku` but tools include MCP writes (potential mismatch)

## Duplicates / near-duplicates (<count>)
- ...

## Stale globs (<count>)
- `skills/platform/mobile-input` — globs `["Assets/Input/**/*.cs"]` match 0 files

## Never-referenced skills (<count>)
- `skills/<name>` — not referenced by any agent/command and globs match 0 files

## Orphaned agents (<count>)
- `agents/<name>` — not referenced from any command (informational)

## Unused in recent sessions (<count>, last 10 sessions)
- `skills/<name>` — 0 loads; `skills/<name>` — 0 loads

## Stale code refs (<count>)
- ...

## Summary
- Remove candidates: <list>
- Merge candidates: <pairs>
- Needs review: <list>
```

End with:

> No changes applied. Review each candidate; remove/merge manually, or run `/unity-skillify` to consolidate.

## Rules

- **Read-only.** Never modify, delete, or move files.
- **Fail soft.** If a YAML block is malformed, list the file as "unparseable" and continue.
- **Efficient.** Use `grep -l` and `find` rather than reading every file fully when possible.
- **Do not auto-fix.** The user decides which candidates to act on.
