-- Task 3: Average completion rate per source (brand)

-- Select each source and calculate its completion rate
SELECT
    -- Classify external_id prefixes to readable source names
  CASE
	WHEN c.external_id LIKE 'PGA%' THEN 'AJA'         -- If it starts with PGA → Al Jazeera Arabic
    WHEN c.external_id LIKE 'PGD%' THEN 'AJD'         -- If it starts with PGD → Al Jazeera Documentary
    WHEN c.external_id LIKE 'PGV%' THEN 'Atheer'      -- If it starts with PGV → Atheer (Podcasts)
    WHEN c.external_id LIKE 'PGL%' THEN 'LIVE'        -- If it starts with PGL → Live channels
    WHEN c.external_id LIKE 'PGC%' THEN 'Originals'   -- If it starts with PGC → Originals / Commissions
    ELSE 'Other'                                      -- Everything else or missing external_id
  END AS source, -- name it as source

  -- Total number of valid watch events
  COUNT(*) AS events_count,

  -- Events reached completion (watched >= 90% of duration)
  SUM(
    CASE
      WHEN v.CONTENT_DURATION > 0
           AND (v.PROGRESS * 100.0) / v.CONTENT_DURATION >= 90.0 THEN 1
      ELSE 0
    END
  ) AS completed_events,

  -- Completion rate (%) = completed_events / total_events * 100
  100.0 * SUM(
    CASE
      WHEN v.CONTENT_DURATION > 0
           AND (v.PROGRESS * 100.0) / v.CONTENT_DURATION >= 90.0 THEN 1
      ELSE 0
    END
  ) / COUNT(*) AS completion_rate_pct

-- Data comes from the viewership table
FROM viewership v

-- Join to catalog to classify each video into a brand/source
LEFT JOIN catalog c
  ON v.CONTENT_ID = c.vod_dve_id

-- Only keep rows where duration is available and > 0 to avoid errors
WHERE v.CONTENT_DURATION IS NOT NULL
  AND v.CONTENT_DURATION > 0

-- Group results so we get one row per source
GROUP BY source

-- Order brands by completion rate (highest first)
ORDER BY completion_rate_pct DESC;
