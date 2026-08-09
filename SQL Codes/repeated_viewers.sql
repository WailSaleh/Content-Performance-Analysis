-- Task 6: Repeat viewers (number and share of users)

-- Build a temporary table of (user, calendar day) pairs
WITH user_days AS (
	SELECT
    v.CUSTOMER_EXID,
	
	-- Extract just the calendar date part from STARTED_AT (before the space between the date and the time)
	CASE
      WHEN instr(v.STARTED_AT, ' ') > 0
        THEN substr(v.STARTED_AT, 1, instr(v.STARTED_AT, ' ') - 1)  -- extracts a piece of text, begin at the first character , stop before the space (e.g., '9/3/2025')
      ELSE v.STARTED_AT  -- fallback if no space is present
    END AS view_date,
	   v.CONTENT_ID
	
	FROM viewership v
	-- One row per (user, day, content) so we can later tag each user activity to a source
	GROUP BY v.CUSTOMER_EXID, view_date,  v.CONTENT_ID
),

-- Count distinct days per user (per content source)
user_day_counts AS (
	SELECT
	ud.CUSTOMER_EXID,
	COUNT(DISTINCT ud.view_date) AS active_days,  -- number of different days this user watched (within source)
	c.external_id
	FROM user_days ud 			-- accesing the temporary table create usr_days
	LEFT JOIN catalog c
		ON ud.CONTENT_ID = c.vod_dve_id
	GROUP BY ud.CUSTOMER_EXID, c.external_id
),

user_sources AS (
  -- classify users as repeat vs one-time, and tag to source
  SELECT
    CUSTOMER_EXID,
    CASE
		WHEN external_id LIKE 'PGA%' THEN 'AJA'         -- PGA → Al Jazeera Arabic
		WHEN external_id LIKE 'PGD%' THEN 'AJD'         -- PGD → Al Jazeera Documentary
		WHEN external_id LIKE 'PGV%' THEN 'Atheer'      -- PGV → Ather Podcasts
		WHEN external_id LIKE 'PGL%' THEN 'LIVE'        -- PGL → Live channels
		WHEN external_id LIKE 'PGC%' THEN 'Originals'   -- PGC → Originals / Commissions
		ELSE 'Other'                                    -- Everything else
	END AS source,
	CASE WHEN active_days > 1 THEN 1 ELSE 0 END AS is_repeat -- users who came back on a different day
  FROM user_day_counts
)

-- Calculate total users and repeat users per sources
SELECT
  source,
  COUNT(DISTINCT CUSTOMER_EXID) AS total_users,                -- unique users for this source
  
  -- Repeat users = users who watched on more than 1 calendar day
  SUM(is_repeat) AS repeat_users,
  
  -- Share of repeat users as a percentage of all users
  ROUND(100.0 * SUM(is_repeat) / COUNT(DISTINCT CUSTOMER_EXID), 2) AS repeat_share_pct
  
FROM user_sources -- accesing the table create user_sources
GROUP BY source
ORDER BY repeat_share_pct DESC;