-- Task 5: New vs. Old content by source (simple version)

SELECT
  -- Classify as New vs Old based only on year/month from created_at
  -- Year = 2025 (found via pattern '/2025 ') AND month in (7,8,9) → “New”
  CASE
    WHEN c.created_at LIKE '%/2025 %'
         AND CAST(substr(c.created_at, 1, instr(c.created_at, '/') - 1) AS INTEGER) IN (7,8,9)
      THEN 'New' 			-- if the month is July, August, or September, we tag the content as New
    ELSE 'Old'
  END AS content_age,

  -- Source classification
  CASE
    WHEN c.external_id LIKE 'PGA%' THEN 'AJA' 				-- PGA → Al Jazeera Arabic
    WHEN c.external_id LIKE 'PGD%' THEN 'AJD'				-- PGD → Al Jazeera Documentary
    WHEN c.external_id LIKE 'PGV%' THEN 'Atheer'			-- PGV → Ather Podcasts
    WHEN c.external_id LIKE 'PGL%' THEN 'LIVE'				-- PGL → Live channels
    WHEN c.external_id LIKE 'PGC%' THEN 'Originals'			-- PGC → Originals / Commissions
    ELSE 'Other'											-- Everything else	
  END AS source,
  
  -- Count unique viewers
  COUNT(DISTINCT v.CUSTOMER_EXID) AS unique_viewers,
  
  -- Total number of view events (all plays, including repeats)
  COUNT(*) AS total_views

FROM viewership v
LEFT JOIN catalog c
  ON v.CONTENT_ID = c.vod_dve_id

-- Only include rows where we have created_at available
WHERE c.created_at IS NOT NULL

-- Group by age + source
GROUP BY content_age, source

-- Order by new/old then biggest audiences
ORDER BY content_age DESC, unique_viewers DESC;
