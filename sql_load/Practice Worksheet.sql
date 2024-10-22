CREATE TABLE job_applied(
    job_id INT,
    job_application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
);
SELECT *
FROM job_applied;
DROP TABLE job_applied;
INSERT INTO job_applied (
        job_id,
        job_application_sent_date,
        custom_resume,
        resume_file_name,
        cover_letter_sent,
        cover_letter_file_name,
        status
    )
VALUES (
        1,
        '2024-02-01',
        true,
        'resume_01.pdf',
        true,
        'cover_letter_01.pdf',
        'submitted'
    ),
    (
        2,
        '2024-02-02',
        true,
        'resume_02.pdf',
        false,
        NULL,
        'interview scheduled'
    ),
    (
        3,
        '2024-02-03',
        true,
        'resume_03.pdf',
        true,
        'cover_letter_03.pdf',
        'ghosted'
    ),
    (
        4,
        '2024-02-04',
        true,
        'resume_04.pdf',
        false,
        NULL,
        'submitted'
    ),
    (
        5,
        '2024-02-05',
        false,
        'resume_05.pdf',
        true,
        'cover_letter_05.pdf',
        'rejected'
    );
ALTER TABLE job_applied
ADD contact VARCHAR(55);
UPDATE job_applied
SET contact = 'Elrich Bachman'
WHERE job_id = 1;
UPDATE job_applied
SET contact = 'Vanessa Pontes'
WHERE job_id = 2;
UPDATE job_applied
SET contact = 'Bertram Gilfoyle'
WHERE job_id = 3;
UPDATE job_applied
SET contact = 'Jian Yang'
WHERE job_id = 4;
UPDATE job_applied
SET contact = 'Dinesh Chugtai'
WHERE job_id = 5;
ALTER TABLE job_applied
    RENAME COLUMN contact TO contact_name;
ALTER TABLE job_applied
ALTER COLUMN contact_name TYPE TEXT;
ALTER TABLE job_applied DROP COLUMN contact_name;
DROP TABLE job_applied;
SELECT *
FROM job_postings_fact
WHERE job_posted_date < '2023-01-01';
SELECT job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date,
    EXTRACT(
        MONTH
        FROM job_posted_date
    ) AS date_month
FROM job_postings_fact
LIMIT 100;
-- write a query to find the average salary both yearly (salary_year_avg)
-- and hourly (salary_hour_avg) for job postings that were posted after June 1, 2023.
-- Group the results by job schedule type.
SELECT job_schedule_type,
    AVG(salary_year_avg) AS avg_yearly_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM job_postings_fact
WHERE job_posted_date > '2023-06-01'
GROUP BY job_schedule_type;
-- Write a query to count the number of job postings for each month in 2023,
-- adjusting the job_posted_date to be in 'American/New York' time zone before extracting (hint) the month.
-- Assume the job_posted_date is stored in UTC. Group by and order by month
SELECT COUNT(job_title_short) AS job_postings_count,
    EXTRACT(
        MONTH
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EDT'
    ) as posted_month
FROM job_postings_fact
WHERE job_posted_date > '2023-01-01'
    AND job_posted_date < '2024-01-01'
GROUP BY EXTRACT(
        MONTH
        FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EDT'
    )
ORDER BY posted_month;
--Write a query to find companies (include company name) that have posted jobs offered health insurance,
--where this postings were made in the second quarter of 2023.
--use data extraction to filter by quarter
SELECT company_dim.name,
    job_postings_fact.job_title_short,
    job_postings_fact.job_posted_date::DATE AS date
FROM job_postings_fact
    LEFT JOIN company_dim ON company_dim.company_id = job_postings_fact.company_id
WHERE job_postings_fact.job_health_insurance = 'true'
    AND EXTRACT(
        YEAR
        FROM job_posted_date
    ) = 2023
    AND EXTRACT(
        QUARTER
        FROM job_posted_date
    ) = 2;
--january
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
        MONTH
        FROM job_posted_date
    ) = 1;

--february
CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
        MONTH
        FROM job_posted_date
    ) = 2;

--march
CREATE TABLE march_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(
        MONTH
        FROM job_posted_date
    ) = 3;
SELECT *
FROM january_jobs;

--Question
--I want to categorize the salaries from each job posting. To see if it fits in my desired salary range.
--Put salary into different bucket
--Define what's a high, standard, or low salary with our own conditions
--Why? it is easy to determine which job postings are worth looking at based on salary. 
--Bucketing is a common practice in data analysis for viewing categories. 
--I only want to look at data analyst roles. 
--Order from highest to lowest

SELECT 
    MAX(salary_year_avg) AS max_salary,
    MIN(salary_year_avg) AS min_salary
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst';


