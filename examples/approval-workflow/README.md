# Approval Workflow Example

Use this example when testing the agent team on an operations approval request system.

## Intake Prompt

```text
We need an approval request system for the operations team.
Users submit requests with amount, vendor, category, attachments, and justification.
Team leads approve or reject. Finance reviews approved requests before payment.
We currently use chat messages and spreadsheets.
Start with discovery. Do not design the system yet.
```

## Expected First Agents

- `discovery-analyst`
- `product-manager`
- `ux-flow-designer`
- `qa-risk-reviewer`

## Risk Areas

- Approval policy by amount.
- Finance handoff.
- Attachment handling.
- Audit log.
- Permission model.
