-- Task 2: Average progress per video

-- Select the video id, title, and the average progress ratio for each video, and source
SELECT
  v.CONTENT_ID,
   -- Classify external_id prefixes to readable source names
  CASE
	WHEN c.external_id LIKE 'PGA%' THEN 'AJA'         -- If it starts with PGA → Al Jazeera Arabic
    WHEN c.external_id LIKE 'PGD%' THEN 'AJD'         -- If it starts with PGD → Al Jazeera Documentary
    WHEN c.external_id LIKE 'PGV%' THEN 'Atheer'      -- If it starts with PGV → Atheer (Podcasts)
    WHEN c.external_id LIKE 'PGL%' THEN 'LIVE'        -- If it starts with PGL → Live channels
    WHEN c.external_id LIKE 'PGC%' THEN 'Originals'   -- If it starts with PGC → Originals / Commissions
    ELSE 'Other'                                      -- Everything else or missing external_id
  END AS source, -- name it as source

  -- Use the title from the catalog if available; otherwise use the CONTENT_ID as text
  -- coalesce take the first non-null value
  -- max() because SQL requires an aggregate function when grouping
  COALESCE(MAX(c.title), CAST(v.CONTENT_ID AS TEXT)) AS title,
  
  -- Count how many watch events contributed to this average (helps spot small-sample noise)
  COUNT(*) AS events_count,

  -- Give video’s duration (in sec). If multiple values exist, just take the maximum.
  MAX(v.CONTENT_DURATION) AS content_duration_sec,
  
  -- Calculate the average progress ratio (Ratio = PROGRESS / CONTENT_DURATION)
  -- PROGRESS = seconds watched
  -- CONTENT_DURATION = total video length in seconds
  -- MIN(100.0, ...) ensures the ratio never goes above 100.0 (100%) (e.g if PROGRESS=900 and DURATION=600 → 900*100/600=150.0 → capped to 100.0)
  AVG(
    CASE
      WHEN v.CONTENT_DURATION IS NULL OR v.CONTENT_DURATION = 0 THEN NULL   -- Skip rows with missing/zero duration
      ELSE MIN(100.0, (v.PROGRESS * 100.0) / v.CONTENT_DURATION)
    END
  ) AS avg_progress_ratio

-- Data comes from the viewership table (all watch events)
FROM viewership v

-- Join with the catalog table so we can display the title
LEFT JOIN catalog c
  ON v.CONTENT_ID = c.vod_dve_id

-- Group results so we get one row per video
GROUP BY v.CONTENT_ID

-- Order results so the videos with the highest average progress appear first
ORDER BY avg_progress_ratio DESC;
