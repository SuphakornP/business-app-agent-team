---
name: ux-flow-design
description: Design business app user journeys, screen flows, role-specific actions, system responses, validation, and empty/error/loading/success states before architecture or database design.
---

# UX Flow Design

Use this skill after scope is clear and before architecture or data model work.

## Required Flow Shape

For every critical workflow, include:

- User Role
- Entry Point
- Screen 1 -> Screen 2 -> Screen 3
- User Action
- System Response
- Validation
- Error State
- Empty State
- Loading State
- Success State
- Permission or visibility rule
- Related requirement IDs

## Required Artifacts

Create or update:

- `docs/ux/01-user-journey.md`
- `docs/ux/02-screen-flow.md`
- `docs/ux/03-state-and-empty-cases.md`
- `.agent-team/agent-results/ux-flow-designer.md`

## Rules

- Do not start from database tables or API endpoints.
- Cover each user role separately when the workflow differs by role.
- Include failure paths, not only happy paths.
- Mark unresolved policy or permission decisions as open questions.
- Prefer explicit screen-to-screen transitions over abstract UX descriptions.

## Done Criteria

The flow phase is done only when each Must Have use case has a journey, screen flow, validation, and error/empty/loading/success coverage.

## Agent Result

End with the standard agent result contract:

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
