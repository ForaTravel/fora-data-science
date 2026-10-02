---
name: 14-day graded-to-signup rate
owner: Data Science
status: active
source_of_truth: analytics.dim_advisor_leads
---

# 14-day signup rate (graded leads)

## Definition
Share of graded advisor leads who sign up within 14 days of grading.

## Calculation
```sql
select
    date_trunc(graded_date, month) as graded_month,
    count(*) as graded_leads,
    countif(signed_up_date is not null and days_graded_to_signed_up <= 14) as signed_up_14d,
    safe_divide(countif(signed_up_date is not null and days_graded_to_signed_up <= 14), count(*)) as signup_rate_14d
from `data-warehouse-359101.analytics.dim_advisor_leads`
where graded_date is not null
group by 1
```

## Grain and filters
- One row per advisor lead. `graded_date` is when Membership graded the application, or when the lead skipped grading.
- Channel cuts use How-Heard attribution (`attributed_channel_tier_0/1/2`); Last Click is separate (`last_click_attributed_channel_tier_*`).

## Caveats
- `graded_date` only exists from 2024-03-20; before that it equals applied date.
- 14 days captures ~89% of eventual signups (Lead quality vs funnel speed, May 2026), so the rate is close to final after two weeks.
- `is_high_quality_applicant` changed definition on 2026-03-11 (Final Rating P0/P1/P3 before; Master Qualification Threshold High/VIP after). Don't trend HQQ across that date without noting it.
