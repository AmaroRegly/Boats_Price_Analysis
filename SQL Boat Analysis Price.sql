#------------ DATA PROCESSING ------------------

#Remove useless variables

ALTER TABLE boats_dataset
DROP COLUMN MyUnknownColumn;

#--------------- TREAT NULL VALUES ---------------

#-------Engine Category Column ----

SELECT 
	engineCategory,
	COUNT(engineCategory) AS count_engine_category #------>Find the amount of null values
FROM
	boats_dataset
GROUP BY
	engineCategory;
    
UPDATE boats_dataset
SET engineCategory = 'unknown'
WHERE engineCategory = '';

#--------Fuel Type Column ---

SELECT 
	fuelType,
   	COUNT(fuelType) AS count_fuel_type
FROM
	boats_dataset
GROUP BY
	fuelType;

UPDATE boats_dataset
SET fuelType = 'unknown'
WHERE fuelType = '';

# ------- Max Engine Year Column ---

SELECT
	maxEngineYear,
   	COUNT(maxEngineYear) AS count_max_engine_year
FROM
	boats_dataset
GROUP BY
	maxEngineYear;

UPDATE boats_dataset
SET maxEngineYear = 'unknown'
WHERE maxEngineYear = 'NA';

UPDATE boats_dataset
SET city = 'unknown'
WHERE city = '';

# ---------- Min Engine Year Column ---

SELECT
	minEngineYear,
    	COUNT(minEngineYear) AS count_min_engine_year
FROM
	boats_dataset
GROUP BY
	minEngineYear;
    
UPDATE boats_dataset
SET minEngineYear = 'unknown'
WHERE minEngineYear = 'NA';

#------------- TREAT VALUES OF CATEGORICAL VARIABLES -----------

ALTER TABLE boats_dataset
MODIFY COLUMN created_date datetime;

ALTER TABLE boats_dataset
CHANGE `condition` situation text;

#----------------- GENERAL DATA ANALYSIS (Understanding the data) ------------------

# --------- Average Boats Price --------

SELECT
	FORMAT(AVG(price),0) AS boat_price_average,
    	FORMAT(MAX(price),0) AS max_price_boat,
    	FORMAT(MIN(price),0) AS min_price_boat
FROM
	boats_dataset;
    
#------- Amount of new and used boats ------------

SELECT
	situation,
    	COUNT(situation) AS amount_situation_boats
FROM
	boats_dataset
GROUP BY
	situation
ORDER BY
	amount_situation_boats desc;
    
#---------- Number of boats by type ------------

SELECT
	type,
	COUNT(type) AS type_boats
FROM
	boats_dataset
GROUP BY
	type
ORDER BY
	type_boats desc;
    
#------------ Number of boats by fuel type ---------------

SELECT
	fuelType,
    	COUNT(fuelType) AS fuel_type_boats
FROM
	boats_dataset
GROUP BY
	fuelType
ORDER BY
	fuel_type_boats desc;
    
#------------- Number of Engines -------------

SELECT
	numEngines,
    	COUNT(numEngines) AS number_engines_count
FROM
	boats_dataset
GROUP BY
	numEngines
ORDER BY
	number_engines_count desc;
    
#------------- Number of boats per year of manufacture (year = year of the boat) ---------------

SELECT
	year,
    	COUNT(*) AS count_year
FROM
	boats_dataset
GROUP BY
	year
ORDER BY
	count_year desc;
        
#------------ Sales by seller -----------------
    
SELECT
	sellerId,
    	COUNT(*) AS number_sales
FROM
	boats_dataset
GROUP BY
	sellerId
ORDER BY
	number_sales desc;

#-------------- Number of sales by year ----------------

SELECT
	created_year,
    	COUNT(*) AS count_sales
FROM
	boats_dataset
GROUP BY
	created_year
ORDER BY
	count_sales desc;

#-------------- Number of boats by brand ------------

SELECT
	make,
    	COUNT(make) AS count_boats_by_brand
