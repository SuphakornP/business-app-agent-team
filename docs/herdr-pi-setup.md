# Herdr and Pi Setup

Use Pi as the primary agent runtime and Herdr as the control plane.

## Recommended Runtime

- Supervisor: Pi with `prompts/supervisor.md`.
- Workers: Pi with role prompts from `prompts/`.
- Control plane: Herdr panes or Herdr agent commands.

## Manual Start

From a target project:

```bash
herdr
pi --prompt-template /path/to/business-app-agent-team/prompts/supervisor.md --name supervisor_$(basename "$PWD")
```

## Scripted Task Preparation

Dry-run task creation:

```bash
bash /path/to/business-app-agent-team/scripts/spawn-agent-team.sh . discovery --dry-run
```

Execute in Herdr:

```bash
bash /path/to/business-app-agent-team/scripts/spawn-agent-team.sh . discovery --execute
```

The script writes task briefs to `.agent-team/tasks/` before starting agents so the supervisor has durable records even if an agent session is interrupted.

## References

- Pi packages: https://pi.dev/docs/latest/packages
- Herdr CLI reference: https://herdr.dev/docs/cli-reference/
- Herdr getting started: https://herdr.dev/docs/getting-started/
