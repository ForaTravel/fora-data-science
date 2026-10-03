# Glossary

Fora business terms. For metric math, see `metrics/`. Column-level definitions are in `tables/` (generated from dbt).

| Term | Definition | Where it lives |
|---|---|---|
| Advisor (subscriber) | A travel advisor on Fora's platform (Portal user). Also called a **subscriber**, since advisors pay a subscription. | `dim_advisors` |
| Community / Team / In-House / Void | `user_type`: Community = regular advisors; Team = HQ staff (by tag); In-House = internal IDs; Void = test/duplicate users. **Analyses should be Community only** unless stated. | `dim_advisors.user_type` |
| Lead | A prospective advisor, from first known through application, grading, invite and signup. | `dim_advisor_leads` |
| Applied (MQL) / Graded (Qualified) / Invited / Signed Up | Lead funnel stages. Applied is also called **MQL**. Graded = reviewed by Membership (or skipped grading); also called **qualified**, since the two steps now happen together. See `metrics/lead-funnel-conversion.md`. | `dim_advisor_leads.*_date` |
| Activated | Advisor created their first booking. | `dim_advisors.activated_date` |
| Offboarded | Advisor deactivated / unsubscribed; drives churn. | `dim_advisors.is_offboarded` |
| P0 / P1 / P2 / P3 / N | **Deprecated June 2026** in favor of the master qualification threshold. Lead qualification ratings (AI grader → `ai_rating`, auto-grader → `auto_rating`, Membership → `final_rating`); N = not qualified. Still needed for historical analysis. | `dim_advisor_leads` |
| Master qualification threshold | Current lead score (`master_qualification_threshold`), combining bio rating, likelihood to join, and expected GMV. Replaced P ratings in 2026. | `dim_advisor_leads` |
| HQQ (High Quality Qualified) | `is_high_quality_applicant`. Before 2026-03-11: Final Rating P0/P1/P3. After: Master Qualification Threshold High/VIP. | `dim_advisor_leads` |
| Sendback | AI-qualified leads (`ai_rating = 'P'`) sent back to Meta as a conversion signal. | `dim_advisor_leads` |
| Persona | Lead segment from the application: Experienced Advisor, Professional Planner, Beginner. | `dim_advisor_leads.persona` |
| Last-Click vs How-Heard attribution | **Last-Click is the default**: GA's last non-direct click (`last_click_attributed_channel_tier_*`). **How-Heard** maps the "How did you hear about us?" answer to channels (`attributed_channel_tier_*`); use it for awareness channels such as podcasts and organic AI. | `dim_advisor_leads`, `agg_growth_channel_metrics_daily` |
| Certification | Advisor level: Uncertified, Certified, Advanced, Pro, Fora X. On daily tables it's estimated from history. | `agg_advisors_daily.certification` |
| Pro / Fora X | Top certification levels. | |
| Path to Pro (P2P) | Program to move advisors to Pro and past $100K trailing GMV, including coaching (`has_path_to_pro_coach`, with start/end dates). Some older Hex charts call it "Pass the Pro". | `dim_advisors` |
| CBV / GMV / TTV / GBV / Book of Business | Commissionable Booking Value; GMV = Gross Merchandise Value, TTV = Total Travel Value, GBV = Gross Booking Value. Whether to include canceled bookings depends on the analysis (include for over-time and cohort comparisons); always state it. "Bookings" means a booking count, not this value. See `metrics/gmv.md`. | `fct_bookings` |
| GCR / NCR | Gross Commission Revenue (total from supplier) / Net Commission Revenue (Fora's share after advisor payout). | `fct_bookings` |
| T365D / T12M | Trailing 365 days / trailing 12 months. | |
| Company pillars | (1) advisors reaching $100K trailing 12-month GMV, including canceled; (2) advisors above $100K last year growing 50%+ this year. See `metrics/trailing-365d-cbv.md`. | `agg_advisors_daily` |
| Growth / Lifestyle | Segment for $100K+ advisors based on growth and clients. See `metrics/trailing-365d-cbv.md`. | `agg_advisors_daily` |
| M0 / M1 … | Advisor's month 0, 1, … after signup. Use `agg_advisors_daily.calendar_months_after_signed_up` (calendar months); some older analyses used 30-day buckets. | `agg_advisors_daily` |
| W0 / D28 / D120 | First week (days 0–7), day 28, day 120 after signup. D28 activation rate is the main cohort-quality metric. | |
| Anchor supplier type | The trip's main supplier type, by priority Cruise > DMC > Multiday Tours > Package > Homes/Villas > Hotel. Other bookings on the trip are attachments. | `fct_trips.supplier_type_anchor` |
| DMC | Destination Management Company (ground-services supplier). | `dim_suppliers.supplier_type` |
| Self-booking | Advisor booking for themselves; estimated by name match. | `fct_bookings.is_self_booking` |
| Portal | The advisor-facing web app. | `fct_portal_sessions`, `fct_portal_page_views` |
| Client Portal (CP) | Client-facing booking experience shared by advisors. | `fct_booking_attribution.is_attributed_to_client_portal` |
| Via | Fora's AI assistant for advisors. | `fct_via_conversations`, `fct_via_messages` |
| Pulse survey | Recurring advisor survey (NPS, CSAT, etc.). | `fct_surveys_pulse` |
