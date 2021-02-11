
SELECT *
FROM app_store_apps
LIMIT 200;


SELECT *
FROM play_store_apps
LIMIT 100;

SELECT price, CAST(replace(price,'$','')::NUMERIC)
FROM play_store_apps

SELECT
COUNT (*)
FROM play_store_apps;

SELECT name, price, rating, primary_genre
FROM play_store_apps
FULL JOIN app_store_apps
USING (name)
LIMIT 100;

WITH calculations AS (
	SELECT name AS name, 
	rating AS rating, 
	CAST(replace(price,'$','')AS NUMERIC) AS price_num,
	CASE WHEN CAST(replace(price,'$','')AS NUMERIC) <=1 THEN 10000
		ELSE CAST(replace(price,'$','')AS NUMERIC)*10000 END AS initial_cost,
	CASE WHEN rating IS NULL THEN 1
		WHEN rating <.5 THEN 1
		WHEN rating <1 THEN 2
		WHEN rating <1.5 THEN 3
		WHEN rating <2 THEN 4
		WHEN rating <2.5 THEN 5
		WHEN rating <3 THEN 6
		WHEN rating <3.5 THEN 7
		WHEN rating <4 THEN 8
		WHEN rating <4.5 THEN 9
		WHEN rating <5 THEN 10 
		WHEN rating = 5 THEN 11 END AS life_span_yr
	FROM play_store_apps)
SELECT 
	psa.name,  
	psa.price,
	initial_cost,
	psa.rating,
	life_span_yr,
	life_span_yr*12*1500 - initial_cost AS profit 
FROM play_store_apps AS psa
JOIN calculations
USING (name)
ORDER BY profit DESC;

----------

WITH names AS (SELECT DISTINCT(name)
			FROM play_store_apps
			INNER JOIN app_store_apps
			USING (name)),
psa_calculations AS (
	SELECT name AS name, 
	CAST(rating AS FLOAT) AS ps_rating, 
	CAST(replace(price,'$','')AS FLOAT) AS ps_price,
	CASE WHEN CAST(replace(price,'$','')AS FLOAT) <=1 THEN 10000
		ELSE CAST(replace(price,'$','')AS FLOAT)*10000 END AS ps_initial_cost,
	CASE WHEN rating IS NULL THEN 1
		WHEN rating <.5 THEN 1
		WHEN rating <1 THEN 2
		WHEN rating <1.5 THEN 3
		WHEN rating <2 THEN 4
		WHEN rating <2.5 THEN 5
		WHEN rating <3 THEN 6
		WHEN rating <3.5 THEN 7
		WHEN rating <4 THEN 8
		WHEN rating <4.5 THEN 9
		WHEN rating <5 THEN 10 
		WHEN rating = 5 THEN 11 END AS ps_life_span_yr
	FROM play_store_apps),
asa_calculations AS (
	SELECT name AS name, 
	CAST(rating AS FLOAT) AS as_rating, 
	CAST(price AS FLOAT) AS as_price,
	CASE WHEN CAST(price AS FLOAT) <=1 THEN 10000
		ELSE CAST(price AS FLOAT)*10000 END AS as_initial_cost,
	CASE WHEN rating IS NULL THEN 1
		WHEN rating <.5 THEN 1
		WHEN rating <1 THEN 2
		WHEN rating <1.5 THEN 3
		WHEN rating <2 THEN 4
		WHEN rating <2.5 THEN 5
		WHEN rating <3 THEN 6
		WHEN rating <3.5 THEN 7
		WHEN rating <4 THEN 8
		WHEN rating <4.5 THEN 9
		WHEN rating <5 THEN 10 
		WHEN rating = 5 THEN 11 END AS as_life_span_yr
	FROM app_store_apps)
SELECT DISTINCT(names.name),
psa.ps_price,
psa.ps_initial_cost,
psa.ps_rating,
psa.ps_life_span_yr,
(2000*12*psa.ps_life_span_yr - psa.ps_initial_cost) AS psa_profit,
asa.as_price,
asa.as_initial_cost,
asa.as_rating,
asa.as_life_span_yr,
(2000*12*asa.as_life_span_yr - asa.as_initial_cost) AS asa_profit,
(2000*12*psa.ps_life_span_yr - psa.ps_initial_cost) + (2000*12*asa.as_life_span_yr - asa.as_initial_cost) AS total_profit
FROM names
LEFT JOIN psa_calculations AS psa
USING (name)
LEFT JOIN asa_calculations AS asa
USING (name)
ORDER BY total_profit DESC;
		