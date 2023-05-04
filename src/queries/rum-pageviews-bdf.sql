--- description: Show page views for specified domains and/or IMS orgs for specified dates based on extrapolation from RUM data
--- Authorization: none
--- interval: 30
--- offset: 0
--- startdate: 2022-02-01
--- enddate: 2022-05-28
--- timezone: UTC
--- url: -
--- device: all
--- domainkey: secret

--placeholder
--inputs per discussion: start date, end date, domain (optional), IMS org (optional), returnOnlyIMS (optional)
--outputs: domain, IMS org, estimated count of page views, last weight, date
WITH rum AS (
  SELECT
    REGEXP_REPLACE(hostname, 'www.', '') AS hostname,
    COUNT(DISTINCT id) AS rum_count,
    weight,
    FORMAT_DATE('%Y-%m-%d', time) AS date
  FROM `helix_rum.cluster`
  WHERE
    time >= '2023-05-01'
    AND time < '2023-06-01'
  GROUP BY date, weight, hostname
)
SELECT
  a.hostname,
  SUM(a.rum_count * a.weight) AS estimated_pv,
  a.date,
  b.ims_org_id
FROM rum a
INNER JOIN `helix_reporting.domain_info` b ON a.hostname = b.domain
AND b.ims_org_id != ''
GROUP BY a.hostname, a.date, b.ims_org_id
ORDER BY a.hostname, a.date
