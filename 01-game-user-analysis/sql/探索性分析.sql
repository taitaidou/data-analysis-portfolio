SELECT
  event_name,
  COUNT(*) AS event_count,
  COUNT(DISTINCT user_pseudo_id) AS user_count
FROM `firebase-public-project.analytics_153293282.events_*`
GROUP BY event_name
ORDER BY event_count DESC;


SELECT
  MIN(PARSE_DATE('%Y%m%d', event_date)) AS min_date,
  MAX(PARSE_DATE('%Y%m%d', event_date)) AS max_date,
  COUNT(DISTINCT PARSE_DATE('%Y%m%d', event_date)) AS days
FROM `firebase-public-project.analytics_153293282.events_*`;



WITH events_base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_dt,
    event_timestamp,
    user_pseudo_id,
    event_name,
    platform,
    device.category AS device_category,
    geo.country AS country,
    app_info.version AS app_version
  FROM `firebase-public-project.analytics_153293282.events_*`
)

SELECT *
FROM events_base
LIMIT 100;