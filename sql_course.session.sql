SELECT
    AVG(salary_year_avg) AS year_avg_salary,
    AVG(salary_hour_avg) AS hour_avg_salary,
    job_schedule_type
FROM
    job_postings_fact
WHERE
    job_posted_date > '2023-06-01'
GROUP BY
    job_schedule_type;



SELECT
    COUNT(job_id) AS job_postings_count,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EDT' AS date_time,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2023
GROUP BY
    month
ORDER BY
    job_posted_date DESC;



SELECT
    COUNT(job_id) AS job_postings_count,
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EDT') AS month
FROM
    job_postings_fact
GROUP BY
    month
ORDER BY
    month ASC;



SELECT
    job_postings_fact.company_id,
    company_dim.name AS company_name,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM job_postings_fact
JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE job_health_insurance = 'TRUE'
    AND job_posted_date >= '2023-04-01' 
    AND job_posted_date < '2023-07-01'
ORDER BY
    month;

--January
CREATE TABLE january_jobs AS
    SELECT*
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

--February
CREATE TABLE february_jobs AS
    SELECT*
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

--March
CREATE TABLE march_jobs AS
    SELECT*
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs;



SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, YK' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
LIMIT
    20;



SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS Location_Category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;



SELECT
    job_title_short,
    salary_year_avg,
    CASE
        WHEN salary_year_avg < 181250 THEN 'low'
        WHEN salary_year_avg BETWEEN 181250 AND 493751 THEN 'standard' 
        ELSE 'high'
    END AS salary_category
FROM
    job_postings_fact
ORDER BY
    salary_year_avg DESC;



SELECT
    candidate_id
FROM candidates
WHERE skills IN ('Python', 'Tableau', and 'PostgreSQL')
ORDER BY candidate_id ASC;



SELECT candidate_id
FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING COUNT(DISTINCT skill) = 3
ORDER BY candidate_id ASC;



SELECT
    pages_likes.user_id,
    pages.page_id,
    pages.page_name
FROM
    pages
LEFT JOIN page_likes ON pages.page_id = page_likes.page.id
ORDER BY
    pages.page_id;

    