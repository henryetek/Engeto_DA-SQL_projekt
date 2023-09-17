
/*Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?*/

WITH food_category AS (
		SELECT DISTINCT 
			food_category AS food_cat, 
			avg_price AS price, 
			cz_price_year AS years
		FROM t_roman_matusek_project_sql_primary_final
), food_category_one_yr_more AS (
		SELECT DISTINCT 
			food_category AS food_cat, 
			avg_price AS price, 
			cz_price_year AS years, 
			cz_price_year -1 AS one_yr_less
		FROM t_roman_matusek_project_sql_primary_final
		WHERE cz_price_year > (SELECT min(cz_price_year) 
							   FROM t_roman_matusek_project_sql_primary_final)
), food_percent_increase AS (
		SELECT	
			a.food_cat AS food_cat, 
			a.price AS price_A, 
			a.years AS years_A,
			b.price AS price_B, 
			b.years AS years_B,
			round(((b.price-a.price)/b.price)*100,2) AS YOY_price_food_increase
		FROM food_category AS a
		INNER JOIN	food_category_one_yr_more AS b
			ON	a.food_cat = b.food_cat
			AND a.years = b.one_yr_less
)
SELECT 
	food_cat AS food_category,
	min(YOY_price_food_increase) AS YOY_price_food_increase
FROM food_percent_increase 
GROUP BY food_cat 
-- vynechání kategorií potravin, kde cena klesá
HAVING min(YOY_price_food_increase)>0
ORDER BY YOY_price_food_increase_%
LIMIT 1; 




