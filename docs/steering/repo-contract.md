# Repo Contract (Lean Captain Stack)

## Principle
- Human is captain: sets goals, priority, and final approval.
- AI agents are crew: implementation, verification, and improvement proposals.

## Delivery Loop
1. Objective + constraints are clarified by human
2. Planner slices feature and maps dependencies
3. Single writer implements one approved slice
4. Reviewers validate against quality gates
5. Human approves merge

## Guardrails
- main branch direct edits: prohibited
- one slice per PR (unless explicitly bundled)
- report-first automation before write automation
