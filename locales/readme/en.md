# Claude Project Template

[한국어 문서](README.ko.md)

A universal development template that runs **Claude Code + Codex + GitHub automation** together.
Suitable for hackathons, production services, SCADA, quant trading, and security projects.

## What's Included

### Claude Code setup (`.claude/`)
- **commands/** — 13 slash commands (`/start`, `/end`, `/claim`, `/tasks`, `/plan`, `/review`, `/session`, `/sync`, `/handoff`, `/spec`, `/newfile`, `/cleanup`, `/phase-check`)
- **hooks/** — pre-commit checks by rigor level, multi-language lint/format hooks
- **settings.json** — default allow/deny command policy (Python, Node, Go, Rust, Docker, Make, etc.)

### Universal agent contract (`AGENTS.md`, `docs/steering/`)
- **AGENTS.md** — tool-agnostic operating contract (SWMR: Single Writer, Many Reviewers)
- **docs/steering/** — repository contract, write boundaries, review gates, hotspot policy

### Codex setup (`.codex/`)
- **AGENTS.md** — Codex adapter rules (execution/audit modes)
- **config.toml** — project-local Codex runtime profiles
- **agents/** — role prompts (`explorer`, `reviewer`, `feature-worker`)

### GitHub automation (`.github/`)
- **workflows/** — automatic labeling, board sync, stale issue management
- **workflows/codex-pr-review.yml** — Codex PR auto-review (comment/report-first)
- **ISSUE_TEMPLATE/** — Feature Request, Bug Report, Task templates
- **PULL_REQUEST_TEMPLATE.md** — PR checklist
- **GIT_WORKFLOW.md** — branch/commit/issue/PR conventions

### Project foundations
- **CLAUDE.md** — project rules (mode/rigor/domain-aware)
- **PLAN.md** — implementation planning template
- **.gitignore** — Python, Node, Go, Rust, Docker, IDE, OS defaults + domain extras

## Usage

### 1) Create a repository from this template

On GitHub, click **Use this template** → **Create a new repository**.

### 2) Clone and initialize

```bash
git clone git@github.com:<your-user>/<your-repo>.git
cd <your-repo>
chmod +x setup.sh init-labels.sh
```

### 3) Run setup

```bash
./setup.sh <project-name> <github-username> [options]
```

#### Real examples

```bash
# Hackathon (fast start)
./setup.sh hackathon dhchoi98 --type web --rigor mvp

# SCADA delivery (enterprise quality)
./setup.sh scada-hmi dhchoi98 --type scada --rigor enterprise --mode team

# Quant trading (production quality, contract-first)
./setup.sh quant-bot dhchoi98 --type quant --rigor production

# Security lab / CTF
./setup.sh ctf-2026 dhchoi98 --type security --rigor mvp

# ML project
./setup.sh ml-project dhchoi98 --type ml --rigor production

# Team project (5-session parallel workflow)
./setup.sh my-service dhchoi98 --type web --rigor production --mode team
```

### Setup options

#### Project type (`--type`)

| Type | Generated directories | Best for |
|------|------------------------|----------|
| `general` (default) | `src/ tests/ docs/` | general-purpose projects |
| `web` | `backend/ frontend/ shared/ docs/ tests/` | web services |
| `cli` | `cmd/ internal/ docs/ tests/` | CLI/system tools |
| `security` | `tools/ exploits/ notes/ reports/` | CTF, security labs, pentesting |
| `ml` | `notebooks/ data/ models/ src/ tests/` | ML/AI projects |
| `scada` | `backend/ hmi/ plc/ drivers/ docs/ tests/` | industrial control, SCADA/HMI |
| `quant` | `core/ strategies/ data/ dashboard/ tests/` | quant trading, finance |

#### Engineering rigor (`--rigor`)

| Rigor | Type rules | Tests | Architecture | Good fit |
|------|------------|-------|--------------|----------|
| `mvp` (default) | recommended (optional) | optional | flexible | hackathons, PoC |
| `production` | function signatures required | core modules required | contract-first, layer separation | production services |
| `enterprise` | strict typing including variables | TDD + coverage targets | clean architecture, DIP | long-lived large systems |

#### Contract-first workflow (production/enterprise)

```
Step 1: Define contracts (human-led)
  → interfaces/protocols, types, data models

Step 2: Write tests (AI-assisted)
  → "Write contract tests for this interface"

Step 3: Implement (AI-assisted)
  → "Implement code that passes these tests"
```

#### Workflow mode (`--mode`)

| Mode | Description |
|------|-------------|
| `solo` (default) | solo development, plan mode optional, no ticket system |
| `team` | multi-session parallel delivery, 5-session ticket workflow, plan mode required |

### 4) Create GitHub labels

```bash
./init-labels.sh
```

### 5) Clean up and create your first commit

```bash
rm setup.sh init-labels.sh
# Customize CLAUDE.md and PLAN.md for your project
git add -A && git commit -m "chore: initial project setup"
```

## Customization points

| File | What to customize |
|------|-------------------|
| `AGENTS.md` | tool-agnostic operating contract, SWMR policy |
| `CLAUDE.md` | project glossary, architecture, stack, hard rules |
| `.codex/config.toml` | Codex runtime policy, profiles, agent mapping |
| `.project-config` | rigor/mode switches (used by hooks) |
| `.claude/settings.json` | allow/deny command policy |
| `.claude/commands/*.md` | custom project commands |
| `.github/ISSUE_TEMPLATE/*.yml` | issue form fields/dropdowns |
| `.github/GIT_WORKFLOW.md` | branching/release conventions |

## Documentation map

```
AGENTS.md                    <- universal contract for all AI tools
CLAUDE.md                    <- Claude-specific project instructions
PLAN.md                      <- planning template
docs/
  steering/
    repo-contract.md         <- repository operating contract
    write-boundaries.yaml    <- write boundary rules
    review-gates.yaml        <- quality gates
    hotspot-files.yaml       <- high-conflict file policy
  QUICKSTART.md              <- quickstart + learning guide
  METHODOLOGY.md             <- coding methodology
  CHECKLISTS.md              <- checklists
.codex/
  AGENTS.md                  <- Codex adapter rules
  config.toml                <- Codex runtime settings
  agents/                    <- Codex role prompts
.work/
  BOARD.md                   <- ticket board (team mode)
  WORKFLOW_GUIDE.md          <- multi-session workflow guide
  MISTAKES.md                <- mistakes log
.github/
  GIT_WORKFLOW.md            <- Git/PR/issue conventions
```

## Requirements

- [Claude Code](https://claude.com/claude-code) CLI
- [GitHub CLI](https://cli.github.com/) (`gh auth login` completed)
- (optional) `ruff`, `mypy` for Python
- (optional) `prettier`, `eslint` for JavaScript/TypeScript
- (optional) `gofmt`, `go vet` for Go
- (optional) `cargo clippy`, `cargo fmt` for Rust
