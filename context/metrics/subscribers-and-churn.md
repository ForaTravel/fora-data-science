---
name: Active subscribers, new subscribers, churn
owner: Data Science
status: active
source_of_truth: analytics.agg_advisors_daily
---

# Subscribers and churn

## Definitions (dbt)
- **Active subscriber** (`is_active_subscriber`): on or after Signed Up date and on or before Offboarded date.
- **New subscriber** (`is_new_subscriber`): true on the Signed Up date.
- **Churned subscriber** (`is_churned_subscriber`): true on the Offboarded date.
- **Activated:** first booking created (`dim_advisors.activated_date`).
- **Active booker** (`is_active_booker`): created a booking (incl. canceled) in the period.

## Calculation
```sql
-- Monthly churn rate = churned in month / active at start of month
with m as (
    select date_trunc(calendar_date, month) as month,
        count(distinct if(calendar_date = date_trunc(calendar_date, month) and is_active_subscriber, advisor_id, null)) as opening_active,
        count(distinct if(is_churned_subscriber, advisor_id, null)) as churned
    from `data-warehouse-359101.analytics.agg_advisors_daily`
    group by 1
)
select month, opening_active, churned, safe_divide(churned, opening_active) as churn_rate
from m where opening_active > 0
```

## Caveats
- Usually restrict to `dim_advisors.user_type = 'Community'` (excludes In-House, Team/HQ, and Void test users).
- "Active" in a *booking* sense varies by analysis (180 days in Growth Model; 60 days for Fora X / 180 otherwise in Subscriber Retention). Name it "booking-active" and state the window.
- `certification` on `agg_advisors_daily` is estimated from history tables, not tracked exactly.
