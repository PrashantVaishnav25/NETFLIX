CREATE TABLE netflix
	(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(500),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(260)
	);

SELECT * FROM netflix;
SELECT COUNT(show_id) FROM netflix;

--Business Problems:

--Count the Number of Movies vs TV Shows
SELECT type, COUNT(TYPE)
FROM netflix
GROUP BY 1;

--Find the Most Common Rating for Movies and TV Shows
SELECT
	type,
	rating
FROM	
	(
	SELECT 
		type,
		rating,
		COUNT(*),
		RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
	FROM netflix
	GROUP BY 1,2
	)	AS t1
	WHERE ranking = 1;
	
-- List All Movies Released in a Specific Year (e.g., 2020)
SELECT title
FROM netflix
WHERE release_year = 2020;

--Find the Top 5 Countries with the Most Content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;

--Identify the Longest Movie
SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

--Find Content Added in the Last 5 Years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';


--List All TV Shows with More Than 5 Seasons
SELECT *
	FROM netflix
WHERE type = 'TV Show'
		AND 
		SPLIT_PART(duration, ' ', 1)::INT > 5;

--Count the Number of Content Items in Each Genre
SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')) AS GENRE,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1;
	

--Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- List All Movies that are Documentaries
SELECT * FROM NETFLIX
WHERE listed_in ILIKE '%Documentaries%';


--Find All Content Without a Director
SELECT * FROM netflix
WHERE director IS NULL;


--Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT *
FROM netflix
WHERE
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
	AND 
	CASTS ILIKE '%SALMAN KHAN%';

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS Actor,
	COUNT(*) 
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


--Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
	


