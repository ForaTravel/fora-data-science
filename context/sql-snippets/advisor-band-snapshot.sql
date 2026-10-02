-- Advisors and their T365D CBV band as of the day before each quarter start.
-- Swap the generate_date_array bounds / interval for monthly snapshots.
with snapshots as (
    select q as period_start
    from unnest(generate_date_array('2025-01-01', current_date(), interval 1 quarter)) as q
)
select
    s.period_start,
    d.advisor_id,
    d.certification,
    d.advisor_growth_or_lifestyle_segment,
    d.non_canceled_trailing_365d_commissionable_booking_value_usd_booked as t365d_cbv,
    case
        when d.non_canceled_trailing_365d_commissionable_booking_value_usd_booked >= 1000000 then '$1M+'
        when d.non_canceled_trailing_365d_commissionable_booking_value_usd_booked >= 500000 then '$500K-$1M'
        when d.non_canceled_trailing_365d_commissionable_booking_value_usd_booked >= 100000 then '$100K-$500K'
        when d.non_canceled_trailing_365d_commissionable_booking_value_usd_booked >= 50000 then '$50K-$100K'
        when d.non_canceled_trailing_365d_commissionable_booking_value_usd_booked > 0 then '<$50K'
        else '$0'
    end as t365d_band
from snapshots as s
inner join `data-warehouse-359101.analytics.agg_advisors_daily` as d
    on d.calendar_date = date_sub(s.period_start, interval 1 day)
inner join `data-warehouse-359101.analytics.dim_advisors` as a
    on d.advisor_id = a.advisor_id
where a.user_type = 'Community'
  and d.is_active_subscriber
