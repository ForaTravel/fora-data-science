-- First date each Community advisor reached $100K trailing 12-month GMV, including canceled bookings
-- (company pillar definition). One row per advisor.
with first_crossings as (

    select
        advisors_daily.advisor_id,
        min(advisors_daily.calendar_date) as first_100k_date
    from `data-warehouse-359101.analytics.agg_advisors_daily` as advisors_daily
    inner join `data-warehouse-359101.analytics.dim_advisors` as advisors
        on advisors_daily.advisor_id = advisors.advisor_id
    where
        advisors_daily.is_first_time_crossed_above_100k_t365d = true and
        advisors.user_type = 'Community'
    group by advisors_daily.advisor_id

)

select * from first_crossings
