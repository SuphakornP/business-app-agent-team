---
name: agent-team-start
description: Start, supervise, and query a guided phase-gated business app agent team without asking the user to type shell commands. Use when the user wants to start an agent team, choose phase/agents/model tier/effort, spawn Herdr/Pi workers, check progress, ask the supervisor what is happening, or continue an in-progress multi-agent workflow.
---

# Agent Team Start

Use this skill as the user-facing entry point for the agent team. Do not ask the user to memorize or type shell commands; run the package scripts yourself.

## Intent Detection

If the user asks any status-style question, run status mode:

- "งานถึงไหนแล้ว"
- "ตอนนี้ทำอะไรอยู่"
- "มี blocker ไหม"
- "progress เป็นยังไง"
- "ask supervisor"
- "status"

If the user asks to start, run, spawn, continue, or plan an agent team, run start mode.

## Start Mode

1. Identify the target project path. Use the current directory if the user does not specify one.
2. Identify phase or preset:
   - vague idea or new app: `discovery`
   - scope/requirements: `planning`
   - user journey/screens: `flow`
   - architecture/data/API: `blueprint`
   - code work: `implementation`
   - review/check: `review`
3. Choose model tier:
   - `strong`: default for this kit. Uses the configured Pi GPT-5.5 xhigh model.
   - `balanced`: normal work with lower thinking level.
   - `free`: lightweight or cost-sensitive work with lower thinking level.
4. Choose effort:
   - `low`: small/routine.
   - `medium`: normal work.
   - `high`: default for this kit, complex work, or high-risk work.
5. Choose run mode:
   - Use `--execute` only when the user clearly wants to start agents now.
   - Use `--dry-run` when previewing, planning, or when Herdr/Pi availability is unclear.
6. Run:

```bash
scripts/agent-team-start.sh <project-path> --preset <preset> --tier <tier> --effort <effort> --goal "<goal>" --execute
```

Use `--dry-run` instead of `--execute` for preview mode.

## Status Mode

Run:

```bash
scripts/ask-supervisor.sh <project-path> "<question>"
```

Then summarize the output for the user. If Herdr is running and a supervisor agent exists, the script sends a `[STATUS_REQ]` to the supervisor. If not, it still records the question and reports local artifact status.

## Supervisor Question Behavior

When a user asks status during a run:

1. Read `.agent-team/current-phase.md`, `.agent-team/task-board.md`, `.agent-team/last-run.md`, `.agent-team/supervisor-status.md`, and `.agent-team/agent-results/*.md`.
2. If Herdr is available, ask the supervisor agent with `scripts/ask-supervisor.sh`.
3. Answer with:
   - current phase
   - active agents
   - what each agent is doing, if known
   - completed artifacts
   - blockers/open questions
   - next expected step

## Presets

- `discovery`: `discovery-analyst`
- `planning`: `product-manager`, `qa-risk-reviewer`
- `flow`: `ux-flow-designer`, `qa-risk-reviewer`
- `blueprint`: `solution-architect`, `data-modeler`, `qa-risk-reviewer`
- `implementation`: `implementation-worker`, `code-reviewer`
- `review`: `qa-risk-reviewer`, `code-reviewer`

## Safety

- Do not start implementation before blueprint approval.
- Do not bypass human approval gates for migrations, auth, production, paid APIs, credentials, sensitive data, destructive operations, or irreversible git actions.
- If a user asks for status, do not spawn new workers unless they explicitly ask to continue or start the next phase.
