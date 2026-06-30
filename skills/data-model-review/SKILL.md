---
name: data-model-review
description: Design or review business app entities, data dictionary fields, relationships, retention, audit fields, migration plans, and traceability back to use cases, screens, reports, and permissions.
---

# Data Model Review

Use this skill only after user flows and requirements are clear.

## Rules

- Do not start from database design before workflow design.
- Map every entity to a use case, screen, report, permission rule, or integration.
- Map every field to a reason and owner.
- Include auditability for approval, assignment, status, and policy-sensitive workflows.
- Treat migration, destructive changes, and sensitive data as human approval gates.

## Required Artifacts

Create or update:

- `docs/data/01-entity-model.md`
- `docs/data/02-data-dictionary.md`
- `docs/data/03-migration-plan.md`
- `.agent-team/agent-results/data-modeler.md`

## Entity Review Checklist

For each entity, include:

- Purpose
- Source use case
- Related screens
- Owner role
- Key fields
- Relationships
- Status lifecycle
- Permission implications
- Reporting needs
- Retention or deletion rule, if known

## Field Review Checklist

For each field, include:

- Type
- Required or optional
- Validation
- Allowed values
- Source of truth
- Reason for existence
- Screen or workflow that uses it
- Sensitive data classification

## Done Criteria

Data model work is done only when entities and fields trace back to approved flows and critical migration/sensitive-data questions are resolved or escalated.

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
