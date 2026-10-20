WITH events_base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_dt,
    user_pseudo_id,
    event_name,
    device.category AS device_category
  FROM `firebase-public-project.analytics_153293282.events_*`
)

SELECT
  device_category,
  COUNT(DISTINCT user_pseudo_id) AS users,
  COUNT(*) AS event_count,
  SAFE_DIVIDE(COUNT(*), COUNT(DISTINCT user_pseudo_id)) AS events_per_user
FROM events_base
GROUP BY device_category
ORDER BY users DESC;