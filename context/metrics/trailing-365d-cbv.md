---
name: Trailing 365-day CBV, pillars, and Growth/Lifestyle
owner: Data Science
status: active
source_of_truth: analytics.agg_advisors_daily
---

# Trailing 365-day CBV (T365D) and the $100K / $500K / $1M pillars

## Definition
An advisor's sum of CBV over the 365 days up to a given date, by booking created date. Used to tier advisors.

| Column (`agg_advisors_daily`) | Includes canceled? |
|---|---|
| `trailing_365d_commissionable_booking_value_usd_booked` | Yes |
| `non_canceled_trailing_365d_commissionable_booking_value_usd_booked` | No |
| `is_above_100k_t365d`, `is_first_time_crossed_above_100k_t365d` (and 500k, 1m) | **Yes** (dbt flags are canceled-inclusive) |

## Pillars
$100K, $500K, $1M T365D CBV. "Hit $100K" in past work has meant either the dbt flag (canceled-inclusive) or a non-canceled threshold; say which.

## Growth vs Lifestyle (advisors at $100K+)
From dbt (`advisor_growth_or_lifestyle_segment`): **Growth** if 5+ booked clients in T365D AND either (a) T365D CBV ≥ $1.5M, (b) $100K–$1.5M with ≥50% YoY growth, or (c) $100K–$1.5M with no prior-year comparison. Other $100K+ advisors are **Lifestyle**. Can be overridden by a manual tag (advisor_segment_tags Google Sheet). Note: because Growth requires 50%+ YoY growth, "Growth advisors grow faster" is partly true by definition.

## Calculation
```sql
-- Advisors in the $100K-$500K band as of the day before a date
select advisor_id
from `data-warehouse-359101.analytics.agg_advisors_daily`
where calendar_date = date_sub(@as_of, interval 1 day)
  and non_canceled_trailing_365d_commissionable_booking_value_usd_booked >= 100000
  and non_canceled_trailing_365d_commissionable_booking_value_usd_booked < 500000
```

## Caveats
- Pillar RDD (DATA-1144, May 2026) found no causal discontinuity at any pillar: crossing $100K does not itself change later production.
- `fct_bookings` also carries the advisor's T365D *at booking time* (`advisor_t365d_*`) and binned versions.
