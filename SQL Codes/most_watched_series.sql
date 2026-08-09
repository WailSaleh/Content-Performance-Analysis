-- Task 4: Most-watched series (unique viewers), with brand classification

SELECT
    -- Classify external_id prefixes to readable source names
  CASE
    WHEN c.external_id LIKE 'PGA%' THEN 'AJA'         -- PGA → Al Jazeera Arabic
    WHEN c.external_id LIKE 'PGD%' THEN 'AJD'         -- PGD → Al Jazeera Documentary
    WHEN c.external_id LIKE 'PGV%' THEN 'Atheer'      -- PGV → Ather Podcasts
    WHEN c.external_id LIKE 'PGL%' THEN 'LIVE'        -- PGL → Live channels
    WHEN c.external_id LIKE 'PGC%' THEN 'Originals'   -- PGC → Originals / Commissions
    ELSE 'Other'                                      -- Everything else
  END AS source,

  -- Series information
  v.SERIES_ID,
  
  -- coalesce replaces null values with "Unknown Series"
  COALESCE(v.SERIES_TITLE, 'Unknown Series') AS series_title,

  -- Count unique viewers (one user per series)
  COUNT(DISTINCT v.CUSTOMER_EXID) AS unique_viewers,

  -- Total number of view events (all plays, including repeats)
  COUNT(*) AS total_views

FROM viewership v

-- Join to catalog to pull external_id (needed for source classification)
LEFT JOIN catalog c
  ON v.CONTENT_ID = c.vod_dve_id

-- Keep only rows where SERIES_ID is available
WHERE v.SERIES_ID IS NOT NULL

-- Group by source + series
GROUP BY source, v.SERIES_ID, v.SERIES_TITLE

-- Order by unique viewers (biggest series first)
ORDER BY unique_viewers DESC;
