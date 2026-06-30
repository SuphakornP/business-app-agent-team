---
name: system-discovery
description: Discover real business problems, workflows, users, pain points, success metrics, assumptions, risks, and clarifying questions before designing a web app, internal tool, approval workflow, CRM, dashboard, ERP-lite system, or business process software.
---

# System Discovery

Use this skill when the idea is still a business problem, feature request, or vague system concept. Do not design the system yet.

## Rules

- Start from real user scenarios, not feature lists.
- Identify current workflow before proposing a new workflow.
- Treat missing policy, ownership, permission, and data definitions as blockers to design.
- Ask clarifying questions before scope, UX, architecture, or data model work.
- Record assumptions and risks instead of hiding them inside confident prose.

## Process

1. Identify the business problem and who feels it.
2. Identify real user roles and decision owners.
3. Map the current workflow, including manual steps and handoffs.
4. Identify pain points: time loss, error, rework, approval delay, duplicated data, missing visibility.
5. Define success criteria and measurable outcomes.
6. List assumptions, constraints, risks, and dependencies.
7. Ask clarifying questions grouped by business policy, user workflow, data, permissions, integration, and delivery.
8. Convert confirmed answers into use cases.

## Required Artifacts

Create or update:

- `docs/product/01-discovery.md`
- `docs/product/02-clarifying-questions.md`
- `docs/product/03-use-cases.md`
- `.agent-team/agent-results/discovery-analyst.md`

## Discovery Output

Include:

- Problem Statement
- Real Scenario
- User Roles
- Current Workflow
- Pain Points
- Success Criteria
- Clarifying Questions
- Assumptions
- Risks
- Recommended Next Phase

## Done Criteria

Discovery is done only when the primary user, current workflow, pain points, and success criteria are explicit. If critical policy or permission questions remain unanswered, return `STATUS: needs_approval` instead of `done`.

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
