WITH events_base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_dt,
    user_pseudo_id,
    event_name
  FROM `firebase-public-project.analytics_153293282.events_*`
)

SELECT
  event_dt,
  COUNT(DISTINCT user_pseudo_id) AS dau,
  COUNT(*) AS event_count,
  SAFE_DIVIDE(COUNT(*), COUNT(DISTINCT user_pseudo_id)) AS events_per_user
FROM events_base
GROUP BY event_dt
ORDER BY event_dt;