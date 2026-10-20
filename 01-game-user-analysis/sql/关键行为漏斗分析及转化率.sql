WITH events_base AS (
  SELECT
    user_pseudo_id,
    event_name
  FROM `firebase-public-project.analytics_153293282.events_*`
)

SELECT
  COUNT(DISTINCT CASE WHEN event_name = 'first_open' THEN user_pseudo_id END) AS first_open_users,
  COUNT(DISTINCT CASE WHEN event_name = 'level_start' THEN user_pseudo_id END) AS level_start_users,
  COUNT(DISTINCT CASE WHEN event_name = 'level_complete' THEN user_pseudo_id END) AS level_complete_users,
  COUNT(DISTINCT CASE WHEN event_name = 'spend_virtual_currency' THEN user_pseudo_id END) AS spend_currency_users
FROM events_base;


WITH funnel AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_name = 'first_open' THEN user_pseudo_id END) AS first_open_users,
    COUNT(DISTINCT CASE WHEN event_name = 'level_start' THEN user_pseudo_id END) AS level_start_users,
    COUNT(DISTINCT CASE WHEN event_name = 'level_complete' THEN user_pseudo_id END) AS level_complete_users,
    COUNT(DISTINCT CASE WHEN event_name = 'spend_virtual_currency' THEN user_pseudo_id END) AS spend_currency_users
  FROM `firebase-public-project.analytics_153293282.events_*`
)

SELECT
  *,
  SAFE_DIVIDE(level_start_users, first_open_users) AS first_to_start_rate,
  SAFE_DIVIDE(level_complete_users, level_start_users) AS start_to_complete_rate,
  SAFE_DIVIDE(spend_currency_users, level_complete_users) AS complete_to_spend_rate
FROM funnel;