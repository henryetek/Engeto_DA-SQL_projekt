/*Má výška HDP vliv na změny ve mzdách a cenách potravin? 
 *Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
*/

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
							   FROM t_roman_matusek_project_sql_primary_final
							   WHERE industry_branch IS NULL)
), food_percent_increase AS (
		SELECT	
			a.gross_wages_name,
			a.food_cat AS food_cat, 
			round(((b.price-a.price)/b.price)*100,2) AS YOY_price_food_increase,
			round(((b.wages-a.wages)/b.wages)*100,2) AS YOY_wages_increase,
			a.wages AS wages_A,
			b.wages AS wages_B,
			a.price AS price_A,
			b.price AS price_B, 
			a.years AS years_A,
			b.years AS years_B
		FROM food_category AS a
		INNER JOIN	food_category_one_yr_more AS b
			ON	a.food_cat = b.food_cat
			AND a.years = b.one_yr_less
)
SELECT  DISTINCT
	concat_ws('-',fi.years_A,fi.years_B) AS years_period,
	HDP.status_HDP,
	HDP.hdp_increase,
	CASE 
		WHEN (HDP.hdp_increase > 3)THEN 'výrazný růst'
		WHEN (HDP.hdp_increase > 0 AND  HDP.hdp_increase < 3)THEN 'standardní_růst'
		WHEN (HDP.hdp_increase < 0 AND  HDP.hdp_increase > -3)THEN 'standardní_pokles'
		WHEN (HDP.hdp_increase < -3)THEN 'výrazný pokles'
		ELSE 'HDP stagnuje'
	END AS progress_HDP,
	fi.YOY_wages_increase AS wages_increase,
	CASE WHEN (fi.YOY_wages_increase > 3) THEN 'výrazný růst'
		 WHEN (fi.YOY_wages_increase > 0  AND fi.YOY_wages_increase < 3)  THEN 'standardní_růst'
		 WHEN (fi.YOY_wages_increase < 0  AND  fi.YOY_wages_increase > -3)THEN 'standardní_pokles'
		 WHEN (fi.YOY_wages_increase < -3)THEN 'výrazný pokles'
		 ELSE 'HDP stagnuje'
	END AS progress_wages,
	wi.progress_food,
	CASE WHEN (wi.progress_food > 3) THEN 'výrazný růst'
		 WHEN (wi.progress_food > 0  AND wi.progress_food < 3)  THEN 'standardní_růst'
		 WHEN (wi.progress_food < 0  AND wi.progress_food > -3)THEN 'standardní_pokles'
		 WHEN (wi.progress_food < -3)THEN 'výrazný pokles'
		 ELSE 'HDP stagnuje'
	END AS progress_food_price
FROM food_percent_increase AS fi
LEFT JOIN (
		SELECT 
			round(avg(price_A),2) AS avg_food_price , 
			round(avg(price_B),2) AS avg_food_price_next_yr , 
			(round(avg(price_A),2) - round(avg(price_B),2)) AS progress_food,
			years_A
		FROM  food_percent_increase
		GROUP BY years_A
		) AS wi ON fi.years_A = wi.years_A
LEFT JOIN (
		SELECT 
			TA.country , 
			TA.GDP , 
			TB.HDP, 
			TA.`year` AS years_A, 
			TB.years AS years_B,
			concat_ws('-',TA.`year`,TB.years) AS years_period,
			round(((TB.HDP - TA.GDP)/TB.HDP) * 100,2) AS hdp_increase,
			CASE 
					WHEN (TB.HDP > TA.GDP)THEN 'HDP roste'
					WHEN (TB.HDP < TA.GDP)THEN 'HDP klesá'
					ELSE 'HDP stagnuje'
			END AS status_HDP
		FROM t_roman_matusek_project_sql_secondary_final AS TA
		INNER JOIN (
					SELECT 
						country AS countryA, 
						GDP AS HDP, 
						`year` AS years
					FROM t_roman_matusek_project_sql_secondary_final
					WHERE abbreviation = 'CZ' 
						AND `year` > (SELECT min(`year`) 
									  FROM t_roman_matusek_project_sql_secondary_final
									  WHERE abbreviation = 'CZ' )
					) AS TB ON TA.`year` = TB.years-1
		WHERE abbreviation = 'CZ'  
	) AS HDP ON fi.years_A = HDP.years_A 
			AND fi.years_B = HDP.years_B
ORDER BY
	years_period;


