-- Task 1: Total views by source (brand)

-- Select the source name and the number of views for each source
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

  -- Count view units for each source
  -- A unique view = 1 user watching 1 video on 1 day.
  -- So if the same user watches the same video 3 times in the same day → count = 1.
  -- We build this by combining CUSTOMER_EXID + CONTENT_ID + the date part of STARTED_AT (e.g user123-850104-9/3/2025)
  COUNT(DISTINCT v.CUSTOMER_EXID || '-' || v.CONTENT_ID || '-' || substr(v.STARTED_AT, 1, instr(v.STARTED_AT,' ')-1)) AS unique_views

-- Data comes from the viewership table (all the watch events)
FROM viewership v

-- Join with the catalog table so each CONTENT_ID can be linked to its external_id
LEFT JOIN catalog c
  ON v.CONTENT_ID = c.vod_dve_id
  -- LEFT JOIN ensures we still keep the view even if the catalog row is missing (it becomes 'Other')

-- Group results so we get one row per source
GROUP BY source

-- Order results so the brands with the most views appear first
ORDER BY unique_views DESC;