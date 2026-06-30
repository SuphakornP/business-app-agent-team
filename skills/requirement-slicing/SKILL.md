---
name: requirement-slicing
description: Convert discovery output into scoped business application requirements, MVP slices, acceptance criteria, out-of-scope boundaries, and open questions for phased delivery.
---

# Requirement Slicing

Use this skill after discovery has produced real use cases and unresolved questions are known.

## Buckets

- Must Have: the first usable version fails without it.
- Should Have: valuable but not required for the first usable version.
- Later: intentionally deferred to a later phase.
- Out of Scope: explicitly excluded so agents do not build it accidentally.
- Open Questions: unresolved decisions that affect scope, workflow, policy, permission, or data.

## Every Requirement Must Include

- ID
- User role
- Use case
- Trigger
- Expected behavior
- Validation
- Error handling
- Acceptance criteria
- Related screen or journey step
- Related data entity, if known
- Priority bucket
- Source discovery note or assumption

## Required Artifacts

Create or update:

- `docs/product/04-scope.md`
- `docs/product/05-requirements.md`
- `.agent-team/agent-results/product-manager.md`

## Slicing Rules

- Keep Phase 1 small enough to ship and test end to end.
- Prefer a thin complete workflow over many unfinished features.
- Do not silently move unclear items into Must Have.
- Make out-of-scope items explicit when users might assume they are included.
- Attach acceptance criteria to behavior, not implementation details.

## Done Criteria

Scope is done only when Phase 1 has clear Must Have requirements, out-of-scope boundaries, and no critical human-owned open questions.

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
