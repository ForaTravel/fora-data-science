-- Community subscribers and their trailing 12-month GMV band as of the day before each quarter start.
-- GMV includes canceled bookings (pillar definition). One row per quarter x advisor.
-- For monthly snapshots, change the generate_date_array interval to 1 month.
with snapshot_dates as (

    select snapshot_start_date
    from unnest(generate_date_array('2025-01-01', current_date(), interval 1 quarter)) as snapshot_start_date

),

advisor_snapshots as (

    select
        snapshot_dates.snapshot_start_date,
        advisors_daily.advisor_id,
        advisors_daily.certification,
        advisors_daily.advisor_growth_or_lifestyle_segment,
        advisors_daily.trailing_365d_commissionable_booking_value_usd_booked as t365d_gmv_usd
    from snapshot_dates
    inner join `data-warehouse-359101.analytics.agg_advisors_daily` as advisors_daily
        on date_sub(snapshot_dates.snapshot_start_date, interval 1 day) = advisors_daily.calendar_date
    inner join `data-warehouse-359101.analytics.dim_advisors` as advisors
        on advisors_daily.advisor_id = advisors.advisor_id
    where
        advisors.user_type = 'Community' and
        advisors_daily.is_active_subscriber = true

),

final as (

    select
        *,
        case
            when t365d_gmv_usd >= 1000000 then '$1M+'
            when t365d_gmv_usd >= 500000 then '$500K-$1M'
            when t365d_gmv_usd >= 100000 then '$100K-$500K'
            when t365d_gmv_usd >= 50000 then '$50K-$100K'
            when t365d_gmv_usd > 0 then '<$50K'
            else '$0'
        end as t365d_gmv_band
    from advisor_snapshots

)

select * from final
