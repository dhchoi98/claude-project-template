# Claude Project Template

[한국어 문서](README.ko.md)

A lean **solo-developer** template for projects driven primarily by **Claude Code**, with **Codex** as a side-tool for boilerplate.

No team mode. No multi-session ticket board. No setup script. Clone, open Claude Code, run `/init`, and start working.

## What's Included

### Claude Code setup (`.claude/`)
- **commands/** — slash commands (`/init`, `/tasks`, `/plan`, `/phase-check`, `/review`, `/spec`, `/newfile`, `/cleanup`)
- **skills/** — reusable work patterns (`read-first`, `self-verify`, `tdd-loop`)
- **agents/** — subagent definitions (`code-reviewer`)
- **hooks/** — auto-context loaders (`session-start.sh`, `pre-compact.sh`) + pre-commit checks scaled by rigor
- **settings.json** — allow/deny command policy + hooks registration

### AI tool contract (`AGENTS.md`)
- Universal operating contract followed by Claude Code, Codex, and any other AI tool you bolt on.

### Codex setup (`.codex/`)
- **AGENTS.md** — Codex adapter rules
- **config.toml** — project-local Codex profiles
- **agents/** — role prompts (`explorer`, `reviewer`, `feature-worker`)

### GitHub automation (`.github/`)
- **workflows/** — auto-labeling, board sync, stale issue management
- **workflows/codex-pr-review.yml** — Codex PR auto-review (comment/report-only)
- **ISSUE_TEMPLATE/** — Feature, bug, task templates
- **PULL_REQUEST_TEMPLATE.md** — PR checklist
- **GIT_WORKFLOW.md** — branch/commit/issue/PR conventions

### Project foundations
- **CLAUDE.md** — solo developer rules + Claude Code/Codex tool division
- **PLAN.md** — phase-based roadmap template
- **docs/RIGOR.md** — engineering depth presets (mvp/production/enterprise)
- **.gitignore** — Python, Node, Go, Rust, Docker, IDE, OS defaults

## Usage

### 1) Create a repository from this template

On GitHub click **Use this template** → **Create a new repository**.

### 2) Clone and open Claude Code

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
claude
```

### 3) Run `/init`

In Claude Code, run:

```
/init
```

Claude will ask you:
- Project name + one-line description
- Project type (`general`, `web`, `cli`, `security`, `ml`, `scada`, `quant`)
- Engineering rigor (`mvp`, `production`, `enterprise`)
- Tech stack (if you know it)

…and then create the directory structure, `.project-config`, initialize PLAN.md, and brief you on the rigor level you chose.

### 4) Start working

The `SessionStart` hook auto-loads `PLAN.md`, `MISTAKES.md`, the most recent snapshot, and Git status into every new session. Just open Claude Code and ask it to start working.

## How rigor levels work

Set in `.project-config`:

```
PROJECT_RIGOR=mvp        # speed first, types/tests optional
PROJECT_RIGOR=production # contract-first, function signatures typed, core tests required
PROJECT_RIGOR=enterprise # full strict, TDD, clean architecture
```

`pre-commit` hook reads this value and scales its checks. Detailed rules in [docs/RIGOR.md](docs/RIGOR.md).

## Tool division (Claude Code / Codex)

| Tool | Role | Best for |
|------|------|----------|
| **Claude Code (CC)** | Main — design + implementation + review | Almost everything. Design, multi-file changes, debugging, refactor |
| **Codex** | Side — small implementations | Boilerplate, single-file functions, repetitive patterns. Use only to save CC tokens; CC always reads the result and self-verifies |

## Customization points

| File | What to customize |
|------|-------------------|
| `CLAUDE.md` | Project rules, glossary, stack |
| `AGENTS.md` | Universal AI tool contract |
| `.codex/config.toml` | Codex runtime profiles |
| `.project-config` | Rigor switch (used by hooks) |
| `.claude/settings.json` | Allow/deny command policy + hook registration |
| `.claude/commands/*.md` | Custom slash commands |
| `.claude/skills/*` | Project-specific reusable patterns |
| `.github/ISSUE_TEMPLATE/*.yml` | Issue forms |
| `.github/GIT_WORKFLOW.md` | Branching/release conventions |

## Documentation map

```
CLAUDE.md                    <- main project rules
AGENTS.md                    <- universal AI tool contract
PLAN.md                      <- phase-based roadmap
docs/
  RIGOR.md                   <- mvp/production/enterprise rules
  QUICKSTART.md              <- quickstart guide
  METHODOLOGY.md             <- coding methodology
  CHECKLISTS.md              <- checklists
.codex/
  AGENTS.md                  <- Codex adapter rules
  config.toml                <- Codex runtime settings
  agents/                    <- Codex role prompts
.work/
  MISTAKES.md                <- mistakes log (auto-loaded by SessionStart hook)
  decisions/                 <- ADRs
  snapshots/                 <- auto-saved by PreCompact hook
.github/
  GIT_WORKFLOW.md            <- Git/PR/issue conventions
```

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh auth login` completed)
- (optional) [Codex CLI](https://github.com/openai/codex) for offloaded boilerplate work
- (optional) `ruff`, `mypy` for Python
- (optional) `prettier`, `eslint` for JavaScript/TypeScript
- (optional) `gofmt`, `go vet` for Go
- (optional) `cargo clippy`, `cargo fmt` for Rust
