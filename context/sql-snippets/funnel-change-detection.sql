-- Flags week-over-baseline changes in advisor funnel conversion rates by last-click channel.
-- One row per complete week x channel x funnel step. Source: agg_growth_channel_metrics_daily.
--
-- Steps (same-period ratios of daily stage counts, not cohort conversion):
--   session_to_applied, applied_to_qualified, qualified_to_signup, session_to_signup
-- Each week is compared with the same channel's prior 8 calendar weeks (pooled), using a
-- two-sided binomial z-score with a smoothed baseline rate. Swap last_click_channel_tier_1
-- for channel_tier_1 (How-Heard) when analyzing awareness channels.
with weekly as (

    select
        date_trunc(date_day, week(monday)) as week_start_date,
        coalesce(last_click_channel_tier_1, 'Unknown') as channel,
        sum(session_count) as session_count,
        sum(applied_advisor_leads_count) as applied_count,
        sum(qualified_advisor_leads_count) as qualified_count,
        sum(signed_up_community_advisors_count) as signup_count
    from `data-warehouse-359101.analytics.agg_growth_channel_metrics_daily`
    where
        is_test_spend = false and
        date_day >= date_sub(current_date(), interval 60 week) and
        date_day < date_trunc(current_date(), week(monday))
    group by week_start_date, channel

),

funnel_steps as (

    select
        weekly.week_start_date,
        weekly.channel,
        step.step_name,
        step.from_count,
        step.to_count
    from weekly
    cross join unnest([
        struct('session_to_applied' as step_name, weekly.session_count as from_count, weekly.applied_count as to_count),
        struct('applied_to_qualified' as step_name, weekly.applied_count as from_count, weekly.qualified_count as to_count),
        struct('qualified_to_signup' as step_name, weekly.qualified_count as from_count, weekly.signup_count as to_count),
        struct('session_to_signup' as step_name, weekly.session_count as from_count, weekly.signup_count as to_count)
    ]) as step

),

with_baseline as (

    select
        *,
        safe_divide(to_count, from_count) as conversion_rate,
        sum(from_count) over baseline_window as baseline_from_count,
        sum(to_count) over baseline_window as baseline_to_count
    from funnel_steps
    window baseline_window as (
        partition by channel, step_name
        order by unix_date(week_start_date)
        range between 56 preceding and 7 preceding
    )

),

scored as (

    select
        *,
        safe_divide(baseline_to_count, baseline_from_count) as baseline_rate,
        least((baseline_to_count + 0.5) / (baseline_from_count + 1), 0.999) as smoothed_baseline_rate
    from with_baseline
    where
        baseline_from_count is not null and
        from_count > 0

),

z_scored as (

    select
        *,
        conversion_rate - baseline_rate as rate_delta,
        safe_divide(conversion_rate, baseline_rate) - 1 as relative_change,
        safe_divide(
            to_count - from_count * smoothed_baseline_rate,
            sqrt(from_count * smoothed_baseline_rate * (1 - smoothed_baseline_rate))
        ) as z_score
    from scored

),

final as (

    select
        *,
        case
            when from_count < 50 or baseline_from_count < 200 then 'Low volume'
            when z_score <= -3 then 'Significant drop'
            when z_score >= 3 then 'Significant lift'
            when abs(z_score) >= 2 then 'Watch'
            else 'Normal'
        end as alert_status
    from z_scored

)

select * from final
