
CREATE TABLE t_roman_matusek_project_SQL_secondary_final (
	SELECT 
		c.continent,
		c.region_in_world,
		e.country, 
		c.capital_city,
		c.abbreviation,
		c.currency_name,
		c.currency_code ,
		e.`year`,
		e.GDP, 
		e.gini, 
		e.taxes
	FROM (
			SELECT 
				country, 
				`year`,
				GDP, 
				gini, 
				taxes
			FROM economies
			WHERE gini IS NOT NULL
		 ) AS e
	JOIN (
			SELECT 
				country,
				abbreviation ,
				capital_city ,
				continent , 
				region_in_world ,
				currency_name , 
				currency_code 
			FROM countries
		 ) AS c ON c.country = e.country
);