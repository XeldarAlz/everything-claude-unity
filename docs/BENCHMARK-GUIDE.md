# Benchmark Guide

How to measure and compare structural correctness of agent output.

---

## What Benchmarks Measure

Benchmarks verify that Claude Code agents produce structurally correct Unity code when given standardized prompts. Each scenario defines:

- A **prompt** to give the agent
- **Expected files** that must exist (glob patterns)
- **Expected patterns** that must appear in specific files (regex)
- **Forbidden patterns** that must NOT appear (anti-patterns like singletons, coroutines, LINQ in gameplay)

The benchmarks do **not** invoke Claude Code. You run Claude Code manually with the scenario prompt, then point the evaluator at the output to score the result.

---

## How to Run

```bash
# Evaluate all scenarios against the current directory
bash benchmarks/run-benchmarks.sh

# Evaluate against a specific working directory
bash benchmarks/run-benchmarks.sh --workdir /path/to/agent/output

# Run a single scenario
bash benchmarks/run-benchmarks.sh --scenario simple-component

# Compare against a previous run
bash benchmarks/run-benchmarks.sh --compare benchmarks/results/previous.json
```

Each run writes a summary JSON to `benchmarks/results/YYYY-MM-DD-HHMMSS.json`.

---

## How to Add Scenarios

Create a JSON file in `benchmarks/scenarios/`:

```json
{
  "name": "scenario-id",
  "description": "Human-readable description of what this tests",
  "prompt": "The prompt to give Claude Code",
  "tags": ["architecture", "mvs"],
  "setup_files": {
    "relative/path.cs": "file contents pre-populated before eval"
  },
  "expected_files": ["**/SomeFile.cs"],
  "expected_patterns": [
    { "file": "**/SomeFile.cs", "pattern": "sealed class" }
  ],
  "forbidden_patterns": [
    { "file": "**/*.cs", "pattern": "StartCoroutine" }
  ]
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `name` | yes | Unique identifier (matches filename without `.json`) |
| `description` | yes | What the scenario tests |
| `prompt` | yes | The prompt to give the agent |
| `tags` | no | Categories for filtering |
| `setup_files` | no | Files to place in the workdir before evaluation |
| `expected_files` | no | Glob patterns for files that must exist |
| `expected_patterns` | no | `{file, pattern}` pairs that must match |
| `forbidden_patterns` | no | `{file, pattern}` pairs that must NOT match |

---

## How to Compare Results

Use the `--compare` flag to diff two runs:

```bash
bash benchmarks/run-benchmarks.sh --compare benchmarks/results/2024-01-15-143022.json
```

This shows regressions (scenarios that previously passed but now fail) and improvements (scenarios that previously failed but now pass). Use this to validate that changes to agents, skills, or rules do not degrade output quality.

---

## Workflow

1. Copy the `prompt` from a scenario JSON.
2. Run Claude Code with that prompt in a scratch Unity project.
3. Run `bash benchmarks/run-benchmarks.sh --workdir /path/to/scratch`.
4. Review the pass/fail summary and the saved results JSON.
