-- -----------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- Collecting our data -----------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------

-- first, we import out data, let's create a database to load our data into.

CREATE DATABASE MXMH_Survey;
USE MXMH_Survey;

-- Create a table with our csv file columns
CREATE TABLE survey_results1 (
  Timestamp TEXT,
  Age INT,
  Primary_streaming_service text,
  Hours_per_day DOUBLE,
  While_working TEXT,
  Instrumentalist CHAR(3),
  Composer VARCHAR(50),
  Fav_genre VARCHAR(20),
  Exploratory CHAR(3),
  Foreign_languages CHAR(3),
  BPM INT,
  Frequency_Classical VARCHAR(20),
  Frequency_Country VARCHAR(20),
  Frequency_EDM VARCHAR(20),
  Frequency_Folk VARCHAR(20),
  Frequency_Gospel VARCHAR(20),
  Frequency_Hip_hop VARCHAR(20),
  Frequency_Jazz VARCHAR(20),
  Frequency_K_pop VARCHAR(20),
  Frequency_Latin VARCHAR(20),
  Frequency_Lofi VARCHAR(20),
  Frequency_Metal VARCHAR(20),
  Frequency_Pop VARCHAR(20),
  Frequency_R_and_B VARCHAR(20),
  Frequency_Rap VARCHAR(20),
  Frequency_Rock VARCHAR(20),
  Frequency_Video_game_music VARCHAR(20),
  Anxiety INT,
  Depression INT,
  Insomnia INT,
  OCD INT,
  Music_effects VARCHAR(10),
  Permissions VARCHAR(20)
);

-- Let's check if the data is imported correctly
SELECT * FROM survey_results1 LIMIT 10;


-- -----------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- Cleaning our data -------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------

SET SQL_SAFE_UPDATES = 0;
SELECT * FROM survey_results1 LIMIT 10;
UPDATE survey_results1 SET music_effects = 'No effect' WHERE music_effects = "";
SET SQL_SAFE_UPDATES = 1; 
SELECT * FROM survey_results1 LIMIT 10;

-- -----------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- Exploring our data ------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------

-- Check the shape of our data (number of columns & rows)
SELECT COUNT(*) AS rows_num FROM survey_results1;
SELECT COUNT(*) AS cols_num FROM information_schema.columns WHERE table_name = 'survey_results1';

-- Check distinct values of select columns

SELECT COUNT(DISTINCT Age) FROM survey_results1;
SELECT DISTINCT primary_streaming_service FROM survey_results1;
SELECT DISTINCT Fav_genre FROM survey_results1;
SELECT DISTINCT Anxiety FROM survey_results1;
SELECT DISTINCT Depression FROM survey_results1;
SELECT DISTINCT Music_effects FROM survey_results1;

-- The Count and percentage from the total of each of the distinct values. This is to find the distribution of music listeners among different columns.
SELECT age, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM survey_results1)) * 100, 1) AS pct 
FROM survey_results1 GROUP BY 1 ORDER BY 3 DESC; 
SELECT primary_streaming_service, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM survey_results1)) * 100, 1) AS pct
FROM survey_results1 GROUP BY 1 ORDER BY 3 DESC;  # 458 (62.2%) of listeners use Spotify, 94 (12.8%) use YouTube Music, 71 (9.6%) do not use a streaming service, 51 (6.9%) use Apple Music, etc.
 # Fav genre - 188 (25.5%) favor Rock
SELECT anxiety, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM survey_results1)) * 100, 1) AS pct
FROM survey_results1 GROUP BY 1 ORDER BY 3 DESC;
SELECT depression, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM survey_results1)) * 100, 1) AS pct
FROM survey_results1 GROUP BY 1 ORDER BY 3 DESC;
SELECT music_effects, COUNT(*) FROM survey_results1 GROUP BY 1 ORDER BY 2 DESC;

-- Which favorite music genre has shown the most improvement in overall mental health?
SELECT Fav_genre, COUNT(music_effects) FROM survey_results1 WHERE music_effects = "Improve" GROUP BY 1 ORDER BY 2 DESC;
-- Answer: Rock has the highest effect on mental health with a count of 126 reporting it improved, followed by Pop (85), Metal(67), Classical(39).

-- Which favorite music genre has worsened mental health?
SELECT fav_genre, COUNT(music_effects) FROM survey_results1 WHERE music_effects = "Worsen" GROUP BY 1 ORDER BY 2 DESC;
-- Answer: Ironically, Rock has also the highest reported "worsened" mental health from listening to the genre (7 reported), followed by Pop (4) and Video game music (4). 

-- Omit false data value
DELETE FROM survey_results1
WHERE BPM = 999999999;

-- Which genre of music has produced the highest BPM?
SELECT fav_genre, MAX(BPM)
FROM survey_results1
GROUP BY fav_genre
ORDER BY MAX(BPM) DESC;
# Highest BPM producing genres: EDM, Rock, Metal

-- Do users with a high depression level tend to explore music?
SELECT Depression, COUNT(Exploratory) FROM survey_results1 WHERE Exploratory = "Yes" GROUP BY 1 ORDER BY 2 DESC;
SELECT Depression, COUNT(Exploratory) FROM survey_results1 WHERE Exploratory = "No" GROUP BY 1 ORDER BY 2 DESC;

-- Aggregations:

SELECT MIN(hours_per_day) AS min_hours, MAX(hours_per_day) AS max_hours, ROUND(AVG(hours_per_day),1) AS avg_hours
FROM survey_results1 WHERE hours_per_day != 0.1; # Decimal value not included; min: 0, max: 24 hrs, avg: 3.6 hrs

SELECT MIN(age) AS min_age, MAX(age) AS max_age, ROUND(AVG(age),1) AS avg_age
FROM survey_results1 WHERE age != 0; # min age: 0, max age: 89, avg age: 25.2

SELECT MIN(hours_per_day) AS min_hours, MAX(hours_per_day) AS max_hours, ROUND(AVG(hours_per_day),1) AS avg_hours
FROM survey_results1;

SELECT MIN(Anxiety) AS min_anxiety, MAX(Anxiety) AS max_anxiety, ROUND(AVG(Anxiety), 1) AS avg_anxiety
FROM survey_results1;

# Does music have the biggest effect on Anxiety, Depression, Insomnia, or OCD? 
SELECT 
  SUM(CASE WHEN anxiety > 0 THEN improve_count ELSE 0 END) AS anxiety_total,
  SUM(CASE WHEN depression > 0 THEN improve_count ELSE 0 END) AS depression_total,
  SUM(CASE WHEN OCD > 0 THEN improve_count ELSE 0 END) AS OCD_total
FROM (
  SELECT 
    anxiety, 
    depression, 
    insomnia, 
    OCD, 
    COUNT(music_effects) AS improve_count
  FROM survey_results1
  WHERE music_effects = 'Improve'
  GROUP BY anxiety, depression, insomnia, OCD
) t;

SELECT 
  SUM(CASE WHEN anxiety > 0 THEN worsen_count ELSE 0 END) AS anxiety_total,
  SUM(CASE WHEN depression > 0 THEN worsen_count ELSE 0 END) AS depression_total,
  SUM(CASE WHEN OCD > 0 THEN worsen_count ELSE 0 END) AS OCD_total
FROM (
  SELECT 
    anxiety, 
    depression, 
    insomnia, 
    OCD, 
    COUNT(music_effects) AS worsen_count
  FROM survey_results1
  WHERE music_effects = 'Worsen'
  GROUP BY anxiety, depression, insomnia, OCD
) t;













