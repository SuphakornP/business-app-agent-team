---
name: agent-orchestration
description: Coordinate a phase-gated multi-agent delivery workflow with a supervisor, specialist workers, Herdr panes, Pi prompts, artifact contracts, validation gates, approval policy, and delivery evidence.
---

# Agent Orchestration

Use this skill as the supervisor playbook. The supervisor controls phase order, assigns workers, validates evidence, and escalates human approval.

## Core Loop

1. Define the current phase and gate.
2. Define required artifacts and done criteria.
3. Assign one bounded task to each specialist.
4. Wait for worker output.
5. Read artifacts and the worker result contract.
6. Validate evidence against the gate checklist.
7. Retry, ask a reviewer, escalate, or close the phase.
8. Update `.agent-team/task-board.md`, `.agent-team/decision-log.md`, `.agent-team/risk-register.md`, and `.agent-team/current-phase.md`.

## Phase Order

1. Intake
2. Discovery
3. Scope
4. User Journey and Screen Flow
5. Requirements
6. Architecture and Data Model
7. Implementation Plan
8. Implementation
9. QA and Review
10. Delivery Summary

## Specialist Defaults

- `discovery-analyst`: ambiguity, real scenarios, questions, use cases.
- `product-manager`: scope, priority, requirements, out-of-scope boundaries.
- `ux-flow-designer`: journeys, screens, state coverage.
- `solution-architect`: system boundary, API, integration, security, permissions.
- `data-modeler`: entities, fields, data dictionary, migration plan.
- `qa-risk-reviewer`: ambiguity, edge cases, risk, acceptance criteria, test coverage.
- `implementation-worker`: code changes and tests after blueprint approval.
- `code-reviewer`: independent review after implementation.

## Never Mark Done Unless

- Required artifacts exist and contain project-specific content.
- Acceptance criteria are satisfied.
- Tests or review checks are recorded.
- Risks and assumptions are documented.
- Open questions are resolved or explicitly escalated.
- The next phase input is clear.

## Escalate to Human

Ask for approval before:

- Changing business policy.
- Creating or changing database migrations.
- Touching authentication, authorization, payment, legal, health, financial, or sensitive personal data.
- Adding paid APIs, external services, credentials, or production deployment changes.
- Doing destructive file/data operations or irreversible git operations.
- Starting a large refactor beyond assigned scope.
- Proceeding when two agents disagree on a critical design decision.

## Supervisor Output Per Phase

End each phase with:

- Phase Summary
- Artifacts
- Decisions
- Risks
- Open Questions
- Recommendation
- Approval Request, if needed

## Worker Result Contract

Require every worker to respond in this format:

```markdown
STATUS: done | blocked | needs_approval | failed
CONFIDENCE: 0-100
TASK_RECEIVED:
WHAT_I_DID:
ARTIFACTS_CREATED_OR_UPDATED:
KEY_DECISIONS:
ASSUMPTIONS:
RISKS:
TESTS_OR_CHECKS:
OPEN_QUESTIONS:
NEXT_RECOMMENDED_ACTION:
```
