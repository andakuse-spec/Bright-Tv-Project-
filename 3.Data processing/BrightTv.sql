---Cheking for the columns
select * 
from `workspace`.`default`.`user_profiles_data` 
limit 100;


---Combining the two tables 
select u.*,
       v.*
from `workspace`.`default`.`user_profiles_data`  as u
left join `workspace`.`default`.`viewership_data` as v
on u.UserID = v.UserID;

-- converting UTC time to SA time 
select 
   *, 
  from_utc_timestamp(TO_TIMESTAMP(RecordDate2, 'yyyy/MM/dd HH:mm'), 'Africa/Johannesburg') AS sast_timestamp
  from `workspace`.`default`.`viewership_data`;

  -- User and Usage combined trends, finding by age group
  SELECT 
 CASE 
   WHEN u.Age < 18 THEN 'Under 18'
  WHEN u.Age BETWEEN 18 AND 25 THEN '18-25'
  WHEN u.Age BETWEEN 26 AND 35 THEN '26-35'
  WHEN u.Age BETWEEN 36 AND 50 THEN '36-50'
  ELSE '50+'
END AS Age_group,
COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`user_profiles_data` U
JOIN `workspace`.`default`.`viewership_data` V
ON u.UserID = v.userid
GROUP BY 
 CASE 
  WHEN u.Age < 18 THEN 'Under 18'
  WHEN u.Age BETWEEN 18 AND 25 THEN '18-25'
  WHEN u.Age BETWEEN 26 AND 35 THEN '26-35'
  WHEN u.Age BETWEEN 36 AND 50 THEN '36-50'
 ELSE '50+'
 END
ORDER BY Total_sessions DESC;


--- Usage by Province to showcase the demand within the region
SELECT 
u.Province,
COUNT(*) AS total_sessions
FROM `workspace`.`default`.`user_profiles_data` u
JOIN `workspace`.`default`.`viewership_data` v
ON u.UserID = v.userid
GROUP BY u.Province
ORDER BY total_sessions DESC;

----Determining the Peak Viewing Time (SA Time) to view Peak usage hours
SELECT 
HOUR(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) AS Hour_SA,
COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`viewership_data` v
JOIN `workspace`.`default`.`user_profiles_data` u
 ON u.UserID = v.userid
GROUP BY HOUR(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS)
ORDER BY Hour_SA;


---Determining the usage by day of the week to view Weekend vs weekday behavior
SELECT 
date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_name,
COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`viewership_data`v
JOIN `workspace`.`default`.`user_profiles_data` u
ON u.UserID = v.userid
GROUP BY Day_name
ORDER BY Total_sessions DESC;

---Content Preference by Gender
SELECT 
u.Gender,
v.Channel2,
COUNT(*) AS Total_views
FROM `workspace`.`default`.`user_profiles_data` u
JOIN `workspace`.`default`.`viewership_data`V
ON u.UserID = v.userid
GROUP BY u.Gender, v.Channel2
ORDER BY Total_views DESC;


--Determining average session duration
SELECT 
v.Channel2,
AVG(
(HOUR(v.`Duration 2`) * 3600) +
(MINUTE(v.`Duration 2`) * 60) +
SECOND(v.`Duration 2`)
) AS Avg_seconds
FROM `workspace`.`default`.`viewership_data`V
JOIN `workspace`.`default`.`user_profiles_data` u
ON u.UserID = v.userid
GROUP BY v.Channel2
ORDER BY Avg_seconds DESC;


---Inspect AGE vs CONTENT
SELECT 
u.Age,
v.Channel2,
COUNT(*) AS Total_views
FROM `workspace`.`default`.`user_profiles_data` u
JOIN `workspace`.`default`.`viewership_data` v
ON u.UserID = v.userid
GROUP BY u.Age, v.Channel2
ORDER BY Total_views DESC;


---Identify Lowest Days
SELECT 
date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_name,
COUNT(*) AS Total_sessions
FROM `workspace`.`default`.`viewership_data` v
JOIN `workspace`.`default`.`user_profiles_data` u
ON u.UserID = v.userid
GROUP BY Day_name
ORDER BY Total_sessions ASC;


---Evaluate the best Performing Content
SELECT 
v.Channel2,
COUNT(*) AS Total_views
FROM `workspace`.`default`.`viewership_data` v
JOIN `workspace`.`default`.`user_profiles_data` u
ON u.UserID = v.userid
GROUP BY v.Channel2
ORDER BY Total_views DESC
LIMIT 5;

---Evaluate the weak content on Low Days (Monday/Tuesday)
SELECT 
date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_name,
v.Channel2,
COUNT(*) AS Total_views
FROM `workspace`.`default`.`viewership_data` v
JOIN `workspace`.`default`.`user_profiles_data` u
ON u.UserID = v.userid
WHERE date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') IN ('Monday','Tuesday')
GROUP BY Day_name, v.Channel2
ORDER BY Total_views ASC;


---The data for the Pivot and Dashboard

SELECT 
u.UserID,
u.Age,
u.Gender,
u.Race,
u.Province,
v.Channel2,
 to_date(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) AS record_date,
date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'HH:mm:ss') AS record_time,
HOUR(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) AS Hour_SA,
date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS, 'EEEE') AS Day_Name,
CASE
WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 6 AND 9 THEN 'Early Morning'
WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 10 AND 12 THEN 'Late Morning'
WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 13 AND 15 THEN 'Early Afternoon'
WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 16 AND 18 THEN 'Late Afternoon'
WHEN hour(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm') + INTERVAL 2 HOURS) BETWEEN 19 AND 22 THEN 'Evening'
ELSE 'Late Night'
END AS Time_bucket,
date_format(TO_TIMESTAMP(v.RecordDate2, 'yyyy/MM/dd HH:mm'), 'MMMM') AS Month_name,
(
(HOUR(v.`Duration 2`) * 3600) +
(MINUTE(v.`Duration 2`) * 60) +
SECOND(v.`Duration 2`)
) AS Duration_Seconds,
CASE
WHEN u.Age < 18 THEN 'Under 18'
WHEN u.Age BETWEEN 18 AND 25 THEN '18-25'
WHEN u.Age BETWEEN 26 AND 35 THEN '26-35'
WHEN u.Age BETWEEN 36 AND 50 THEN '36-50'
ELSE '50+'
END AS Age_group
FROM `workspace`.`default`.`user_profiles_data`u
JOIN `workspace`.`default`.`viewership_data` v
ON u.UserID = v.UserID;
