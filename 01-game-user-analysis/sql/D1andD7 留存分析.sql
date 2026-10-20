WITH events_base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_dt,
    user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
),
first_seen AS (
  SELECT
    user_pseudo_id,
    MIN(event_dt) AS cohort_date
  FROM events_base
  GROUP BY user_pseudo_id
),
user_active AS (
  SELECT DISTINCT
    user_pseudo_id,
    event_dt
  FROM events_base
)

SELECT
  f.cohort_date,
  COUNT(DISTINCT f.user_pseudo_id) AS new_users,
  COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_dt, f.cohort_date, DAY) = 1 THEN f.user_pseudo_id END) AS d1_retained_users,
  COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_dt, f.cohort_date, DAY) = 7 THEN f.user_pseudo_id END) AS d7_retained_users,
  SAFE_DIVIDE(
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_dt, f.cohort_date, DAY) = 1 THEN f.user_pseudo_id END),
    COUNT(DISTINCT f.user_pseudo_id)
  ) AS d1_retention,
  SAFE_DIVIDE(
    COUNT(DISTINCT CASE WHEN DATE_DIFF(a.event_dt, f.cohort_date, DAY) = 7 THEN f.user_pseudo_id END),
    COUNT(DISTINCT f.user_pseudo_id)
  ) AS d7_retention
FROM first_seen f
LEFT JOIN user_active a
  ON f.user_pseudo_id = a.user_pseudo_id
GROUP BY f.cohort_date
ORDER BY f.cohort_date;