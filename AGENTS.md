# Fora Data Science Context Layer

This repo is the shared, version-controlled context for data work at Fora: definitions, data source docs, reusable skills, and past analyses. It is tool-agnostic. Everything is Markdown (with YAML frontmatter) or SQL, so any AI assistant or person can read it.

## Map

| Path | What it holds |
|---|---|
| `context/glossary.md` | Business terms and how Fora uses them |
| `context/metrics/` | One file per metric: definition, SQL, owner, caveats |
| `context/data-sources/` | What lives in each system (warehouse, Amplitude, HubSpot, Omni, Hex) |
| `context/tables/` | Per-table docs: grain, keys, joins, known issues |
| `context/sql-snippets/` | Reusable joins and filters |
| `skills/` | Step-by-step playbooks, one folder per skill, each with a `SKILL.md`. Start with `skills/fora-data-context/` for any data question |
| `analyses/<collection>/` | Completed analyses, grouped into collections |
| `templates/` | Starting points for new metrics, analyses, and skills |

## Rules for assistants

1. **Check before you define.** Before writing a metric or a business term, look in `context/metrics/` and `context/glossary.md`. Use the existing definition; if it seems wrong, flag it rather than silently diverging.
2. **Look for prior work.** Before starting an analysis, search `analyses/` for related questions.
3. **Use the templates** in `templates/` when adding a metric, analysis, or skill.
4. **No raw data.** Commit queries, aggregates, and findings only. Never commit row-level advisor, client, or booking data, credentials, or exports containing personal information.
5. **Link to the source.** Analyses should link to the Hex project (or other tool) that produced them.

## Analysis collections

`marketing`, `strategy`, `business-units`, `product`, `finance`, `product-operations`, `partners`, `leadership`, `international`, `other`.

Each analysis lives at `analyses/<collection>/YYYY-MM-<short-slug>/` with a `README.md` following `templates/analysis.md`. Many analyses are Hex exports: the `*.hex.yaml` file holds every SQL, Python, and markdown cell in order (written findings are usually in the markdown cells). If an analysis spans collections, put it in the primary one and list the others in its `collections` frontmatter.
