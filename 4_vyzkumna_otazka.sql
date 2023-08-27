/* Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?*/

WITH food_category AS (
		SELECT 
			gross_wages_name_per_emp AS gross_wages_name, 
			avg_wages_value AS wages, 
			food_category AS food_cat, 
			avg_price AS price,
			cz_price_year AS years
		FROM t_roman_matusek_project_sql_primary_final
		WHERE industry_branch IS NULL 
), food_category_one_yr_more AS (
		SELECT
			gross_wages_name_per_emp AS gross_wages_name,
			avg_wages_value AS wages,
			food_category AS food_cat, 
			avg_price AS price, 
			cz_price_year AS years, 
			cz_price_year -1 AS one_yr_less
		FROM t_roman_matusek_project_sql_primary_final
		WHERE industry_branch IS NULL 
			AND cz_price_year > (SELECT min(cz_price_year) 
							   FROM t_roman_matusek_project_sql_primary_final)
), food_percent_increase AS (
		SELECT	
			a.gross_wages_name,
			a.food_cat AS food_cat, 
			round(((b.price-a.price)/b.price)*100,2) AS YOY_price_food_increase,
			round(((b.wages-a.wages)/b.wages)*100,2) AS YOY_wages_increase,
			b.price AS price_B, 
			a.years AS years_A,
			b.years AS years_B,
			round(((b.price-a.price)/b.price)*100,2) - round(((b.wages-a.wages)/b.wages)*100,2) AS diff_wages_and_price
		FROM food_category AS a
		INNER JOIN	food_category_one_yr_more AS b
			ON	a.food_cat = b.food_cat
			AND a.years = b.one_yr_less
) 
SELECT  DISTINCT 
	years_A AS years_more_increase
FROM food_percent_increase
WHERE diff_wages_and_price>10
ORDER BY years_more_increase;