FROM
	boats_dataset
GROUP BY
	make
ORDER BY
	count_boats_by_brand desc;

#----------- Number of hull material --------------

SELECT
	hullMaterial,
    	COUNT(hullMaterial) AS count_hull_material
FROM
	boats_dataset
GROUP BY
	hullMaterial
ORDER BY
	count_hull_material desc;
    
#------------ Average Age of Boats --------------

SELECT
	ROUND(AVG(EXTRACT(Year FROM CURRENT_DATE) - Year),0) AS Age
FROM
	boats_dataset;

    
#----------------- DATA ANALYSIS FOR STAKEHOLDERS -----------------
    
#------------ Boats with above average prices ----------------
    
SELECT
	*
FROM
	boats_dataset
WHERE
	price > (SELECT AVG(price) FROM boats_dataset) and
    fuelType <> 'unknown';

#--------------- Which is the most expensive boat sold for each seller? -------------

SELECT
	sellerId,
	MAX(price) AS max_price
FROM
	boats_dataset
GROUP BY
	sellerId
ORDER BY
	max_price desc;
    
#---------- What are the average prices for new boats manufactured after 2010 by type of fuel? -------------

SELECT
	fuelType,
    	ROUND(AVG(price),2) AS Avg_price
FROM
	boats_dataset
WHERE
	situation = 'new' and
    	year > 2010 and
    	fuelType <> 'unknown'
GROUP BY
	fuelType
ORDER BY
	Avg_price desc;

#--------- Which city buys the most boats? --------------

SELECT
	city,
    	COUNT(*) AS count_city
FROM
	boats_dataset
GROUP BY
	city
ORDER BY
	count_city desc;

#--------- Pricing Analysis ------------

#------------ What is the average price of boats per year of manufacture? -----------

SELECT
	Year,
	FORMAT(ROUND(AVG(price), 2),0) AS avg_price
FROM
	boats_dataset
GROUP BY
	Year
ORDER BY
	avg_price desc;

#------------ Is there a relationship between the price and the age of the boat? ------------

SELECT 
    	FORMAT(ROUND(AVG(CASE WHEN Year > 2000 THEN price END), 2),0) AS avg_price_higher_2000s,
    	FORMAT(ROUND(AVG(CASE WHEN Year < 2000 THEN price END), 2),0) AS avg_price_lower_2000s
FROM 
    	boats_dataset;
    
#-------------- What is the price distribution of boats by hull type (hullMaterial)? --------------

SELECT
	hullMaterial,
    	AVG(price) AS avg_price_hull
FROM
	boats_dataset
GROUP BY
	hullMaterial
ORDER BY
	avg_price_hull desc;

#------------- Engine performance analysis---------------------

#------------- What is the average engine power by type of boat? ------------ 

SELECT
	type,
    	AVG(totalHP) AS avg_hp
FROM
	boats_dataset
GROUP BY
	type;

#---------- Is there a relationship between the number of engines and total power? A: Yes, according to the analysis, the more engines, the more power the boat has. --------------

SELECT
	numEngines,
    AVG(totalHP)
FROM
	boats_dataset
GROUP BY
	numEngines;
    
#----------- What is the average age of engines per engine category (engineCategory)? --------------

SELECT
    	engineCategory,
    	ROUND(AVG(EXTRACT(Year FROM CURRENT_DATE) - maxEngineYear), 0) AS avg_age_engine
FROM
	boats_dataset
WHERE
	maxEngineYear <> 'unknown'
GROUP BY
	engineCategory;

#--------------- Geographic analysis ---------------------

#----------- What is the geographic distribution of boat sales by state? ------------

SELECT
	state,
    	COUNT(*) AS count_sales_by_state
FROM
	boats_dataset
GROUP BY
	state
ORDER BY
	count_sales_by_state desc;

#---------- Is there a correlation between the price of boats and geographic location? A: In the analysis, we can notice that the average price, the sum of sales and the highest price come from the state of Florida. -------

