# Human Approval Policy

Agents must stop and request supervisor or human approval before:

1. Creating or changing database migrations.
2. Deleting files, records, or persistent data.
3. Changing authentication or authorization logic.
4. Adding external services, paid APIs, credentials, or new vendors.
5. Touching production deployment settings.
6. Changing business rules not explicitly approved.
7. Handling sensitive personal, health, financial, or legal data.
8. Performing large refactors beyond assigned scope.
9. Installing new dependencies.
10. Making irreversible git operations.

The supervisor records every approval request in `.agent-team/decision-log.md` and keeps the phase open until the approval is resolved.
