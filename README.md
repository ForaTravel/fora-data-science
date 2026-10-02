# fora-data-science

The data science context layer for Fora: metric definitions, data source docs, reusable AI skills, and a library of past analyses.

Start with [AGENTS.md](AGENTS.md) for the map and conventions. It's written for both people and AI assistants.

## Using it with an AI assistant

- **Claude Code:** install as a plugin to get every skill in `skills/`:
  `/plugin marketplace add ForaTravel/fora-data-science`, then `/plugin install fora-data-science`.
  Or just open the repo; Claude reads `CLAUDE.md`, which points to `AGENTS.md`.
- **ChatGPT / Codex / Cursor / others:** open or upload the repo. These tools read `AGENTS.md`. Skills are plain Markdown; point the assistant at the relevant `skills/<name>/SKILL.md`.

## Contributing

- New analysis: copy `templates/analysis.md` to `analyses/<collection>/YYYY-MM-<slug>/README.md`.
- New metric: copy `templates/metric.md` to `context/metrics/<metric-name>.md`.
- New skill: copy `templates/skill.md` to `skills/<skill-name>/SKILL.md`.
