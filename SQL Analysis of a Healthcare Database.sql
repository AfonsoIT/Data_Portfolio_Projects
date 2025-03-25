/*
Healthcare Patient Data Exploration

*/

--Understand column names and data types

SELECT *
FROM nis_table
LIMIT 10;


-- Count patients by age, gender and region

SELECT AGE, SEX, HOSP_REGION, COUNT(*) AS patient_count
FROM nis_table
GROUP BY AGE, SEX, HOSP_REGION
ORDER BY patient_count DESC;


-- Analyze readmissions by combining patient and hospital data

SELECT p.AGE, p.SEX, h.HOSP_REGION, p.TOTCHG
FROM nis_table AS p
JOIN hospital_info AS h 
ON p.HOSP_ID = h.HOSP_ID
WHERE p.READMIT = 1;

-- Readmission Rate by Diagnostics

SELECT DX1 AS primary_diagnosis, COUNT(*) AS total_cases, SUM(CASE WHEN READMIT = 1 THEN 1 ELSE 0 END) AS readmissions, ROUND(100.0 * SUM(CASE WHEN READMIT = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmission_rate
FROM nis_table
GROUP BY DX1
ORDER BY readmission_rate DESC
LIMIT 20;

or

WITH ReadmissionStats AS (
    SELECT DX1, COUNT(*) AS total_cases, SUM(CASE WHEN READMIT = 1 THEN 1 ELSE 0 END) AS readmissions
    FROM nis_table
    GROUP BY DX1
)
SELECT DX1, ROUND(100.0 * readmissions / total_cases, 2) AS readmission_rate
FROM ReadmissionStats
ORDER BY readmission_rate DESC
LIMIT 20;


-- Average Hospital Charge by Diagnosis and Region

SELECT DX1 AS primary_diagnosis, HOSP_REGION, ROUND(AVG(TOTCHG), 2) AS avg_hospital_charge, COUNT(*) AS case_count
FROM nis_table
GROUP BY DX1, HOSP_REGION
ORDER BY avg_hospital_charge DESC
LIMIT 20;


--  Length of Stay vs. Cost Analysis

SELECT LOS, ROUND(AVG(TOTCHG), 2) AS avg_cost, COUNT(*) AS patient_count
FROM nis_table
GROUP BY LOS
ORDER BY LOS ASC;


-- Top 10 Diagnoses with highest total cost

SELECT  DX1 AS primary_diagnosis, SUM(TOTCHG) AS total_cost, COUNT(*) AS case_count
FROM nis_table
GROUP BY DX1
ORDER BY total_cost DESC
LIMIT 10;


-- Readmission Rate per Age Group

SELECT CASE 
        WHEN AGE < 18 THEN 'Pediatric'
        WHEN AGE BETWEEN 18 AND 44 THEN 'Young Adult'
        WHEN AGE BETWEEN 45 AND 64 THEN 'Middle Age'
        ELSE 'Senior'
       END AS age_group,
    COUNT(*) AS total_cases, SUM(CASE WHEN READMIT = 1 THEN 1 ELSE 0 END) AS readmissions, ROUND(100.0 * SUM(CASE WHEN READMIT = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS readmission_rate
FROM nis_table
GROUP BY age_group
ORDER BY readmission_rate DESC;


-- Create a view for high-cost readmissions.

CREATE VIEW HighCostReadmissions AS
SELECT AGE, SEX, DX1, TOTCHG
FROM nis_table
WHERE READMIT = 1 AND TOTCHG > 75000;

-- Access to the created view

SELECT * FROM HighCostReadmissions;
