---
name: fora-data-context
description: Fora's shared data definitions, table docs, and past analyses. Use for ANY question about Fora data or metrics: advisors, bookings, GMV, commission, revenue, retention, signups, funnels, suppliers, partners, Via or other product usage, marketing performance, or any request to write SQL, pull numbers, build a dashboard, or run an analysis on Fora data.
---

# Fora data context

Load this before answering a Fora data question or writing a query. The files below are the agreed source of truth; prefer them over your own assumptions.

## Steps

1. **Definitions first.** Search `../../context/glossary.md` and `../../context/metrics/` for every business term and metric in the question. Use the definition and SQL written there. If none exists, say so and state the definition you are assuming.
2. **Know the tables.** Check `../../context/tables/` and `../../context/data-sources/` for the grain, keys, joins, and known issues of any table you plan to use. Reuse joins from `../../context/sql-snippets/`.
3. **Look for prior work.** Search `../../analyses/` (all collections) for related questions. If an existing analysis answers it, cite it and its date, then say whether the numbers may be stale.
4. **Pick a playbook.** If a skill in `../` matches the task (e.g. `product-analyst` for feature usage deep dives), follow it.
5. **Answer with sources.** Say which definitions, tables, and prior analyses you relied on, with file paths.

## Contributing back

If the work produced a new definition, a table gotcha, or a finished analysis, offer to add it to the repo (github.com/ForaTravel/fora-data-science) following its README.
