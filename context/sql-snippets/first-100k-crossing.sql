-- First date each advisor crossed $100K trailing-365d CBV (canceled-inclusive, matching the dbt flag).
-- For a non-canceled version, use min(calendar_date) where
-- non_canceled_trailing_365d_commissionable_booking_value_usd_booked >= 100000.
select advisor_id, min(calendar_date) as first_100k_date
from `data-warehouse-359101.analytics.agg_advisors_daily`
where is_first_time_crossed_above_100k_t365d
group by 1
