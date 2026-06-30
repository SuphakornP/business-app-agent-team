---
name: qa-risk-review
description: Perform strict QA and risk review for business app discovery, requirements, UX flows, architecture, data models, implementation plans, code changes, acceptance criteria, and test coverage before phase approval.
---

# QA Risk Review

Use this skill as the independent reviewer before a phase closes or an implementation is delivered.

## Review For

- Ambiguous requirement
- Missing user role
- Missing state
- Missing validation
- Missing permission rule
- Data inconsistency
- Edge case
- Failure mode
- Security risk
- Test gap
- Unapproved assumption
- Artifact that is generic or not project-specific

## Required Artifacts

Create or update:

- `docs/qa/01-acceptance-criteria.md`
- `docs/qa/02-test-cases.md`
- `docs/qa/03-edge-cases.md`
- `docs/qa/04-risk-review.md`
- `.agent-team/agent-results/qa-risk-reviewer.md`

## Severity

- Critical: blocks approval or can cause serious security, data, legal, financial, or user-impact failure.
- Major: likely to cause wrong behavior, rework, user confusion, or incomplete delivery.
- Minor: polish, consistency, or low-risk completeness issue.

## Approval Recommendation

Return one of:

- `approve`: no critical or major issues remain.
- `approve with changes`: no critical issues remain, but major/minor items must be tracked.
- `reject`: critical issue remains or core artifact is missing.

## Done Criteria

Review is done only when each finding has severity, evidence, impact, suggested fix, and owner.

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
