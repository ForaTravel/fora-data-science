---
name: GMV (Commissionable Booking Value)
aliases: [CBV, GMV, TTV, GBV, Book of Business]
owner: Data Science
status: active
source_of_truth: analytics.fct_bookings.commissionable_booking_value_usd
---

# GMV / CBV

## Definition
The USD value of bookings that is eligible for commission. dbt calls it **Commissionable Booking Value (CBV)**. The same number goes by several names:

| Name | Stands for |
|---|---|
| CBV | Commissionable Booking Value (dbt column name) |
| GMV | Gross Merchandise Value |
| TTV | Total Travel Value |
| GBV | Gross Booking Value |
| Book of Business | An advisor's GMV, usually trailing 12 months |

"Bookings" means a **count of bookings**, not this value.

## Calculation
```sql
-- Monthly GMV by booking created month, including canceled bookings (one row per month)
select
    date_trunc(date(created_at), month) as created_month,
    sum(commissionable_booking_value_usd) as gmv_usd,
    sum(if(is_canceled = false, commissionable_booking_value_usd, 0)) as non_canceled_gmv_usd
from `data-warehouse-359101.analytics.fct_bookings`
group by created_month
```
At advisor x day grain, use `agg_advisors_daily.commissionable_booking_value_usd_booked` (canceled-inclusive) or `non_canceled_commissionable_booking_value_usd_booked`.

## Dates
- **`created_at` (default):** when Fora received the booking, i.e. when its record was created in Portal (booked via platform, uploaded by FinOps, or submitted as a self-booking). Use this unless told otherwise.
- **`booked_date`:** when the advisor actually made the booking. Can differ from `created_at`, especially for uploaded and self-reported bookings.
- **`start_date` / `end_date`:** travel dates.

## Cancellations
Whether to include canceled bookings **depends on the analysis**. Always say which you used.
- **Include canceled (dbt default)** when comparing over time, especially cohorts. Newer bookings and cohorts haven't had time to cancel, so excluding cancellations unfairly favors them.
- **Exclude canceled** (`is_canceled = false`, or `non_canceled_` columns) when the stakeholder asks for it, e.g. realized GMV for a closed period.
- `is_canceled = true` means `booking_status = 'Cancellation'`. Pending and Failed bookings are already removed from `fct_bookings`.

## Caveats
- Past analyses mixed both definitions (e.g. Growth Model EDA and p95 Subscriber Analysis include cancellations; Pillar RDD and D120 exclude them). Don't compare numbers across them without checking.
- Self-bookings (`is_self_booking`, estimated by name match) are included unless filtered.

## Related
- Revenue: `gross_commission_revenue_usd` (GCR, total commission from the supplier) and `net_commission_revenue_usd` (NCR = GCR minus advisor commission payable, what Fora keeps).
- [trailing-365d-cbv.md](trailing-365d-cbv.md) for advisor tiers and the company pillars.
