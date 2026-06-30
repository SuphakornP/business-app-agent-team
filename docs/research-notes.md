# Research Notes

Current implementation choices are based on the package and orchestration surfaces available in Pi and Herdr.

## Findings

- Pi packages support bundling skills and prompts through `package.json`, which matches this kit's `pi.skills` and `pi.prompts` structure.
- Herdr provides a CLI surface for starting agents and inspecting agent state, which fits the control-plane role.
- The safest MVP is a reusable package of operating rules, prompts, templates, schemas, and validation scripts. A deeper Pi extension can be added later after repeated project use proves which operations should be automated.

## Sources

- Pi packages: https://pi.dev/docs/latest/packages
- Herdr CLI reference: https://herdr.dev/docs/cli-reference/
- Herdr getting started: https://herdr.dev/docs/getting-started/
