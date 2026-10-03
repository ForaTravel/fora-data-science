---
name: Active subscribers, new subscribers, churn
owner: Data Science
status: active
source_of_truth: analytics.agg_advisors_daily
---

# Subscribers and churn

At Fora, "subscriber" and "advisor" mean the same person: advisors pay a subscription.

## Definitions (dbt)
- **Active subscriber** (`is_active_subscriber`): on or after Signed Up date and on or before Offboarded date.
- **New subscriber** (`is_new_subscriber`): true on the Signed Up date.
- **Churned subscriber** (`is_churned_subscriber`): true on the Offboarded date.
- **Activated:** first booking created (`dim_advisors.activated_date`).
- **Active booker** (`is_active_booker`): created a booking (incl. canceled) in the period.

## Calculation
```sql
-- Monthly Community subscriber churn rate = churned in month / active on the 1st (one row per month)
with community_advisors_daily as (

    select
        advisors_daily.advisor_id,
        advisors_daily.calendar_date,
        advisors_daily.is_active_subscriber,
        advisors_daily.is_churned_subscriber
    from `data-warehouse-359101.analytics.agg_advisors_daily` as advisors_daily
    inner join `data-warehouse-359101.analytics.dim_advisors` as advisors
        on advisors_daily.advisor_id = advisors.advisor_id
    where advisors.user_type = 'Community'

),

monthly as (

    select
        date_trunc(calendar_date, month) as month_start_date,
        count(distinct if(calendar_date = date_trunc(calendar_date, month) and is_active_subscriber = true, advisor_id, null)) as opening_active_count,
        count(distinct if(is_churned_subscriber = true, advisor_id, null)) as churned_count
    from community_advisors_daily
    group by month_start_date

),

final as (

    select
        month_start_date,
        opening_active_count,
        churned_count,
        safe_divide(churned_count, opening_active_count) as churn_rate
    from monthly
    where opening_active_count > 0

)

select * from final
```

## Caveats
- Analyses should be **Community only** (`dim_advisors.user_type = 'Community'`), which excludes In-House, Team/HQ, and Void test users. The query above does this.
- "Active" in a *booking* sense varies by analysis (180 days in Growth Model; 60 days for Fora X / 180 otherwise in Subscriber Retention). Name it "booking-active" and state the window.
- `certification` on `agg_advisors_daily` is estimated from history tables, not tracked exactly.
