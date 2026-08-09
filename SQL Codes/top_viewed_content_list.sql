-- Task 7: Top-viewed content list (episodes)

SELECT
	CASE
		WHEN external_id LIKE 'PGA%' THEN 'AJA'         -- PGA → Al Jazeera Arabic
		WHEN external_id LIKE 'PGD%' THEN 'AJD'         -- PGD → Al Jazeera Documentary
		WHEN external_id LIKE 'PGV%' THEN 'Atheer'      -- PGV → Ather Podcasts
		WHEN external_id LIKE 'PGL%' THEN 'LIVE'        -- PGL → Live channels
		WHEN external_id LIKE 'PGC%' THEN 'Originals'   -- PGC → Originals / Commissions
		ELSE 'Other'                                    -- Everything else
	END AS source,
  c.title,                     -- episode title
  c.series_title,              -- series name (if available)
  c.thumbnail_url,             -- thumbnail image link for title
  COUNT(DISTINCT v.CUSTOMER_EXID || '-' || v.CONTENT_ID || '-' ||
        substr(v.STARTED_AT, 1, instr(v.STARTED_AT,' ')-1)) AS unique_views  -- unique view = (user + content + calendar day)

FROM viewership v
LEFT JOIN catalog c
  ON v.CONTENT_ID = c.vod_dve_id

WHERE c.title IS NOT NULL 	-- exclude cases with no title (null)
	AND TRIM(c.title) <> '' -- exclude rows where the title is just an empty string

GROUP BY c.title, c.series_title, c.thumbnail_url	-- to get one row per episode.

ORDER BY unique_views DESC 	-- find the most watched

LIMIT 20;   -- show top 20 episodes
