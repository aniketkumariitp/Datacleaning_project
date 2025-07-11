-- ------------------------------------------------------------
-- 📁 SQL Project: Layoffs Data Cleaning
-- 🛠️ Goal: Clean raw layoff data for analysis

-- STEP 1: Remove Duplicates
-- Identify and eliminate duplicate records using ROW_NUMBER()

-- STEP 2: Standardize the Data
-- Clean inconsistencies like extra spaces, inconsistent country/industry names, and date formats

-- STEP 3: Handle Null or Blank Values
-- Fill in missing data where possible or decide whether to keep/delete based on context

-- STEP 4: Remove Unnecessary Columns or Rows
-- Drop columns used temporarily and remove rows that don't add value to analysis

-- ------------------------------------------------------------





-- TURN OFF SAFE MODE 
SET SQL_SAFE_UPDATES = 0;

-- USE THE TARGET DATABASE
USE world_layoffs;

--  STEP 1: VIEW RAW DATA
SELECT * FROM layoffs;

-- ----------------------------------------------------
-- CREATE STAGING TABLE TO WORK ON CLEANING
-- ----------------------------------------------------
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- ----------------------------------------------------
-- IDENTIFY DUPLICATES USING ROW_NUMBER()
-- ----------------------------------------------------
SELECT *,
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off,
               percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Using CTE to isolate duplicates
WITH duplicate_cte AS (
  SELECT *,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num
  FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- ----------------------------------------------------
-- DELETE DUPLICATES BY INSERTING CLEANED DATA
-- ----------------------------------------------------
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

--  Insert cleaned data with row numbers
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off,
               percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Delete duplicate rows (row_num > 1)
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Preview cleaned dataset
SELECT * 
FROM layoffs_staging2;

-- ----------------------------------------------------
-- STANDARDIZE VALUES
-- ----------------------------------------------------

--  Trim extra spaces from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

--  Clean country values (like 'United States.')
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

--  Convert string dates to proper DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ----------------------------------------------------
-- HANDLE NULLS & MISSING VALUES
-- ----------------------------------------------------

--  Check for rows with both layoff fields NULL (useless data)
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

--  Delete rows where both layoff values are NULL
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Identify rows with missing industry
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

--  Check if other rows with same company have valid industry
SELECT t1.company, t1.industry AS missing_val, t2.industry AS valid_val
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Fill missing industry using matching company names
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

-- Set empty string industries to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- ----------------------------------------------------
-- FINAL CLEANUP
-- ----------------------------------------------------

-- Drop row_num column used for deduplication
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ✅ Final preview of cleaned table
SELECT * FROM layoffs_staging2;