SELECT
    job_title_short,
    salary_year_avg,
    CASE
        WHEN salary_year_avg > '441666.67' THEN 'high'
        WHEN salary_year_avg >= '233333.33' AND salary_year_avg <= '441666.67' THEN 'standard'
        ELSE 'low'
    END AS salary_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
ORDER BY salary_year_avg DESC;

/*
Find the companies that have the most job openings. 
-Get the total number of job postings per company ID.
-Returned the total number of jobs with the company name.
*/

--Subquery

SELECT
    job_title_short,
    company_id,
    COUNT(*) AS job_count
FROM job_postings_fact
GROUP BY
    job_id
ORDER BY
    job_count DESC;

SELECT
    name,
    company_count
FROM(
SELECT
    company_dim.name,
    job_postings_fact.company_id,
    count(*) AS company_count
FROM
    company_dim
LEFT JOIN
    job_postings_fact ON company_dim.company_id = job_postings_fact.company_id
GROUP BY
    company_dim.name,
    job_postings_fact.company_id
ORDER BY
    company_count DESC
) AS total_company_posting;

--CTEs

WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT
    company_dim.name,
    company_job_count.total_jobs
FROM
    company_dim
LEFT JOIN
    company_job_count ON company_dim.company_id = company_job_count.company_id
ORDER BY
    total_jobs DESC;


/*Identify the top five skills that are most frequently mentioned in job postings.
--use a subquery to find the skill IDs with the highest counts in the skills_job_dim table
--and then join this result of the skills_dim table to get skill names.
*/

--Subquery
SELECT
    skills_dim.skills AS skill_name
FROM
    skills_dim
JOIN(
    SELECT
        skill_id,
        COUNT(*)
    FROM skills_job_dim
    GROUP BY
        skill_id
    ORDER BY
        count DESC
    LIMIT 5
) skills_job_dim ON skills_dim.skill_id = skills_job_dim.skill_id;


--CTEs
WITH job_skills_count AS (
SELECT
    skill_id,
    COUNT(*) AS skill_count
FROM
    skills_job_dim
GROUP BY
    skill_id
ORDER BY
    skill_count DESC
LIMIT
    5
)

SELECT
    skills_dim.skills
FROM
    skills_dim
LEFT JOIN
    job_skills_count ON skills_dim.skill_id = job_skills_count.skill_id
ORDER BY
    job_skills_count.skill_count DESC


/*
--Determine the size small medium or large for each company but first identifying the number of job postings they have.
--Use a subquery to calculate the total job postings per company. 
--A company is considered small if it has less than 10 job postings, 
--medium if the number of job postings is between 10 and 50, 
--and Large if it has more than fifty job postings. 
--Implemented a subquery to aggregate job counts per company before classifying them based on size.
*/


SELECT
    company_id,
    CASE
        WHEN job_postings_count > 50 THEN 'large'
        WHEN job_postings_count BETWEEN 10 AND 50 THEN 'medium'
        ELSE 'small'
    END AS company_category
FROM (
    SELECT
        company_id,
        COUNT(*) AS job_postings_count
    FROM
        job_postings_fact
    GROUP BY
        company_id
) AS job_count;

/*
--Find the count of the number of remote job postings per skill
  --display the top 5 skills by their demand in remote jobs
  --include skill ID, name, and count of postings requiring the skill
*/

WITH remote_job_count AS (
    SELECT
        skills_job_dim.skill_id,
        COUNT(*) AS skill_count
    FROM
        job_postings_fact
    INNER JOIN
        skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    WHERE
        job_work_from_home = TRUE
    GROUP BY
        skills_job_dim.skill_id
)

SELECT
    skills_dim.skill_id,
    skills_dim.skills AS skill_name,
    skill_count
FROM
    remote_job_count
INNER JOIN
    skills_dim ON remote_job_count.skill_id = skills_dim.skill_id
ORDER BY
    skill_count DESC
LIMIT 5

/*
union operators

Get the corresponding skill and skill type for each job posting quarter one.
Include those without any skills too.
why? Look at the skills and the type for each job first quarter to have a salary > $70,000.
*/

SELECT
    job_id,
    NULL AS skills,
    NULL AS type
FROM
    job_postings_fact
WHERE
    salary_year_avg > 70000 AND
    EXTRACT(QUARTER FROM job_posted_date) = 1

UNION

SELECT
    job_id,
    skills_dim.skills,
    skills_dim.type
FROM
    skills_dim
LEFT JOIN
    skills_job_dim ON skills_job_dim.skill_id = skills_dim.skill_id





SELECT *
FROM job_postings_fact
WHERE
    salary_year_avg > 70000 AND
    EXTRACT(QUARTER FROM job_posted_date) = 1
ORDER BY
    job_id ASC
LIMIT 100;

SELECT *
FROM skills_dim
LIMIT 100;