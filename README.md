# fora-data-science

The data science context layer for Fora: metric definitions, data source docs, reusable AI skills, and a library of past analyses.

Start with [AGENTS.md](AGENTS.md) for the map and conventions. It's written for both people and AI assistants.

## Making AI assistants use this repo

The goal: any data question asked to an assistant at Fora should start from this repo's definitions and prior work.

**Claude (Claude Code and the Claude desktop app)**
- Install the plugin. It includes the `fora-data-context` skill, which Claude loads automatically for any Fora data question:
  ```
  /plugin marketplace add ForaTravel/fora-data-science
  /plugin install fora-data-science@fora-data-science
  ```
- To make it the default for everyone, add this plugin to Fora's org plugin catalog so it's installed for the data team (or whole company) without each person running the commands.
- Optional belt-and-braces: add a line to your personal `~/.claude/CLAUDE.md`:
  > For any question about Fora data, metrics, or analyses, first use the `fora-data-context` skill (repo: github.com/ForaTravel/fora-data-science).

**ChatGPT**
- Create a ChatGPT Project (or custom GPT) for data work, connect the GitHub connector to this repo, and paste the "Rules for assistants" section of `AGENTS.md` into the project instructions.

**Codex, Cursor, and other coding agents**
- Open or clone the repo. They read `AGENTS.md` automatically.

## Adding to the repo: steps for data scientists

1. **Pull first.** `git pull` so you're working on the latest definitions.
2. **Branch.** `git checkout -b <your-name>/<short-description>`.
3. **Pick the right home.**
   - A finished analysis → `analyses/<collection>/YYYY-MM-<slug>/README.md` (copy `templates/analysis.md`). Collections: marketing, strategy, business-units, product, finance, product-operations, partners, leadership, international, other.
   - A metric definition → `context/metrics/<metric-name>.md` (copy `templates/metric.md`).
   - A table's grain, keys, or gotchas → `context/tables/<schema>.<table>.md`.
   - A business term → a row in `context/glossary.md`.
   - A reusable workflow or prompt → `skills/<skill-name>/SKILL.md` (copy `templates/skill.md`).
4. **Check for duplicates.** Search the repo for the metric, term, or question. Update the existing file rather than adding a second definition. If you change a definition, note what changed and when in its Caveats section.
5. **Fill in the frontmatter.** Analyses need `collection`, `author`, `date`, `status`, and a `source` link to the Hex project. Skills need a `description` that says *when* to use them, because that's how assistants decide to load them.
6. **Include the SQL, not the data.** Put queries in `queries/`. Never commit row-level data, client or advisor PII, credentials, or exports (CSV/Parquet/Excel are git-ignored).
7. **Write for a reader without context.** Lead with the question and the answer. State caveats and the date range.
8. **Open a PR** and ask someone on the data team to review. Merge when approved.

You can ask Claude to do steps 2–8 for you: "Write up my Hex project <link> as an analysis in fora-data-science."
