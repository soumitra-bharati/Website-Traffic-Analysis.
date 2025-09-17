CREATE DATABASE web_traffic_db;
USE web_traffic_db;

SELECT * FROM website_traffic_dataset;

-- Handle missing values
UPDATE website_traffic_dataset
SET session_duration_seconds = 0
WHERE session_duration_seconds IS NULL;

-- Removing outliers 
UPDATE website_traffic_dataset
SET session_duration_seconds = 3600
WHERE session_duration_seconds > 3600;

-- Creating view
CREATE VIEW cleaned_traffic AS
SELECT 
    session_id,
    user_id,
    DATE(timestamp) AS date,
    HOUR(timestamp) AS hour,
    traffic_source,
    device,
    pageviews,
    session_duration_seconds,
    bounce,
    conversion,
    events_count
FROM website_traffic_dataset
WHERE pageviews >= 1 AND session_duration_seconds >= 0;  

-- Total sessions 
SELECT COUNT(*) FROM cleaned_traffic;
SELECT * FROM cleaned_traffic;
-- Average session duration by source: 
SELECT 
	traffic_source, 
	ROUND(AVG(session_duration_seconds),2) AS avg_duration 
FROM 
	cleaned_traffic 
GROUP BY 
	traffic_source;

-- Bounce Rate
SELECT 
	traffic_source, 
    ROUND(SUM(bounce)/COUNT(*),2)*100 AS bounce_rate 
FROM 
	cleaned_traffic 
GROUP BY 
	traffic_source;
  
-- total sessions
SELECT 
	COUNT(*) AS total_sessions
FROM 
	cleaned_traffic;
    
-- bounce rate
SELECT 
	SUM(bounce) / COUNT(*) AS bounce_rate
FROM
	cleaned_traffic;
    
-- conversion rate
SELECT 
	traffic_source,
	(ROUND(SUM(conversion) / COUNT(*),2))*100 AS conversion_rate
FROM 
	cleaned_traffic
GROUP BY
	traffic_source;
    

-- Average duration
SELECT
	ROUND(AVG(session_duration_seconds),2) AS avg_duration
FROM 
	cleaned_traffic;	
    
-- Retension 
-- based on What percentage of all unique users have ever returned for a second session on a different day
WITH UserFirstVisit AS (
    SELECT
        user_id,
        MIN(date) AS first_visit_date,
        COUNT(DISTINCT date) AS distinct_visit_days
    FROM
        cleaned_traffic
    GROUP BY
        user_id
)

SELECT
    SUM(CASE WHEN distinct_visit_days > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(user_id) AS retention_rate_percentage
FROM
    UserFirstVisit;