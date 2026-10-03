---
name: Advisor lead funnel conversion
owner: Data Science
status: active
source_of_truth: analytics.dim_advisor_leads, analytics.agg_growth_channel_metrics_daily
---

# Advisor lead funnel conversion

## Funnel stages
Site session → first known → **applied** (MQL) → **graded** (= qualified) → invited → **signed up** → activated.

"Graded" and "qualified" mean the same step. They used to be separate, but in recent years the time between grading and qualification has gone to zero.

## Metrics

| Metric | Numerator / denominator | Source |
|---|---|---|
| **Graded-to-signup rate** (headline) | signed up within N days of grading / graded leads | `dim_advisor_leads` |
| Applied-to-graded rate | graded / applied | `dim_advisor_leads` |
| Applied-to-signup rate | signed up / applied | `dim_advisor_leads` |
| Session-to-signup rate | signups / site sessions | `agg_growth_channel_metrics_daily` |

**Standard windows:** 0, 1, 7, and 14 days (`days_graded_to_signed_up <= N`). 14 days is the most common headline, and it captures about 89% of eventual signups (Lead quality vs funnel speed, May 2026). Day 0 alone captures about 39%.

## Calculation
```sql
-- Graded-to-signup rates by graded month and window (one row per month)
select
    date_trunc(graded_date, month) as graded_month,
    count(*) as graded_lead_count,
    safe_divide(countif(days_graded_to_signed_up <= 0), count(*)) as signup_rate_0d,
    safe_divide(countif(days_graded_to_signed_up <= 1), count(*)) as signup_rate_1d,
    safe_divide(countif(days_graded_to_signed_up <= 7), count(*)) as signup_rate_7d,
    safe_divide(countif(days_graded_to_signed_up <= 14), count(*)) as signup_rate_14d
from `data-warehouse-359101.analytics.dim_advisor_leads`
where graded_date is not null
group by graded_month
```

```sql
-- Weekly session-to-signup and funnel rates by last-click channel (one row per week x channel)
select
    date_trunc(date_day, week(monday)) as week_start_date,
    last_click_channel_tier_1,
    sum(session_count) as session_count,
    sum(applied_advisor_leads_count) as applied_lead_count,
    sum(qualified_advisor_leads_count) as qualified_lead_count,
    sum(signed_up_community_advisors_count) as signup_count,
    safe_divide(sum(signed_up_community_advisors_count), sum(session_count)) as session_to_signup_rate,
    safe_divide(sum(signed_up_community_advisors_count), sum(applied_advisor_leads_count)) as applied_to_signup_rate
from `data-warehouse-359101.analytics.agg_growth_channel_metrics_daily`
where is_test_spend = false
group by week_start_date, last_click_channel_tier_1
```

## Caveats
- Rates over a window need a mature cohort: exclude leads graded fewer than N days ago, or the latest periods will look low.
- `graded_date` only exists from 2024-03-20; before that it equals `applied_date`.
- The aggregate table counts each stage on the day it happened, so its "applied-to-signup" is a same-period ratio, not a cohort rate. Use `dim_advisor_leads` for cohort conversion.
- Attribution: use **last-click** by default; use **How-Heard** for awareness channels such as podcasts and organic AI. See the glossary.
- Lead quality fields changed in 2026. See `context/glossary.md` (P ratings, HQQ, master qualification threshold).
