# Benchmarks

Measures **structural correctness** of Claude Code agent output when working on
Unity projects. Each scenario defines a prompt, the files/patterns the agent
should produce, and patterns it must avoid.

The runner does **not** invoke Claude Code. You run Claude Code manually with the
benchmark prompt, then point the evaluator at the working directory to score the
result.

## Quick start

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

## Adding a scenario

Create a JSON file in `benchmarks/scenarios/`. Schema:

```json
{
  "name": "scenario-id",
  "description": "Human-readable description",
  "prompt": "The prompt to give Claude Code",
  "tags": ["architecture", "mvs"],
  "setup_files": {
    "relative/path.cs": "file contents (optional, pre-populated before eval)"
  },
  "expected_files": ["**/SomeFile.cs"],
  "expected_patterns": [
    { "file": "**/SomeFile.cs", "pattern": "regex pattern" }
  ],
  "forbidden_patterns": [
    { "file": "**/*.cs", "pattern": "regex that must NOT match" }
  ]
}
```

### Fields

| Field               | Required | Description                                       |
|---------------------|----------|---------------------------------------------------|
| `name`              | yes      | Unique identifier (matches filename without .json)|
| `description`       | yes      | What the scenario tests                           |
| `prompt`            | yes      | The prompt to give the agent                      |
| `tags`              | no       | Categories for filtering                          |
| `setup_files`       | no       | Files to place in the workdir before evaluation   |
| `expected_files`    | no       | Glob patterns for files that must exist           |
| `expected_patterns` | no       | `{file, pattern}` pairs that must match           |
| `forbidden_patterns`| no       | `{file, pattern}` pairs that must NOT match       |

## Results

Each run writes a summary JSON to `benchmarks/results/YYYY-MM-DD-HHMMSS.json`.
Use `--compare` to diff two runs and see regressions or improvements.

## Workflow

1. Copy the `prompt` from a scenario JSON.
2. Run Claude Code with that prompt in a scratch Unity project.
3. Run `bash benchmarks/run-benchmarks.sh --workdir /path/to/scratch`.
4. Review the pass/fail summary and the saved results JSON.
