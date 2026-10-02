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
select
    date_trunc(date(submitted_at), month) as response_month,
    round(100 * (countif(likelihood_to_recommend_rating >= 9)
               - countif(likelihood_to_recommend_rating <= 6))
          / nullif(countif(likelihood_to_recommend_rating is not null), 0), 1) as nps
from `data-warehouse-359101.analytics.fct_surveys_pulse`
group by 1
```

## Caveats
- `survey_source` is Intercom or Typeform. The switch to Intercom (late 2025) changed response volume, and NPS dropped from the mid-50s to ~38–44 at the same time. Treat it as a possible break in the series.
- Typeform responses before Oct 2025 have no advisor link and no ratings.
