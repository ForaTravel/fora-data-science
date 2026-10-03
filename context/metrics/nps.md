---
name: Advisor NPS (Pulse survey)
owner: Data Science
status: active
source_of_truth: analytics.fct_surveys_pulse
---

# Advisor NPS

## Definition
NPS = % Promoters (9–10) − % Detractors (0–6), from `likelihood_to_recommend_rating` (0–10). Passives are 7–8.

## Calculation
```sql
-- Monthly advisor NPS from the Pulse survey (one row per response month)
with responses as (

    select
        date_trunc(date(submitted_at), month) as response_month,
        likelihood_to_recommend_rating
    from `data-warehouse-359101.analytics.fct_surveys_pulse`
    where likelihood_to_recommend_rating is not null

),

final as (

    select
        response_month,
        count(*) as response_count,
        countif(likelihood_to_recommend_rating >= 9) as promoter_count,
        countif(likelihood_to_recommend_rating <= 6) as detractor_count,
        round(100 * safe_divide(
            countif(likelihood_to_recommend_rating >= 9) - countif(likelihood_to_recommend_rating <= 6),
            count(*)
        ), 1) as nps
    from responses
    group by response_month

)

select * from final
```

## Caveats
- `survey_source` is Intercom or Typeform. The switch to Intercom (late 2025) changed response volume, and NPS dropped from the mid-50s to ~38–44 at the same time. Treat it as a possible break in the series.
- Typeform responses before Oct 2025 have no advisor link and no ratings.
