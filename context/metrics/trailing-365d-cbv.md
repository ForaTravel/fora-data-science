---
name: Trailing 365-day GMV, company pillars, and Growth/Lifestyle
owner: Data Science
status: active
source_of_truth: analytics.agg_advisors_daily
---

# Trailing 365-day GMV (T365D / T12M) and the company pillars

## Definition
An advisor's GMV over the 365 days up to a date, by booking `created_at`. Also called trailing 12-month (T12M) GMV.

| Column (`agg_advisors_daily`) | Includes canceled? |
|---|---|
| `trailing_365d_commissionable_booking_value_usd_booked` | Yes |
| `non_canceled_trailing_365d_commissionable_booking_value_usd_booked` | No |
| `is_above_100k_t365d`, `is_first_time_crossed_above_100k_t365d` (also `_500k`, `_1m`) | Yes |

## The two company pillars
1. **Reach $100K:** an advisor's trailing 12-month GMV reaches $100K, **including canceled bookings**. Use `is_above_100k_t365d` / `is_first_time_crossed_above_100k_t365d`.
2. **Grow 50%+:** advisors who were above $100K in the previous year grow their trailing 12-month GMV by 50% or more this year.

**Why $100K:** the top 10% of advisors by trailing GMV produce about 70% of all GMV, and that group starts at roughly $100K. The goal is more advisors in it.

$500K and $1M are additional tiers with their own dbt flags. They are not company pillars.

## Growth vs Lifestyle (advisors at $100K+)
From dbt (`advisor_growth_or_lifestyle_segment`), an advisor is **Growth** if they have 5+ booked clients in T365D and meet one of:
- (a) T365D GMV of $1.5M or more (no growth test);
- (b) T365D GMV of $100K–$1.5M and 50%+ year-over-year growth;
- (c) T365D GMV of $100K–$1.5M and no prior-year comparison (no growth test).

All other $100K+ advisors are **Lifestyle**. A manual tag in the advisor_segment_tags Google Sheet can override the segment.

Because branch (b) requires 50%+ growth, comparable Growth advisors in the $100K–$1.5M range grow faster partly by definition.

## Calculation
```sql
-- Community advisors in the $100K-$500K band as of a snapshot date (one row per advisor)
select
    advisors_daily.advisor_id,
    advisors_daily.trailing_365d_commissionable_booking_value_usd_booked as t365d_gmv_usd
from `data-warehouse-359101.analytics.agg_advisors_daily` as advisors_daily
inner join `data-warehouse-359101.analytics.dim_advisors` as advisors
    on advisors_daily.advisor_id = advisors.advisor_id
where
    advisors_daily.calendar_date = date_sub(@as_of_date, interval 1 day) and
    advisors.user_type = 'Community' and
    advisors_daily.trailing_365d_commissionable_booking_value_usd_booked >= 100000 and
    advisors_daily.trailing_365d_commissionable_booking_value_usd_booked < 500000
```

## Caveats
- Pillar RDD (DATA-1144, May 2026) found no causal jump at $100K, $500K, or $1M: crossing a threshold doesn't by itself change later production. The pillar matters because of who is above it (see "Why $100K"), not because crossing it changes behavior.
- `fct_bookings` also carries the advisor's T365D at booking time (`advisor_t365d_*`) and binned versions.
