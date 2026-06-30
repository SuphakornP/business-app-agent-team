# Agent Contract

Every worker must produce artifacts and end with the result contract below. The supervisor treats missing fields as incomplete work.

## Result Contract

```markdown
STATUS: done | blocked | needs_approval | failed
CONFIDENCE: 0-100
TASK_RECEIVED:
- ...
WHAT_I_DID:
- ...
ARTIFACTS_CREATED_OR_UPDATED:
- path:
  summary:
KEY_DECISIONS:
- decision:
  reason:
ASSUMPTIONS:
- assumption:
  impact:
RISKS:
- risk:
  severity:
  mitigation:
TESTS_OR_CHECKS:
- check:
  result:
OPEN_QUESTIONS:
- question:
  owner: human | supervisor | another_agent
NEXT_RECOMMENDED_ACTION:
- ...
```

## Status Semantics

- `done`: assigned scope is complete, artifacts exist, checks are recorded, and no critical human-owned question remains.
- `blocked`: worker cannot continue without missing context, tool access, file access, or upstream artifact.
- `needs_approval`: worker can continue only after a human or supervisor approves a decision.
- `failed`: worker attempted the task and could not produce usable output.

## Confidence Rules

- `90-100`: artifact is complete and validated against the checklist.
- `70-89`: usable with known minor gaps.
- `50-69`: partial, needs review before use.
- `<50`: do not close the phase from this result.

## Supervisor Validation Rules

- If `STATUS: done` and critical human-owned `OPEN_QUESTIONS` exist, treat the result as `needs_approval`.
- If required artifact paths are missing, treat the result as `blocked`.
- If confidence is below 70, request review or retry before closing a phase.
- If tests/checks are absent for implementation work, do not deliver.
