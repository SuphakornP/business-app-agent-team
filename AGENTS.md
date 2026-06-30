# Agent Team Package Instructions

This repo is a reusable Pi package for phase-gated business application agent teams.

## Maintenance Rules

- Keep `skills/*/SKILL.md` concise and self-contained.
- Keep prompts role-specific; do not make workers responsible for phase closure.
- Keep templates generic but structured enough that a supervisor can validate them.
- Keep scripts dependency-light: bash and python3 only unless a dependency is explicitly justified.
- Keep `schemas/*.json` valid JSON and compatible with draft 2020-12.
- Run `bash scripts/validate-package.sh` after changing package files.

## Orchestration Rules

- Supervisor owns phase order, evidence checks, approval escalation, and final delivery summary.
- Workers own bounded artifacts and must end with the standard agent result contract.
- Implementation must not start before blueprint and implementation plan approval.
- Database migration, auth, production, dependency, external service, sensitive data, destructive operation, and irreversible git changes require human approval.
