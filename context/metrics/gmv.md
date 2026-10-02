---
name: GMV (Commissionable Booking Value)
aliases: [CBV, TTV, GBV, GMV, Bookings]
owner: Data Science
status: active
source_of_truth: analytics.fct_bookings.commissionable_booking_value_usd
---

# GMV / CBV

## Definition
The USD value of bookings that is eligible for commission. dbt calls it **Commissionable Booking Value (CBV)**; it is also called TTV, GMV, GBV, or just "Bookings". These all mean the same column.

## Calculation
```sql
-- Default at Fora: non-canceled CBV by booking created date
select
    date_trunc(date(created_at), month) as booking_month,
    sum(commissionable_booking_value_usd) as gmv_usd
from `data-warehouse-359101.analytics.fct_bookings`
where not is_canceled
group by 1
```
Daily/advisor grain: use `agg_advisors_daily.non_canceled_commissionable_booking_value_usd_booked`.

## Grain and filters
- **Date:** booking `created_at` (the "booked" date), not travel date, unless stated.
- **Cancellations:** dbt defaults *include* canceled bookings. Columns prefixed `non_canceled_` exclude them. **State which one you used.** Recommended default for performance analysis: non-canceled.
- `is_canceled` = `booking_status = 'Cancellation'`. Pending/Failed bookings are already excluded from `fct_bookings`.
- Self-bookings (`is_self_booking`, estimated by name match) are included unless you filter them.

## Caveats
- Past analyses have mixed canceled-inclusive and non-canceled GMV (e.g. Growth Model EDA, Advisor Contribution, p95 Subscriber Analysis include cancellations; Pillar RDD, D120 exclude them). Numbers are not comparable across those.
- Some analyses use `booking_status != 'Cancellation'` and others `not is_canceled`; these are equivalent.

## Related
- Revenue: `gross_commission_revenue_usd` (GCR, total commission from supplier) and `net_commission_revenue_usd` (NCR = GCR − advisor commission payable, i.e. what Fora keeps).
- [trailing-365d-cbv.md](trailing-365d-cbv.md) for advisor tiers and pillars.
