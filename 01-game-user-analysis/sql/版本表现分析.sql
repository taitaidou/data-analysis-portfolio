WITH events_base AS (
  SELECT
    user_pseudo_id,
    event_name,
    app_info.version AS app_version
  FROM `firebase-public-project.analytics_153293282.events_*`
)

SELECT
  app_version,
  COUNT(DISTINCT user_pseudo_id) AS users,
  COUNT(*) AS event_count,
  SAFE_DIVIDE(COUNT(*), COUNT(DISTINCT user_pseudo_id)) AS events_per_user,
  COUNT(DISTINCT CASE WHEN event_name = 'level_complete' THEN user_pseudo_id END) AS level_complete_users
FROM events_base
WHERE app_version IS NOT NULL
GROUP BY app_version
ORDER BY users DESC;