/*
 * Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 * použít CTE tabulku ???
 * Mzda klesá ve 23 případech
 */

SELECT DISTINCT 
	pf.industry_branch AS industry_branch, 
	pf.avg_wages_value AS wages,
	pf_1.wages AS wages_to_compare,
	concat_ws('-',pf.payroll_year,pf_1.years) AS years_period,
	CASE  
		WHEN (pf.avg_wages_value>pf_1.wages) THEN 'Mzda klesá'
		WHEN (pf.avg_wages_value<pf_1.wages) THEN 'Mzda roste'
		ELSE 'Mzda stagnuje'
	END AS wage_progression
FROM t_roman_matusek_project_SQL_primary_final AS pf
LEFT JOIN (
		SELECT 
			pf.industry_branch AS industry_branch,
			pf.avg_wages_value AS wages,
			pf.payroll_year AS years,
			pf.payroll_year -1 AS a_year_ago
		FROM t_roman_matusek_project_SQL_primary_final pf
		WHERE 
			industry_branch IS NOT NULL
			AND pf.payroll_year > (SELECT min(payroll_year) 
								   FROM t_roman_matusek_project_sql_primary_final)
		) AS pf_1 ON pf.payroll_year = pf_1.a_year_ago
		  		  AND pf.industry_branch = pf_1.industry_branch
WHERE 
	pf.industry_branch IS NOT NULL
	AND pf_1.a_year_ago IS NOT NULL
ORDER BY 
		industry_branch,
		pf.payroll_year,
		wage_progression 
		;