SELECT
	state,
    	ROUND(AVG(price), 2) AS avg_price_state,
    	SUM(price) AS sum_price,
    	MAX(price) AS max_price
FROM
	boats_dataset
GROUP BY
	state
ORDER BY
	sum_price desc,
    avg_price_state desc,
    max_price desc;

#----------- How do sales vary over time in different cities? ------------

SELECT
	city,
	created_year,
    	FORMAT(SUM(price),0) AS sum_price,
    	FORMAT(AVG(price),0) AS avg_price
FROM
	boats_dataset
GROUP BY
	created_year,
    city
ORDER BY
	city,
    	created_year;

#------------- Análise de tendências----------------

#--------What is the boat sales trend over the years? A: We can say that, over the years, we have increased our boat portfolio and have more expensive boats. Consequently, our revenue potential has increased due to this variety of boats.

SELECT
	created_year,
    	COUNT(*) AS number_boats,
    	FORMAT(SUM(price),0) AS sum_price,
    	FORMAT(AVG(price),0) AS avg_price,
    	FORMAT(MIN(price),0) AS min_price,
    	FORMAT(MAX(price),0) AS max_price
FROM
	boats_dataset
GROUP BY
	created_year
ORDER BY
	created_year;

#--------- Is there a trend in the popularity of different types of boats over time? A: "Power" type boats have always led sales, but from 2013, we started selling "sail" type boats. However, this type of boat only became relevant in sales in 2018, but still, with a lower number of sales than "power" type boats.

SELECT
	created_year,
    	type,
    	COUNT(*) AS number_sales
FROM
	boats_dataset
GROUP BY
	created_year,
    type
ORDER BY
	created_year;

#----------------- Análise de sazonalidade ----------------- 

#------ Is there seasonality in boat sales over the years? A: Over the years, late summer and early fall are times of greatest sales. Both in average price per month and in units sold. -----------

SELECT
	created_month,
    	FORMAT(ROUND(AVG(price),2),0) AS avg_price,
    	COUNT(*) AS total_sales_per_mounth,
    	CASE
		WHEN created_month IN (06, 07, 08) THEN 'Summer'
	        WHEN created_month IN (09, 10, 11) THEN 'Fall'
	        WHEN created_month IN (12, 01, 02) THEN 'Winter'
	        WHEN created_month IN (03, 04, 05) THEN 'Spring'
		END AS Season
FROM
	boats_dataset
GROUP BY
	created_month
ORDER BY
	created_month;    

#--------- What is the impact of seasonality on sales of different types of boats? A: "Power" type boats continue to be the best-selling boats at any time. However, in late spring and early summer, sail-type boats see a slight increase in sales.

WITH season_analysis AS (
	SELECT
		created_month,
		COUNT(*) AS total_sales_per_month,
		CASE
			WHEN created_month IN (06, 07, 08) THEN 'Summer'
			WHEN created_month IN (09, 10, 11) THEN 'Fall'
			WHEN created_month IN (12, 01, 02) THEN 'Winter'
			WHEN created_month IN (03, 04, 05) THEN 'Spring'
		END AS Season,
		type
	FROM
		boats_dataset
	GROUP BY
		Season,
		type, created_month
	ORDER BY
		created_month
)
SELECT
	Season,
    	type,
    	SUM(total_sales_per_month) AS number_sales
FROM
	season_analysis
GROUP BY
	Season,
    type;

#----------- Boat type percentage ----------------

SELECT 
    	type,
    	COUNT(*) AS total_count,
    	(COUNT(*) / (SELECT COUNT(*) FROM boats_dataset)) * 100 AS percentage
FROM 
    	boats_dataset
GROUP BY 
    	type;


# ------------ Ranking of Price ------------------

SELECT
	fuelType,
    	FORMAT(sum(price),0) AS total ,
    	RANK() OVER(ORDER BY sum(price) desc) AS ranking_price
FROM
	boats_dataset
GROUP BY
	fuelType;
