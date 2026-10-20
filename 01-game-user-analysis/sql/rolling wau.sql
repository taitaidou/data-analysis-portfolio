WITH events_base AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_dt,
    user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_*`
),
dates AS (
  SELECT DISTINCT event_dt
  FROM events_base
)

SELECT
  d.event_dt,
  COUNT(DISTINCT e.user_pseudo_id) AS wau
FROM dates d
LEFT JOIN events_base e
  ON e.event_dt BETWEEN DATE_SUB(d.event_dt, INTERVAL 6 DAY) AND d.event_dt
GROUP BY d.event_dt
ORDER BY d.event_dt;