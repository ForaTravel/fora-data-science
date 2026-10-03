# BigQuery warehouse

- **Project:** `data-warehouse-359101`
- **Use `analytics`** for analysis. It's built by dbt from the [ForaTravel/dbt](https://github.com/ForaTravel/dbt) repo (`models/3_marts`). Table docs: `context/tables/`.
- **Raw event datasets** exist for things dbt doesn't model yet, e.g. `advisor_portal_production` (Segment events such as Client Portal clicks) and `advisor_portal_db_production` (Portal DB replicas). Prefer `analytics` when a modeled table exists.
- **Don't use `dbt_<name>` schemas** (e.g. `dbt_nicholas`) in shared work. They're personal dev builds and can be stale or broken.

## Deprecated tables (still queryable, don't use in new work)
| Deprecated | Use instead |
|---|---|
| `agg_advisor_facts_daily` | `agg_advisors_daily` |
| `agg_advisor_facts` | `agg_advisors_alltime` |
| `agg_advisor_summaries` | `agg_advisors_alltime` |

Note the column names differ: e.g. `agg_advisor_facts_daily.date_day` → `agg_advisors_daily.calendar_date`, and `trailing_365d_commissionable_booking_value_non_canceled_usd` → `non_canceled_trailing_365d_commissionable_booking_value_usd_booked`.

## Other tools
- **Hex:** notebooks and apps; projects are exported into `analyses/` (see `scripts/export_hex.py`).
- **Omni:** BI semantic layer and dashboards.
- **Amplitude, HubSpot:** product events and CRM; the warehouse versions are usually preferable for analysis.
