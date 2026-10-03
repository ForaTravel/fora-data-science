# SQL style guide

Fora follows [Matt Mazur's SQL Style Guide](https://github.com/mattm/sql-style-guide). Read the original for rationale and examples. This page summarizes the rules and adds Fora/BigQuery specifics. **Assistants writing SQL for this repo or for Fora analyses must follow it.**

## Rules (summary)

**Formatting**
- Lowercase everything: keywords, functions, types.
- Indent 4 spaces. Left-align keywords; don't pad to align columns.
- One selected column per line, never on the `select` line (`select *` alone is fine).
- Trailing commas at line ends, not leading.
- No spaces inside parentheses. Break long `in (...)` lists over indented lines.
- Single quotes for strings. Use `!=`, not `<>`.
- Multi-line `where` conditions with the operator (`and`/`or`) at the end of each line.

**Naming**
- `snake_case` for everything. Tables are plural.
- Booleans start with `is_`, `has_`, or `does_`. Dates end in `_date`, timestamps in `_at`.
- Always name aggregates and wrapped columns with `as` (`count(*) as booking_count`).
- CTE names describe their contents (`hotel_bookings`, not `hb` or `t1`).

**Joins**
- Write `inner join` / `left join` explicitly, never bare `join`.
- In the `on` clause, put the table referenced first on the left (`on bookings.supplier_id = suppliers.supplier_id`).
- One join condition stays on the `join` line; several go on indented lines below.
- When a query has joins, prefix every column with its table name or alias.

**Structure**
- CTEs, not subqueries. Separate CTEs with a blank line, align the closing `)` with `with`, and end with `select * from <final_cte>`.
- Be explicit with booleans: `is_canceled = false`, not `not is_canceled`.
- `group by` either all column names or all positions, never mixed. Put grouping columns first in the `select`.
- `case`: nothing after `case` on its line; each `when` on its own line, one level deeper; `end` aligned with `case`.
- Window functions on one line, or `partition by` / `order by` on their own indented lines.

## Fora / BigQuery specifics
- Fully qualify tables with backticks: `` `data-warehouse-359101.analytics.fct_bookings` ``.
- The guide says to avoid table aliases unless names are long. Fully qualified BigQuery names count as long, so alias them, using **meaningful aliases** (`bookings`, `suppliers`, `advisors_daily`), never single letters.
- Use the `analytics` dataset, not personal `dbt_<name>` schemas.
- Put a one-line `--` comment at the top of every saved query saying what it returns and at what grain.

## Example
```sql
-- Monthly non-canceled hotel GMV by supplier country (one row per month x country)
with hotel_bookings as (

    select
        bookings.booking_id,
        bookings.commissionable_booking_value_usd,
        date_trunc(date(bookings.created_at), month) as created_month,
        suppliers.physical_country
    from `data-warehouse-359101.analytics.fct_bookings` as bookings
    inner join `data-warehouse-359101.analytics.dim_suppliers` as suppliers
        on bookings.supplier_id = suppliers.supplier_id
    where
        suppliers.supplier_type = 'Hotel' and
        bookings.is_canceled = false

),

final as (

    select
        created_month,
        physical_country,
        count(*) as booking_count,
        sum(commissionable_booking_value_usd) as gmv_usd
    from hotel_bookings
    group by created_month, physical_country

)

select * from final
```
