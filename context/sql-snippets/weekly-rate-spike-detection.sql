-- Flags weeks where hotel cancellation rate in a country jumps vs that country's prior 12 calendar weeks.
-- One row per complete week x supplier country. Adapted from "Hotel cancellation anomaly by geography" (May 2026).
--
-- Method: binomial z-score of this week's canceled count vs the pooled baseline rate.
-- - The baseline uses a RANGE frame on day numbers, so it always covers 12 calendar weeks,
--   even when a country has weeks with no bookings.
-- - The baseline rate is smoothed ((events + 0.5) / (n + 1)) so a zero-cancellation baseline
--   still produces a defined z-score instead of silently reading as Normal.
with hotel_bookings as (

    select
        date_trunc(date(bookings.created_at, 'America/New_York'), week(sunday)) as week_start_date,
        coalesce(nullif(suppliers.physical_country, ''), 'Unknown') as supplier_country,
        bookings.is_canceled
    from `data-warehouse-359101.analytics.fct_bookings` as bookings
    inner join `data-warehouse-359101.analytics.dim_suppliers` as suppliers
        on bookings.supplier_id = suppliers.supplier_id
    where
        suppliers.supplier_type = 'Hotel' and
        date(bookings.created_at, 'America/New_York') >= date_sub(current_date('America/New_York'), interval 116 week) and
        date(bookings.created_at, 'America/New_York') < date_trunc(current_date('America/New_York'), week(sunday))

),

weekly as (

    select
        week_start_date,
        supplier_country,
        count(*) as booking_count,
        countif(is_canceled = true) as canceled_count
    from hotel_bookings
    group by week_start_date, supplier_country

),

with_baseline as (

    select
        *,
        safe_divide(canceled_count, booking_count) as cancellation_rate,
        sum(booking_count) over baseline_window as baseline_booking_count,
        sum(canceled_count) over baseline_window as baseline_canceled_count
    from weekly
    window baseline_window as (
        partition by supplier_country
        order by unix_date(week_start_date)
        range between 84 preceding and 7 preceding
    )

),

scored as (

    select
        *,
        safe_divide(baseline_canceled_count, baseline_booking_count) as baseline_rate,
        (baseline_canceled_count + 0.5) / (baseline_booking_count + 1) as smoothed_baseline_rate
    from with_baseline
    where baseline_booking_count is not null

),

z_scored as (

    select
        *,
        cancellation_rate - baseline_rate as rate_delta,
        safe_divide(
            canceled_count - booking_count * smoothed_baseline_rate,
            sqrt(booking_count * smoothed_baseline_rate * (1 - smoothed_baseline_rate))
        ) as z_score
    from scored

),

final as (

    select
        *,
        case
            when booking_count < 10 or baseline_booking_count < 50 then 'Low volume'
            when z_score >= 3 and rate_delta >= 0.05 then 'High spike'
            when z_score >= 2 and rate_delta >= 0.03 then 'Medium spike'
            when z_score >= 1.5 and rate_delta >= 0.02 then 'Watch'
            else 'Normal'
        end as alert_status
    from z_scored

)

select * from final
