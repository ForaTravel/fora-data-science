-- Flag weeks where a rate (here: hotel cancellation rate by country) jumps vs its own 12-week baseline.
-- Binomial z-score vs pooled prior-12-week rate. Adapted from "Hotel cancellation anomaly by geography" (May 2026).
with weekly as (
    select
        date_trunc(date(b.created_at, 'America/New_York'), week(sunday)) as week_start,
        coalesce(nullif(s.physical_country, ''), 'Unknown') as geo,
        count(*) as n,
        countif(b.is_canceled) as events
    from `data-warehouse-359101.analytics.fct_bookings` as b
    inner join `data-warehouse-359101.analytics.dim_suppliers` as s on b.supplier_id = s.supplier_id
    where s.supplier_type = 'Hotel'
      and date(b.created_at, 'America/New_York') >= date_sub(current_date(), interval 116 week)
    group by 1, 2
),
scored as (
    select *,
        safe_divide(events, n) as rate,
        safe_divide(sum(events) over w, sum(n) over w) as baseline_rate,
        sum(n) over w as baseline_n
    from weekly
    window w as (partition by geo order by week_start rows between 12 preceding and 1 preceding)
)
select *,
    rate - baseline_rate as delta,
    safe_divide(events - n * baseline_rate, sqrt(n * baseline_rate * (1 - baseline_rate))) as z,
    case
        when n < 10 or baseline_n < 50 then 'Low volume'
        when safe_divide(events - n * baseline_rate, sqrt(n * baseline_rate * (1 - baseline_rate))) >= 3 and rate - baseline_rate >= 0.05 then 'High spike'
        when safe_divide(events - n * baseline_rate, sqrt(n * baseline_rate * (1 - baseline_rate))) >= 2 and rate - baseline_rate >= 0.03 then 'Medium spike'
        else 'Normal'
    end as alert
from scored
where baseline_rate is not null
