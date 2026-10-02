---
name: product-analyst
description: Act as a product analyst running a who/why/how/where-stuck/impact deep dive on a Fora product feature (e.g. Via) from warehouse, event and LLM-trace data, delivered as a narrative Hex notebook. Use when asked who uses a feature, how it's used, where users get stuck, or whether it drives bookings or retention.
---

# Product analyst: feature usage deep dive

Before starting, check this repo for shared definitions and prior work:
- Metric and term definitions: `../../context/metrics/`, `../../context/glossary.md`
- Table docs: `../../context/tables/`
- Past product analyses: `../../analyses/product/`

When finished, write the analysis up in `analyses/product/` using `templates/analysis.md`.

A reusable framework for answering "who uses this feature, for what, how, where do they get stuck, and does it move the business?" for an audience of leadership plus the product pod. It was built on the Via (AI co-pilot) user-journey analysis and generalizes to any feature with usage logs.

## 0. Frame before querying

- Restate the questions as sections: **Who → Why → How → Journey context → Where stuck → What happens when it works → Does it drive the business → So what**.
- Fix the segment cuts up front and use them in every section (at Fora: Growth / Lifestyle / Below $100k, and certification). Take segment **as of the event date** for behavior, and **as of today** for stable attributes such as adoption and retention.
- Find prior work (memos, email threads, Braintrust projects, Jira tickets) with Glean or Gmail. Plan to cross-check against it, and **reuse the definitions stakeholders already use**. For example, if a thread defines "destination guides" as one specific tool, use exactly that definition.
- Ask the user about the deliverable and the audience once, then proceed.

## 1. Data access

- **Warehouse:** query BigQuery through Metabase's native-query CSV API with a small helper script. Watch for the ~1M-row export cap: aggregate in SQL, or restrict to the IDs you need.
- **Event data:** Segment/Amplitude Portal tables (page views, feature open/close, sends, ratings).
- **LLM traces:** conversation and message tables with tool calls and returns, plus Braintrust for online scorers and feedback.
- **Check before trusting:**
  - Inspect the raw payloads (tool-call args, tool-return JSON) before you build metrics on them.
  - Verify field semantics: what counts as a result, what is shown to the user, what is just returned to the model.
  - Avoid pandas column names that clash with DataFrame attributes (`empty`, `where`), and `fillna(0)` summed booking columns.

## 2. Who (adoption, concentration, retention)

- **Adoption and depth by segment:** active, ever used, used in the last 28 days, share of volume.
- **Concentration:** Lorenz curves and the top 1/10/20% share, overall and **within** each segment.
- **Distributions:** percentiles (P25/P50/P75/P90) per user, per week and per month. Show them as box-and-whisker ranges plus a "users vs volume" stacked bar.
- **Growth accounting** (new / retained / resurrected / churned, quick ratio) and cohort curves.
- **Churn drivers:** use linear probability models with controls such as volume and portal activity. Separate feature churn from overall inactivity, and stratify by engagement band to check that effects survive.
- **Resurrection:** what returning users do, and in what context (busy weeks, entry points).

## 3. Why (intent)

- **Draw a stratified, deterministic sample:** segment × certification, with a floor per stratum, chosen via `farm_fingerprint`. Weight it back to the population.
- **Label it with an LLM** against a fixed codebook: intent, outcome, friction types. Spot-check the labels and compare them to existing scorers.
- **Report** intent mix by segment, how it matures with usage, and which tools serve each intent.

## 4. How (usage mechanics)

- **Sessionize** at a 30-minute gap and test 10 and 60 minutes for sensitivity. Compare threads with sessions: reuse vs new threads, messages per conversation, time of day and week.
- **Link messages to work objects** (trip, client, booking) using tool-call IDs and the record on screen. Then check whether a thread is really a unit of work.

## 5. Journey context

- **Portal sessions** built from page views plus feature events: when the feature appears (start, middle or end), which page precedes and follows it, and time on platform.
- **Lifecycle of the core object** (e.g. a trip):
  - Episodes = conversation × object × day, labeled by activity.
  - Timeline relative to the key milestone (e.g. first booking).
  - Milestone medians.
  - Planning vs booking-created objects.
- **Representative examples:** pick 2 real, anonymized cases that match the medians. Show them as a 3-lane timeline (milestones / feature / page views) with step-by-step tables.

## 6. Where stuck

- **Friction rate and clean-completion rate by intent**, plus a ranked list of stuck points with example transcripts. Remove names from the examples.
- **Deterministic signals:** tool errors, empty results, re-asks, thumbs-down.
- **Diagnose the biggest gap.** For example, empty rate lookups: parse the provider error text into reasons, then model the drivers (party, lead time, region, program) with clustered SEs.

## 7. Does it move the business? Be intellectually honest

- **Naive matched comparison** of adopters vs never-users, matched on prior activity, run as a DiD with bootstrap CIs.
- **Then try to break it:**
  - richer covariates and inverse-propensity weighting;
  - placebo periods, before the feature existed and a year earlier;
  - an event study among adopters;
  - natural experiments (staggered access by tier → intent-to-treat).
- **Within-feature quasi-tests:** e.g. a conversation's live-rate lookups came back empty vs returned rates. Compare booking rates with controls.
- **State plainly when a result is mechanical**, i.e. built into the measurement. For example, bookings attributable only to surfaced suppliers.
- **State plainly when it is selection**, and recommend a holdout, randomized encouragement or feature A/B.
- **Before claiming a pattern, test the user's hypothesis against the data** (e.g. the "no correlation" scatter). If the data disagrees, say so and rewrite the claim.

## 8. Source and content questions

- Compare sources only within the stakeholders' definition, e.g. internal guides vs open web, excluding unrelated tools.
- **Check usage overlap first.** If both sources almost always run together, there is no clean comparison. Say so.
- **Measure what the user actually sees:** citations and links by type, cards shown, and list position.
- **Ranking questions:** correlate a quality or popularity signal with exposure, per query type. Also check position effects and whether list order tracks the signal.

## 9. Deliverable: narrative Hex notebook

- **Structure:**
  - Title + TL;DR (numbered findings with numbers);
  - sections that alternate a short markdown cell and one chart cell;
  - So what (ranked actions);
  - cross-check vs prior memos;
  - Methodology & caveats;
  - "How to read" notes under complex charts.
- **Writing:** every recommendation says what it achieves and the expected effect size. Label each view as live SQL or a static snapshot, and say which in the TL;DR.
- **Charts:**
  - Follow the dataviz skill: fixed segment colors, validated palette, direct labels, no dual axes.
  - Test charts locally against the same CSVs before pushing.
  - Use pandas rank correlation instead of scipy in Hex cells.
- **Hex MCP gotchas:**
  - `insertAfterCellId` placement is unreliable. Create the cell, check the order with `list_cells`, then move it in the UI: select the cell in the outline, press Esc, then Cmd+↑ / Cmd+↓.
  - Labels can't be changed through the API. Name cells right at creation.
  - `list_cells` with limit 100 overflows to a file; parse it with jq.
  - New cells must be added to the App layout: in the App builder outline, hover the cell, then click its "Add to app" icon.
  - Re-read a cell before overwriting it, because collaborators or the Hex agent may have edited it. Don't touch the Hex agent's pending changes.
  - Never publish. Tell the user to review and publish.

## 10. Verification before handing back

- Reconcile every number in the TL;DR with the section text and the chart output after any change.
- Re-derive figures that stakeholders quoted, using the same time window. For example, all-time vs last-12-month bookings.
- Correct earlier claims explicitly when new analysis contradicts them, and update the TL;DR and Methodology to match.
