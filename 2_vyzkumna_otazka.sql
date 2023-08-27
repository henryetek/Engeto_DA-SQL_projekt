/*
 * Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 */

SELECT 
	cpp.years AS years,
	cpp.food AS food_category, 
	concat(round((cpp.wages/cpp.food_price),0),' ', cpp.food_unit) AS number_to_buy
FROM (
		SELECT 
			pp.avg_wages_value AS wages,
			pp.payroll_year AS years, 
			pp.food_category AS food, 
			pp.avg_price AS food_price,
			pp.food_unit AS food_unit
		FROM t_roman_matusek_project_sql_primary_final AS pp
		WHERE pp.industry_branch IS NULL
			 AND (pp.food_category = 'Mléko polotučné pasterované' OR pp.food_category ='Chléb konzumní kmínový')
			 AND pp.payroll_year = (SELECT min(payroll_year) 
									FROM t_roman_matusek_project_sql_primary_final AS pp
									WHERE pp.industry_branch IS NULL
										 AND (pp.food_category = 'Mléko polotučné pasterované' OR pp.food_category ='Chléb konzumní kmínový')) 
	UNION ALL
		SELECT 
			pp.avg_wages_value AS wages,
			pp.payroll_year AS years, 
			pp.food_category AS food, 
			pp.avg_price AS food_price,
			pp.food_unit AS food_unit
		FROM t_roman_matusek_project_sql_primary_final AS pp
		WHERE pp.industry_branch IS NULL
			 AND (pp.food_category = 'Mléko polotučné pasterované' OR pp.food_category ='Chléb konzumní kmínový')
			 AND pp.payroll_year = (SELECT max(payroll_year) 
									FROM t_roman_matusek_project_sql_primary_final AS pp
									WHERE pp.industry_branch IS NULL
										 AND (pp.food_category = 'Mléko polotučné pasterované' OR pp.food_category ='Chléb konzumní kmínový'))
	)cpp
ORDER BY years,food_category DESC; 

