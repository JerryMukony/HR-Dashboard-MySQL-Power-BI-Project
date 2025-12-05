USE project;

SELECT * FROM human_resources;

ALTER TABLE human_resources
CHANGE COLUMN ï»¿id Emp_id VARCHAR(20) NULL;

SELECT birthdate FROM human_resources;

UPDATE human_resources
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d' )
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d' )
    ELSE NULL
END;

DESCRIBE human_resources;

ALTER TABLE human_resources
MODIFY COLUMN birthdate DATE;

UPDATE human_resources
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d' )
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d' )
    ELSE NULL
END;
ALTER TABLE human_resources
MODIFY COLUMN hire_date DATE;

UPDATE human_resources
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

SELECT termdate FROM human_resources;
ALTER TABLE human_resources
MODIFY COLUMN termdate DATE;

ALTER TABLE human_resources
CHANGE COLUMN termdate termdate DATE DEFAULT NULL;

ALTER TABLE human_resources ADD COLUMN age INT;
UPDATE human_resources
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	ABS(min(age)) AS youngest,
	ABS(max(age)) AS oldest
FROM human_resources;

SELECT 
COUNT(*)
FROM human_resources
WHERE age < 18;

-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT 
gender,
COUNT(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate =''
GROUP BY gender;
 

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT 
race,
COUNT(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate =''
GROUP BY race
ORDER BY COUNT(*) DESC;

-- 3. What is the age distribution of employees in the company?
SELECT
min(age) AS youngest,
ROUND(AVG(age), 0) Avg_age,
max(age) AS oldest
FROM human_resources
WHERE age >= 18 AND termdate ='';

SELECT 
CASE 
	WHEN age >=18 AND age <=24 THEN '18-24'
    WHEN age >=25 AND age <=34 THEN '25-34'
    WHEN age >=35 AND age <=44 THEN '35-44'
    WHEN age >=45 AND age <=54 THEN '45-54'
    WHEN age >=55 AND age <=64 THEN '55-64'
    ELSE '65 +'
END age_group,
	count(*) AS count
FROM human_resources
WHERE age >=18 AND termdate = ''
GROUP BY age_group
ORDER BY age_group;


SELECT 
CASE 
	WHEN age >=18 AND age <=24 THEN '18-24'
    WHEN age >=25 AND age <=34 THEN '25-34'
    WHEN age >=35 AND age <=44 THEN '35-44'
    WHEN age >=45 AND age <=54 THEN '45-54'
    WHEN age >=55 AND age <=64 THEN '55-64'
    ELSE '65 +'
END age_group, gender,
	count(*) AS count
FROM human_resources
WHERE age >=18 AND termdate = ''
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT  
location,
count(*)
FROM human_resources
WHERE age >= 18 AND termdate = ''
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
	ROUND(avg(datediff(termdate, hire_date))/365,0) AS avg_length_employment_in_years
FROM human_resources
WHERE termdate <= CURDATE() AND termdate <> '' AND age >=18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT 
department,
gender,
COUNT(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate = ''
GROUP BY department, gender
ORDER BY department;


-- 7. What is the distribution of job titles across the company?
SELECT 
jobtitle,
department,
COUNT(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate = ''
GROUP BY jobtitle, department
ORDER BY jobtitle desc;

-- 8. Which department has the highest turnover rate?
SELECT
department,
total_count,
terminated_count,
ROUND((terminated_count/total_count ) * 100,2) AS termination_rate
FROM (
	SELECT department,
    COUNT(*) AS total_count,
    SUM(CASE WHEN termdate <> '' and termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
FROM human_resources
WHERE age >= 18
GROUP BY department
) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, location_city, COUNT(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate = ''
GROUP BY location_state, location_city
ORDER BY location_state, COUNT(*) DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
year(),
hires,
terminations,
hires - terminations AS net_change,
ROUND((hires - terminations)/hires * 100, 2) AS net_change_rate
	FROM(
		SELECT
			YEAR(hire_date) AS year,
			count(*) AS hires,
			SUM(CASE WHEN termdate <> '' and termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
		FROM human_resources
		WHERE age >=18
		GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, Round(avg(datediff(termdate, hire_date)/365), 0) AS avg_tenure
FROM human_resources
WHERE age >= 18 AND termdate = '' AND termdate <=CURDATE()
GROUP BY department;









