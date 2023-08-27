/*
 data mezd (tabulka czechia_payroll a související tabulky) a cen potravin (tabulka czechia_price a související tabulky)  
 a číselníky krajů a regionů za Českou republiku 
 sjednocených na totožné porovnatelné období – společné roky
 */

CREATE OR REPLACE TABLE t_roman_matusek_project_SQL_primary_final AS
(SELECT pay.*, price.*
FROM (
	/*pro srovnatelné období je cena zprůměrovaná na jednotlivé roky*/
	SELECT 
		cpc.name AS food_category,
		round(avg(cp.value),2) AS avg_price, 
		cpc.price_value AS food_value,
		cpc.price_unit AS food_unit,
		YEAR(cp.date_from) AS cz_price_year 
	FROM czechia_price AS cp 
	LEFT JOIN czechia_price_category AS cpc 
		ON cp.category_code = cpc.code 
	LEFT JOIN czechia_region AS cr 
		ON cp.region_code = cr.code
	WHERE cp.region_code IS NULL
	GROUP BY 
		cpc.name, 
		concat(cpc.price_value,' ',cpc.price_unit), 
		YEAR(cp.date_from)
	)AS price
LEFT JOIN (
	/*pro srovnatelné období je cena zprůměrovaná na jednotlivé roky
	 * hodnotím údaje o mzdách , kod = 5958 (vynechání údajů o počtu "Průměrný počet zaměstnaných osob")
	 * kalkulační kod je pro fyzické osoby (nepočítám s přepočtenými hodnotami)
	 * */
	SELECT 
		payb.name AS industry_branch,
		payv.name AS gross_wages_name_per_emp,
		avg(pay.value) AS avg_wages_value,
		payu.name AS unit,
		payc.name AS calcul_code,
		pay.payroll_year AS  payroll_year 
	FROM czechia_payroll AS pay
	LEFT JOIN czechia_payroll_industry_branch AS payb 
		ON pay.industry_branch_code = payb.code
	LEFT JOIN czechia_payroll_unit payu 
		ON pay.unit_code = payu.code 
	LEFT JOIN czechia_payroll_calculation payc 
		ON pay.calculation_code = payc.code 
	LEFT JOIN czechia_payroll_value_type AS payv 
		ON pay.value_type_code = payv.code
		AND payv.code = 5958 
	WHERE payv.code IS NOT NULL 
		AND pay.calculation_code = 100
	GROUP BY 
		payb.name, 
		payv.name, 
		payu.name, 
		payc.name, 
		pay.payroll_year
	) AS pay ON price.cz_price_year = pay.payroll_year 	
);

