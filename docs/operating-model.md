# Operating Model

This kit uses a supervisor-worker pattern. The supervisor owns sequencing, evidence, risk, and approval. Workers own bounded specialist artifacts.

## Principles

- Start from real user scenarios, not feature lists.
- Keep phase order strict until the blueprint is approved.
- Use parallel workers only when upstream artifacts are clear enough to prevent guessing.
- Make every worker write artifacts and a standard agent result.
- Close phases with evidence: files, checks, decisions, and risk status.
- Escalate high-impact uncertainty to a human instead of burying it in assumptions.

## Default Flow

1. Human gives idea or project request.
2. Supervisor runs Intake and Discovery.
3. Discovery asks clarifying questions and records assumptions.
4. Product Manager scopes Phase 1.
5. UX Flow Designer maps journeys and screen states.
6. Solution Architect and Data Modeler create the technical blueprint.
7. QA Risk Reviewer checks ambiguity, risk, and test coverage.
8. Supervisor asks for approval where required.
9. Implementation workers make changes in bounded tasks.
10. Reviewer and QA verify before delivery.

## Parallelism Rules

Use sequential work for:

- Discovery before scope.
- Scope before UX flow.
- UX flow before architecture and data model.
- Blueprint approval before implementation.

Use parallel work for:

- QA review after a draft artifact exists.
- Architecture and data model review after flows are stable.
- Frontend, backend, tests, and docs implementation after task boundaries are clear.

## Supervisor Responsibilities

- Create task briefs.
- Select workers and expected artifacts.
- Read worker output and artifacts.
- Validate gates with `scripts/validate-artifacts.sh`.
- Update `.agent-team/` state files.
- Ask human approval for high-impact decisions.
- Retry or split tasks when output lacks evidence.
- Answer human status questions during active runs by reading `.agent-team/` state, asking workers for `[STATUS_REQ]` updates when needed, and updating `.agent-team/supervisor-status.md`.

## Worker Responsibilities

- Stay inside assigned scope.
- Produce required artifacts.
- Record assumptions, risks, checks, and open questions.
- End with the standard agent result contract.
- Do not communicate directly with other workers unless the supervisor explicitly delegates that channel.

## Status Questions

Users can ask the supervisor for progress while workers are running. A status request must not start a new phase or change scope.

The supervisor should report:

- current phase
- active agents and their current work
- completed artifacts
- blockers and open questions
- next expected step
- confidence or ETA, if known

The durable status artifact is `.agent-team/supervisor-status.md`.
